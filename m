From: Bernd Schubert <bernd.schubert-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH 1/2] Fix possible Null pointer dereference in
	ipoib_start_xmit()
Date: Tue, 16 Aug 2011 12:56:54 +0200
Message-ID: <20110816105654.1805137.9189.stgit@fsdevel3>
References: <20110816105648.1805137.35191.stgit@fsdevel3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110816105648.1805137.35191.stgit@fsdevel3>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This will fix https://bugzilla.kernel.org/show_bug.cgi?id=41212

fslab2 login: [  114.392408] EXT4-fs (sdc): barriers disabled
[  114.449737] EXT4-fs (sdc): mounted filesystem with writeback data mode.
Opts: journal_async_commit,barrier=0,data=writeback
[  240.944030] BUG: unable to handle kernel NULL pointer dereference at
0000000000000040
[  240.948007] IP: [<ffffffffa0366ce9>] ipoib_start_xmit+0x39/0x280 [ib_ipoib]
[...]
[  240.948007] Call Trace:
[  240.948007]  <IRQ>
[  240.948007]  [<ffffffff812cd5e0>] dev_hard_start_xmit+0x2a0/0x590
[  240.948007]  [<ffffffff8131f680>] ? arp_create+0x70/0x200
[  240.948007]  [<ffffffff812e8e1f>] sch_direct_xmit+0xef/0x1c0

Signed-off-by: Bernd Schubert <bernd.schubert-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 43f89ba..fe89c46 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -717,11 +717,13 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_neigh *neigh;
-	struct neighbour *n;
+	struct neighbour *n = NULL;
 	unsigned long flags;
 
-	n = dst_get_neighbour(skb_dst(skb));
-	if (likely(skb_dst(skb) && n)) {
+	if (likely(skb_dst(skb)))
+		n = dst_get_neighbour(skb_dst(skb));
+
+	if (likely(n)) {
 		if (unlikely(!*to_ipoib_neigh(n))) {
 			ipoib_path_lookup(skb, dev);
 			return NETDEV_TX_OK;

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
