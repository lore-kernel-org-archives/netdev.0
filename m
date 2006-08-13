From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 03/16] [RTNETLINK]: Add rtnetlink notification interface
Date: Mon, 14 Aug 2006 00:00:03 +0200
Message-ID: <20060814214339.771459195@postel.suug.ch>
References: <20060814213718.580598840@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:14542 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964976AbWHNVob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:44:31 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=rtnl_notify
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds rtnl_notify() to send rtnetlink notification messages and
rtnl_set_sk_err() to report notification errors as socket
errors in order to indicate the need of a resync due to loss
of events.

nlmsg_report() is added to properly document the meaning of
NLM_F_ECHO.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19.git/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.git.orig/net/core/rtnetlink.c
+++ net-2.6.19.git/net/core/rtnetlink.c
@@ -171,6 +171,22 @@ int rtnl_unicast(struct sk_buff *skb, u3
 	return nlmsg_unicast(rtnl, skb, pid);
 }
 
+int rtnl_notify(struct sk_buff *skb, u32 pid, u32 group,
+		struct nlmsghdr *nlh, gfp_t flags)
+{
+	int report = 0;
+
+	if (nlh)
+		report = nlmsg_report(nlh);
+
+	return nlmsg_notify(rtnl, skb, pid, group, report, flags);
+}
+
+void rtnl_set_sk_err(u32 group, int error)
+{
+	netlink_set_err(rtnl, 0, group, error);
+}
+
 int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics)
 {
 	struct rtattr *mx = (struct rtattr*)skb->tail;
@@ -829,3 +845,5 @@ EXPORT_SYMBOL(rtnl_lock);
 EXPORT_SYMBOL(rtnl_trylock);
 EXPORT_SYMBOL(rtnl_unlock);
 EXPORT_SYMBOL(rtnl_unicast);
+EXPORT_SYMBOL(rtnl_notify);
+EXPORT_SYMBOL(rtnl_set_sk_err);
Index: net-2.6.19.git/include/linux/rtnetlink.h
===================================================================
--- net-2.6.19.git.orig/include/linux/rtnetlink.h
+++ net-2.6.19.git/include/linux/rtnetlink.h
@@ -585,6 +585,9 @@ struct rtnetlink_link
 extern struct rtnetlink_link * rtnetlink_links[NPROTO];
 extern int rtnetlink_send(struct sk_buff *skb, u32 pid, u32 group, int echo);
 extern int rtnl_unicast(struct sk_buff *skb, u32 pid);
+extern int rtnl_notify(struct sk_buff *skb, u32 pid, u32 group,
+		       struct nlmsghdr *nlh, gfp_t flags);
+extern void rtnl_set_sk_err(u32 group, int error);
 extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
 
 extern void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
Index: net-2.6.19.git/include/net/netlink.h
===================================================================
--- net-2.6.19.git.orig/include/net/netlink.h
+++ net-2.6.19.git/include/net/netlink.h
@@ -65,6 +65,9 @@
  *   nlmsg_validate()			validate netlink message incl. attrs
  *   nlmsg_for_each_attr()		loop over all attributes
  *
+ * Misc:
+ *   nlmsg_report()			report back to application?
+ *
  * ------------------------------------------------------------------------
  *                          Attributes Interface
  * ------------------------------------------------------------------------
@@ -194,6 +197,9 @@ extern void		netlink_run_queue(struct so
 						    struct nlmsghdr *, int *));
 extern void		netlink_queue_skip(struct nlmsghdr *nlh,
 					   struct sk_buff *skb);
+extern int		nlmsg_notify(struct sock *sk, struct sk_buff *skb,
+				     u32 pid, unsigned int group, int report,
+				     gfp_t flags);
 
 extern int		nla_validate(struct nlattr *head, int len, int maxtype,
 				     struct nla_policy *policy);
@@ -376,6 +382,17 @@ static inline int nlmsg_validate(struct 
 }
 
 /**
+ * nlmsg_report - need to report back to application?
+ * @nlh: netlink message header
+ *
+ * Returns 1 if a report back to the application is requested.
+ */
+static inline int nlmsg_report(struct nlmsghdr *nlh)
+{
+	return !!(nlh->nlmsg_flags & NLM_F_ECHO);
+}
+
+/**
  * nlmsg_for_each_attr - iterate over a stream of attributes
  * @pos: loop counter, set to current attribute
  * @nlh: netlink message header

