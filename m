From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 11/16] Don't lookup the socket if there's a socket
	attached to the skb
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.42034.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the socket cached in the TPROXY target if it's present.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 net/ipv4/udp.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 28c3c31..230cd8c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -360,6 +360,14 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct hlist_head udptable[])
 	int err;
 	struct net *net = dev_net(skb->dev);
 
+#if defined(CONFIG_NETFILTER_TPROXY) || defined(CONFIG_NETFILTER_TPROXY_MODULE)
+	if (unlikely(skb->sk)) {
+		/* steal reference */
+		sk = skb->sk;
+		skb->destructor = NULL;
+		skb->sk = NULL;
+	} else
+#endif
 	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
 			iph->saddr, uh->source, skb->dev->ifindex, udptable);
 	if (sk == NULL) {
@@ -1198,6 +1206,14 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 		return __udp4_lib_mcast_deliver(net, skb, uh,
 				saddr, daddr, udptable);
 
+#if defined(CONFIG_NETFILTER_TPROXY) || defined(CONFIG_NETFILTER_TPROXY_MODULE)
+	if (unlikely(skb->sk)) {
+		/* steal reference */
+		sk = skb->sk;
+		skb->destructor = NULL;
+		skb->sk = NULL;
+	} else
+#endif
 	sk = __udp4_lib_lookup(net, saddr, uh->source, daddr,
 			uh->dest, inet_iif(skb), udptable);
 


