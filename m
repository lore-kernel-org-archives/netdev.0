From: jamal <hadi@cyberus.ca>
Subject: [PATCH][XFRM] export SAD info
Date: Wed, 25 Apr 2007 11:42:41 -0400
Message-ID: <1177515761.9923.3.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-SmRQZDKGeQzg0dmZBA3H"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:52040 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031093AbXDYPmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 11:42:45 -0400
Received: by wx-out-0506.google.com with SMTP id h31so275484wxd
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 08:42:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-SmRQZDKGeQzg0dmZBA3H
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Dave,

Something ive been meaning to do since you made the hash changes. I will
be doing one also for policy. Against latest Linus tree because i am
having strange challenges syncing net-2.6.22.

cheers,
jamal

--=-SmRQZDKGeQzg0dmZBA3H
Content-Disposition: attachment; filename=xfrm_sadinfo
Content-Type: text/plain; name=xfrm_sadinfo; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] export SAD info

On a system with a lot of SAs, counting SAD entries chews useful
CPU time since you need to dump the whole SAD to user space;
i.e something like ip xfrm state ls | grep -i src | wc -l
I have seen taking literally minutes on a 40K SAs when the system
is swapping.
With this patch, some of the SAD info (that was already being tracked)
is exposed to user space. i.e you do:
ip xfrm state count
And you get the count; you can also pass -s to the command line and
get the hash info.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 1fb99604e38f27c1ad4cb74b11f148c34d0d3be6
tree 1bb35db627ac5d3d2f370d0fc993ba6b80392696
parent 146d97b89c83c9460012185bfd584d21a3b5fe19
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 25 Apr 2007 11:30:21 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 25 Apr 2007 11:30:21 -0400

 include/linux/xfrm.h  |   25 ++++++++++++++++++++++
 include/net/xfrm.h    |    8 +++++++
 net/xfrm/xfrm_state.c |   12 ++++++++++-
 net/xfrm/xfrm_user.c  |   56 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 100 insertions(+), 1 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 15ca89e..9c656a5 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -181,6 +181,10 @@ enum {
 	XFRM_MSG_MIGRATE,
 #define XFRM_MSG_MIGRATE XFRM_MSG_MIGRATE
 
+	XFRM_MSG_NEWSADINFO,
+#define XFRM_MSG_NEWSADINFO XFRM_MSG_NEWSADINFO
+	XFRM_MSG_GETSADINFO,
+#define XFRM_MSG_GETSADINFO XFRM_MSG_GETSADINFO
 	__XFRM_MSG_MAX
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
@@ -234,6 +238,17 @@ enum xfrm_ae_ftype_t {
 #define XFRM_AE_MAX (__XFRM_AE_MAX - 1)
 };
 
+/* SAD Table filter flags  */
+enum xfrm_sad_ftype_t {
+	XFRM_SAD_UNSPEC,
+	XFRM_SAD_HMASK=1,
+	XFRM_SAD_HMAX=2,
+	XFRM_SAD_CNT=4,
+	__XFRM_SAD_MAX
+
+#define XFRM_SAD_MAX (__XFRM_SAD_MAX - 1)
+};
+
 struct xfrm_userpolicy_type {
 	__u8		type;
 	__u16		reserved1;
@@ -265,6 +280,16 @@ enum xfrm_attr_type_t {
 #define XFRMA_MAX (__XFRMA_MAX - 1)
 };
 
+enum xfrm_sadattr_type_t {
+	XFRMA_SAD_UNSPEC,
+	XFRMA_SADHMASK,
+	XFRMA_SADHMAX,
+	XFRMA_SADCNT,
+	__XFRMA_SAD_MAX
+
+#define XFRMA_SAD_MAX (__XFRMA_SAD_MAX - 1)
+};
+
 struct xfrm_usersa_info {
 	struct xfrm_selector		sel;
 	struct xfrm_id			id;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5a00aa8..4922e9f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -416,6 +416,13 @@ struct xfrm_audit
 	u32	secid;
 };
 
+/* SAD metadata, add more later */
+struct xfrm_sadinfo
+{
+	u32 sadhcnt; /* current hash bkts */
+	u32 sadhmcnt; /* max allowed hash bkts */
+	u32 sadcnt; /* current running count */
+};
 #ifdef CONFIG_AUDITSYSCALL
 extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
 		    struct xfrm_policy *xp, struct xfrm_state *x);
@@ -938,6 +945,7 @@ static inline int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **s
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
+extern void xfrm_sad_getinfo(struct xfrm_sadinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_notify(struct xfrm_state *x, int event);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index c1581fb..98e5ce3 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -53,7 +53,7 @@ static struct hlist_head *xfrm_state_bysrc __read_mostly;
 static struct hlist_head *xfrm_state_byspi __read_mostly;
 static unsigned int xfrm_state_hmask __read_mostly;
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
-static u32 xfrm_state_num;
+static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
 
 static inline unsigned int xfrm_dst_hash(xfrm_address_t *daddr,
@@ -421,6 +421,16 @@ restart:
 }
 EXPORT_SYMBOL(xfrm_state_flush);
 
+void xfrm_sad_getinfo(struct xfrm_sadinfo *si)
+{
+	spin_lock_bh(&xfrm_state_lock);
+	si->sadcnt = xfrm_state_num;
+	si->sadhcnt = xfrm_state_hmask;
+	si->sadhmcnt = xfrm_state_hashmax;
+	spin_unlock_bh(&xfrm_state_lock);
+}
+EXPORT_SYMBOL(xfrm_sad_getinfo);
+
 static int
 xfrm_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 		  struct xfrm_tmpl *tmpl,
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 816e369..089159a 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -672,6 +672,61 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 	return skb;
 }
 
+static int build_sadinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
+{
+	struct xfrm_sadinfo si;
+	struct nlmsghdr *nlh;
+	u32 *f;
+
+	nlh = nlmsg_put(skb, pid, seq, XFRM_MSG_NEWSADINFO, sizeof(u32), 0);
+	if (nlh == NULL) /* shouldnt really happen ... */
+		return -EMSGSIZE;
+
+	f = nlmsg_data(nlh);
+	*f = flags;
+	xfrm_sad_getinfo(&si);
+
+	if (flags & XFRM_SAD_HMASK)
+		NLA_PUT_U32(skb, XFRMA_SADHMASK, si.sadhcnt);
+	if (flags & XFRM_SAD_HMAX)
+		NLA_PUT_U32(skb, XFRMA_SADHMAX, si.sadhmcnt);
+	if (flags & XFRM_SAD_CNT)
+		NLA_PUT_U32(skb, XFRMA_SADCNT, si.sadcnt);
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
+		struct rtattr **xfrma)
+{
+	struct sk_buff *r_skb;
+	u32 *flags = NLMSG_DATA(nlh);
+	u32 spid = NETLINK_CB(skb).pid;
+	u32 seq = nlh->nlmsg_seq;
+	int len = NLMSG_LENGTH(sizeof(u32));
+
+	if (*flags & XFRM_SAD_HMASK)
+		len += RTA_SPACE(sizeof(u32));
+	if (*flags & XFRM_SAD_HMAX)
+		len += RTA_SPACE(sizeof(u32));
+	if (*flags & XFRM_SAD_CNT)
+		len += RTA_SPACE(sizeof(u32));
+
+	r_skb = alloc_skb(len, GFP_ATOMIC);
+
+	if (r_skb == NULL)
+		return -ENOMEM;
+
+	if (build_sadinfo(r_skb, spid, seq, *flags) < 0)
+		BUG();
+
+	return nlmsg_unicast(xfrm_nl, r_skb, spid);
+}
+
 static int xfrm_get_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct rtattr **xfrma)
 {
@@ -1850,6 +1905,7 @@ static struct xfrm_link {
 	[XFRM_MSG_NEWAE       - XFRM_MSG_BASE] = { .doit = xfrm_new_ae  },
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = { .doit = xfrm_get_ae  },
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = { .doit = xfrm_do_migrate    },
+	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_sadinfo    },
 };
 
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, int *errp)

--=-SmRQZDKGeQzg0dmZBA3H--

