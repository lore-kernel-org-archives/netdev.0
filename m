From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [RFC PATCH 07/17] netlabel: Add support for removing a CALIPSO DOI.
Date: Tue, 22 Dec 2015 11:46:43 +0000
Message-ID: <1450784813-18304-8-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Return-path: <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Post: <mailto:selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Help: <mailto:selinux-request-+05T5uksL2qpZYMLLGbcSA@public.gmane.org?subject=help>
Errors-To: selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
Sender: "Selinux" <selinux-bounces-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: netdev.vger.kernel.org

Remove a specified DOI through the NLBL_CALIPSO_C_REMOVE command.
It requires the attribute:
 NLBL_CALIPSO_A_DOI.

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
---
 include/net/netlabel.h          |  1 +
 net/ipv6/calipso.c              | 48 +++++++++++++++++++++
 net/netlabel/netlabel_calipso.c | 92 +++++++++++++++++++++++++++++++++++++++++
 net/netlabel/netlabel_calipso.h |  1 +
 4 files changed, 142 insertions(+)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index c6e1ce9..0ffe32f 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -237,6 +237,7 @@ struct netlbl_calipso_ops {
 	int (*doi_add)(struct calipso_doi *doi_def,
 		       struct netlbl_audit *audit_info);
 	void (*doi_free)(struct calipso_doi *doi_def);
+	int (*doi_remove)(u32 doi, struct netlbl_audit *audit_info);
 	struct calipso_doi *(*doi_getdef)(u32 doi);
 	void (*doi_putdef)(struct calipso_doi *doi_def);
 	int (*doi_walk)(u32 *skip_cnt,
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index fa17c7a..d7df7a4 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -163,6 +163,53 @@ static void calipso_doi_free_rcu(struct rcu_head *entry)
 }
 
 /**
+ * calipso_doi_remove - Remove an existing DOI from the CALIPSO protocol engine
+ * @doi: the DOI value
+ * @audit_secid: the LSM secid to use in the audit message
+ *
+ * Description:
+ * Removes a DOI definition from the CALIPSO engine.  The NetLabel routines will
+ * be called to release their own LSM domain mappings as well as our own
+ * domain list.  Returns zero on success and negative values on failure.
+ *
+ */
+static int calipso_doi_remove(u32 doi, struct netlbl_audit *audit_info)
+{
+	int ret_val;
+	struct calipso_doi *doi_def;
+	struct audit_buffer *audit_buf;
+
+	spin_lock(&calipso_doi_list_lock);
+	doi_def = calipso_doi_search(doi);
+	if (!doi_def) {
+		spin_unlock(&calipso_doi_list_lock);
+		ret_val = -ENOENT;
+		goto doi_remove_return;
+	}
+	if (!atomic_dec_and_test(&doi_def->refcount)) {
+		spin_unlock(&calipso_doi_list_lock);
+		ret_val = -EBUSY;
+		goto doi_remove_return;
+	}
+	list_del_rcu(&doi_def->list);
+	spin_unlock(&calipso_doi_list_lock);
+
+	call_rcu(&doi_def->rcu, calipso_doi_free_rcu);
+	ret_val = 0;
+
+doi_remove_return:
+	audit_buf = netlbl_audit_start(AUDIT_MAC_CALIPSO_DEL, audit_info);
+	if (audit_buf) {
+		audit_log_format(audit_buf,
+				 " calipso_doi=%u res=%u",
+				 doi, ret_val == 0 ? 1 : 0);
+		audit_log_end(audit_buf);
+	}
+
+	return ret_val;
+}
+
+/**
  * calipso_doi_getdef - Returns a reference to a valid DOI definition
  * @doi: the DOI value
  *
@@ -253,6 +300,7 @@ doi_walk_return:
 static const struct netlbl_calipso_ops ops = {
 	.doi_add          = calipso_doi_add,
 	.doi_free         = calipso_doi_free,
+	.doi_remove       = calipso_doi_remove,
 	.doi_getdef       = calipso_doi_getdef,
 	.doi_putdef       = calipso_doi_putdef,
 	.doi_walk         = calipso_doi_walk,
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index a014ec2..2083b15 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -53,6 +53,12 @@ struct netlbl_calipso_doiwalk_arg {
 	u32 seq;
 };
 
+/* Argument struct for netlbl_domhsh_walk() */
+struct netlbl_domhsh_walk_arg {
+	struct netlbl_audit *audit_info;
+	u32 doi;
+};
+
 /* NetLabel Generic NETLINK CALIPSO family */
 static struct genl_family netlbl_calipso_gnl_family = {
 	.id = GENL_ID_GENERATE,
@@ -261,6 +267,64 @@ static int netlbl_calipso_listall(struct sk_buff *skb,
 	return skb->len;
 }
 
+/**
+ * netlbl_calipso_remove_cb - netlbl_calipso_remove() callback for REMOVE
+ * @entry: LSM domain mapping entry
+ * @arg: the netlbl_domhsh_walk_arg structure
+ *
+ * Description:
+ * This function is intended for use by netlbl_calipso_remove() as the callback
+ * for the netlbl_domhsh_walk() function; it removes LSM domain map entries
+ * which are associated with the CALIPSO DOI specified in @arg.  Returns zero on
+ * success, negative values on failure.
+ *
+ */
+static int netlbl_calipso_remove_cb(struct netlbl_dom_map *entry, void *arg)
+{
+	struct netlbl_domhsh_walk_arg *cb_arg = arg;
+
+	if (entry->def.type == NETLBL_NLTYPE_CALIPSO &&
+	    entry->def.calipso->doi == cb_arg->doi)
+		return netlbl_domhsh_remove_entry(entry, cb_arg->audit_info);
+
+	return 0;
+}
+
+/**
+ * netlbl_calipso_remove - Handle a REMOVE message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated REMOVE message and respond accordingly.  Returns
+ * zero on success, negative values on failure.
+ *
+ */
+static int netlbl_calipso_remove(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val = -EINVAL;
+	struct netlbl_domhsh_walk_arg cb_arg;
+	struct netlbl_audit audit_info;
+	u32 skip_bkt = 0;
+	u32 skip_chain = 0;
+
+	if (!info->attrs[NLBL_CALIPSO_A_DOI])
+		return -EINVAL;
+
+	netlbl_netlink_auditinfo(skb, &audit_info);
+	cb_arg.doi = nla_get_u32(info->attrs[NLBL_CALIPSO_A_DOI]);
+	cb_arg.audit_info = &audit_info;
+	ret_val = netlbl_domhsh_walk(&skip_bkt, &skip_chain,
+				     netlbl_calipso_remove_cb, &cb_arg);
+	if (ret_val == 0 || ret_val == -ENOENT) {
+		ret_val = calipso_doi_remove(cb_arg.doi, &audit_info);
+		if (ret_val == 0)
+			atomic_dec(&netlabel_mgmt_protocount);
+	}
+
+	return ret_val;
+}
+
 /* NetLabel Generic NETLINK Command Definitions
  */
 
@@ -273,6 +337,13 @@ static const struct genl_ops netlbl_calipso_ops[] = {
 	.dumpit = NULL,
 	},
 	{
+	.cmd = NLBL_CALIPSO_C_REMOVE,
+	.flags = GENL_ADMIN_PERM,
+	.policy = calipso_genl_policy,
+	.doit = netlbl_calipso_remove,
+	.dumpit = NULL,
+	},
+	{
 	.cmd = NLBL_CALIPSO_C_LIST,
 	.flags = 0,
 	.policy = calipso_genl_policy,
@@ -366,6 +437,27 @@ void calipso_doi_free(struct calipso_doi *doi_def)
 }
 
 /**
+ * calipso_doi_remove - Remove an existing DOI from the CALIPSO protocol engine
+ * @doi: the DOI value
+ * @audit_secid: the LSM secid to use in the audit message
+ *
+ * Description:
+ * Removes a DOI definition from the CALIPSO engine.  The NetLabel routines will
+ * be called to release their own LSM domain mappings as well as our own
+ * domain list.  Returns zero on success and negative values on failure.
+ *
+ */
+int calipso_doi_remove(u32 doi, struct netlbl_audit *audit_info)
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->doi_remove(doi, audit_info);
+	return ret_val;
+}
+
+/**
  * calipso_doi_getdef - Returns a reference to a valid DOI definition
  * @doi: the DOI value
  *
diff --git a/net/netlabel/netlabel_calipso.h b/net/netlabel/netlabel_calipso.h
index 5d86752..b864480 100644
--- a/net/netlabel/netlabel_calipso.h
+++ b/net/netlabel/netlabel_calipso.h
@@ -124,6 +124,7 @@ static inline int netlbl_calipso_genl_init(void)
 int calipso_doi_add(struct calipso_doi *doi_def,
 		    struct netlbl_audit *audit_info);
 void calipso_doi_free(struct calipso_doi *doi_def);
+int calipso_doi_remove(u32 doi, struct netlbl_audit *audit_info);
 struct calipso_doi *calipso_doi_getdef(u32 doi);
 void calipso_doi_putdef(struct calipso_doi *doi_def);
 int calipso_doi_walk(u32 *skip_cnt,
-- 
1.8.0

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
