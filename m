From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2 2/3] net: export some generic xdp helpers
Date: Fri, 11 Aug 2017 19:41:17 +0800
Message-ID: <1502451678-17358-3-git-send-email-jasowang@redhat.com>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
Cc: kubakici@wp.pl, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch tries to export some generic xdp helpers to drivers. This
can let driver to do XDP for a specific skb. This is useful for the
case when the packet is hard to be processed at page level directly
(e.g jumbo/GSO frame).

With this patch, there's no need for driver to forbid the XDP set when
configuration is not suitable. Instead, it can defer the XDP for
packets that is hard to be processed directly after skb is created.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/netdevice.h |  2 ++
 net/core/dev.c            | 14 ++++++++------
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1d238d5..0f1c4cb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3243,6 +3243,8 @@ static inline void dev_consume_skb_any(struct sk_buff *skb)
 	__dev_kfree_skb_any(skb, SKB_REASON_CONSUMED);
 }
 
+void generic_xdp_tx(struct sk_buff *skb, struct bpf_prog *xdp_prog);
+int do_xdp_generic(struct bpf_prog *xdp_prog, struct sk_buff *skb);
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
 int netif_receive_skb(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 3f69f6e..1a6657a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3920,7 +3920,7 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 /* When doing generic XDP we have to bypass the qdisc layer and the
  * network taps in order to match in-driver-XDP behavior.
  */
-static void generic_xdp_tx(struct sk_buff *skb, struct bpf_prog *xdp_prog)
+void generic_xdp_tx(struct sk_buff *skb, struct bpf_prog *xdp_prog)
 {
 	struct net_device *dev = skb->dev;
 	struct netdev_queue *txq;
@@ -3941,13 +3941,12 @@ static void generic_xdp_tx(struct sk_buff *skb, struct bpf_prog *xdp_prog)
 		kfree_skb(skb);
 	}
 }
+EXPORT_SYMBOL_GPL(generic_xdp_tx);
 
 static struct static_key generic_xdp_needed __read_mostly;
 
-static int do_xdp_generic(struct sk_buff *skb)
+int do_xdp_generic(struct bpf_prog *xdp_prog, struct sk_buff *skb)
 {
-	struct bpf_prog *xdp_prog = rcu_dereference(skb->dev->xdp_prog);
-
 	if (xdp_prog) {
 		u32 act = netif_receive_generic_xdp(skb, xdp_prog);
 		int err;
@@ -3972,6 +3971,7 @@ static int do_xdp_generic(struct sk_buff *skb)
 	kfree_skb(skb);
 	return XDP_DROP;
 }
+EXPORT_SYMBOL_GPL(do_xdp_generic);
 
 static int netif_rx_internal(struct sk_buff *skb)
 {
@@ -3982,7 +3982,8 @@ static int netif_rx_internal(struct sk_buff *skb)
 	trace_netif_rx(skb);
 
 	if (static_key_false(&generic_xdp_needed)) {
-		int ret = do_xdp_generic(skb);
+		int ret = do_xdp_generic(rcu_dereference(skb->dev->xdp_prog),
+					 skb);
 
 		/* Consider XDP consuming the packet a success from
 		 * the netdev point of view we do not want to count
@@ -4503,7 +4504,8 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
 	rcu_read_lock();
 
 	if (static_key_false(&generic_xdp_needed)) {
-		int ret = do_xdp_generic(skb);
+		int ret = do_xdp_generic(rcu_dereference(skb->dev->xdp_prog),
+					 skb);
 
 		if (ret != XDP_PASS) {
 			rcu_read_unlock();
-- 
2.7.4
