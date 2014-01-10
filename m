From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 4/7] net_sched: optimize tcf_match_indev()
Date: Thu,  9 Jan 2014 16:14:02 -0800
Message-ID: <1389312845-10304-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:36706 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbaAJAOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:14:41 -0500
Received: by mail-pb0-f45.google.com with SMTP id rp16so3699698pbb.4
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:14:40 -0800 (PST)
In-Reply-To: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcf_match_indev() is called in fast path, it is not wise to
search for a netdev by ifindex and then compare by its name,
just compare the ifindex.

Also, dev->name could be changed by user-space, therefore
the match would be always fail, but dev->ifindex could
be consistent.

BTW, this will also save some bytes from the core struct of u32.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/pkt_cls.h | 30 +++++++++++++++---------------
 net/sched/cls_fw.c    | 19 ++++++++++++-------
 net/sched/cls_u32.c   | 19 ++++++++++++-------
 3 files changed, 39 insertions(+), 29 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 50ea079..a2441fb 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -338,27 +338,27 @@ static inline int tcf_valid_offset(const struct sk_buff *skb,
 #include <net/net_namespace.h>
 
 static inline int
-tcf_change_indev(struct tcf_proto *tp, char *indev, struct nlattr *indev_tlv)
+tcf_change_indev(struct net *net, struct nlattr *indev_tlv)
 {
+	char indev[IFNAMSIZ];
+	struct net_device *dev;
+
 	if (nla_strlcpy(indev, indev_tlv, IFNAMSIZ) >= IFNAMSIZ)
 		return -EINVAL;
-	return 0;
+	dev = __dev_get_by_name(net, indev);
+	if (!dev)
+		return -ENODEV;
+	return dev->ifindex;
 }
 
-static inline int
-tcf_match_indev(struct sk_buff *skb, char *indev)
+static inline bool
+tcf_match_indev(struct sk_buff *skb, int ifindex)
 {
-	struct net_device *dev;
-
-	if (indev[0]) {
-		if  (!skb->skb_iif)
-			return 0;
-		dev = __dev_get_by_index(dev_net(skb->dev), skb->skb_iif);
-		if (!dev || strcmp(indev, dev->name))
-			return 0;
-	}
-
-	return 1;
+	if (!ifindex)
+		return true;
+	if  (!skb->skb_iif)
+		return false;
+	return ifindex == skb->skb_iif;
 }
 #endif /* CONFIG_NET_CLS_IND */
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index d605285..ca662aa 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -41,7 +41,7 @@ struct fw_filter {
 	u32			id;
 	struct tcf_result	res;
 #ifdef CONFIG_NET_CLS_IND
-	char			indev[IFNAMSIZ];
+	int			ifindex;
 #endif /* CONFIG_NET_CLS_IND */
 	struct tcf_exts		exts;
 };
@@ -86,7 +86,7 @@ static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			if (f->id == id) {
 				*res = f->res;
 #ifdef CONFIG_NET_CLS_IND
-				if (!tcf_match_indev(skb, f->indev))
+				if (!tcf_match_indev(skb, f->ifindex))
 					continue;
 #endif /* CONFIG_NET_CLS_IND */
 				r = tcf_exts_exec(skb, &f->exts, res);
@@ -207,9 +207,11 @@ fw_change_attrs(struct net *net, struct tcf_proto *tp, struct fw_filter *f,
 
 #ifdef CONFIG_NET_CLS_IND
 	if (tb[TCA_FW_INDEV]) {
-		err = tcf_change_indev(tp, f->indev, tb[TCA_FW_INDEV]);
-		if (err < 0)
+		int ret;
+		ret = tcf_change_indev(net, tb[TCA_FW_INDEV]);
+		if (ret < 0)
 			goto errout;
+		f->ifindex = ret;
 	}
 #endif /* CONFIG_NET_CLS_IND */
 
@@ -348,9 +350,12 @@ static int fw_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 	    nla_put_u32(skb, TCA_FW_CLASSID, f->res.classid))
 		goto nla_put_failure;
 #ifdef CONFIG_NET_CLS_IND
-	if (strlen(f->indev) &&
-	    nla_put_string(skb, TCA_FW_INDEV, f->indev))
-		goto nla_put_failure;
+	if (f->ifindex) {
+		struct net_device *dev;
+		dev = __dev_get_by_index(net, f->ifindex);
+		if (dev && nla_put_string(skb, TCA_FW_INDEV, dev->name))
+			goto nla_put_failure;
+	}
 #endif /* CONFIG_NET_CLS_IND */
 	if (head->mask != 0xFFFFFFFF &&
 	    nla_put_u32(skb, TCA_FW_MASK, head->mask))
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index e25411a..f509b79 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -48,7 +48,7 @@ struct tc_u_knode {
 	struct tc_u_hnode	*ht_up;
 	struct tcf_exts		exts;
 #ifdef CONFIG_NET_CLS_IND
-	char                     indev[IFNAMSIZ];
+	int			ifindex;
 #endif
 	u8			fshift;
 	struct tcf_result	res;
@@ -152,7 +152,7 @@ check_terminal:
 
 				*res = n->res;
 #ifdef CONFIG_NET_CLS_IND
-				if (!tcf_match_indev(skb, n->indev)) {
+				if (!tcf_match_indev(skb, n->ifindex)) {
 					n = n->next;
 					goto next_knode;
 				}
@@ -527,9 +527,11 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 
 #ifdef CONFIG_NET_CLS_IND
 	if (tb[TCA_U32_INDEV]) {
-		err = tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV]);
-		if (err < 0)
+		int ret;
+		ret = tcf_change_indev(net, tb[TCA_U32_INDEV]);
+		if (ret < 0)
 			goto errout;
+		n->ifindex = ret;
 	}
 #endif
 	tcf_exts_change(tp, &n->exts, &e);
@@ -760,9 +762,12 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			goto nla_put_failure;
 
 #ifdef CONFIG_NET_CLS_IND
-		if (strlen(n->indev) &&
-		    nla_put_string(skb, TCA_U32_INDEV, n->indev))
-			goto nla_put_failure;
+		if (n->ifindex) {
+			struct net_device *dev;
+			dev = __dev_get_by_index(net, n->ifindex);
+			if (dev && nla_put_string(skb, TCA_U32_INDEV, dev->name))
+				goto nla_put_failure;
+		}
 #endif
 #ifdef CONFIG_CLS_U32_PERF
 		if (nla_put(skb, TCA_U32_PCNT,
-- 
1.8.3.1
