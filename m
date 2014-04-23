From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next v4 2/3] net: ipv6: Use ip6_datagram_send_common in L2TP IPv6.
Date: Wed, 23 Apr 2014 15:37:57 +0900
Message-ID: <1398235078-27088-2-git-send-email-lorenzo@google.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
 <1398235078-27088-1-git-send-email-lorenzo@google.com>
Cc: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
	davem@davemloft.net, eric.dumazet@gmail.com,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:42277 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753856AbaDWGiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 02:38:08 -0400
Received: by mail-pa0-f50.google.com with SMTP id rd3so450252pab.37
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 23:38:08 -0700 (PDT)
In-Reply-To: <1398235078-27088-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code was also virtually identical with the UDP and raw
socket sendmsg code.

Tested: compiles with CONFIG_IPV6={m,y} and CONFIG_L2TP_IP={m,y}.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/l2tp/l2tp_ip6.c | 112 ++++------------------------------------------------
 1 file changed, 8 insertions(+), 104 deletions(-)

diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 7704ea9..790db43 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -485,19 +485,15 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 {
 	struct ipv6_txoptions opt_space;
 	DECLARE_SOCKADDR(struct sockaddr_l2tpip6 *, lsa, msg->msg_name);
-	struct in6_addr *daddr, *final_p, final;
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct ipv6_txoptions *opt = NULL;
-	struct ip6_flowlabel *flowlabel = NULL;
+	struct ipv6_txoptions *opt;
 	struct dst_entry *dst = NULL;
 	struct flowi6 fl6;
 	int addr_len = msg->msg_namelen;
-	int hlimit = -1;
-	int tclass = -1;
-	int dontfrag = -1;
+	int hlimit, tclass, dontfrag;
 	int transhdrlen = 4; /* zero session-id */
 	int ulen = len + transhdrlen;
 	int err;
+	int connected;
 
 	/* Rough check on arithmetic overflow,
 	   better check is made in ip6_append_data().
@@ -514,7 +510,7 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	 */
 	memset(&fl6, 0, sizeof(fl6));
 
-	fl6.flowi6_mark = sk->sk_mark;
+	fl6.flowi6_proto = sk->sk_protocol;
 
 	if (lsa) {
 		if (addr_len < SIN6_LEN_RFC2133)
@@ -522,103 +518,13 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 
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
-		if ((fl6.flowlabel & IPV6_FLOWLABEL_MASK) && !flowlabel) {
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
+	err = ip6_datagram_send_common(sk, msg, (struct sockaddr_in6 *) lsa,
+				       addr_len, &fl6, &dst, &opt, &opt_space,
+				       &hlimit, &tclass, &dontfrag, &connected);
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
-
-	if (dontfrag < 0)
-		dontfrag = np->dontfrag;
 
 	if (msg->msg_flags & MSG_CONFIRM)
 		goto do_confirm;
@@ -637,8 +543,6 @@ back_from_confirm:
 done:
 	dst_release(dst);
 out:
-	fl6_sock_release(flowlabel);
-
 	return err < 0 ? err : len;
 
 do_confirm:
-- 
1.9.1.423.g4596e3a
