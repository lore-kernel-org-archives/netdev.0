From: Thomas Graf <tgraf@suug.ch>
Subject: [GENL]: Provide more information to userspace about registered genl families
Date: Thu, 31 Aug 2006 23:21:29 +0200
Message-ID: <20060831212129.GF3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50306 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932451AbWHaVVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 17:21:09 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Additionaly exports the following information when providing
the list of registered generic netlink families:
  - protocol version
  - header size
  - maximum number of attributes
  - list of available operations including
      - id
      - flags
      - avaiability of policy and doit/dumpit function

libnl HEAD provides a utility to read this new information:

	0x0010 nlctrl version 1
	    hdrsize 0 maxattr 6
	      op GETFAMILY (0x03) [POLICY,DOIT,DUMPIT]
	0x0011 NLBL_MGMT version 1
	    hdrsize 0 maxattr 0
	      op unknown (0x02) [DOIT]
	      op unknown (0x03) [DOIT]
	      ....

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/include/linux/genetlink.h
===================================================================
--- net-2.6.19.orig/include/linux/genetlink.h	2006-08-31 16:01:16.000000000 +0200
+++ net-2.6.19/include/linux/genetlink.h	2006-08-31 19:24:43.000000000 +0200
@@ -16,6 +16,8 @@
 
 #define GENL_HDRLEN	NLMSG_ALIGN(sizeof(struct genlmsghdr))
 
+#define GENL_ADMIN_PERM		0x01
+
 /*
  * List of reserved static generic netlink identifiers:
  */
@@ -43,9 +45,25 @@
 	CTRL_ATTR_UNSPEC,
 	CTRL_ATTR_FAMILY_ID,
 	CTRL_ATTR_FAMILY_NAME,
+	CTRL_ATTR_VERSION,
+	CTRL_ATTR_HDRSIZE,
+	CTRL_ATTR_MAXATTR,
+	CTRL_ATTR_OPS,
 	__CTRL_ATTR_MAX,
 };
 
 #define CTRL_ATTR_MAX (__CTRL_ATTR_MAX - 1)
 
+enum {
+	CTRL_ATTR_OP_UNSPEC,
+	CTRL_ATTR_OP_ID,
+	CTRL_ATTR_OP_FLAGS,
+	CTRL_ATTR_OP_POLICY,
+	CTRL_ATTR_OP_DOIT,
+	CTRL_ATTR_OP_DUMPIT,
+	__CTRL_ATTR_OP_MAX,
+};
+
+#define CTRL_ATTR_OP_MAX (__CTRL_ATTR_OP_MAX - 1)
+
 #endif	/* __LINUX_GENERIC_NETLINK_H */
Index: net-2.6.19/net/netlink/genetlink.c
===================================================================
--- net-2.6.19.orig/net/netlink/genetlink.c	2006-08-31 16:21:39.000000000 +0200
+++ net-2.6.19/net/netlink/genetlink.c	2006-08-31 19:10:38.000000000 +0200
@@ -387,7 +387,10 @@
 static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
 			  u32 flags, struct sk_buff *skb, u8 cmd)
 {
+	struct nlattr *nla_ops;
+	struct genl_ops *ops;
 	void *hdr;
+	int idx = 1;
 
 	hdr = genlmsg_put(skb, pid, seq, GENL_ID_CTRL, 0, flags, cmd,
 			  family->version);
@@ -396,6 +399,37 @@
 
 	NLA_PUT_STRING(skb, CTRL_ATTR_FAMILY_NAME, family->name);
 	NLA_PUT_U16(skb, CTRL_ATTR_FAMILY_ID, family->id);
+	NLA_PUT_U32(skb, CTRL_ATTR_VERSION, family->version);
+	NLA_PUT_U32(skb, CTRL_ATTR_HDRSIZE, family->hdrsize);
+	NLA_PUT_U32(skb, CTRL_ATTR_MAXATTR, family->maxattr);
+
+	nla_ops = nla_nest_start(skb, CTRL_ATTR_OPS);
+	if (nla_ops == NULL)
+		goto nla_put_failure;
+
+	list_for_each_entry(ops, &family->ops_list, ops_list) {
+		struct nlattr *nest;
+
+		nest = nla_nest_start(skb, idx++);
+		if (nest == NULL)
+			goto nla_put_failure;
+
+		NLA_PUT_U32(skb, CTRL_ATTR_OP_ID, ops->cmd);
+		NLA_PUT_U32(skb, CTRL_ATTR_OP_FLAGS, ops->flags);
+
+		if (ops->policy)
+			NLA_PUT_FLAG(skb, CTRL_ATTR_OP_POLICY);
+
+		if (ops->doit)
+			NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DOIT);
+
+		if (ops->dumpit)
+			NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DUMPIT);
+
+		nla_nest_end(skb, nest);
+	}
+
+	nla_nest_end(skb, nla_ops);
 
 	return genlmsg_end(skb, hdr);
 
@@ -411,6 +445,9 @@
 	int chains_to_skip = cb->args[0];
 	int fams_to_skip = cb->args[1];
 
+	if (chains_to_skip != 0)
+		genl_lock();
+
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++) {
 		if (i < chains_to_skip)
 			continue;
@@ -428,6 +465,9 @@
 	}
 
 errout:
+	if (chains_to_skip != 0)
+		genl_unlock();
+
 	cb->args[0] = i;
 	cb->args[1] = n;
 
Index: net-2.6.19/include/net/genetlink.h
===================================================================
--- net-2.6.19.orig/include/net/genetlink.h	2006-08-31 19:24:15.000000000 +0200
+++ net-2.6.19/include/net/genetlink.h	2006-08-31 19:24:20.000000000 +0200
@@ -27,8 +27,6 @@
 	struct list_head	family_list;	/* private */
 };
 
-#define GENL_ADMIN_PERM		0x01
-
 /**
  * struct genl_info - receiving information
  * @snd_seq: sending sequence number
