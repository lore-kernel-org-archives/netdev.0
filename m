From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next] ipv6: add new struct ipcm6_cookie
Date: Fri, 29 Apr 2016 17:31:12 -0700
Message-ID: <1461976272-10738-1-git-send-email-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>, Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32942 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbcD3Abb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 20:31:31 -0400
Received: by mail-pa0-f53.google.com with SMTP id zm5so57428372pac.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 17:31:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In the sendmsg function of UDP, raw, ICMP and l2tp sockets, we use local
variables like hlimits, tclass, opt and dontfrag and pass them to corresponding
functions like ip6_make_skb, ip6_append_data and xxx_push_pending_frames.
This is not a good practice and makes it hard to add new parameters.
This fix introduces a new struct ipcm6_cookie similar to ipcm_cookie in
ipv4 and include the above mentioned variables. And we only pass the
pointer to this structure to corresponding functions. This makes it easier
to add new parameters in the future and makes the function cleaner.

Signed-off-by: Wei Wang <weiwan@google.com>
---
 include/net/ipv6.h       | 18 ++++++++++++------
 include/net/transp_v6.h  |  3 +--
 net/ipv6/datagram.c      | 13 ++++++-------
 net/ipv6/icmp.c          | 28 ++++++++++++++++------------
 net/ipv6/ip6_flowlabel.c |  6 +++---
 net/ipv6/ip6_output.c    | 42 ++++++++++++++++++++----------------------
 net/ipv6/ipv6_sockglue.c |  6 +++---
 net/ipv6/ping.c          | 12 +++++++-----
 net/ipv6/raw.c           | 33 ++++++++++++++++++---------------
 net/ipv6/udp.c           | 38 +++++++++++++++++++-------------------
 net/l2tp/l2tp_ip6.c      | 33 ++++++++++++++++++---------------
 11 files changed, 123 insertions(+), 109 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 415213d..11a0452 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -251,6 +251,13 @@ struct ipv6_fl_socklist {
 	struct rcu_head			rcu;
 };
 
+struct ipcm6_cookie {
+	__s16 hlimit;
+	__s16 tclass;
+	__s8  dontfrag;
+	struct ipv6_txoptions *opt;
+};
+
 static inline struct ipv6_txoptions *txopt_get(const struct ipv6_pinfo *np)
 {
 	struct ipv6_txoptions *opt;
@@ -863,9 +870,9 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr);
 int ip6_append_data(struct sock *sk,
 		    int getfrag(void *from, char *to, int offset, int len,
 				int odd, struct sk_buff *skb),
-		    void *from, int length, int transhdrlen, int hlimit,
-		    int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
-		    struct rt6_info *rt, unsigned int flags, int dontfrag,
+		    void *from, int length, int transhdrlen,
+		    struct ipcm6_cookie *ipc6, struct flowi6 *fl6,
+		    struct rt6_info *rt, unsigned int flags,
 		    const struct sockcm_cookie *sockc);
 
 int ip6_push_pending_frames(struct sock *sk);
@@ -881,9 +888,8 @@ struct sk_buff *ip6_make_skb(struct sock *sk,
 			     int getfrag(void *from, char *to, int offset,
 					 int len, int odd, struct sk_buff *skb),
 			     void *from, int length, int transhdrlen,
-			     int hlimit, int tclass, struct ipv6_txoptions *opt,
-			     struct flowi6 *fl6, struct rt6_info *rt,
-			     unsigned int flags, int dontfrag,
+			     struct ipcm6_cookie *ipc6, struct flowi6 *fl6,
+			     struct rt6_info *rt, unsigned int flags,
 			     const struct sockcm_cookie *sockc);
 
 static inline struct sk_buff *ip6_finish_skb(struct sock *sk)
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 2b1c345..276f976 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -41,8 +41,7 @@ void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 				    struct sk_buff *skb);
 
 int ip6_datagram_send_ctl(struct net *net, struct sock *sk, struct msghdr *msg,
-			  struct flowi6 *fl6, struct ipv6_txoptions *opt,
-			  int *hlimit, int *tclass, int *dontfrag,
+			  struct flowi6 *fl6, struct ipcm6_cookie *ipc6,
 			  struct sockcm_cookie *sockc);
 
 void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index ea9ee5c..00d0c29 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -727,14 +727,13 @@ EXPORT_SYMBOL_GPL(ip6_datagram_recv_ctl);
 
 int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 			  struct msghdr *msg, struct flowi6 *fl6,
-			  struct ipv6_txoptions *opt,
-			  int *hlimit, int *tclass, int *dontfrag,
-			  struct sockcm_cookie *sockc)
+			  struct ipcm6_cookie *ipc6, struct sockcm_cookie *sockc)
 {
 	struct in6_pktinfo *src_info;
 	struct cmsghdr *cmsg;
 	struct ipv6_rt_hdr *rthdr;
 	struct ipv6_opt_hdr *hdr;
+	struct ipv6_txoptions *opt = ipc6->opt;
 	int len;
 	int err = 0;
 
@@ -953,8 +952,8 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 				goto exit_f;
 			}
 
-			*hlimit = *(int *)CMSG_DATA(cmsg);
-			if (*hlimit < -1 || *hlimit > 0xff) {
+			ipc6->hlimit = *(int *)CMSG_DATA(cmsg);
+			if (ipc6->hlimit < -1 || ipc6->hlimit > 0xff) {
 				err = -EINVAL;
 				goto exit_f;
 			}
@@ -974,7 +973,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 				goto exit_f;
 
 			err = 0;
-			*tclass = tc;
+			ipc6->tclass = tc;
 
 			break;
 		    }
@@ -992,7 +991,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 				goto exit_f;
 
 			err = 0;
-			*dontfrag = df;
+			ipc6->dontfrag = df;
 
 			break;
 		    }
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 23b9a4c..9554b99 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -401,10 +401,10 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	struct flowi6 fl6;
 	struct icmpv6_msg msg;
 	struct sockcm_cookie sockc_unused = {0};
+	struct ipcm6_cookie ipc6;
 	int iif = 0;
 	int addr_type = 0;
 	int len;
-	int hlimit;
 	int err = 0;
 	u32 mark = IP6_REPLY_MARK(net, skb->mark);
 
@@ -507,7 +507,10 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	if (IS_ERR(dst))
 		goto out;
 
-	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+	ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+	ipc6.tclass = np->tclass;
+	ipc6.dontfrag = np->dontfrag;
+	ipc6.opt = NULL;
 
 	msg.skb = skb;
 	msg.offset = skb_network_offset(skb);
@@ -526,9 +529,9 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg,
 			      len + sizeof(struct icmp6hdr),
-			      sizeof(struct icmp6hdr), hlimit,
-			      np->tclass, NULL, &fl6, (struct rt6_info *)dst,
-			      MSG_DONTWAIT, np->dontfrag, &sockc_unused);
+			      sizeof(struct icmp6hdr),
+			      &ipc6, &fl6, (struct rt6_info *)dst,
+			      MSG_DONTWAIT, &sockc_unused);
 	if (err) {
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTERRORS);
 		ip6_flush_pending_frames(sk);
@@ -563,9 +566,8 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	struct flowi6 fl6;
 	struct icmpv6_msg msg;
 	struct dst_entry *dst;
+	struct ipcm6_cookie ipc6;
 	int err = 0;
-	int hlimit;
-	u8 tclass;
 	u32 mark = IP6_REPLY_MARK(net, skb->mark);
 	struct sockcm_cookie sockc_unused = {0};
 
@@ -607,19 +609,21 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	if (IS_ERR(dst))
 		goto out;
 
-	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
-
 	idev = __in6_dev_get(skb->dev);
 
 	msg.skb = skb;
 	msg.offset = 0;
 	msg.type = ICMPV6_ECHO_REPLY;
 
-	tclass = ipv6_get_dsfield(ipv6_hdr(skb));
+	ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+	ipc6.tclass = ipv6_get_dsfield(ipv6_hdr(skb));
+	ipc6.dontfrag = np->dontfrag;
+	ipc6.opt = NULL;
+
 	err = ip6_append_data(sk, icmpv6_getfrag, &msg, skb->len + sizeof(struct icmp6hdr),
-				sizeof(struct icmp6hdr), hlimit, tclass, NULL, &fl6,
+				sizeof(struct icmp6hdr), &ipc6, &fl6,
 				(struct rt6_info *)dst, MSG_DONTWAIT,
-				np->dontfrag, &sockc_unused);
+				&sockc_unused);
 
 	if (err) {
 		__ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTERRORS);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 35d3ddc..b912f0d 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -373,7 +373,7 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 		struct msghdr msg;
 		struct flowi6 flowi6;
 		struct sockcm_cookie sockc_junk;
-		int junk;
+		struct ipcm6_cookie ipc6;
 
 		err = -ENOMEM;
 		fl->opt = kmalloc(sizeof(*fl->opt) + olen, GFP_KERNEL);
@@ -390,8 +390,8 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 		msg.msg_control = (void *)(fl->opt+1);
 		memset(&flowi6, 0, sizeof(flowi6));
 
-		err = ip6_datagram_send_ctl(net, sk, &msg, &flowi6, fl->opt,
-					    &junk, &junk, &junk, &sockc_junk);
+		ipc6.opt = fl->opt;
+		err = ip6_datagram_send_ctl(net, sk, &msg, &flowi6, &ipc6, &sockc_junk);
 		if (err)
 			goto done;
 		err = -EINVAL;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 2b3ffc5..cbf127a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1182,12 +1182,12 @@ static void ip6_append_data_mtu(unsigned int *mtu,
 }
 
 static int ip6_setup_cork(struct sock *sk, struct inet_cork_full *cork,
-			  struct inet6_cork *v6_cork,
-			  int hlimit, int tclass, struct ipv6_txoptions *opt,
+			  struct inet6_cork *v6_cork, struct ipcm6_cookie *ipc6,
 			  struct rt6_info *rt, struct flowi6 *fl6)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	unsigned int mtu;
+	struct ipv6_txoptions *opt = ipc6->opt;
 
 	/*
 	 * setup for corking
@@ -1229,8 +1229,8 @@ static int ip6_setup_cork(struct sock *sk, struct inet_cork_full *cork,
 	dst_hold(&rt->dst);
 	cork->base.dst = &rt->dst;
 	cork->fl.u.ip6 = *fl6;
-	v6_cork->hop_limit = hlimit;
-	v6_cork->tclass = tclass;
+	v6_cork->hop_limit = ipc6->hlimit;
+	v6_cork->tclass = ipc6->tclass;
 	if (rt->dst.flags & DST_XFRM_TUNNEL)
 		mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
 		      rt->dst.dev->mtu : dst_mtu(&rt->dst);
@@ -1258,7 +1258,7 @@ static int __ip6_append_data(struct sock *sk,
 			     int getfrag(void *from, char *to, int offset,
 					 int len, int odd, struct sk_buff *skb),
 			     void *from, int length, int transhdrlen,
-			     unsigned int flags, int dontfrag,
+			     unsigned int flags, struct ipcm6_cookie *ipc6,
 			     const struct sockcm_cookie *sockc)
 {
 	struct sk_buff *skb, *skb_prev = NULL;
@@ -1298,7 +1298,7 @@ static int __ip6_append_data(struct sock *sk,
 		      sizeof(struct frag_hdr) : 0) +
 		     rt->rt6i_nfheader_len;
 
-	if (cork->length + length > mtu - headersize && dontfrag &&
+	if (cork->length + length > mtu - headersize && ipc6->dontfrag &&
 	    (sk->sk_protocol == IPPROTO_UDP ||
 	     sk->sk_protocol == IPPROTO_RAW)) {
 		ipv6_local_rxpmtu(sk, fl6, mtu - headersize +
@@ -1564,9 +1564,9 @@ error:
 int ip6_append_data(struct sock *sk,
 		    int getfrag(void *from, char *to, int offset, int len,
 				int odd, struct sk_buff *skb),
-		    void *from, int length, int transhdrlen, int hlimit,
-		    int tclass, struct ipv6_txoptions *opt, struct flowi6 *fl6,
-		    struct rt6_info *rt, unsigned int flags, int dontfrag,
+		    void *from, int length, int transhdrlen,
+		    struct ipcm6_cookie *ipc6, struct flowi6 *fl6,
+		    struct rt6_info *rt, unsigned int flags,
 		    const struct sockcm_cookie *sockc)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -1580,12 +1580,12 @@ int ip6_append_data(struct sock *sk,
 		/*
 		 * setup for corking
 		 */
-		err = ip6_setup_cork(sk, &inet->cork, &np->cork, hlimit,
-				     tclass, opt, rt, fl6);
+		err = ip6_setup_cork(sk, &inet->cork, &np->cork,
+				     ipc6, rt, fl6);
 		if (err)
 			return err;
 
-		exthdrlen = (opt ? opt->opt_flen : 0);
+		exthdrlen = (ipc6->opt ? ipc6->opt->opt_flen : 0);
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
 	} else {
@@ -1595,8 +1595,7 @@ int ip6_append_data(struct sock *sk,
 
 	return __ip6_append_data(sk, fl6, &sk->sk_write_queue, &inet->cork.base,
 				 &np->cork, sk_page_frag(sk), getfrag,
-				 from, length, transhdrlen, flags, dontfrag,
-				 sockc);
+				 from, length, transhdrlen, flags, ipc6, sockc);
 }
 EXPORT_SYMBOL_GPL(ip6_append_data);
 
@@ -1752,15 +1751,14 @@ struct sk_buff *ip6_make_skb(struct sock *sk,
 			     int getfrag(void *from, char *to, int offset,
 					 int len, int odd, struct sk_buff *skb),
 			     void *from, int length, int transhdrlen,
-			     int hlimit, int tclass,
-			     struct ipv6_txoptions *opt, struct flowi6 *fl6,
+			     struct ipcm6_cookie *ipc6, struct flowi6 *fl6,
 			     struct rt6_info *rt, unsigned int flags,
-			     int dontfrag, const struct sockcm_cookie *sockc)
+			     const struct sockcm_cookie *sockc)
 {
 	struct inet_cork_full cork;
 	struct inet6_cork v6_cork;
 	struct sk_buff_head queue;
-	int exthdrlen = (opt ? opt->opt_flen : 0);
+	int exthdrlen = (ipc6->opt ? ipc6->opt->opt_flen : 0);
 	int err;
 
 	if (flags & MSG_PROBE)
@@ -1772,17 +1770,17 @@ struct sk_buff *ip6_make_skb(struct sock *sk,
 	cork.base.addr = 0;
 	cork.base.opt = NULL;
 	v6_cork.opt = NULL;
-	err = ip6_setup_cork(sk, &cork, &v6_cork, hlimit, tclass, opt, rt, fl6);
+	err = ip6_setup_cork(sk, &cork, &v6_cork, ipc6, rt, fl6);
 	if (err)
 		return ERR_PTR(err);
 
-	if (dontfrag < 0)
-		dontfrag = inet6_sk(sk)->dontfrag;
+	if (ipc6->dontfrag < 0)
+		ipc6->dontfrag = inet6_sk(sk)->dontfrag;
 
 	err = __ip6_append_data(sk, fl6, &queue, &cork.base, &v6_cork,
 				&current->task_frag, getfrag, from,
 				length + exthdrlen, transhdrlen + exthdrlen,
-				flags, dontfrag, sockc);
+				flags, ipc6, sockc);
 	if (err) {
 		__ip6_flush_pending_frames(sk, &queue, &cork, &v6_cork);
 		return ERR_PTR(err);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4ff4b29..a9895e1 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -473,7 +473,7 @@ sticky_done:
 		struct msghdr msg;
 		struct flowi6 fl6;
 		struct sockcm_cookie sockc_junk;
-		int junk;
+		struct ipcm6_cookie ipc6;
 
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
@@ -503,9 +503,9 @@ sticky_done:
 
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void *)(opt+1);
+		ipc6.opt = opt;
 
-		retv = ip6_datagram_send_ctl(net, sk, &msg, &fl6, opt, &junk,
-					     &junk, &junk, &sockc_junk);
+		retv = ip6_datagram_send_ctl(net, sk, &msg, &fl6, &ipc6, &sockc_junk);
 		if (retv)
 			goto done;
 update:
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index da1cff7..3ee3e44 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -58,11 +58,11 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	int iif = 0;
 	struct flowi6 fl6;
 	int err;
-	int hlimit;
 	struct dst_entry *dst;
 	struct rt6_info *rt;
 	struct pingfakehdr pfh;
 	struct sockcm_cookie junk = {0};
+	struct ipcm6_cookie ipc6;
 
 	pr_debug("ping_v6_sendmsg(sk=%p,sk->num=%u)\n", inet, inet->inet_num);
 
@@ -139,13 +139,15 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	pfh.wcheck = 0;
 	pfh.family = AF_INET6;
 
-	hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+	ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+	ipc6.tclass = np->tclass;
+	ipc6.dontfrag = np->dontfrag;
+	ipc6.opt = NULL;
 
 	lock_sock(sk);
 	err = ip6_append_data(sk, ping_getfrag, &pfh, len,
-			      0, hlimit,
-			      np->tclass, NULL, &fl6, rt,
-			      MSG_DONTWAIT, np->dontfrag, &junk);
+			      0, &ipc6, &fl6, rt,
+			      MSG_DONTWAIT, &junk);
 
 	if (err) {
 		ICMP6_INC_STATS(sock_net(sk), rt->rt6i_idev,
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index b07ce21..896350d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -746,10 +746,8 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	struct raw6_frag_vec rfv;
 	struct flowi6 fl6;
 	struct sockcm_cookie sockc;
+	struct ipcm6_cookie ipc6;
 	int addr_len = msg->msg_namelen;
-	int hlimit = -1;
-	int tclass = -1;
-	int dontfrag = -1;
 	u16 proto;
 	int err;
 
@@ -770,6 +768,11 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	fl6.flowi6_mark = sk->sk_mark;
 
+	ipc6.hlimit = -1;
+	ipc6.tclass = -1;
+	ipc6.dontfrag = -1;
+	ipc6.opt = NULL;
+
 	if (sin6) {
 		if (addr_len < SIN6_LEN_RFC2133)
 			return -EINVAL;
@@ -827,10 +830,9 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
+		ipc6.opt = opt;
 
-		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					    &hlimit, &tclass, &dontfrag,
-					    &sockc);
+		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, &ipc6, &sockc);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
@@ -846,7 +848,7 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (!opt) {
 		opt = txopt_get(np);
 		opt_to_free = opt;
-		}
+	}
 	if (flowlabel)
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
@@ -881,14 +883,14 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		err = PTR_ERR(dst);
 		goto out;
 	}
-	if (hlimit < 0)
-		hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+	if (ipc6.hlimit < 0)
+		ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
-	if (tclass < 0)
-		tclass = np->tclass;
+	if (ipc6.tclass < 0)
+		ipc6.tclass = np->tclass;
 
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
+	if (ipc6.dontfrag < 0)
+		ipc6.dontfrag = np->dontfrag;
 
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
@@ -897,10 +899,11 @@ back_from_confirm:
 	if (inet->hdrincl)
 		err = rawv6_send_hdrinc(sk, msg, len, &fl6, &dst, msg->msg_flags);
 	else {
+		ipc6.opt = opt;
 		lock_sock(sk);
 		err = ip6_append_data(sk, raw6_getfrag, &rfv,
-			len, 0, hlimit, tclass, opt, &fl6, (struct rt6_info *)dst,
-			msg->msg_flags, dontfrag, &sockc);
+			len, 0, &ipc6, &fl6, (struct rt6_info *)dst,
+			msg->msg_flags, &sockc);
 
 		if (err)
 			ip6_flush_pending_frames(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1ba5a74..a4dc7ba 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1064,11 +1064,9 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct flowi6 fl6;
 	struct dst_entry *dst;
+	struct ipcm6_cookie ipc6;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
-	int hlimit = -1;
-	int tclass = -1;
-	int dontfrag = -1;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
 	int connected = 0;
@@ -1076,6 +1074,10 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 	struct sockcm_cookie sockc;
 
+	ipc6.hlimit = -1;
+	ipc6.tclass = -1;
+	ipc6.dontfrag = -1;
+
 	/* destination address check */
 	if (sin6) {
 		if (addr_len < offsetof(struct sockaddr, sa_data))
@@ -1200,10 +1202,9 @@ do_udp_sendmsg:
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
+		ipc6.opt = opt;
 
-		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					    &hlimit, &tclass, &dontfrag,
-					    &sockc);
+		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, &ipc6, &sockc);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
@@ -1224,6 +1225,7 @@ do_udp_sendmsg:
 	if (flowlabel)
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
+	ipc6.opt = opt;
 
 	fl6.flowi6_proto = sk->sk_protocol;
 	if (!ipv6_addr_any(daddr))
@@ -1253,11 +1255,11 @@ do_udp_sendmsg:
 		goto out;
 	}
 
-	if (hlimit < 0)
-		hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+	if (ipc6.hlimit < 0)
+		ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
-	if (tclass < 0)
-		tclass = np->tclass;
+	if (ipc6.tclass < 0)
+		ipc6.tclass = np->tclass;
 
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
@@ -1268,9 +1270,9 @@ back_from_confirm:
 		struct sk_buff *skb;
 
 		skb = ip6_make_skb(sk, getfrag, msg, ulen,
-				   sizeof(struct udphdr), hlimit, tclass, opt,
+				   sizeof(struct udphdr), &ipc6,
 				   &fl6, (struct rt6_info *)dst,
-				   msg->msg_flags, dontfrag, &sockc);
+				   msg->msg_flags, &sockc);
 		err = PTR_ERR(skb);
 		if (!IS_ERR_OR_NULL(skb))
 			err = udp_v6_send_skb(skb, &fl6);
@@ -1291,14 +1293,12 @@ back_from_confirm:
 	up->pending = AF_INET6;
 
 do_append_data:
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
+	if (ipc6.dontfrag < 0)
+		ipc6.dontfrag = np->dontfrag;
 	up->len += ulen;
-	err = ip6_append_data(sk, getfrag, msg, ulen,
-		sizeof(struct udphdr), hlimit, tclass, opt, &fl6,
-		(struct rt6_info *)dst,
-		corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, dontfrag,
-		&sockc);
+	err = ip6_append_data(sk, getfrag, msg, ulen, sizeof(struct udphdr),
+			      &ipc6, &fl6, (struct rt6_info *)dst,
+			      corkreq ? msg->msg_flags|MSG_MORE : msg->msg_flags, &sockc);
 	if (err)
 		udp_v6_flush_pending_frames(sk);
 	else if (!corkreq)
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 46e0726..ca215e7 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -495,10 +495,8 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	struct dst_entry *dst = NULL;
 	struct flowi6 fl6;
 	struct sockcm_cookie sockc_unused = {0};
+	struct ipcm6_cookie ipc6;
 	int addr_len = msg->msg_namelen;
-	int hlimit = -1;
-	int tclass = -1;
-	int dontfrag = -1;
 	int transhdrlen = 4; /* zero session-id */
 	int ulen = len + transhdrlen;
 	int err;
@@ -520,6 +518,10 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 
 	fl6.flowi6_mark = sk->sk_mark;
 
+	ipc6.hlimit = -1;
+	ipc6.tclass = -1;
+	ipc6.dontfrag = -1;
+
 	if (lsa) {
 		if (addr_len < SIN6_LEN_RFC2133)
 			return -EINVAL;
@@ -564,11 +566,11 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
+		ipc6.opt = opt;
 
-                err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-                                            &hlimit, &tclass, &dontfrag,
-                                            &sockc_unused);
-                if (err < 0) {
+		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, &ipc6,
+					    &sockc_unused);
+		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
 		}
@@ -588,6 +590,7 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	if (flowlabel)
 		opt = fl6_merge_options(&opt_space, flowlabel, opt);
 	opt = ipv6_fixup_options(&opt_space, opt);
+	ipc6.opt = opt;
 
 	fl6.flowi6_proto = sk->sk_protocol;
 	if (!ipv6_addr_any(daddr))
@@ -612,14 +615,14 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		goto out;
 	}
 
-	if (hlimit < 0)
-		hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
+	if (ipc6.hlimit < 0)
+		ipc6.hlimit = ip6_sk_dst_hoplimit(np, &fl6, dst);
 
-	if (tclass < 0)
-		tclass = np->tclass;
+	if (ipc6.tclass < 0)
+		ipc6.tclass = np->tclass;
 
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
+	if (ipc6.dontfrag < 0)
+		ipc6.dontfrag = np->dontfrag;
 
 	if (msg->msg_flags & MSG_CONFIRM)
 		goto do_confirm;
@@ -627,9 +630,9 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 back_from_confirm:
 	lock_sock(sk);
 	err = ip6_append_data(sk, ip_generic_getfrag, msg,
-			      ulen, transhdrlen, hlimit, tclass, opt,
+			      ulen, transhdrlen, &ipc6
 			      &fl6, (struct rt6_info *)dst,
-			      msg->msg_flags, dontfrag, &sockc_unused);
+			      msg->msg_flags, &sockc_unused);
 	if (err)
 		ip6_flush_pending_frames(sk);
 	else if (!(msg->msg_flags & MSG_MORE))
-- 
2.8.0.rc3.226.g39d4020
