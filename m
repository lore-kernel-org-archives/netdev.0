From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net 1/1] net sched ife action: fix encoding to use real length
Date: Fri, 19 Aug 2016 06:17:40 -0400
Message-ID: <1471601860-3336-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, mrv@mojatatu.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33787 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752581AbcHSKgM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 06:36:12 -0400
Received: by mail-it0-f67.google.com with SMTP id d65so1229222ith.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 03:36:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Encoding of the metadata was using the padded length as opposed to
the real length of the data which is a bug per specification.
This has not been an issue todate because all metadatum specified
so far has been 32 bit where aligned and data length are the same width.
This also includes a bug fix for validating the length of a u16 field.
But since there is no metadata of size u16 yes we are fine to include it
here.

While at it get rid of magic numbers

Fixes: ef6980b6

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_ife.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 141a06e..e87cd81 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -53,7 +53,7 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
 	u32 *tlv = (u32 *)(skbdata);
 	u16 totlen = nla_total_size(dlen);	/*alignment + hdr */
 	char *dptr = (char *)tlv + NLA_HDRLEN;
-	u32 htlv = attrtype << 16 | totlen;
+	u32 htlv = attrtype << 16 | dlen;
 
 	*tlv = htonl(htlv);
 	memset(dptr, 0, totlen - NLA_HDRLEN);
@@ -135,7 +135,7 @@ EXPORT_SYMBOL_GPL(ife_release_meta_gen);
 
 int ife_validate_meta_u32(void *val, int len)
 {
-	if (len == 4)
+	if (len == sizeof(u32))
 		return 0;
 
 	return -EINVAL;
@@ -144,8 +144,8 @@ EXPORT_SYMBOL_GPL(ife_validate_meta_u32);
 
 int ife_validate_meta_u16(void *val, int len)
 {
-	/* length will include padding */
-	if (len == NLA_ALIGN(2))
+	/* length will not include padding */
+	if (len == sizeof(u16))
 		return 0;
 
 	return -EINVAL;
@@ -652,12 +652,14 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 		u8 *tlvdata = (u8 *)tlv;
 		u16 mtype = tlv->type;
 		u16 mlen = tlv->len;
+		u16 alen;
 
 		mtype = ntohs(mtype);
 		mlen = ntohs(mlen);
+		alen = NLA_ALIGN(mlen);
 
-		if (find_decode_metaid(skb, ife, mtype, (mlen - 4),
-				       (void *)(tlvdata + 4))) {
+		if (find_decode_metaid(skb, ife, mtype, (mlen - NLA_HDRLEN),
+				       (void *)(tlvdata + NLA_HDRLEN))) {
 			/* abuse overlimits to count when we receive metadata
 			 * but dont have an ops for it
 			 */
@@ -666,8 +668,8 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 			ife->tcf_qstats.overlimits++;
 		}
 
-		tlvdata += mlen;
-		ifehdrln -= mlen;
+		tlvdata += alen;
+		ifehdrln -= alen;
 		tlv = (struct meta_tlvhdr *)tlvdata;
 	}
 
-- 
1.9.1
