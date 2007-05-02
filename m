From: jamal <hadi@cyberus.ca>
Subject: [PATCH][XFRM] SAD info TLV aggregation
Date: Wed, 02 May 2007 18:18:08 -0400
Message-ID: <1178144288.4078.5.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-aNYBELoNqVFtKhBgje4o"
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:7214 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993194AbXEBWSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 18:18:14 -0400
Received: by wx-out-0506.google.com with SMTP id h31so269127wxd
        for <netdev@vger.kernel.org>; Wed, 02 May 2007 15:18:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-aNYBELoNqVFtKhBgje4o
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Dave,
against net-2.6.22.

I am keeping the thin 32 bit header, but other than that everything is
in one TLV. SPD info one to follow..

cheers,
jamal



--=-aNYBELoNqVFtKhBgje4o
Content-Disposition: attachment; filename=xfrmk-sad-2622-1
Content-Type: text/plain; name=xfrmk-sad-2622-1; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] SAD info TLV aggregationx

Aggregate the SAD info TLVs.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 48d8642f8e49b2c4e249858a65bf760ac03a4be7
tree 0041377be49d157d18de8b5abff13f93222f14cc
parent f0b0a76736fa63b21b1658ed514ecd67d39e485e
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 02 May 2007 14:43:05 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Wed, 02 May 2007 14:43:05 -0400

 include/linux/xfrm.h  |   21 +++++++--------------
 include/net/xfrm.h    |   10 +---------
 net/xfrm/xfrm_state.c |    2 +-
 net/xfrm/xfrm_user.c  |   16 +++-------------
 4 files changed, 12 insertions(+), 37 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index a5d53e0..31e2a2a 100644
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
@@ -287,14 +276,18 @@ enum xfrm_attr_type_t {
 
 enum xfrm_sadattr_type_t {
 	XFRMA_SAD_UNSPEC,
-	XFRMA_SADHMASK,
-	XFRMA_SADHMAX,
-	XFRMA_SADCNT,
+	XFRMA_SADINFO,
 	__XFRMA_SAD_MAX
 
 #define XFRMA_SAD_MAX (__XFRMA_SAD_MAX - 1)
 };
 
+struct xfrmu_sadinfo {
+	__u32 sadhcnt; /* current hash bkts */
+	__u32 sadhmcnt; /* max allowed hash bkts */
+	__u32 sadcnt; /* current running count */
+};
+
 /* SPD Table filter flags  */
 enum xfrm_spd_ftype_t {
 	XFRM_SPD_UNSPEC,
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 66c2d3e..d3551b2 100644
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
@@ -967,7 +959,7 @@ static inline int xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **s
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
-extern void xfrm_sad_getinfo(struct xfrm_sadinfo *si);
+extern void xfrm_sad_getinfo(struct xfrmu_sadinfo *si);
 extern void xfrm_spd_getinfo(struct xfrm_spdinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f3a61eb..e5e7b0f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -421,7 +421,7 @@ restart:
 }
 EXPORT_SYMBOL(xfrm_state_flush);
 
-void xfrm_sad_getinfo(struct xfrm_sadinfo *si)
+void xfrm_sad_getinfo(struct xfrmu_sadinfo *si)
 {
 	spin_lock_bh(&xfrm_state_lock);
 	si->sadcnt = xfrm_state_num;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4210d91..0d98955 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -749,7 +749,7 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 static int build_sadinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 {
-	struct xfrm_sadinfo si;
+	struct xfrmu_sadinfo si;
 	struct nlmsghdr *nlh;
 	u32 *f;
 
@@ -761,12 +761,7 @@ static int build_sadinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 	*f = flags;
 	xfrm_sad_getinfo(&si);
 
-	if (flags & XFRM_SAD_HMASK)
-		NLA_PUT_U32(skb, XFRMA_SADHMASK, si.sadhcnt);
-	if (flags & XFRM_SAD_HMAX)
-		NLA_PUT_U32(skb, XFRMA_SADHMAX, si.sadhmcnt);
-	if (flags & XFRM_SAD_CNT)
-		NLA_PUT_U32(skb, XFRMA_SADCNT, si.sadcnt);
+	NLA_PUT(skb, XFRMA_SADINFO, sizeof(si), &si);
 
 	return nlmsg_end(skb, nlh);
 
@@ -784,12 +779,7 @@ static int xfrm_get_sadinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 seq = nlh->nlmsg_seq;
 	int len = NLMSG_LENGTH(sizeof(u32));
 
-	if (*flags & XFRM_SAD_HMASK)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SAD_HMAX)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SAD_CNT)
-		len += RTA_SPACE(sizeof(u32));
+	len += RTA_SPACE(sizeof(struct xfrmu_sadinfo));
 
 	r_skb = alloc_skb(len, GFP_ATOMIC);
 

--=-aNYBELoNqVFtKhBgje4o--

