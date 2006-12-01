From: jamal <hadi@cyberus.ca>
Subject: [G[PATCH 1/2][ENETLINK] max cmd boundary chec
Date: Fri, 01 Dec 2006 06:30:13 -0500
Message-ID: <1164972613.3562.7.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-WMhpg2A16h9Mkgew1bjW"
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:38337 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S936458AbWLALaT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 06:30:19 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1515948nze
        for <netdev@vger.kernel.org>; Fri, 01 Dec 2006 03:30:18 -0800 (PST)
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WMhpg2A16h9Mkgew1bjW
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

hopefully no mime crap
cheers,
jamal

--=-WMhpg2A16h9Mkgew1bjW
Content-Disposition: attachment; filename=gnl-dec1-1
Content-Type: text/plain; name=gnl-dec1-1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[GENETLINK] max cmd boundary check

We need to boundary check for commands being registered.

Signed-off-by: Jamal Hadi Salim<hadi@cyberus.ca>

---
commit 349e0e00396b79d8f2f9a41f6dc28dee9e7d3e3e
tree 02388c5729f2481644643a41837135bf52698e9e
parent 5465ae68b5ec11b2820db3f9b4c6fd94f113da44
author J Hadi Salim <hadi@cyberus.ca> Fri, 01 Dec 2006 05:59:46 -0500
committer J Hadi Salim <hadi@cyberus.ca> Fri, 01 Dec 2006 05:59:46 -0500

 include/linux/genetlink.h |    1 +
 net/netlink/genetlink.c   |   21 ++++++++++++++-------
 2 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 9049dc6..2427d58 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -7,6 +7,7 @@
 
 #define GENL_MIN_ID	NLMSG_MIN_TYPE
 #define GENL_MAX_ID	1023
+#define GENL_MAX_CMDS	256
 
 struct genlmsghdr {
 	__u8	cmd;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index cc874f0..50928da 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -79,13 +79,22 @@ static struct genl_family *genl_family_find_byname(char *name)
 	return NULL;
 }
 
-static struct genl_ops *genl_get_cmd(u8 cmd, struct genl_family *family)
+static struct genl_ops *genl_get_cmd(u8 cmd, struct genl_family *family, int *err)
 {
+	int i = 0;
 	struct genl_ops *ops;
 
-	list_for_each_entry(ops, &family->ops_list, ops_list)
-		if (ops->cmd == cmd)
+	list_for_each_entry(ops, &family->ops_list, ops_list) {
+		if (ops->cmd == cmd) {
+			*err = -EEXIST;
 			return ops;
+		}
+		if (++i > GENL_MAX_CMDS) {
+			/* is there a better code for exceeding range?*/
+			*err = -ERANGE;
+			return ops;
+		}
+	}
 
 	return NULL;
 }
@@ -138,10 +147,8 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 	if (ops->dumpit == NULL && ops->doit == NULL)
 		goto errout;
 
-	if (genl_get_cmd(ops->cmd, family)) {
-		err = -EEXIST;
+	if (genl_get_cmd(ops->cmd, family, &err)) 
 		goto errout;
-	}
 
 	genl_lock();
 	list_add_tail(&ops->ops_list, &family->ops_list);
@@ -313,7 +320,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (nlh->nlmsg_len < nlmsg_msg_size(hdrlen))
 		goto errout;
 
-	ops = genl_get_cmd(hdr->cmd, family);
+	ops = genl_get_cmd(hdr->cmd, family, &err);
 	if (ops == NULL) {
 		err = -EOPNOTSUPP;
 		goto errout;

--=-WMhpg2A16h9Mkgew1bjW--

