From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 5/9] rtnetlink: support strict attribute checking
Date: Thu, 15 Oct 2015 18:39:10 +0200
Message-ID: <31d3a063c16018d3ddfc8acb544474f15c9c381e.1444926905.git.jbenc@redhat.com>
References: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815AbbJOQjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:40 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow rtnl callbacks to support strict attribute checking. They can do so by
passing new RTNL_F_STRICT flag to rtnl_register_flags. The semantics of the
current rtnl_register and __rtnl_register functions were preserved in order
not to change almost hundred of the call sites.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/rtnetlink.h | 27 ++++++++++++++++++++++----
 net/core/rtnetlink.c    | 51 +++++++++++++++++++++++++++++++------------------
 2 files changed, 55 insertions(+), 23 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index aff6ceb891a9..58bf1f5ad6a1 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -8,13 +8,32 @@ typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
 typedef u16 (*rtnl_calcit_func)(struct sk_buff *, struct nlmsghdr *);
 
-int __rtnl_register(int protocol, int msgtype,
-		    rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
-void rtnl_register(int protocol, int msgtype,
-		   rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
+#define RTNL_F_STRICT	1
+
+int __rtnl_register_flags(int protocol, int msgtype,
+			  rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func,
+			  unsigned int flags);
+void rtnl_register_flags(int protocol, int msgtype,
+			 rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func,
+			 unsigned int flags);
 int rtnl_unregister(int protocol, int msgtype);
 void rtnl_unregister_all(int protocol);
 
+static inline int __rtnl_register(int protocol, int msgtype,
+				  rtnl_doit_func doit, rtnl_dumpit_func dumpit,
+				  rtnl_calcit_func calcit)
+{
+	return __rtnl_register_flags(protocol, msgtype,
+				     doit, dumpit, calcit, 0);
+}
+
+static inline void rtnl_register(int protocol, int msgtype,
+				 rtnl_doit_func doit, rtnl_dumpit_func dumpit,
+				 rtnl_calcit_func calcit)
+{
+	rtnl_register_flags(protocol, msgtype, doit, dumpit, calcit, 0);
+}
+
 static inline int rtnl_msg_family(const struct nlmsghdr *nlh)
 {
 	if (nlmsg_len(nlh) >= sizeof(struct rtgenmsg))
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index afb41c7492b4..dedc539b960c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -61,6 +61,7 @@ struct rtnl_link {
 	rtnl_doit_func		doit;
 	rtnl_dumpit_func	dumpit;
 	rtnl_calcit_func 	calcit;
+	unsigned int		flags;
 };
 
 static DEFINE_MUTEX(rtnl_mutex);
@@ -119,7 +120,8 @@ static inline int rtm_msgindex(int msgtype)
 	return msgindex;
 }
 
-static rtnl_doit_func rtnl_get_doit(int protocol, int msgindex)
+static rtnl_doit_func rtnl_get_doit(int protocol, int msgindex,
+				    unsigned int *flags)
 {
 	struct rtnl_link *tab;
 
@@ -131,6 +133,7 @@ static rtnl_doit_func rtnl_get_doit(int protocol, int msgindex)
 	if (tab == NULL || tab[msgindex].doit == NULL)
 		tab = rtnl_msg_handlers[PF_UNSPEC];
 
+	*flags = tab[msgindex].flags;
 	return tab[msgindex].doit;
 }
 
@@ -165,12 +168,13 @@ static rtnl_calcit_func rtnl_get_calcit(int protocol, int msgindex)
 }
 
 /**
- * __rtnl_register - Register a rtnetlink message type
+ * __rtnl_register_flags - Register a rtnetlink message type
  * @protocol: Protocol family or PF_UNSPEC
  * @msgtype: rtnetlink message type
  * @doit: Function pointer called for each request message
  * @dumpit: Function pointer called for each dump request (NLM_F_DUMP) message
  * @calcit: Function pointer to calc size of dump message
+ * @flags: RTNL_F_ flags
  *
  * Registers the specified function pointers (at least one of them has
  * to be non-NULL) to be called whenever a request message for the
@@ -182,9 +186,9 @@ static rtnl_calcit_func rtnl_get_calcit(int protocol, int msgindex)
  *
  * Returns 0 on success or a negative error code.
  */
-int __rtnl_register(int protocol, int msgtype,
-		    rtnl_doit_func doit, rtnl_dumpit_func dumpit,
-		    rtnl_calcit_func calcit)
+int __rtnl_register_flags(int protocol, int msgtype,
+			  rtnl_doit_func doit, rtnl_dumpit_func dumpit,
+			  rtnl_calcit_func calcit, unsigned int flags)
 {
 	struct rtnl_link *tab;
 	int msgindex;
@@ -210,29 +214,32 @@ int __rtnl_register(int protocol, int msgtype,
 	if (calcit)
 		tab[msgindex].calcit = calcit;
 
+	tab[msgindex].flags = flags;
+
 	return 0;
 }
-EXPORT_SYMBOL_GPL(__rtnl_register);
+EXPORT_SYMBOL_GPL(__rtnl_register_flags);
 
 /**
- * rtnl_register - Register a rtnetlink message type
+ * rtnl_register_flags - Register a rtnetlink message type
  *
- * Identical to __rtnl_register() but panics on failure. This is useful
- * as failure of this function is very unlikely, it can only happen due
- * to lack of memory when allocating the chain to store all message
- * handlers for a protocol. Meant for use in init functions where lack
- * of memory implies no sense in continuing.
+ * Identical to __rtnl_register_flags() but panics on failure. This is
+ * useful as failure of this function is very unlikely, it can only happen
+ * due to lack of memory when allocating the chain to store all message
+ * handlers for a protocol. Meant for use in init functions where lack of
+ * memory implies no sense in continuing.
  */
-void rtnl_register(int protocol, int msgtype,
-		   rtnl_doit_func doit, rtnl_dumpit_func dumpit,
-		   rtnl_calcit_func calcit)
+void rtnl_register_flags(int protocol, int msgtype,
+			 rtnl_doit_func doit, rtnl_dumpit_func dumpit,
+			 rtnl_calcit_func calcit, unsigned int flags)
 {
-	if (__rtnl_register(protocol, msgtype, doit, dumpit, calcit) < 0)
+	if (__rtnl_register_flags(protocol, msgtype, doit, dumpit, calcit,
+				  flags) < 0)
 		panic("Unable to register rtnetlink message handler, "
 		      "protocol = %d, message type = %d\n",
 		      protocol, msgtype);
 }
-EXPORT_SYMBOL_GPL(rtnl_register);
+EXPORT_SYMBOL_GPL(rtnl_register_flags);
 
 /**
  * rtnl_unregister - Unregister a rtnetlink message type
@@ -3298,6 +3305,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	rtnl_doit_func doit;
+	unsigned int flags;
 	int sz_idx, kind;
 	int family;
 	int type;
@@ -3326,6 +3334,9 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		rtnl_calcit_func calcit;
 		u16 min_dump_alloc = 0;
 
+		if (nlh->nlmsg_flags & NLM_F_STRICT)
+			return -EPROTO;
+
 		dumpit = rtnl_get_dumpit(family, type);
 		if (dumpit == NULL)
 			return -EOPNOTSUPP;
@@ -3346,9 +3357,11 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return err;
 	}
 
-	doit = rtnl_get_doit(family, type);
+	doit = rtnl_get_doit(family, type, &flags);
 	if (doit == NULL)
 		return -EOPNOTSUPP;
+	if (!(flags & RTNL_F_STRICT) && (nlh->nlmsg_flags & NLM_F_STRICT))
+		return -EPROTO;
 
 	return doit(skb, nlh);
 }
@@ -3356,7 +3369,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 static void rtnetlink_rcv(struct sk_buff *skb)
 {
 	rtnl_lock();
-	netlink_rcv_skb(skb, false, &rtnetlink_rcv_msg);
+	netlink_rcv_skb(skb, true, &rtnetlink_rcv_msg);
 	rtnl_unlock();
 }
 
-- 
1.8.3.1
