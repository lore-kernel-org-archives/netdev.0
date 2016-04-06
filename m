From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 1/2] security: add hook for netlabel status change notification
Date: Wed,  6 Apr 2016 11:51:34 +0200
Message-ID: <d10dce15546a6d15ad64cfdbf48fb44dc88eea82.1459934322.git.pabeni@redhat.com>
References: <cover.1459934322.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <cover.1459934322.git.pabeni@redhat.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new LSM hook called every time the netlbl usage
count is changed. This allows an LSM to register a set of hooks
on demand according to the netlabel status.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/lsm_hooks.h         | 6 ++++++
 include/linux/security.h          | 5 +++++
 net/netlabel/netlabel_cipso_v4.c  | 8 ++++++--
 net/netlabel/netlabel_unlabeled.c | 5 ++++-
 security/security.c               | 7 +++++++
 5 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index cdee11c..9a6b90f 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -875,6 +875,10 @@
  *	This hook can be used by the module to update any security state
  *	associated with the TUN device's security structure.
  *	@security pointer to the TUN devices's security structure.
+ * @netlbl_changed:
+ *	This hook can be used by the module to update any security state
+ *	associated with the netlbl_enable() status (i.e. registering/
+ *	deregistering additional hooks on demands)
  *
  * Security hooks for XFRM operations.
  *
@@ -1576,6 +1580,7 @@ union security_list_options {
 	int (*tun_dev_attach_queue)(void *security);
 	int (*tun_dev_attach)(struct sock *sk, void *security);
 	int (*tun_dev_open)(void *security);
+	void (*netlbl_changed)(void);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1805,6 +1810,7 @@ struct security_hook_heads {
 	struct list_head tun_dev_attach;
 	struct list_head tun_dev_open;
 	struct list_head skb_owned_by;
+	struct list_head netlbl_changed;
 #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	struct list_head xfrm_policy_alloc_security;
diff --git a/include/linux/security.h b/include/linux/security.h
index 157f0cb..8bff4e5 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1162,6 +1162,7 @@ int security_tun_dev_create(void);
 int security_tun_dev_attach_queue(void *security);
 int security_tun_dev_attach(struct sock *sk, void *security);
 int security_tun_dev_open(void *security);
+void security_netlbl_changed(void);
 
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct sock *sock,
@@ -1354,6 +1355,10 @@ static inline int security_tun_dev_open(void *security)
 {
 	return 0;
 }
+
+static inline void security_netlbl_changed(void)
+{
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index 7fd1104..1b508ea 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -438,8 +438,10 @@ static int netlbl_cipsov4_add(struct sk_buff *skb, struct genl_info *info)
 		ret_val = netlbl_cipsov4_add_local(info, &audit_info);
 		break;
 	}
-	if (ret_val == 0)
+	if (ret_val == 0) {
 		atomic_inc(&netlabel_mgmt_protocount);
+		security_netlbl_changed();
+	}
 
 	return ret_val;
 }
@@ -725,8 +727,10 @@ static int netlbl_cipsov4_remove(struct sk_buff *skb, struct genl_info *info)
 				     netlbl_cipsov4_remove_cb, &cb_arg);
 	if (ret_val == 0 || ret_val == -ENOENT) {
 		ret_val = cipso_v4_doi_remove(cb_arg.doi, &audit_info);
-		if (ret_val == 0)
+		if (ret_val == 0) {
 			atomic_dec(&netlabel_mgmt_protocount);
+			security_netlbl_changed();
+		}
 	}
 
 	return ret_val;
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 9eaa9a1..7795700 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -451,8 +451,10 @@ int netlbl_unlhsh_add(struct net *net,
 	default:
 		ret_val = -EINVAL;
 	}
-	if (ret_val == 0)
+	if (ret_val == 0) {
 		atomic_inc(&netlabel_mgmt_protocount);
+		security_netlbl_changed();
+	}
 
 unlhsh_add_return:
 	rcu_read_unlock();
@@ -692,6 +694,7 @@ int netlbl_unlhsh_remove(struct net *net,
 	if (ret_val == 0) {
 		netlbl_unlhsh_condremove_iface(iface);
 		atomic_dec(&netlabel_mgmt_protocount);
+		security_netlbl_changed();
 	}
 
 unlhsh_remove_return:
diff --git a/security/security.c b/security/security.c
index 3644b03..e4d6262 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1396,6 +1396,12 @@ int security_tun_dev_open(void *security)
 }
 EXPORT_SYMBOL(security_tun_dev_open);
 
+void security_netlbl_changed(void)
+{
+	call_void_hook(netlbl_changed);
+}
+EXPORT_SYMBOL(security_netlbl_changed);
+
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1849,6 +1855,7 @@ struct security_hook_heads security_hook_heads = {
 		LIST_HEAD_INIT(security_hook_heads.tun_dev_attach),
 	.tun_dev_open =	LIST_HEAD_INIT(security_hook_heads.tun_dev_open),
 	.skb_owned_by =	LIST_HEAD_INIT(security_hook_heads.skb_owned_by),
+	.netlbl_changed = LIST_HEAD_INIT(security_hook_heads.netlbl_changed),
 #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =
-- 
1.8.3.1

