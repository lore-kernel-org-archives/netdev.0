From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC 1/2] genetlink: introduce pre_doit/post_doit hooks
Date: Thu, 30 Sep 2010 23:10:14 +0200
Message-ID: <20100930211131.021309930@sipsolutions.net>
References: <20100930211013.472957770@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: tgraf-G/eBtMaohhA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=genl-more-boilerplate.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Each family may have some amount of boilerplate
locking code that applies to most, or even all,
commands.

This allows a family to handle such things in
a more generic way, by allowing it to
 a) include private flags in each operation
 b) specify a pre_doit hook that is called,
    before an operation's doit() callback and
    may return an error directly,
 c) specify a post_doit hook that can undo
    locking or similar things done by pre_doit,
    and finally
 d) include two private pointers in each info
    struct passed between all these operations
    including doit(). (It's two because I'll
    need two in nl80211 -- can be extended.)

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/net/genetlink.h |   18 ++++++++++++++++++
 net/netlink/genetlink.c |   14 +++++++++++++-
 2 files changed, 31 insertions(+), 1 deletion(-)

--- wireless-testing.orig/include/net/genetlink.h	2010-09-30 22:19:03.000000000 +0200
+++ wireless-testing/include/net/genetlink.h	2010-09-30 22:34:10.000000000 +0200
@@ -20,6 +20,9 @@ struct genl_multicast_group {
 	u32			id;
 };
 
+struct genl_ops;
+struct genl_info;
+
 /**
  * struct genl_family - generic netlink family
  * @id: protocol family idenfitier
@@ -29,6 +32,10 @@ struct genl_multicast_group {
  * @maxattr: maximum number of attributes supported
  * @netnsok: set to true if the family can handle network
  *	namespaces and should be presented in all of them
+ * @pre_doit: called before an operation's doit callback, it may
+ *	do additional, common, filtering and return an error
+ * @post_doit: called after an operation's doit callback, it may
+ *	undo operations done by pre_doit, for example release locks
  * @attrbuf: buffer to store parsed attributes
  * @ops_list: list of all assigned operations
  * @family_list: family list
@@ -41,6 +48,12 @@ struct genl_family {
 	unsigned int		version;
 	unsigned int		maxattr;
 	bool			netnsok;
+	int			(*pre_doit)(struct genl_ops *ops,
+					    struct sk_buff *skb,
+					    struct genl_info *info);
+	void			(*post_doit)(struct genl_ops *ops,
+					     struct sk_buff *skb,
+					     struct genl_info *info);
 	struct nlattr **	attrbuf;	/* private */
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
@@ -55,6 +68,8 @@ struct genl_family {
  * @genlhdr: generic netlink message header
  * @userhdr: user specific header
  * @attrs: netlink attributes
+ * @_net: network namespace
+ * @user_ptr: user pointers
  */
 struct genl_info {
 	u32			snd_seq;
@@ -66,6 +81,7 @@ struct genl_info {
 #ifdef CONFIG_NET_NS
 	struct net *		_net;
 #endif
+	void *			user_ptr[2];
 };
 
 static inline struct net *genl_info_net(struct genl_info *info)
@@ -81,6 +97,7 @@ static inline void genl_info_net_set(str
 /**
  * struct genl_ops - generic netlink operations
  * @cmd: command identifier
+ * @internal_flags: flags used by the family
  * @flags: flags
  * @policy: attribute validation policy
  * @doit: standard command callback
@@ -90,6 +107,7 @@ static inline void genl_info_net_set(str
  */
 struct genl_ops {
 	u8			cmd;
+	u8			internal_flags;
 	unsigned int		flags;
 	const struct nla_policy	*policy;
 	int		       (*doit)(struct sk_buff *skb,
--- wireless-testing.orig/net/netlink/genetlink.c	2010-09-30 22:19:56.000000000 +0200
+++ wireless-testing/net/netlink/genetlink.c	2010-09-30 22:22:28.000000000 +0200
@@ -547,8 +547,20 @@ static int genl_rcv_msg(struct sk_buff *
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = family->attrbuf;
 	genl_info_net_set(&info, net);
+	memset(&info.user_ptr, 0, sizeof(info.user_ptr));
 
-	return ops->doit(skb, &info);
+	if (family->pre_doit) {
+		err = family->pre_doit(ops, skb, &info);
+		if (err)
+			return err;
+	}
+
+	err = ops->doit(skb, &info);
+
+	if (family->post_doit)
+		family->post_doit(ops, skb, &info);
+
+	return err;
 }
 
 static void genl_rcv(struct sk_buff *skb)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
