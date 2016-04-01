From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH v2 net-next 6/8] ipv6: process socket-level control messages in IPv6
Date: Fri,  1 Apr 2016 11:04:38 -0400
Message-ID: <1459523080-29329-7-git-send-email-soheil.kdev@gmail.com>
References: <1459523080-29329-1-git-send-email-soheil.kdev@gmail.com>
Cc: willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, kafai@fb.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:34769 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758920AbcDAPEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:04:46 -0400
Received: by mail-qg0-f67.google.com with SMTP id j35so11432197qge.1
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:04:46 -0700 (PDT)
In-Reply-To: <1459523080-29329-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Process socket-level control messages by invoking
__sock_cmsg_send in ip6_datagram_send_ctl for control messages on
the SOL_SOCKET layer.

This makes sure whenever ip6_datagram_send_ctl is called for
udp and raw, we also process socket-level control messages.

This is a bit uglier than IPv4, since IPv6 does not have
something like ipcm_cookie. Perhaps we can later create
a control message cookie for IPv6?

Note that this commit interprets new control messages that
were ignored before. As such, this commit does not change
the behavior of IPv6 control messages.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Willem de Bruijn <willemb@google.com>
---
 include/net/transp_v6.h  | 3 ++-
 net/ipv6/datagram.c      | 9 ++++++++-
 net/ipv6/ip6_flowlabel.c | 3 ++-
 net/ipv6/ipv6_sockglue.c | 3 ++-
 net/ipv6/raw.c           | 6 +++++-
 net/ipv6/udp.c           | 5 ++++-
 6 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index b927413..2b1c345 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -42,7 +42,8 @@ void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 
 int ip6_datagram_send_ctl(struct net *net, struct sock *sk, struct msghdr *msg,
 			  struct flowi6 *fl6, struct ipv6_txoptions *opt,
-			  int *hlimit, int *tclass, int *dontfrag);
+			  int *hlimit, int *tclass, int *dontfrag,
+			  struct sockcm_cookie *sockc);
 
 void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
 			     __u16 srcp, __u16 destp, int bucket);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 4281621..a73d701 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -685,7 +685,8 @@ EXPORT_SYMBOL_GPL(ip6_datagram_recv_ctl);
 int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 			  struct msghdr *msg, struct flowi6 *fl6,
 			  struct ipv6_txoptions *opt,
-			  int *hlimit, int *tclass, int *dontfrag)
+			  int *hlimit, int *tclass, int *dontfrag,
+			  struct sockcm_cookie *sockc)
 {
 	struct in6_pktinfo *src_info;
 	struct cmsghdr *cmsg;
@@ -702,6 +703,12 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 			goto exit_f;
 		}
 
+		if (cmsg->cmsg_level == SOL_SOCKET) {
+			if (__sock_cmsg_send(sk, msg, cmsg, sockc))
+				return -EINVAL;
+			continue;
+		}
+
 		if (cmsg->cmsg_level != SOL_IPV6)
 			continue;
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index dc2db4f..35d3ddc 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -372,6 +372,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 	if (olen > 0) {
 		struct msghdr msg;
 		struct flowi6 flowi6;
+		struct sockcm_cookie sockc_junk;
 		int junk;
 
 		err = -ENOMEM;
@@ -390,7 +391,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 		memset(&flowi6, 0, sizeof(flowi6));
 
 		err = ip6_datagram_send_ctl(net, sk, &msg, &flowi6, fl->opt,
-					    &junk, &junk, &junk);
+					    &junk, &junk, &junk, &sockc_junk);
 		if (err)
 			goto done;
 		err = -EINVAL;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4449ad1..a5557d2 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -471,6 +471,7 @@ sticky_done:
 		struct ipv6_txoptions *opt = NULL;
 		struct msghdr msg;
 		struct flowi6 fl6;
+		struct sockcm_cookie sockc_junk;
 		int junk;
 
 		memset(&fl6, 0, sizeof(fl6));
@@ -503,7 +504,7 @@ sticky_done:
 		msg.msg_control = (void *)(opt+1);
 
 		retv = ip6_datagram_send_ctl(net, sk, &msg, &fl6, opt, &junk,
-					     &junk, &junk);
+					     &junk, &junk, &sockc_junk);
 		if (retv)
 			goto done;
 update:
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fa59dd7..f175ec0 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -745,6 +745,7 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	struct dst_entry *dst = NULL;
 	struct raw6_frag_vec rfv;
 	struct flowi6 fl6;
+	struct sockcm_cookie sockc;
 	int addr_len = msg->msg_namelen;
 	int hlimit = -1;
 	int tclass = -1;
@@ -821,13 +822,16 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (fl6.flowi6_oif == 0)
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 
+	sockc.tsflags = 0;
+
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
 		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					    &hlimit, &tclass, &dontfrag);
+					    &hlimit, &tclass, &dontfrag,
+					    &sockc);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fd25e44..8371a51 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1128,6 +1128,7 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	int connected = 0;
 	int is_udplite = IS_UDPLITE(sk);
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
+	struct sockcm_cookie sockc;
 
 	/* destination address check */
 	if (sin6) {
@@ -1247,6 +1248,7 @@ do_udp_sendmsg:
 		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
 
 	fl6.flowi6_mark = sk->sk_mark;
+	sockc.tsflags = 0;
 
 	if (msg->msg_controllen) {
 		opt = &opt_space;
@@ -1254,7 +1256,8 @@ do_udp_sendmsg:
 		opt->tot_len = sizeof(*opt);
 
 		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					    &hlimit, &tclass, &dontfrag);
+					    &hlimit, &tclass, &dontfrag,
+					    &sockc);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
-- 
2.8.0.rc3.226.g39d4020
