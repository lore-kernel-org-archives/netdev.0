From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3] [GENL]: Add genlmsg_put_reply() to simplify building reply headers
Date: Tue, 14 Nov 2006 12:46:31 +0100
Message-ID: <20061114114657.922717203@lsx.localdomain>
References: <20061114114628.033840590@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:27068 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S933423AbWKNLsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 06:48:17 -0500
To: davem@davemloft.net
Content-Disposition: inline; filename=genlmsg_put_reply
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By modyfing genlmsg_put() to take a genl_family and by adding
genlmsg_put_reply() the process of constructing the netlink
and generic netlink headers is simplified.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/include/net/genetlink.h
===================================================================
--- net-2.6.20.orig/include/net/genetlink.h	2006-11-14 12:46:16.000000000 +0100
+++ net-2.6.20/include/net/genetlink.h	2006-11-14 12:46:18.000000000 +0100
@@ -79,34 +79,51 @@
  * @skb: socket buffer holding the message
  * @pid: netlink pid the message is addressed to
  * @seq: sequence number (usually the one of the sender)
- * @type: netlink message type
- * @hdrlen: length of the user specific header
+ * @family: generic netlink family
  * @flags netlink message flags
  * @cmd: generic netlink command
- * @version: version
  *
  * Returns pointer to user specific header
  */
 static inline void *genlmsg_put(struct sk_buff *skb, u32 pid, u32 seq,
-				int type, int hdrlen, int flags,
-				u8 cmd, u8 version)
+				struct genl_family *family, int flags, u8 cmd)
 {
 	struct nlmsghdr *nlh;
 	struct genlmsghdr *hdr;
 
-	nlh = nlmsg_put(skb, pid, seq, type, GENL_HDRLEN + hdrlen, flags);
+	nlh = nlmsg_put(skb, pid, seq, family->id, GENL_HDRLEN +
+			family->hdrsize, flags);
 	if (nlh == NULL)
 		return NULL;
 
 	hdr = nlmsg_data(nlh);
 	hdr->cmd = cmd;
-	hdr->version = version;
+	hdr->version = family->version;
 	hdr->reserved = 0;
 
 	return (char *) hdr + GENL_HDRLEN;
 }
 
 /**
+ * genlmsg_put_reply - Add generic netlink header to a reply message
+ * @skb: socket buffer holding the message
+ * @info: receiver info
+ * @family: generic netlink family
+ * @flags: netlink message flags
+ * @cmd: generic netlink command
+ *
+ * Returns pointer to user specific header
+ */
+static inline void *genlmsg_put_reply(struct sk_buff *skb,
+				      struct genl_info *info,
+				      struct genl_family *family,
+				      int flags, u8 cmd)
+{
+	return genlmsg_put(skb, info->snd_pid, info->snd_seq, family,
+			   flags, cmd);
+}
+
+/**
  * genlmsg_end - Finalize a generic netlink message
  * @skb: socket buffer the message is stored in
  * @hdr: user specific header
Index: net-2.6.20/kernel/taskstats.c
===================================================================
--- net-2.6.20.orig/kernel/taskstats.c	2006-11-14 12:46:02.000000000 +0100
+++ net-2.6.20/kernel/taskstats.c	2006-11-14 12:46:18.000000000 +0100
@@ -85,13 +85,9 @@
 		int seq = get_cpu_var(taskstats_seqnum)++;
 		put_cpu_var(taskstats_seqnum);
 
-		reply = genlmsg_put(skb, 0, seq,
-				family.id, 0, 0,
-				cmd, family.version);
+		reply = genlmsg_put(skb, 0, seq, &family, 0, cmd);
 	} else
-		reply = genlmsg_put(skb, info->snd_pid, info->snd_seq,
-				family.id, 0, 0,
-				cmd, family.version);
+		reply = genlmsg_put_reply(skb, info, &family, 0, cmd);
 	if (reply == NULL) {
 		nlmsg_free(skb);
 		return -EINVAL;
Index: net-2.6.20/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_cipso_v4.c	2006-11-14 12:46:02.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_cipso_v4.c	2006-11-14 12:46:18.000000000 +0100
@@ -457,12 +457,8 @@
 		ret_val = -ENOMEM;
 		goto list_failure;
 	}
-	data = netlbl_netlink_hdr_put(ans_skb,
-				      info->snd_pid,
-				      info->snd_seq,
-				      netlbl_cipsov4_gnl_family.id,
-				      0,
-				      NLBL_CIPSOV4_C_LIST);
+	data = genlmsg_put_reply(ans_skb, info, &netlbl_cipsov4_gnl_family,
+				 0, NLBL_CIPSOV4_C_LIST);
 	if (data == NULL) {
 		ret_val = -ENOMEM;
 		goto list_failure;
@@ -607,12 +603,9 @@
 	struct netlbl_cipsov4_doiwalk_arg *cb_arg = arg;
 	void *data;
 
-	data = netlbl_netlink_hdr_put(cb_arg->skb,
-				      NETLINK_CB(cb_arg->nl_cb->skb).pid,
-				      cb_arg->seq,
-				      netlbl_cipsov4_gnl_family.id,
-				      NLM_F_MULTI,
-				      NLBL_CIPSOV4_C_LISTALL);
+	data = genlmsg_put(cb_arg->skb, NETLINK_CB(cb_arg->nl_cb->skb).pid,
+			   cb_arg->seq, &netlbl_cipsov4_gnl_family,
+			   NLM_F_MULTI, NLBL_CIPSOV4_C_LISTALL);
 	if (data == NULL)
 		goto listall_cb_failure;
 
Index: net-2.6.20/net/netlabel/netlabel_mgmt.c
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_mgmt.c	2006-11-14 12:46:02.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_mgmt.c	2006-11-14 12:46:18.000000000 +0100
@@ -188,12 +188,9 @@
 	struct netlbl_domhsh_walk_arg *cb_arg = arg;
 	void *data;
 
-	data = netlbl_netlink_hdr_put(cb_arg->skb,
-				      NETLINK_CB(cb_arg->nl_cb->skb).pid,
-				      cb_arg->seq,
-				      netlbl_mgmt_gnl_family.id,
-				      NLM_F_MULTI,
-				      NLBL_MGMT_C_LISTALL);
+	data = genlmsg_put(cb_arg->skb, NETLINK_CB(cb_arg->nl_cb->skb).pid,
+			   cb_arg->seq, &netlbl_mgmt_gnl_family,
+			   NLM_F_MULTI, NLBL_MGMT_C_LISTALL);
 	if (data == NULL)
 		goto listall_cb_failure;
 
@@ -359,12 +356,8 @@
 	ans_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
 		return -ENOMEM;
-	data = netlbl_netlink_hdr_put(ans_skb,
-				      info->snd_pid,
-				      info->snd_seq,
-				      netlbl_mgmt_gnl_family.id,
-				      0,
-				      NLBL_MGMT_C_LISTDEF);
+	data = genlmsg_put_reply(ans_skb, info, &netlbl_mgmt_gnl_family,
+				 0, NLBL_MGMT_C_LISTDEF);
 	if (data == NULL)
 		goto listdef_failure;
 
@@ -422,12 +415,9 @@
 	int ret_val = -ENOMEM;
 	void *data;
 
-	data = netlbl_netlink_hdr_put(skb,
-				      NETLINK_CB(cb->skb).pid,
-				      cb->nlh->nlmsg_seq,
-				      netlbl_mgmt_gnl_family.id,
-				      NLM_F_MULTI,
-				      NLBL_MGMT_C_PROTOCOLS);
+	data = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+			   &netlbl_mgmt_gnl_family, NLM_F_MULTI,
+			   NLBL_MGMT_C_PROTOCOLS);
 	if (data == NULL)
 		goto protocols_cb_failure;
 
@@ -495,12 +485,8 @@
 	ans_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
 		return -ENOMEM;
-	data = netlbl_netlink_hdr_put(ans_skb,
-				      info->snd_pid,
-				      info->snd_seq,
-				      netlbl_mgmt_gnl_family.id,
-				      0,
-				      NLBL_MGMT_C_VERSION);
+	data = genlmsg_put_reply(ans_skb, info, &netlbl_mgmt_gnl_family,
+				 0, NLBL_MGMT_C_VERSION);
 	if (data == NULL)
 		goto version_failure;
 
Index: net-2.6.20/net/netlabel/netlabel_unlabeled.c
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_unlabeled.c	2006-11-14 12:46:02.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_unlabeled.c	2006-11-14 12:46:18.000000000 +0100
@@ -141,12 +141,8 @@
 	ans_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (ans_skb == NULL)
 		goto list_failure;
-	data = netlbl_netlink_hdr_put(ans_skb,
-				      info->snd_pid,
-				      info->snd_seq,
-				      netlbl_unlabel_gnl_family.id,
-				      0,
-				      NLBL_UNLABEL_C_LIST);
+	data = genlmsg_put_reply(ans_skb, info, &netlbl_unlabel_gnl_family,
+				 0, NLBL_UNLABEL_C_LIST);
 	if (data == NULL) {
 		ret_val = -ENOMEM;
 		goto list_failure;
Index: net-2.6.20/net/netlabel/netlabel_user.h
===================================================================
--- net-2.6.20.orig/net/netlabel/netlabel_user.h	2006-11-14 12:46:02.000000000 +0100
+++ net-2.6.20/net/netlabel/netlabel_user.h	2006-11-14 12:46:18.000000000 +0100
@@ -42,37 +42,6 @@
 /* NetLabel NETLINK helper functions */
 
 /**
- * netlbl_netlink_hdr_put - Write the NETLINK buffers into a sk_buff
- * @skb: the packet
- * @pid: the PID of the receipient
- * @seq: the sequence number
- * @type: the generic NETLINK message family type
- * @cmd: command
- *
- * Description:
- * Write both a NETLINK nlmsghdr structure and a Generic NETLINK genlmsghdr
- * struct to the packet.  Returns a pointer to the start of the payload buffer
- * on success or NULL on failure.
- *
- */
-static inline void *netlbl_netlink_hdr_put(struct sk_buff *skb,
-					   u32 pid,
-					   u32 seq,
-					   int type,
-					   int flags,
-					   u8 cmd)
-{
-	return genlmsg_put(skb,
-			   pid,
-			   seq,
-			   type,
-			   0,
-			   flags,
-			   cmd,
-			   NETLBL_PROTO_VERSION);
-}
-
-/**
  * netlbl_netlink_auditinfo - Fetch the audit information from a NETLINK msg
  * @skb: the packet
  * @audit_info: NetLabel audit information
Index: net-2.6.20/net/netlink/genetlink.c
===================================================================
--- net-2.6.20.orig/net/netlink/genetlink.c	2006-11-14 12:46:02.000000000 +0100
+++ net-2.6.20/net/netlink/genetlink.c	2006-11-14 12:46:18.000000000 +0100
@@ -384,6 +384,13 @@
  * Controller
  **************************************************************************/
 
+static struct genl_family genl_ctrl = {
+	.id = GENL_ID_CTRL,
+	.name = "nlctrl",
+	.version = 0x1,
+	.maxattr = CTRL_ATTR_MAX,
+};
+
 static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
 			  u32 flags, struct sk_buff *skb, u8 cmd)
 {
@@ -392,8 +399,7 @@
 	void *hdr;
 	int idx = 1;
 
-	hdr = genlmsg_put(skb, pid, seq, GENL_ID_CTRL, 0, flags, cmd,
-			  family->version);
+	hdr = genlmsg_put(skb, pid, seq, &genl_ctrl, flags, cmd);
 	if (hdr == NULL)
 		return -1;
 
@@ -562,13 +568,6 @@
 	.policy		= ctrl_policy,
 };
 
-static struct genl_family genl_ctrl = {
-	.id = GENL_ID_CTRL,
-	.name = "nlctrl",
-	.version = 0x1,
-	.maxattr = CTRL_ATTR_MAX,
-};
-
 static int __init genl_init(void)
 {
 	int i, err;

--

