From: Huw Davies <huw@codeweavers.com>
Subject: [PATCH v4 05/19] netlabel: Add support for enumerating the CALIPSO DOI list.
Date: Mon, 20 Jun 2016 14:36:45 +0100
Message-ID: <1466429819-12707-6-git-send-email-huw@codeweavers.com>
Cc: Paul Moore <pmoore@redhat.com>
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:49034 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212AbcFTNyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 09:54:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enumerate the DOI list through the NLBL_CALIPSO_C_LISTALL command.
It takes no attributes.

Signed-off-by: Huw Davies <huw@codeweavers.com>
---
 include/net/netlabel.h          |   4 ++
 net/ipv6/calipso.c              |  41 ++++++++++++++++
 net/netlabel/netlabel_calipso.c | 106 ++++++++++++++++++++++++++++++++++++++++
 net/netlabel/netlabel_calipso.h |  14 ++++++
 4 files changed, 165 insertions(+)

diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index 0f05b83..2653d3a 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -225,6 +225,7 @@ struct netlbl_lsm_secattr {
  * @doi_free: free a CALIPSO DOI
  * @doi_getdef: returns a reference to a DOI
  * @doi_putdef: releases a reference of a DOI
+ * @doi_walk: enumerate the DOI list
  *
  * Description:
  * This structure is filled out by the CALIPSO engine and passed
@@ -238,6 +239,9 @@ struct netlbl_calipso_ops {
 	void (*doi_free)(struct calipso_doi *doi_def);
 	struct calipso_doi *(*doi_getdef)(u32 doi);
 	void (*doi_putdef)(struct calipso_doi *doi_def);
+	int (*doi_walk)(u32 *skip_cnt,
+			int (*callback)(struct calipso_doi *doi_def, void *arg),
+			void *cb_arg);
 };
 
 /*
diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index 128cc69..fa17c7a 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -210,11 +210,52 @@ static void calipso_doi_putdef(struct calipso_doi *doi_def)
 	call_rcu(&doi_def->rcu, calipso_doi_free_rcu);
 }
 
+/**
+ * calipso_doi_walk - Iterate through the DOI definitions
+ * @skip_cnt: skip past this number of DOI definitions, updated
+ * @callback: callback for each DOI definition
+ * @cb_arg: argument for the callback function
+ *
+ * Description:
+ * Iterate over the DOI definition list, skipping the first @skip_cnt entries.
+ * For each entry call @callback, if @callback returns a negative value stop
+ * 'walking' through the list and return.  Updates the value in @skip_cnt upon
+ * return.  Returns zero on success, negative values on failure.
+ *
+ */
+static int calipso_doi_walk(u32 *skip_cnt,
+			    int (*callback)(struct calipso_doi *doi_def,
+					    void *arg),
+			    void *cb_arg)
+{
+	int ret_val = -ENOENT;
+	u32 doi_cnt = 0;
+	struct calipso_doi *iter_doi;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(iter_doi, &calipso_doi_list, list)
+		if (atomic_read(&iter_doi->refcount) > 0) {
+			if (doi_cnt++ < *skip_cnt)
+				continue;
+			ret_val = callback(iter_doi, cb_arg);
+			if (ret_val < 0) {
+				doi_cnt--;
+				goto doi_walk_return;
+			}
+		}
+
+doi_walk_return:
+	rcu_read_unlock();
+	*skip_cnt = doi_cnt;
+	return ret_val;
+}
+
 static const struct netlbl_calipso_ops ops = {
 	.doi_add          = calipso_doi_add,
 	.doi_free         = calipso_doi_free,
 	.doi_getdef       = calipso_doi_getdef,
 	.doi_putdef       = calipso_doi_putdef,
+	.doi_walk         = calipso_doi_walk,
 };
 
 /**
diff --git a/net/netlabel/netlabel_calipso.c b/net/netlabel/netlabel_calipso.c
index 6161170..2141145 100644
--- a/net/netlabel/netlabel_calipso.c
+++ b/net/netlabel/netlabel_calipso.c
@@ -46,6 +46,13 @@
 #include "netlabel_mgmt.h"
 #include "netlabel_domainhash.h"
 
+/* Argument struct for calipso_doi_walk() */
+struct netlbl_calipso_doiwalk_arg {
+	struct netlink_callback *nl_cb;
+	struct sk_buff *skb;
+	u32 seq;
+};
+
 /* NetLabel Generic NETLINK CALIPSO family */
 static struct genl_family netlbl_calipso_gnl_family = {
 	.id = GENL_ID_GENERATE,
@@ -183,6 +190,73 @@ list_failure:
 	return ret_val;
 }
 
+/**
+ * netlbl_calipso_listall_cb - calipso_doi_walk() callback for LISTALL
+ * @doi_def: the CALIPSO DOI definition
+ * @arg: the netlbl_calipso_doiwalk_arg structure
+ *
+ * Description:
+ * This function is designed to be used as a callback to the
+ * calipso_doi_walk() function for use in generating a response for a LISTALL
+ * message.  Returns the size of the message on success, negative values on
+ * failure.
+ *
+ */
+static int netlbl_calipso_listall_cb(struct calipso_doi *doi_def, void *arg)
+{
+	int ret_val = -ENOMEM;
+	struct netlbl_calipso_doiwalk_arg *cb_arg = arg;
+	void *data;
+
+	data = genlmsg_put(cb_arg->skb, NETLINK_CB(cb_arg->nl_cb->skb).portid,
+			   cb_arg->seq, &netlbl_calipso_gnl_family,
+			   NLM_F_MULTI, NLBL_CALIPSO_C_LISTALL);
+	if (!data)
+		goto listall_cb_failure;
+
+	ret_val = nla_put_u32(cb_arg->skb, NLBL_CALIPSO_A_DOI, doi_def->doi);
+	if (ret_val != 0)
+		goto listall_cb_failure;
+	ret_val = nla_put_u32(cb_arg->skb,
+			      NLBL_CALIPSO_A_MTYPE,
+			      doi_def->type);
+	if (ret_val != 0)
+		goto listall_cb_failure;
+
+	genlmsg_end(cb_arg->skb, data);
+	return 0;
+
+listall_cb_failure:
+	genlmsg_cancel(cb_arg->skb, data);
+	return ret_val;
+}
+
+/**
+ * netlbl_calipso_listall - Handle a LISTALL message
+ * @skb: the NETLINK buffer
+ * @cb: the NETLINK callback
+ *
+ * Description:
+ * Process a user generated LISTALL message and respond accordingly.  Returns
+ * zero on success and negative values on error.
+ *
+ */
+static int netlbl_calipso_listall(struct sk_buff *skb,
+				  struct netlink_callback *cb)
+{
+	struct netlbl_calipso_doiwalk_arg cb_arg;
+	u32 doi_skip = cb->args[0];
+
+	cb_arg.nl_cb = cb;
+	cb_arg.skb = skb;
+	cb_arg.seq = cb->nlh->nlmsg_seq;
+
+	calipso_doi_walk(&doi_skip, netlbl_calipso_listall_cb, &cb_arg);
+
+	cb->args[0] = doi_skip;
+	return skb->len;
+}
+
 /* NetLabel Generic NETLINK Command Definitions
  */
 
@@ -201,6 +275,13 @@ static const struct genl_ops netlbl_calipso_ops[] = {
 	.doit = netlbl_calipso_list,
 	.dumpit = NULL,
 	},
+	{
+	.cmd = NLBL_CALIPSO_C_LISTALL,
+	.flags = 0,
+	.policy = calipso_genl_policy,
+	.doit = NULL,
+	.dumpit = netlbl_calipso_listall,
+	},
 };
 
 /* NetLabel Generic NETLINK Protocol Functions
@@ -316,3 +397,28 @@ void calipso_doi_putdef(struct calipso_doi *doi_def)
 	if (ops)
 		ops->doi_putdef(doi_def);
 }
+
+/**
+ * calipso_doi_walk - Iterate through the DOI definitions
+ * @skip_cnt: skip past this number of DOI definitions, updated
+ * @callback: callback for each DOI definition
+ * @cb_arg: argument for the callback function
+ *
+ * Description:
+ * Iterate over the DOI definition list, skipping the first @skip_cnt entries.
+ * For each entry call @callback, if @callback returns a negative value stop
+ * 'walking' through the list and return.  Updates the value in @skip_cnt upon
+ * return.  Returns zero on success, negative values on failure.
+ *
+ */
+int calipso_doi_walk(u32 *skip_cnt,
+		     int (*callback)(struct calipso_doi *doi_def, void *arg),
+		     void *cb_arg)
+{
+	int ret_val = -ENOMSG;
+	const struct netlbl_calipso_ops *ops = netlbl_calipso_ops_get();
+
+	if (ops)
+		ret_val = ops->doi_walk(skip_cnt, callback, cb_arg);
+	return ret_val;
+}
diff --git a/net/netlabel/netlabel_calipso.h b/net/netlabel/netlabel_calipso.h
index 6da737a..1f24174 100644
--- a/net/netlabel/netlabel_calipso.h
+++ b/net/netlabel/netlabel_calipso.h
@@ -63,6 +63,17 @@
  *
  *   If using CALIPSO_MAP_PASS no additional attributes are required.
  *
+ * o LISTALL:
+ *   This message is sent by an application to list the valid DOIs on the
+ *   system.  When sent by an application there is no payload and the
+ *   NLM_F_DUMP flag should be set.  The kernel should respond with a series of
+ *   the following messages.
+ *
+ *   Required attributes:
+ *
+ *    NLBL_CALIPSO_A_DOI
+ *    NLBL_CALIPSO_A_MTYPE
+ *
  */
 
 /* NetLabel CALIPSO commands */
@@ -105,5 +116,8 @@ int calipso_doi_add(struct calipso_doi *doi_def,
 void calipso_doi_free(struct calipso_doi *doi_def);
 struct calipso_doi *calipso_doi_getdef(u32 doi);
 void calipso_doi_putdef(struct calipso_doi *doi_def);
+int calipso_doi_walk(u32 *skip_cnt,
+		     int (*callback)(struct calipso_doi *doi_def, void *arg),
+		     void *cb_arg);
 
 #endif
-- 
2.7.4
