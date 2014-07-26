From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 3.15 075/109] xen-netback: Fix handling
	frag_list on grant op error path
Date: Sat, 26 Jul 2014 12:02:37 -0700
Message-ID: <20140726190226.131386964@linuxfoundation.org>
References: <20140726190223.834037485@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
	Zoltan Kiss <zoltan.kiss@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, Armin Zentai <armin.zentai@ezit.hu>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20140726190223.834037485@linuxfoundation.org>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

3.15-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Zoltan Kiss <zoltan.kiss@citrix.com>

[ Upstream commit 1a998d3e6bc1e44f4c0bc7509bdedef8ed3845ec ]

The error handling for skb's with frag_list was completely wrong, it caused
double unmap attempts to happen if the error was on the first skb. Move it to
the right place in the loop.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Reported-by: Armin Zentai <armin.zentai@ezit.hu>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/xen-netback/netback.c |   37 ++++++++++++++++++++-----------------
 1 file changed, 20 insertions(+), 17 deletions(-)

--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1007,10 +1007,16 @@ static int xenvif_tx_check_gop(struct xe
 {
 	struct gnttab_map_grant_ref *gop_map = *gopp_map;
 	u16 pending_idx = XENVIF_TX_CB(skb)->pending_idx;
+	/* This always points to the shinfo of the skb being checked, which
+	 * could be either the first or the one on the frag_list
+	 */
 	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	/* If this is non-NULL, we are currently checking the frag_list skb, and
+	 * this points to the shinfo of the first one
+	 */
+	struct skb_shared_info *first_shinfo = NULL;
 	int nr_frags = shinfo->nr_frags;
 	int i, err;
-	struct sk_buff *first_skb = NULL;
 
 	/* Check status of header. */
 	err = (*gopp_copy)->status;
@@ -1063,31 +1069,28 @@ check_frags:
 			xenvif_idx_unmap(vif, pending_idx);
 		}
 
+		/* And if we found the error while checking the frag_list, unmap
+		 * the first skb's frags
+		 */
+		if (first_shinfo) {
+			for (j = 0; j < first_shinfo->nr_frags; j++) {
+				pending_idx = frag_get_pending_idx(&first_shinfo->frags[j]);
+				xenvif_idx_unmap(vif, pending_idx);
+			}
+		}
+
 		/* Remember the error: invalidate all subsequent fragments. */
 		err = newerr;
 	}
 
-	if (skb_has_frag_list(skb)) {
-		first_skb = skb;
-		skb = shinfo->frag_list;
-		shinfo = skb_shinfo(skb);
+	if (skb_has_frag_list(skb) && !first_shinfo) {
+		first_shinfo = skb_shinfo(skb);
+		shinfo = skb_shinfo(skb_shinfo(skb)->frag_list);
 		nr_frags = shinfo->nr_frags;
 
 		goto check_frags;
 	}
 
-	/* There was a mapping error in the frag_list skb. We have to unmap
-	 * the first skb's frags
-	 */
-	if (first_skb && err) {
-		int j;
-		shinfo = skb_shinfo(first_skb);
-		for (j = 0; j < shinfo->nr_frags; j++) {
-			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
-			xenvif_idx_unmap(vif, pending_idx);
-		}
-	}
-
 	*gopp_map = gop_map;
 	return err;
 }
