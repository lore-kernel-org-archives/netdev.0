From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next-2.6 (TAKE 4)] MLD Snooping
Date: Fri, 23 Apr 2010 14:01:22 +0900
Message-ID: <201004230501.o3N51MA8008837@94.43.138.210.xn.2iij.net>
Content-Type: text/plain
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:52342 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438Ab0DWFBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 01:01:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please consider pulling following changes since commit
efe91932e79cfe59a562b70d8eb18049b36debc6
	sky2: size status ring based on Tx/Rx ring
at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-next.git net-next-2.6_20100423a/br/br_multicast_v3

Changes since TAKE 3
--------------------
- Fix compilation / linkage errors
- Fix destination address of MLD message.
- Pass-through local multicast not only link-local ones.
- Fix tab/space inconsistency in include/net/mld.h

HEADLINES
---------

    ipv6 mcast: Introduce include/net/mld.h for MLD definitions.
    bridge br_multicast: Make functions less ipv4 dependent.
    bridge br_multicast: IPv6 MLD support.

DIFFSTAT
--------

 include/net/mld.h         |   75 +++++
 net/bridge/Kconfig        |    6 
 net/bridge/br_multicast.c |  619 +++++++++++++++++++++++++++++++++++++++++----
 net/bridge/br_private.h   |   15 +
 net/ipv6/mcast.c          |  135 +++-------
 5 files changed, 694 insertions(+), 156 deletions(-)

CHANGESETS
----------

commit 6e7cb8370760ec17e10098399822292def8d84f3
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Apr 18 12:42:05 2010 +0900

    ipv6 mcast: Introduce include/net/mld.h for MLD definitions.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/mld.h b/include/net/mld.h
new file mode 100644
index 0000000..467143c
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
+#define mld2r_cksum		mld2r_hdr.icmp6_cksum
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
+#define mld2q_type		mld2q_hdr.icmp6_type
+#define mld2q_code		mld2q_hdr.icmp6_code
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
index 62ed082..006aee6 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -44,6 +44,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
+#include <net/mld.h>
 
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
@@ -71,54 +72,11 @@
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
@@ -157,14 +115,6 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
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
@@ -1161,7 +1111,7 @@ int igmp6_event_query(struct sk_buff *skb)
 	struct in6_addr *group;
 	unsigned long max_delay;
 	struct inet6_dev *idev;
-	struct icmp6hdr *hdr;
+	struct mld_msg *mld;
 	int group_type;
 	int mark = 0;
 	int len;
@@ -1182,8 +1132,8 @@ int igmp6_event_query(struct sk_buff *skb)
 	if (idev == NULL)
 		return 0;
 
-	hdr = icmp6_hdr(skb);
-	group = (struct in6_addr *) (hdr + 1);
+	mld = (struct mld_msg *)icmp6_hdr(skb);
+	group = &mld->mld_mca;
 	group_type = ipv6_addr_type(group);
 
 	if (group_type != IPV6_ADDR_ANY &&
@@ -1197,7 +1147,7 @@ int igmp6_event_query(struct sk_buff *skb)
 		/* MLDv1 router present */
 
 		/* Translate milliseconds to jiffies */
-		max_delay = (ntohs(hdr->icmp6_maxdelay)*HZ)/1000;
+		max_delay = (ntohs(mld->mld_maxdelay)*HZ)/1000;
 
 		switchback = (idev->mc_qrv + 1) * max_delay;
 		idev->mc_v1_seen = jiffies + switchback;
@@ -1216,14 +1166,14 @@ int igmp6_event_query(struct sk_buff *skb)
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
@@ -1232,9 +1182,9 @@ int igmp6_event_query(struct sk_buff *skb)
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
@@ -1270,7 +1220,7 @@ int igmp6_event_query(struct sk_buff *skb)
 					ma->mca_flags &= ~MAF_GSQUERY;
 			}
 			if (!(ma->mca_flags & MAF_GSQUERY) ||
-			    mld_marksources(ma, ntohs(mlh2->nsrcs), mlh2->srcs))
+			    mld_marksources(ma, ntohs(mlh2->mld2q_nsrcs), mlh2->mld2q_srcs))
 				igmp6_group_queried(ma, max_delay);
 			spin_unlock_bh(&ma->mca_lock);
 			break;
@@ -1286,9 +1236,8 @@ int igmp6_event_query(struct sk_buff *skb)
 int igmp6_event_report(struct sk_buff *skb)
 {
 	struct ifmcaddr6 *ma;
-	struct in6_addr *addrp;
 	struct inet6_dev *idev;
-	struct icmp6hdr *hdr;
+	struct mld_msg *mld;
 	int addr_type;
 
 	/* Our own report looped back. Ignore it. */
@@ -1300,10 +1249,10 @@ int igmp6_event_report(struct sk_buff *skb)
 	    skb->pkt_type != PACKET_BROADCAST)
 		return 0;
 
-	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
+	if (!pskb_may_pull(skb, sizeof(*mld) - sizeof(struct icmp6hdr)))
 		return -EINVAL;
 
-	hdr = icmp6_hdr(skb);
+	mld = (struct mld_msg *)icmp6_hdr(skb);
 
 	/* Drop reports with not link local source */
 	addr_type = ipv6_addr_type(&ipv6_hdr(skb)->saddr);
@@ -1311,8 +1260,6 @@ int igmp6_event_report(struct sk_buff *skb)
 	    !(addr_type&IPV6_ADDR_LINKLOCAL))
 		return -EINVAL;
 
-	addrp = (struct in6_addr *) (hdr + 1);
-
 	idev = in6_dev_get(skb->dev);
 	if (idev == NULL)
 		return -ENODEV;
@@ -1323,7 +1270,7 @@ int igmp6_event_report(struct sk_buff *skb)
 
 	read_lock_bh(&idev->lock);
 	for (ma = idev->mc_list; ma; ma=ma->next) {
-		if (ipv6_addr_equal(&ma->mca_addr, addrp)) {
+		if (ipv6_addr_equal(&ma->mca_addr, &mld->mld_mca)) {
 			spin_lock(&ma->mca_lock);
 			if (del_timer(&ma->mca_timer))
 				atomic_dec(&ma->mca_refcnt);
@@ -1432,11 +1379,11 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
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
 
@@ -1458,9 +1405,10 @@ static void mld_sendpack(struct sk_buff *skb)
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
 
@@ -1521,7 +1469,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	pgr->grec_nsrcs = 0;
 	pgr->grec_mca = pmc->mca_addr;	/* structure copy */
 	pmr = (struct mld2_report *)skb_transport_header(skb);
-	pmr->ngrec = htons(ntohs(pmr->ngrec)+1);
+	pmr->mld2r_ngrec = htons(ntohs(pmr->mld2r_ngrec)+1);
 	*ppgr = pgr;
 	return skb;
 }
@@ -1557,7 +1505,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 
 	/* EX and TO_EX get a fresh packet, if needed */
 	if (truncate) {
-		if (pmr && pmr->ngrec &&
+		if (pmr && pmr->mld2r_ngrec &&
 		    AVAILABLE(skb) < grec_size(pmc, type, gdeleted, sdeleted)) {
 			if (skb)
 				mld_sendpack(skb);
@@ -1770,9 +1718,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
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
@@ -1820,16 +1767,14 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
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
 

---
commit 8ef2a9a59854994bace13b5c4f7edc2c8d4d124e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Apr 18 12:42:07 2010 +0900

    bridge br_multicast: Make functions less ipv4 dependent.
    
    Introduce struct br_ip{} to store ip address and protocol
    and make functions more generic so that we can support
    both IPv4 and IPv6 with less pain.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 81bfdfe..64a3e4f 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -27,48 +27,86 @@
 
 #include "br_private.h"
 
-static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
+static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
+{
+	if (a->proto != b->proto)
+		return 0;
+	switch (a->proto) {
+	case htons(ETH_P_IP):
+		return a->u.ip4 == b->u.ip4;
+	}
+	return 0;
+}
+
+static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
 {
 	return jhash_1word(mdb->secret, (__force u32)ip) & (mdb->max - 1);
 }
 
+static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
+			     struct br_ip *ip)
+{
+	switch (ip->proto) {
+	case htons(ETH_P_IP):
+		return __br_ip4_hash(mdb, ip->u.ip4);
+	}
+	return 0;
+}
+
 static struct net_bridge_mdb_entry *__br_mdb_ip_get(
-	struct net_bridge_mdb_htable *mdb, __be32 dst, int hash)
+	struct net_bridge_mdb_htable *mdb, struct br_ip *dst, int hash)
 {
 	struct net_bridge_mdb_entry *mp;
 	struct hlist_node *p;
 
 	hlist_for_each_entry_rcu(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
-		if (dst == mp->addr)
+		if (br_ip_equal(&mp->addr, dst))
 			return mp;
 	}
 
 	return NULL;
 }
 
-static struct net_bridge_mdb_entry *br_mdb_ip_get(
+static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 	struct net_bridge_mdb_htable *mdb, __be32 dst)
 {
-	if (!mdb)
-		return NULL;
+	struct br_ip br_dst;
+
+	br_dst.u.ip4 = dst;
+	br_dst.proto = htons(ETH_P_IP);
 
+	return __br_mdb_ip_get(mdb, &br_dst, __br_ip4_hash(mdb, dst));
+}
+
+static struct net_bridge_mdb_entry *br_mdb_ip_get(
+	struct net_bridge_mdb_htable *mdb, struct br_ip *dst)
+{
 	return __br_mdb_ip_get(mdb, dst, br_ip_hash(mdb, dst));
 }
 
 struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 					struct sk_buff *skb)
 {
-	if (br->multicast_disabled)
+	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct br_ip ip;
+
+	if (!mdb || br->multicast_disabled)
+		return NULL;
+
+	if (BR_INPUT_SKB_CB(skb)->igmp)
 		return NULL;
 
+	ip.proto = skb->protocol;
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		if (BR_INPUT_SKB_CB(skb)->igmp)
-			break;
-		return br_mdb_ip_get(br->mdb, ip_hdr(skb)->daddr);
+		ip.u.ip4 = ip_hdr(skb)->daddr;
+		break;
+	default:
+		return NULL;
 	}
 
-	return NULL;
+	return br_mdb_ip_get(mdb, &ip);
 }
 
 static void br_mdb_free(struct rcu_head *head)
@@ -95,7 +133,7 @@ static int br_mdb_copy(struct net_bridge_mdb_htable *new,
 	for (i = 0; i < old->max; i++)
 		hlist_for_each_entry(mp, p, &old->mhash[i], hlist[old->ver])
 			hlist_add_head(&mp->hlist[new->ver],
-				       &new->mhash[br_ip_hash(new, mp->addr)]);
+				       &new->mhash[br_ip_hash(new, &mp->addr)]);
 
 	if (!elasticity)
 		return 0;
@@ -163,7 +201,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 	struct net_bridge_port_group *p;
 	struct net_bridge_port_group **pp;
 
-	mp = br_mdb_ip_get(mdb, pg->addr);
+	mp = br_mdb_ip_get(mdb, &pg->addr);
 	if (WARN_ON(!mp))
 		return;
 
@@ -249,8 +287,8 @@ out:
 	return 0;
 }
 
-static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
-						__be32 group)
+static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
+						    __be32 group)
 {
 	struct sk_buff *skb;
 	struct igmphdr *ih;
@@ -314,12 +352,22 @@ out:
 	return skb;
 }
 
+static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
+						struct br_ip *addr)
+{
+	switch (addr->proto) {
+	case htons(ETH_P_IP):
+		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
+	}
+	return NULL;
+}
+
 static void br_multicast_send_group_query(struct net_bridge_mdb_entry *mp)
 {
 	struct net_bridge *br = mp->br;
 	struct sk_buff *skb;
 
-	skb = br_multicast_alloc_query(br, mp->addr);
+	skb = br_multicast_alloc_query(br, &mp->addr);
 	if (!skb)
 		goto timer;
 
@@ -353,7 +401,7 @@ static void br_multicast_send_port_group_query(struct net_bridge_port_group *pg)
 	struct net_bridge *br = port->br;
 	struct sk_buff *skb;
 
-	skb = br_multicast_alloc_query(br, pg->addr);
+	skb = br_multicast_alloc_query(br, &pg->addr);
 	if (!skb)
 		goto timer;
 
@@ -383,8 +431,8 @@ out:
 }
 
 static struct net_bridge_mdb_entry *br_multicast_get_group(
-	struct net_bridge *br, struct net_bridge_port *port, __be32 group,
-	int hash)
+	struct net_bridge *br, struct net_bridge_port *port,
+	struct br_ip *group, int hash)
 {
 	struct net_bridge_mdb_htable *mdb = br->mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -396,9 +444,8 @@ static struct net_bridge_mdb_entry *br_multicast_get_group(
 
 	hlist_for_each_entry(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
 		count++;
-		if (unlikely(group == mp->addr)) {
+		if (unlikely(br_ip_equal(group, &mp->addr)))
 			return mp;
-		}
 	}
 
 	elasticity = 0;
@@ -463,7 +510,8 @@ err:
 }
 
 static struct net_bridge_mdb_entry *br_multicast_new_group(
-	struct net_bridge *br, struct net_bridge_port *port, __be32 group)
+	struct net_bridge *br, struct net_bridge_port *port,
+	struct br_ip *group)
 {
 	struct net_bridge_mdb_htable *mdb = br->mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -496,7 +544,7 @@ rehash:
 		goto out;
 
 	mp->br = br;
-	mp->addr = group;
+	mp->addr = *group;
 	setup_timer(&mp->timer, br_multicast_group_expired,
 		    (unsigned long)mp);
 	setup_timer(&mp->query_timer, br_multicast_group_query_expired,
@@ -510,7 +558,8 @@ out:
 }
 
 static int br_multicast_add_group(struct net_bridge *br,
-				  struct net_bridge_port *port, __be32 group)
+				  struct net_bridge_port *port,
+				  struct br_ip *group)
 {
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
@@ -518,9 +567,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 	unsigned long now = jiffies;
 	int err;
 
-	if (ipv4_is_local_multicast(group))
-		return 0;
-
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
 	    (port && port->state == BR_STATE_DISABLED))
@@ -549,7 +595,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 	if (unlikely(!p))
 		goto err;
 
-	p->addr = group;
+	p->addr = *group;
 	p->port = port;
 	p->next = *pp;
 	hlist_add_head(&p->mglist, &port->mglist);
@@ -570,6 +616,21 @@ err:
 	return err;
 }
 
+static int br_ip4_multicast_add_group(struct net_bridge *br,
+				      struct net_bridge_port *port,
+				      __be32 group)
+{
+	struct br_ip br_group;
+
+	if (ipv4_is_local_multicast(group))
+		return 0;
+
+	br_group.u.ip4 = group;
+	br_group.proto = htons(ETH_P_IP);
+
+	return br_multicast_add_group(br, port, &br_group);
+}
+
 static void br_multicast_router_expired(unsigned long data)
 {
 	struct net_bridge_port *port = (void *)data;
@@ -591,19 +652,15 @@ static void br_multicast_local_router_expired(unsigned long data)
 {
 }
 
-static void br_multicast_send_query(struct net_bridge *br,
-				    struct net_bridge_port *port, u32 sent)
+static void __br_multicast_send_query(struct net_bridge *br,
+				      struct net_bridge_port *port,
+				      struct br_ip *ip)
 {
-	unsigned long time;
 	struct sk_buff *skb;
 
-	if (!netif_running(br->dev) || br->multicast_disabled ||
-	    timer_pending(&br->multicast_querier_timer))
-		return;
-
-	skb = br_multicast_alloc_query(br, 0);
+	skb = br_multicast_alloc_query(br, ip);
 	if (!skb)
-		goto timer;
+		return;
 
 	if (port) {
 		__skb_push(skb, sizeof(struct ethhdr));
@@ -612,8 +669,23 @@ static void br_multicast_send_query(struct net_bridge *br,
 			dev_queue_xmit);
 	} else
 		netif_rx(skb);
+}
+
+static void br_multicast_send_query(struct net_bridge *br,
+				    struct net_bridge_port *port, u32 sent)
+{
+	unsigned long time;
+	struct br_ip br_group;
+
+	if (!netif_running(br->dev) || br->multicast_disabled ||
+	    timer_pending(&br->multicast_querier_timer))
+		return;
+
+	br_group.u.ip4 = 0;
+	br_group.proto = htons(ETH_P_IP);
+
+	__br_multicast_send_query(br, port, &br_group);
 
-timer:
 	time = jiffies;
 	time += sent < br->multicast_startup_query_count ?
 		br->multicast_startup_query_interval :
@@ -698,9 +770,9 @@ void br_multicast_disable_port(struct net_bridge_port *port)
 	spin_unlock(&br->multicast_lock);
 }
 
-static int br_multicast_igmp3_report(struct net_bridge *br,
-				     struct net_bridge_port *port,
-				     struct sk_buff *skb)
+static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
+					 struct net_bridge_port *port,
+					 struct sk_buff *skb)
 {
 	struct igmpv3_report *ih;
 	struct igmpv3_grec *grec;
@@ -745,7 +817,7 @@ static int br_multicast_igmp3_report(struct net_bridge *br,
 			continue;
 		}
 
-		err = br_multicast_add_group(br, port, group);
+		err = br_ip4_multicast_add_group(br, port, group);
 		if (err)
 			break;
 	}
@@ -800,7 +872,7 @@ timer:
 
 static void br_multicast_query_received(struct net_bridge *br,
 					struct net_bridge_port *port,
-					__be32 saddr)
+					int saddr)
 {
 	if (saddr)
 		mod_timer(&br->multicast_querier_timer,
@@ -811,9 +883,9 @@ static void br_multicast_query_received(struct net_bridge *br,
 	br_multicast_mark_router(br, port);
 }
 
-static int br_multicast_query(struct net_bridge *br,
-			      struct net_bridge_port *port,
-			      struct sk_buff *skb)
+static int br_ip4_multicast_query(struct net_bridge *br,
+				  struct net_bridge_port *port,
+				  struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 	struct igmphdr *ih = igmp_hdr(skb);
@@ -831,7 +903,7 @@ static int br_multicast_query(struct net_bridge *br,
 	    (port && port->state == BR_STATE_DISABLED))
 		goto out;
 
-	br_multicast_query_received(br, port, iph->saddr);
+	br_multicast_query_received(br, port, !!iph->saddr);
 
 	group = ih->group;
 
@@ -859,7 +931,7 @@ static int br_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip_get(br->mdb, group);
+	mp = br_mdb_ip4_get(br->mdb, group);
 	if (!mp)
 		goto out;
 
@@ -885,7 +957,7 @@ out:
 
 static void br_multicast_leave_group(struct net_bridge *br,
 				     struct net_bridge_port *port,
-				     __be32 group)
+				     struct br_ip *group)
 {
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -893,9 +965,6 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	unsigned long now;
 	unsigned long time;
 
-	if (ipv4_is_local_multicast(group))
-		return;
-
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
 	    (port && port->state == BR_STATE_DISABLED) ||
@@ -946,6 +1015,22 @@ out:
 	spin_unlock(&br->multicast_lock);
 }
 
+static void br_ip4_multicast_leave_group(struct net_bridge *br,
+					 struct net_bridge_port *port,
+					 __be32 group)
+{
+	struct br_ip br_group;
+
+	if (ipv4_is_local_multicast(group))
+		return;
+
+	br_group.u.ip4 = group;
+	br_group.proto = htons(ETH_P_IP);
+
+	br_multicast_leave_group(br, port, &br_group);
+}
+
+
 static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
 				 struct sk_buff *skb)
@@ -1023,16 +1108,16 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
-		err = br_multicast_add_group(br, port, ih->group);
+		err = br_ip4_multicast_add_group(br, port, ih->group);
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
-		err = br_multicast_igmp3_report(br, port, skb2);
+		err = br_ip4_multicast_igmp3_report(br, port, skb2);
 		break;
 	case IGMP_HOST_MEMBERSHIP_QUERY:
-		err = br_multicast_query(br, port, skb2);
+		err = br_ip4_multicast_query(br, port, skb2);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
-		br_multicast_leave_group(br, port, ih->group);
+		br_ip4_multicast_leave_group(br, port, ih->group);
 		break;
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 63181e4..45d11e4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -45,6 +45,14 @@ struct mac_addr
 	unsigned char	addr[6];
 };
 
+struct br_ip
+{
+	union {
+		__be32	ip4;
+	} u;
+	__be16		proto;
+};
+
 struct net_bridge_fdb_entry
 {
 	struct hlist_node		hlist;
@@ -64,7 +72,7 @@ struct net_bridge_port_group {
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct timer_list		query_timer;
-	__be32				addr;
+	struct br_ip			addr;
 	u32				queries_sent;
 };
 
@@ -77,7 +85,7 @@ struct net_bridge_mdb_entry
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct timer_list		query_timer;
-	__be32				addr;
+	struct br_ip			addr;
 	u32				queries_sent;
 };
 

---
commit 08b202b6726459626c73ecfa08fcdc8c3efc76c2
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 23 01:54:22 2010 +0900

    bridge br_multicast: IPv6 MLD support.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
index d115d5c..9190ae4 100644
--- a/net/bridge/Kconfig
+++ b/net/bridge/Kconfig
@@ -33,14 +33,14 @@ config BRIDGE
 	  If unsure, say N.
 
 config BRIDGE_IGMP_SNOOPING
-	bool "IGMP snooping"
+	bool "IGMP/MLD snooping"
 	depends on BRIDGE
 	depends on INET
 	default y
 	---help---
 	  If you say Y here, then the Ethernet bridge will be able selectively
-	  forward multicast traffic based on IGMP traffic received from each
-	  port.
+	  forward multicast traffic based on IGMP/MLD traffic received from
+	  each port.
 
 	  Say N to exclude this support and reduce the binary size.
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 64a3e4f..38d1fbd 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -24,9 +24,24 @@
 #include <linux/slab.h>
 #include <linux/timer.h>
 #include <net/ip.h>
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#include <net/ipv6.h>
+#include <net/mld.h>
+#include <net/addrconf.h>
+#endif
 
 #include "br_private.h"
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline int ipv6_is_local_multicast(const struct in6_addr *addr)
+{
+	if (ipv6_addr_is_multicast(addr) &&
+	    IPV6_ADDR_MC_SCOPE(addr) <= IPV6_ADDR_SCOPE_LINKLOCAL)
+		return 1;
+	return 0;
+}
+#endif
+
 static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 {
 	if (a->proto != b->proto)
@@ -34,6 +49,10 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 	switch (a->proto) {
 	case htons(ETH_P_IP):
 		return a->u.ip4 == b->u.ip4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return ipv6_addr_equal(&a->u.ip6, &b->u.ip6);
+#endif
 	}
 	return 0;
 }
@@ -43,12 +62,24 @@ static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
 	return jhash_1word(mdb->secret, (__force u32)ip) & (mdb->max - 1);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline int __br_ip6_hash(struct net_bridge_mdb_htable *mdb,
+				const struct in6_addr *ip)
+{
+	return jhash2((__force u32 *)ip->s6_addr32, 4, mdb->secret) & (mdb->max - 1);
+}
+#endif
+
 static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
 			     struct br_ip *ip)
 {
 	switch (ip->proto) {
 	case htons(ETH_P_IP):
 		return __br_ip4_hash(mdb, ip->u.ip4);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return __br_ip6_hash(mdb, &ip->u.ip6);
+#endif
 	}
 	return 0;
 }
@@ -78,6 +109,19 @@ static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 	return __br_mdb_ip_get(mdb, &br_dst, __br_ip4_hash(mdb, dst));
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static struct net_bridge_mdb_entry *br_mdb_ip6_get(
+	struct net_bridge_mdb_htable *mdb, const struct in6_addr *dst)
+{
+	struct br_ip br_dst;
+
+	ipv6_addr_copy(&br_dst.u.ip6, dst);
+	br_dst.proto = htons(ETH_P_IPV6);
+
+	return __br_mdb_ip_get(mdb, &br_dst, __br_ip6_hash(mdb, dst));
+}
+#endif
+
 static struct net_bridge_mdb_entry *br_mdb_ip_get(
 	struct net_bridge_mdb_htable *mdb, struct br_ip *dst)
 {
@@ -102,6 +146,11 @@ struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 	case htons(ETH_P_IP):
 		ip.u.ip4 = ip_hdr(skb)->daddr;
 		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		ipv6_addr_copy(&ip.u.ip6, &ipv6_hdr(skb)->daddr);
+		break;
+#endif
 	default:
 		return NULL;
 	}
@@ -352,12 +401,94 @@ out:
 	return skb;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
+						    struct in6_addr *group)
+{
+	struct sk_buff *skb;
+	struct ipv6hdr *ip6h;
+	struct mld_msg *mldq;
+	struct ethhdr *eth;
+	u8 *hopopt;
+	unsigned long interval;
+
+	skb = netdev_alloc_skb_ip_align(br->dev, sizeof(*eth) + sizeof(*ip6h) +
+						 8 + sizeof(*mldq));
+	if (!skb)
+		goto out;
+
+	skb->protocol = htons(ETH_P_IPV6);
+
+	/* Ethernet header */
+	skb_reset_mac_header(skb);
+	eth = eth_hdr(skb);
+
+	memcpy(eth->h_source, br->dev->dev_addr, 6);
+	ipv6_eth_mc_map(group, eth->h_dest);
+	eth->h_proto = htons(ETH_P_IPV6);
+	skb_put(skb, sizeof(*eth));
+
+	/* IPv6 header + HbH option */
+	skb_set_network_header(skb, skb->len);
+	ip6h = ipv6_hdr(skb);
+
+	*(__force __be32 *)ip6h = htonl(0x60000000);
+	ip6h->payload_len = 8 + sizeof(*mldq);
+	ip6h->nexthdr = IPPROTO_HOPOPTS;
+	ip6h->hop_limit = 1;
+	ipv6_addr_set(&ip6h->saddr, 0, 0, 0, 0);
+	ipv6_addr_set(&ip6h->daddr, htonl(0xff020000), 0, 0, htonl(1));
+
+	hopopt = (u8 *)(ip6h + 1);
+	hopopt[0] = IPPROTO_ICMPV6;		/* next hdr */
+	hopopt[1] = 0;				/* length of HbH */
+	hopopt[2] = IPV6_TLV_ROUTERALERT;	/* Router Alert */
+	hopopt[3] = 2;				/* Length of RA Option */
+	hopopt[4] = 0;				/* Type = 0x0000 (MLD) */
+	hopopt[5] = 0;
+	hopopt[6] = IPV6_TLV_PAD0;		/* Pad0 */
+	hopopt[7] = IPV6_TLV_PAD0;		/* Pad0 */
+
+	skb_put(skb, sizeof(*ip6h) + 8);
+
+	/* ICMPv6 */
+	skb_set_transport_header(skb, skb->len);
+	mldq = (struct mld_msg *) icmp6_hdr(skb);
+
+	interval = ipv6_addr_any(group) ? br->multicast_last_member_interval :
+					  br->multicast_query_response_interval;
+
+	mldq->mld_type = ICMPV6_MGM_QUERY;
+	mldq->mld_code = 0;
+	mldq->mld_cksum = 0;
+	mldq->mld_maxdelay = htons((u16)jiffies_to_msecs(interval));
+	mldq->mld_reserved = 0;
+	ipv6_addr_copy(&mldq->mld_mca, group);
+
+	/* checksum */
+	mldq->mld_cksum = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+					  sizeof(*mldq), IPPROTO_ICMPV6,
+					  csum_partial(mldq,
+						       sizeof(*mldq), 0));
+	skb_put(skb, sizeof(*mldq));
+
+	__skb_pull(skb, sizeof(*eth));
+
+out:
+	return skb;
+}
+#endif
+
 static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
 						struct br_ip *addr)
 {
 	switch (addr->proto) {
 	case htons(ETH_P_IP):
 		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return br_ip6_multicast_alloc_query(br, &addr->u.ip6);
+#endif
 	}
 	return NULL;
 }
@@ -631,6 +762,23 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 	return br_multicast_add_group(br, port, &br_group);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_ip6_multicast_add_group(struct net_bridge *br,
+				      struct net_bridge_port *port,
+				      const struct in6_addr *group)
+{
+	struct br_ip br_group;
+
+	if (ipv6_is_local_multicast(group))
+		return 0;
+
+	ipv6_addr_copy(&br_group.u.ip6, group);
+	br_group.proto = htons(ETH_P_IP);
+
+	return br_multicast_add_group(br, port, &br_group);
+}
+#endif
+
 static void br_multicast_router_expired(unsigned long data)
 {
 	struct net_bridge_port *port = (void *)data;
@@ -681,10 +829,15 @@ static void br_multicast_send_query(struct net_bridge *br,
 	    timer_pending(&br->multicast_querier_timer))
 		return;
 
-	br_group.u.ip4 = 0;
+	memset(&br_group.u, 0, sizeof(br_group.u));
+
 	br_group.proto = htons(ETH_P_IP);
+	__br_multicast_send_query(br, port, &br_group);
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	br_group.proto = htons(ETH_P_IPV6);
 	__br_multicast_send_query(br, port, &br_group);
+#endif
 
 	time = jiffies;
 	time += sent < br->multicast_startup_query_count ?
@@ -825,6 +978,66 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 	return err;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_ip6_multicast_mld2_report(struct net_bridge *br,
+					struct net_bridge_port *port,
+					struct sk_buff *skb)
+{
+	struct icmp6hdr *icmp6h;
+	struct mld2_grec *grec;
+	int i;
+	int len;
+	int num;
+	int err = 0;
+
+	if (!pskb_may_pull(skb, sizeof(*icmp6h)))
+		return -EINVAL;
+
+	icmp6h = icmp6_hdr(skb);
+	num = ntohs(icmp6h->icmp6_dataun.un_data16[1]);
+	len = sizeof(*icmp6h);
+
+	for (i = 0; i < num; i++) {
+		__be16 *nsrcs, _nsrcs;
+
+		nsrcs = skb_header_pointer(skb,
+					   len + offsetof(struct mld2_grec,
+							  grec_mca),
+					   sizeof(_nsrcs), &_nsrcs);
+		if (!nsrcs)
+			return -EINVAL;
+
+		if (!pskb_may_pull(skb,
+				   len + sizeof(*grec) +
+				   sizeof(struct in6_addr) * (*nsrcs)))
+			return -EINVAL;
+
+		grec = (struct mld2_grec *)(skb->data + len);
+		len += sizeof(*grec) + sizeof(struct in6_addr) * (*nsrcs);
+
+		/* We treat these as MLDv1 reports for now. */
+		switch (grec->grec_type) {
+		case MLD2_MODE_IS_INCLUDE:
+		case MLD2_MODE_IS_EXCLUDE:
+		case MLD2_CHANGE_TO_INCLUDE:
+		case MLD2_CHANGE_TO_EXCLUDE:
+		case MLD2_ALLOW_NEW_SOURCES:
+		case MLD2_BLOCK_OLD_SOURCES:
+			break;
+
+		default:
+			continue;
+		}
+
+		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca);
+		if (!err)
+			break;
+	}
+
+	return err;
+}
+#endif
+
 static void br_multicast_add_router(struct net_bridge *br,
 				    struct net_bridge_port *port)
 {
@@ -955,6 +1168,75 @@ out:
 	return err;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_ip6_multicast_query(struct net_bridge *br,
+				  struct net_bridge_port *port,
+				  struct sk_buff *skb)
+{
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct mld_msg *mld = (struct mld_msg *) icmp6_hdr(skb);
+	struct net_bridge_mdb_entry *mp;
+	struct mld2_query *mld2q;
+	struct net_bridge_port_group *p, **pp;
+	unsigned long max_delay;
+	unsigned long now = jiffies;
+	struct in6_addr *group = NULL;
+	int err = 0;
+
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev) ||
+	    (port && port->state == BR_STATE_DISABLED))
+		goto out;
+
+	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr));
+
+	if (skb->len == sizeof(*mld)) {
+		if (!pskb_may_pull(skb, sizeof(*mld))) {
+			err = -EINVAL;
+			goto out;
+		}
+		mld = (struct mld_msg *) icmp6_hdr(skb);
+		max_delay = msecs_to_jiffies(htons(mld->mld_maxdelay));
+		if (max_delay)
+			group = &mld->mld_mca;
+	} else if (skb->len >= sizeof(*mld2q)) {
+		if (!pskb_may_pull(skb, sizeof(*mld2q))) {
+			err = -EINVAL;
+			goto out;
+		}
+		mld2q = (struct mld2_query *)icmp6_hdr(skb);
+		if (!mld2q->mld2q_nsrcs)
+			group = &mld2q->mld2q_mca;
+		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(mld2q->mld2q_mrc) : 1;
+	}
+
+	if (!group)
+		goto out;
+
+	mp = br_mdb_ip6_get(br->mdb, group);
+	if (!mp)
+		goto out;
+
+	max_delay *= br->multicast_last_member_count;
+	if (!hlist_unhashed(&mp->mglist) &&
+	    (timer_pending(&mp->timer) ?
+	     time_after(mp->timer.expires, now + max_delay) :
+	     try_to_del_timer_sync(&mp->timer) >= 0))
+		mod_timer(&mp->timer, now + max_delay);
+
+	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+		if (timer_pending(&p->timer) ?
+		    time_after(p->timer.expires, now + max_delay) :
+		    try_to_del_timer_sync(&p->timer) >= 0)
+			mod_timer(&mp->timer, now + max_delay);
+	}
+
+out:
+	spin_unlock(&br->multicast_lock);
+	return err;
+}
+#endif
+
 static void br_multicast_leave_group(struct net_bridge *br,
 				     struct net_bridge_port *port,
 				     struct br_ip *group)
@@ -1030,6 +1312,22 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 	br_multicast_leave_group(br, port, &br_group);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static void br_ip6_multicast_leave_group(struct net_bridge *br,
+					 struct net_bridge_port *port,
+					 const struct in6_addr *group)
+{
+	struct br_ip br_group;
+
+	if (ipv6_is_local_multicast(group))
+		return;
+
+	ipv6_addr_copy(&br_group.u.ip6, group);
+	br_group.proto = htons(ETH_P_IPV6);
+
+	br_multicast_leave_group(br, port, &br_group);
+}
+#endif
 
 static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
@@ -1129,6 +1427,126 @@ err_out:
 	return err;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_multicast_ipv6_rcv(struct net_bridge *br,
+				 struct net_bridge_port *port,
+				 struct sk_buff *skb)
+{
+	struct sk_buff *skb2 = skb;
+	struct ipv6hdr *ip6h;
+	struct icmp6hdr *icmp6h;
+	u8 nexthdr;
+	unsigned len;
+	unsigned offset;
+	int err;
+
+	BR_INPUT_SKB_CB(skb)->igmp = 0;
+	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
+
+	if (!pskb_may_pull(skb, sizeof(*ip6h)))
+		return -EINVAL;
+
+	ip6h = ipv6_hdr(skb);
+
+	/*
+	 * We're interested in MLD messages only.
+	 *  - Version is 6
+	 *  - MLD has always Router Alert hop-by-hop option
+	 *  - But we do not support jumbrograms.
+	 */
+	if (ip6h->version != 6 ||
+	    ip6h->nexthdr != IPPROTO_HOPOPTS ||
+	    ip6h->payload_len == 0)
+		return 0;
+
+	len = ntohs(ip6h->payload_len);
+	if (skb->len < len)
+		return -EINVAL;
+
+	nexthdr = ip6h->nexthdr;
+	offset = ipv6_skip_exthdr(skb, sizeof(*ip6h), &nexthdr);
+
+	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
+		return 0;
+
+	/* Okay, we found ICMPv6 header */
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+	if (!skb2)
+		return -ENOMEM;
+
+	len -= offset - skb_network_offset(skb2);
+
+	__skb_pull(skb2, offset);
+	skb_reset_transport_header(skb2);
+
+	err = -EINVAL;
+	if (!pskb_may_pull(skb2, sizeof(*icmp6h)))
+		goto out;
+
+	icmp6h = icmp6_hdr(skb2);
+
+	switch (icmp6h->icmp6_type) {
+	case ICMPV6_MGM_QUERY:
+	case ICMPV6_MGM_REPORT:
+	case ICMPV6_MGM_REDUCTION:
+	case ICMPV6_MLD2_REPORT:
+		break;
+	default:
+		err = 0;
+		goto out;
+	}
+
+	/* Okay, we found MLD message. Check further. */
+	if (skb2->len > len) {
+		err = pskb_trim_rcsum(skb2, len);
+		if (err)
+			goto out;
+	}
+
+	switch (skb2->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		if (!csum_fold(skb2->csum))
+			break;
+		/*FALLTHROUGH*/
+	case CHECKSUM_NONE:
+		skb2->csum = 0;
+		if (skb_checksum_complete(skb2))
+			goto out;
+	}
+
+	err = 0;
+
+	BR_INPUT_SKB_CB(skb)->igmp = 1;
+
+	switch (icmp6h->icmp6_type) {
+	case ICMPV6_MGM_REPORT:
+	    {
+		struct mld_msg *mld = (struct mld_msg *)icmp6h;
+		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
+		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca);
+		break;
+	    }
+	case ICMPV6_MLD2_REPORT:
+		err = br_ip6_multicast_mld2_report(br, port, skb2);
+		break;
+	case ICMPV6_MGM_QUERY:
+		err = br_ip6_multicast_query(br, port, skb2);
+		break;
+	case ICMPV6_MGM_REDUCTION:
+	    {
+		struct mld_msg *mld = (struct mld_msg *)icmp6h;
+		br_ip6_multicast_leave_group(br, port, &mld->mld_mca);
+	    }
+	}
+
+out:
+	__skb_push(skb2, offset);
+	if (skb2 != skb)
+		kfree_skb(skb2);
+	return err;
+}
+#endif
+
 int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 		     struct sk_buff *skb)
 {
@@ -1138,6 +1556,10 @@ int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		return br_multicast_ipv4_rcv(br, port, skb);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return br_multicast_ipv6_rcv(br, port, skb);
+#endif
 	}
 
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 45d11e4..018499e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -49,6 +49,9 @@ struct br_ip
 {
 	union {
 		__be32	ip4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		struct in6_addr ip6;
+#endif
 	} u;
 	__be16		proto;
 };

---
commit 6e7cb8370760ec17e10098399822292def8d84f3
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Apr 18 12:42:05 2010 +0900

    ipv6 mcast: Introduce include/net/mld.h for MLD definitions.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/mld.h b/include/net/mld.h
new file mode 100644
index 0000000..467143c
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
+#define mld2r_cksum		mld2r_hdr.icmp6_cksum
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
+#define mld2q_type		mld2q_hdr.icmp6_type
+#define mld2q_code		mld2q_hdr.icmp6_code
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
index 62ed082..006aee6 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -44,6 +44,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
+#include <net/mld.h>
 
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
@@ -71,54 +72,11 @@
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
@@ -157,14 +115,6 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
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
@@ -1161,7 +1111,7 @@ int igmp6_event_query(struct sk_buff *skb)
 	struct in6_addr *group;
 	unsigned long max_delay;
 	struct inet6_dev *idev;
-	struct icmp6hdr *hdr;
+	struct mld_msg *mld;
 	int group_type;
 	int mark = 0;
 	int len;
@@ -1182,8 +1132,8 @@ int igmp6_event_query(struct sk_buff *skb)
 	if (idev == NULL)
 		return 0;
 
-	hdr = icmp6_hdr(skb);
-	group = (struct in6_addr *) (hdr + 1);
+	mld = (struct mld_msg *)icmp6_hdr(skb);
+	group = &mld->mld_mca;
 	group_type = ipv6_addr_type(group);
 
 	if (group_type != IPV6_ADDR_ANY &&
@@ -1197,7 +1147,7 @@ int igmp6_event_query(struct sk_buff *skb)
 		/* MLDv1 router present */
 
 		/* Translate milliseconds to jiffies */
-		max_delay = (ntohs(hdr->icmp6_maxdelay)*HZ)/1000;
+		max_delay = (ntohs(mld->mld_maxdelay)*HZ)/1000;
 
 		switchback = (idev->mc_qrv + 1) * max_delay;
 		idev->mc_v1_seen = jiffies + switchback;
@@ -1216,14 +1166,14 @@ int igmp6_event_query(struct sk_buff *skb)
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
@@ -1232,9 +1182,9 @@ int igmp6_event_query(struct sk_buff *skb)
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
@@ -1270,7 +1220,7 @@ int igmp6_event_query(struct sk_buff *skb)
 					ma->mca_flags &= ~MAF_GSQUERY;
 			}
 			if (!(ma->mca_flags & MAF_GSQUERY) ||
-			    mld_marksources(ma, ntohs(mlh2->nsrcs), mlh2->srcs))
+			    mld_marksources(ma, ntohs(mlh2->mld2q_nsrcs), mlh2->mld2q_srcs))
 				igmp6_group_queried(ma, max_delay);
 			spin_unlock_bh(&ma->mca_lock);
 			break;
@@ -1286,9 +1236,8 @@ int igmp6_event_query(struct sk_buff *skb)
 int igmp6_event_report(struct sk_buff *skb)
 {
 	struct ifmcaddr6 *ma;
-	struct in6_addr *addrp;
 	struct inet6_dev *idev;
-	struct icmp6hdr *hdr;
+	struct mld_msg *mld;
 	int addr_type;
 
 	/* Our own report looped back. Ignore it. */
@@ -1300,10 +1249,10 @@ int igmp6_event_report(struct sk_buff *skb)
 	    skb->pkt_type != PACKET_BROADCAST)
 		return 0;
 
-	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
+	if (!pskb_may_pull(skb, sizeof(*mld) - sizeof(struct icmp6hdr)))
 		return -EINVAL;
 
-	hdr = icmp6_hdr(skb);
+	mld = (struct mld_msg *)icmp6_hdr(skb);
 
 	/* Drop reports with not link local source */
 	addr_type = ipv6_addr_type(&ipv6_hdr(skb)->saddr);
@@ -1311,8 +1260,6 @@ int igmp6_event_report(struct sk_buff *skb)
 	    !(addr_type&IPV6_ADDR_LINKLOCAL))
 		return -EINVAL;
 
-	addrp = (struct in6_addr *) (hdr + 1);
-
 	idev = in6_dev_get(skb->dev);
 	if (idev == NULL)
 		return -ENODEV;
@@ -1323,7 +1270,7 @@ int igmp6_event_report(struct sk_buff *skb)
 
 	read_lock_bh(&idev->lock);
 	for (ma = idev->mc_list; ma; ma=ma->next) {
-		if (ipv6_addr_equal(&ma->mca_addr, addrp)) {
+		if (ipv6_addr_equal(&ma->mca_addr, &mld->mld_mca)) {
 			spin_lock(&ma->mca_lock);
 			if (del_timer(&ma->mca_timer))
 				atomic_dec(&ma->mca_refcnt);
@@ -1432,11 +1379,11 @@ static struct sk_buff *mld_newpack(struct net_device *dev, int size)
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
 
@@ -1458,9 +1405,10 @@ static void mld_sendpack(struct sk_buff *skb)
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
 
@@ -1521,7 +1469,7 @@ static struct sk_buff *add_grhead(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	pgr->grec_nsrcs = 0;
 	pgr->grec_mca = pmc->mca_addr;	/* structure copy */
 	pmr = (struct mld2_report *)skb_transport_header(skb);
-	pmr->ngrec = htons(ntohs(pmr->ngrec)+1);
+	pmr->mld2r_ngrec = htons(ntohs(pmr->mld2r_ngrec)+1);
 	*ppgr = pgr;
 	return skb;
 }
@@ -1557,7 +1505,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 
 	/* EX and TO_EX get a fresh packet, if needed */
 	if (truncate) {
-		if (pmr && pmr->ngrec &&
+		if (pmr && pmr->mld2r_ngrec &&
 		    AVAILABLE(skb) < grec_size(pmc, type, gdeleted, sdeleted)) {
 			if (skb)
 				mld_sendpack(skb);
@@ -1770,9 +1718,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
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
@@ -1820,16 +1767,14 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
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
 

---
commit 8ef2a9a59854994bace13b5c4f7edc2c8d4d124e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sun Apr 18 12:42:07 2010 +0900

    bridge br_multicast: Make functions less ipv4 dependent.
    
    Introduce struct br_ip{} to store ip address and protocol
    and make functions more generic so that we can support
    both IPv4 and IPv6 with less pain.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 81bfdfe..64a3e4f 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -27,48 +27,86 @@
 
 #include "br_private.h"
 
-static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
+static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
+{
+	if (a->proto != b->proto)
+		return 0;
+	switch (a->proto) {
+	case htons(ETH_P_IP):
+		return a->u.ip4 == b->u.ip4;
+	}
+	return 0;
+}
+
+static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
 {
 	return jhash_1word(mdb->secret, (__force u32)ip) & (mdb->max - 1);
 }
 
+static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
+			     struct br_ip *ip)
+{
+	switch (ip->proto) {
+	case htons(ETH_P_IP):
+		return __br_ip4_hash(mdb, ip->u.ip4);
+	}
+	return 0;
+}
+
 static struct net_bridge_mdb_entry *__br_mdb_ip_get(
-	struct net_bridge_mdb_htable *mdb, __be32 dst, int hash)
+	struct net_bridge_mdb_htable *mdb, struct br_ip *dst, int hash)
 {
 	struct net_bridge_mdb_entry *mp;
 	struct hlist_node *p;
 
 	hlist_for_each_entry_rcu(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
-		if (dst == mp->addr)
+		if (br_ip_equal(&mp->addr, dst))
 			return mp;
 	}
 
 	return NULL;
 }
 
-static struct net_bridge_mdb_entry *br_mdb_ip_get(
+static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 	struct net_bridge_mdb_htable *mdb, __be32 dst)
 {
-	if (!mdb)
-		return NULL;
+	struct br_ip br_dst;
+
+	br_dst.u.ip4 = dst;
+	br_dst.proto = htons(ETH_P_IP);
 
+	return __br_mdb_ip_get(mdb, &br_dst, __br_ip4_hash(mdb, dst));
+}
+
+static struct net_bridge_mdb_entry *br_mdb_ip_get(
+	struct net_bridge_mdb_htable *mdb, struct br_ip *dst)
+{
 	return __br_mdb_ip_get(mdb, dst, br_ip_hash(mdb, dst));
 }
 
 struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 					struct sk_buff *skb)
 {
-	if (br->multicast_disabled)
+	struct net_bridge_mdb_htable *mdb = br->mdb;
+	struct br_ip ip;
+
+	if (!mdb || br->multicast_disabled)
+		return NULL;
+
+	if (BR_INPUT_SKB_CB(skb)->igmp)
 		return NULL;
 
+	ip.proto = skb->protocol;
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		if (BR_INPUT_SKB_CB(skb)->igmp)
-			break;
-		return br_mdb_ip_get(br->mdb, ip_hdr(skb)->daddr);
+		ip.u.ip4 = ip_hdr(skb)->daddr;
+		break;
+	default:
+		return NULL;
 	}
 
-	return NULL;
+	return br_mdb_ip_get(mdb, &ip);
 }
 
 static void br_mdb_free(struct rcu_head *head)
@@ -95,7 +133,7 @@ static int br_mdb_copy(struct net_bridge_mdb_htable *new,
 	for (i = 0; i < old->max; i++)
 		hlist_for_each_entry(mp, p, &old->mhash[i], hlist[old->ver])
 			hlist_add_head(&mp->hlist[new->ver],
-				       &new->mhash[br_ip_hash(new, mp->addr)]);
+				       &new->mhash[br_ip_hash(new, &mp->addr)]);
 
 	if (!elasticity)
 		return 0;
@@ -163,7 +201,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 	struct net_bridge_port_group *p;
 	struct net_bridge_port_group **pp;
 
-	mp = br_mdb_ip_get(mdb, pg->addr);
+	mp = br_mdb_ip_get(mdb, &pg->addr);
 	if (WARN_ON(!mp))
 		return;
 
@@ -249,8 +287,8 @@ out:
 	return 0;
 }
 
-static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
-						__be32 group)
+static struct sk_buff *br_ip4_multicast_alloc_query(struct net_bridge *br,
+						    __be32 group)
 {
 	struct sk_buff *skb;
 	struct igmphdr *ih;
@@ -314,12 +352,22 @@ out:
 	return skb;
 }
 
+static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
+						struct br_ip *addr)
+{
+	switch (addr->proto) {
+	case htons(ETH_P_IP):
+		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
+	}
+	return NULL;
+}
+
 static void br_multicast_send_group_query(struct net_bridge_mdb_entry *mp)
 {
 	struct net_bridge *br = mp->br;
 	struct sk_buff *skb;
 
-	skb = br_multicast_alloc_query(br, mp->addr);
+	skb = br_multicast_alloc_query(br, &mp->addr);
 	if (!skb)
 		goto timer;
 
@@ -353,7 +401,7 @@ static void br_multicast_send_port_group_query(struct net_bridge_port_group *pg)
 	struct net_bridge *br = port->br;
 	struct sk_buff *skb;
 
-	skb = br_multicast_alloc_query(br, pg->addr);
+	skb = br_multicast_alloc_query(br, &pg->addr);
 	if (!skb)
 		goto timer;
 
@@ -383,8 +431,8 @@ out:
 }
 
 static struct net_bridge_mdb_entry *br_multicast_get_group(
-	struct net_bridge *br, struct net_bridge_port *port, __be32 group,
-	int hash)
+	struct net_bridge *br, struct net_bridge_port *port,
+	struct br_ip *group, int hash)
 {
 	struct net_bridge_mdb_htable *mdb = br->mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -396,9 +444,8 @@ static struct net_bridge_mdb_entry *br_multicast_get_group(
 
 	hlist_for_each_entry(mp, p, &mdb->mhash[hash], hlist[mdb->ver]) {
 		count++;
-		if (unlikely(group == mp->addr)) {
+		if (unlikely(br_ip_equal(group, &mp->addr)))
 			return mp;
-		}
 	}
 
 	elasticity = 0;
@@ -463,7 +510,8 @@ err:
 }
 
 static struct net_bridge_mdb_entry *br_multicast_new_group(
-	struct net_bridge *br, struct net_bridge_port *port, __be32 group)
+	struct net_bridge *br, struct net_bridge_port *port,
+	struct br_ip *group)
 {
 	struct net_bridge_mdb_htable *mdb = br->mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -496,7 +544,7 @@ rehash:
 		goto out;
 
 	mp->br = br;
-	mp->addr = group;
+	mp->addr = *group;
 	setup_timer(&mp->timer, br_multicast_group_expired,
 		    (unsigned long)mp);
 	setup_timer(&mp->query_timer, br_multicast_group_query_expired,
@@ -510,7 +558,8 @@ out:
 }
 
 static int br_multicast_add_group(struct net_bridge *br,
-				  struct net_bridge_port *port, __be32 group)
+				  struct net_bridge_port *port,
+				  struct br_ip *group)
 {
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
@@ -518,9 +567,6 @@ static int br_multicast_add_group(struct net_bridge *br,
 	unsigned long now = jiffies;
 	int err;
 
-	if (ipv4_is_local_multicast(group))
-		return 0;
-
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
 	    (port && port->state == BR_STATE_DISABLED))
@@ -549,7 +595,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 	if (unlikely(!p))
 		goto err;
 
-	p->addr = group;
+	p->addr = *group;
 	p->port = port;
 	p->next = *pp;
 	hlist_add_head(&p->mglist, &port->mglist);
@@ -570,6 +616,21 @@ err:
 	return err;
 }
 
+static int br_ip4_multicast_add_group(struct net_bridge *br,
+				      struct net_bridge_port *port,
+				      __be32 group)
+{
+	struct br_ip br_group;
+
+	if (ipv4_is_local_multicast(group))
+		return 0;
+
+	br_group.u.ip4 = group;
+	br_group.proto = htons(ETH_P_IP);
+
+	return br_multicast_add_group(br, port, &br_group);
+}
+
 static void br_multicast_router_expired(unsigned long data)
 {
 	struct net_bridge_port *port = (void *)data;
@@ -591,19 +652,15 @@ static void br_multicast_local_router_expired(unsigned long data)
 {
 }
 
-static void br_multicast_send_query(struct net_bridge *br,
-				    struct net_bridge_port *port, u32 sent)
+static void __br_multicast_send_query(struct net_bridge *br,
+				      struct net_bridge_port *port,
+				      struct br_ip *ip)
 {
-	unsigned long time;
 	struct sk_buff *skb;
 
-	if (!netif_running(br->dev) || br->multicast_disabled ||
-	    timer_pending(&br->multicast_querier_timer))
-		return;
-
-	skb = br_multicast_alloc_query(br, 0);
+	skb = br_multicast_alloc_query(br, ip);
 	if (!skb)
-		goto timer;
+		return;
 
 	if (port) {
 		__skb_push(skb, sizeof(struct ethhdr));
@@ -612,8 +669,23 @@ static void br_multicast_send_query(struct net_bridge *br,
 			dev_queue_xmit);
 	} else
 		netif_rx(skb);
+}
+
+static void br_multicast_send_query(struct net_bridge *br,
+				    struct net_bridge_port *port, u32 sent)
+{
+	unsigned long time;
+	struct br_ip br_group;
+
+	if (!netif_running(br->dev) || br->multicast_disabled ||
+	    timer_pending(&br->multicast_querier_timer))
+		return;
+
+	br_group.u.ip4 = 0;
+	br_group.proto = htons(ETH_P_IP);
+
+	__br_multicast_send_query(br, port, &br_group);
 
-timer:
 	time = jiffies;
 	time += sent < br->multicast_startup_query_count ?
 		br->multicast_startup_query_interval :
@@ -698,9 +770,9 @@ void br_multicast_disable_port(struct net_bridge_port *port)
 	spin_unlock(&br->multicast_lock);
 }
 
-static int br_multicast_igmp3_report(struct net_bridge *br,
-				     struct net_bridge_port *port,
-				     struct sk_buff *skb)
+static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
+					 struct net_bridge_port *port,
+					 struct sk_buff *skb)
 {
 	struct igmpv3_report *ih;
 	struct igmpv3_grec *grec;
@@ -745,7 +817,7 @@ static int br_multicast_igmp3_report(struct net_bridge *br,
 			continue;
 		}
 
-		err = br_multicast_add_group(br, port, group);
+		err = br_ip4_multicast_add_group(br, port, group);
 		if (err)
 			break;
 	}
@@ -800,7 +872,7 @@ timer:
 
 static void br_multicast_query_received(struct net_bridge *br,
 					struct net_bridge_port *port,
-					__be32 saddr)
+					int saddr)
 {
 	if (saddr)
 		mod_timer(&br->multicast_querier_timer,
@@ -811,9 +883,9 @@ static void br_multicast_query_received(struct net_bridge *br,
 	br_multicast_mark_router(br, port);
 }
 
-static int br_multicast_query(struct net_bridge *br,
-			      struct net_bridge_port *port,
-			      struct sk_buff *skb)
+static int br_ip4_multicast_query(struct net_bridge *br,
+				  struct net_bridge_port *port,
+				  struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 	struct igmphdr *ih = igmp_hdr(skb);
@@ -831,7 +903,7 @@ static int br_multicast_query(struct net_bridge *br,
 	    (port && port->state == BR_STATE_DISABLED))
 		goto out;
 
-	br_multicast_query_received(br, port, iph->saddr);
+	br_multicast_query_received(br, port, !!iph->saddr);
 
 	group = ih->group;
 
@@ -859,7 +931,7 @@ static int br_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	mp = br_mdb_ip_get(br->mdb, group);
+	mp = br_mdb_ip4_get(br->mdb, group);
 	if (!mp)
 		goto out;
 
@@ -885,7 +957,7 @@ out:
 
 static void br_multicast_leave_group(struct net_bridge *br,
 				     struct net_bridge_port *port,
-				     __be32 group)
+				     struct br_ip *group)
 {
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -893,9 +965,6 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	unsigned long now;
 	unsigned long time;
 
-	if (ipv4_is_local_multicast(group))
-		return;
-
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
 	    (port && port->state == BR_STATE_DISABLED) ||
@@ -946,6 +1015,22 @@ out:
 	spin_unlock(&br->multicast_lock);
 }
 
+static void br_ip4_multicast_leave_group(struct net_bridge *br,
+					 struct net_bridge_port *port,
+					 __be32 group)
+{
+	struct br_ip br_group;
+
+	if (ipv4_is_local_multicast(group))
+		return;
+
+	br_group.u.ip4 = group;
+	br_group.proto = htons(ETH_P_IP);
+
+	br_multicast_leave_group(br, port, &br_group);
+}
+
+
 static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
 				 struct sk_buff *skb)
@@ -1023,16 +1108,16 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	case IGMP_HOST_MEMBERSHIP_REPORT:
 	case IGMPV2_HOST_MEMBERSHIP_REPORT:
 		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
-		err = br_multicast_add_group(br, port, ih->group);
+		err = br_ip4_multicast_add_group(br, port, ih->group);
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
-		err = br_multicast_igmp3_report(br, port, skb2);
+		err = br_ip4_multicast_igmp3_report(br, port, skb2);
 		break;
 	case IGMP_HOST_MEMBERSHIP_QUERY:
-		err = br_multicast_query(br, port, skb2);
+		err = br_ip4_multicast_query(br, port, skb2);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
-		br_multicast_leave_group(br, port, ih->group);
+		br_ip4_multicast_leave_group(br, port, ih->group);
 		break;
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 63181e4..45d11e4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -45,6 +45,14 @@ struct mac_addr
 	unsigned char	addr[6];
 };
 
+struct br_ip
+{
+	union {
+		__be32	ip4;
+	} u;
+	__be16		proto;
+};
+
 struct net_bridge_fdb_entry
 {
 	struct hlist_node		hlist;
@@ -64,7 +72,7 @@ struct net_bridge_port_group {
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct timer_list		query_timer;
-	__be32				addr;
+	struct br_ip			addr;
 	u32				queries_sent;
 };
 
@@ -77,7 +85,7 @@ struct net_bridge_mdb_entry
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct timer_list		query_timer;
-	__be32				addr;
+	struct br_ip			addr;
 	u32				queries_sent;
 };
 

---
commit 08b202b6726459626c73ecfa08fcdc8c3efc76c2
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Apr 23 01:54:22 2010 +0900

    bridge br_multicast: IPv6 MLD support.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
index d115d5c..9190ae4 100644
--- a/net/bridge/Kconfig
+++ b/net/bridge/Kconfig
@@ -33,14 +33,14 @@ config BRIDGE
 	  If unsure, say N.
 
 config BRIDGE_IGMP_SNOOPING
-	bool "IGMP snooping"
+	bool "IGMP/MLD snooping"
 	depends on BRIDGE
 	depends on INET
 	default y
 	---help---
 	  If you say Y here, then the Ethernet bridge will be able selectively
-	  forward multicast traffic based on IGMP traffic received from each
-	  port.
+	  forward multicast traffic based on IGMP/MLD traffic received from
+	  each port.
 
 	  Say N to exclude this support and reduce the binary size.
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 64a3e4f..38d1fbd 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -24,9 +24,24 @@
 #include <linux/slab.h>
 #include <linux/timer.h>
 #include <net/ip.h>
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+#include <net/ipv6.h>
+#include <net/mld.h>
+#include <net/addrconf.h>
+#endif
 
 #include "br_private.h"
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline int ipv6_is_local_multicast(const struct in6_addr *addr)
+{
+	if (ipv6_addr_is_multicast(addr) &&
+	    IPV6_ADDR_MC_SCOPE(addr) <= IPV6_ADDR_SCOPE_LINKLOCAL)
+		return 1;
+	return 0;
+}
+#endif
+
 static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 {
 	if (a->proto != b->proto)
@@ -34,6 +49,10 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 	switch (a->proto) {
 	case htons(ETH_P_IP):
 		return a->u.ip4 == b->u.ip4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return ipv6_addr_equal(&a->u.ip6, &b->u.ip6);
+#endif
 	}
 	return 0;
 }
@@ -43,12 +62,24 @@ static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
 	return jhash_1word(mdb->secret, (__force u32)ip) & (mdb->max - 1);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline int __br_ip6_hash(struct net_bridge_mdb_htable *mdb,
+				const struct in6_addr *ip)
+{
+	return jhash2((__force u32 *)ip->s6_addr32, 4, mdb->secret) & (mdb->max - 1);
+}
+#endif
+
 static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
 			     struct br_ip *ip)
 {
 	switch (ip->proto) {
 	case htons(ETH_P_IP):
 		return __br_ip4_hash(mdb, ip->u.ip4);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return __br_ip6_hash(mdb, &ip->u.ip6);
+#endif
 	}
 	return 0;
 }
@@ -78,6 +109,19 @@ static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 	return __br_mdb_ip_get(mdb, &br_dst, __br_ip4_hash(mdb, dst));
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static struct net_bridge_mdb_entry *br_mdb_ip6_get(
+	struct net_bridge_mdb_htable *mdb, const struct in6_addr *dst)
+{
+	struct br_ip br_dst;
+
+	ipv6_addr_copy(&br_dst.u.ip6, dst);
+	br_dst.proto = htons(ETH_P_IPV6);
+
+	return __br_mdb_ip_get(mdb, &br_dst, __br_ip6_hash(mdb, dst));
+}
+#endif
+
 static struct net_bridge_mdb_entry *br_mdb_ip_get(
 	struct net_bridge_mdb_htable *mdb, struct br_ip *dst)
 {
@@ -102,6 +146,11 @@ struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 	case htons(ETH_P_IP):
 		ip.u.ip4 = ip_hdr(skb)->daddr;
 		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		ipv6_addr_copy(&ip.u.ip6, &ipv6_hdr(skb)->daddr);
+		break;
+#endif
 	default:
 		return NULL;
 	}
@@ -352,12 +401,94 @@ out:
 	return skb;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
+						    struct in6_addr *group)
+{
+	struct sk_buff *skb;
+	struct ipv6hdr *ip6h;
+	struct mld_msg *mldq;
+	struct ethhdr *eth;
+	u8 *hopopt;
+	unsigned long interval;
+
+	skb = netdev_alloc_skb_ip_align(br->dev, sizeof(*eth) + sizeof(*ip6h) +
+						 8 + sizeof(*mldq));
+	if (!skb)
+		goto out;
+
+	skb->protocol = htons(ETH_P_IPV6);
+
+	/* Ethernet header */
+	skb_reset_mac_header(skb);
+	eth = eth_hdr(skb);
+
+	memcpy(eth->h_source, br->dev->dev_addr, 6);
+	ipv6_eth_mc_map(group, eth->h_dest);
+	eth->h_proto = htons(ETH_P_IPV6);
+	skb_put(skb, sizeof(*eth));
+
+	/* IPv6 header + HbH option */
+	skb_set_network_header(skb, skb->len);
+	ip6h = ipv6_hdr(skb);
+
+	*(__force __be32 *)ip6h = htonl(0x60000000);
+	ip6h->payload_len = 8 + sizeof(*mldq);
+	ip6h->nexthdr = IPPROTO_HOPOPTS;
+	ip6h->hop_limit = 1;
+	ipv6_addr_set(&ip6h->saddr, 0, 0, 0, 0);
+	ipv6_addr_set(&ip6h->daddr, htonl(0xff020000), 0, 0, htonl(1));
+
+	hopopt = (u8 *)(ip6h + 1);
+	hopopt[0] = IPPROTO_ICMPV6;		/* next hdr */
+	hopopt[1] = 0;				/* length of HbH */
+	hopopt[2] = IPV6_TLV_ROUTERALERT;	/* Router Alert */
+	hopopt[3] = 2;				/* Length of RA Option */
+	hopopt[4] = 0;				/* Type = 0x0000 (MLD) */
+	hopopt[5] = 0;
+	hopopt[6] = IPV6_TLV_PAD0;		/* Pad0 */
+	hopopt[7] = IPV6_TLV_PAD0;		/* Pad0 */
+
+	skb_put(skb, sizeof(*ip6h) + 8);
+
+	/* ICMPv6 */
+	skb_set_transport_header(skb, skb->len);
+	mldq = (struct mld_msg *) icmp6_hdr(skb);
+
+	interval = ipv6_addr_any(group) ? br->multicast_last_member_interval :
+					  br->multicast_query_response_interval;
+
+	mldq->mld_type = ICMPV6_MGM_QUERY;
+	mldq->mld_code = 0;
+	mldq->mld_cksum = 0;
+	mldq->mld_maxdelay = htons((u16)jiffies_to_msecs(interval));
+	mldq->mld_reserved = 0;
+	ipv6_addr_copy(&mldq->mld_mca, group);
+
+	/* checksum */
+	mldq->mld_cksum = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+					  sizeof(*mldq), IPPROTO_ICMPV6,
+					  csum_partial(mldq,
+						       sizeof(*mldq), 0));
+	skb_put(skb, sizeof(*mldq));
+
+	__skb_pull(skb, sizeof(*eth));
+
+out:
+	return skb;
+}
+#endif
+
 static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
 						struct br_ip *addr)
 {
 	switch (addr->proto) {
 	case htons(ETH_P_IP):
 		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return br_ip6_multicast_alloc_query(br, &addr->u.ip6);
+#endif
 	}
 	return NULL;
 }
@@ -631,6 +762,23 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 	return br_multicast_add_group(br, port, &br_group);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_ip6_multicast_add_group(struct net_bridge *br,
+				      struct net_bridge_port *port,
+				      const struct in6_addr *group)
+{
+	struct br_ip br_group;
+
+	if (ipv6_is_local_multicast(group))
+		return 0;
+
+	ipv6_addr_copy(&br_group.u.ip6, group);
+	br_group.proto = htons(ETH_P_IP);
+
+	return br_multicast_add_group(br, port, &br_group);
+}
+#endif
+
 static void br_multicast_router_expired(unsigned long data)
 {
 	struct net_bridge_port *port = (void *)data;
@@ -681,10 +829,15 @@ static void br_multicast_send_query(struct net_bridge *br,
 	    timer_pending(&br->multicast_querier_timer))
 		return;
 
-	br_group.u.ip4 = 0;
+	memset(&br_group.u, 0, sizeof(br_group.u));
+
 	br_group.proto = htons(ETH_P_IP);
+	__br_multicast_send_query(br, port, &br_group);
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	br_group.proto = htons(ETH_P_IPV6);
 	__br_multicast_send_query(br, port, &br_group);
+#endif
 
 	time = jiffies;
 	time += sent < br->multicast_startup_query_count ?
@@ -825,6 +978,66 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 	return err;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_ip6_multicast_mld2_report(struct net_bridge *br,
+					struct net_bridge_port *port,
+					struct sk_buff *skb)
+{
+	struct icmp6hdr *icmp6h;
+	struct mld2_grec *grec;
+	int i;
+	int len;
+	int num;
+	int err = 0;
+
+	if (!pskb_may_pull(skb, sizeof(*icmp6h)))
+		return -EINVAL;
+
+	icmp6h = icmp6_hdr(skb);
+	num = ntohs(icmp6h->icmp6_dataun.un_data16[1]);
+	len = sizeof(*icmp6h);
+
+	for (i = 0; i < num; i++) {
+		__be16 *nsrcs, _nsrcs;
+
+		nsrcs = skb_header_pointer(skb,
+					   len + offsetof(struct mld2_grec,
+							  grec_mca),
+					   sizeof(_nsrcs), &_nsrcs);
+		if (!nsrcs)
+			return -EINVAL;
+
+		if (!pskb_may_pull(skb,
+				   len + sizeof(*grec) +
+				   sizeof(struct in6_addr) * (*nsrcs)))
+			return -EINVAL;
+
+		grec = (struct mld2_grec *)(skb->data + len);
+		len += sizeof(*grec) + sizeof(struct in6_addr) * (*nsrcs);
+
+		/* We treat these as MLDv1 reports for now. */
+		switch (grec->grec_type) {
+		case MLD2_MODE_IS_INCLUDE:
+		case MLD2_MODE_IS_EXCLUDE:
+		case MLD2_CHANGE_TO_INCLUDE:
+		case MLD2_CHANGE_TO_EXCLUDE:
+		case MLD2_ALLOW_NEW_SOURCES:
+		case MLD2_BLOCK_OLD_SOURCES:
+			break;
+
+		default:
+			continue;
+		}
+
+		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca);
+		if (!err)
+			break;
+	}
+
+	return err;
+}
+#endif
+
 static void br_multicast_add_router(struct net_bridge *br,
 				    struct net_bridge_port *port)
 {
@@ -955,6 +1168,75 @@ out:
 	return err;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_ip6_multicast_query(struct net_bridge *br,
+				  struct net_bridge_port *port,
+				  struct sk_buff *skb)
+{
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct mld_msg *mld = (struct mld_msg *) icmp6_hdr(skb);
+	struct net_bridge_mdb_entry *mp;
+	struct mld2_query *mld2q;
+	struct net_bridge_port_group *p, **pp;
+	unsigned long max_delay;
+	unsigned long now = jiffies;
+	struct in6_addr *group = NULL;
+	int err = 0;
+
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev) ||
+	    (port && port->state == BR_STATE_DISABLED))
+		goto out;
+
+	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr));
+
+	if (skb->len == sizeof(*mld)) {
+		if (!pskb_may_pull(skb, sizeof(*mld))) {
+			err = -EINVAL;
+			goto out;
+		}
+		mld = (struct mld_msg *) icmp6_hdr(skb);
+		max_delay = msecs_to_jiffies(htons(mld->mld_maxdelay));
+		if (max_delay)
+			group = &mld->mld_mca;
+	} else if (skb->len >= sizeof(*mld2q)) {
+		if (!pskb_may_pull(skb, sizeof(*mld2q))) {
+			err = -EINVAL;
+			goto out;
+		}
+		mld2q = (struct mld2_query *)icmp6_hdr(skb);
+		if (!mld2q->mld2q_nsrcs)
+			group = &mld2q->mld2q_mca;
+		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(mld2q->mld2q_mrc) : 1;
+	}
+
+	if (!group)
+		goto out;
+
+	mp = br_mdb_ip6_get(br->mdb, group);
+	if (!mp)
+		goto out;
+
+	max_delay *= br->multicast_last_member_count;
+	if (!hlist_unhashed(&mp->mglist) &&
+	    (timer_pending(&mp->timer) ?
+	     time_after(mp->timer.expires, now + max_delay) :
+	     try_to_del_timer_sync(&mp->timer) >= 0))
+		mod_timer(&mp->timer, now + max_delay);
+
+	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+		if (timer_pending(&p->timer) ?
+		    time_after(p->timer.expires, now + max_delay) :
+		    try_to_del_timer_sync(&p->timer) >= 0)
+			mod_timer(&mp->timer, now + max_delay);
+	}
+
+out:
+	spin_unlock(&br->multicast_lock);
+	return err;
+}
+#endif
+
 static void br_multicast_leave_group(struct net_bridge *br,
 				     struct net_bridge_port *port,
 				     struct br_ip *group)
@@ -1030,6 +1312,22 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 	br_multicast_leave_group(br, port, &br_group);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static void br_ip6_multicast_leave_group(struct net_bridge *br,
+					 struct net_bridge_port *port,
+					 const struct in6_addr *group)
+{
+	struct br_ip br_group;
+
+	if (ipv6_is_local_multicast(group))
+		return;
+
+	ipv6_addr_copy(&br_group.u.ip6, group);
+	br_group.proto = htons(ETH_P_IPV6);
+
+	br_multicast_leave_group(br, port, &br_group);
+}
+#endif
 
 static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
@@ -1129,6 +1427,126 @@ err_out:
 	return err;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_multicast_ipv6_rcv(struct net_bridge *br,
+				 struct net_bridge_port *port,
+				 struct sk_buff *skb)
+{
+	struct sk_buff *skb2 = skb;
+	struct ipv6hdr *ip6h;
+	struct icmp6hdr *icmp6h;
+	u8 nexthdr;
+	unsigned len;
+	unsigned offset;
+	int err;
+
+	BR_INPUT_SKB_CB(skb)->igmp = 0;
+	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
+
+	if (!pskb_may_pull(skb, sizeof(*ip6h)))
+		return -EINVAL;
+
+	ip6h = ipv6_hdr(skb);
+
+	/*
+	 * We're interested in MLD messages only.
+	 *  - Version is 6
+	 *  - MLD has always Router Alert hop-by-hop option
+	 *  - But we do not support jumbrograms.
+	 */
+	if (ip6h->version != 6 ||
+	    ip6h->nexthdr != IPPROTO_HOPOPTS ||
+	    ip6h->payload_len == 0)
+		return 0;
+
+	len = ntohs(ip6h->payload_len);
+	if (skb->len < len)
+		return -EINVAL;
+
+	nexthdr = ip6h->nexthdr;
+	offset = ipv6_skip_exthdr(skb, sizeof(*ip6h), &nexthdr);
+
+	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
+		return 0;
+
+	/* Okay, we found ICMPv6 header */
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+	if (!skb2)
+		return -ENOMEM;
+
+	len -= offset - skb_network_offset(skb2);
+
+	__skb_pull(skb2, offset);
+	skb_reset_transport_header(skb2);
+
+	err = -EINVAL;
+	if (!pskb_may_pull(skb2, sizeof(*icmp6h)))
+		goto out;
+
+	icmp6h = icmp6_hdr(skb2);
+
+	switch (icmp6h->icmp6_type) {
+	case ICMPV6_MGM_QUERY:
+	case ICMPV6_MGM_REPORT:
+	case ICMPV6_MGM_REDUCTION:
+	case ICMPV6_MLD2_REPORT:
+		break;
+	default:
+		err = 0;
+		goto out;
+	}
+
+	/* Okay, we found MLD message. Check further. */
+	if (skb2->len > len) {
+		err = pskb_trim_rcsum(skb2, len);
+		if (err)
+			goto out;
+	}
+
+	switch (skb2->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		if (!csum_fold(skb2->csum))
+			break;
+		/*FALLTHROUGH*/
+	case CHECKSUM_NONE:
+		skb2->csum = 0;
+		if (skb_checksum_complete(skb2))
+			goto out;
+	}
+
+	err = 0;
+
+	BR_INPUT_SKB_CB(skb)->igmp = 1;
+
+	switch (icmp6h->icmp6_type) {
+	case ICMPV6_MGM_REPORT:
+	    {
+		struct mld_msg *mld = (struct mld_msg *)icmp6h;
+		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
+		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca);
+		break;
+	    }
+	case ICMPV6_MLD2_REPORT:
+		err = br_ip6_multicast_mld2_report(br, port, skb2);
+		break;
+	case ICMPV6_MGM_QUERY:
+		err = br_ip6_multicast_query(br, port, skb2);
+		break;
+	case ICMPV6_MGM_REDUCTION:
+	    {
+		struct mld_msg *mld = (struct mld_msg *)icmp6h;
+		br_ip6_multicast_leave_group(br, port, &mld->mld_mca);
+	    }
+	}
+
+out:
+	__skb_push(skb2, offset);
+	if (skb2 != skb)
+		kfree_skb(skb2);
+	return err;
+}
+#endif
+
 int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 		     struct sk_buff *skb)
 {
@@ -1138,6 +1556,10 @@ int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		return br_multicast_ipv4_rcv(br, port, skb);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return br_multicast_ipv6_rcv(br, port, skb);
+#endif
 	}
 
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 45d11e4..018499e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -49,6 +49,9 @@ struct br_ip
 {
 	union {
 		__be32	ip4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		struct in6_addr ip6;
+#endif
 	} u;
 	__be16		proto;
 };

---
