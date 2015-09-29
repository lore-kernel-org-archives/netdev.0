From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 5/7] net: tcp_ipv6, udp_ipv6: hook up LOCAL_SOCKET_IN netfilter chains
Date: Tue, 29 Sep 2015 13:12:18 +0200
Message-ID: <1443525140-13493-6-git-send-email-daniel@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Run the NF_INET_LOCAL_SOCKET_IN netfilter chain rules after the
destination socket for IPv6 unicast and multicast ports have been
looked up.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/ipv6/netfilter/nf_tables_ipv6.c | 14 ++++++++------
 net/ipv6/tcp_ipv6.c                 |  8 ++++++++
 net/ipv6/udp.c                      |  9 +++++++++
 3 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index c8148ba..53c7923 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -49,11 +49,12 @@ struct nft_af_info nft_af_ipv6 __read_mostly = {
 	.owner		= THIS_MODULE,
 	.nops		= 1,
 	.hooks		= {
-		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv6,
-		[NF_INET_LOCAL_OUT]	= nft_ipv6_output,
-		[NF_INET_FORWARD]	= nft_do_chain_ipv6,
-		[NF_INET_PRE_ROUTING]	= nft_do_chain_ipv6,
-		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv6,
+		[NF_INET_LOCAL_IN]		= nft_do_chain_ipv6,
+		[NF_INET_LOCAL_OUT]		= nft_ipv6_output,
+		[NF_INET_FORWARD]		= nft_do_chain_ipv6,
+		[NF_INET_PRE_ROUTING]		= nft_do_chain_ipv6,
+		[NF_INET_POST_ROUTING]		= nft_do_chain_ipv6,
+		[NF_INET_LOCAL_SOCKET_IN]	= nft_do_chain_ipv6,
 	},
 };
 EXPORT_SYMBOL_GPL(nft_af_ipv6);
@@ -95,7 +96,8 @@ static const struct nf_chain_type filter_ipv6 = {
 			  (1 << NF_INET_LOCAL_OUT) |
 			  (1 << NF_INET_FORWARD) |
 			  (1 << NF_INET_PRE_ROUTING) |
-			  (1 << NF_INET_POST_ROUTING),
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_SOCKET_IN),
 };
 
 static int __init nf_tables_ipv6_init(void)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 97d9314..0b0706d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -37,6 +37,7 @@
 #include <linux/init.h>
 #include <linux/jhash.h>
 #include <linux/ipsec.h>
+#include <linux/netfilter.h>
 #include <linux/times.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
@@ -1392,6 +1393,13 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	ret = nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_SOCKET_IN, sk,
+		      skb, skb->dev, NULL, NULL);
+	if (ret != 1) {
+		sock_put(sk);
+		return 0;
+	}
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 0aba654..99df081 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -33,6 +33,7 @@
 #include <linux/icmpv6.h>
 #include <linux/init.h>
 #include <linux/module.h>
+#include <linux/netfilter.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <asm/uaccess.h>
@@ -746,7 +747,15 @@ static void flush_stack(struct sock **stack, unsigned int count,
 	unsigned int i;
 
 	for (i = 0; i < count; i++) {
+		int ret;
+
 		sk = stack[i];
+
+		ret = nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_SOCKET_IN, sk,
+			      skb, skb->dev, NULL, NULL);
+		if (ret != 1)
+			continue;
+
 		if (likely(!skb1))
 			skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
 		if (!skb1) {
-- 
2.5.0

