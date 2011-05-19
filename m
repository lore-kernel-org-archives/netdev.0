From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: reduce per device ICMP mib sizes
Date: Thu, 19 May 2011 13:14:23 +0200
Message-ID: <1305803663.3028.39.camel@edumazet-laptop>
References: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
	 <1305787158.3019.12.camel@edumazet-laptop>
	 <1305788113.3019.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58667 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932075Ab1ESLO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 07:14:27 -0400
Received: by wwa36 with SMTP id 36so2757958wwa.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 04:14:26 -0700 (PDT)
In-Reply-To: <1305788113.3019.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 08:55 +0200, Eric Dumazet a =C3=A9crit :

> Looking at snmp6_alloc_dev(), we allocate three mib per device :
>=20
> ipstats_mib  (30 * sizeof(u64) * number_of_possible_cpus)
> icmpv6_mib    (4 * sizeof(long) * number_of_possible_cpus)
> icmpv6msg_mib  (26 * sizeof(long))
>=20

Oops, I forgot that mibs were doubled (one set for USER, one set for BH=
)

And :
#define __ICMP6MSG_MIB_MAX 512

So icmpv6msg_mib is really 512*sizeof(long)*number_of_possible_cpus*2=20

32 kbytes per device on a 8cpu machine, 32bit kernel.

Plus all other mibs... yes thats way too big for a seldom used stuff.

Here is patch I cooked and tested on my machine :

[PATCH net-next-2.6] ipv6: reduce per device ICMP mib sizes.

ipv6 has per device ICMP SNMP counters, taking too much space because
they use percpu storage.

needed size per device is :=20
(512+4)*sizeof(long)*number_of_possible_cpus*2=20

On a 32bit kernel, 16 possible cpus, this wastes more than 64kbytes of
memory per ipv6 enabled network device, taken in vmalloc pool.

Since ICMP messages are rare, just use shared counters (atomic_long_t)

Per network space ICMP counters are still using percpu memory, we might
also convert them to shared counters in a future patch.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Denys Fedoryshchenko <denys@visp.net.lb>
---
 include/net/if_inet6.h |    4 +--
 include/net/ipv6.h     |   19 +++++++++++++-----
 include/net/snmp.h     |   14 +++++++++++++
 net/ipv6/addrconf.c    |   24 +++++++++++------------
 net/ipv6/proc.c        |   40 +++++++++++++++++++++++++--------------
 5 files changed, 68 insertions(+), 33 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 0c603fe..11cf373 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -154,8 +154,8 @@ struct ifacaddr6 {
 struct ipv6_devstat {
 	struct proc_dir_entry	*proc_dir_entry;
 	DEFINE_SNMP_STAT(struct ipstats_mib, ipv6);
-	DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6);
-	DEFINE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg);
+	DEFINE_SNMP_STAT_ATOMIC(struct icmpv6_mib_device, icmpv6dev);
+	DEFINE_SNMP_STAT_ATOMIC(struct icmpv6msg_mib_device, icmpv6msgdev);
 };
=20
 struct inet6_dev {
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e1c60b4..c033ed0 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -123,6 +123,15 @@ extern struct ctl_path net_ipv6_ctl_path[];
 	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));\
 })
=20
+/* per device counters are atomic_long_t */
+#define _DEVINCATOMIC(net, statname, modifier, idev, field)		\
+({									\
+	struct inet6_dev *_idev =3D (idev);				\
+	if (likely(_idev !=3D NULL))					\
+		SNMP_INC_STATS_ATOMIC_LONG((_idev)->stats.statname##dev, (field)); \
+	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));\
+})
+
 #define _DEVADD(net, statname, modifier, idev, field, val)		\
 ({									\
 	struct inet6_dev *_idev =3D (idev);				\
@@ -154,16 +163,16 @@ extern struct ctl_path net_ipv6_ctl_path[];
 #define IP6_UPD_PO_STATS_BH(net, idev,field,val)   \
 		_DEVUPD(net, ipv6, 64_BH, idev, field, val)
 #define ICMP6_INC_STATS(net, idev, field)	\
-		_DEVINC(net, icmpv6, , idev, field)
+		_DEVINCATOMIC(net, icmpv6, , idev, field)
 #define ICMP6_INC_STATS_BH(net, idev, field)	\
-		_DEVINC(net, icmpv6, _BH, idev, field)
+		_DEVINCATOMIC(net, icmpv6, _BH, idev, field)
=20
 #define ICMP6MSGOUT_INC_STATS(net, idev, field)		\
-	_DEVINC(net, icmpv6msg, , idev, field +256)
+	_DEVINCATOMIC(net, icmpv6msg, , idev, field +256)
 #define ICMP6MSGOUT_INC_STATS_BH(net, idev, field)	\
-	_DEVINC(net, icmpv6msg, _BH, idev, field +256)
+	_DEVINCATOMIC(net, icmpv6msg, _BH, idev, field +256)
 #define ICMP6MSGIN_INC_STATS_BH(net, idev, field)	\
-	_DEVINC(net, icmpv6msg, _BH, idev, field)
+	_DEVINCATOMIC(net, icmpv6msg, _BH, idev, field)
=20
 struct ip6_ra_chain {
 	struct ip6_ra_chain	*next;
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 27461d6..479083a 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -72,14 +72,24 @@ struct icmpmsg_mib {
=20
 /* ICMP6 (IPv6-ICMP) */
 #define ICMP6_MIB_MAX	__ICMP6_MIB_MAX
+/* per network ns counters */
 struct icmpv6_mib {
 	unsigned long	mibs[ICMP6_MIB_MAX];
 };
+/* per device counters, (shared on all cpus) */
+struct icmpv6_mib_device {
+	atomic_long_t	mibs[ICMP6_MIB_MAX];
+};
=20
 #define ICMP6MSG_MIB_MAX  __ICMP6MSG_MIB_MAX
+/* per network ns counters */
 struct icmpv6msg_mib {
 	unsigned long	mibs[ICMP6MSG_MIB_MAX];
 };
+/* per device counters, (shared on all cpus) */
+struct icmpv6msg_mib_device {
+	atomic_long_t	mibs[ICMP6MSG_MIB_MAX];
+};
=20
=20
 /* TCP */
@@ -114,6 +124,8 @@ struct linux_xfrm_mib {
  */=20
 #define DEFINE_SNMP_STAT(type, name)	\
 	__typeof__(type) __percpu *name[2]
+#define DEFINE_SNMP_STAT_ATOMIC(type, name)	\
+	__typeof__(type) *name
 #define DECLARE_SNMP_STAT(type, name)	\
 	extern __typeof__(type) __percpu *name[2]
=20
@@ -124,6 +136,8 @@ struct linux_xfrm_mib {
 			__this_cpu_inc(mib[0]->mibs[field])
 #define SNMP_INC_STATS_USER(mib, field)	\
 			this_cpu_inc(mib[1]->mibs[field])
+#define SNMP_INC_STATS_ATOMIC_LONG(mib, field)	\
+			atomic_long_inc(&mib->mibs[field])
 #define SNMP_INC_STATS(mib, field)	\
 			this_cpu_inc(mib[!in_softirq()]->mibs[field])
 #define SNMP_DEC_STATS(mib, field)	\
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f2f9b2e..3cfbbf3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -289,19 +289,19 @@ static int snmp6_alloc_dev(struct inet6_dev *idev=
)
 			  sizeof(struct ipstats_mib),
 			  __alignof__(struct ipstats_mib)) < 0)
 		goto err_ip;
-	if (snmp_mib_init((void __percpu **)idev->stats.icmpv6,
-			  sizeof(struct icmpv6_mib),
-			  __alignof__(struct icmpv6_mib)) < 0)
+	idev->stats.icmpv6dev =3D kzalloc(sizeof(struct icmpv6_mib_device),
+					GFP_KERNEL);
+	if (!idev->stats.icmpv6dev)
 		goto err_icmp;
-	if (snmp_mib_init((void __percpu **)idev->stats.icmpv6msg,
-			  sizeof(struct icmpv6msg_mib),
-			  __alignof__(struct icmpv6msg_mib)) < 0)
+	idev->stats.icmpv6msgdev =3D kzalloc(sizeof(struct icmpv6msg_mib_devi=
ce),
+					   GFP_KERNEL);
+	if (!idev->stats.icmpv6msgdev)
 		goto err_icmpmsg;
=20
 	return 0;
=20
 err_icmpmsg:
-	snmp_mib_free((void __percpu **)idev->stats.icmpv6);
+	kfree(idev->stats.icmpv6dev);
 err_icmp:
 	snmp_mib_free((void __percpu **)idev->stats.ipv6);
 err_ip:
@@ -310,8 +310,8 @@ err_ip:
=20
 static void snmp6_free_dev(struct inet6_dev *idev)
 {
-	snmp_mib_free((void __percpu **)idev->stats.icmpv6msg);
-	snmp_mib_free((void __percpu **)idev->stats.icmpv6);
+	kfree(idev->stats.icmpv6msgdev);
+	kfree(idev->stats.icmpv6dev);
 	snmp_mib_free((void __percpu **)idev->stats.ipv6);
 }
=20
@@ -3838,7 +3838,7 @@ static inline size_t inet6_if_nlmsg_size(void)
 	       + nla_total_size(inet6_ifla6_size()); /* IFLA_PROTINFO */
 }
=20
-static inline void __snmp6_fill_stats(u64 *stats, void __percpu **mib,
+static inline void __snmp6_fill_statsdev(u64 *stats, atomic_long_t *mi=
b,
 				      int items, int bytes)
 {
 	int i;
@@ -3848,7 +3848,7 @@ static inline void __snmp6_fill_stats(u64 *stats,=
 void __percpu **mib,
 	/* Use put_unaligned() because stats may not be aligned for u64. */
 	put_unaligned(items, &stats[0]);
 	for (i =3D 1; i < items; i++)
-		put_unaligned(snmp_fold_field(mib, i), &stats[i]);
+		put_unaligned(atomic_long_read(&mib[i]), &stats[i]);
=20
 	memset(&stats[items], 0, pad);
 }
@@ -3877,7 +3877,7 @@ static void snmp6_fill_stats(u64 *stats, struct i=
net6_dev *idev, int attrtype,
 				     IPSTATS_MIB_MAX, bytes, offsetof(struct ipstats_mib, syncp));
 		break;
 	case IFLA_INET6_ICMP6STATS:
-		__snmp6_fill_stats(stats, (void __percpu **)idev->stats.icmpv6, ICMP=
6_MIB_MAX, bytes);
+		__snmp6_fill_statsdev(stats, idev->stats.icmpv6dev->mibs, ICMP6_MIB_=
MAX, bytes);
 		break;
 	}
 }
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 24b3558..18ff5df 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -141,7 +141,11 @@ static const struct snmp_mib snmp6_udplite6_list[]=
 =3D {
 	SNMP_MIB_SENTINEL
 };
=20
-static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void __perc=
pu **mib)
+/* can be called either with percpu mib (pcpumib !=3D NULL),
+ * or shared one (smib !=3D NULL)
+ */
+static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void __perc=
pu **pcpumib,
+				     atomic_long_t *smib)
 {
 	char name[32];
 	int i;
@@ -158,14 +162,14 @@ static void snmp6_seq_show_icmpv6msg(struct seq_f=
ile *seq, void __percpu **mib)
 		snprintf(name, sizeof(name), "Icmp6%s%s",
 			i & 0x100 ? "Out" : "In", p);
 		seq_printf(seq, "%-32s\t%lu\n", name,
-			snmp_fold_field(mib, i));
+			pcpumib ? snmp_fold_field(pcpumib, i) : atomic_long_read(smib + i))=
;
 	}
=20
 	/* print by number (nonzero only) - ICMPMsgStat format */
 	for (i =3D 0; i < ICMP6MSG_MIB_MAX; i++) {
 		unsigned long val;
=20
-		val =3D snmp_fold_field(mib, i);
+		val =3D pcpumib ? snmp_fold_field(pcpumib, i) : atomic_long_read(smi=
b + i);
 		if (!val)
 			continue;
 		snprintf(name, sizeof(name), "Icmp6%sType%u",
@@ -174,14 +178,22 @@ static void snmp6_seq_show_icmpv6msg(struct seq_f=
ile *seq, void __percpu **mib)
 	}
 }
=20
-static void snmp6_seq_show_item(struct seq_file *seq, void __percpu **=
mib,
+/* can be called either with percpu mib (pcpumib !=3D NULL),
+ * or shared one (smib !=3D NULL)
+ */
+static void snmp6_seq_show_item(struct seq_file *seq, void __percpu **=
pcpumib,
+				atomic_long_t *smib,
 				const struct snmp_mib *itemlist)
 {
 	int i;
+	unsigned long val;
=20
-	for (i =3D 0; itemlist[i].name; i++)
-		seq_printf(seq, "%-32s\t%lu\n", itemlist[i].name,
-			   snmp_fold_field(mib, itemlist[i].entry));
+	for (i =3D 0; itemlist[i].name; i++) {
+		val =3D pcpumib ?
+			snmp_fold_field(pcpumib, itemlist[i].entry) :
+			atomic_long_read(smib + itemlist[i].entry);
+		seq_printf(seq, "%-32s\t%lu\n", itemlist[i].name, val);
+	}
 }
=20
 static void snmp6_seq_show_item64(struct seq_file *seq, void __percpu =
**mib,
@@ -201,13 +213,13 @@ static int snmp6_seq_show(struct seq_file *seq, v=
oid *v)
 	snmp6_seq_show_item64(seq, (void __percpu **)net->mib.ipv6_statistics=
,
 			    snmp6_ipstats_list, offsetof(struct ipstats_mib, syncp));
 	snmp6_seq_show_item(seq, (void __percpu **)net->mib.icmpv6_statistics=
,
-			    snmp6_icmp6_list);
+			    NULL, snmp6_icmp6_list);
 	snmp6_seq_show_icmpv6msg(seq,
-			    (void __percpu **)net->mib.icmpv6msg_statistics);
+			    (void __percpu **)net->mib.icmpv6msg_statistics, NULL);
 	snmp6_seq_show_item(seq, (void __percpu **)net->mib.udp_stats_in6,
-			    snmp6_udp6_list);
+			    NULL, snmp6_udp6_list);
 	snmp6_seq_show_item(seq, (void __percpu **)net->mib.udplite_stats_in6=
,
-			    snmp6_udplite6_list);
+			    NULL, snmp6_udplite6_list);
 	return 0;
 }
=20
@@ -229,11 +241,11 @@ static int snmp6_dev_seq_show(struct seq_file *se=
q, void *v)
 	struct inet6_dev *idev =3D (struct inet6_dev *)seq->private;
=20
 	seq_printf(seq, "%-32s\t%u\n", "ifIndex", idev->dev->ifindex);
-	snmp6_seq_show_item(seq, (void __percpu **)idev->stats.ipv6,
+	snmp6_seq_show_item(seq, (void __percpu **)idev->stats.ipv6, NULL,
 			    snmp6_ipstats_list);
-	snmp6_seq_show_item(seq, (void __percpu **)idev->stats.icmpv6,
+	snmp6_seq_show_item(seq, NULL, idev->stats.icmpv6dev->mibs,
 			    snmp6_icmp6_list);
-	snmp6_seq_show_icmpv6msg(seq, (void __percpu **)idev->stats.icmpv6msg=
);
+	snmp6_seq_show_icmpv6msg(seq, NULL, idev->stats.icmpv6msgdev->mibs);
 	return 0;
 }
=20


