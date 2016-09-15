From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next 1/2] net sched ife action: add 16 bit helpers
Date: Thu, 15 Sep 2016 06:49:53 -0400
Message-ID: <1473936594-5152-1-git-send-email-jhs@emojatatu.com>
Cc: daniel@iogearbox.net, xiyou.wangcong@gmail.com,
        netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34849 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755183AbcIOKuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 06:50:03 -0400
Received: by mail-it0-f65.google.com with SMTP id e20so4093278itc.2
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 03:50:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

encoder and checker for 16 bits metadata

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/tc_act/tc_ife.h |  2 ++
 net/sched/act_ife.c         | 26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/net/tc_act/tc_ife.h b/include/net/tc_act/tc_ife.h
index 5164bd7..9fd2bea0 100644
--- a/include/net/tc_act/tc_ife.h
+++ b/include/net/tc_act/tc_ife.h
@@ -50,9 +50,11 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen,
 int ife_alloc_meta_u32(struct tcf_meta_info *mi, void *metaval, gfp_t gfp);
 int ife_alloc_meta_u16(struct tcf_meta_info *mi, void *metaval, gfp_t gfp);
 int ife_check_meta_u32(u32 metaval, struct tcf_meta_info *mi);
+int ife_check_meta_u16(u16 metaval, struct tcf_meta_info *mi);
 int ife_encode_meta_u32(u32 metaval, void *skbdata, struct tcf_meta_info *mi);
 int ife_validate_meta_u32(void *val, int len);
 int ife_validate_meta_u16(void *val, int len);
+int ife_encode_meta_u16(u16 metaval, void *skbdata, struct tcf_meta_info *mi);
 void ife_release_meta_gen(struct tcf_meta_info *mi);
 int register_ife_op(struct tcf_meta_ops *mops);
 int unregister_ife_op(struct tcf_meta_ops *mops);
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index e87cd81..ccf7b4b 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -63,6 +63,23 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
 }
 EXPORT_SYMBOL_GPL(ife_tlv_meta_encode);
 
+int ife_encode_meta_u16(u16 metaval, void *skbdata, struct tcf_meta_info *mi)
+{
+	u16 edata = 0;
+
+	if (mi->metaval)
+		edata = *(u16 *)mi->metaval;
+	else if (metaval)
+		edata = metaval;
+
+	if (!edata) /* will not encode */
+		return 0;
+
+	edata = htons(edata);
+	return ife_tlv_meta_encode(skbdata, mi->metaid, 2, &edata);
+}
+EXPORT_SYMBOL_GPL(ife_encode_meta_u16);
+
 int ife_get_meta_u32(struct sk_buff *skb, struct tcf_meta_info *mi)
 {
 	if (mi->metaval)
@@ -81,6 +98,15 @@ int ife_check_meta_u32(u32 metaval, struct tcf_meta_info *mi)
 }
 EXPORT_SYMBOL_GPL(ife_check_meta_u32);
 
+int ife_check_meta_u16(u16 metaval, struct tcf_meta_info *mi)
+{
+	if (metaval || mi->metaval)
+		return 8; /* T+L+(V) == 2+2+(2+2bytepad) */
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ife_check_meta_u16);
+
 int ife_encode_meta_u32(u32 metaval, void *skbdata, struct tcf_meta_info *mi)
 {
 	u32 edata = metaval;
-- 
1.9.1
