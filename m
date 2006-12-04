From: jamal <hadi@cyberus.ca>
Subject: [RFC][GENETLINK] move command capabilities  to flags
Date: Mon, 04 Dec 2006 16:07:42 -0500
Message-ID: <1165266463.3643.46.camel@localhost>
References: <1165060612.3564.8.camel@localhost>
	 <20061204092041.GN8693@postel.suug.ch> <1165237269.3664.15.camel@localhost>
	 <20061204163115.GR8693@postel.suug.ch> <1165254484.3643.29.camel@localhost>
	 <20061204180000.GU8693@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-LIspNt5vhLKoeaNLFfLp"
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.227]:10226 "EHLO
	nz-out-0102.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S937381AbWLDVHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 16:07:47 -0500
Received: by nz-out-0102.google.com with SMTP id s1so1958140nze
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 13:07:47 -0800 (PST)
To: davem@davemloft.net
In-Reply-To: <20061204180000.GU8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-LIspNt5vhLKoeaNLFfLp
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2006-04-12 at 19:00 +0100, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-12-04 12:48

> > We can resolve that by uping the version for the controller.
> > User will use that a signal.
> 
> Good idea, makes me happy :-) please do that in your patch as well.


Ok, here she goes... 
If looks good, Dave please apply to net-2.6.20

cheers,
jamal

--=-LIspNt5vhLKoeaNLFfLp
Content-Disposition: attachment; filename=genl_capab_fl_take2
Content-Type: text/plain; name=genl_capab_fl_take2; charset=us-ascii
Content-Transfer-Encoding: 7bit

This patch moves command capabilities to command flags. Other than
being cleaner, saves several bytes.
We increment the nlctrl version so as to signal to user space that
to not expect the attributes. We will try to be careful
not to do this too often ;->

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 49ba7537cec41f0db2500054b5fde3c193c37a97
tree f56cb78a17a9847df33101fd4a807617f74d27c6
parent 55a2dc3caa86e03cb3d9e856215e2fceb5cf5f66
author Jamal Hadi Salim <hadi@cyberus.ca> Mon, 04 Dec 2006 15:49:06 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Mon, 04 Dec 2006 15:49:06 -0500

 include/linux/genetlink.h |    6 +++---
 net/netlink/genetlink.c   |   18 ++++++++----------
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 9049dc6..f7a9377 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -17,6 +17,9 @@ struct genlmsghdr {
 #define GENL_HDRLEN	NLMSG_ALIGN(sizeof(struct genlmsghdr))
 
 #define GENL_ADMIN_PERM		0x01
+#define GENL_CMD_CAP_DO		0x02
+#define GENL_CMD_CAP_DUMP	0x04
+#define GENL_CMD_CAP_HASPOL	0x08
 
 /*
  * List of reserved static generic netlink identifiers:
@@ -58,9 +61,6 @@ enum {
 	CTRL_ATTR_OP_UNSPEC,
 	CTRL_ATTR_OP_ID,
 	CTRL_ATTR_OP_FLAGS,
-	CTRL_ATTR_OP_POLICY,
-	CTRL_ATTR_OP_DOIT,
-	CTRL_ATTR_OP_DUMPIT,
 	__CTRL_ATTR_OP_MAX,
 };
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index cc874f0..3e37ea5 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -143,6 +143,13 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
 		goto errout;
 	}
 
+	if (ops->dumpit)
+		ops->flags |= GENL_CMD_CAP_DO;
+	if (ops->doit)
+		ops->flags |= GENL_CMD_CAP_DUMP;
+	if (ops->policy)
+		ops->flags |= GENL_CMD_CAP_HASPOL;
+
 	genl_lock();
 	list_add_tail(&ops->ops_list, &family->ops_list);
 	genl_unlock();
@@ -387,7 +394,7 @@ static void genl_rcv(struct sock *sk, int len)
 static struct genl_family genl_ctrl = {
 	.id = GENL_ID_CTRL,
 	.name = "nlctrl",
-	.version = 0x1,
+	.version = 0x2,
 	.maxattr = CTRL_ATTR_MAX,
 };
 
@@ -425,15 +432,6 @@ static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
 			NLA_PUT_U32(skb, CTRL_ATTR_OP_ID, ops->cmd);
 			NLA_PUT_U32(skb, CTRL_ATTR_OP_FLAGS, ops->flags);
 
-			if (ops->policy)
-				NLA_PUT_FLAG(skb, CTRL_ATTR_OP_POLICY);
-
-			if (ops->doit)
-				NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DOIT);
-
-			if (ops->dumpit)
-				NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DUMPIT);
-
 			nla_nest_end(skb, nest);
 		}
 

--=-LIspNt5vhLKoeaNLFfLp--

