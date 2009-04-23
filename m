From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Thu, 23 Apr 2009 14:28:39 -0400
Message-ID: <20090423182839.GD30405@hmsreliant.think-freely.org>
References: <49EEE4F1.4020705@cosmosbay.com> <20090422.025003.92631170.davem@davemloft.net> <20090422165034.GC17947@hmsreliant.think-freely.org> <49EF566B.70203@cosmosbay.com> <20090423152823.GA30405@hmsreliant.think-freely.org> <49F09933.2010200@cosmosbay.com> <20090423165620.GB30405@hmsreliant.think-freely.org> <49F0A1C8.5080601@cosmosbay.com> <20090423172524.GC30405@hmsreliant.think-freely.org> <49F0A641.90303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nhorman@tuxdriver.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35528 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987AbZDWS2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 14:28:47 -0400
Content-Disposition: inline
In-Reply-To: <49F0A641.90303@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 07:32:49PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
>=20
> > Perhaps we could define the size of each counter at compile time, s=
o that at
> > least 64 bit systems can have sane counters?
>=20
> Well, mibs are "unsigned long", so are 64 bits on these systems.
>=20
> >=20
> > Btw, I will repost one more time to take in the above enhancement y=
ou suggested
> > regarding the limited use of per_cpu_ptr and in_softirq (my last po=
st made it
> > sound like I wouldnt)
>=20
> OK, thanks
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


Ok, last time (I hope :)). New patch, functionally identially.  changes=
 are:

1) Incorporate Erics suggestion to improve efficiency of SNMP_UPD_PO_ST=
ATS*
macros by reduing use of in_softirq and per_cpu_ptr.


The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMcastOct=
ets and
OutMcastOctets:
http://tools.ietf.org/html/rfc4293
But it seems we don't track those in any way that easy to separate from=
 other
protocols.  This patch adds those missing counters to the stats file. T=
ested
successfully by me

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/snmp.h  |   10 ++++++++--
 include/net/ip.h      |    3 +++
 include/net/ipv6.h    |   15 ++++++++++++++-
 include/net/snmp.h    |   19 ++++++++++++++++++-
 net/ipv4/ip_input.c   |   13 ++++++++-----
 net/ipv4/ip_output.c  |   14 +++++++-------
 net/ipv4/proc.c       |   10 ++++++++--
 net/ipv6/ip6_input.c  |    7 ++++---
 net/ipv6/ip6_output.c |    9 +++++----
 net/ipv6/mcast.c      |   11 ++++++-----
 net/ipv6/ndisc.c      |    4 ++--
 net/ipv6/proc.c       |   10 ++++++++--
 net/ipv6/raw.c        |    2 +-
 13 files changed, 92 insertions(+), 35 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index aee3f1e..0f953fe 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -18,7 +18,7 @@
 enum
 {
 	IPSTATS_MIB_NUM =3D 0,
-	IPSTATS_MIB_INRECEIVES,			/* InReceives */
+	IPSTATS_MIB_INPKTS,			/* InReceives */
 	IPSTATS_MIB_INHDRERRORS,		/* InHdrErrors */
 	IPSTATS_MIB_INTOOBIGERRORS,		/* InTooBigErrors */
 	IPSTATS_MIB_INNOROUTES,			/* InNoRoutes */
@@ -28,7 +28,7 @@ enum
 	IPSTATS_MIB_INDISCARDS,			/* InDiscards */
 	IPSTATS_MIB_INDELIVERS,			/* InDelivers */
 	IPSTATS_MIB_OUTFORWDATAGRAMS,		/* OutForwDatagrams */
-	IPSTATS_MIB_OUTREQUESTS,		/* OutRequests */
+	IPSTATS_MIB_OUTPKTS,			/* OutRequests */
 	IPSTATS_MIB_OUTDISCARDS,		/* OutDiscards */
 	IPSTATS_MIB_OUTNOROUTES,		/* OutNoRoutes */
 	IPSTATS_MIB_REASMTIMEOUT,		/* ReasmTimeout */
@@ -42,6 +42,12 @@ enum
 	IPSTATS_MIB_OUTMCASTPKTS,		/* OutMcastPkts */
 	IPSTATS_MIB_INBCASTPKTS,		/* InBcastPkts */
 	IPSTATS_MIB_OUTBCASTPKTS,		/* OutBcastPkts */
+	IPSTATS_MIB_INOCTETS,			/* InOctets */
+	IPSTATS_MIB_OUTOCTETS,			/* OutOctets */
+	IPSTATS_MIB_INMCASTOCTETS,		/* InMcastOctets */
+	IPSTATS_MIB_OUTMCASTOCTETS,		/* OutMcastOctets */
+	IPSTATS_MIB_INBCASTOCTETS,		/* InBcastOctets */
+	IPSTATS_MIB_OUTBCASTOCTETS,		/* OutBcastOctets */
 	__IPSTATS_MIB_MAX
 };
=20
diff --git a/include/net/ip.h b/include/net/ip.h
index 4ac7577..72c3692 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -168,7 +168,10 @@ struct ipv4_config
 extern struct ipv4_config ipv4_config;
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ip_statisti=
cs, field)
 #define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip_st=
atistics, field)
+#define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.ip_sta=
tistics, field, val)
 #define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH((net)->mib.=
ip_statistics, field, val)
+#define IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS((net)->mib.=
ip_statistics, field, val)
+#define IP_UPD_PO_STATS_BH(net, field, val) SNMP_UPD_PO_STATS_BH((net)=
->mib.ip_statistics, field, val)
 #define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statis=
tics, field)
 #define NET_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.net_=
statistics, field)
 #define NET_INC_STATS_USER(net, field) 	SNMP_INC_STATS_USER((net)->mib=
=2Enet_statistics, field)
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c1f16fc..f27fd83 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -126,15 +126,28 @@ extern struct ctl_path net_ipv6_ctl_path[];
 	SNMP_ADD_STATS##modifier((net)->mib.statname##_statistics, (field), (=
val));\
 })
=20
+#define _DEVUPD(net, statname, modifier, idev, field, val)		\
+({									\
+	struct inet6_dev *_idev =3D (idev);				\
+	if (likely(_idev !=3D NULL))					\
+		SNMP_UPD_PO_STATS##modifier((_idev)->stats.statname, field, (val)); =
\
+	SNMP_UPD_PO_STATS##modifier((net)->mib.statname##_statistics, field, =
(val));\
+})
+
 /* MIBs */
=20
 #define IP6_INC_STATS(net, idev,field)		\
 		_DEVINC(net, ipv6, , idev, field)
 #define IP6_INC_STATS_BH(net, idev,field)	\
 		_DEVINC(net, ipv6, _BH, idev, field)
+#define IP6_ADD_STATS(net, idev,field,val)	\
+		_DEVADD(net, ipv6, , idev, field, val)
 #define IP6_ADD_STATS_BH(net, idev,field,val)	\
 		_DEVADD(net, ipv6, _BH, idev, field, val)
-
+#define IP6_UPD_PO_STATS(net, idev,field,val)   \
+		_DEVUPD(net, ipv6, , idev, field, val)
+#define IP6_UPD_PO_STATS_BH(net, idev,field,val)   \
+		_DEVUPD(net, ipv6, _BH, idev, field, val)
 #define ICMP6_INC_STATS(net, idev, field)	\
 		_DEVINC(net, icmpv6, , idev, field)
 #define ICMP6_INC_STATS_BH(net, idev, field)	\
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 57c9362..8c842e0 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -153,6 +153,11 @@ struct linux_xfrm_mib {
 		per_cpu_ptr(mib[!in_softirq()], get_cpu())->mibs[field]--; \
 		put_cpu(); \
 	} while (0)
+#define SNMP_ADD_STATS(mib, field, addend) 	\
+	do { \
+		per_cpu_ptr(mib[!in_softirq()], get_cpu())->mibs[field] +=3D addend;=
 \
+		put_cpu(); \
+	} while (0)
 #define SNMP_ADD_STATS_BH(mib, field, addend) 	\
 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field] +=3D addend=
)
 #define SNMP_ADD_STATS_USER(mib, field, addend) 	\
@@ -160,5 +165,17 @@ struct linux_xfrm_mib {
 		per_cpu_ptr(mib[1], get_cpu())->mibs[field] +=3D addend; \
 		put_cpu(); \
 	} while (0)
-
+#define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
+	do { \
+		__typeof__(mib[0]) ptr =3D per_cpu_ptr(mib[!in_softirq()], get_cpu()=
);\
+		ptr->mibs[basefield##PKTS]++; \
+		ptr->mibs[basefield##OCTETS] +=3D addend;\
+		put_cpu(); \
+	} while (0)
+#define SNMP_UPD_PO_STATS_BH(mib, basefield, addend)	\
+	do { \
+		__typeof__(mib[0]) ptr =3D per_cpu_ptr(mib[!in_softirq()], raw_smp_p=
rocessor_id());\
+		ptr->mibs[basefield##PKTS]++; \
+		ptr->mibs[basefield##OCTETS] +=3D addend;\
+	} while (0)
 #endif
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 1a58a6f..40f6206 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -358,10 +358,12 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		goto drop;
=20
 	rt =3D skb->rtable;
-	if (rt->rt_type =3D=3D RTN_MULTICAST)
-		IP_INC_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INMCASTPKTS);
-	else if (rt->rt_type =3D=3D RTN_BROADCAST)
-		IP_INC_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INBCASTPKTS);
+	if (rt->rt_type =3D=3D RTN_MULTICAST) {
+		IP_UPD_PO_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INMCAST,
+				skb->len);
+	} else if (rt->rt_type =3D=3D RTN_BROADCAST)
+		IP_UPD_PO_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INBCAST,
+				skb->len);
=20
 	return dst_input(skb);
=20
@@ -384,7 +386,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *=
dev, struct packet_type *pt,
 	if (skb->pkt_type =3D=3D PACKET_OTHERHOST)
 		goto drop;
=20
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INRECEIVES);
+
+	IP_UPD_PO_STATS_BH(dev_net(dev), IPSTATS_MIB_IN, skb->len);
=20
 	if ((skb =3D skb_share_check(skb, GFP_ATOMIC)) =3D=3D NULL) {
 		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3e7e910..991041c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -181,10 +181,10 @@ static inline int ip_finish_output2(struct sk_buf=
f *skb)
 	struct net_device *dev =3D dst->dev;
 	unsigned int hh_len =3D LL_RESERVED_SPACE(dev);
=20
-	if (rt->rt_type =3D=3D RTN_MULTICAST)
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTMCASTPKTS);
-	else if (rt->rt_type =3D=3D RTN_BROADCAST)
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTBCASTPKTS);
+	if (rt->rt_type =3D=3D RTN_MULTICAST) {
+		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUTMCAST, skb->len);
+	} else if (rt->rt_type =3D=3D RTN_BROADCAST)
+		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUTBCAST, skb->len);
=20
 	/* Be paranoid, rather than too clever. */
 	if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
@@ -244,8 +244,8 @@ int ip_mc_output(struct sk_buff *skb)
 	/*
 	 *	If the indicated interface is up and running, send the packet.
 	 */
-	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
-
+	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+=09
 	skb->dev =3D dev;
 	skb->protocol =3D htons(ETH_P_IP);
=20
@@ -298,7 +298,7 @@ int ip_output(struct sk_buff *skb)
 {
 	struct net_device *dev =3D skb->dst->dev;
=20
-	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
+	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
=20
 	skb->dev =3D dev;
 	skb->protocol =3D htons(ETH_P_IP);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index cf0cdee..f25542c 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -90,14 +90,14 @@ static const struct file_operations sockstat_seq_fo=
ps =3D {
=20
 /* snmp items */
 static const struct snmp_mib snmp4_ipstats_list[] =3D {
-	SNMP_MIB_ITEM("InReceives", IPSTATS_MIB_INRECEIVES),
+	SNMP_MIB_ITEM("InReceives", IPSTATS_MIB_INPKTS),
 	SNMP_MIB_ITEM("InHdrErrors", IPSTATS_MIB_INHDRERRORS),
 	SNMP_MIB_ITEM("InAddrErrors", IPSTATS_MIB_INADDRERRORS),
 	SNMP_MIB_ITEM("ForwDatagrams", IPSTATS_MIB_OUTFORWDATAGRAMS),
 	SNMP_MIB_ITEM("InUnknownProtos", IPSTATS_MIB_INUNKNOWNPROTOS),
 	SNMP_MIB_ITEM("InDiscards", IPSTATS_MIB_INDISCARDS),
 	SNMP_MIB_ITEM("InDelivers", IPSTATS_MIB_INDELIVERS),
-	SNMP_MIB_ITEM("OutRequests", IPSTATS_MIB_OUTREQUESTS),
+	SNMP_MIB_ITEM("OutRequests", IPSTATS_MIB_OUTPKTS),
 	SNMP_MIB_ITEM("OutDiscards", IPSTATS_MIB_OUTDISCARDS),
 	SNMP_MIB_ITEM("OutNoRoutes", IPSTATS_MIB_OUTNOROUTES),
 	SNMP_MIB_ITEM("ReasmTimeout", IPSTATS_MIB_REASMTIMEOUT),
@@ -118,6 +118,12 @@ static const struct snmp_mib snmp4_ipextstats_list=
[] =3D {
 	SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
 	SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
 	SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
+	SNMP_MIB_ITEM("InOctets", IPSTATS_MIB_INOCTETS),
+	SNMP_MIB_ITEM("OutOctets", IPSTATS_MIB_OUTOCTETS),
+	SNMP_MIB_ITEM("InMcastOctets", IPSTATS_MIB_INMCASTOCTETS),
+	SNMP_MIB_ITEM("OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
+	SNMP_MIB_ITEM("InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
+	SNMP_MIB_ITEM("OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 8f04bd9..bc1a920 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -70,7 +70,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *=
dev, struct packet_type *pt
=20
 	idev =3D __in6_dev_get(skb->dev);
=20
-	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INRECEIVES);
+	IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_IN, skb->len);
=20
 	if ((skb =3D skb_share_check(skb, GFP_ATOMIC)) =3D=3D NULL ||
 	    !idev || unlikely(idev->cnf.disable_ipv6)) {
@@ -242,8 +242,9 @@ int ip6_mc_input(struct sk_buff *skb)
 	struct ipv6hdr *hdr;
 	int deliver;
=20
-	IP6_INC_STATS_BH(dev_net(skb->dst->dev),
-			 ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCASTPKTS);
+	IP6_UPD_PO_STATS_BH(dev_net(skb->dst->dev),
+			 ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCAST,
+			 skb->len);
=20
 	hdr =3D ipv6_hdr(skb);
 	deliver =3D ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9fb49c3..735a2bf 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -159,7 +159,8 @@ static int ip6_output2(struct sk_buff *skb)
 			}
 		}
=20
-		IP6_INC_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_UPD_PO_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCAST,
+				skb->len);
 	}
=20
 	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
@@ -275,8 +276,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, =
struct flowi *fl,
=20
 	mtu =3D dst_mtu(dst);
 	if ((skb->len <=3D mtu) || skb->local_df || skb_is_gso(skb)) {
-		IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
-			      IPSTATS_MIB_OUTREQUESTS);
+		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb->dst),
+			      IPSTATS_MIB_OUT, skb->len);
 		return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
 	}
@@ -1516,7 +1517,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb->mark =3D sk->sk_mark;
=20
 	skb->dst =3D dst_clone(&rt->u.dst);
-	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
 	if (proto =3D=3D IPPROTO_ICMPV6) {
 		struct inet6_dev *idev =3D ip6_dst_idev(skb->dst);
=20
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index a51fb33..7434f73 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1449,7 +1449,8 @@ static void mld_sendpack(struct sk_buff *skb)
 	int err;
 	struct flowi fl;
=20
-	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
+
 	payload_len =3D (skb->tail - skb->network_header) - sizeof(*pip6);
 	mldlen =3D skb->tail - skb->transport_header;
 	pip6->payload_len =3D htons(payload_len);
@@ -1479,7 +1480,7 @@ out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS_BH(net, idev, ICMPV6_MLD2_REPORT);
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
-		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_OUTMCAST, skb->len);
 	} else
 		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
=20
@@ -1774,8 +1775,8 @@ static void igmp6_send(struct in6_addr *addr, str=
uct net_device *dev, int type)
 	struct flowi fl;
=20
 	rcu_read_lock();
-	IP6_INC_STATS(net, __in6_dev_get(dev),
-		      IPSTATS_MIB_OUTREQUESTS);
+	IP6_UPD_PO_STATS(net, __in6_dev_get(dev),
+		      IPSTATS_MIB_OUT, skb->len);
 	rcu_read_unlock();
 	if (type =3D=3D ICMPV6_MGM_REDUCTION)
 		snd_addr =3D &in6addr_linklocal_allrouters;
@@ -1844,7 +1845,7 @@ out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
-		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, skb->len);
 	} else
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
=20
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9f061d1..ab65cc5 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -533,7 +533,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 	skb->dst =3D dst;
=20
 	idev =3D in6_dev_get(dst->dev);
-	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
=20
 	err =3D NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 		      dst_output);
@@ -1613,7 +1613,7 @@ void ndisc_send_redirect(struct sk_buff *skb, str=
uct neighbour *neigh,
=20
 	buff->dst =3D dst;
 	idev =3D in6_dev_get(dst->dev);
-	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 	err =3D NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
 		      dst_output);
 	if (!err) {
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 97c17fd..590ddef 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -61,7 +61,7 @@ static const struct file_operations sockstat6_seq_fop=
s =3D {
=20
 static struct snmp_mib snmp6_ipstats_list[] =3D {
 /* ipv6 mib according to RFC 2465 */
-	SNMP_MIB_ITEM("Ip6InReceives", IPSTATS_MIB_INRECEIVES),
+	SNMP_MIB_ITEM("Ip6InReceives", IPSTATS_MIB_INPKTS),
 	SNMP_MIB_ITEM("Ip6InHdrErrors", IPSTATS_MIB_INHDRERRORS),
 	SNMP_MIB_ITEM("Ip6InTooBigErrors", IPSTATS_MIB_INTOOBIGERRORS),
 	SNMP_MIB_ITEM("Ip6InNoRoutes", IPSTATS_MIB_INNOROUTES),
@@ -71,7 +71,7 @@ static struct snmp_mib snmp6_ipstats_list[] =3D {
 	SNMP_MIB_ITEM("Ip6InDiscards", IPSTATS_MIB_INDISCARDS),
 	SNMP_MIB_ITEM("Ip6InDelivers", IPSTATS_MIB_INDELIVERS),
 	SNMP_MIB_ITEM("Ip6OutForwDatagrams", IPSTATS_MIB_OUTFORWDATAGRAMS),
-	SNMP_MIB_ITEM("Ip6OutRequests", IPSTATS_MIB_OUTREQUESTS),
+	SNMP_MIB_ITEM("Ip6OutRequests", IPSTATS_MIB_OUTPKTS),
 	SNMP_MIB_ITEM("Ip6OutDiscards", IPSTATS_MIB_OUTDISCARDS),
 	SNMP_MIB_ITEM("Ip6OutNoRoutes", IPSTATS_MIB_OUTNOROUTES),
 	SNMP_MIB_ITEM("Ip6ReasmTimeout", IPSTATS_MIB_REASMTIMEOUT),
@@ -83,6 +83,12 @@ static struct snmp_mib snmp6_ipstats_list[] =3D {
 	SNMP_MIB_ITEM("Ip6FragCreates", IPSTATS_MIB_FRAGCREATES),
 	SNMP_MIB_ITEM("Ip6InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
 	SNMP_MIB_ITEM("Ip6OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
+	SNMP_MIB_ITEM("Ip6InOctets", IPSTATS_MIB_INOCTETS),
+	SNMP_MIB_ITEM("Ip6OutOctets", IPSTATS_MIB_OUTOCTETS),
+	SNMP_MIB_ITEM("Ip6InMcastOctets", IPSTATS_MIB_INMCASTOCTETS),
+	SNMP_MIB_ITEM("Ip6OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
+	SNMP_MIB_ITEM("Ip6InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
+	SNMP_MIB_ITEM("Ip6OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 61f6827..e99307f 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -638,7 +638,7 @@ static int rawv6_send_hdrinc(struct sock *sk, void =
*from, int length,
 	if (err)
 		goto error_fault;
=20
-	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_UPD_PO_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUT, skb->l=
en);
 	err =3D NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev=
,
 		      dst_output);
 	if (err > 0)
