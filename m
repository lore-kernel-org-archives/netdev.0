From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: Add mask support to fwmark classifier
Date: Fri, 25 Aug 2006 12:29:16 +0200
Message-ID: <44EED0FC.4050108@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020502020304000507000207"
Cc: jamal <hadi@cyberus.ca>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42402 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932394AbWHYK3U
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 06:29:20 -0400
To: Linux Netdev List <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020502020304000507000207
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

This patch adds support to mask the nfmark value before the lookup
the the fw classifier. Unfortunately it has some drawbacks, so I'd
be interested if anyone can think of a better way.

The problem is that in order to avoid walking through all filters
contained in one instance, we need to mask the value before the
lookup. This means all filters share the same mask, which is
taken from the first filter created and stored in the filter head.
The user interface however always refers to a single filter,
not the head, so it can't be changed afterwards unless we just
overwrite it whenever a new filter is installed. Both is not
really perfect. The current patch doesn't allow to change the
mark and enforces that all filters use the same one, which I think
is better than allowing inconsistent configurations.

Any better ideas?


--------------020502020304000507000207
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: Add mask support to fwmark classifier

Support masking the nfmark value before the search. The mask value is
global for all filters contained in one instance. It can only be set
when a new instance is created, all filters must specify the same mask.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c7dff54dc2dca206ff54f66bfce290c49f98a3c8
tree 88d48096f13674f29413dc5c9853c7d0a8c5feac
parent e5d8ce21a2261f73b078d802bd2ab3508153b177
author Patrick McHardy <kaber@trash.net> Fri, 25 Aug 2006 12:03:19 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 25 Aug 2006 12:03:19 +0200

 include/linux/pkt_cls.h |    1 +
 net/sched/cls_fw.c      |   25 ++++++++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index bd2c5a2..c3f01b3 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -305,6 +305,7 @@ enum
 	TCA_FW_POLICE,
 	TCA_FW_INDEV, /*  used by CONFIG_NET_CLS_IND */
 	TCA_FW_ACT, /* used by CONFIG_NET_CLS_ACT */
+	TCA_FW_MASK,
 	__TCA_FW_MAX
 };
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index e6973d9..c9385dc 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -50,6 +50,7 @@ #define HTSIZE (PAGE_SIZE/sizeof(struct 
 struct fw_head
 {
 	struct fw_filter *ht[HTSIZE];
+	u32 mask;
 };
 
 struct fw_filter
@@ -101,7 +102,7 @@ static int fw_classify(struct sk_buff *s
 	struct fw_filter *f;
 	int r;
 #ifdef CONFIG_NETFILTER
-	u32 id = skb->nfmark;
+	u32 id = skb->nfmark & head->mask;
 #else
 	u32 id = 0;
 #endif
@@ -209,7 +210,9 @@ static int
 fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
 	struct rtattr **tb, struct rtattr **tca, unsigned long base)
 {
+	struct fw_head *head = (struct fw_head*)tp->root;
 	struct tcf_exts e;
+	u32 mask;
 	int err;
 
 	err = tcf_exts_validate(tp, tb, tca[TCA_RATE-1], &e, &fw_ext_map);
@@ -232,6 +235,15 @@ #ifdef CONFIG_NET_CLS_IND
 	}
 #endif /* CONFIG_NET_CLS_IND */
 
+	if (tb[TCA_FW_MASK-1]) {
+		if (RTA_PAYLOAD(tb[TCA_FW_MASK-1]) != sizeof(u32))
+			goto errout;
+		mask = *(u32*)RTA_DATA(tb[TCA_FW_MASK-1]);
+		if (mask != head->mask)
+			goto errout;
+	} else if (head->mask != 0xFFFFFFFF)
+		goto errout;
+
 	tcf_exts_change(tp, &f->exts, &e);
 
 	return 0;
@@ -267,9 +279,17 @@ static int fw_change(struct tcf_proto *t
 		return -EINVAL;
 
 	if (head == NULL) {
+		u32 mask = 0xFFFFFFFF;
+		if (tb[TCA_FW_MASK-1]) {
+			if (RTA_PAYLOAD(tb[TCA_FW_MASK-1]) != sizeof(u32))
+				return -EINVAL;
+			mask = *(u32*)RTA_DATA(tb[TCA_FW_MASK-1]);
+		}
+
 		head = kzalloc(sizeof(struct fw_head), GFP_KERNEL);
 		if (head == NULL)
 			return -ENOBUFS;
+		head->mask = mask;
 
 		tcf_tree_lock(tp);
 		tp->root = head;
@@ -330,6 +350,7 @@ static void fw_walk(struct tcf_proto *tp
 static int fw_dump(struct tcf_proto *tp, unsigned long fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
+	struct fw_head *head = (struct fw_head *)tp->root;
 	struct fw_filter *f = (struct fw_filter*)fh;
 	unsigned char	 *b = skb->tail;
 	struct rtattr *rta;
@@ -351,6 +372,8 @@ #ifdef CONFIG_NET_CLS_IND
 	if (strlen(f->indev))
 		RTA_PUT(skb, TCA_FW_INDEV, IFNAMSIZ, f->indev);
 #endif /* CONFIG_NET_CLS_IND */
+	if (head->mask != 0xFFFFFFFF)
+		RTA_PUT(skb, TCA_FW_MASK, 4, &head->mask);
 
 	if (tcf_exts_dump(skb, &f->exts, &fw_ext_map) < 0)
 		goto rtattr_failure;

--------------020502020304000507000207--
