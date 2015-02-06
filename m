From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] cipso: don't use IPCB() to locate the CIPSO IP option
Date: Fri, 06 Feb 2015 14:57:28 -0500
Message-ID: <20150206195728.28733.12118.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: casey@schaufler-ca.com, netdev@vger.kernel.org
To: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754101AbbBFT5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2015 14:57:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the IPCB() macro to get the IPv4 options is convenient, but
unfortunately NetLabel often needs to examine the CIPSO option outside
of the scope of the IP layer in the stack.  While historically IPCB()
worked above the IP layer, due to the inclusion of the inet_skb_param
struct at the head of the {tcp,udp}_skb_cb structs, recent commit
971f10ec ("tcp: better TCP_SKB_CB layout to reduce cache line misses")
reordered the tcp_skb_cb struct and invalidated this IPCB() trick.

This patch fixes the problem by creating a new function,
cipso_v4_optptr(), which locates the CIPSO option inside the IP header
without calling IPCB().  Unfortunately, this isn't as fast as a simple
lookup so some additional tweaks were made to limit the use of this
new function.

Cc: <stable@vger.kernel.org> # 3.18
Reported-by: Casey Schaufler <casey@schaufler-ca.com>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/net/cipso_ipv4.h     |   25 +++++++++++++--------
 net/ipv4/cipso_ipv4.c        |   51 +++++++++++++++++++++++++-----------------
 net/netlabel/netlabel_kapi.c |   15 ++++++++----
 3 files changed, 56 insertions(+), 35 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index a6fd939..3ebb168 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -121,13 +121,6 @@ extern int cipso_v4_rbm_strictvalid;
 #endif
 
 /*
- * Helper Functions
- */
-
-#define CIPSO_V4_OPTEXIST(x) (IPCB(x)->opt.cipso != 0)
-#define CIPSO_V4_OPTPTR(x) (skb_network_header(x) + IPCB(x)->opt.cipso)
-
-/*
  * DOI List Functions
  */
 
@@ -190,7 +183,7 @@ static inline int cipso_v4_doi_domhsh_remove(struct cipso_v4_doi *doi_def,
 
 #ifdef CONFIG_NETLABEL
 void cipso_v4_cache_invalidate(void);
-int cipso_v4_cache_add(const struct sk_buff *skb,
+int cipso_v4_cache_add(const unsigned char *cipso_ptr,
 		       const struct netlbl_lsm_secattr *secattr);
 #else
 static inline void cipso_v4_cache_invalidate(void)
@@ -198,7 +191,7 @@ static inline void cipso_v4_cache_invalidate(void)
 	return;
 }
 
-static inline int cipso_v4_cache_add(const struct sk_buff *skb,
+static inline int cipso_v4_cache_add(const unsigned char *cipso_ptr,
 				     const struct netlbl_lsm_secattr *secattr)
 {
 	return 0;
@@ -211,6 +204,8 @@ static inline int cipso_v4_cache_add(const struct sk_buff *skb,
 
 #ifdef CONFIG_NETLABEL
 void cipso_v4_error(struct sk_buff *skb, int error, u32 gateway);
+int cipso_v4_getattr(const unsigned char *cipso,
+		     struct netlbl_lsm_secattr *secattr);
 int cipso_v4_sock_setattr(struct sock *sk,
 			  const struct cipso_v4_doi *doi_def,
 			  const struct netlbl_lsm_secattr *secattr);
@@ -226,6 +221,7 @@ int cipso_v4_skbuff_setattr(struct sk_buff *skb,
 int cipso_v4_skbuff_delattr(struct sk_buff *skb);
 int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 			    struct netlbl_lsm_secattr *secattr);
+unsigned char *cipso_v4_optptr(const struct sk_buff *skb);
 int cipso_v4_validate(const struct sk_buff *skb, unsigned char **option);
 #else
 static inline void cipso_v4_error(struct sk_buff *skb,
@@ -235,6 +231,12 @@ static inline void cipso_v4_error(struct sk_buff *skb,
 	return;
 }
 
+static inline int cipso_v4_getattr(const unsigned char *cipso,
+				   struct netlbl_lsm_secattr *secattr)
+{
+	return -ENOSYS;
+}
+
 static inline int cipso_v4_sock_setattr(struct sock *sk,
 				      const struct cipso_v4_doi *doi_def,
 				      const struct netlbl_lsm_secattr *secattr)
@@ -282,6 +284,11 @@ static inline int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 	return -ENOSYS;
 }
 
+static inline unsigned char *cipso_v4_optptr(const struct sk_buff *skb)
+{
+	return NULL;
+}
+
 static inline int cipso_v4_validate(const struct sk_buff *skb,
 				    unsigned char **option)
 {
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 5160c71..e361ea6 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -378,20 +378,18 @@ static int cipso_v4_cache_check(const unsigned char *key,
  * negative values on failure.
  *
  */
-int cipso_v4_cache_add(const struct sk_buff *skb,
+int cipso_v4_cache_add(const unsigned char *cipso_ptr,
 		       const struct netlbl_lsm_secattr *secattr)
 {
 	int ret_val = -EPERM;
 	u32 bkt;
 	struct cipso_v4_map_cache_entry *entry = NULL;
 	struct cipso_v4_map_cache_entry *old_entry = NULL;
-	unsigned char *cipso_ptr;
 	u32 cipso_ptr_len;
 
 	if (!cipso_v4_cache_enabled || cipso_v4_cache_bucketsize <= 0)
 		return 0;
 
-	cipso_ptr = CIPSO_V4_OPTPTR(skb);
 	cipso_ptr_len = cipso_ptr[1];
 
 	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
@@ -1579,6 +1577,33 @@ static int cipso_v4_parsetag_loc(const struct cipso_v4_doi *doi_def,
 }
 
 /**
+ * cipso_v4_optptr - Find the CIPSO option in the packet
+ * @skb: the packet
+ *
+ * Description:
+ * Parse the packet's IP header looking for a CIPSO option.  Returns a pointer
+ * to the start of the CIPSO option on success, NULL if one if not found.
+ *
+ */
+unsigned char *cipso_v4_optptr(const struct sk_buff *skb)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	unsigned char *optptr = (unsigned char *)&(ip_hdr(skb)[1]);
+	int optlen;
+	int taglen;
+
+	for (optlen = iph->ihl*4 - sizeof(struct iphdr); optlen > 0; ) {
+		if (optptr[0] == IPOPT_CIPSO)
+			return optptr;
+		taglen = optptr[1];
+		optlen -= taglen;
+		optptr += taglen;
+	}
+
+	return NULL;
+}
+
+/**
  * cipso_v4_validate - Validate a CIPSO option
  * @option: the start of the option, on error it is set to point to the error
  *
@@ -2119,8 +2144,8 @@ void cipso_v4_req_delattr(struct request_sock *req)
  * on success and negative values on failure.
  *
  */
-static int cipso_v4_getattr(const unsigned char *cipso,
-			    struct netlbl_lsm_secattr *secattr)
+int cipso_v4_getattr(const unsigned char *cipso,
+		     struct netlbl_lsm_secattr *secattr)
 {
 	int ret_val = -ENOMSG;
 	u32 doi;
@@ -2305,22 +2330,6 @@ int cipso_v4_skbuff_delattr(struct sk_buff *skb)
 	return 0;
 }
 
-/**
- * cipso_v4_skbuff_getattr - Get the security attributes from the CIPSO option
- * @skb: the packet
- * @secattr: the security attributes
- *
- * Description:
- * Parse the given packet's CIPSO option and return the security attributes.
- * Returns zero on success and negative values on failure.
- *
- */
-int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
-			    struct netlbl_lsm_secattr *secattr)
-{
-	return cipso_v4_getattr(CIPSO_V4_OPTPTR(skb), secattr);
-}
-
 /*
  * Setup Functions
  */
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index a845cd4..28cddc8 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -1065,10 +1065,12 @@ int netlbl_skbuff_getattr(const struct sk_buff *skb,
 			  u16 family,
 			  struct netlbl_lsm_secattr *secattr)
 {
+	unsigned char *ptr;
+
 	switch (family) {
 	case AF_INET:
-		if (CIPSO_V4_OPTEXIST(skb) &&
-		    cipso_v4_skbuff_getattr(skb, secattr) == 0)
+		ptr = cipso_v4_optptr(skb);
+		if (ptr && cipso_v4_getattr(ptr, secattr) == 0)
 			return 0;
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1094,7 +1096,7 @@ int netlbl_skbuff_getattr(const struct sk_buff *skb,
  */
 void netlbl_skbuff_err(struct sk_buff *skb, int error, int gateway)
 {
-	if (CIPSO_V4_OPTEXIST(skb))
+	if (cipso_v4_optptr(skb))
 		cipso_v4_error(skb, error, gateway);
 }
 
@@ -1126,11 +1128,14 @@ void netlbl_cache_invalidate(void)
 int netlbl_cache_add(const struct sk_buff *skb,
 		     const struct netlbl_lsm_secattr *secattr)
 {
+	unsigned char *ptr;
+
 	if ((secattr->flags & NETLBL_SECATTR_CACHE) == 0)
 		return -ENOMSG;
 
-	if (CIPSO_V4_OPTEXIST(skb))
-		return cipso_v4_cache_add(skb, secattr);
+	ptr = cipso_v4_optptr(skb);
+	if (ptr)
+		return cipso_v4_cache_add(ptr, secattr);
 
 	return -ENOMSG;
 }
