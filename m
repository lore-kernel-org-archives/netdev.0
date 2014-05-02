From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v6 1/2] net: ipv6: Unduplicate UDP, raw, and L2TP sendmsg
Date: Sat,  3 May 2014 04:11:07 +0900
Message-ID: <1399057868-3488-2-git-send-email-lorenzo@google.com>
References: <1399057868-3488-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	yoshifuji@linux-ipv6.org, david.laight@aculab.com,
	eric.dumazet@gmail.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:46388 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680AbaEBTLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:11:19 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so5822621pab.13
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 12:11:18 -0700 (PDT)
In-Reply-To: <1399057868-3488-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udpv6_sendmsg, rawv6_sendmsg and l2tp_ip6_sendmsg share ~100
lines of mostly identical code. Move this into a new
ipv6_datagram_send_common helper function.

In order to do so without having to pass around too many
parameters, define a new ip6_output_opts structure that holds
some of the information needed by ip6_append_data and retrieved
from userspace by ip6_datagram_send_ctl.

Tested: black-box functional testing using user-mode Linux. The
following were tested to work as expected:

- UDP sends using sendto and connect/send.
- Raw socket sends using sendto.
- Mark routing and oif routing using SO_BINDTODEVICE on UDP and
  raw sockets.
- IPv6 extension headers set on UDP packets via setsockopt()
- L2TP compiles with CONFIG_IPV6={m,y} and CONFIG_L2TP_IP={m,y}.

Untested:
- Setting hop limit, tclass and options via cmsg.

Performance: netperf UDP_STREAM results (1-byte and 1452-byte
payloads) shows impact is in the noise (+-1%).

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/ipv6.h       |  33 ++++++++++-
 include/net/transp_v6.h  |   7 ++-
 net/ipv6/datagram.c      | 145 +++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/icmp.c          |  27 +++++----
 net/ipv6/ip6_flowlabel.c |   6 +-
 net/ipv6/ip6_output.c    |  11 ++--
 net/ipv6/ipv6_sockglue.c |   7 ++-
 net/ipv6/ping.c          |  11 ++--
 net/ipv6/raw.c           | 101 ++-------------------------------
 net/ipv6/udp.c           | 122 ++++-----------------------------------
 net/l2tp/l2tp_ip6.c      | 108 +++--------------------------------
 11 files changed, 230 insertions(+), 348 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 5b40ad2..eb69821 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -706,6 +706,28 @@ static inline u8 ip6_tclass(__be32 flowinfo)
 {
 	return ntohl(flowinfo & IPV6_TCLASS_MASK) >> IPV6_TCLASS_SHIFT;
 }
+
+struct ip6_output_opts {
+	int hlimit: 9;
+	int tclass: 9;
+	int dontfrag: 2;
+	unsigned connected: 1;
+	struct ipv6_txoptions *opt;
+};
+#define IP6_OUTOPTS_INIT { -1, -1, -1, 0, NULL }
+
+static inline void ip6_output_opts_sk_dst_init(struct ip6_output_opts *outopts,
+					       struct ipv6_pinfo *np,
+					       struct flowi6 *fl6,
+					       struct dst_entry *dst)
+{
+	outopts->hlimit = ip6_sk_dst_hoplimit(np, fl6, dst);
+	outopts->tclass = np->tclass;
+	outopts->dontfrag = np->dontfrag;
+	outopts->connected = 0;
+	outopts->opt = np->opt;
+}
+
 /*
  *	Prototypes exported by ipv6
  */
@@ -730,9 +752,10 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr);
 int ip6_append_data(struct sock *sk,
 		    int getfrag(void *from, char *to, int offset, int len,
 				int odd, struct sk_buff *skb),
-		    void *from, int length, int transhdrlen, int hlimit,
-		    int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
-		    struct rt6_info *rt, unsigned int flags, int dontfrag);
+		    void *from, int length, int transhdrlen,
+		    struct flowi6 *fl6, struct rt6_info *rt,
+		    const struct ip6_output_opts *outopts,
+		    unsigned int flags);
 
 int ip6_push_pending_frames(struct sock *sk);
 
@@ -804,6 +827,10 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
 int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
 				 int addr_len);
+int ip6_datagram_send_common(struct sock *sk, struct msghdr *msg,
+			     struct flowi6 *fl6, struct dst_entry **dstp,
+			     struct ip6_output_opts *opt,
+			     struct ipv6_txoptions *opt_space);
 
 int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len,
 		    int *addr_len);
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index b927413..c2b8324 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -11,6 +11,7 @@ extern struct proto tcpv6_prot;
 extern struct proto pingv6_prot;
 
 struct flowi6;
+struct ip6_output_opts;
 
 /* extension headers */
 int ipv6_exthdrs_init(void);
@@ -40,9 +41,9 @@ void ip6_datagram_recv_common_ctl(struct sock *sk, struct msghdr *msg,
 void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 				    struct sk_buff *skb);
 
-int ip6_datagram_send_ctl(struct net *net, struct sock *sk, struct msghdr *msg,
-			  struct flowi6 *fl6, struct ipv6_txoptions *opt,
-			  int *hlimit, int *tclass, int *dontfrag);
+int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
+			  struct msghdr *msg, struct flowi6 *fl6,
+			  struct ip6_output_opts *outopts);
 
 void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
 			     __u16 srcp, __u16 destp, int bucket);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index c3bf2d2..68b8009 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -640,13 +640,13 @@ EXPORT_SYMBOL_GPL(ip6_datagram_recv_ctl);
 
 int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 			  struct msghdr *msg, struct flowi6 *fl6,
-			  struct ipv6_txoptions *opt,
-			  int *hlimit, int *tclass, int *dontfrag)
+			  struct ip6_output_opts *outopts)
 {
 	struct in6_pktinfo *src_info;
 	struct cmsghdr *cmsg;
 	struct ipv6_rt_hdr *rthdr;
 	struct ipv6_opt_hdr *hdr;
+	struct ipv6_txoptions *opt = outopts->opt;
 	int len;
 	int err = 0;
 
@@ -854,18 +854,23 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 
 		case IPV6_2292HOPLIMIT:
 		case IPV6_HOPLIMIT:
+		    {
+			int hlimit;
+
 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int))) {
 				err = -EINVAL;
 				goto exit_f;
 			}
 
-			*hlimit = *(int *)CMSG_DATA(cmsg);
-			if (*hlimit < -1 || *hlimit > 0xff) {
+			hlimit = *(int *)CMSG_DATA(cmsg);
+			if (hlimit < -1 || hlimit > 0xff) {
 				err = -EINVAL;
 				goto exit_f;
 			}
+			outopts->hlimit = hlimit;
 
 			break;
+		    }
 
 		case IPV6_TCLASS:
 		    {
@@ -880,7 +885,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 				goto exit_f;
 
 			err = 0;
-			*tclass = tc;
+			outopts->tclass = tc;
 
 			break;
 		    }
@@ -898,7 +903,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 				goto exit_f;
 
 			err = 0;
-			*dontfrag = df;
+			outopts->dontfrag = df;
 
 			break;
 		    }
@@ -915,6 +920,134 @@ exit_f:
 }
 EXPORT_SYMBOL_GPL(ip6_datagram_send_ctl);
 
+int ip6_datagram_send_common(struct sock *sk, struct msghdr *msg,
+			     struct flowi6 *fl6, struct dst_entry **dstp,
+			     struct ip6_output_opts *outopts,
+			     struct ipv6_txoptions *opt_space)
+{
+	struct ipv6_txoptions *opt = NULL;
+	struct ip6_flowlabel *flowlabel = NULL;
+	struct in6_addr *final_p, final;
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct in6_addr *daddr;
+	struct dst_entry *dst;
+	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
+	int addr_len = msg->msg_namelen;
+	int err;
+	int connected;
+
+	if (sin6) {
+		daddr = &sin6->sin6_addr;
+
+		if (np->sndflow) {
+			fl6->flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
+			if (fl6->flowlabel&IPV6_FLOWLABEL_MASK) {
+				flowlabel = fl6_sock_lookup(sk, fl6->flowlabel);
+				if (flowlabel == NULL)
+					return -EINVAL;
+			}
+		}
+
+		/* Otherwise it will be difficult to maintain
+		 * sk->sk_dst_cache.
+		 */
+		if (sk->sk_state == TCP_ESTABLISHED &&
+		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr))
+			daddr = &sk->sk_v6_daddr;
+
+		if (addr_len >= sizeof(struct sockaddr_in6) &&
+		    sin6->sin6_scope_id &&
+		    __ipv6_addr_needs_scope_id(__ipv6_addr_type(daddr)))
+			fl6->flowi6_oif = sin6->sin6_scope_id;
+
+		connected = 0;
+	} else {
+		if (sk->sk_state != TCP_ESTABLISHED)
+			return -EDESTADDRREQ;
+
+		daddr = &sk->sk_v6_daddr;
+		fl6->flowlabel = np->flow_label;
+		connected = 1;
+	}
+
+	if (!fl6->flowi6_oif)
+		fl6->flowi6_oif = sk->sk_bound_dev_if;
+
+	if (!fl6->flowi6_oif)
+		fl6->flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
+
+	fl6->flowi6_mark = sk->sk_mark;
+
+	if (msg->msg_controllen) {
+		opt = opt_space;
+		memset(opt, 0, sizeof(*opt));
+		opt->tot_len = sizeof(*opt);
+
+		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, fl6,
+					    outopts);
+		if (err < 0) {
+			fl6_sock_release(flowlabel);
+			return err;
+		}
+		if ((fl6->flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
+			flowlabel = fl6_sock_lookup(sk, fl6->flowlabel);
+			if (flowlabel == NULL)
+				return -EINVAL;
+		}
+		if (!(opt->opt_nflen|opt->opt_flen))
+			opt = NULL;
+		connected = 0;
+	}
+	if (opt == NULL)
+		opt = np->opt;
+	if (flowlabel)
+		opt = fl6_merge_options(opt_space, flowlabel, opt);
+	opt = ipv6_fixup_options(opt_space, opt);
+
+	fl6_sock_release(flowlabel);
+
+	if (!ipv6_addr_any(daddr))
+		fl6->daddr = *daddr;
+	else
+		fl6->daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
+
+	if (ipv6_addr_any(&fl6->saddr) && !ipv6_addr_any(&np->saddr))
+		fl6->saddr = np->saddr;
+
+	final_p = fl6_update_dst(fl6, opt, &final);
+	if (final_p)
+		connected = 0;
+
+	if (!fl6->flowi6_oif && ipv6_addr_is_multicast(&fl6->daddr)) {
+		fl6->flowi6_oif = np->mcast_oif;
+		connected = 0;
+	} else if (!fl6->flowi6_oif)
+		fl6->flowi6_oif = np->ucast_oif;
+
+	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
+
+	dst = ip6_sk_dst_lookup_flow(sk, fl6, final_p);
+	if (IS_ERR(dst))
+		return PTR_ERR(dst);
+
+	if (outopts->hlimit < 0)
+		outopts->hlimit = ip6_sk_dst_hoplimit(np, fl6, dst);
+
+	if (outopts->tclass < 0)
+		outopts->tclass = np->tclass;
+
+	if (outopts->dontfrag < 0)
+		outopts->dontfrag = np->dontfrag;
+
+	outopts->opt = opt;
+	outopts->connected = connected;
+
+	*dstp = dst;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip6_datagram_send_common);
+
 void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
 			     __u16 srcp, __u16 destp, int bucket)
 {
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 3b0905b..ebcefa9 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -398,8 +398,8 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	int iif = 0;
 	int addr_type = 0;
 	int len;
-	int hlimit;
 	int err = 0;
+	struct ip6_output_opts outopts;
 
 	if ((u8 *)hdr < skb->head ||
 	    (skb_network_header(skb) + sizeof(*hdr)) > skb_tail_pointer(skb))
@@ -493,7 +493,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	if (IS_ERR(dst))
 		goto out;
 
-	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+	ip6_output_opts_sk_dst_init(&outopts, np, &fl6, dst);
 
 	msg.skb = skb;
 	msg.offset = skb_network_offset(skb);
@@ -511,9 +511,9 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg,
 			      len + sizeof(struct icmp6hdr),
-			      sizeof(struct icmp6hdr), hlimit,
-			      np->tclass, NULL, &fl6, (struct rt6_info *)dst,
-			      MSG_DONTWAIT, np->dontfrag);
+			      sizeof(struct icmp6hdr),
+			      &fl6, (struct rt6_info *)dst, &outopts,
+			      MSG_DONTWAIT);
 	if (err) {
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
@@ -546,11 +546,10 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	struct icmp6hdr *icmph = icmp6_hdr(skb);
 	struct icmp6hdr tmp_hdr;
 	struct flowi6 fl6;
+	struct ip6_output_opts outopts;
 	struct icmpv6_msg msg;
 	struct dst_entry *dst;
 	int err = 0;
-	int hlimit;
-	u8 tclass;
 
 	saddr = &ipv6_hdr(skb)->daddr;
 
@@ -588,19 +587,19 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	if (IS_ERR(dst))
 		goto out;
 
-	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
-
 	idev = __in6_dev_get(skb->dev);
 
 	msg.skb = skb;
 	msg.offset = 0;
 	msg.type = ICMPV6_ECHO_REPLY;
 
-	tclass = ipv6_get_dsfield(ipv6_hdr(skb));
-	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
-				sizeof(struct icmp6hdr), hlimit, tclass, NULL, &fl6,
-				(struct rt6_info *)dst, MSG_DONTWAIT,
-				np->dontfrag);
+	ip6_output_opts_sk_dst_init(&outopts, np, &fl6, dst);
+	outopts.tclass = ipv6_get_dsfield(ipv6_hdr(skb));
+
+	err = ip6_append_data(sk, icmpv6_getfrag, &msg,
+			      skb->len + sizeof(struct icmp6hdr),
+			      sizeof(struct icmp6hdr), &fl6,
+			      (struct rt6_info *)dst, &outopts, MSG_DONTWAIT);
 
 	if (err) {
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTERRORS);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 4052694..444595c 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -374,7 +374,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 	if (olen > 0) {
 		struct msghdr msg;
 		struct flowi6 flowi6;
-		int junk;
+		struct ip6_output_opts outopts;
 
 		err = -ENOMEM;
 		fl->opt = kmalloc(sizeof(*fl->opt) + olen, GFP_KERNEL);
@@ -391,10 +391,10 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 		msg.msg_control = (void*)(fl->opt+1);
 		memset(&flowi6, 0, sizeof(flowi6));
 
-		err = ip6_datagram_send_ctl(net, sk, &msg, &flowi6, fl->opt,
-					    &junk, &junk, &junk);
+		err = ip6_datagram_send_ctl(net, sk, &msg, &flowi6, &outopts);
 		if (err)
 			goto done;
+		fl->opt = outopts.opt;
 		err = -EINVAL;
 		if (fl->opt->opt_flen)
 			goto done;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 40e7581..d358ddd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1123,8 +1123,9 @@ static void ip6_append_data_mtu(unsigned int *mtu,
 int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int offset, int len, int odd, struct sk_buff *skb),
 	void *from, int length, int transhdrlen,
-	int hlimit, int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
-	struct rt6_info *rt, unsigned int flags, int dontfrag)
+	struct flowi6 *fl6, struct rt6_info *rt,
+	const struct ip6_output_opts *outopts,
+	unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1138,6 +1139,8 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int err;
 	int offset = 0;
 	__u8 tx_flags = 0;
+	struct ipv6_txoptions *opt = outopts->opt;
+	int dontfrag = outopts->dontfrag;
 
 	if (flags&MSG_PROBE)
 		return 0;
@@ -1183,8 +1186,8 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		dst_hold(&rt->dst);
 		cork->dst = &rt->dst;
 		inet->cork.fl.u.ip6 = *fl6;
-		np->cork.hop_limit = hlimit;
-		np->cork.tclass = tclass;
+		np->cork.hop_limit = outopts->hlimit;
+		np->cork.tclass = outopts->tclass;
 		if (rt->dst.flags & DST_XFRM_TUNNEL)
 			mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
 			      rt->dst.dev->mtu : dst_mtu(&rt->dst);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index edb58af..e514ad8 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -443,10 +443,10 @@ sticky_done:
 
 	case IPV6_2292PKTOPTIONS:
 	{
+		struct ip6_output_opts outopts;
 		struct ipv6_txoptions *opt = NULL;
 		struct msghdr msg;
 		struct flowi6 fl6;
-		int junk;
 
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
@@ -476,13 +476,14 @@ sticky_done:
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
 
-		retv = ip6_datagram_send_ctl(net, sk, &msg, &fl6, opt, &junk,
-					     &junk, &junk);
+		outopts.opt = opt;
+		retv = ip6_datagram_send_ctl(net, sk, &msg, &fl6, &outopts);
 		if (retv)
 			goto done;
 update:
 		retv = 0;
 		opt = ipv6_update_options(sk, opt);
+
 done:
 		if (opt)
 			sock_kfree_s(sk, opt, opt->tot_len);
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index a2a1d80..ee633a6 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -83,13 +83,13 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct ip6_output_opts outopts;
 	struct icmp6hdr user_icmph;
 	int addr_type;
 	struct in6_addr *daddr;
 	int iif = 0;
 	struct flowi6 fl6;
 	int err;
-	int hlimit;
 	struct dst_entry *dst;
 	struct rt6_info *rt;
 	struct pingfakehdr pfh;
@@ -168,13 +168,12 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	pfh.wcheck = 0;
 	pfh.family = AF_INET6;
 
-	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+
+	ip6_output_opts_sk_dst_init(&outopts, np, &fl6, dst);
 
 	lock_sock(sk);
-	err = ip6_append_data(sk, ping_getfrag, &pfh, len,
-			      0, hlimit,
-			      np->tclass, NULL, &fl6, rt,
-			      MSG_DONTWAIT, np->dontfrag);
+	err = ip6_append_data(sk, ping_getfrag, &pfh, len, 0,
+			      &outopts, &fl6, rt, MSG_DONTWAIT);
 
 	if (err) {
 		ICMP6_INC_STATS(sock_net(sk), rt->rt6i_idev,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index dddfb5f..146faca 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -739,18 +739,12 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 {
 	struct ipv6_txoptions opt_space;
 	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
-	struct in6_addr *daddr, *final_p, final;
 	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct raw6_sock *rp = raw6_sk(sk);
-	struct ipv6_txoptions *opt = NULL;
-	struct ip6_flowlabel *flowlabel = NULL;
+	struct ip6_output_opts outopts = IP6_OUTOPTS_INIT;
 	struct dst_entry *dst = NULL;
 	struct flowi6 fl6;
 	int addr_len = msg->msg_namelen;
-	int hlimit = -1;
-	int tclass = -1;
-	int dontfrag = -1;
 	u16 proto;
 	int err;
 
@@ -769,8 +763,6 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	 */
 	memset(&fl6, 0, sizeof(fl6));
 
-	fl6.flowi6_mark = sk->sk_mark;
-
 	if (sin6) {
 		if (addr_len < SIN6_LEN_RFC2133)
 			return -EINVAL;
@@ -788,99 +780,19 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 		if (proto > 255)
 			return -EINVAL;
-
-		daddr = &sin6->sin6_addr;
-		if (np->sndflow) {
-			fl6.flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-			if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
-				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-				if (flowlabel == NULL)
-					return -EINVAL;
-			}
-		}
-
-		/*
-		 * Otherwise it will be difficult to maintain
-		 * sk->sk_dst_cache.
-		 */
-		if (sk->sk_state == TCP_ESTABLISHED &&
-		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr))
-			daddr = &sk->sk_v6_daddr;
-
-		if (addr_len >= sizeof(struct sockaddr_in6) &&
-		    sin6->sin6_scope_id &&
-		    __ipv6_addr_needs_scope_id(__ipv6_addr_type(daddr)))
-			fl6.flowi6_oif = sin6->sin6_scope_id;
 	} else {
-		if (sk->sk_state != TCP_ESTABLISHED)
-			return -EDESTADDRREQ;
-
 		proto = inet->inet_num;
-		daddr = &sk->sk_v6_daddr;
-		fl6.flowlabel = np->flow_label;
-	}
-
-	if (fl6.flowi6_oif == 0)
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
-
-	if (msg->msg_controllen) {
-		opt = &opt_space;
-		memset(opt, 0, sizeof(struct ipv6_txoptions));
-		opt->tot_len = sizeof(struct ipv6_txoptions);
-
-		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					    &hlimit, &tclass, &dontfrag);
-		if (err < 0) {
-			fl6_sock_release(flowlabel);
-			return err;
-		}
-		if ((fl6.flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
-			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-			if (flowlabel == NULL)
-				return -EINVAL;
-		}
-		if (!(opt->opt_nflen|opt->opt_flen))
-			opt = NULL;
 	}
-	if (opt == NULL)
-		opt = np->opt;
-	if (flowlabel)
-		opt = fl6_merge_options(&opt_space, flowlabel, opt);
-	opt = ipv6_fixup_options(&opt_space, opt);
 
 	fl6.flowi6_proto = proto;
 	err = rawv6_probe_proto_opt(&fl6, msg);
 	if (err)
 		goto out;
 
-	if (!ipv6_addr_any(daddr))
-		fl6.daddr = *daddr;
-	else
-		fl6.daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
-	if (ipv6_addr_any(&fl6.saddr) && !ipv6_addr_any(&np->saddr))
-		fl6.saddr = np->saddr;
-
-	final_p = fl6_update_dst(&fl6, opt, &final);
-
-	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
-		fl6.flowi6_oif = np->mcast_oif;
-	else if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = np->ucast_oif;
-	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
-
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
-	if (IS_ERR(dst)) {
-		err = PTR_ERR(dst);
+	err = ip6_datagram_send_common(sk, msg, &fl6, &dst,
+				       &outopts, &opt_space);
+	if (err)
 		goto out;
-	}
-	if (hlimit < 0)
-		hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
-
-	if (tclass < 0)
-		tclass = np->tclass;
-
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
 
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
@@ -891,8 +803,8 @@ back_from_confirm:
 	else {
 		lock_sock(sk);
 		err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
-			len, 0, hlimit, tclass, opt, &fl6, (struct rt6_info*)dst,
-			msg->msg_flags, dontfrag);
+			len, 0, &fl6, (struct rt6_info *)dst, &outopts,
+			msg->msg_flags);
 
 		if (err)
 			ip6_flush_pending_frames(sk);
@@ -903,7 +815,6 @@ back_from_confirm:
 done:
 	dst_release(dst);
 out:
-	fl6_sock_release(flowlabel);
 	return err<0?err:len;
 do_confirm:
 	dst_confirm(dst);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d8d6ca0..0f7baff 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -39,6 +39,7 @@
 
 #include <net/ndisc.h>
 #include <net/protocol.h>
+#include <net/ipv6.h>
 #include <net/transp_v6.h>
 #include <net/ip6_route.h>
 #include <net/raw.h>
@@ -1044,19 +1045,14 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
-	struct in6_addr *daddr, *final_p, final;
-	struct ipv6_txoptions *opt = NULL;
-	struct ip6_flowlabel *flowlabel = NULL;
+	struct in6_addr *daddr;
+	struct ip6_output_opts outopts = IP6_OUTOPTS_INIT;
 	struct flowi6 fl6;
-	struct dst_entry *dst;
+	struct dst_entry *dst = NULL;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
-	int hlimit = -1;
-	int tclass = -1;
-	int dontfrag = -1;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
-	int connected = 0;
 	int is_udplite = IS_UDPLITE(sk);
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 
@@ -1123,7 +1119,7 @@ do_udp_sendmsg:
 				release_sock(sk);
 				return -EAFNOSUPPORT;
 			}
-			dst = NULL;
+			outopts.dontfrag = np->dontfrag;
 			goto do_append_data;
 		}
 		release_sock(sk);
@@ -1131,112 +1127,22 @@ do_udp_sendmsg:
 	ulen += sizeof(struct udphdr);
 
 	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = sk->sk_protocol;
 
 	if (sin6) {
 		if (sin6->sin6_port == 0)
 			return -EINVAL;
 
 		fl6.fl6_dport = sin6->sin6_port;
-		daddr = &sin6->sin6_addr;
-
-		if (np->sndflow) {
-			fl6.flowlabel = sin6->sin6_flowinfo&IPV6_FLOWINFO_MASK;
-			if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
-				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-				if (flowlabel == NULL)
-					return -EINVAL;
-			}
-		}
-
-		/*
-		 * Otherwise it will be difficult to maintain
-		 * sk->sk_dst_cache.
-		 */
-		if (sk->sk_state == TCP_ESTABLISHED &&
-		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr))
-			daddr = &sk->sk_v6_daddr;
-
-		if (addr_len >= sizeof(struct sockaddr_in6) &&
-		    sin6->sin6_scope_id &&
-		    __ipv6_addr_needs_scope_id(__ipv6_addr_type(daddr)))
-			fl6.flowi6_oif = sin6->sin6_scope_id;
 	} else {
-		if (sk->sk_state != TCP_ESTABLISHED)
-			return -EDESTADDRREQ;
-
 		fl6.fl6_dport = inet->inet_dport;
-		daddr = &sk->sk_v6_daddr;
-		fl6.flowlabel = np->flow_label;
-		connected = 1;
-	}
-
-	if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
-
-	if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
-
-	fl6.flowi6_mark = sk->sk_mark;
-
-	if (msg->msg_controllen) {
-		opt = &opt_space;
-		memset(opt, 0, sizeof(struct ipv6_txoptions));
-		opt->tot_len = sizeof(*opt);
-
-		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					    &hlimit, &tclass, &dontfrag);
-		if (err < 0) {
-			fl6_sock_release(flowlabel);
-			return err;
-		}
-		if ((fl6.flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
-			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-			if (flowlabel == NULL)
-				return -EINVAL;
-		}
-		if (!(opt->opt_nflen|opt->opt_flen))
-			opt = NULL;
-		connected = 0;
 	}
-	if (opt == NULL)
-		opt = np->opt;
-	if (flowlabel)
-		opt = fl6_merge_options(&opt_space, flowlabel, opt);
-	opt = ipv6_fixup_options(&opt_space, opt);
-
-	fl6.flowi6_proto = sk->sk_protocol;
-	if (!ipv6_addr_any(daddr))
-		fl6.daddr = *daddr;
-	else
-		fl6.daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
-	if (ipv6_addr_any(&fl6.saddr) && !ipv6_addr_any(&np->saddr))
-		fl6.saddr = np->saddr;
 	fl6.fl6_sport = inet->inet_sport;
 
-	final_p = fl6_update_dst(&fl6, opt, &final);
-	if (final_p)
-		connected = 0;
-
-	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr)) {
-		fl6.flowi6_oif = np->mcast_oif;
-		connected = 0;
-	} else if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = np->ucast_oif;
-
-	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
-
-	dst = ip6_sk_dst_lookup_flow(sk, &fl6, final_p);
-	if (IS_ERR(dst)) {
-		err = PTR_ERR(dst);
-		dst = NULL;
+	err = ip6_datagram_send_common(sk, msg, &fl6, &dst,
+				       &outopts, &opt_space);
+	if (err)
 		goto out;
-	}
-
-	if (hlimit < 0)
-		hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
-
-	if (tclass < 0)
-		tclass = np->tclass;
 
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
@@ -1256,14 +1162,11 @@ back_from_confirm:
 	up->pending = AF_INET6;
 
 do_append_data:
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
 	up->len += ulen;
 	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
-		sizeof(struct udphdr), hlimit, tclass, opt, &fl6,
-		(struct rt6_info*)dst,
-		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag);
+		sizeof(struct udphdr), &fl6, (struct rt6_info*)dst, &outopts,
+		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
 	else if (!corkreq)
@@ -1272,7 +1175,7 @@ do_append_data:
 		up->pending = 0;
 
 	if (dst) {
-		if (connected) {
+		if (outopts.connected) {
 			ip6_dst_store(sk, dst,
 				      ipv6_addr_equal(&fl6.daddr, &sk->sk_v6_daddr) ?
 				      &sk->sk_v6_daddr : NULL,
@@ -1292,7 +1195,6 @@ do_append_data:
 	release_sock(sk);
 out:
 	dst_release(dst);
-	fl6_sock_release(flowlabel);
 	if (!err)
 		return len;
 	/*
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index e472d44..fe4d931 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -485,16 +485,10 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 {
 	struct ipv6_txoptions opt_space;
 	DECLARE_SOCKADDR(struct sockaddr_l2tpip6 *, lsa, msg->msg_name);
-	struct in6_addr *daddr, *final_p, final;
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct ipv6_txoptions *opt = NULL;
-	struct ip6_flowlabel *flowlabel = NULL;
+	struct ip6_output_opts outopts = IP6_OUTOPTS_INIT;
 	struct dst_entry *dst = NULL;
 	struct flowi6 fl6;
 	int addr_len = msg->msg_namelen;
-	int hlimit = -1;
-	int tclass = -1;
-	int dontfrag = -1;
 	int transhdrlen = 4; /* zero session-id */
 	int ulen = len + transhdrlen;
 	int err;
@@ -514,7 +508,7 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	 */
 	memset(&fl6, 0, sizeof(fl6));
 
-	fl6.flowi6_mark = sk->sk_mark;
+	fl6.flowi6_proto = sk->sk_protocol;
 
 	if (lsa) {
 		if (addr_len < SIN6_LEN_RFC2133)
@@ -522,97 +516,12 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
 		if (lsa->l2tp_family && lsa->l2tp_family != AF_INET6)
 			return -EAFNOSUPPORT;
-
-		daddr = &lsa->l2tp_addr;
-		if (np->sndflow) {
-			fl6.flowlabel = lsa->l2tp_flowinfo & IPV6_FLOWINFO_MASK;
-			if (fl6.flowlabel&IPV6_FLOWLABEL_MASK) {
-				flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-				if (flowlabel == NULL)
-					return -EINVAL;
-			}
-		}
-
-		/*
-		 * Otherwise it will be difficult to maintain
-		 * sk->sk_dst_cache.
-		 */
-		if (sk->sk_state == TCP_ESTABLISHED &&
-		    ipv6_addr_equal(daddr, &sk->sk_v6_daddr))
-			daddr = &sk->sk_v6_daddr;
-
-		if (addr_len >= sizeof(struct sockaddr_in6) &&
-		    lsa->l2tp_scope_id &&
-		    ipv6_addr_type(daddr) & IPV6_ADDR_LINKLOCAL)
-			fl6.flowi6_oif = lsa->l2tp_scope_id;
-	} else {
-		if (sk->sk_state != TCP_ESTABLISHED)
-			return -EDESTADDRREQ;
-
-		daddr = &sk->sk_v6_daddr;
-		fl6.flowlabel = np->flow_label;
 	}
 
-	if (fl6.flowi6_oif == 0)
-		fl6.flowi6_oif = sk->sk_bound_dev_if;
-
-	if (msg->msg_controllen) {
-		opt = &opt_space;
-		memset(opt, 0, sizeof(struct ipv6_txoptions));
-		opt->tot_len = sizeof(struct ipv6_txoptions);
-
-		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					    &hlimit, &tclass, &dontfrag);
-		if (err < 0) {
-			fl6_sock_release(flowlabel);
-			return err;
-		}
-		if ((fl6.flowlabel & IPV6_FLOWLABEL_MASK) && !flowlabel) {
-			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-			if (flowlabel == NULL)
-				return -EINVAL;
-		}
-		if (!(opt->opt_nflen|opt->opt_flen))
-			opt = NULL;
-	}
-
-	if (opt == NULL)
-		opt = np->opt;
-	if (flowlabel)
-		opt = fl6_merge_options(&opt_space, flowlabel, opt);
-	opt = ipv6_fixup_options(&opt_space, opt);
-
-	fl6.flowi6_proto = sk->sk_protocol;
-	if (!ipv6_addr_any(daddr))
-		fl6.daddr = *daddr;
-	else
-		fl6.daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
-	if (ipv6_addr_any(&fl6.saddr) && !ipv6_addr_any(&np->saddr))
-		fl6.saddr = np->saddr;
-
-	final_p = fl6_update_dst(&fl6, opt, &final);
-
-	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
-		fl6.flowi6_oif = np->mcast_oif;
-	else if (!fl6.flowi6_oif)
-		fl6.flowi6_oif = np->ucast_oif;
-
-	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
-
-	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
-	if (IS_ERR(dst)) {
-		err = PTR_ERR(dst);
+	err = ip6_datagram_send_common(sk, msg, &fl6, &dst,
+				       &outopts, &opt_space);
+	if (err)
 		goto out;
-	}
-
-	if (hlimit < 0)
-		hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
-
-	if (tclass < 0)
-		tclass = np->tclass;
-
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
 
 	if (msg->msg_flags & MSG_CONFIRM)
 		goto do_confirm;
@@ -620,9 +529,8 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 back_from_confirm:
 	lock_sock(sk);
 	err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
-			      ulen, transhdrlen, hlimit, tclass, opt,
-			      &fl6, (struct rt6_info *)dst,
-			      msg->msg_flags, dontfrag);
+			      ulen, transhdrlen, &fl6, (struct rt6_info *)dst,
+			      &outopts, msg->msg_flags);
 	if (err)
 		ip6_flush_pending_frames(sk);
 	else if (!(msg->msg_flags & MSG_MORE))
@@ -631,8 +539,6 @@ back_from_confirm:
 done:
 	dst_release(dst);
 out:
-	fl6_sock_release(flowlabel);
-
 	return err < 0 ? err : len;
 
 do_confirm:
-- 
1.9.1.423.g4596e3a
