From: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
Subject: [RFC PATCH 04/17] netlabel: Add support for querying a CALIPSO DOI.
Date: Tue, 22 Dec 2015 11:46:40 +0000
Message-ID: <1450784813-18304-5-git-send-email-huw@codeweavers.com>
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

Query a specified DOI through the NLBL_CALIPSO_C_LIST command.
It requires the attribute:
 NLBL_CALIPSO_A_DOI.

The reply will contain:
 NLBL_CALIPSO_A_MTYPE

Signed-off-by: Huw Davies <huw-PJ7GQ4yptbsswetKESUqMA@public.gmane.org>
---
 include/net/netlabel.h          |   4 ++
 net/ipv6/calipso.c              |  68 +++++++++++++++++++++++++++
 net/netlabel/netlabel_calipso.c | 102 ++++++++++++++++++++++++++++++++++++++++
 net/netlabel/netlabel_calipso.h |   2 +
 4 files changed, 176 insertions(+)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index ced56b0..e072350 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -223,6 +223,8 @@ struct netlbl_lsm_secattr {
  * struct netlbl_calipso_ops - NetLabel CALIPSO operations
  * @doi_add: add a CALIPSO DOI
  * @doi_free: free a CALIPSO DOI
+ * @doi_getdef: returns a reference to a DOI
+ * @doi_putdef: releases a reference of a DOI
  *
  * Description:
  * This structure is filled out by the CALIPSO engine and passed
@@ -234,6 +236,8 @@ struct netlbl_calipso_ops {
 	int (*doi_add)(struct calipso_doi *doi_def,
 		       struct netlbl_audit *audit_info);
 	void (*doi_free)(struct calipso_doi *doi_def);
+	struct calipso_doi *(*doi_getdef)(u32 doi);
+	void (*doi_putdef)(struct calipso_doi *doi_def);
 };
 
 /*
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index aa44310..128cc69 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -144,9 +144,77 @@ static void calipso_doi_free(struct calipso_doi *doi_def)
 	kfree(doi_def);
 }
 
+/**
+ * calipso_doi_free_rcu - Frees a DOI definition via the RCU pointer
+ * @entry: the entry's RCU field
+ *
+ * Description:
+ * This function is designed to be used as a callback to the call_rcu()
+ * function so that the memory allocated to the DOI definition can be released
+ * safely.
+ *
+ */
+static void calipso_doi_free_rcu(struct rcu_head *entry)
+{
+	struct calipso_doi *doi_def;
+
+	doi_def = container_of(entry, struct calipso_doi, rcu);
+	calipso_doi_free(doi_def);
+}
+
+/**
+ * calipso_doi_getdef - Returns a reference to a valid DOI definition
+ * @doi: the DOI value
+ *
+ * Description:
+ * Searches for a valid DOI definition and if one is found it is returned to
+ * the caller.  Otherwise NULL is returned.  The caller must ensure that
+ * calipso_doi_putdef() is called when the caller is done.
+ *
+ */
+static struct calipso_doi *calipso_doi_getdef(u32 doi)
+{
+	struct calipso_doi *doi_def;
+
+	rcu_read_lock();
+	doi_def = calipso_doi_search(doi);
+	if (!doi_def)
+		goto doi_getdef_return;
+	if (!atomic_inc_not_zero(&doi_def->refcount))
+		doi_def = NULL;
+
+doi_getdef_return:
+	rcu_read_unlock();
+	return doi_def;
+}
+
+/**
+ * calipso_doi_putdef - Releases a reference for the given DOI definition
+ * @doi_def: the DOI definition
+ *
+ * Description:
+ * Releases a DOI definition reference obtained from calipso_doi_getdef().
+ *
+ */
+static void calipso_doi_putdef(struct calipso_doi *doi_def)
+{
+	if (!doi_def)
+		return;
+
+	if (!atomic_dec_and_test(&doi_def->refcount))
+		return;
+	spin_lock(&calipso_doi_list_lock);
+	list_del_rcu(&doi_def->list);
+	spin_unlock(&calipso_doi_list_lock);
+
+	call_rcu(&doi_def->rcu, calipso_doi_free_rcu);
+}
+
 static const struct netlbl_calipso_ops ops = {
 	.doi_add          = calipso_doi_add,
 	.doi_free         = calipso_doi_free,
+	.doi_getdef       = calipso_doi_getdef,
+	.doi_putdef       = calipso_doi_putdef,
 };
 
 /**
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index 013d1e2..1effc61 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -128,6 +128,65 @@ static int netlbl_calipso_add(struct sk_buff *skb, struct genl_info *info)
 	return ret_val;
 }
 
+/**
+ * netlbl_calipso_list - Handle a LIST message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated LIST message and respond accordingly.
+ * Returns zero on success and negative values on error.
+ *
+ */
+static int netlbl_calipso_list(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret_val;
+	struct sk_buff *ans_skb = NULL;
+	void *data;
+	u32 doi;
+	struct calipso_doi *doi_def;
+
+	if (!info->attrs[NLBL_CALIPSO_A_DOI]) {
+		ret_val = -EINVAL;
+		goto list_failure;
+	}
+
+	doi = nla_get_u32(info->attrs[NLBL_CALIPSO_A_DOI]);
+
+	doi_def = calipso_doi_getdef(doi);
+	if (!doi_def) {
+		ret_val = -EINVAL;
+		goto list_failure;
+	}
+
+	ans_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!ans_skb) {
+		ret_val = -ENOMEM;
+		goto list_failure_put;
+	}
+	data = genlmsg_put_reply(ans_skb, info, &netlbl_calipso_gnl_family,
+				 0, NLBL_CALIPSO_C_LIST);
+	if (!data) {
+		ret_val = -ENOMEM;
+		goto list_failure_put;
+	}
+
+	ret_val = nla_put_u32(ans_skb, NLBL_CALIPSO_A_MTYPE, doi_def->type);
+	if (ret_val != 0)
+		goto list_failure_put;
+
+	calipso_doi_putdef(doi_def);
+
+	genlmsg_end(ans_skb, data);
+	return genlmsg_reply(ans_skb, info);
+
+list_failure_put:
+	calipso_doi_putdef(doi_def);
+list_failure:
+	kfree_skb(ans_skb);
+	return ret_val;
+}
+
 /* NetLabel Generic NETLINK Command Definitions
  */
 
@@ -139,6 +198,13 @@ static const struct genl_ops netlbl_calipso_ops[] = {
 	.doit = netlbl_calipso_add,
 	.dumpit = NULL,
 	},
+	{
+	.cmd = NLBL_CALIPSO_C_LIST,
+	.flags = 0,
+	.policy = calipso_genl_policy,
+	.doit = netlbl_calipso_list,
+	.dumpit = NULL,
+	},
 };
 
 /* NetLabel Generic NETLINK Protocol Functions
@@ -217,3 +283,39 @@ void calipso_doi_free(struct calipso_doi *doi_def)
 	if (ops)
 		ops->doi_free(doi_def);
 }
+
+/**
+ * calipso_doi_getdef - Returns a reference to a valid DOI definition
+ * @doi: the DOI value
+ *
+ * Description:
+ * Searches for a valid DOI definition and if one is found it is returned to
+ * the caller.  Otherwise NULL is returned.  The caller must ensure that
+ * calipso_doi_putdef() is called when the caller is done.
+ *
+ */
+struct calipso_doi *calipso_doi_getdef(u32 doi)
+{
+	struct calipso_doi *ret_val = NULL;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->doi_getdef(doi);
+	return ret_val;
+}
+
+/**
+ * calipso_doi_putdef - Releases a reference for the given DOI definition
+ * @doi_def: the DOI definition
+ *
+ * Description:
+ * Releases a DOI definition reference obtained from calipso_doi_getdef().
+ *
+ */
+void calipso_doi_putdef(struct calipso_doi *doi_def)
+{
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ops->doi_putdef(doi_def);
+}
diff --git a/net/netlabel/netlabel_calipso.h b/net/netlabel/netlabel_calipso.h
index 01bfd37..6cf1cad 100644
--- a/net/netlabel/netlabel_calipso.h
+++ b/net/netlabel/netlabel_calipso.h
@@ -124,5 +124,7 @@ static inline int netlbl_calipso_genl_init(void)
 int calipso_doi_add(struct calipso_doi *doi_def,
 		    struct netlbl_audit *audit_info);
 void calipso_doi_free(struct calipso_doi *doi_def);
+struct calipso_doi *calipso_doi_getdef(u32 doi);
+void calipso_doi_putdef(struct calipso_doi *doi_def);
 
 #endif
-- 
1.8.0

_______________________________________________
Selinux mailing list
Selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
To unsubscribe, send email to Selinux-leave-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
To get help, send an email containing "help" to Selinux-request-+05T5uksL2pAGbPMOrvdOA@public.gmane.org
