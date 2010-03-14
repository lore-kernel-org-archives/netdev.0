From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6 1/3 (TAKE 3)] ipv6 mcast: Introduce include/net/mld.h for MLD definitions.
Date: Sun, 14 Mar 2010 13:47:16 +0900
Message-ID: <201004080611.o386BUQx014996@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60032 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab0DHGLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 02:11:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/mld.h |   75 +++++++++++++++++++++++++++++
 net/ipv6/mcast.c  |  135 ++++++++++++++++-------------------------------------
 2 files changed, 115 insertions(+), 95 deletions(-)
 create mode 100644 include/net/mld.h

diff --git a/include/net/mld.h b/include/net/mld.h
new file mode 100644
index 0000000..ecc7553
--- /dev/null
+++ b/include/net/mld.h
@@ -0,0 +1,75 @@
+#ifndef LINUX_MLD_H
+#define LINUX_MLD_H
+
+#include <linux/in6.h>
+#include <linux/icmpv6.h>
+
+/* MLDv1 Query/Report/Done */
+struct mld_msg {
+	struct icmp6hdr		mld_hdr;
+	struct in6_addr		mld_mca;
+};
+
+#define mld_type		mld_hdr.icmp6_type
+#define mld_code		mld_hdr.icmp6_code
+#define mld_cksum		mld_hdr.icmp6_cksum
+#define mld_maxdelay		mld_hdr.icmp6_maxdelay
+#define mld_reserved		mld_hdr.icmp6_dataun.un_data16[1]
+
+/* Multicast Listener Discovery version 2 headers */
+/* MLDv2 Report */
+struct mld2_grec {
+	__u8		grec_type;
+	__u8		grec_auxwords;
+	__be16		grec_nsrcs;
+	struct in6_addr	grec_mca;
+	struct in6_addr	grec_src[0];
+};
+
+struct mld2_report {
+	struct icmp6hdr		mld2r_hdr;
+	struct mld2_grec	mld2r_grec[0];
+};
+
+#define mld2r_type		mld2r_hdr.icmp6_type
+#define mld2r_resv1		mld2r_hdr.icmp6_code
+#define	mld2r_cksum		mld2r_hdr.icmp6_cksum
+#define mld2r_resv2		mld2r_hdr.icmp6_dataun.un_data16[0]
+#define mld2r_ngrec		mld2r_hdr.icmp6_dataun.un_data16[1]
+
+/* MLDv2 Query */
+struct mld2_query {
+	struct icmp6hdr		mld2q_hdr;
+	struct in6_addr		mld2q_mca;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8			mld2q_qrv:3,
+				mld2q_suppress:1,
+				mld2q_resv2:4;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	__u8			mld2q_resv2:4,
+				mld2q_suppress:1,
+				mld2q_qrv:3;
+#else
+#error "Please fix <asm/byteorder.h>"
+#endif
+	__u8			mld2q_qqic;
+	__be16			mld2q_nsrcs;
+	struct in6_addr		mld2q_srcs[0];
+};
+
+#define	mld2q_type		mld2q_hdr.icmp6_type
+#define	mld2q_code		mld2q_hdr.icmp6_code
+#define mld2q_cksum		mld2q_hdr.icmp6_cksum
+#define mld2q_mrc		mld2q_hdr.icmp6_maxdelay
+#define mld2q_resv1		mld2q_hdr.icmp6_dataun.un_data16[1]
+
+/* Max Response Code */
+#define MLDV2_MASK(value, nb) ((nb)>=32 ? (value) : ((1<<(nb))-1) & (value))
+#define MLDV2_EXP(thresh, nbmant, nbexp, value) \
+	((value) < (thresh) ? (value) : \
+	((MLDV2_MASK(value, nbmant) | (1<<(nbmant))) << \
+	(MLDV2_MASK((value) >> (nbmant), nbexp) + (nbexp))))
+
+#define MLDV2_MRC(value) MLDV2_EXP(0x8000, 12, 3, value)
+
+#endif
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 37d1868..d951797 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -43,6 +43,7 @@
 #include <linux/init.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <net/mld.h>
 
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
@@ -70,54 +71,11 @@
 #define MDBG(x)
 #endif
 
-/*
- *  These header formats should be in a separate include file, but icmpv6.h
- *  doesn't have in6_addr defined in all cases, there is no __u128, and no
- *  other files reference these.
- *
- *  			+-DLS 4/14/03
- */
-
-/* Multicast Listener Discovery version 2 headers */
-
-struct mld2_grec {
-	__u8		grec_type;
-	__u8		grec_auxwords;
-	__be16		grec_nsrcs;
-	struct in6_addr	grec_mca;
-	struct in6_addr	grec_src[0];
-};
-
-struct mld2_report {
-	__u8	type;
-	__u8	resv1;
-	__sum16	csum;
-	__be16	resv2;
-	__be16	ngrec;
-	struct mld2_grec grec[0];
-};
-
-struct mld2_query {
-	__u8 type;
-	__u8 code;
-	__sum16 csum;
-	__be16 mrc;
-	__be16 resv1;
-	struct in6_addr mca;
-#if defined(__LITTLE_ENDIAN_BITFIELD)
-	__u8 qrv:3,
-	     suppress:1,
-	     resv2:4;
-#elif defined(__BIG_ENDIAN_BITFIELD)
-	__u8 resv2:4,
-	     suppress:1,
-	     qrv:3;
-#else
-#error "Please fix <asm/byteorder.h>"
-#endif
-	__u8 qqic;
-	__be16 nsrcs;
-	struct in6_addr srcs[0];
+/* Ensure that we have struct in6_addr aligned on 32bit word. */
+static void *__mld2_query_bugs[] __attribute__((__unused__)) = {
+	BUILD_BUG_ON_NULL(offsetof(struct mld2_query, mld2q_srcs) % 4),
+	BUILD_BUG_ON_NULL(offsetof(struct mld2_report, mld2r_grec) % 4),
+	BUILD_BUG_ON_NULL(offsetof(struct mld2_grec, grec_mca) % 4)
 };
 
 static struct in6_addr mld2_all_mcr = MLD2_ALL_MCR_INIT;
@@ -156,14 +114,6 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 		((idev)->mc_v1_seen && \
 		time_before(jiffies, (idev)->mc_v1_seen)))
 
-#define MLDV2_MASK(value, nb) ((nb)>=32 ? (value) : ((1<<(nb))-1) & (value))
-#define MLDV2_EXP(thresh, nbmant, nbexp, value) \
-	((value) < (thresh) ? (value) : \
-	((MLDV2_MASK(value, nbmant) | (1<<(nbmant))) << \
-	(MLDV2_MASK((value) >> (nbmant), nbexp) + (nbexp))))
-
-#define MLDV2_MRC(value) MLDV2_EXP(0x8000, 12, 3, value)
-
 #define IPV6_MLD_MAX_MSF	64
 
 int sysctl_mld_max_msf __read_mostly = IPV6_MLD_MAX_MSF;
@@ -1160,7 +1110,7 @@ int igmp6_event_query(struct sk_buff *skb)
 	struct in6_addr *group;
 	unsigned long max_delay;
 	struct inet6_dev *idev;
-	struct icmp6hdr *hdr;
+	struct mld_msg *mld;
 	int group_type;
 	int mark = 0;
 	int len;
@@ -1181,8 +1131,8 @@ int igmp6_event_query(struct sk_buff *skb)
 	if (idev == NULL)
 		return 0;
 
-	hdr = icmp6_hdr(skb);
-	group = (struct in6_addr *) (hdr + 1);
+	mld = mld_msg(skb);
+	group = &mld->mld_mca;
 	group_type = ipv6_addr_type(group);
 
 	if (group_type != IPV6_ADDR_ANY &&
@@ -1196,7 +1146,7 @@ int igmp6_event_query(struct sk_buff *skb)
 		/* MLDv1 router present */
 
 		/* Translate milliseconds to jiffies */
-		max_delay = (ntohs(hdr->icmp6_maxdelay)*HZ)/1000;
+		max_delay = (ntohs(mld->mld_maxdelay)*HZ)/1000;
 
 		switchback = (idev->mc_qrv + 1) * max_delay;
 		idev->mc_v1_seen = jiffies + switchback;
@@ -1215,14 +1165,14 @@ int igmp6_event_query(struct sk_buff *skb)
 			return -EINVAL;
 		}
 		mlh2 = (struct mld2_query *)skb_transport_header(skb);
-		max_delay = (MLDV2_MRC(ntohs(mlh2->mrc))*HZ)/1000;
+		max_delay = (MLDV2_MRC(ntohs(mlh2->mld2q_mrc))*HZ)/1000;
 		if (!max_delay)
 			max_delay = 1;
 		idev->mc_maxdelay = max_delay;
-		if (mlh2->qrv)
-			idev->mc_qrv = mlh2->qrv;
+		if (mlh2->mld2q_qrv)
+			idev->mc_qrv = mlh2->mld2q_qrv;
 		if (group_type == IPV6_ADDR_ANY) { /* general query */
-			if (mlh2->nsrcs) {
+			if (mlh2->mld2q_nsrcs) {
 				in6_dev_put(idev);
 				return -EINVAL; /* no sources allowed */
 			}
@@ -1231,9 +1181,9 @@ int igmp6_event_query(struct sk_buff *skb)
 			return 0;
 		}
 		/* mark sources to include, if group & source-specific */
-		if (mlh2->nsrcs != 0) {
+		if (mlh2->mld2q_nsrcs != 0) {
 			if (!pskb_may_pull(skb, srcs_offset +
-			    ntohs(mlh2->nsrcs) * sizeof(struct in6_addr))) {
+			    ntohs(mlh2->mld2q_nsrcs) * sizeof(struct in6_addr))) {
 				in6_dev_put(idev);
 				return -EINVAL;
 			}
@@ -1269,7 +1219,7 @@ int igmp6_event_query(struct sk_buff *skb)
 					ma->mca_flags &= ~MAF_GSQUERY;
 			}
 			if (!(ma->mca_flags & MAF_GSQUERY) ||
-			    mld_marksources(ma, ntohs(mlh2->nsrcs), mlh2->srcs))
+			    mld_marksources(ma, ntohs(mlh2->mld2q_nsrcs), mlh2->mld2q_srcs))
 				igmp6_group_queried(ma, max_delay);
 			spin_unlock_bh(&ma->mca_lock);
 			break;
@@ -1285,9 +1235,8 @@ int igmp6_event_query(struct sk_buff *skb)
 int igmp6_event_report(struct sk_buff *skb)
 {
 	struct ifmcaddr6 *ma;
-	struct in6_addr *addrp;
 	struct inet6_dev *idev;
-	struct icmp6hdr *hdr;
+	struct mld_msg *mld;
 	int addr_type;
 
 	/* Our own report looped back. Ignore it. */
@@ -1299,10 +1248,10 @@ int igmp6_event_report(struct sk_buff *skb)
 	    skb->pkt_type != PACKET_BROADCAST)
 		return 0;
 
-	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
+	if (!pskb_may_pull(skb, sizeof(*mld) - sizeof(struct icmp6hdr)))
 		return -EINVAL;
 
-	hdr = icmp6_hdr(skb);
+	mld = mld_msg(skb);
 
 	/* Drop reports with not link local source */
 	addr_type = ipv6_addr_type(&ipv6_hdr(skb)->saddr);
@@ -1310,8 +1259,6 @@ int igmp6_event_report(struct sk_buff *skb)
 	    !(addr_type&IPV6_ADDR_LINKLOCAL))
 		return -EINVAL;
 
-	addrp = (struct in6_addr *) (hdr + 1);
-
 	idev = in6_dev_get(skb->dev);
 	if (idev == NULL)
 		return -ENODEV;
@@ -1322,7 +1269,7 @@ int igmp6_event_report(struct sk_buff *skb)
 
 	read_lock_bh(&idev->lock);
 	for (ma = idev->mc_list; ma; ma=ma->next) {
-		if (ipv6_addr_equal(&ma->mca_addr, addrp)) {
+		if (ipv6_addr_equal(&ma->mca_addr, &mld->mld_mca)) {
 			spin_lock(&ma->mca_lock);
 			if (del_timer(&ma->mca_timer))
 				atomic_dec(&ma->mca_refcnt);
@@ -1431,11 +1378,11 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 	skb_set_transport_header(skb, skb_tail_pointer(skb) - skb->data);
 	skb_put(skb, sizeof(*pmr));
 	pmr = (struct mld2_report *)skb_transport_header(skb);
-	pmr->type = ICMPV6_MLD2_REPORT;
-	pmr->resv1 = 0;
-	pmr->csum = 0;
-	pmr->resv2 = 0;
-	pmr->ngrec = 0;
+	pmr->mld2r_type = ICMPV6_MLD2_REPORT;
+	pmr->mld2r_resv1 = 0;
+	pmr->mld2r_cksum = 0;
+	pmr->mld2r_resv2 = 0;
+	pmr->mld2r_ngrec = 0;
 	return skb;
 }
 
@@ -1457,9 +1404,10 @@ static void mld_sendpack(struct sk_buff *skb)
 	mldlen = skb->tail - skb->transport_header;
 	pip6->payload_len = htons(payload_len);
 
-	pmr->csum = csum_ipv6_magic(&pip6->saddr, &pip6->daddr, mldlen,
-		IPPROTO_ICMPV6, csum_partial(skb_transport_header(skb),
-					     mldlen, 0));
+	pmr->mld2r_cksum = csum_ipv6_magic(&pip6->saddr, &pip6->daddr, mldlen,
+					   IPPROTO_ICMPV6,
+					   csum_partial(skb_transport_header(skb),
+							mldlen, 0));
 
 	dst = icmp6_dst_alloc(skb->dev, NULL, &ipv6_hdr(skb)->daddr);
 
@@ -1520,7 +1468,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	pgr->grec_nsrcs = 0;
 	pgr->grec_mca = pmc->mca_addr;	/* structure copy */
 	pmr = (struct mld2_report *)skb_transport_header(skb);
-	pmr->ngrec = htons(ntohs(pmr->ngrec)+1);
+	pmr->mld2r_ngrec = htons(ntohs(pmr->mld2r_ngrec)+1);
 	*ppgr = pgr;
 	return skb;
 }
@@ -1556,7 +1504,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 
 	/* EX and TO_EX get a fresh packet, if needed */
 	if (truncate) {
-		if (pmr && pmr->ngrec &&
+		if (pmr && pmr->mld2r_ngrec &&
 		    AVAILABLE(skb) < grec_size(pmc, type, gdeleted, sdeleted)) {
 			if (skb)
 				mld_sendpack(skb);
@@ -1769,9 +1717,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	struct sock *sk = net->ipv6.igmp_sk;
 	struct inet6_dev *idev;
 	struct sk_buff *skb;
-	struct icmp6hdr *hdr;
+	struct mld_msg *hdr;
 	const struct in6_addr *snd_addr, *saddr;
-	struct in6_addr *addrp;
 	struct in6_addr addr_buf;
 	int err, len, payload_len, full_len;
 	u8 ra[8] = { IPPROTO_ICMPV6, 0,
@@ -1819,16 +1766,14 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	memcpy(skb_put(skb, sizeof(ra)), ra, sizeof(ra));
 
-	hdr = (struct icmp6hdr *) skb_put(skb, sizeof(struct icmp6hdr));
-	memset(hdr, 0, sizeof(struct icmp6hdr));
-	hdr->icmp6_type = type;
+	hdr = (struct mld_msg *) skb_put(skb, sizeof(struct mld_msg));
+	memset(hdr, 0, sizeof(struct mld_msg));
+	hdr->mld_type = type;
+	ipv6_addr_copy(&hdr->mld_mca, addr);
 
-	addrp = (struct in6_addr *) skb_put(skb, sizeof(struct in6_addr));
-	ipv6_addr_copy(addrp, addr);
-
-	hdr->icmp6_cksum = csum_ipv6_magic(saddr, snd_addr, len,
-					   IPPROTO_ICMPV6,
-					   csum_partial(hdr, len, 0));
+	hdr->mld_cksum = csum_ipv6_magic(saddr, snd_addr, len,
+					 IPPROTO_ICMPV6,
+					 csum_partial(hdr, len, 0));
 
 	idev = in6_dev_get(skb->dev);
 
-- 
1.5.6.5

