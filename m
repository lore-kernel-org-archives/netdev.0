From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next 1/3] net: ipv6: unduplicate {raw,udp}v6_sendmsg code
Date: Tue, 22 Apr 2014 17:13:33 +0900
Message-ID: <1398154415-24486-1-git-send-email-lorenzo@google.com>
Cc: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
	davem@davemloft.net, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:53703 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbaDVINq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 04:13:46 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so4596361pdb.14
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 01:13:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rawv6_sendmsg and udpv6_sendmsg have ~100 lines of almost
identical code. Move this into a new ipv6_datagram_send_common
helper function.

Tested: black-box tested using user-mode Linux.

- Basic UDP sends using sendto work.
- Mark routing and oif routing using SO_BINDTODEVICE work.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/ipv6.h  |   7 +++
 net/ipv6/datagram.c | 131 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c      | 107 ++++--------------------------------------
 net/ipv6/udp.c      | 117 ++++------------------------------------------
 4 files changed, 154 insertions(+), 208 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d640925..f1a247a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -785,6 +785,13 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
 int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
 				 int addr_len);
+int ip6_datagram_send_common(struct sock *sk, struct msghdr *msg,
+			     struct sockaddr_in6 *sin6, int addr_len,
+			     struct flowi6 *fl6, struct dst_entry **dstp,
+			     struct ipv6_txoptions **optp,
+			     struct ipv6_txoptions *opt_space,
+			     int *hlimit, int *tclass, int *dontfrag,
+			     int *connected);
 
 int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len,
 		    int *addr_len);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index c3bf2d2..a7ec6ee 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -915,6 +915,137 @@ exit_f:
 }
 EXPORT_SYMBOL_GPL(ip6_datagram_send_ctl);
 
+int ip6_datagram_send_common(struct sock *sk, struct msghdr *msg,
+			     struct sockaddr_in6 *sin6, int addr_len,
+			     struct flowi6 *fl6, struct dst_entry **dstp,
+			     struct ipv6_txoptions **optp,
+			     struct ipv6_txoptions *opt_space,
+			     int *hlimit, int *tclass, int *dontfrag,
+			     int *connected) {
+	struct ipv6_txoptions *opt = NULL;
+	struct ip6_flowlabel *flowlabel = NULL;
+	struct in6_addr *final_p, final;
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct in6_addr *daddr;
+	struct dst_entry *dst;
+	int err;
+
+	*optp = NULL;
+	*dstp = NULL;
+	*hlimit = *tclass = *dontfrag = -1;
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
+	} else {
+		if (sk->sk_state != TCP_ESTABLISHED)
+			return -EDESTADDRREQ;
+
+		daddr = &sk->sk_v6_daddr;
+		fl6->flowlabel = np->flow_label;
+		*connected = 1;
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
+		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, fl6, opt,
+					    hlimit, tclass, dontfrag);
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
+		*connected = 0;
+	}
+	if (opt == NULL)
+		opt = np->opt;
+	if (flowlabel)
+		opt = fl6_merge_options(opt_space, flowlabel, opt);
+	opt = ipv6_fixup_options(opt_space, opt);
+
+	if (!ipv6_addr_any(daddr))
+		fl6->daddr = *daddr;
+	else
+		fl6->daddr.s6_addr[15] = 0x1; /* :: means loopback (BSD'ism) */
+	if (ipv6_addr_any(&fl6->saddr) && !ipv6_addr_any(&np->saddr))
+		fl6->saddr = np->saddr;
+
+	final_p = fl6_update_dst(fl6, opt, &final);
+	if (final_p)
+		*connected = 0;
+
+	if (!fl6->flowi6_oif && ipv6_addr_is_multicast(&fl6->daddr)) {
+		fl6->flowi6_oif = np->mcast_oif;
+		*connected = 0;
+	} else if (!fl6->flowi6_oif)
+		fl6->flowi6_oif = np->ucast_oif;
+
+	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
+
+	dst = ip6_sk_dst_lookup_flow(sk, fl6, final_p);
+	if (IS_ERR(dst)) {
+		fl6_sock_release(flowlabel);
+		return PTR_ERR(dst);
+	}
+
+	if (*hlimit < 0) {
+		if (ipv6_addr_is_multicast(&fl6->daddr))
+			*hlimit = np->mcast_hops;
+		else
+			*hlimit = np->hop_limit;
+		if (*hlimit < 0)
+			*hlimit = ip6_dst_hoplimit(dst);
+	}
+
+	if (*tclass < 0)
+		*tclass = np->tclass;
+
+	if (*dontfrag < 0)
+		*dontfrag = np->dontfrag;
+
+	*dstp = dst;
+	*optp = opt;
+
+	return 0;
+}
+
 void ip6_dgram_sock_seq_show(struct seq_file *seq, struct sock *sp,
 			     __u16 srcp, __u16 destp, int bucket)
 {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 1f29996..212fc95 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -739,20 +739,16 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 {
 	struct ipv6_txoptions opt_space;
 	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
-	struct in6_addr *daddr, *final_p, final;
 	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct raw6_sock *rp = raw6_sk(sk);
-	struct ipv6_txoptions *opt = NULL;
-	struct ip6_flowlabel *flowlabel = NULL;
-	struct dst_entry *dst = NULL;
+	struct ipv6_txoptions *opt;
+	struct dst_entry *dst;
 	struct flowi6 fl6;
 	int addr_len = msg->msg_namelen;
-	int hlimit = -1;
-	int tclass = -1;
-	int dontfrag = -1;
+	int hlimit, tclass, dontfrag;
 	u16 proto;
 	int err;
+	int connected;
 
 	/* Rough check on arithmetic overflow,
 	   better check is made in ip6_append_data().
@@ -769,8 +765,6 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	 */
 	memset(&fl6, 0, sizeof(fl6));
 
-	fl6.flowi6_mark = sk->sk_mark;
-
 	if (sin6) {
 		if (addr_len < SIN6_LEN_RFC2133)
 			return -EINVAL;
@@ -788,105 +782,21 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
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
-		if ((fl6.flowlabel&IPV6_FLOWLABEL_MASK) && !flowlabel) {
-			flowlabel = fl6_sock_lookup(sk, fl6.flowlabel);
-			if (flowlabel == NULL)
-				return -EINVAL;
-		}
-		if (!(opt->opt_nflen|opt->opt_flen))
-			opt = NULL;
-	}
-	if (opt == NULL)
-		opt = np->opt;
-	if (flowlabel)
-		opt = fl6_merge_options(&opt_space, flowlabel, opt);
-	opt = ipv6_fixup_options(&opt_space, opt);
-
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
+	err = ip6_datagram_send_common(sk, msg, sin6, addr_len, &fl6, &dst,
+				       &opt, &opt_space, &hlimit, &tclass,
+				       &dontfrag, &connected);
+	if (err)
 		goto out;
-	}
-	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl6.daddr))
-			hlimit = np->mcast_hops;
-		else
-			hlimit = np->hop_limit;
-		if (hlimit < 0)
-			hlimit = ip6_dst_hoplimit(dst);
-	}
-
-	if (tclass < 0)
-		tclass = np->tclass;
 
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
 
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
@@ -909,7 +819,6 @@ back_from_confirm:
 done:
 	dst_release(dst);
 out:
-	fl6_sock_release(flowlabel);
 	return err<0?err:len;
 do_confirm:
 	dst_confirm(dst);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1e586d9..777b423 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1044,16 +1044,13 @@ int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	DECLARE_SOCKADDR(struct sockaddr_in6 *, sin6, msg->msg_name);
-	struct in6_addr *daddr, *final_p, final;
-	struct ipv6_txoptions *opt = NULL;
-	struct ip6_flowlabel *flowlabel = NULL;
+	struct in6_addr *daddr;
+	struct ipv6_txoptions *opt;
 	struct flowi6 fl6;
 	struct dst_entry *dst;
 	int addr_len = msg->msg_namelen;
 	int ulen = len;
-	int hlimit = -1;
-	int tclass = -1;
-	int dontfrag = -1;
+	int hlimit, tclass, dontfrag;
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
 	int connected = 0;
@@ -1131,118 +1128,23 @@ do_udp_sendmsg:
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
+	err = ip6_datagram_send_common(sk, msg, sin6, addr_len, &fl6, &dst,
+				       &opt, &opt_space, &hlimit, &tclass,
+				       &dontfrag, &connected);
+	if (err)
 		goto out;
-	}
-
-	if (hlimit < 0) {
-		if (ipv6_addr_is_multicast(&fl6.daddr))
-			hlimit = np->mcast_hops;
-		else
-			hlimit = np->hop_limit;
-		if (hlimit < 0)
-			hlimit = ip6_dst_hoplimit(dst);
-	}
-
-	if (tclass < 0)
-		tclass = np->tclass;
 
 	if (msg->msg_flags&MSG_CONFIRM)
 		goto do_confirm;
@@ -1262,8 +1164,6 @@ back_from_confirm:
 	up->pending = AF_INET6;
 
 do_append_data:
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
 	up->len += ulen;
 	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
 	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
@@ -1298,7 +1198,6 @@ do_append_data:
 	release_sock(sk);
 out:
 	dst_release(dst);
-	fl6_sock_release(flowlabel);
 	if (!err)
 		return len;
 	/*
-- 
1.9.1.423.g4596e3a
