From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH 2/3] IPv6: Add dontfrag argument to relevant functions
Date: Fri, 23 Apr 2010 17:26:08 -0400
Message-ID: <1272057969-6526-3-git-send-email-brian.haley@hp.com>
References: <>
 <1272057969-6526-1-git-send-email-brian.haley@hp.com>
 <1272057969-6526-2-git-send-email-brian.haley@hp.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:42518 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544Ab0DWVei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 17:34:38 -0400
In-Reply-To: <1272057969-6526-2-git-send-email-brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dontfrag argument to relevant functions for
IPV6_DONTFRAG support, as well as allowing the value
to be passed-in via ancillary cmsg data.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
 include/net/ipv6.h       |    3 ++-
 include/net/transp_v6.h  |    3 ++-
 net/ipv6/datagram.c      |   21 ++++++++++++++++++++-
 net/ipv6/icmp.c          |    5 +++--
 net/ipv6/ip6_flowlabel.c |    3 ++-
 net/ipv6/ip6_output.c    |    2 +-
 net/ipv6/ipv6_sockglue.c |    3 ++-
 net/ipv6/raw.c           |    9 +++++++--
 net/ipv6/udp.c           |    9 +++++++--
 9 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index b1d8db9..7ab6323 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -503,7 +503,8 @@ extern int			ip6_append_data(struct sock *sk,
 						struct ipv6_txoptions *opt,
 						struct flowi *fl,
 						struct rt6_info *rt,
-						unsigned int flags);
+						unsigned int flags,
+						int dontfrag);
 
 extern int			ip6_push_pending_frames(struct sock *sk);
 
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index d65381c..42a0eb6 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -44,7 +44,8 @@ extern int			datagram_send_ctl(struct net *net,
 						  struct msghdr *msg,
 						  struct flowi *fl,
 						  struct ipv6_txoptions *opt,
-						  int *hlimit, int *tclass);
+						  int *hlimit, int *tclass,
+						  int *dontfrag);
 
 #define		LOOPBACK4_IPV6		cpu_to_be32(0x7f000006)
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 622dc79..f5076d3 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -497,7 +497,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 int datagram_send_ctl(struct net *net,
 		      struct msghdr *msg, struct flowi *fl,
 		      struct ipv6_txoptions *opt,
-		      int *hlimit, int *tclass)
+		      int *hlimit, int *tclass, int *dontfrag)
 {
 	struct in6_pktinfo *src_info;
 	struct cmsghdr *cmsg;
@@ -737,6 +737,25 @@ int datagram_send_ctl(struct net *net,
 
 			break;
 		    }
+
+		case IPV6_DONTFRAG:
+		    {
+			int df;
+
+			err = -EINVAL;
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int))) {
+				goto exit_f;
+			}
+
+			df = *(int *)CMSG_DATA(cmsg);
+			if (df < 0 || df > 1)
+				goto exit_f;
+
+			err = 0;
+			*dontfrag = df;
+
+			break;
+		    }
 		default:
 			LIMIT_NETDEBUG(KERN_DEBUG "invalid cmsg type: %d\n",
 				       cmsg->cmsg_type);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 12d2fa4..ce79929 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -481,7 +481,7 @@ route_done:
 			      len + sizeof(struct icmp6hdr),
 			      sizeof(struct icmp6hdr), hlimit,
 			      np->tclass, NULL, &fl, (struct rt6_info*)dst,
-			      MSG_DONTWAIT);
+			      MSG_DONTWAIT, np->dontfrag);
 	if (err) {
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
 		ip6_flush_pending_frames(sk);
@@ -561,7 +561,8 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
 				sizeof(struct icmp6hdr), hlimit, np->tclass, NULL, &fl,
-				(struct rt6_info*)dst, MSG_DONTWAIT);
+				(struct rt6_info*)dst, MSG_DONTWAIT,
+				np->dontfrag);
 
 	if (err) {
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 14e2321..1365468 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -360,7 +360,8 @@ fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 		msg.msg_control = (void*)(fl->opt+1);
 		flowi.oif = 0;
 
-		err = datagram_send_ctl(net, &msg, &flowi, fl->opt, &junk, &junk);
+		err = datagram_send_ctl(net, &msg, &flowi, fl->opt, &junk,
+					&junk, &junk);
 		if (err)
 			goto done;
 		err = -EINVAL;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 263d4cf..54d43dd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1105,7 +1105,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int offset, int len, int odd, struct sk_buff *skb),
 	void *from, int length, int transhdrlen,
 	int hlimit, int tclass, struct ipv6_txoptions *opt, struct flowi *fl,
-	struct rt6_info *rt, unsigned int flags)
+	struct rt6_info *rt, unsigned int flags, int dontfrag)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 2bf9eda..bd43f01 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -458,7 +458,8 @@ sticky_done:
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
 
-		retv = datagram_send_ctl(net, &msg, &fl, opt, &junk, &junk);
+		retv = datagram_send_ctl(net, &msg, &fl, opt, &junk, &junk,
+					 &junk);
 		if (retv)
 			goto done;
 update:
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8763b1a..44a84ea 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -733,6 +733,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	int addr_len = msg->msg_namelen;
 	int hlimit = -1;
 	int tclass = -1;
+	int dontfrag = -1;
 	u16 proto;
 	int err;
 
@@ -811,7 +812,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
-		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit,
+					&tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
@@ -880,6 +882,9 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (tclass < 0)
 		tclass = np->tclass;
 
+	if (dontfrag < 0)
+		dontfrag = np->dontfrag;
+
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
 
@@ -890,7 +895,7 @@ back_from_confirm:
 		lock_sock(sk);
 		err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
 			len, 0, hlimit, tclass, opt, &fl, (struct rt6_info*)dst,
-			msg->msg_flags);
+			msg->msg_flags, dontfrag);
 
 		if (err)
 			ip6_flush_pending_frames(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 92bf903..39e3665 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -919,6 +919,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	int ulen = len;
 	int hlimit = -1;
 	int tclass = -1;
+	int dontfrag = -1;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
 	int connected = 0;
@@ -1049,7 +1050,8 @@ do_udp_sendmsg:
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
 
-		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit,
+					&tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
@@ -1120,6 +1122,9 @@ do_udp_sendmsg:
 	if (tclass < 0)
 		tclass = np->tclass;
 
+	if (dontfrag < 0)
+		dontfrag = np->dontfrag;
+
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
 back_from_confirm:
@@ -1143,7 +1148,7 @@ do_append_data:
 	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
 		sizeof(struct udphdr), hlimit, tclass, opt, &fl,
 		(struct rt6_info*)dst,
-		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
+		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
 	else if (!corkreq)
-- 
1.5.4.3

