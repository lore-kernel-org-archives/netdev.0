From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH 2/3] net: wrap skb->secmark access with set and get
 functions
Date: Tue, 16 Apr 2013 16:39:18 -0400
Message-ID: <20130416203918.10474.15532.stgit@localhost>
References: <20130416202437.10474.45713.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130416202437.10474.45713.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Abstract away direct access to the "secmark" field in the sk_buff
struct via the LSM hooks security_skb_secmark_{get,set}().

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/linux/security.h       |   20 +++++++++++++++++++-
 net/netfilter/xt_CONNSECMARK.c |   10 ++++++----
 net/netfilter/xt_SECMARK.c     |    2 +-
 security/capability.c          |   10 ++++++++++
 security/security.c            |   11 +++++++++++
 security/selinux/hooks.c       |   22 +++++++++++++++++-----
 6 files changed, 64 insertions(+), 11 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 032c366..464f123 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -1016,6 +1016,13 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	This hook sets the packet's owning sock.
  *	@skb is the packet.
  *	@sk the sock which owns the packet.
+ * @skb_secmark_set:
+ *	This hook sets the secmark on a packet.
+ *	@skb the packet.
+ *	@secmark the secmark value.
+ * @skb_secmark_get:
+ *	This hook returns the packet's secmark.
+ *	@skb the packet.
  *
  * Security hooks for XFRM operations.
  *
@@ -1643,6 +1650,8 @@ struct security_operations {
 	int (*tun_dev_attach) (struct sock *sk, void *security);
 	int (*tun_dev_open) (void *security);
 	void (*skb_owned_by) (struct sk_buff *skb, struct sock *sk);
+	void (*skb_secmark_set) (struct sk_buff *skb, u32 secmark);
+	u32 (*skb_secmark_get) (const struct sk_buff *skb);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -2592,8 +2601,9 @@ int security_tun_dev_create(void);
 int security_tun_dev_attach_queue(void *security);
 int security_tun_dev_attach(struct sock *sk, void *security);
 int security_tun_dev_open(void *security);
-
 void security_skb_owned_by(struct sk_buff *skb, struct sock *sk);
+void security_skb_secmark_set(struct sk_buff *skb, u32 secmark);
+u32 security_skb_secmark_get(const struct sk_buff *skb);
 
 #else	/* CONFIG_SECURITY_NETWORK */
 static inline int security_unix_stream_connect(struct sock *sock,
@@ -2791,6 +2801,14 @@ static inline void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 {
 }
 
+static inline void security_skb_secmark_set(struct sk_buff *skb, u32 secmark)
+{
+}
+
+static inline u32 security_skb_secmark_get(const struct sk_buff *skb)
+{
+	return 0;
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index e04dc28..2201c1b 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -35,13 +35,15 @@ MODULE_ALIAS("ip6t_CONNSECMARK");
  */
 static void secmark_save(const struct sk_buff *skb)
 {
-	if (skb->secmark) {
+	u32 secmark = security_skb_secmark_get(skb);
+
+	if (secmark) {
 		struct nf_conn *ct;
 		enum ip_conntrack_info ctinfo;
 
 		ct = nf_ct_get(skb, &ctinfo);
 		if (ct && !ct->secmark) {
-			ct->secmark = skb->secmark;
+			ct->secmark = secmark;
 			nf_conntrack_event_cache(IPCT_SECMARK, ct);
 		}
 	}
@@ -53,13 +55,13 @@ static void secmark_save(const struct sk_buff *skb)
  */
 static void secmark_restore(struct sk_buff *skb)
 {
-	if (!skb->secmark) {
+	if (!security_skb_secmark_get(skb)) {
 		const struct nf_conn *ct;
 		enum ip_conntrack_info ctinfo;
 
 		ct = nf_ct_get(skb, &ctinfo);
 		if (ct && ct->secmark)
-			skb->secmark = ct->secmark;
+			security_skb_secmark_set(skb, ct->secmark);
 	}
 }
 
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index 9faf5e0..ed20d8e 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -45,7 +45,7 @@ secmark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		BUG();
 	}
 
-	skb->secmark = secmark;
+	security_skb_secmark_set(skb, secmark);
 	return XT_CONTINUE;
 }
 
diff --git a/security/capability.c b/security/capability.c
index 6783c3e..b7c0ef2 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -742,6 +742,14 @@ static void cap_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 {
 }
 
+static void cap_skb_secmark_set(struct sk_buff *skb, u32 secmark)
+{
+}
+
+static u32 cap_skb_secmark_get(const struct sk_buff *skb)
+{
+	return 0;
+}
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
@@ -1077,6 +1085,8 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, tun_dev_attach_queue);
 	set_to_cap_if_null(ops, tun_dev_attach);
 	set_to_cap_if_null(ops, skb_owned_by);
+	set_to_cap_if_null(ops, skb_secmark_set);
+	set_to_cap_if_null(ops, skb_secmark_get);
 #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	set_to_cap_if_null(ops, xfrm_policy_alloc_security);
diff --git a/security/security.c b/security/security.c
index 03f248b..7e2b7c7 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1295,6 +1295,17 @@ void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 	security_ops->skb_owned_by(skb, sk);
 }
 
+void security_skb_secmark_set(struct sk_buff *skb, u32 secmark)
+{
+	security_ops->skb_secmark_set(skb, secmark);
+}
+EXPORT_SYMBOL(security_skb_secmark_set);
+
+u32 security_skb_secmark_get(const struct sk_buff *skb)
+{
+	return security_ops->skb_secmark_get(skb);
+}
+EXPORT_SYMBOL(security_skb_secmark_get);
 #endif	/* CONFIG_SECURITY_NETWORK */
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 7171a95..5021cf7 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3473,6 +3473,21 @@ static void selinux_task_to_inode(struct task_struct *p,
 	isec->initialized = 1;
 }
 
+static void selinux_skb_owned_by(struct sk_buff *skb, struct sock *sk)
+{
+	skb_set_owner_w(skb, sk);
+}
+
+static void selinux_skb_secmark_set(struct sk_buff *skb, u32 secmark)
+{
+	skb->secmark = secmark;
+}
+
+static u32 selinux_skb_secmark_get(const struct sk_buff *skb)
+{
+	return skb->secmark;
+}
+
 /* Returns error only if unable to parse addresses */
 static int selinux_parse_skb_ipv4(struct sk_buff *skb,
 			struct common_audit_data *ad, u8 *proto)
@@ -4364,11 +4379,6 @@ static void selinux_inet_conn_established(struct sock *sk, struct sk_buff *skb)
 	selinux_skb_peerlbl_sid(skb, family, &sksec->peer_sid);
 }
 
-static void selinux_skb_owned_by(struct sk_buff *skb, struct sock *sk)
-{
-	skb_set_owner_w(skb, sk);
-}
-
 static int selinux_secmark_relabel_packet(u32 sid)
 {
 	const struct task_security_struct *__tsec;
@@ -5671,6 +5681,8 @@ static struct security_operations selinux_ops = {
 	.tun_dev_attach =		selinux_tun_dev_attach,
 	.tun_dev_open =			selinux_tun_dev_open,
 	.skb_owned_by =			selinux_skb_owned_by,
+	.skb_secmark_set =		selinux_skb_secmark_set,
+	.skb_secmark_get =		selinux_skb_secmark_get,
 
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
 	.xfrm_policy_alloc_security =	selinux_xfrm_policy_alloc,

