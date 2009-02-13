From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] genetlink: introduce pre/post methods
Date: Fri, 13 Feb 2009 10:04:25 +0100
Message-ID: <1234515865.4204.16.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sometimes doit/dumpit callbacks for a given family consist
of quite a bit of boilerplate code, for example locking or
generic sanity checks on messages.

These methods allow writing the boilerplate code just once
instead of copying it into all handlers.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
I'd like to have this go in via the wireless tree because I have a
bugfix for that tree which depends on this infrastructure.

Note: struct genl_info just moves.

 include/net/genetlink.h |   47 ++++++++++++++++++++++++++++-------------------
 net/netlink/genetlink.c |   19 ++++++++++++++++---
 2 files changed, 44 insertions(+), 22 deletions(-)

--- wireless-testing.orig/include/net/genetlink.h	2009-02-13 09:14:26.000000000 +0100
+++ wireless-testing/include/net/genetlink.h	2009-02-13 10:00:37.000000000 +0100
@@ -21,12 +21,35 @@ struct genl_multicast_group
 };
 
 /**
+ * struct genl_info - receiving information
+ * @snd_seq: sending sequence number
+ * @snd_pid: netlink pid of sender
+ * @nlhdr: netlink message header
+ * @genlhdr: generic netlink message header
+ * @userhdr: user specific header
+ * @attrs: netlink attributes
+ */
+struct genl_info
+{
+	u32			snd_seq;
+	u32			snd_pid;
+	struct nlmsghdr *	nlhdr;
+	struct genlmsghdr *	genlhdr;
+	void *			userhdr;
+	struct nlattr **	attrs;
+};
+
+/**
  * struct genl_family - generic netlink family
  * @id: protocol family idenfitier
  * @hdrsize: length of user specific header in bytes
  * @name: name of family
  * @version: protocol version
  * @maxattr: maximum number of attributes supported
+ * @pre_doit: called before any doit op
+ * @post_doit: called after any doit op
+ * @pre_dumpit: called before any dumpit op
+ * @post_dumpit: called after any dumpit op
  * @attrbuf: buffer to store parsed attributes
  * @ops_list: list of all assigned operations
  * @family_list: family list
@@ -39,6 +62,11 @@ struct genl_family
 	char			name[GENL_NAMSIZ];
 	unsigned int		version;
 	unsigned int		maxattr;
+	int			(*pre_doit)(struct sk_buff *skb,
+					    struct genl_info *info);
+	void			(*post_doit)(void);
+	int			(*pre_dumpit)(void);
+	void			(*post_dumpit)(void);
 	struct nlattr **	attrbuf;	/* private */
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
@@ -46,25 +74,6 @@ struct genl_family
 };
 
 /**
- * struct genl_info - receiving information
- * @snd_seq: sending sequence number
- * @snd_pid: netlink pid of sender
- * @nlhdr: netlink message header
- * @genlhdr: generic netlink message header
- * @userhdr: user specific header
- * @attrs: netlink attributes
- */
-struct genl_info
-{
-	u32			snd_seq;
-	u32			snd_pid;
-	struct nlmsghdr *	nlhdr;
-	struct genlmsghdr *	genlhdr;
-	void *			userhdr;
-	struct nlattr **	attrs;
-};
-
-/**
  * struct genl_ops - generic netlink operations
  * @cmd: command identifier
  * @flags: flags
--- wireless-testing.orig/net/netlink/genetlink.c	2009-02-13 09:14:26.000000000 +0100
+++ wireless-testing/net/netlink/genetlink.c	2009-02-13 09:54:32.000000000 +0100
@@ -446,8 +446,14 @@ static int genl_rcv_msg(struct sk_buff *
 			return -EOPNOTSUPP;
 
 		genl_unlock();
-		err = netlink_dump_start(genl_sock, skb, nlh,
-					 ops->dumpit, ops->done);
+		err = 0;
+		if (family->pre_dumpit)
+			err = family->pre_dumpit();
+		if (!err)
+			err = netlink_dump_start(genl_sock, skb, nlh,
+						 ops->dumpit, ops->done);
+		if (family->post_dumpit)
+			family->post_dumpit();
 		genl_lock();
 		return err;
 	}
@@ -469,7 +475,14 @@ static int genl_rcv_msg(struct sk_buff *
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = family->attrbuf;
 
-	return ops->doit(skb, &info);
+	err = 0;
+	if (family->pre_doit)
+		err = family->pre_doit(skb, &info);
+	if (!err)
+		err = ops->doit(skb, &info);
+	if (family->post_doit)
+		family->post_doit();
+	return err;
 }
 
 static void genl_rcv(struct sk_buff *skb)


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
