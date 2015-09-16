From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 27/30] bridge: Add br_netif_receive_skb remove netif_receive_skb_sk
Date: Tue, 15 Sep 2015 20:04:15 -0500
Message-ID: <1442365458-16349-27-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netif_receive_skb_sk is only called once in the bridge code, replace
it with a bridge specific function that calls netif_receive_skb.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netdevice.h | 6 +-----
 net/bridge/br_input.c     | 7 ++++++-
 net/core/dev.c            | 4 ++--
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e664f87c8e4c..97ab5c9a7069 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2985,11 +2985,7 @@ static inline void dev_consume_skb_any(struct sk_buff *skb)
 
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
-int netif_receive_skb_sk(struct sock *sk, struct sk_buff *skb);
-static inline int netif_receive_skb(struct sk_buff *skb)
-{
-	return netif_receive_skb_sk(skb->sk, skb);
-}
+int netif_receive_skb(struct sk_buff *skb);
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
 void napi_gro_flush(struct napi_struct *napi, bool flush_old);
 struct sk_buff *napi_get_frags(struct napi_struct *napi);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f921a5dce22d..2359c041e27c 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -26,6 +26,11 @@
 br_should_route_hook_t __rcu *br_should_route_hook __read_mostly;
 EXPORT_SYMBOL(br_should_route_hook);
 
+static int br_netif_receive_skb(struct sock *sk, struct sk_buff *skb)
+{
+	return netif_receive_skb(skb);
+}
+
 static int br_pass_frame_up(struct sk_buff *skb)
 {
 	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
@@ -57,7 +62,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 
 	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, NULL, skb,
 		       indev, NULL,
-		       netif_receive_skb_sk);
+		       br_netif_receive_skb);
 }
 
 static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
diff --git a/net/core/dev.c b/net/core/dev.c
index dcf9ff913925..7db9b012dfb7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3982,13 +3982,13 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
  *	NET_RX_SUCCESS: no congestion
  *	NET_RX_DROP: packet was dropped
  */
-int netif_receive_skb_sk(struct sock *sk, struct sk_buff *skb)
+int netif_receive_skb(struct sk_buff *skb)
 {
 	trace_netif_receive_skb_entry(skb);
 
 	return netif_receive_skb_internal(skb);
 }
-EXPORT_SYMBOL(netif_receive_skb_sk);
+EXPORT_SYMBOL(netif_receive_skb);
 
 /* Network device is going away, flush any packets still pending
  * Called with irqs disabled.
-- 
2.2.1

