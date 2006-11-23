From: Thomas Graf <tgraf@suug.ch>
Subject: [GENETLINK] ctrl: Avoid empty CTRL_ATTR_OPS attribute when dumping
Date: Thu, 23 Nov 2006 14:47:54 +0100
Message-ID: <20061123134754.GQ8693@postel.suug.ch>
References: <4466a10611191122r2bd16dbdmc35991c13dc9c92f@mail.gmail.com> <20061119195402.GJ8693@postel.suug.ch> <20061121.173556.07641543.davem@davemloft.net> <20061121.174058.104035138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33678 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S933718AbWKWNre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 08:47:34 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061121.174058.104035138.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Based on Jamal's patch but compiled and even tested. :-)

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/net/netlink/genetlink.c
===================================================================
--- net-2.6.20.orig/net/netlink/genetlink.c	2006-11-23 14:37:54.000000000 +0100
+++ net-2.6.20/net/netlink/genetlink.c	2006-11-23 14:39:42.000000000 +0100
@@ -394,10 +394,7 @@
 static int ctrl_fill_info(struct genl_family *family, u32 pid, u32 seq,
 			  u32 flags, struct sk_buff *skb, u8 cmd)
 {
-	struct nlattr *nla_ops;
-	struct genl_ops *ops;
 	void *hdr;
-	int idx = 1;
 
 	hdr = genlmsg_put(skb, pid, seq, &genl_ctrl, flags, cmd);
 	if (hdr == NULL)
@@ -409,33 +406,39 @@
 	NLA_PUT_U32(skb, CTRL_ATTR_HDRSIZE, family->hdrsize);
 	NLA_PUT_U32(skb, CTRL_ATTR_MAXATTR, family->maxattr);
 
-	nla_ops = nla_nest_start(skb, CTRL_ATTR_OPS);
-	if (nla_ops == NULL)
-		goto nla_put_failure;
+	if (!list_empty(&family->ops_list)) {
+		struct nlattr *nla_ops;
+		struct genl_ops *ops;
+		int idx = 1;
 
-	list_for_each_entry(ops, &family->ops_list, ops_list) {
-		struct nlattr *nest;
-
-		nest = nla_nest_start(skb, idx++);
-		if (nest == NULL)
+		nla_ops = nla_nest_start(skb, CTRL_ATTR_OPS);
+		if (nla_ops == NULL)
 			goto nla_put_failure;
 
-		NLA_PUT_U32(skb, CTRL_ATTR_OP_ID, ops->cmd);
-		NLA_PUT_U32(skb, CTRL_ATTR_OP_FLAGS, ops->flags);
+		list_for_each_entry(ops, &family->ops_list, ops_list) {
+			struct nlattr *nest;
 
-		if (ops->policy)
-			NLA_PUT_FLAG(skb, CTRL_ATTR_OP_POLICY);
+			nest = nla_nest_start(skb, idx++);
+			if (nest == NULL)
+				goto nla_put_failure;
 
-		if (ops->doit)
-			NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DOIT);
+			NLA_PUT_U32(skb, CTRL_ATTR_OP_ID, ops->cmd);
+			NLA_PUT_U32(skb, CTRL_ATTR_OP_FLAGS, ops->flags);
 
-		if (ops->dumpit)
-			NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DUMPIT);
+			if (ops->policy)
+				NLA_PUT_FLAG(skb, CTRL_ATTR_OP_POLICY);
 
-		nla_nest_end(skb, nest);
-	}
+			if (ops->doit)
+				NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DOIT);
+
+			if (ops->dumpit)
+				NLA_PUT_FLAG(skb, CTRL_ATTR_OP_DUMPIT);
 
-	nla_nest_end(skb, nla_ops);
+			nla_nest_end(skb, nest);
+		}
+
+		nla_nest_end(skb, nla_ops);
+	}
 
 	return genlmsg_end(skb, hdr);
 
