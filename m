From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 4/7] net: tcp_ipv4, udp_ipv4: hook up LOCAL_SOCKET_IN netfilter chains
Date: Tue, 29 Sep 2015 13:12:17 +0200
Message-ID: <1443525140-13493-5-git-send-email-daniel@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:60180 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934622AbbI2LMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 07:12:39 -0400
In-Reply-To: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Run the NF_INET_LOCAL_SOCKET_IN netfilter chain rules after the
destination socket for IPv4 unicast and multicast ports have been
looked up.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/ipv4/netfilter/nf_tables_ipv4.c | 10 +++++-----
 net/ipv4/tcp_ipv4.c                 |  8 ++++++++
 net/ipv4/udp.c                      | 15 +++++++++++++++
 3 files changed, 28 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index abee60a..2e65664 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -50,11 +50,11 @@ struct nft_af_info nft_af_ipv4 __read_mostly = {
 	.owner		= THIS_MODULE,
 	.nops		= 1,
 	.hooks		= {
-		[NF_INET_LOCAL_IN]	= nft_do_chain_ipv4,
-		[NF_INET_LOCAL_OUT]	= nft_ipv4_output,
-		[NF_INET_FORWARD]	= nft_do_chain_ipv4,
-		[NF_INET_PRE_ROUTING]	= nft_do_chain_ipv4,
-		[NF_INET_POST_ROUTING]	= nft_do_chain_ipv4,
+		[NF_INET_LOCAL_IN]		= nft_do_chain_ipv4,
+		[NF_INET_LOCAL_OUT]		= nft_ipv4_output,
+		[NF_INET_FORWARD]		= nft_do_chain_ipv4,
+		[NF_INET_PRE_ROUTING]		= nft_do_chain_ipv4,
+		[NF_INET_POST_ROUTING]		= nft_do_chain_ipv4,
 		[NF_INET_LOCAL_SOCKET_IN]	= nft_do_chain_ipv4,
 	},
 };
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 93898e0..83bc7b3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -78,6 +78,7 @@
 
 #include <linux/inet.h>
 #include <linux/ipv6.h>
+#include <linux/netfilter.h>
 #include <linux/stddef.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -1594,6 +1595,13 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	if (!sk)
 		goto no_tcp_socket;
 
+	ret = nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_SOCKET_IN, sk,
+		      skb, skb->dev, NULL, NULL);
+	if (ret != 1) {
+		sock_put(sk);
+		return 0;
+	}
+
 process:
 	if (sk->sk_state == TCP_TIME_WAIT)
 		goto do_time_wait;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f7d1d5e..57c7571 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -97,6 +97,7 @@
 #include <linux/mm.h>
 #include <linux/inet.h>
 #include <linux/netdevice.h>
+#include <linux/netfilter.h>
 #include <linux/slab.h>
 #include <net/tcp_states.h>
 #include <linux/skbuff.h>
@@ -1633,7 +1634,14 @@ static void flush_stack(struct sock **stack, unsigned int count,
 	struct sock *sk;
 
 	for (i = 0; i < count; i++) {
+		int ret;
 		sk = stack[i];
+
+		ret = nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_SOCKET_IN, sk,
+			      skb, skb->dev, NULL, NULL);
+		if (ret != 1)
+			continue;
+
 		if (likely(!skb1))
 			skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
 
@@ -1820,6 +1828,13 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk) {
 		int ret;
 
+		ret = nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_SOCKET_IN, sk,
+			      skb, skb->dev, NULL, NULL);
+		if (ret != 1) {
+			sock_put(sk);
+			return 0;
+		}
+
 		if (inet_get_convert_csum(sk) && uh->check && !IS_UDPLITE(sk))
 			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
 						 inet_compute_pseudo);
-- 
2.5.0
