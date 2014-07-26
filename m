From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 3.15 076/109] xen-netback: Fix releasing frag_list skbs in error path
Date: Sat, 26 Jul 2014 12:02:38 -0700
Message-ID: <20140726190226.160782147@linuxfoundation.org>
References: <20140726190223.834037485@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, Zoltan Kiss <zoltan.kiss@citrix.com>,
	Armin Zentai <armin.zentai@ezit.hu>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140726190223.834037485@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.15-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Zoltan Kiss <zoltan.kiss@citrix.com>

[ Upstream commit b42cc6e421e7bf74e545483aa34b99d2a2ca6d3a ]

When the grant operations failed, the skb is freed up eventually, and it tries
to release the frags, if there is any. For the main skb nr_frags is set to 0 to
avoid this, but on the frag_list it iterates through the frags array, and tries
to call put_page on the page pointer which contains garbage at that time.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Reported-by: Armin Zentai <armin.zentai@ezit.hu>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/xen-netback/netback.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1498,7 +1498,16 @@ static int xenvif_tx_submit(struct xenvi
 
 		/* Check the remap error code. */
 		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop_map, &gop_copy))) {
+			/* If there was an error, xenvif_tx_check_gop is
+			 * expected to release all the frags which were mapped,
+			 * so kfree_skb shouldn't do it again
+			 */
 			skb_shinfo(skb)->nr_frags = 0;
+			if (skb_has_frag_list(skb)) {
+				struct sk_buff *nskb =
+						skb_shinfo(skb)->frag_list;
+				skb_shinfo(nskb)->nr_frags = 0;
+			}
 			kfree_skb(skb);
 			continue;
 		}
