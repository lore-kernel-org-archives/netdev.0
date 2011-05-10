From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/10] ipv4: Pass explicit daddr arg to ip_send_reply().
Date: Mon, 09 May 2011 22:31:10 -0700 (PDT)
Message-ID: <20110509.223110.59684485.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751659Ab1EJFbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:31:42 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CA7D424C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This eliminates an access to rt->rt_src.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip.h     |    4 ++--
 net/ipv4/ip_output.c |    7 +++----
 net/ipv4/tcp_ipv4.c  |    4 ++--
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 0b30d3a..07118c7 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -174,8 +174,8 @@ static inline __u8 ip_reply_arg_flowi_flags(const struct ip_reply_arg *arg)
 	return (arg->flags & IP_REPLY_ARG_NOSRCCHECK) ? FLOWI_FLAG_ANYSRC : 0;
 }
 
-void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *arg,
-		   unsigned int len); 
+void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
+		   struct ip_reply_arg *arg, unsigned int len); 
 
 struct ipv4_config {
 	int	log_martians;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index cd89d22..70778d4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1459,20 +1459,19 @@ static int ip_reply_glue_bits(void *dptr, char *to, int offset,
  *	Should run single threaded per socket because it uses the sock
  *     	structure to pass arguments.
  */
-void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *arg,
-		   unsigned int len)
+void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
+		   struct ip_reply_arg *arg, unsigned int len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options_data replyopts;
 	struct ipcm_cookie ipc;
 	struct flowi4 fl4;
-	__be32 daddr;
 	struct rtable *rt = skb_rtable(skb);
 
 	if (ip_options_echo(&replyopts.opt.opt, skb))
 		return;
 
-	daddr = ipc.addr = rt->rt_src;
+	ipc.addr = daddr;
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2b65503..f67fb34 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -651,7 +651,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 	arg.flags = (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRCCHECK : 0;
 
 	net = dev_net(skb_dst(skb)->dev);
-	ip_send_reply(net->ipv4.tcp_sock, skb,
+	ip_send_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
 		      &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
@@ -726,7 +726,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 	if (oif)
 		arg.bound_dev_if = oif;
 
-	ip_send_reply(net->ipv4.tcp_sock, skb,
+	ip_send_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
 		      &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
-- 
1.7.5.1

