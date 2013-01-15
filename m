From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [ 103/221] xen/netfront: improve truesize tracking
Date: Tue, 15 Jan 2013 10:50:30 -0800
Message-ID: <20130115185005.470007939@linuxfoundation.org>
References: <20130115184958.025580322@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Dumazet <edumazet@google.com>, xen-devel@lists.xen.org,
	Sander Eikelenboom <linux@eikelenboom.it>,
	annie li <annie.li@oracle.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20130115184958.025580322@linuxfoundation.org>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

3.7-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Ian Campbell <Ian.Campbell@citrix.com>

commit d9a58a782e396a0f04e8445b7ba3763c8a48c7fe upstream.

Using RX_COPY_THRESHOLD is incorrect if the SKB is actually smaller
than that. We have already accounted for this in
NETFRONT_SKB_CB(skb)->pull_to so use that instead.

Fixes WARN_ON from skb_try_coalesce.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Sander Eikelenboom <linux@eikelenboom.it>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: annie li <annie.li@oracle.com>
Cc: xen-devel@lists.xen.org
Cc: netdev@vger.kernel.org
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 drivers/net/xen-netfront.c |   27 ++++-----------------------
 1 file changed, 4 insertions(+), 23 deletions(-)

--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1015,29 +1015,10 @@ err:
 		i = xennet_fill_frags(np, skb, &tmpq);
 
 		/*
-		 * Truesize approximates the size of true data plus
-		 * any supervisor overheads. Adding hypervisor
-		 * overheads has been shown to significantly reduce
-		 * achievable bandwidth with the default receive
-		 * buffer size. It is therefore not wise to account
-		 * for it here.
-		 *
-		 * After alloc_skb(RX_COPY_THRESHOLD), truesize is set
-		 * to RX_COPY_THRESHOLD + the supervisor
-		 * overheads. Here, we add the size of the data pulled
-		 * in xennet_fill_frags().
-		 *
-		 * We also adjust for any unused space in the main
-		 * data area by subtracting (RX_COPY_THRESHOLD -
-		 * len). This is especially important with drivers
-		 * which split incoming packets into header and data,
-		 * using only 66 bytes of the main data area (see the
-		 * e1000 driver for example.)  On such systems,
-		 * without this last adjustement, our achievable
-		 * receive throughout using the standard receive
-		 * buffer size was cut by 25%(!!!).
-		 */
-		skb->truesize += skb->data_len - RX_COPY_THRESHOLD;
+                 * Truesize is the actual allocation size, even if the
+                 * allocation is only partially used.
+                 */
+		skb->truesize += PAGE_SIZE * skb_shinfo(skb)->nr_frags;
 		skb->len += skb->data_len;
 
 		if (rx->flags & XEN_NETRXF_csum_blank)
