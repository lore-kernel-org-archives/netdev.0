From: Brian Haley <brian.haley@hp.com>
Subject: Re: IPV6_DONTFRAG sockopt etc.
Date: Fri, 29 Jan 2010 16:14:37 -0500
Message-ID: <4B634FBD.7010305@hp.com>
References: <alpine.LRH.2.00.1001291138310.29525@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:16024 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755145Ab0A2VOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 16:14:40 -0500
In-Reply-To: <alpine.LRH.2.00.1001291138310.29525@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pekka,

Pekka Savola wrote:
> Hello,
> 
> There appear to be a couple of sockopts in RFC3542 that aren't
> implemented yet (they're #if 0'd in the code)
> 
> #define IPV6_RECVPATHMTU        60
> #define IPV6_PATHMTU            61
> #define IPV6_DONTFRAG           62
> #define IPV6_USE_MIN_MTU        63
> 
> In one particular app, I would have found IPV6_DONTFRAG useful.

Here's a possible patch for IPV6_DONTFRAG, compiled, but untested,
if you have some time.  Of course it might not be of much use
without IPV6_RECVPATHMTU since you won't know what to reduce the
send() to - that would probably require different code in
ip6_append_data(), etc.  Like I said, untested.

-Brian


RFC: Implement IPV6_DONTFRAG socket option, RFC 3542.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/include/linux/in6.h b/include/linux/in6.h
index bd55c6e..8a2b8bb 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -224,7 +224,9 @@ struct in6_flowlabel_req {
 #if 0	/* not yet */
 #define IPV6_RECVPATHMTU	60
 #define IPV6_PATHMTU		61
+#endif
 #define IPV6_DONTFRAG		62
+#if 0	/* not yet */
 #define IPV6_USE_MIN_MTU	63
 #endif
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e0cc9a7..102f3fe 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -340,15 +340,17 @@ struct ipv6_pinfo {
 	} rxopt;
 
 	/* sockopt flags */
-	__u8			recverr:1,
+	__u16			recverr:1,
 	                        sndflow:1,
 				pmtudisc:2,
 				ipv6only:1,
-				srcprefs:3;	/* 001: prefer temporary address
+				srcprefs:3,	/* 001: prefer temporary address
 						 * 010: prefer public address
 						 * 100: prefer care-of address
 						 */
+				dontfrag:1;
 	__u8			tclass;
+	__u8			padding;
 
 	__u32			dst_cookie;
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ccab594..f8d61d7 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -500,7 +500,8 @@ extern int			ip6_append_data(struct sock *sk,
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
index e6f9cdf..582f043 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -496,7 +496,7 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 int datagram_send_ctl(struct net *net,
 		      struct msghdr *msg, struct flowi *fl,
 		      struct ipv6_txoptions *opt,
-		      int *hlimit, int *tclass)
+		      int *hlimit, int *tclass, int *dontfrag)
 {
 	struct in6_pktinfo *src_info;
 	struct cmsghdr *cmsg;
@@ -736,6 +736,25 @@ int datagram_send_ctl(struct net *net,
 
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
index 217dbc2..c3f9e59 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -486,7 +486,7 @@ route_done:
 			      len + sizeof(struct icmp6hdr),
 			      sizeof(struct icmp6hdr), hlimit,
 			      np->tclass, NULL, &fl, (struct rt6_info*)dst,
-			      MSG_DONTWAIT);
+			      MSG_DONTWAIT, np->dontfrag);
 	if (err) {
 		ip6_flush_pending_frames(sk);
 		goto out_put;
@@ -565,7 +565,8 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
 				sizeof(struct icmp6hdr), hlimit, np->tclass, NULL, &fl,
-				(struct rt6_info*)dst, MSG_DONTWAIT);
+				(struct rt6_info*)dst, MSG_DONTWAIT,
+				np->dontfrag);
 
 	if (err) {
 		ip6_flush_pending_frames(sk);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index e41eba8..62c9329 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -359,7 +359,8 @@ fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 		msg.msg_control = (void*)(fl->opt+1);
 		flowi.oif = 0;
 
-		err = datagram_send_ctl(net, &msg, &flowi, fl->opt, &junk, &junk);
+		err = datagram_send_ctl(net, &msg, &flowi, fl->opt, &junk,
+					&junk, &junk);
 		if (err)
 			goto done;
 		err = -EINVAL;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index eb6d097..61e0157 100644
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
@@ -1197,6 +1197,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
 		if (inet->cork.length + length > sizeof(struct ipv6hdr) + IPV6_MAXPLEN - fragheaderlen) {
+toobig:
 			ipv6_local_error(sk, EMSGSIZE, fl, mtu-exthdrlen);
 			return -EMSGSIZE;
 		}
@@ -1219,15 +1220,21 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	 */
 
 	inet->cork.length += length;
-	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) &&
-	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
-
-		err = ip6_ufo_append_data(sk, getfrag, from, length, hh_len,
-					  fragheaderlen, transhdrlen, mtu,
-					  flags);
-		if (err)
-			goto error;
-		return 0;
+	if (length > mtu) {
+		int proto = sk->sk_protocol;
+		if (dontfrag && (proto == IPPROTO_UDP || proto == IPPROTO_RAW))
+			goto toobig;
+
+		if (proto == IPPROTO_UDP &&
+		    (rt->u.dst.dev->features & NETIF_F_UFO)) {
+
+			err = ip6_ufo_append_data(sk, getfrag, from, length,
+						  hh_len, fragheaderlen,
+						  transhdrlen, mtu, flags);
+			if (err)
+				goto error;
+			return 0;
+		}
 	}
 
 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 430454e..c0006fb 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -450,7 +450,8 @@ sticky_done:
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
 
-		retv = datagram_send_ctl(net, &msg, &fl, opt, &junk, &junk);
+		retv = datagram_send_ctl(net, &msg, &fl, opt, &junk, &junk,
+					 &junk);
 		if (retv)
 			goto done;
 update:
@@ -766,6 +767,10 @@ pref_skip_coa:
 
 		break;
 	    }
+	case IPV6_DONTFRAG:
+		np->dontfrag = valbool;
+		retv = 0;
+		break;
 	}
 
 	release_sock(sk);
@@ -1114,6 +1119,10 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			val |= IPV6_PREFER_SRC_HOME;
 		break;
 
+	case IPV6_DONTFRAG:
+		val = np->dontfrag;
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ed31c37..2018322 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -732,6 +732,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	int addr_len = msg->msg_namelen;
 	int hlimit = -1;
 	int tclass = -1;
+	int dontfrag = -1;
 	u16 proto;
 	int err;
 
@@ -810,7 +811,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
-		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit,
+					&tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
@@ -879,6 +881,12 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (tclass < 0)
 		tclass = np->tclass;
 
+	if (dontfrag < 0) {
+		dontfrag = np->dontfrag;
+		if (dontfrag < 0)
+			dontfrag = 0;
+	}
+
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
 
@@ -889,7 +897,7 @@ back_from_confirm:
 		lock_sock(sk);
 		err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
 			len, 0, hlimit, tclass, opt, &fl, (struct rt6_info*)dst,
-			msg->msg_flags);
+			msg->msg_flags, dontfrag);
 
 		if (err)
 			ip6_flush_pending_frames(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 34efb35..0568778 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -912,6 +912,7 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	int ulen = len;
 	int hlimit = -1;
 	int tclass = -1;
+	int dontfrag = -1;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
 	int connected = 0;
@@ -1042,7 +1043,8 @@ do_udp_sendmsg:
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
 
-		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit,
+					&tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
@@ -1113,6 +1115,12 @@ do_udp_sendmsg:
 	if (tclass < 0)
 		tclass = np->tclass;
 
+	if (dontfrag < 0) {
+		dontfrag = np->dontfrag;
+		if (dontfrag < 0)
+			dontfrag = 0;
+	}
+
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
 back_from_confirm:
@@ -1136,7 +1144,7 @@ do_append_data:
 	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
 		sizeof(struct udphdr), hlimit, tclass, opt, &fl,
 		(struct rt6_info*)dst,
-		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
+		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
 	else if (!corkreq)
