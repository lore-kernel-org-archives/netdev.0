From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: Fix cls indev validation
Date: Sun, 19 Dec 2004 21:30:50 +0100
Message-ID: <20041219203050.GK17998@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

This patch is actually part of a patchset for 2.6.11 inclusion
but the memory corruption possibility might make it worth
for 2.6.10. It's not really dangerous since it requires
admin capabilities though.

Puts the indev validation into its own function to allow
parameter validation before any changes are made. Changes
the sanity check from >= IFNAMSIZ to > IFNAMSIZ to correctly
handle 0 terminated strings and replaces the dangerous sprintf
with a memcpy bound to the TLV size. Providing a indev TLV
for kernels without CONFIG_NET_CLS_IND support will now lead
to EOPPNOTSUPP.

The sprintf could have been abused to overwrite memory after
the indev attribute if the TLV data was not 0 terminated.
(Bound to a few limitations, e.g.  it would have to contain a
rta header at RTA_ALIGN(IFNAMSIZ)+1 etc.)

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc3-bk7.orig/include/net/pkt_cls.h	2004-12-14 14:24:04.000000000 +0100
+++ linux-2.6.10-rc3-bk7/include/net/pkt_cls.h	2004-12-14 14:54:41.000000000 +0100
@@ -160,19 +160,25 @@
 
 #ifdef CONFIG_NET_CLS_IND
 static inline int
-tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
+tcf_validate_indev(struct rtattr *indev_tlv)
 {
-	if (RTA_PAYLOAD(indev_tlv) >= IFNAMSIZ) {
-		printk("cls: bad indev name %s\n", (char *) RTA_DATA(indev_tlv));
+	if (indev_tlv && RTA_PAYLOAD(indev_tlv) > IFNAMSIZ) {
+		if (net_ratelimit())
+			printk("cls: bad indev name %s\n", (char *) RTA_DATA(indev_tlv));
 		return -EINVAL;
 	}
 
-	memset(indev, 0, IFNAMSIZ);
-	sprintf(indev, "%s", (char *) RTA_DATA(indev_tlv));
-
 	return 0;
 }
 
+static inline void
+tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *id_tlv)
+{
+	memset(indev, 0, IFNAMSIZ);
+	memcpy(indev, RTA_DATA(id_tlv), RTA_PAYLOAD(id_tlv));
+	indev[IFNAMSIZ - 1] = '\0';
+}
+
 static inline int
 tcf_match_indev(struct sk_buff *skb, char *indev)
 {
@@ -185,6 +191,12 @@
 
 	return 1;
 }
+#else /* CONFIG_NET_CLS_IND */
+static inline int
+tcf_validate_indev(struct rtattr *indev_tlv)
+{
+	return indev_tlv ? -EOPNOTSUPP : 0;
+}
 #endif /* CONFIG_NET_CLS_IND */
 
 #ifdef CONFIG_NET_CLS_POLICE
--- linux-2.6.10-rc3-bk7.orig/net/sched/cls_u32.c	2004-12-14 14:24:34.000000000 +0100
+++ linux-2.6.10-rc3-bk7/net/sched/cls_u32.c	2004-12-14 14:55:18.000000000 +0100
@@ -488,6 +488,12 @@
 			 struct tc_u_knode *n, struct rtattr **tb,
 			 struct rtattr *est)
 {
+	int err;
+
+	err = tcf_validate_indev(tb[TCA_U32_INDEV-1]);
+	if (err < 0)
+		return err;
+
 	if (tb[TCA_U32_LINK-1]) {
 		u32 handle = *(u32*)RTA_DATA(tb[TCA_U32_LINK-1]);
 		struct tc_u_hnode *ht_down = NULL;
@@ -535,12 +541,10 @@
 	}
 #endif
 #endif
+
 #ifdef CONFIG_NET_CLS_IND
-	if (tb[TCA_U32_INDEV-1]) {
-		int err = tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV-1]);
-		if (err < 0)
-			return err;
-	}
+	if (tb[TCA_U32_INDEV-1])
+		tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV-1]);
 #endif
 
 	return 0;
--- linux-2.6.10-rc3-bk7.orig/net/sched/cls_fw.c	2004-12-14 14:24:34.000000000 +0100
+++ linux-2.6.10-rc3-bk7/net/sched/cls_fw.c	2004-12-14 14:33:50.000000000 +0100
@@ -208,21 +208,24 @@
 fw_change_attrs(struct tcf_proto *tp, struct fw_filter *f,
 	struct rtattr **tb, struct rtattr **tca, unsigned long base)
 {
-	int err = -EINVAL;
+	int err;
+
+	err = tcf_validate_indev(tb[TCA_FW_INDEV-1]);
+	if (err < 0)
+		goto errout;
 
 	if (tb[TCA_FW_CLASSID-1]) {
-		if (RTA_PAYLOAD(tb[TCA_FW_CLASSID-1]) != sizeof(u32))
+		if (RTA_PAYLOAD(tb[TCA_FW_CLASSID-1]) != sizeof(u32)) {
+			err = -EINVAL;
 			goto errout;
+		}
 		f->res.classid = *(u32*)RTA_DATA(tb[TCA_FW_CLASSID-1]);
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
 #ifdef CONFIG_NET_CLS_IND
-	if (tb[TCA_FW_INDEV-1]) {
-		err = tcf_change_indev(tp, f->indev, tb[TCA_FW_INDEV-1]);
-		if (err < 0)
-			goto errout;
-	}
+	if (tb[TCA_FW_INDEV-1])
+		tcf_change_indev(tp, f->indev, tb[TCA_FW_INDEV-1]);
 #endif /* CONFIG_NET_CLS_IND */
 
 #ifdef CONFIG_NET_CLS_ACT
