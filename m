From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH] LSM: Add inet_sys_snd_skb() LSM hook
Date: Wed, 19 Dec 2007 17:21:00 -0500
Message-ID: <20071219222100.1626.38321.stgit@flek.americas.hpqcorp.net>
References: <20071219220539.1626.46073.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:20370 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508AbXLSWVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 17:21:02 -0500
Received: from g4t0017.houston.hp.com (localhost.localdomain [127.0.0.1])
	by receive-from-antispam-filter (Postfix) with SMTP id 474023864B
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 22:21:02 +0000 (UTC)
Received: from smtp1.fc.hp.com (smtp.fc.hp.com [15.15.136.127])
	by g4t0017.houston.hp.com (Postfix) with ESMTP id 33DF838685
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 22:21:02 +0000 (UTC)
In-Reply-To: <20071219220539.1626.46073.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an inet_sys_snd_skb() LSM hook to allow the LSM to provide packet level
access control for all outbound packets.  Using the existing postroute_last
netfilter hook turns out to be problematic as it is can be invoked multiple
times for a single packet, e.g. individual IPsec transforms, adding unwanted
overhead and complicating the security policy.
---

 include/linux/security.h |   11 +++++++++++
 net/ipv4/ip_output.c     |    7 +++++++
 net/ipv6/ip6_output.c    |    5 +++++
 security/dummy.c         |    8 +++++++-
 security/security.c      |    6 ++++++
 5 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index db19c92..1b8d332 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -876,6 +876,10 @@ struct request_sock;
  *     Sets the connection's peersid to the secmark on skb.
  * @req_classify_flow:
  *	Sets the flow's sid to the openreq sid.
+ * @inet_sys_snd_skb:
+ *	Check permissions on outgoing network packets.
+ *	@skb is the packet to check
+ *	@family is the packet's address family
  *
  * Security hooks for XFRM operations.
  *
@@ -1416,6 +1420,7 @@ struct security_operations {
 	void (*inet_csk_clone)(struct sock *newsk, const struct request_sock *req);
 	void (*inet_conn_established)(struct sock *sk, struct sk_buff *skb);
 	void (*req_classify_flow)(const struct request_sock *req, struct flowi *fl);
+	int (*inet_sys_snd_skb)(struct sk_buff *skb, int family);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2328,6 +2333,7 @@ void security_sk_free(struct sock *sk);
 void security_sk_clone(const struct sock *sk, struct sock *newsk);
 void security_sk_classify_flow(struct sock *sk, struct flowi *fl);
 void security_req_classify_flow(const struct request_sock *req, struct flowi *fl);
+int security_inet_sys_snd_skb(struct sk_buff *skb, int family);
 void security_sock_graft(struct sock*sk, struct socket *parent);
 int security_inet_conn_request(struct sock *sk,
 			struct sk_buff *skb, struct request_sock *req);
@@ -2471,6 +2477,11 @@ static inline void security_req_classify_flow(const struct request_sock *req, st
 {
 }
 
+static inline int security_inet_sys_snd_skb(struct sk_buff *skb, int family)
+{
+	return 0;
+}
+
 static inline void security_sock_graft(struct sock* sk, struct socket *parent)
 {
 }
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index fd99fbd..82a7297 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -204,6 +204,8 @@ static inline int ip_skb_dst_mtu(struct sk_buff *skb)
 
 static int ip_finish_output(struct sk_buff *skb)
 {
+	int err;
+
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
 	if (skb->dst->xfrm != NULL) {
@@ -211,6 +213,11 @@ static int ip_finish_output(struct sk_buff *skb)
 		return dst_output(skb);
 	}
 #endif
+
+	err = security_inet_sys_snd_skb(skb, AF_INET);
+	if (err)
+		return err;
+
 	if (skb->len > ip_skb_dst_mtu(skb) && !skb_is_gso(skb))
 		return ip_fragment(skb, ip_finish_output2);
 	else
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6338a9c..44ddf32 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -72,8 +72,13 @@ static __inline__ void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *f
 
 static int ip6_output_finish(struct sk_buff *skb)
 {
+	int err;
 	struct dst_entry *dst = skb->dst;
 
+	err = security_inet_sys_snd_skb(skb, AF_INET6);
+	if (err)
+		return err;
+
 	if (dst->hh)
 		return neigh_hh_output(dst->hh, skb);
 	else if (dst->neighbour)
diff --git a/security/dummy.c b/security/dummy.c
index 0b62f95..384979a 100644
--- a/security/dummy.c
+++ b/security/dummy.c
@@ -848,6 +848,11 @@ static inline void dummy_req_classify_flow(const struct request_sock *req,
 			struct flowi *fl)
 {
 }
+
+static inline int dummy_inet_sys_snd_skb(struct sk_buff *skb, int family)
+{
+	return 0;
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1122,7 +1127,8 @@ void security_fixup_ops (struct security_operations *ops)
 	set_to_dummy_if_null(ops, inet_csk_clone);
 	set_to_dummy_if_null(ops, inet_conn_established);
 	set_to_dummy_if_null(ops, req_classify_flow);
- #endif	/* CONFIG_SECURITY_NETWORK */
+	set_to_dummy_if_null(ops, inet_sys_snd_skb);
+#endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef  CONFIG_SECURITY_NETWORK_XFRM
 	set_to_dummy_if_null(ops, xfrm_policy_alloc_security);
 	set_to_dummy_if_null(ops, xfrm_policy_clone_security);
diff --git a/security/security.c b/security/security.c
index 3bdcada..7f55459 100644
--- a/security/security.c
+++ b/security/security.c
@@ -961,6 +961,12 @@ void security_req_classify_flow(const struct request_sock *req, struct flowi *fl
 }
 EXPORT_SYMBOL(security_req_classify_flow);
 
+int security_inet_sys_snd_skb(struct sk_buff *skb, int family)
+{
+	return security_ops->inet_sys_snd_skb(skb, family);
+}
+EXPORT_SYMBOL(security_inet_sys_snd_skb);
+
 void security_sock_graft(struct sock *sk, struct socket *parent)
 {
 	security_ops->sock_graft(sk, parent);

