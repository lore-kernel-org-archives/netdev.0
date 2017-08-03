From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 2/4] ip/options: explicitly provide net ns to __ip_options_echo()
Date: Thu,  3 Aug 2017 18:07:06 +0200
Message-ID: <31096a330a56cfd40eea136be505270184fbb5d4.1501775813.git.pabeni@redhat.com>
References: <cover.1501775813.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51720 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751629AbdHCQHh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 12:07:37 -0400
In-Reply-To: <cover.1501775813.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ip_options_echo() uses the current network namespace, and
currently retrives it via skb->dst->dev.

This commit adds an explicit 'net' argument to __ip_options_echo()
and update all the call sites to provide it, usually via a simpler
sock_net().

After this change, __ip_options_echo() no more needs to access
skb->dst and we can drop a couple of hack to preserve such
info in the rx path.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/ip.h       | 9 +++++----
 include/net/tcp.h      | 5 +++--
 net/ipv4/icmp.c        | 4 ++--
 net/ipv4/ip_options.c  | 6 +++---
 net/ipv4/ip_output.c   | 2 +-
 net/ipv4/ip_sockglue.c | 7 ++++---
 net/ipv4/syncookies.c  | 2 +-
 net/ipv4/tcp_ipv4.c    | 2 +-
 8 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 821cedcc8e73..9e59dcf1787a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -567,11 +567,12 @@ int ip_forward(struct sk_buff *skb);
 void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
 		      __be32 daddr, struct rtable *rt, int is_frag);
 
-int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
-		      const struct ip_options *sopt);
-static inline int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
+int __ip_options_echo(struct net *net, struct ip_options *dopt,
+		      struct sk_buff *skb, const struct ip_options *sopt);
+static inline int ip_options_echo(struct net *net, struct ip_options *dopt,
+				  struct sk_buff *skb)
 {
-	return __ip_options_echo(dopt, skb, &IPCB(skb)->opt);
+	return __ip_options_echo(net, dopt, skb, &IPCB(skb)->opt);
 }
 
 void ip_options_fragment(struct sk_buff *skb);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index bb1881b4ce48..5173fecde495 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1885,7 +1885,8 @@ extern void tcp_rack_reo_timeout(struct sock *sk);
 /*
  * Save and compile IPv4 options, return a pointer to it
  */
-static inline struct ip_options_rcu *tcp_v4_save_options(struct sk_buff *skb)
+static inline struct ip_options_rcu *tcp_v4_save_options(struct net *net,
+							 struct sk_buff *skb)
 {
 	const struct ip_options *opt = &TCP_SKB_CB(skb)->header.h4.opt;
 	struct ip_options_rcu *dopt = NULL;
@@ -1894,7 +1895,7 @@ static inline struct ip_options_rcu *tcp_v4_save_options(struct sk_buff *skb)
 		int opt_size = sizeof(*dopt) + opt->optlen;
 
 		dopt = kmalloc(opt_size, GFP_ATOMIC);
-		if (dopt && __ip_options_echo(&dopt->opt, skb, opt)) {
+		if (dopt && __ip_options_echo(net, &dopt->opt, skb, opt)) {
 			kfree(dopt);
 			dopt = NULL;
 		}
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index c2be26b98b5f..681e33998e03 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -412,7 +412,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	int type = icmp_param->data.icmph.type;
 	int code = icmp_param->data.icmph.code;
 
-	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb))
+	if (ip_options_echo(net, &icmp_param->replyopts.opt.opt, skb))
 		return;
 
 	/* Needed by both icmp_global_allow and icmp_xmit_lock */
@@ -694,7 +694,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 					  iph->tos;
 	mark = IP4_REPLY_MARK(net, skb_in->mark);
 
-	if (ip_options_echo(&icmp_param.replyopts.opt.opt, skb_in))
+	if (ip_options_echo(net, &icmp_param.replyopts.opt.opt, skb_in))
 		goto out_unlock;
 
 
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index fdda97308c0b..525ae88d1e58 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -86,8 +86,8 @@ void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
  * NOTE: dopt cannot point to skb.
  */
 
-int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
-		      const struct ip_options *sopt)
+int __ip_options_echo(struct net *net, struct ip_options *dopt,
+		      struct sk_buff *skb, const struct ip_options *sopt)
 {
 	unsigned char *sptr, *dptr;
 	int soffset, doffset;
@@ -140,7 +140,7 @@ int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
 						__be32 addr;
 
 						memcpy(&addr, dptr+soffset-1, 4);
-						if (inet_addr_type(dev_net(skb_dst(skb)->dev), addr) != RTN_UNICAST) {
+						if (inet_addr_type(net, addr) != RTN_UNICAST) {
 							dopt->ts_needtime = 1;
 							soffset += 8;
 						}
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b631ec685d77..73b0b15245b6 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1525,7 +1525,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	int err;
 	int oif;
 
-	if (__ip_options_echo(&replyopts.opt.opt, skb, sopt))
+	if (__ip_options_echo(net, &replyopts.opt.opt, skb, sopt))
 		return;
 
 	ipc.addr = daddr;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index ecc4b4a2413e..1c3354d028a4 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -80,7 +80,8 @@ static void ip_cmsg_recv_opts(struct msghdr *msg, struct sk_buff *skb)
 }
 
 
-static void ip_cmsg_recv_retopts(struct msghdr *msg, struct sk_buff *skb)
+static void ip_cmsg_recv_retopts(struct net *net, struct msghdr *msg,
+				 struct sk_buff *skb)
 {
 	unsigned char optbuf[sizeof(struct ip_options) + 40];
 	struct ip_options *opt = (struct ip_options *)optbuf;
@@ -88,7 +89,7 @@ static void ip_cmsg_recv_retopts(struct msghdr *msg, struct sk_buff *skb)
 	if (IPCB(skb)->opt.optlen == 0)
 		return;
 
-	if (ip_options_echo(opt, skb)) {
+	if (ip_options_echo(net, opt, skb)) {
 		msg->msg_flags |= MSG_CTRUNC;
 		return;
 	}
@@ -204,7 +205,7 @@ void ip_cmsg_recv_offset(struct msghdr *msg, struct sock *sk,
 	}
 
 	if (flags & IP_CMSG_RETOPTS) {
-		ip_cmsg_recv_retopts(msg, skb);
+		ip_cmsg_recv_retopts(sock_net(sk), msg, skb);
 
 		flags &= ~IP_CMSG_RETOPTS;
 		if (!flags)
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 03ad8778c395..b1bb1b3a1082 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -355,7 +355,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
 	 */
-	ireq->opt = tcp_v4_save_options(skb);
+	ireq->opt = tcp_v4_save_options(sock_net(sk), skb);
 
 	if (security_inet_conn_request(sk, skb, req)) {
 		reqsk_free(req);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9b51663cd5a4..5f708c85110e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1267,7 +1267,7 @@ static void tcp_v4_init_req(struct request_sock *req,
 
 	sk_rcv_saddr_set(req_to_sk(req), ip_hdr(skb)->daddr);
 	sk_daddr_set(req_to_sk(req), ip_hdr(skb)->saddr);
-	ireq->opt = tcp_v4_save_options(skb);
+	ireq->opt = tcp_v4_save_options(sock_net(sk_listener), skb);
 }
 
 static struct dst_entry *tcp_v4_route_req(const struct sock *sk,
-- 
2.13.3
