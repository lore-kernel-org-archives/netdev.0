From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH] Deinline __nlmsg_put and genlmsg_put. -7k code on i386 defconfig
Date: Sun, 29 Jan 2012 20:02:43 +0100
Message-ID: <4F2597D3.6050606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David Miller davem"@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change also removes commented-out copy of __nlmsg_put
which was last touched in 2005 with "Enable once all users
have been converted" comment on top.

    text	   data	    bss	    dec	    hex	filename
8453183	 533115	1810804	10797102 a4c02e	vmlinux.o.before
8446103	 533115	1810804	10790022 a4a486	vmlinux.o

Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>
---
  include/linux/netlink.h  |   18 ++----------------
  include/net/genetlink.h  |   32 ++------------------------------
  include/net/netlink.h    |   35 -----------------------------------
  net/netlink/af_netlink.c |   17 +++++++++++++++++
  net/netlink/genetlink.c  |   31 +++++++++++++++++++++++++++++++
  5 files changed, 52 insertions(+), 81 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 52e4895..a390e9d 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -237,22 +237,8 @@ struct netlink_notify {
  	int protocol;
  };

-static __inline__ struct nlmsghdr *
-__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
-{
-	struct nlmsghdr *nlh;
-	int size = NLMSG_LENGTH(len);
-
-	nlh = (struct nlmsghdr*)skb_put(skb, NLMSG_ALIGN(size));
-	nlh->nlmsg_type = type;
-	nlh->nlmsg_len = size;
-	nlh->nlmsg_flags = flags;
-	nlh->nlmsg_pid = pid;
-	nlh->nlmsg_seq = seq;
-	if (!__builtin_constant_p(size) || NLMSG_ALIGN(size) - size != 0)
-		memset(NLMSG_DATA(nlh) + len, 0, NLMSG_ALIGN(size) - size);
-	return nlh;
-}
+struct nlmsghdr *
+__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags);

  #define NLMSG_NEW(skb, pid, seq, type, len, flags) \
  ({	if (unlikely(skb_tailroom(skb) < (int)NLMSG_SPACE(len))) \
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 7db3299..d514c59 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -130,36 +130,8 @@ extern void genl_unregister_mc_group(struct genl_family *family,
  				     struct genl_multicast_group *grp);
  extern void genl_notify(struct sk_buff *skb, struct net *net, u32 pid,
  			u32 group, struct nlmsghdr *nlh, gfp_t flags);
-
-/**
- * genlmsg_put - Add generic netlink header to netlink message
- * @skb: socket buffer holding the message
- * @pid: netlink pid the message is addressed to
- * @seq: sequence number (usually the one of the sender)
- * @family: generic netlink family
- * @flags netlink message flags
- * @cmd: generic netlink command
- *
- * Returns pointer to user specific header
- */
-static inline void *genlmsg_put(struct sk_buff *skb, u32 pid, u32 seq,
-				struct genl_family *family, int flags, u8 cmd)
-{
-	struct nlmsghdr *nlh;
-	struct genlmsghdr *hdr;
-
-	nlh = nlmsg_put(skb, pid, seq, family->id, GENL_HDRLEN +
-			family->hdrsize, flags);
-	if (nlh == NULL)
-		return NULL;
-
-	hdr = nlmsg_data(nlh);
-	hdr->cmd = cmd;
-	hdr->version = family->version;
-	hdr->reserved = 0;
-
-	return (char *) hdr + GENL_HDRLEN;
-}
+extern void *genlmsg_put(struct sk_buff *skb, u32 pid, u32 seq,
+			 struct genl_family *family, int flags, u8 cmd);

  /**
   * genlmsg_nlhdr - Obtain netlink header from user specified header
diff --git a/include/net/netlink.h b/include/net/netlink.h
index cb1f350..f394fe5 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -441,41 +441,6 @@ static inline int nlmsg_report(const struct nlmsghdr *nlh)
  	nla_for_each_attr(pos, nlmsg_attrdata(nlh, hdrlen), \
  			  nlmsg_attrlen(nlh, hdrlen), rem)

-#if 0
-/* FIXME: Enable once all users have been converted */
-
-/**
- * __nlmsg_put - Add a new netlink message to an skb
- * @skb: socket buffer to store message in
- * @pid: netlink process id
- * @seq: sequence number of message
- * @type: message type
- * @payload: length of message payload
- * @flags: message flags
- *
- * The caller is responsible to ensure that the skb provides enough
- * tailroom for both the netlink header and payload.
- */
-static inline struct nlmsghdr *__nlmsg_put(struct sk_buff *skb, u32 pid,
-					   u32 seq, int type, int payload,
-					   int flags)
-{
-	struct nlmsghdr *nlh;
-
-	nlh = (struct nlmsghdr *) skb_put(skb, nlmsg_total_size(payload));
-	nlh->nlmsg_type = type;
-	nlh->nlmsg_len = nlmsg_msg_size(payload);
-	nlh->nlmsg_flags = flags;
-	nlh->nlmsg_pid = pid;
-	nlh->nlmsg_seq = seq;
-
-	memset((unsigned char *) nlmsg_data(nlh) + payload, 0,
-	       nlmsg_padlen(payload));
-
-	return nlh;
-}
-#endif
-
  /**
   * nlmsg_put - Add a new netlink message to an skb
   * @skb: socket buffer to store message in
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 629b061..7e2c35f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1645,6 +1645,23 @@ static void netlink_destroy_callback(struct netlink_callback *cb)
  	kfree(cb);
  }

+struct nlmsghdr *
+__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
+{
+	struct nlmsghdr *nlh;
+	int size = NLMSG_LENGTH(len);
+
+	nlh = (struct nlmsghdr*)skb_put(skb, NLMSG_ALIGN(size));
+	nlh->nlmsg_type = type;
+	nlh->nlmsg_len = size;
+	nlh->nlmsg_flags = flags;
+	nlh->nlmsg_pid = pid;
+	nlh->nlmsg_seq = seq;
+	memset(NLMSG_DATA(nlh) + len, 0, NLMSG_ALIGN(size) - size);
+	return nlh;
+}
+EXPORT_SYMBOL(__nlmsg_put);
+
  /*
   * It looks a bit ugly.
   * It would be better to create kernel thread.
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index c29d256..a115471 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -498,6 +498,37 @@ int genl_unregister_family(struct genl_family *family)
  }
  EXPORT_SYMBOL(genl_unregister_family);

+/**
+ * genlmsg_put - Add generic netlink header to netlink message
+ * @skb: socket buffer holding the message
+ * @pid: netlink pid the message is addressed to
+ * @seq: sequence number (usually the one of the sender)
+ * @family: generic netlink family
+ * @flags netlink message flags
+ * @cmd: generic netlink command
+ *
+ * Returns pointer to user specific header
+ */
+void *genlmsg_put(struct sk_buff *skb, u32 pid, u32 seq,
+				struct genl_family *family, int flags, u8 cmd)
+{
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *hdr;
+
+	nlh = nlmsg_put(skb, pid, seq, family->id, GENL_HDRLEN +
+			family->hdrsize, flags);
+	if (nlh == NULL)
+		return NULL;
+
+	hdr = nlmsg_data(nlh);
+	hdr->cmd = cmd;
+	hdr->version = family->version;
+	hdr->reserved = 0;
+
+	return (char *) hdr + GENL_HDRLEN;
+}
+EXPORT_SYMBOL(genlmsg_put);
+
  static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
  {
  	struct genl_ops *ops;
-- 
1.7.7.6
