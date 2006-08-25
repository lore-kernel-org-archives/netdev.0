From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: Add mask support to fwmark classifier
Date: Fri, 25 Aug 2006 14:14:18 +0200
Message-ID: <44EEE99A.2030205@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020801070004020803000508"
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38569 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751470AbWHYMOV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 08:14:21 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020801070004020803000508
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------020801070004020803000508
Content-Type: text/plain;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

[NET_SCHED]: Add mask support to fwmark classifier

Support masking the nfmark value before the search. The mask value is
global for all filters contained in one instance. It can only be set
when a new instance is created, all filters must specify the same mask.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 734b411074d5cdb6cf1d85c7460f63730fe958f6
tree 4324105ebc0a46250cc564ecbfa3f11b8dba4369
parent bcd4f6996453aaf0a8d5515dcc533115621c961f
author Patrick McHardy <kaber@trash.net> Fri, 25 Aug 2006 14:01:20 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 25 Aug 2006 14:01:20 +0200

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
index e6973d9..e54acc6 100644
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
+	struct fw_head *head = (struct fw_head *)tp->root;
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

--------------020801070004020803000508--
