From: Paul Moore <paul.moore@hp.com>
Subject: [RFC PATCH v2 1/2] NetLabel: Allow passing the LSM domain as a shared
	pointer
Date: Wed, 09 Apr 2008 16:50:39 -0400
Message-ID: <20080409205039.26774.50884.stgit@flek.lan>
References: <20080409204936.26774.55254.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080409204936.26774.55254.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Smack doesn't have the need to create a private copy of the LSM "domain" when
setting NetLabel security attributes like SELinux, however, the current
NetLabel code requires a private copy of the LSM "domain".  This patches fixes
that by letting the LSM determine how it wants to pass the domain value.

 * NETLBL_SECATTR_DOMAIN_CPY
   The current behavior, NetLabel assumes that the domain value is a copy and
   frees it when done

 * NETLBL_SECATTR_DOMAIN
   New, Smack-friendly behavior, NetLabel assumes that the domain value is a
   reference to a string managed by the LSM and does not free it when done

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/net/netlabel.h         |   14 ++++++++++----
 security/selinux/ss/services.c |    2 +-
 security/smack/smack_lsm.c     |    2 +-
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 0ca67d7..5e53a85 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -162,7 +162,7 @@ struct netlbl_lsm_secattr_catmap {
 
 /**
  * struct netlbl_lsm_secattr - NetLabel LSM security attributes
- * @flags: indicate which attributes are contained in this structure
+ * @flags: indicate structure attributes, see NETLBL_SECATTR_*
  * @type: indicate the NLTYPE of the attributes
  * @domain: the NetLabel LSM domain
  * @cache: NetLabel LSM specific cache
@@ -180,17 +180,22 @@ struct netlbl_lsm_secattr_catmap {
  * NetLabel itself when returning security attributes to the LSM.
  *
  */
+struct netlbl_lsm_secattr {
+	u32 flags;
+	/* bitmap values for 'flags' */
 #define NETLBL_SECATTR_NONE             0x00000000
 #define NETLBL_SECATTR_DOMAIN           0x00000001
+#define NETLBL_SECATTR_DOMAIN_CPY       (NETLBL_SECATTR_DOMAIN | \
+					 NETLBL_SECATTR_FREE_DOMAIN)
 #define NETLBL_SECATTR_CACHE            0x00000002
 #define NETLBL_SECATTR_MLS_LVL          0x00000004
 #define NETLBL_SECATTR_MLS_CAT          0x00000008
 #define NETLBL_SECATTR_SECID            0x00000010
+	/* bitmap meta-values for 'flags' */
+#define NETLBL_SECATTR_FREE_DOMAIN      0x01000000
 #define NETLBL_SECATTR_CACHEABLE        (NETLBL_SECATTR_MLS_LVL | \
 					 NETLBL_SECATTR_MLS_CAT | \
 					 NETLBL_SECATTR_SECID)
-struct netlbl_lsm_secattr {
-	u32 flags;
 	u32 type;
 	char *domain;
 	struct netlbl_lsm_cache *cache;
@@ -303,7 +308,8 @@ static inline void netlbl_secattr_init(struct netlbl_lsm_secattr *secattr)
  */
 static inline void netlbl_secattr_destroy(struct netlbl_lsm_secattr *secattr)
 {
-	kfree(secattr->domain);
+	if (secattr->flags & NETLBL_SECATTR_FREE_DOMAIN)
+		kfree(secattr->domain);
 	if (secattr->flags & NETLBL_SECATTR_CACHE)
 		netlbl_secattr_cache_free(secattr->cache);
 	if (secattr->flags & NETLBL_SECATTR_MLS_CAT)
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 3f2bad2..5fd54f2 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -2651,7 +2651,7 @@ int security_netlbl_sid_to_secattr(u32 sid, struct netlbl_lsm_secattr *secattr)
 		goto netlbl_sid_to_secattr_failure;
 	secattr->domain = kstrdup(policydb.p_type_val_to_name[ctx->type - 1],
 				  GFP_ATOMIC);
-	secattr->flags |= NETLBL_SECATTR_DOMAIN;
+	secattr->flags |= NETLBL_SECATTR_DOMAIN_CPY;
 	mls_export_netlbl_lvl(ctx, secattr);
 	rc = mls_export_netlbl_cat(ctx, secattr);
 	if (rc != 0)
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 732ba27..e2d6f7c 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1275,7 +1275,7 @@ static void smack_to_secattr(char *smack, struct netlbl_lsm_secattr *nlsp)
 
 	switch (smack_net_nltype) {
 	case NETLBL_NLTYPE_CIPSOV4:
-		nlsp->domain = kstrdup(smack, GFP_ATOMIC);
+		nlsp->domain = smack;
 		nlsp->flags = NETLBL_SECATTR_DOMAIN | NETLBL_SECATTR_MLS_LVL;
 
 		rc = smack_to_cipso(smack, &cipso);

