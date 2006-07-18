From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 08/10] MLSXFRM-v02: Add flow labeling
Date: Tue, 18 Jul 2006 12:24:50 -0500
Message-ID: <44BD1962.3040306@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, tjaeger@cse.psu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:45345 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932325AbWGRRZN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:25:13 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This labels the flows that could utilize IPSec xfrms at the points the
flows are defined so that IPSec policy and SAs at the right label can be used.

The following protos are currently not handled, but they should continue
to be able to use single-labeled IPSec like they currently do.

ipmr
ip_gre
ipip
igmp
sit
sctp
ip6_tunnel (IPv6 over IPv6 tunnel device)
decnet


Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
---
 include/linux/security.h         |   38 +++++++++++++++++++----------
 include/net/route.h              |    3 ++
 net/dccp/ipv4.c                  |    1 
 net/dccp/ipv6.c                  |    6 ++++
 net/ipv4/af_inet.c               |    1 
 net/ipv4/icmp.c                  |    2 +
 net/ipv4/inet_connection_sock.c  |    1 
 net/ipv4/ip_output.c             |    2 +
 net/ipv4/netfilter/ipt_REJECT.c  |    1 
 net/ipv4/raw.c                   |    1 
 net/ipv4/syncookies.c            |    1 
 net/ipv4/udp.c                   |    1 
 net/ipv6/af_inet6.c              |    1 
 net/ipv6/datagram.c              |    2 +
 net/ipv6/icmp.c                  |    2 +
 net/ipv6/inet6_connection_sock.c |    1 
 net/ipv6/ndisc.c                 |    1 
 net/ipv6/netfilter/ip6t_REJECT.c |    1 
 net/ipv6/raw.c                   |    1 
 net/ipv6/tcp_ipv6.c              |    7 +++++
 net/ipv6/udp.c                   |    2 +
 net/xfrm/xfrm_policy.c           |    3 --
 security/dummy.c                 |    7 ++---
 security/selinux/hooks.c         |    8 +++---
 security/selinux/include/xfrm.h  |   14 ----------
 security/selinux/xfrm.c          |   11 +++++---
 26 files changed, 79 insertions(+), 40 deletions(-)

--- linux-2.6.17.af_key/include/linux/security.h	2006-07-17 14:10:26.000000000 -0500
+++ linux-2.6.17/include/linux/security.h	2006-07-17 16:25:29.000000000 -0500
@@ -32,6 +32,7 @@
 #include <linux/sched.h>
 #include <linux/key.h>
 #include <linux/xfrm.h>
+#include <net/flow.h>
 
 struct ctl_table;
 
@@ -815,8 +816,8 @@ struct swap_info_struct;
  *	Deallocate security structure.
  * @sk_clone_security:
  *	Clone/copy security structure.
- * @sk_getsid:
- *	Retrieve the LSM-specific sid for the sock to enable caching of network
+ * @sk_getsecid:
+ *	Retrieve the LSM-specific secid for the sock to enable caching of network
  *	authorizations.
  *
  * Security hooks for XFRM operations.
@@ -882,8 +883,9 @@ struct swap_info_struct;
  *	Return 1 if there is a match.
  * @xfrm_decode_session:
  *	@skb points to skb to decode.
- *	@fl points to the flow key to set.
- *	Return 0 if successful decoding.
+ *	@secid points to the flow key secid to set.
+ *	@ckall says if all xfrms used should be checked for same secid.
+ *	Return 0 if ckall is zero or all xfrms used have the same secid.
  *
  * Security hooks affecting all Key Management operations
  *
@@ -1341,7 +1343,7 @@ struct security_operations {
 	int (*sk_alloc_security) (struct sock *sk, int family, gfp_t priority);
 	void (*sk_free_security) (struct sock *sk);
 	void (*sk_clone_security) (const struct sock *sk, struct sock *newsk);
-	unsigned int (*sk_getsid) (struct sock *sk, struct flowi *fl, u8 dir);
+	void (*sk_getsecid) (struct sock *sk, u32 *secid);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1358,7 +1360,7 @@ struct security_operations {
 	int (*xfrm_state_pol_flow_match)(struct xfrm_state *x,
 			struct xfrm_policy *xp, struct flowi *fl);
 	int (*xfrm_flow_state_match)(struct flowi *fl, struct xfrm_state *xfrm);
-	int (*xfrm_decode_session)(struct sk_buff *skb, struct flowi *fl);
+	int (*xfrm_decode_session)(struct sk_buff *skb, u32 *secid, int ckall);
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 
 	/* key management security hooks */
@@ -2888,9 +2890,9 @@ static inline void security_sk_clone(con
 	return security_ops->sk_clone_security(sk, newsk);
 }
 
-static inline unsigned int security_sk_sid(struct sock *sk, struct flowi *fl, u8 dir)
+static inline void security_sk_classify_flow(struct sock *sk, struct flowi *fl)
 {
-	return security_ops->sk_getsid(sk, fl, dir);
+	security_ops->sk_getsecid(sk, &fl->secid);
 }
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct socket * sock,
@@ -3019,9 +3021,8 @@ static inline void security_sk_clone(con
 {
 }
 
-static inline unsigned int security_sk_sid(struct sock *sk, struct flowi *fl, u8 dir)
+static inline void security_sk_classify_flow(struct sock *sk, struct flowi *fl)
 {
-	return 0;
 }
 #endif	/* CONFIG_SECURITY_NETWORK */
 
@@ -3086,9 +3087,16 @@ static inline int security_xfrm_flow_sta
 	return security_ops->xfrm_flow_state_match(fl, xfrm);
 }
 
-static inline int security_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl)
+static inline int security_xfrm_decode_session(struct sk_buff *skb, u32 *secid)
+{
+	return security_ops->xfrm_decode_session(skb, secid, 1);
+}
+
+static inline void security_skb_classify_flow(struct sk_buff *skb, struct flowi *fl)
 {
-	return security_ops->xfrm_decode_session(skb, fl);
+	int rc = security_ops->xfrm_decode_session(skb, &fl->secid, 0);
+
+	BUG_ON(rc);
 }
 #else	/* CONFIG_SECURITY_NETWORK_XFRM */
 static inline int security_xfrm_policy_alloc(struct xfrm_policy *xp, struct xfrm_user_sec_ctx *sec_ctx)
@@ -3148,11 +3156,15 @@ static inline int security_xfrm_flow_sta
 	return 1;
 }
 
-static inline int security_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl)
+static inline int security_xfrm_decode_session(struct sk_buff *skb, u32 *secid)
 {
 	return 0;
 }
 
+static inline void security_skb_classify_flow(struct sk_buff *skb, struct flowi *fl)
+{
+}
+
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 
 #ifdef CONFIG_KEYS
--- linux-2.6.17.af_key/include/net/route.h	2006-07-14 09:28:24.000000000 -0500
+++ linux-2.6.17/include/net/route.h	2006-07-17 16:05:38.000000000 -0500
@@ -32,6 +32,7 @@
 #include <linux/route.h>
 #include <linux/ip.h>
 #include <linux/cache.h>
+#include <linux/security.h>
 
 #ifndef __KERNEL__
 #warning This file is not supposed to be used outside of kernel.
@@ -166,6 +167,7 @@ static inline int ip_route_connect(struc
 		ip_rt_put(*rp);
 		*rp = NULL;
 	}
+	security_sk_classify_flow(sk, &fl);
 	return ip_route_output_flow(rp, &fl, sk, 0);
 }
 
@@ -182,6 +184,7 @@ static inline int ip_route_newports(stru
 		fl.proto = protocol;
 		ip_rt_put(*rp);
 		*rp = NULL;
+		security_sk_classify_flow(sk, &fl);
 		return ip_route_output_flow(rp, &fl, sk, 0);
 	}
 	return 0;
--- linux-2.6.17.af_key/security/dummy.c	2006-07-17 14:10:26.000000000 -0500
+++ linux-2.6.17/security/dummy.c	2006-07-17 16:05:38.000000000 -0500
@@ -810,9 +810,8 @@ static inline void dummy_sk_clone_securi
 {
 }
 
-static unsigned int dummy_sk_getsid(struct sock *sk, struct flowi *fl, u8 dir)
+static inline void dummy_sk_getsecid(struct sock *sk, u32 *secid)
 {
-	return 0;
 }
 #endif	/* CONFIG_SECURITY_NETWORK */
 
@@ -867,7 +866,7 @@ static int dummy_xfrm_flow_state_match(s
 	return 1;
 }
 
-static int dummy_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl)
+static int dummy_xfrm_decode_session(struct sk_buff *skb, u32 *fl, int ckall)
 {
 	return 0;
 }
@@ -1073,7 +1072,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, sk_alloc_security);
 	set_to_dummy_if_null(ops, sk_free_security);
 	set_to_dummy_if_null(ops, sk_clone_security);
-	set_to_dummy_if_null(ops, sk_getsid);
+	set_to_dummy_if_null(ops, sk_getsecid);
  #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
 	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);
--- linux-2.6.17.af_key/security/selinux/hooks.c	2006-07-17 14:10:26.000000000 -0500
+++ linux-2.6.17/security/selinux/hooks.c	2006-07-17 16:07:42.000000000 -0500
@@ -3565,14 +3565,14 @@ static void selinux_sk_clone_security(co
 	newssec->peer_sid = ssec->peer_sid;
 }
 
-static unsigned int selinux_sk_getsid_security(struct sock *sk, struct flowi *fl, u8 dir)
+static void selinux_sk_getsecid(struct sock *sk, u32 *secid)
 {
 	if (!sk)
-		return selinux_no_sk_sid(fl);
+		*secid = SECINITSID_ANY_SOCKET;
 	else {
 		struct sk_security_struct *sksec = sk->sk_security;
 
-		return sksec->sid;
+		*secid = sksec->sid;
 	}
 }
 
@@ -4612,7 +4612,7 @@ static struct security_operations selinu
 	.sk_alloc_security =		selinux_sk_alloc_security,
 	.sk_free_security =		selinux_sk_free_security,
 	.sk_clone_security =		selinux_sk_clone_security,
-	.sk_getsid = 			selinux_sk_getsid_security,
+	.sk_getsecid = 			selinux_sk_getsecid,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,
--- linux-2.6.17.af_key/security/selinux/include/xfrm.h	2006-07-17 14:10:26.000000000 -0500
+++ linux-2.6.17/security/selinux/include/xfrm.h	2006-07-17 16:08:29.000000000 -0500
@@ -19,7 +19,7 @@ int selinux_xfrm_policy_lookup(struct xf
 int selinux_xfrm_state_pol_flow_match(struct xfrm_state *x,
 			struct xfrm_policy *xp, struct flowi *fl);
 int selinux_xfrm_flow_state_match(struct flowi *fl, struct xfrm_state *xfrm);
-int selinux_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl);
+int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *fl, int ckall);
 
 
 /*
@@ -33,18 +33,6 @@ static inline struct inode_security_stru
 	return SOCK_INODE(sk->sk_socket)->i_security;
 }
 
-
-static inline u32 selinux_no_sk_sid(struct flowi *fl)
-{
-	/* NOTE: no sock occurs on ICMP reply, forwards, ... */
-	/* icmp_reply: authorize as kernel packet */
-	if (fl && fl->proto == IPPROTO_ICMP) {
-		return SECINITSID_KERNEL;
-	}
-
-	return SECINITSID_ANY_SOCKET;
-}
-
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 int selinux_xfrm_sock_rcv_skb(u32 sid, struct sk_buff *skb,
 			struct avc_audit_data *ad);
--- linux-2.6.17.af_key/security/selinux/xfrm.c	2006-07-17 14:10:26.000000000 -0500
+++ linux-2.6.17/security/selinux/xfrm.c	2006-07-17 16:05:38.000000000 -0500
@@ -158,11 +158,11 @@ int selinux_xfrm_flow_state_match(struct
  * LSM hook implementation that determines the sid for the session.
  */
 
-int selinux_xfrm_decode_session(struct sk_buff *skb, struct flowi *fl)
+int selinux_xfrm_decode_session(struct sk_buff *skb, u32 *sid, int ckall)
 {
 	struct sec_path *sp;
 
-	fl->secid = SECSID_NULL;
+	*sid = SECSID_NULL;
 
 	if (skb == NULL)
 		return 0;
@@ -177,10 +177,13 @@ int selinux_xfrm_decode_session(struct s
 				struct xfrm_sec_ctx *ctx = x->security;
 
 				if (!sid_set) {
-					fl->secid = ctx->ctx_sid;
+					*sid = ctx->ctx_sid;
 					sid_set = 1;
+
+					if (!ckall)
+						break;
 				}
-				else if (fl->secid != ctx->ctx_sid)
+				else if (*sid != ctx->ctx_sid)
 					return -EINVAL;
 			}
 		}
--- linux-2.6.17.af_key/net/dccp/ipv4.c	2006-07-14 09:28:31.000000000 -0500
+++ linux-2.6.17/net/dccp/ipv4.c	2006-07-17 16:05:38.000000000 -0500
@@ -679,6 +679,7 @@ static struct dst_entry* dccp_v4_route_s
 			   	     }
 			  };
 
+	security_skb_classify_flow(skb, &fl);
 	if (ip_route_output_flow(&rt, &fl, sk, 0)) {
 		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
--- linux-2.6.17.af_key/net/dccp/ipv6.c	2006-07-14 09:28:31.000000000 -0500
+++ linux-2.6.17/net/dccp/ipv6.c	2006-07-17 16:05:38.000000000 -0500
@@ -200,6 +200,7 @@ static int dccp_v6_connect(struct sock *
 	fl.oif = sk->sk_bound_dev_if;
 	fl.fl_ip_dport = usin->sin6_port;
 	fl.fl_ip_sport = inet->sport;
+	security_sk_classify_flow(sk, &fl);
 
 	if (np->opt != NULL && np->opt->srcrt != NULL) {
 		const struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
@@ -321,6 +322,7 @@ static void dccp_v6_err(struct sk_buff *
 			fl.oif = sk->sk_bound_dev_if;
 			fl.fl_ip_dport = inet->dport;
 			fl.fl_ip_sport = inet->sport;
+			security_sk_classify_flow(sk, &fl);
 
 			err = ip6_dst_lookup(sk, &dst, &fl);
 			if (err) {
@@ -421,6 +423,7 @@ static int dccp_v6_send_response(struct 
 	fl.oif = ireq6->iif;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_sk(sk)->sport;
+	security_sk_classify_flow(sk, &fl);
 
 	if (dst == NULL) {
 		opt = np->opt;
@@ -565,6 +568,7 @@ static void dccp_v6_ctl_send_reset(struc
 	fl.oif = inet6_iif(rxskb);
 	fl.fl_ip_dport = dh->dccph_dport;
 	fl.fl_ip_sport = dh->dccph_sport;
+	security_skb_classify_flow(rxskb, &fl);
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
 	if (!ip6_dst_lookup(NULL, &skb->dst, &fl)) {
@@ -621,6 +625,7 @@ static void dccp_v6_reqsk_send_ack(struc
 	fl.oif = inet6_iif(rxskb);
 	fl.fl_ip_dport = dh->dccph_dport;
 	fl.fl_ip_sport = dh->dccph_sport;
+	security_skb_classify_flow(rxskb, &fl);
 
 	if (!ip6_dst_lookup(NULL, &skb->dst, &fl)) {
 		if (xfrm_lookup(&skb->dst, &fl, NULL, 0) >= 0) {
@@ -842,6 +847,7 @@ static struct sock *dccp_v6_request_recv
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->sport;
+		security_sk_classify_flow(sk, &fl);
 
 		if (ip6_dst_lookup(sk, &dst, &fl))
 			goto out;
--- linux-2.6.17.af_key/net/ipv4/af_inet.c	2006-07-14 09:57:21.000000000 -0500
+++ linux-2.6.17/net/ipv4/af_inet.c	2006-07-17 16:05:38.000000000 -0500
@@ -1074,6 +1074,7 @@ int inet_sk_rebuild_header(struct sock *
 		},
 	};
 						
+	security_sk_classify_flow(sk, &fl);
 	err = ip_route_output_flow(&rt, &fl, sk, 0);
 }
 	if (!err)
--- linux-2.6.17.af_key/net/ipv4/icmp.c	2006-07-14 09:28:33.000000000 -0500
+++ linux-2.6.17/net/ipv4/icmp.c	2006-07-17 16:05:38.000000000 -0500
@@ -406,6 +406,7 @@ static void icmp_reply(struct icmp_bxm *
 						.saddr = rt->rt_spec_dst,
 						.tos = RT_TOS(skb->nh.iph->tos) } },
 				    .proto = IPPROTO_ICMP };
+		security_skb_classify_flow(skb, &fl);
 		if (ip_route_output_key(&rt, &fl))
 			goto out_unlock;
 	}
@@ -560,6 +561,7 @@ void icmp_send(struct sk_buff *skb_in, i
 				}
 			}
 		};
+		security_skb_classify_flow(skb_in, &fl);
 		if (ip_route_output_key(&rt, &fl))
 			goto out_unlock;
 	}
--- linux-2.6.17.af_key/net/ipv4/inet_connection_sock.c	2006-07-14 09:28:33.000000000 -0500
+++ linux-2.6.17/net/ipv4/inet_connection_sock.c	2006-07-17 16:05:38.000000000 -0500
@@ -327,6 +327,7 @@ struct dst_entry* inet_csk_route_req(str
 				       { .sport = inet_sk(sk)->sport,
 					 .dport = ireq->rmt_port } } };
 
+	security_sk_classify_flow(sk, &fl);
 	if (ip_route_output_flow(&rt, &fl, sk, 0)) {
 		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
--- linux-2.6.17.af_key/net/ipv4/ip_output.c	2006-07-14 09:57:21.000000000 -0500
+++ linux-2.6.17/net/ipv4/ip_output.c	2006-07-17 16:05:38.000000000 -0500
@@ -328,6 +328,7 @@ int ip_queue_xmit(struct sk_buff *skb, i
 			 * keep trying until route appears or the connection times
 			 * itself out.
 			 */
+			security_sk_classify_flow(sk, &fl);
 			if (ip_route_output_flow(&rt, &fl, sk, 0))
 				goto no_route;
 		}
@@ -1364,6 +1365,7 @@ void ip_send_reply(struct sock *sk, stru
 					       { .sport = skb->h.th->dest,
 					         .dport = skb->h.th->source } },
 				    .proto = sk->sk_protocol };
+		security_skb_classify_flow(skb, &fl);
 		if (ip_route_output_key(&rt, &fl))
 			return;
 	}
--- linux-2.6.17.af_key/net/ipv4/netfilter/ipt_REJECT.c	2006-07-14 09:28:33.000000000 -0500
+++ linux-2.6.17/net/ipv4/netfilter/ipt_REJECT.c	2006-07-17 16:05:38.000000000 -0500
@@ -90,6 +90,7 @@ static inline struct rtable *route_rever
 	fl.proto = IPPROTO_TCP;
 	fl.fl_ip_sport = tcph->dest;
 	fl.fl_ip_dport = tcph->source;
+	security_skb_classify_flow(skb, &fl);
 
 	xfrm_lookup((struct dst_entry **)&rt, &fl, NULL, 0);
 
--- linux-2.6.17.af_key/net/ipv4/raw.c	2006-07-14 09:28:33.000000000 -0500
+++ linux-2.6.17/net/ipv4/raw.c	2006-07-17 16:05:38.000000000 -0500
@@ -484,6 +484,7 @@ static int raw_sendmsg(struct kiocb *ioc
 		if (!inet->hdrincl)
 			raw_probe_proto_opt(&fl, msg);
 
+		security_sk_classify_flow(sk, &fl);
 		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
 	}
 	if (err)
--- linux-2.6.17.af_key/net/ipv4/syncookies.c	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/net/ipv4/syncookies.c	2006-07-17 16:05:38.000000000 -0500
@@ -259,6 +259,7 @@ struct sock *cookie_v4_check(struct sock
 				    .uli_u = { .ports =
 					       { .sport = skb->h.th->dest,
 						 .dport = skb->h.th->source } } };
+		security_sk_classify_flow(sk, &fl);
 		if (ip_route_output_key(&rt, &fl)) {
 			reqsk_free(req);
 			goto out; 
--- linux-2.6.17.af_key/net/ipv4/udp.c	2006-07-14 09:28:33.000000000 -0500
+++ linux-2.6.17/net/ipv4/udp.c	2006-07-17 16:05:38.000000000 -0500
@@ -603,6 +603,7 @@ int udp_sendmsg(struct kiocb *iocb, stru
 				    .uli_u = { .ports =
 					       { .sport = inet->sport,
 						 .dport = dport } } };
+		security_sk_classify_flow(sk, &fl);
 		err = ip_route_output_flow(&rt, &fl, sk, !(msg->msg_flags&MSG_DONTWAIT));
 		if (err)
 			goto out;
--- linux-2.6.17.af_key/net/ipv6/af_inet6.c	2006-07-14 09:28:33.000000000 -0500
+++ linux-2.6.17/net/ipv6/af_inet6.c	2006-07-17 16:05:38.000000000 -0500
@@ -637,6 +637,7 @@ int inet6_sk_rebuild_header(struct sock 
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet->dport;
 		fl.fl_ip_sport = inet->sport;
+		security_sk_classify_flow(sk, &fl);
 
 		if (np->opt && np->opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
--- linux-2.6.17.af_key/net/ipv6/datagram.c	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/net/ipv6/datagram.c	2006-07-17 16:05:38.000000000 -0500
@@ -156,6 +156,8 @@ ipv4_connected:
 	if (!fl.oif && (addr_type&IPV6_ADDR_MULTICAST))
 		fl.oif = np->mcast_oif;
 
+	security_sk_classify_flow(sk, &fl);
+
 	if (flowlabel) {
 		if (flowlabel->opt && flowlabel->opt->srcrt) {
 			struct rt0_hdr *rt0 = (struct rt0_hdr *) flowlabel->opt->srcrt;
--- linux-2.6.17.af_key/net/ipv6/icmp.c	2006-07-14 09:57:21.000000000 -0500
+++ linux-2.6.17/net/ipv6/icmp.c	2006-07-17 16:05:38.000000000 -0500
@@ -358,6 +358,7 @@ void icmpv6_send(struct sk_buff *skb, in
 	fl.oif = iif;
 	fl.fl_icmp_type = type;
 	fl.fl_icmp_code = code;
+	security_skb_classify_flow(skb, &fl);
 
 	if (icmpv6_xmit_lock())
 		return;
@@ -472,6 +473,7 @@ static void icmpv6_echo_reply(struct sk_
 		ipv6_addr_copy(&fl.fl6_src, saddr);
 	fl.oif = skb->dev->ifindex;
 	fl.fl_icmp_type = ICMPV6_ECHO_REPLY;
+	security_skb_classify_flow(skb, &fl);
 
 	if (icmpv6_xmit_lock())
 		return;
--- linux-2.6.17.af_key/net/ipv6/inet6_connection_sock.c	2006-07-14 09:28:35.000000000 -0500
+++ linux-2.6.17/net/ipv6/inet6_connection_sock.c	2006-07-17 16:05:38.000000000 -0500
@@ -157,6 +157,7 @@ int inet6_csk_xmit(struct sk_buff *skb, 
 	fl.oif = sk->sk_bound_dev_if;
 	fl.fl_ip_sport = inet->sport;
 	fl.fl_ip_dport = inet->dport;
+	security_sk_classify_flow(sk, &fl);
 
 	if (np->opt && np->opt->srcrt) {
 		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
--- linux-2.6.17.af_key/net/ipv6/ndisc.c	2006-07-14 09:28:35.000000000 -0500
+++ linux-2.6.17/net/ipv6/ndisc.c	2006-07-17 16:05:38.000000000 -0500
@@ -419,6 +419,7 @@ static inline void ndisc_flow_init(struc
 	fl->proto	 	= IPPROTO_ICMPV6;
 	fl->fl_icmp_type	= type;
 	fl->fl_icmp_code	= 0;
+	security_sk_classify_flow(ndisc_socket->sk, fl);
 }
 
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
--- linux-2.6.17.af_key/net/ipv6/netfilter/ip6t_REJECT.c	2006-07-14 09:28:35.000000000 -0500
+++ linux-2.6.17/net/ipv6/netfilter/ip6t_REJECT.c	2006-07-17 16:05:38.000000000 -0500
@@ -96,6 +96,7 @@ static void send_reset(struct sk_buff *o
 	ipv6_addr_copy(&fl.fl6_dst, &oip6h->saddr);
 	fl.fl_ip_sport = otcph.dest;
 	fl.fl_ip_dport = otcph.source;
+	security_skb_classify_flow(oldskb, &fl);
 	dst = ip6_route_output(NULL, &fl);
 	if (dst == NULL)
 		return;
--- linux-2.6.17.af_key/net/ipv6/raw.c	2006-06-17 20:49:35.000000000 -0500
+++ linux-2.6.17/net/ipv6/raw.c	2006-07-17 16:05:38.000000000 -0500
@@ -758,6 +758,7 @@ static int rawv6_sendmsg(struct kiocb *i
 
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
+	security_sk_classify_flow(sk, &fl);
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
--- linux-2.6.17.af_key/net/ipv6/tcp_ipv6.c	2006-07-14 09:57:21.000000000 -0500
+++ linux-2.6.17/net/ipv6/tcp_ipv6.c	2006-07-17 16:05:38.000000000 -0500
@@ -251,6 +251,8 @@ static int tcp_v6_connect(struct sock *s
 		final_p = &final;
 	}
 
+	security_sk_classify_flow(sk, &fl);
+
 	err = ip6_dst_lookup(sk, &dst, &fl);
 	if (err)
 		goto failure;
@@ -374,6 +376,7 @@ static void tcp_v6_err(struct sk_buff *s
 			fl.oif = sk->sk_bound_dev_if;
 			fl.fl_ip_dport = inet->dport;
 			fl.fl_ip_sport = inet->sport;
+			security_skb_classify_flow(skb, &fl);
 
 			if ((err = ip6_dst_lookup(sk, &dst, &fl))) {
 				sk->sk_err_soft = -err;
@@ -468,6 +471,7 @@ static int tcp_v6_send_synack(struct soc
 	fl.oif = treq->iif;
 	fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport = inet_sk(sk)->sport;
+	security_sk_classify_flow(sk, &fl);
 
 	if (dst == NULL) {
 		opt = np->opt;
@@ -626,6 +630,7 @@ static void tcp_v6_send_reset(struct sk_
 	fl.oif = inet6_iif(skb);
 	fl.fl_ip_dport = t1->dest;
 	fl.fl_ip_sport = t1->source;
+	security_skb_classify_flow(skb, &fl);
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
@@ -692,6 +697,7 @@ static void tcp_v6_send_ack(struct sk_bu
 	fl.oif = inet6_iif(skb);
 	fl.fl_ip_dport = t1->dest;
 	fl.fl_ip_sport = t1->source;
+	security_skb_classify_flow(skb, &fl);
 
 	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >= 0) {
@@ -925,6 +931,7 @@ static struct sock * tcp_v6_syn_recv_soc
 		fl.oif = sk->sk_bound_dev_if;
 		fl.fl_ip_dport = inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport = inet_sk(sk)->sport;
+		security_sk_classify_flow(sk, &fl);
 
 		if (ip6_dst_lookup(sk, &dst, &fl))
 			goto out;
--- linux-2.6.17.af_key/net/ipv6/udp.c	2006-07-14 09:28:35.000000000 -0500
+++ linux-2.6.17/net/ipv6/udp.c	2006-07-17 16:05:38.000000000 -0500
@@ -782,6 +782,8 @@ do_udp_sendmsg:
 		connected = 0;
 	}
 
+	security_sk_classify_flow(sk, fl);
+
 	err = ip6_dst_lookup(sk, &dst, fl);
 	if (err)
 		goto out;
--- linux-2.6.17.af_key/net/xfrm/xfrm_policy.c	2006-07-17 14:10:26.000000000 -0500
+++ linux-2.6.17/net/xfrm/xfrm_policy.c	2006-07-17 16:05:38.000000000 -0500
@@ -864,7 +864,6 @@ int xfrm_lookup(struct dst_entry **dst_p
 	u16 family;
 	u8 dir = policy_to_flow_dir(XFRM_POLICY_OUT);
 
-	fl->secid = security_sk_sid(sk, fl, dir);
 restart:
 	genid = atomic_read(&flow_cache_genid);
 	policy = NULL;
@@ -1040,7 +1039,7 @@ xfrm_decode_session(struct sk_buff *skb,
 		return -EAFNOSUPPORT;
 
 	afinfo->decode_session(skb, fl);
-	err = security_xfrm_decode_session(skb, fl);
+	err = security_xfrm_decode_session(skb, &fl->secid);
 	xfrm_policy_put_afinfo(afinfo);
 	return err;
 }
