From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND][PATCH][XFRM] SAD info TLV aggregation
Date: Fri, 04 May 2007 20:10:44 +0200
Message-ID: <463B7724.8000300@trash.net>
References: <1178233601.4068.2.camel@localhost> <463A7BF7.5010604@trash.net> <1178239828.4068.52.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010905090701010706050800"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60927 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031492AbXEDSLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 14:11:13 -0400
In-Reply-To: <1178239828.4068.52.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010905090701010706050800
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

jamal wrote:
> On Fri, 2007-04-05 at 02:19 +0200, Patrick McHardy wrote:
> 
> 
>>If you dont mind I'm just going to resend myself with fixed
>>names tomorrow so you don't have to bother doing this again.
> 
> 
> If you have the cycles please go ahead. Otherwise i could do it
> in a couple of days.


Here they are, thanks for your patience :)

I've changed them to XFRMA_SAD_... and XFRMA_SPD_... since
UNSPEC and MAX are usually seperated by an underscore.


--------------010905090701010706050800
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[XFRM] SAD info TLV aggregationx

Aggregate the SAD info TLVs.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 430aa4b4ccb949b5efbf2651c1c2949f25f7cd75
tree 45c4576e94660d97d9d21bb28aee74ccef941571
parent db3459d1a71d885334831cdca6646a48f5ea0483
author Patrick McHardy <kaber@trash.net> Fri, 04 May 2007 20:07:49 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 04 May 2007 20:07:49 +0200

 include/linux/xfrm.h  |   21 +++++++--------------
 include/net/xfrm.h    |   17 ++++++++---------
 net/xfrm/xfrm_state.c |    2 +-
 net/xfrm/xfrm_user.c  |   22 +++++++++-------------
 4 files changed, 25 insertions(+), 37 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index a5d53e0..c237fe3 100644
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
+	XFRMA_SAD_CNT,
+	XFRMA_SAD_HINFO,
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
index 4210d91..c35b9ea 100644
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
+	NLA_PUT_U32(skb, XFRMA_SAD_CNT, si.sadcnt);
+	NLA_PUT(skb, XFRMA_SAD_HINFO, sizeof(sh), &sh);
 
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
 

--------------010905090701010706050800
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[XFRM] SPD info TLV aggregation

Aggregate the SPD info TLVs.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 572b08f6ad7d473edd282fd40ceadbb4dce522a2
tree 0238946f1db4f2b83dbbd2df6b4db8245fa8cf65
parent 430aa4b4ccb949b5efbf2651c1c2949f25f7cd75
author Patrick McHardy <kaber@trash.net> Fri, 04 May 2007 20:08:07 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 04 May 2007 20:08:07 +0200

 include/linux/xfrm.h   |   39 +++++++++++++++----------------------
 include/net/xfrm.h     |   24 +++++++++++------------
 net/xfrm/xfrm_policy.c |    2 +-
 net/xfrm/xfrm_user.c   |   51 +++++++++++++++---------------------------------
 4 files changed, 45 insertions(+), 71 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index c237fe3..b58adc5 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -288,36 +288,29 @@ struct xfrmu_sadhinfo {
 	__u32 sadhmcnt; /* max allowed hash bkts */
 };
 
-/* SPD Table filter flags  */
-enum xfrm_spd_ftype_t {
-	XFRM_SPD_UNSPEC,
-	XFRM_SPD_HMASK=1,
-	XFRM_SPD_HMAX=2,
-	XFRM_SPD_ICNT=4,
-	XFRM_SPD_OCNT=8,
-	XFRM_SPD_FCNT=16,
-	XFRM_SPD_ISCNT=32,
-	XFRM_SPD_OSCNT=64,
-	XFRM_SPD_FSCNT=128,
-	__XFRM_SPD_MAX
-
-#define XFRM_SPD_MAX (__XFRM_SPD_MAX - 1)
-};
 enum xfrm_spdattr_type_t {
 	XFRMA_SPD_UNSPEC,
-	XFRMA_SPDHMASK,
-	XFRMA_SPDHMAX,
-	XFRMA_SPDICNT,
-	XFRMA_SPDOCNT,
-	XFRMA_SPDFCNT,
-	XFRMA_SPDISCNT,
-	XFRMA_SPDOSCNT,
-	XFRMA_SPDFSCNT,
+	XFRMA_SPD_INFO,
+	XFRMA_SPD_HINFO,
 	__XFRMA_SPD_MAX
 
 #define XFRMA_SPD_MAX (__XFRMA_SPD_MAX - 1)
 };
 
+struct xfrmu_spdinfo {
+	__u32 incnt;
+	__u32 outcnt;
+	__u32 fwdcnt;
+	__u32 inscnt;
+	__u32 outscnt;
+	__u32 fwdscnt;
+};
+
+struct xfrmu_spdhinfo {
+	__u32 spdhcnt;
+	__u32 spdhmcnt;
+};
+
 struct xfrm_usersa_info {
 	struct xfrm_selector		sel;
 	struct xfrm_id			id;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index d0d7db5..39ef925 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -416,17 +416,6 @@ struct xfrm_audit
 	u32	secid;
 };
 
-struct xfrm_spdinfo
-{
-	u32 incnt;
-	u32 outcnt;
-	u32 fwdcnt;
-	u32 inscnt;
-	u32 outscnt;
-	u32 fwdscnt;
-	u32 spdhcnt;
-	u32 spdhmcnt;
-};
 #ifdef CONFIG_AUDITSYSCALL
 extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
 		    struct xfrm_policy *xp, struct xfrm_state *x);
@@ -963,11 +952,22 @@ struct xfrmk_sadinfo {
 	u32 sadcnt; /* current running count */
 };
 
+struct xfrmk_spdinfo {
+	u32 incnt;
+	u32 outcnt;
+	u32 fwdcnt;
+	u32 inscnt;
+	u32 outscnt;
+	u32 fwdscnt;
+	u32 spdhcnt;
+	u32 spdhmcnt;
+};
+
 extern struct xfrm_state *xfrm_find_acq_byseq(u32 seq);
 extern int xfrm_state_delete(struct xfrm_state *x);
 extern void xfrm_state_flush(u8 proto, struct xfrm_audit *audit_info);
 extern void xfrm_sad_getinfo(struct xfrmk_sadinfo *si);
-extern void xfrm_spd_getinfo(struct xfrm_spdinfo *si);
+extern void xfrm_spd_getinfo(struct xfrmk_spdinfo *si);
 extern int xfrm_replay_check(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_advance(struct xfrm_state *x, __be32 seq);
 extern void xfrm_replay_notify(struct xfrm_state *x, int event);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 263e34e..95271e8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -579,7 +579,7 @@ static inline int xfrm_byidx_should_resize(int total)
 	return 0;
 }
 
-void xfrm_spd_getinfo(struct xfrm_spdinfo *si)
+void xfrm_spd_getinfo(struct xfrmk_spdinfo *si)
 {
 	read_lock_bh(&xfrm_policy_lock);
 	si->incnt = xfrm_policy_count[XFRM_POLICY_IN];
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index c35b9ea..b14c7e5 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -674,7 +674,9 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 
 static int build_spdinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 {
-	struct xfrm_spdinfo si;
+	struct xfrmk_spdinfo si;
+	struct xfrmu_spdinfo spc;
+	struct xfrmu_spdhinfo sph;
 	struct nlmsghdr *nlh;
 	u32 *f;
 
@@ -685,23 +687,17 @@ static int build_spdinfo(struct sk_buff *skb, u32 pid, u32 seq, u32 flags)
 	f = nlmsg_data(nlh);
 	*f = flags;
 	xfrm_spd_getinfo(&si);
-
-	if (flags & XFRM_SPD_HMASK)
-		NLA_PUT_U32(skb, XFRMA_SPDHMASK, si.spdhcnt);
-	if (flags & XFRM_SPD_HMAX)
-		NLA_PUT_U32(skb, XFRMA_SPDHMAX, si.spdhmcnt);
-	if (flags & XFRM_SPD_ICNT)
-		NLA_PUT_U32(skb, XFRMA_SPDICNT, si.incnt);
-	if (flags & XFRM_SPD_OCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDOCNT, si.outcnt);
-	if (flags & XFRM_SPD_FCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDFCNT, si.fwdcnt);
-	if (flags & XFRM_SPD_ISCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDISCNT, si.inscnt);
-	if (flags & XFRM_SPD_OSCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDOSCNT, si.inscnt);
-	if (flags & XFRM_SPD_FSCNT)
-		NLA_PUT_U32(skb, XFRMA_SPDFSCNT, si.inscnt);
+	spc.incnt = si.incnt;
+	spc.outcnt = si.outcnt;
+	spc.fwdcnt = si.fwdcnt;
+	spc.inscnt = si.inscnt;
+	spc.outscnt = si.outscnt;
+	spc.fwdscnt = si.fwdscnt;
+	sph.spdhcnt = si.spdhcnt;
+	sph.spdhmcnt = si.spdhmcnt;
+
+	NLA_PUT(skb, XFRMA_SPD_INFO, sizeof(spc), &spc);
+	NLA_PUT(skb, XFRMA_SPD_HINFO, sizeof(sph), &sph);
 
 	return nlmsg_end(skb, nlh);
 
@@ -719,23 +715,8 @@ static int xfrm_get_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
 	u32 seq = nlh->nlmsg_seq;
 	int len = NLMSG_LENGTH(sizeof(u32));
 
-
-	if (*flags & XFRM_SPD_HMASK)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_HMAX)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_ICNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_OCNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_FCNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_ISCNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_OSCNT)
-		len += RTA_SPACE(sizeof(u32));
-	if (*flags & XFRM_SPD_FSCNT)
-		len += RTA_SPACE(sizeof(u32));
+	len += RTA_SPACE(sizeof(struct xfrmu_spdinfo));
+	len += RTA_SPACE(sizeof(struct xfrmu_spdhinfo));
 
 	r_skb = alloc_skb(len, GFP_ATOMIC);
 	if (r_skb == NULL)

--------------010905090701010706050800--
