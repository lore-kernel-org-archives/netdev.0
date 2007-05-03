From: jamal <hadi@cyberus.ca>
Subject: [RESEND][PATCH][XFRM] SAD info TLV aggregation
Date: Thu, 03 May 2007 19:06:41 -0400
Message-ID: <1178233601.4068.2.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-xh7Ga5zMtpsQ/wbUVOSs"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:16947 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767423AbXECXGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 19:06:48 -0400
Received: by wx-out-0506.google.com with SMTP id h31so589474wxd
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 16:06:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-xh7Ga5zMtpsQ/wbUVOSs
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Ok, heres a resend of the SAD details with IPSEC and HASH info
separated. Against net-2.6
Dave, please apply.

cheers,
jamal


--=-xh7Ga5zMtpsQ/wbUVOSs
Content-Disposition: attachment; filename=xfrmk-sad-2622-2
Content-Type: text/plain; name=xfrmk-sad-2622-2; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] SAD info TLV aggregationx

Aggregate the SAD info TLVs.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit c157d47586129bc4cb8320217df9f80a4dea8b6f
tree 161b0ae239ab783e8df3a425e7cb58ac36d0fb8e
parent fc38582db98533066f4ba64f948720483fbfe7b2
author Jamal Hadi Salim <hadi@cyberus.ca> Thu, 03 May 2007 14:54:47 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Thu, 03 May 2007 14:54:47 -0400

 include/linux/xfrm.h  |   21 +++++++--------------
 include/net/xfrm.h    |   17 ++++++++---------
 net/xfrm/xfrm_state.c |    2 +-
 net/xfrm/xfrm_user.c  |   22 +++++++++-------------
 4 files changed, 25 insertions(+), 37 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index a5d53e0..81c95aa 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -243,17 +243,6 @@ enum xfrm_ae_ftype_t {
 #define XFRM_AE_MAX (__XFRM_AE_MAX - 1)
 };
 
-/* SAD Table filter flags  */
-enum xfrm_sad_ftype_t {
-	XFRM_SAD_UNSPEC,
-	XFRM_SAD_HMASK=1,
-	XFRM_SAD_HMAX=2,
-	XFRM_SAD_CNT=4,
-	__XFRM_SAD_MAX
-
-#define XFRM_SAD_MAX (__XFRM_SAD_MAX - 1)
-};
-
 struct xfrm_userpolicy_type {
 	__u8		type;
 	__u16		reserved1;
@@ -286,15 +275,19 @@ enum xfrm_attr_type_t {
 };
 
 enum xfrm_sadattr_type_t {
-	XFRMA_SAD_UNSPEC,
-	XFRMA_SADHMASK,
-	XFRMA_SADHMAX,
+	XFRMA_SADUNSPEC,
 	XFRMA_SADCNT,
+	XFRMA_SADHINFO,
 	__XFRMA_SAD_MAX
 
 #define XFRMA_SAD_MAX (__XFRMA_SAD_MAX - 1)
 };
 
+struct xfrmu_sadhinfo {
+	__u32 sadhcnt; /* current hash bkts */
+	__u32 sadhmcnt; /* max allowed hash bkts */
+};
+
 /* SPD Table filter flags  */
 enum xfrm_spd_ftype_t {
 	XFRM_SPD_UNSPEC,
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 66c2d3e..d0d7db5 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -416,14 +416,6 @@ struct xfrm_audit
 	u32	secid;
 };
 
-/* SAD metadata, add more later */
-struct xfrm_sadinfo
-{
-	u32 sadhcnt; /* current hash bkts */
-	u32 sadhmcnt; /* max allowed hash bkts */
-	u32 sadcnt; /* current running count */
-};
-
 struct xfrm_spdinfo
 {
 	u32 incnt;
@@ -964,10 +956,17 @@ static inline int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **s
 	return -ENOSYS;
 }
 #endif
+
+struct xfrmk_sadinfo {
+	u32 sadhcnt; /* current hash bkts */
+	u32 sadhmcnt; /* max allowed hash bkts */
+	u32 sadcnt; /* current running count */
+};
+
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
-extern void xfrm_sad_getinfo(struct xfrm_sadinfo *si);
+extern void xfrm_sad_getinfo(struct xfrmk_sadinfo *si);
 extern void xfrm_spd_getinfo(struct xfrm_spdinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f3a61eb..9955ff4 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -421,7 +421,7 @@ restart:
 }
 EXPORT_SYMBOL(xfrm_state_flush);
 
-void xfrm_sad_getinfo(struct xfrm_sadinfo *si)
+void xfrm_sad_getinfo(struct xfrmk_sadinfo *si)
 {
 	spin_lock_bh(&xfrm_state_lock);
 	si->sadcnt = xfrm_state_num;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4210d91..9220d14 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -749,7 +749,8 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 static int build_sadinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 {
-	struct xfrm_sadinfo si;
+	struct xfrmk_sadinfo si;
+	struct xfrmu_sadhinfo sh;
 	struct nlmsghdr *nlh;
 	u32 *f;
 
@@ -761,12 +762,11 @@ static int build_sadinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 	*f = flags;
 	xfrm_sad_getinfo(&si);
 
-	if (flags & XFRM_SAD_HMASK)
-		NLA_PUT_U32(skb, XFRMA_SADHMASK, si.sadhcnt);
-	if (flags & XFRM_SAD_HMAX)
-		NLA_PUT_U32(skb, XFRMA_SADHMAX, si.sadhmcnt);
-	if (flags & XFRM_SAD_CNT)
-		NLA_PUT_U32(skb, XFRMA_SADCNT, si.sadcnt);
+	sh.sadhmcnt = si.sadhmcnt;
+	sh.sadhcnt = si.sadhcnt;
+
+	NLA_PUT_U32(skb, XFRMA_SADCNT, si.sadcnt);
+	NLA_PUT(skb, XFRMA_SADHINFO, sizeof(sh), &sh);
 
 	return nlmsg_end(skb, nlh);
 
@@ -784,12 +784,8 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 seq = nlh->nlmsg_seq;
 	int len = NLMSG_LENGTH(sizeof(u32));
 
-	if (*flags & XFRM_SAD_HMASK)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SAD_HMAX)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SAD_CNT)
-		len += RTA_SPACE(sizeof(u32));
+	len += RTA_SPACE(sizeof(struct xfrmu_sadhinfo));
+	len += RTA_SPACE(sizeof(u32));
 
 	r_skb = alloc_skb(len, GFP_ATOMIC);
 

--=-xh7Ga5zMtpsQ/wbUVOSs--

