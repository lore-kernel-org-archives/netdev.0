From: Richard Haines <richard_c_haines@btinternet.com>
Subject: [RFC PATCH 4/5] netlabel: Add SCTP support
Date: Tue, 17 Oct 2017 14:58:54 +0100
Message-ID: <20171017135854.4343-1-richard_c_haines@btinternet.com>
Cc: paul@paul-moore.com, vyasevich@gmail.com, nhorman@tuxdriver.com,
        sds@tycho.nsa.gov, eparis@parisplace.org,
        marcelo.leitner@gmail.com,
        Richard Haines <richard_c_haines@btinternet.com>
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support to label SCTP associations and cater for a situation where
family = PF_INET6 with an ip_hdr(skb)->version = 4.

Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
---
 include/net/netlabel.h            |  3 ++
 net/netlabel/netlabel_kapi.c      | 80 +++++++++++++++++++++++++++++++++++++++
 net/netlabel/netlabel_unlabeled.c | 10 +++++
 3 files changed, 93 insertions(+)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 72d6435..7348966 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -494,6 +494,9 @@ int netlbl_conn_setattr(struct sock *sk,
 			const struct netlbl_lsm_secattr *secattr);
 int netlbl_req_setattr(struct request_sock *req,
 		       const struct netlbl_lsm_secattr *secattr);
+int netlbl_sctp_setattr(struct sock *sk,
+			struct sk_buff *skb,
+			const struct netlbl_lsm_secattr *secattr);
 void netlbl_req_delattr(struct request_sock *req);
 int netlbl_skbuff_setattr(struct sk_buff *skb,
 			  u16 family,
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index ea7c670..1c82bbe 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -1121,6 +1121,7 @@ int netlbl_conn_setattr(struct sock *sk,
 	switch (addr->sa_family) {
 	case AF_INET:
 		addr4 = (struct sockaddr_in *)addr;
+
 		entry = netlbl_domhsh_getentry_af4(secattr->domain,
 						   addr4->sin_addr.s_addr);
 		if (entry == NULL) {
@@ -1177,6 +1178,85 @@ int netlbl_conn_setattr(struct sock *sk,
 }
 
 /**
+ * netlbl_sctp_setattr - Label an incoming sctp association socket using
+ * the correct protocol
+ * @sk: the socket to label
+ * @skb: the packet
+ * @secattr: the security attributes
+ *
+ * Description:
+ * Attach the correct label to the given socket using the security attributes
+ * specified in @secattr.  Returns zero on success, negative values on failure.
+ *
+ */
+int netlbl_sctp_setattr(struct sock *sk,
+			struct sk_buff *skb,
+			const struct netlbl_lsm_secattr *secattr)
+{
+	int ret_val = -EINVAL;
+	struct netlbl_dommap_def *entry;
+	struct iphdr *hdr4;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct ipv6hdr *hdr6;
+#endif
+
+	rcu_read_lock();
+	switch (sk->sk_family) {
+	case AF_INET:
+		hdr4 = ip_hdr(skb);
+
+		entry = netlbl_domhsh_getentry_af4(secattr->domain,
+						   hdr4->saddr);
+		if (entry == NULL) {
+			ret_val = -ENOENT;
+			goto sctp_setattr_return;
+		}
+		switch (entry->type) {
+		case NETLBL_NLTYPE_CIPSOV4:
+			ret_val = cipso_v4_sock_setattr(sk, entry->cipso,
+							secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			netlbl_sock_delattr(sk);
+			ret_val = 0;
+			break;
+		default:
+			ret_val = -ENOENT;
+		}
+		break;
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6:
+		hdr6 = ipv6_hdr(skb);
+		entry = netlbl_domhsh_getentry_af6(secattr->domain,
+						   &hdr6->saddr);
+		if (entry == NULL) {
+			ret_val = -ENOENT;
+			goto sctp_setattr_return;
+		}
+		switch (entry->type) {
+		case NETLBL_NLTYPE_CALIPSO:
+			ret_val = calipso_sock_setattr(sk, entry->calipso,
+						       secattr);
+			break;
+		case NETLBL_NLTYPE_UNLABELED:
+			netlbl_sock_delattr(sk);
+			ret_val = 0;
+			break;
+		default:
+			ret_val = -ENOENT;
+		}
+		break;
+#endif /* IPv6 */
+	default:
+		ret_val = -EPROTONOSUPPORT;
+	}
+
+sctp_setattr_return:
+	rcu_read_unlock();
+	return ret_val;
+}
+
+/**
  * netlbl_req_setattr - Label a request socket using the correct protocol
  * @req: the request socket to label
  * @secattr: the security attributes
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 22dc1b9..c070dfc 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1472,6 +1472,16 @@ int netlbl_unlabel_getattr(const struct sk_buff *skb,
 		iface = rcu_dereference(netlbl_unlhsh_def);
 	if (iface == NULL || !iface->valid)
 		goto unlabel_getattr_nolabel;
+
+#if IS_ENABLED(CONFIG_IPV6)
+	/* When resolving a fallback label, check the sk_buff version as
+	 * it is possible (e.g. SCTP) to have family = PF_INET6 while
+	 * receiving ip_hdr(skb)->version = 4.
+	 */
+	if (family == PF_INET6 && ip_hdr(skb)->version == 4)
+		family = PF_INET;
+#endif /* IPv6 */
+
 	switch (family) {
 	case PF_INET: {
 		struct iphdr *hdr4;
-- 
2.13.6

