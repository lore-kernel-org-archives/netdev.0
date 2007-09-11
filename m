From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH][2/2] Add ICMPMsgStats MIB (RFC 4293)
Date: Mon, 10 Sep 2007 21:12:36 -0600
Message-ID: <OFEACEAA0F.CED91D65-ON88257353.00117603-88257353.00118EE6@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 00118EE488257353_="
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:39611 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965630AbXIKDMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 23:12:39 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8B3CcLX002944
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 23:12:38 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8B3Ccon456538
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 21:12:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8B3Cc2a002650
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 21:12:38 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_mixed 00118EE488257353_=
Content-Type: text/plain; charset="US-ASCII"

Background: RFC 4293 deprecates existing individual, named ICMP
type counters to be replaced with the ICMPMsgStatsTable. This table
includes entries for both IPv4 and IPv6, and requires counting of all
ICMP types, whether or not the machine implements the type.

These patches "remove" (but not really) the existing counters, and
replace them with the ICMPMsgStats tables for v4 and v6.
It includes the named counters in the /proc places they were, but gets the
values for them from the new tables. It also counts packets generated
from raw socket output (e.g., OutEchoes, MLD queries, RA's from
radvd, etc).

Changes:
1) create icmpmsg_statistics mib
2) create icmpv6msg_statistics mib
3) modify existing counters to use these
4) modify /proc/net/snmp to add "IcmpMsg" with all ICMP types
        listed by number for easy SNMP parsing
5) modify /proc/net/snmp printing for "Icmp" to get the named data
        from new counters.

IPv6 patch attached.

                                        +-DLS

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp linux-2.6.22.5/include/linux/snmp.h 
linux-2.6.22.5_ICMPv6MSG/include/linux/snmp.h
--- linux-2.6.22.5/include/linux/snmp.h 2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG/include/linux/snmp.h       2007-09-10 
15:02:43.000000000 -0700
@@ -91,35 +91,12 @@ enum
        ICMP6_MIB_NUM = 0,
        ICMP6_MIB_INMSGS,                       /* InMsgs */
        ICMP6_MIB_INERRORS,                     /* InErrors */
-       ICMP6_MIB_INDESTUNREACHS,               /* InDestUnreachs */
-       ICMP6_MIB_INPKTTOOBIGS,                 /* InPktTooBigs */
-       ICMP6_MIB_INTIMEEXCDS,                  /* InTimeExcds */
-       ICMP6_MIB_INPARMPROBLEMS,               /* InParmProblems */
-       ICMP6_MIB_INECHOS,                      /* InEchos */
-       ICMP6_MIB_INECHOREPLIES,                /* InEchoReplies */
-       ICMP6_MIB_INGROUPMEMBQUERIES,           /* InGroupMembQueries */
-       ICMP6_MIB_INGROUPMEMBRESPONSES,         /* InGroupMembResponses */
-       ICMP6_MIB_INGROUPMEMBREDUCTIONS,        /* InGroupMembReductions 
*/
-       ICMP6_MIB_INROUTERSOLICITS,             /* InRouterSolicits */
-       ICMP6_MIB_INROUTERADVERTISEMENTS,       /* InRouterAdvertisements 
*/
-       ICMP6_MIB_INNEIGHBORSOLICITS,           /* InNeighborSolicits */
-       ICMP6_MIB_INNEIGHBORADVERTISEMENTS,     /* 
InNeighborAdvertisements */
-       ICMP6_MIB_INREDIRECTS,                  /* InRedirects */
        ICMP6_MIB_OUTMSGS,                      /* OutMsgs */
-       ICMP6_MIB_OUTDESTUNREACHS,              /* OutDestUnreachs */
-       ICMP6_MIB_OUTPKTTOOBIGS,                /* OutPktTooBigs */
-       ICMP6_MIB_OUTTIMEEXCDS,                 /* OutTimeExcds */
-       ICMP6_MIB_OUTPARMPROBLEMS,              /* OutParmProblems */
-       ICMP6_MIB_OUTECHOREPLIES,               /* OutEchoReplies */
-       ICMP6_MIB_OUTROUTERSOLICITS,            /* OutRouterSolicits */
-       ICMP6_MIB_OUTNEIGHBORSOLICITS,          /* OutNeighborSolicits */
-       ICMP6_MIB_OUTNEIGHBORADVERTISEMENTS,    /* 
OutNeighborAdvertisements */
-       ICMP6_MIB_OUTREDIRECTS,                 /* OutRedirects */
-       ICMP6_MIB_OUTGROUPMEMBRESPONSES,        /* OutGroupMembResponses 
*/
-       ICMP6_MIB_OUTGROUPMEMBREDUCTIONS,       /* OutGroupMembReductions 
*/
        __ICMP6_MIB_MAX
 };
 
+#define __ICMP6MSG_MIB_MAX 512 /* Out+In for all 8-bit ICMPv6 types */
+
 /* tcp mib definitions */
 /*
  * RFC 1213:  MIB-II TCP group
diff -ruNp linux-2.6.22.5/include/net/ipv6.h 
linux-2.6.22.5_ICMPv6MSG/include/net/ipv6.h
--- linux-2.6.22.5/include/net/ipv6.h   2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG/include/net/ipv6.h 2007-09-10 
15:41:19.000000000 -0700
@@ -132,6 +132,7 @@ DECLARE_SNMP_STAT(struct ipstats_mib, ip
        SNMP_INC_STATS_USER(ipv6_statistics, field);                    \
 })
 DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
+DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
 #define ICMP6_INC_STATS(idev, field)           ({                      \
        struct inet6_dev *_idev = (idev);                               \
        if (likely(_idev != NULL))                                      \
@@ -157,6 +158,14 @@ DECLARE_SNMP_STAT(struct icmpv6_mib, icm
                SNMP_INC_STATS_OFFSET_BH(_idev->stats.icmpv6, field, 
_offset);       \
        SNMP_INC_STATS_OFFSET_BH(icmpv6_statistics, field, _offset); \
 })
+
+#define ICMP6MSGOUT_INC_STATS(field) SNMP_INC_STATS(icmpv6msg_statistics, 
field+256)
+#define ICMP6MSGOUT_INC_STATS_BH(field) 
SNMP_INC_STATS_BH(icmpv6msg_statistics, field+256)
+#define ICMP6MSGOUT_INC_STATS_USER(field) 
SNMP_INC_STATS_USER(icmpv6msg_statistics, field+256)
+#define ICMP6MSGIN_INC_STATS(field) SNMP_INC_STATS(icmpv6msg_statistics, 
field)
+#define ICMP6MSGIN_INC_STATS_BH(field) 
SNMP_INC_STATS_BH(icmpv6msg_statistics, field)
+#define ICMP6MSGIN_INC_STATS_USER(field) 
SNMP_INC_STATS_USER(icmpv6msg_statistics, field)
+
 DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 #define UDP6_INC_STATS_BH(field, is_udplite)                         do { 
 \
diff -ruNp linux-2.6.22.5/include/net/snmp.h 
linux-2.6.22.5_ICMPv6MSG/include/net/snmp.h
--- linux-2.6.22.5/include/net/snmp.h   2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG/include/net/snmp.h 2007-09-10 
15:00:18.000000000 -0700
@@ -88,6 +88,12 @@ struct icmpv6_mib {
        unsigned long   mibs[ICMP6_MIB_MAX];
 } __SNMP_MIB_ALIGN__;
 
+#define ICMP6MSG_MIB_MAX  __ICMP6MSG_MIB_MAX
+struct icmpv6msg_mib {
+       unsigned long   mibs[ICMP6MSG_MIB_MAX];
+} __SNMP_MIB_ALIGN__;
+
+
 /* TCP */
 #define TCP_MIB_MAX    __TCP_MIB_MAX
 struct tcp_mib {
diff -ruNp linux-2.6.22.5/net/ipv6/af_inet6.c 
linux-2.6.22.5_ICMPv6MSG/net/ipv6/af_inet6.c
--- linux-2.6.22.5/net/ipv6/af_inet6.c  2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG/net/ipv6/af_inet6.c        2007-09-10 
14:19:57.000000000 -0700
@@ -719,6 +719,9 @@ static int __init init_ipv6_mibs(void)
        if (snmp_mib_init((void **)icmpv6_statistics, sizeof (struct 
icmpv6_mib),
                          __alignof__(struct icmpv6_mib)) < 0)
                goto err_icmp_mib;
+       if (snmp_mib_init((void **)icmpv6msg_statistics,
+           sizeof (struct icmpv6msg_mib), __alignof__(struct icmpv6_mib)) 
< 0)
+               goto err_icmpmsg_mib;
        if (snmp_mib_init((void **)udp_stats_in6, sizeof (struct udp_mib),
                          __alignof__(struct udp_mib)) < 0)
                goto err_udp_mib;
@@ -730,6 +733,8 @@ static int __init init_ipv6_mibs(void)
 err_udplite_mib:
        snmp_mib_free((void **)udp_stats_in6);
 err_udp_mib:
+       snmp_mib_free((void **)icmpv6msg_statistics);
+err_icmpmsg_mib:
        snmp_mib_free((void **)icmpv6_statistics);
 err_icmp_mib:
        snmp_mib_free((void **)ipv6_statistics);
diff -ruNp linux-2.6.22.5/net/ipv6/icmp.c 
linux-2.6.22.5_ICMPv6MSG/net/ipv6/icmp.c
--- linux-2.6.22.5/net/ipv6/icmp.c      2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG/net/ipv6/icmp.c    2007-09-10 
15:24:27.000000000 -0700
@@ -69,6 +69,8 @@
 
 DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics) __read_mostly;
 EXPORT_SYMBOL(icmpv6_statistics);
+DEFINE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics) 
__read_mostly;
+EXPORT_SYMBOL(icmpv6msg_statistics);
 
 /*
  *     The ICMP socket(s). This is the most convenient way to flow 
control
@@ -247,6 +249,7 @@ static int icmpv6_push_pending_frames(st
                                                      len, fl->proto,
                                                      tmp_csum);
        }
+       ICMP6MSGOUT_INC_STATS_BH(icmp6h->icmp6_type);
        ip6_push_pending_frames(sk);
 out:
        return err;
@@ -456,8 +459,6 @@ void icmpv6_send(struct sk_buff *skb, in
        }
        err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, len + 
sizeof(struct icmp6hdr));
 
-       if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
-               ICMP6_INC_STATS_OFFSET_BH(idev, ICMP6_MIB_OUTDESTUNREACHS, 
type - ICMPV6_DEST_UNREACH);
        ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
 
 out_put:
@@ -547,7 +548,6 @@ static void icmpv6_echo_reply(struct sk_
        }
        err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, skb->len + 
sizeof(struct icmp6hdr));
 
-       ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTECHOREPLIES);
        ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
 
 out_put:
@@ -656,10 +656,7 @@ static int icmpv6_rcv(struct sk_buff **p
 
        type = hdr->icmp6_type;
 
-       if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
-               ICMP6_INC_STATS_OFFSET_BH(idev, ICMP6_MIB_INDESTUNREACHS, 
type - ICMPV6_DEST_UNREACH);
-       else if (type >= ICMPV6_ECHO_REQUEST && type <= NDISC_REDIRECT)
-               ICMP6_INC_STATS_OFFSET_BH(idev, ICMP6_MIB_INECHOS, type - 
ICMPV6_ECHO_REQUEST);
+       ICMP6MSGIN_INC_STATS_BH(type);
 
        switch (type) {
        case ICMPV6_ECHO_REQUEST:
diff -ruNp linux-2.6.22.5/net/ipv6/mcast.c 
linux-2.6.22.5_ICMPv6MSG/net/ipv6/mcast.c
--- linux-2.6.22.5/net/ipv6/mcast.c     2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG/net/ipv6/mcast.c   2007-09-10 
14:24:33.000000000 -0700
@@ -1478,6 +1478,7 @@ static void mld_sendpack(struct sk_buff 
        err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
                mld_dev_queue_xmit);
        if (!err) {
+               ICMP6MSGOUT_INC_STATS(ICMPV6_MLD2_REPORT);
                ICMP6_INC_STATS(idev,ICMP6_MIB_OUTMSGS);
                IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
        } else
@@ -1821,10 +1822,7 @@ static void igmp6_send(struct in6_addr *
        err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
                mld_dev_queue_xmit);
        if (!err) {
-               if (type == ICMPV6_MGM_REDUCTION)
-                       ICMP6_INC_STATS(idev, 
ICMP6_MIB_OUTGROUPMEMBREDUCTIONS);
-               else
-                       ICMP6_INC_STATS(idev, 
ICMP6_MIB_OUTGROUPMEMBRESPONSES);
+               ICMP6MSGOUT_INC_STATS(type);
                ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
                IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
        } else
diff -ruNp linux-2.6.22.5/net/ipv6/ndisc.c 
linux-2.6.22.5_ICMPv6MSG/net/ipv6/ndisc.c
--- linux-2.6.22.5/net/ipv6/ndisc.c     2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG/net/ipv6/ndisc.c   2007-09-10 
15:04:51.000000000 -0700
@@ -431,7 +431,7 @@ static void __ndisc_send(struct net_devi
                         struct neighbour *neigh,
                         struct in6_addr *daddr, struct in6_addr *saddr,
                         struct icmp6hdr *icmp6h, struct in6_addr *target,
-                        int llinfo, int icmp6_mib_outnd)
+                        int llinfo)
 {
        struct flowi fl;
        struct dst_entry *dst;
@@ -441,9 +441,11 @@ static void __ndisc_send(struct net_devi
        struct inet6_dev *idev;
        int len;
        int err;
-       u8 *opt;
+       u8 *opt, type;
+
+       type = icmp6h->icmp6_type;
 
-       ndisc_flow_init(&fl, icmp6h->icmp6_type, saddr, daddr,
+       ndisc_flow_init(&fl, type, saddr, daddr,
                        dev->ifindex);
 
        dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output);
@@ -504,7 +506,7 @@ static void __ndisc_send(struct net_devi
 
        err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, 
dst_output);
        if (!err) {
-               ICMP6_INC_STATS(idev, icmp6_mib_outnd);
+               ICMP6MSGOUT_INC_STATS(type);
                ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
        }
 
@@ -542,8 +544,7 @@ static void ndisc_send_na(struct net_dev
 
        __ndisc_send(dev, neigh, daddr, src_addr,
                     &icmp6h, solicited_addr,
-                    inc_opt ? ND_OPT_TARGET_LL_ADDR : 0,
-                    ICMP6_MIB_OUTNEIGHBORADVERTISEMENTS);
+                    inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
 }
 
 void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
@@ -564,8 +565,7 @@ void ndisc_send_ns(struct net_device *de
 
        __ndisc_send(dev, neigh, daddr, saddr,
                     &icmp6h, solicit,
-                    !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0,
-                    ICMP6_MIB_OUTNEIGHBORSOLICITS);
+                    !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
 
 void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
@@ -599,8 +599,7 @@ void ndisc_send_rs(struct net_device *de
 #endif
        __ndisc_send(dev, NULL, daddr, saddr,
                     &icmp6h, NULL,
-                    send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0,
-                    ICMP6_MIB_OUTROUTERSOLICITS);
+                    send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
 
 
@@ -1454,7 +1453,7 @@ void ndisc_send_redirect(struct sk_buff 
        IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
        err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, 
dst_output);
        if (!err) {
-               ICMP6_INC_STATS(idev, ICMP6_MIB_OUTREDIRECTS);
+               ICMP6MSGOUT_INC_STATS(NDISC_REDIRECT);
                ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
        }
 
diff -ruNp linux-2.6.22.5/net/ipv6/proc.c 
linux-2.6.22.5_ICMPv6MSG/net/ipv6/proc.c
--- linux-2.6.22.5/net/ipv6/proc.c      2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG/net/ipv6/proc.c    2007-09-10 
15:15:31.000000000 -0700
@@ -85,47 +85,33 @@ static struct snmp_mib snmp6_ipstats_lis
 };
 
 static struct snmp_mib snmp6_icmp6_list[] = {
-/* icmpv6 mib according to RFC 2466
-
-   Exceptions:  {In|Out}AdminProhibs are removed, because I see
-               no good reasons to account them separately
-               of another dest.unreachs.
-               OutErrs is zero identically.
-               OutEchos too.
-               OutRouterAdvertisements too.
-               OutGroupMembQueries too.
- */
+/* icmpv6 mib according to RFC 2466 */
        SNMP_MIB_ITEM("Icmp6InMsgs", ICMP6_MIB_INMSGS),
        SNMP_MIB_ITEM("Icmp6InErrors", ICMP6_MIB_INERRORS),
-       SNMP_MIB_ITEM("Icmp6InDestUnreachs", ICMP6_MIB_INDESTUNREACHS),
-       SNMP_MIB_ITEM("Icmp6InPktTooBigs", ICMP6_MIB_INPKTTOOBIGS),
-       SNMP_MIB_ITEM("Icmp6InTimeExcds", ICMP6_MIB_INTIMEEXCDS),
-       SNMP_MIB_ITEM("Icmp6InParmProblems", ICMP6_MIB_INPARMPROBLEMS),
-       SNMP_MIB_ITEM("Icmp6InEchos", ICMP6_MIB_INECHOS),
-       SNMP_MIB_ITEM("Icmp6InEchoReplies", ICMP6_MIB_INECHOREPLIES),
-       SNMP_MIB_ITEM("Icmp6InGroupMembQueries", 
ICMP6_MIB_INGROUPMEMBQUERIES),
-       SNMP_MIB_ITEM("Icmp6InGroupMembResponses", 
ICMP6_MIB_INGROUPMEMBRESPONSES),
-       SNMP_MIB_ITEM("Icmp6InGroupMembReductions", 
ICMP6_MIB_INGROUPMEMBREDUCTIONS),
-       SNMP_MIB_ITEM("Icmp6InRouterSolicits", 
ICMP6_MIB_INROUTERSOLICITS),
-       SNMP_MIB_ITEM("Icmp6InRouterAdvertisements", 
ICMP6_MIB_INROUTERADVERTISEMENTS),
-       SNMP_MIB_ITEM("Icmp6InNeighborSolicits", 
ICMP6_MIB_INNEIGHBORSOLICITS),
-       SNMP_MIB_ITEM("Icmp6InNeighborAdvertisements", 
ICMP6_MIB_INNEIGHBORADVERTISEMENTS),
-       SNMP_MIB_ITEM("Icmp6InRedirects", ICMP6_MIB_INREDIRECTS),
        SNMP_MIB_ITEM("Icmp6OutMsgs", ICMP6_MIB_OUTMSGS),
-       SNMP_MIB_ITEM("Icmp6OutDestUnreachs", ICMP6_MIB_OUTDESTUNREACHS),
-       SNMP_MIB_ITEM("Icmp6OutPktTooBigs", ICMP6_MIB_OUTPKTTOOBIGS),
-       SNMP_MIB_ITEM("Icmp6OutTimeExcds", ICMP6_MIB_OUTTIMEEXCDS),
-       SNMP_MIB_ITEM("Icmp6OutParmProblems", ICMP6_MIB_OUTPARMPROBLEMS),
-       SNMP_MIB_ITEM("Icmp6OutEchoReplies", ICMP6_MIB_OUTECHOREPLIES),
-       SNMP_MIB_ITEM("Icmp6OutRouterSolicits", 
ICMP6_MIB_OUTROUTERSOLICITS),
-       SNMP_MIB_ITEM("Icmp6OutNeighborSolicits", 
ICMP6_MIB_OUTNEIGHBORSOLICITS),
-       SNMP_MIB_ITEM("Icmp6OutNeighborAdvertisements", 
ICMP6_MIB_OUTNEIGHBORADVERTISEMENTS),
-       SNMP_MIB_ITEM("Icmp6OutRedirects", ICMP6_MIB_OUTREDIRECTS),
-       SNMP_MIB_ITEM("Icmp6OutGroupMembResponses", 
ICMP6_MIB_OUTGROUPMEMBRESPONSES),
-       SNMP_MIB_ITEM("Icmp6OutGroupMembReductions", 
ICMP6_MIB_OUTGROUPMEMBREDUCTIONS),
        SNMP_MIB_SENTINEL
 };
 
+/* RFC 4293 v6 ICMPMsgStatsTable; named items for RFC 2466 compatibility 
*/
+static char *icmp6type2name[256] = {
+       [ICMPV6_DEST_UNREACH] = "DestUnreachs",
+       [ICMPV6_PKT_TOOBIG] = "PktTooBigs",
+       [ICMPV6_TIME_EXCEED] = "TimeExcds",
+       [ICMPV6_PARAMPROB] = "ParmProblems",
+       [ICMPV6_ECHO_REQUEST] = "EchoRequest",
+       [ICMPV6_ECHO_REPLY] = "EchoReplies",
+       [ICMPV6_MGM_QUERY] = "GroupMembQueries",
+       [ICMPV6_MGM_REPORT] = "GroupMembResponses",
+       [ICMPV6_MGM_REDUCTION] = "GroupMembReductions",
+       [ICMPV6_MLD2_REPORT] = "MLDv2Reports",
+       [NDISC_ROUTER_ADVERTISEMENT] = "RouterAdvertisements",
+       [NDISC_ROUTER_SOLICITATION] = "RouterSolicits",
+       [NDISC_NEIGHBOUR_ADVERTISEMENT] = "NeighborAdvertisements",
+       [NDISC_NEIGHBOUR_SOLICITATION] = "NeighborSolicits",
+       [NDISC_REDIRECT] = "NeighborRedirects",
+};
+
+
 static struct snmp_mib snmp6_udp6_list[] = {
        SNMP_MIB_ITEM("Udp6InDatagrams", UDP_MIB_INDATAGRAMS),
        SNMP_MIB_ITEM("Udp6NoPorts", UDP_MIB_NOPORTS),
@@ -142,6 +128,40 @@ static struct snmp_mib snmp6_udplite6_li
        SNMP_MIB_SENTINEL
 };
 
+static void snmp6_seq_show_icmpv6msg(struct seq_file *seq)
+{
+       static char name[32];
+       int i;
+
+       /* print by name -- deprecated items */
+       for (i = 0; i < ICMP6MSG_MIB_MAX; i++) {
+               int icmptype;
+               char *p;
+
+               icmptype = i & 0xff;
+               p = icmp6type2name[icmptype];
+               if (!p) /* don't print un-named types here */
+                       continue;
+               (void) snprintf(name, sizeof(name)-1, "Icmp6%s%s",
+                       i & 0x100 ? "Out" : "In", p);
+               seq_printf(seq, "%-32s\t%lu\n", name,
+                       snmp_fold_field((void **) icmpv6msg_statistics, 
i));
+       }
+
+       /* print by number (nonzero only) - ICMPMsgStat format */
+       for (i = 0; i < ICMP6MSG_MIB_MAX; i++) {
+               unsigned long val;
+
+               val = snmp_fold_field((void **) icmpv6msg_statistics, i);
+               if (!val)
+                       continue;
+               (void) snprintf(name, sizeof(name)-1, "Icmp6%sType%u",
+                       i & 0x100 ?  "Out" : "In", i & 0xff);
+               seq_printf(seq, "%-32s\t%lu\n", name, val);
+       }
+       return;
+}
+
 static inline void
 snmp6_seq_show_item(struct seq_file *seq, void **mib, struct snmp_mib 
*itemlist)
 {
@@ -162,6 +182,7 @@ static int snmp6_seq_show(struct seq_fil
        } else {
                snmp6_seq_show_item(seq, (void **)ipv6_statistics, 
snmp6_ipstats_list);
                snmp6_seq_show_item(seq, (void **)icmpv6_statistics, 
snmp6_icmp6_list);
+               snmp6_seq_show_icmpv6msg(seq);
                snmp6_seq_show_item(seq, (void **)udp_stats_in6, 
snmp6_udp6_list);
                snmp6_seq_show_item(seq, (void **)udplite_stats_in6, 
snmp6_udplite6_list);
        }
diff -ruNp linux-2.6.22.5/net/ipv6/raw.c 
linux-2.6.22.5_ICMPv6MSG/net/ipv6/raw.c
--- linux-2.6.22.5/net/ipv6/raw.c       2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG/net/ipv6/raw.c     2007-09-10 
15:09:37.000000000 -0700
@@ -543,6 +543,11 @@ static int rawv6_push_pending_frames(str
        if (skb_store_bits(skb, offset, &csum, 2))
                BUG();
 
+       if (fl->proto == IPPROTO_ICMPV6) {
+               ICMP6_INC_STATS_BH(NULL, ICMP6_MIB_OUTMSGS);
+               ICMP6MSGOUT_INC_STATS_BH(icmp6_hdr(skb)->icmp6_type);
+       }
+
 send:
        err = ip6_push_pending_frames(sk);
 out:


--=_mixed 00118EE488257353_=
Content-Type: application/octet-stream; name="icmpmsgmib6.patch"
Content-Disposition: attachment; filename="icmpmsgmib6.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMjIuNS9pbmNsdWRlL2xpbnV4L3NubXAuaCBsaW51eC0yLjYu
MjIuNV9JQ01QdjZNU0cvaW5jbHVkZS9saW51eC9zbm1wLmgKLS0tIGxpbnV4LTIuNi4yMi41L2lu
Y2x1ZGUvbGludXgvc25tcC5oCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0wNzAwCisr
KyBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cvaW5jbHVkZS9saW51eC9zbm1wLmgJMjAwNy0wOS0x
MCAxNTowMjo0My4wMDAwMDAwMDAgLTA3MDAKQEAgLTkxLDM1ICs5MSwxMiBAQCBlbnVtCiAJSUNN
UDZfTUlCX05VTSA9IDAsCiAJSUNNUDZfTUlCX0lOTVNHUywJCQkvKiBJbk1zZ3MgKi8KIAlJQ01Q
Nl9NSUJfSU5FUlJPUlMsCQkJLyogSW5FcnJvcnMgKi8KLQlJQ01QNl9NSUJfSU5ERVNUVU5SRUFD
SFMsCQkvKiBJbkRlc3RVbnJlYWNocyAqLwotCUlDTVA2X01JQl9JTlBLVFRPT0JJR1MsCQkJLyog
SW5Qa3RUb29CaWdzICovCi0JSUNNUDZfTUlCX0lOVElNRUVYQ0RTLAkJCS8qIEluVGltZUV4Y2Rz
ICovCi0JSUNNUDZfTUlCX0lOUEFSTVBST0JMRU1TLAkJLyogSW5QYXJtUHJvYmxlbXMgKi8KLQlJ
Q01QNl9NSUJfSU5FQ0hPUywJCQkvKiBJbkVjaG9zICovCi0JSUNNUDZfTUlCX0lORUNIT1JFUExJ
RVMsCQkvKiBJbkVjaG9SZXBsaWVzICovCi0JSUNNUDZfTUlCX0lOR1JPVVBNRU1CUVVFUklFUywJ
CS8qIEluR3JvdXBNZW1iUXVlcmllcyAqLwotCUlDTVA2X01JQl9JTkdST1VQTUVNQlJFU1BPTlNF
UywJCS8qIEluR3JvdXBNZW1iUmVzcG9uc2VzICovCi0JSUNNUDZfTUlCX0lOR1JPVVBNRU1CUkVE
VUNUSU9OUywJLyogSW5Hcm91cE1lbWJSZWR1Y3Rpb25zICovCi0JSUNNUDZfTUlCX0lOUk9VVEVS
U09MSUNJVFMsCQkvKiBJblJvdXRlclNvbGljaXRzICovCi0JSUNNUDZfTUlCX0lOUk9VVEVSQURW
RVJUSVNFTUVOVFMsCS8qIEluUm91dGVyQWR2ZXJ0aXNlbWVudHMgKi8KLQlJQ01QNl9NSUJfSU5O
RUlHSEJPUlNPTElDSVRTLAkJLyogSW5OZWlnaGJvclNvbGljaXRzICovCi0JSUNNUDZfTUlCX0lO
TkVJR0hCT1JBRFZFUlRJU0VNRU5UUywJLyogSW5OZWlnaGJvckFkdmVydGlzZW1lbnRzICovCi0J
SUNNUDZfTUlCX0lOUkVESVJFQ1RTLAkJCS8qIEluUmVkaXJlY3RzICovCiAJSUNNUDZfTUlCX09V
VE1TR1MsCQkJLyogT3V0TXNncyAqLwotCUlDTVA2X01JQl9PVVRERVNUVU5SRUFDSFMsCQkvKiBP
dXREZXN0VW5yZWFjaHMgKi8KLQlJQ01QNl9NSUJfT1VUUEtUVE9PQklHUywJCS8qIE91dFBrdFRv
b0JpZ3MgKi8KLQlJQ01QNl9NSUJfT1VUVElNRUVYQ0RTLAkJCS8qIE91dFRpbWVFeGNkcyAqLwot
CUlDTVA2X01JQl9PVVRQQVJNUFJPQkxFTVMsCQkvKiBPdXRQYXJtUHJvYmxlbXMgKi8KLQlJQ01Q
Nl9NSUJfT1VURUNIT1JFUExJRVMsCQkvKiBPdXRFY2hvUmVwbGllcyAqLwotCUlDTVA2X01JQl9P
VVRST1VURVJTT0xJQ0lUUywJCS8qIE91dFJvdXRlclNvbGljaXRzICovCi0JSUNNUDZfTUlCX09V
VE5FSUdIQk9SU09MSUNJVFMsCQkvKiBPdXROZWlnaGJvclNvbGljaXRzICovCi0JSUNNUDZfTUlC
X09VVE5FSUdIQk9SQURWRVJUSVNFTUVOVFMsCS8qIE91dE5laWdoYm9yQWR2ZXJ0aXNlbWVudHMg
Ki8KLQlJQ01QNl9NSUJfT1VUUkVESVJFQ1RTLAkJCS8qIE91dFJlZGlyZWN0cyAqLwotCUlDTVA2
X01JQl9PVVRHUk9VUE1FTUJSRVNQT05TRVMsCS8qIE91dEdyb3VwTWVtYlJlc3BvbnNlcyAqLwot
CUlDTVA2X01JQl9PVVRHUk9VUE1FTUJSRURVQ1RJT05TLAkvKiBPdXRHcm91cE1lbWJSZWR1Y3Rp
b25zICovCiAJX19JQ01QNl9NSUJfTUFYCiB9OwogCisjZGVmaW5lIF9fSUNNUDZNU0dfTUlCX01B
WCA1MTIgLyogT3V0K0luIGZvciBhbGwgOC1iaXQgSUNNUHY2IHR5cGVzICovCisKIC8qIHRjcCBt
aWIgZGVmaW5pdGlvbnMgKi8KIC8qCiAgKiBSRkMgMTIxMzogIE1JQi1JSSBUQ1AgZ3JvdXAKZGlm
ZiAtcnVOcCBsaW51eC0yLjYuMjIuNS9pbmNsdWRlL25ldC9pcHY2LmggbGludXgtMi42LjIyLjVf
SUNNUHY2TVNHL2luY2x1ZGUvbmV0L2lwdjYuaAotLS0gbGludXgtMi42LjIyLjUvaW5jbHVkZS9u
ZXQvaXB2Ni5oCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0y
LjYuMjIuNV9JQ01QdjZNU0cvaW5jbHVkZS9uZXQvaXB2Ni5oCTIwMDctMDktMTAgMTU6NDE6MTku
MDAwMDAwMDAwIC0wNzAwCkBAIC0xMzIsNiArMTMyLDcgQEAgREVDTEFSRV9TTk1QX1NUQVQoc3Ry
dWN0IGlwc3RhdHNfbWliLCBpcAogCVNOTVBfSU5DX1NUQVRTX1VTRVIoaXB2Nl9zdGF0aXN0aWNz
LCBmaWVsZCk7CQkJXAogfSkKIERFQ0xBUkVfU05NUF9TVEFUKHN0cnVjdCBpY21wdjZfbWliLCBp
Y21wdjZfc3RhdGlzdGljcyk7CitERUNMQVJFX1NOTVBfU1RBVChzdHJ1Y3QgaWNtcHY2bXNnX21p
YiwgaWNtcHY2bXNnX3N0YXRpc3RpY3MpOwogI2RlZmluZSBJQ01QNl9JTkNfU1RBVFMoaWRldiwg
ZmllbGQpCQkoewkJCVwKIAlzdHJ1Y3QgaW5ldDZfZGV2ICpfaWRldiA9IChpZGV2KTsJCQkJXAog
CWlmIChsaWtlbHkoX2lkZXYgIT0gTlVMTCkpCQkJCQlcCkBAIC0xNTcsNiArMTU4LDE0IEBAIERF
Q0xBUkVfU05NUF9TVEFUKHN0cnVjdCBpY21wdjZfbWliLCBpY20KIAkJU05NUF9JTkNfU1RBVFNf
T0ZGU0VUX0JIKF9pZGV2LT5zdGF0cy5pY21wdjYsIGZpZWxkLCBfb2Zmc2V0KTsJXAogCVNOTVBf
SU5DX1NUQVRTX09GRlNFVF9CSChpY21wdjZfc3RhdGlzdGljcywgZmllbGQsIF9vZmZzZXQpOyAg
ICAJXAogfSkKKworI2RlZmluZSBJQ01QNk1TR09VVF9JTkNfU1RBVFMoZmllbGQpIFNOTVBfSU5D
X1NUQVRTKGljbXB2Nm1zZ19zdGF0aXN0aWNzLCBmaWVsZCsyNTYpCisjZGVmaW5lIElDTVA2TVNH
T1VUX0lOQ19TVEFUU19CSChmaWVsZCkgU05NUF9JTkNfU1RBVFNfQkgoaWNtcHY2bXNnX3N0YXRp
c3RpY3MsIGZpZWxkKzI1NikKKyNkZWZpbmUgSUNNUDZNU0dPVVRfSU5DX1NUQVRTX1VTRVIoZmll
bGQpIFNOTVBfSU5DX1NUQVRTX1VTRVIoaWNtcHY2bXNnX3N0YXRpc3RpY3MsIGZpZWxkKzI1NikK
KyNkZWZpbmUgSUNNUDZNU0dJTl9JTkNfU1RBVFMoZmllbGQpIFNOTVBfSU5DX1NUQVRTKGljbXB2
Nm1zZ19zdGF0aXN0aWNzLCBmaWVsZCkKKyNkZWZpbmUgSUNNUDZNU0dJTl9JTkNfU1RBVFNfQkgo
ZmllbGQpIFNOTVBfSU5DX1NUQVRTX0JIKGljbXB2Nm1zZ19zdGF0aXN0aWNzLCBmaWVsZCkKKyNk
ZWZpbmUgSUNNUDZNU0dJTl9JTkNfU1RBVFNfVVNFUihmaWVsZCkgU05NUF9JTkNfU1RBVFNfVVNF
UihpY21wdjZtc2dfc3RhdGlzdGljcywgZmllbGQpCisKIERFQ0xBUkVfU05NUF9TVEFUKHN0cnVj
dCB1ZHBfbWliLCB1ZHBfc3RhdHNfaW42KTsKIERFQ0xBUkVfU05NUF9TVEFUKHN0cnVjdCB1ZHBf
bWliLCB1ZHBsaXRlX3N0YXRzX2luNik7CiAjZGVmaW5lIFVEUDZfSU5DX1NUQVRTX0JIKGZpZWxk
LCBpc191ZHBsaXRlKSAJCQkgICAgICBkbyAgeyAgXApkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41
L2luY2x1ZGUvbmV0L3NubXAuaCBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cvaW5jbHVkZS9uZXQv
c25tcC5oCi0tLSBsaW51eC0yLjYuMjIuNS9pbmNsdWRlL25ldC9zbm1wLmgJMjAwNy0wOC0yMiAx
NjoyMzo1NC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4yMi41X0lDTVB2Nk1TRy9pbmNs
dWRlL25ldC9zbm1wLmgJMjAwNy0wOS0xMCAxNTowMDoxOC4wMDAwMDAwMDAgLTA3MDAKQEAgLTg4
LDYgKzg4LDEyIEBAIHN0cnVjdCBpY21wdjZfbWliIHsKIAl1bnNpZ25lZCBsb25nCW1pYnNbSUNN
UDZfTUlCX01BWF07CiB9IF9fU05NUF9NSUJfQUxJR05fXzsKIAorI2RlZmluZSBJQ01QNk1TR19N
SUJfTUFYICBfX0lDTVA2TVNHX01JQl9NQVgKK3N0cnVjdCBpY21wdjZtc2dfbWliIHsKKwl1bnNp
Z25lZCBsb25nCW1pYnNbSUNNUDZNU0dfTUlCX01BWF07Cit9IF9fU05NUF9NSUJfQUxJR05fXzsK
KworCiAvKiBUQ1AgKi8KICNkZWZpbmUgVENQX01JQl9NQVgJX19UQ1BfTUlCX01BWAogc3RydWN0
IHRjcF9taWIgewpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L25ldC9pcHY2L2FmX2luZXQ2LmMg
bGludXgtMi42LjIyLjVfSUNNUHY2TVNHL25ldC9pcHY2L2FmX2luZXQ2LmMKLS0tIGxpbnV4LTIu
Ni4yMi41L25ldC9pcHY2L2FmX2luZXQ2LmMJMjAwNy0wOC0yMiAxNjoyMzo1NC4wMDAwMDAwMDAg
LTA3MDAKKysrIGxpbnV4LTIuNi4yMi41X0lDTVB2Nk1TRy9uZXQvaXB2Ni9hZl9pbmV0Ni5jCTIw
MDctMDktMTAgMTQ6MTk6NTcuMDAwMDAwMDAwIC0wNzAwCkBAIC03MTksNiArNzE5LDkgQEAgc3Rh
dGljIGludCBfX2luaXQgaW5pdF9pcHY2X21pYnModm9pZCkKIAlpZiAoc25tcF9taWJfaW5pdCgo
dm9pZCAqKilpY21wdjZfc3RhdGlzdGljcywgc2l6ZW9mIChzdHJ1Y3QgaWNtcHY2X21pYiksCiAJ
CQkgIF9fYWxpZ25vZl9fKHN0cnVjdCBpY21wdjZfbWliKSkgPCAwKQogCQlnb3RvIGVycl9pY21w
X21pYjsKKwlpZiAoc25tcF9taWJfaW5pdCgodm9pZCAqKilpY21wdjZtc2dfc3RhdGlzdGljcywK
KwkgICAgc2l6ZW9mIChzdHJ1Y3QgaWNtcHY2bXNnX21pYiksIF9fYWxpZ25vZl9fKHN0cnVjdCBp
Y21wdjZfbWliKSkgPCAwKQorCQlnb3RvIGVycl9pY21wbXNnX21pYjsKIAlpZiAoc25tcF9taWJf
aW5pdCgodm9pZCAqKil1ZHBfc3RhdHNfaW42LCBzaXplb2YgKHN0cnVjdCB1ZHBfbWliKSwKIAkJ
CSAgX19hbGlnbm9mX18oc3RydWN0IHVkcF9taWIpKSA8IDApCiAJCWdvdG8gZXJyX3VkcF9taWI7
CkBAIC03MzAsNiArNzMzLDggQEAgc3RhdGljIGludCBfX2luaXQgaW5pdF9pcHY2X21pYnModm9p
ZCkKIGVycl91ZHBsaXRlX21pYjoKIAlzbm1wX21pYl9mcmVlKCh2b2lkICoqKXVkcF9zdGF0c19p
bjYpOwogZXJyX3VkcF9taWI6CisJc25tcF9taWJfZnJlZSgodm9pZCAqKilpY21wdjZtc2dfc3Rh
dGlzdGljcyk7CitlcnJfaWNtcG1zZ19taWI6CiAJc25tcF9taWJfZnJlZSgodm9pZCAqKilpY21w
djZfc3RhdGlzdGljcyk7CiBlcnJfaWNtcF9taWI6CiAJc25tcF9taWJfZnJlZSgodm9pZCAqKilp
cHY2X3N0YXRpc3RpY3MpOwpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L25ldC9pcHY2L2ljbXAu
YyBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cvbmV0L2lwdjYvaWNtcC5jCi0tLSBsaW51eC0yLjYu
MjIuNS9uZXQvaXB2Ni9pY21wLmMJMjAwNy0wOC0yMiAxNjoyMzo1NC4wMDAwMDAwMDAgLTA3MDAK
KysrIGxpbnV4LTIuNi4yMi41X0lDTVB2Nk1TRy9uZXQvaXB2Ni9pY21wLmMJMjAwNy0wOS0xMCAx
NToyNDoyNy4wMDAwMDAwMDAgLTA3MDAKQEAgLTY5LDYgKzY5LDggQEAKIAogREVGSU5FX1NOTVBf
U1RBVChzdHJ1Y3QgaWNtcHY2X21pYiwgaWNtcHY2X3N0YXRpc3RpY3MpIF9fcmVhZF9tb3N0bHk7
CiBFWFBPUlRfU1lNQk9MKGljbXB2Nl9zdGF0aXN0aWNzKTsKK0RFRklORV9TTk1QX1NUQVQoc3Ry
dWN0IGljbXB2Nm1zZ19taWIsIGljbXB2Nm1zZ19zdGF0aXN0aWNzKSBfX3JlYWRfbW9zdGx5Owor
RVhQT1JUX1NZTUJPTChpY21wdjZtc2dfc3RhdGlzdGljcyk7CiAKIC8qCiAgKglUaGUgSUNNUCBz
b2NrZXQocykuIFRoaXMgaXMgdGhlIG1vc3QgY29udmVuaWVudCB3YXkgdG8gZmxvdyBjb250cm9s
CkBAIC0yNDcsNiArMjQ5LDcgQEAgc3RhdGljIGludCBpY21wdjZfcHVzaF9wZW5kaW5nX2ZyYW1l
cyhzdAogCQkJCQkJICAgICAgbGVuLCBmbC0+cHJvdG8sCiAJCQkJCQkgICAgICB0bXBfY3N1bSk7
CiAJfQorCUlDTVA2TVNHT1VUX0lOQ19TVEFUU19CSChpY21wNmgtPmljbXA2X3R5cGUpOwogCWlw
Nl9wdXNoX3BlbmRpbmdfZnJhbWVzKHNrKTsKIG91dDoKIAlyZXR1cm4gZXJyOwpAQCAtNDU2LDgg
KzQ1OSw2IEBAIHZvaWQgaWNtcHY2X3NlbmQoc3RydWN0IHNrX2J1ZmYgKnNrYiwgaW4KIAl9CiAJ
ZXJyID0gaWNtcHY2X3B1c2hfcGVuZGluZ19mcmFtZXMoc2ssICZmbCwgJnRtcF9oZHIsIGxlbiAr
IHNpemVvZihzdHJ1Y3QgaWNtcDZoZHIpKTsKIAotCWlmICh0eXBlID49IElDTVBWNl9ERVNUX1VO
UkVBQ0ggJiYgdHlwZSA8PSBJQ01QVjZfUEFSQU1QUk9CKQotCQlJQ01QNl9JTkNfU1RBVFNfT0ZG
U0VUX0JIKGlkZXYsIElDTVA2X01JQl9PVVRERVNUVU5SRUFDSFMsIHR5cGUgLSBJQ01QVjZfREVT
VF9VTlJFQUNIKTsKIAlJQ01QNl9JTkNfU1RBVFNfQkgoaWRldiwgSUNNUDZfTUlCX09VVE1TR1Mp
OwogCiBvdXRfcHV0OgpAQCAtNTQ3LDcgKzU0OCw2IEBAIHN0YXRpYyB2b2lkIGljbXB2Nl9lY2hv
X3JlcGx5KHN0cnVjdCBza18KIAl9CiAJZXJyID0gaWNtcHY2X3B1c2hfcGVuZGluZ19mcmFtZXMo
c2ssICZmbCwgJnRtcF9oZHIsIHNrYi0+bGVuICsgc2l6ZW9mKHN0cnVjdCBpY21wNmhkcikpOwog
Ci0JSUNNUDZfSU5DX1NUQVRTX0JIKGlkZXYsIElDTVA2X01JQl9PVVRFQ0hPUkVQTElFUyk7CiAJ
SUNNUDZfSU5DX1NUQVRTX0JIKGlkZXYsIElDTVA2X01JQl9PVVRNU0dTKTsKIAogb3V0X3B1dDoK
QEAgLTY1NiwxMCArNjU2LDcgQEAgc3RhdGljIGludCBpY21wdjZfcmN2KHN0cnVjdCBza19idWZm
ICoqcAogCiAJdHlwZSA9IGhkci0+aWNtcDZfdHlwZTsKIAotCWlmICh0eXBlID49IElDTVBWNl9E
RVNUX1VOUkVBQ0ggJiYgdHlwZSA8PSBJQ01QVjZfUEFSQU1QUk9CKQotCQlJQ01QNl9JTkNfU1RB
VFNfT0ZGU0VUX0JIKGlkZXYsIElDTVA2X01JQl9JTkRFU1RVTlJFQUNIUywgdHlwZSAtIElDTVBW
Nl9ERVNUX1VOUkVBQ0gpOwotCWVsc2UgaWYgKHR5cGUgPj0gSUNNUFY2X0VDSE9fUkVRVUVTVCAm
JiB0eXBlIDw9IE5ESVNDX1JFRElSRUNUKQotCQlJQ01QNl9JTkNfU1RBVFNfT0ZGU0VUX0JIKGlk
ZXYsIElDTVA2X01JQl9JTkVDSE9TLCB0eXBlIC0gSUNNUFY2X0VDSE9fUkVRVUVTVCk7CisJSUNN
UDZNU0dJTl9JTkNfU1RBVFNfQkgodHlwZSk7CiAKIAlzd2l0Y2ggKHR5cGUpIHsKIAljYXNlIElD
TVBWNl9FQ0hPX1JFUVVFU1Q6CmRpZmYgLXJ1TnAgbGludXgtMi42LjIyLjUvbmV0L2lwdjYvbWNh
c3QuYyBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cvbmV0L2lwdjYvbWNhc3QuYwotLS0gbGludXgt
Mi42LjIyLjUvbmV0L2lwdjYvbWNhc3QuYwkyMDA3LTA4LTIyIDE2OjIzOjU0LjAwMDAwMDAwMCAt
MDcwMAorKysgbGludXgtMi42LjIyLjVfSUNNUHY2TVNHL25ldC9pcHY2L21jYXN0LmMJMjAwNy0w
OS0xMCAxNDoyNDozMy4wMDAwMDAwMDAgLTA3MDAKQEAgLTE0NzgsNiArMTQ3OCw3IEBAIHN0YXRp
YyB2b2lkIG1sZF9zZW5kcGFjayhzdHJ1Y3Qgc2tfYnVmZiAKIAllcnIgPSBORl9IT09LKFBGX0lO
RVQ2LCBORl9JUDZfTE9DQUxfT1VULCBza2IsIE5VTEwsIHNrYi0+ZGV2LAogCQltbGRfZGV2X3F1
ZXVlX3htaXQpOwogCWlmICghZXJyKSB7CisJCUlDTVA2TVNHT1VUX0lOQ19TVEFUUyhJQ01QVjZf
TUxEMl9SRVBPUlQpOwogCQlJQ01QNl9JTkNfU1RBVFMoaWRldixJQ01QNl9NSUJfT1VUTVNHUyk7
CiAJCUlQNl9JTkNfU1RBVFMoaWRldiwgSVBTVEFUU19NSUJfT1VUTUNBU1RQS1RTKTsKIAl9IGVs
c2UKQEAgLTE4MjEsMTAgKzE4MjIsNyBAQCBzdGF0aWMgdm9pZCBpZ21wNl9zZW5kKHN0cnVjdCBp
bjZfYWRkciAqCiAJZXJyID0gTkZfSE9PSyhQRl9JTkVUNiwgTkZfSVA2X0xPQ0FMX09VVCwgc2ti
LCBOVUxMLCBza2ItPmRldiwKIAkJbWxkX2Rldl9xdWV1ZV94bWl0KTsKIAlpZiAoIWVycikgewot
CQlpZiAodHlwZSA9PSBJQ01QVjZfTUdNX1JFRFVDVElPTikKLQkJCUlDTVA2X0lOQ19TVEFUUyhp
ZGV2LCBJQ01QNl9NSUJfT1VUR1JPVVBNRU1CUkVEVUNUSU9OUyk7Ci0JCWVsc2UKLQkJCUlDTVA2
X0lOQ19TVEFUUyhpZGV2LCBJQ01QNl9NSUJfT1VUR1JPVVBNRU1CUkVTUE9OU0VTKTsKKwkJSUNN
UDZNU0dPVVRfSU5DX1NUQVRTKHR5cGUpOwogCQlJQ01QNl9JTkNfU1RBVFMoaWRldiwgSUNNUDZf
TUlCX09VVE1TR1MpOwogCQlJUDZfSU5DX1NUQVRTKGlkZXYsIElQU1RBVFNfTUlCX09VVE1DQVNU
UEtUUyk7CiAJfSBlbHNlCmRpZmYgLXJ1TnAgbGludXgtMi42LjIyLjUvbmV0L2lwdjYvbmRpc2Mu
YyBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cvbmV0L2lwdjYvbmRpc2MuYwotLS0gbGludXgtMi42
LjIyLjUvbmV0L2lwdjYvbmRpc2MuYwkyMDA3LTA4LTIyIDE2OjIzOjU0LjAwMDAwMDAwMCAtMDcw
MAorKysgbGludXgtMi42LjIyLjVfSUNNUHY2TVNHL25ldC9pcHY2L25kaXNjLmMJMjAwNy0wOS0x
MCAxNTowNDo1MS4wMDAwMDAwMDAgLTA3MDAKQEAgLTQzMSw3ICs0MzEsNyBAQCBzdGF0aWMgdm9p
ZCBfX25kaXNjX3NlbmQoc3RydWN0IG5ldF9kZXZpCiAJCQkgc3RydWN0IG5laWdoYm91ciAqbmVp
Z2gsCiAJCQkgc3RydWN0IGluNl9hZGRyICpkYWRkciwgc3RydWN0IGluNl9hZGRyICpzYWRkciwK
IAkJCSBzdHJ1Y3QgaWNtcDZoZHIgKmljbXA2aCwgc3RydWN0IGluNl9hZGRyICp0YXJnZXQsCi0J
CQkgaW50IGxsaW5mbywgaW50IGljbXA2X21pYl9vdXRuZCkKKwkJCSBpbnQgbGxpbmZvKQogewog
CXN0cnVjdCBmbG93aSBmbDsKIAlzdHJ1Y3QgZHN0X2VudHJ5ICpkc3Q7CkBAIC00NDEsOSArNDQx
LDExIEBAIHN0YXRpYyB2b2lkIF9fbmRpc2Nfc2VuZChzdHJ1Y3QgbmV0X2RldmkKIAlzdHJ1Y3Qg
aW5ldDZfZGV2ICppZGV2OwogCWludCBsZW47CiAJaW50IGVycjsKLQl1OCAqb3B0OworCXU4ICpv
cHQsIHR5cGU7CisKKwl0eXBlID0gaWNtcDZoLT5pY21wNl90eXBlOwogCi0JbmRpc2NfZmxvd19p
bml0KCZmbCwgaWNtcDZoLT5pY21wNl90eXBlLCBzYWRkciwgZGFkZHIsCisJbmRpc2NfZmxvd19p
bml0KCZmbCwgdHlwZSwgc2FkZHIsIGRhZGRyLAogCQkJZGV2LT5pZmluZGV4KTsKIAogCWRzdCA9
IG5kaXNjX2RzdF9hbGxvYyhkZXYsIG5laWdoLCBkYWRkciwgaXA2X291dHB1dCk7CkBAIC01MDQs
NyArNTA2LDcgQEAgc3RhdGljIHZvaWQgX19uZGlzY19zZW5kKHN0cnVjdCBuZXRfZGV2aQogCiAJ
ZXJyID0gTkZfSE9PSyhQRl9JTkVUNiwgTkZfSVA2X0xPQ0FMX09VVCwgc2tiLCBOVUxMLCBkc3Qt
PmRldiwgZHN0X291dHB1dCk7CiAJaWYgKCFlcnIpIHsKLQkJSUNNUDZfSU5DX1NUQVRTKGlkZXYs
IGljbXA2X21pYl9vdXRuZCk7CisJCUlDTVA2TVNHT1VUX0lOQ19TVEFUUyh0eXBlKTsKIAkJSUNN
UDZfSU5DX1NUQVRTKGlkZXYsIElDTVA2X01JQl9PVVRNU0dTKTsKIAl9CiAKQEAgLTU0Miw4ICs1
NDQsNyBAQCBzdGF0aWMgdm9pZCBuZGlzY19zZW5kX25hKHN0cnVjdCBuZXRfZGV2CiAKIAlfX25k
aXNjX3NlbmQoZGV2LCBuZWlnaCwgZGFkZHIsIHNyY19hZGRyLAogCQkgICAgICZpY21wNmgsIHNv
bGljaXRlZF9hZGRyLAotCQkgICAgIGluY19vcHQgPyBORF9PUFRfVEFSR0VUX0xMX0FERFIgOiAw
LAotCQkgICAgIElDTVA2X01JQl9PVVRORUlHSEJPUkFEVkVSVElTRU1FTlRTKTsKKwkJICAgICBp
bmNfb3B0ID8gTkRfT1BUX1RBUkdFVF9MTF9BRERSIDogMCk7CiB9CiAKIHZvaWQgbmRpc2Nfc2Vu
ZF9ucyhzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgbmVpZ2hib3VyICpuZWlnaCwKQEAg
LTU2NCw4ICs1NjUsNyBAQCB2b2lkIG5kaXNjX3NlbmRfbnMoc3RydWN0IG5ldF9kZXZpY2UgKmRl
CiAKIAlfX25kaXNjX3NlbmQoZGV2LCBuZWlnaCwgZGFkZHIsIHNhZGRyLAogCQkgICAgICZpY21w
NmgsIHNvbGljaXQsCi0JCSAgICAgIWlwdjZfYWRkcl9hbnkoc2FkZHIpID8gTkRfT1BUX1NPVVJD
RV9MTF9BRERSIDogMCwKLQkJICAgICBJQ01QNl9NSUJfT1VUTkVJR0hCT1JTT0xJQ0lUUyk7CisJ
CSAgICAgIWlwdjZfYWRkcl9hbnkoc2FkZHIpID8gTkRfT1BUX1NPVVJDRV9MTF9BRERSIDogMCk7
CiB9CiAKIHZvaWQgbmRpc2Nfc2VuZF9ycyhzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3Qg
aW42X2FkZHIgKnNhZGRyLApAQCAtNTk5LDggKzU5OSw3IEBAIHZvaWQgbmRpc2Nfc2VuZF9ycyhz
dHJ1Y3QgbmV0X2RldmljZSAqZGUKICNlbmRpZgogCV9fbmRpc2Nfc2VuZChkZXYsIE5VTEwsIGRh
ZGRyLCBzYWRkciwKIAkJICAgICAmaWNtcDZoLCBOVUxMLAotCQkgICAgIHNlbmRfc2xsYW8gPyBO
RF9PUFRfU09VUkNFX0xMX0FERFIgOiAwLAotCQkgICAgIElDTVA2X01JQl9PVVRST1VURVJTT0xJ
Q0lUUyk7CisJCSAgICAgc2VuZF9zbGxhbyA/IE5EX09QVF9TT1VSQ0VfTExfQUREUiA6IDApOwog
fQogCiAKQEAgLTE0NTQsNyArMTQ1Myw3IEBAIHZvaWQgbmRpc2Nfc2VuZF9yZWRpcmVjdChzdHJ1
Y3Qgc2tfYnVmZiAKIAlJUDZfSU5DX1NUQVRTKGlkZXYsIElQU1RBVFNfTUlCX09VVFJFUVVFU1RT
KTsKIAllcnIgPSBORl9IT09LKFBGX0lORVQ2LCBORl9JUDZfTE9DQUxfT1VULCBidWZmLCBOVUxM
LCBkc3QtPmRldiwgZHN0X291dHB1dCk7CiAJaWYgKCFlcnIpIHsKLQkJSUNNUDZfSU5DX1NUQVRT
KGlkZXYsIElDTVA2X01JQl9PVVRSRURJUkVDVFMpOworCQlJQ01QNk1TR09VVF9JTkNfU1RBVFMo
TkRJU0NfUkVESVJFQ1QpOwogCQlJQ01QNl9JTkNfU1RBVFMoaWRldiwgSUNNUDZfTUlCX09VVE1T
R1MpOwogCX0KIApkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L25ldC9pcHY2L3Byb2MuYyBsaW51
eC0yLjYuMjIuNV9JQ01QdjZNU0cvbmV0L2lwdjYvcHJvYy5jCi0tLSBsaW51eC0yLjYuMjIuNS9u
ZXQvaXB2Ni9wcm9jLmMJMjAwNy0wOC0yMiAxNjoyMzo1NC4wMDAwMDAwMDAgLTA3MDAKKysrIGxp
bnV4LTIuNi4yMi41X0lDTVB2Nk1TRy9uZXQvaXB2Ni9wcm9jLmMJMjAwNy0wOS0xMCAxNToxNToz
MS4wMDAwMDAwMDAgLTA3MDAKQEAgLTg1LDQ3ICs4NSwzMyBAQCBzdGF0aWMgc3RydWN0IHNubXBf
bWliIHNubXA2X2lwc3RhdHNfbGlzCiB9OwogCiBzdGF0aWMgc3RydWN0IHNubXBfbWliIHNubXA2
X2ljbXA2X2xpc3RbXSA9IHsKLS8qIGljbXB2NiBtaWIgYWNjb3JkaW5nIHRvIFJGQyAyNDY2Ci0K
LSAgIEV4Y2VwdGlvbnM6ICB7SW58T3V0fUFkbWluUHJvaGlicyBhcmUgcmVtb3ZlZCwgYmVjYXVz
ZSBJIHNlZQotCQlubyBnb29kIHJlYXNvbnMgdG8gYWNjb3VudCB0aGVtIHNlcGFyYXRlbHkKLQkJ
b2YgYW5vdGhlciBkZXN0LnVucmVhY2hzLgotCQlPdXRFcnJzIGlzIHplcm8gaWRlbnRpY2FsbHku
Ci0JCU91dEVjaG9zIHRvby4KLQkJT3V0Um91dGVyQWR2ZXJ0aXNlbWVudHMgdG9vLgotCQlPdXRH
cm91cE1lbWJRdWVyaWVzIHRvby4KLSAqLworLyogaWNtcHY2IG1pYiBhY2NvcmRpbmcgdG8gUkZD
IDI0NjYgKi8KIAlTTk1QX01JQl9JVEVNKCJJY21wNkluTXNncyIsIElDTVA2X01JQl9JTk1TR1Mp
LAogCVNOTVBfTUlCX0lURU0oIkljbXA2SW5FcnJvcnMiLCBJQ01QNl9NSUJfSU5FUlJPUlMpLAot
CVNOTVBfTUlCX0lURU0oIkljbXA2SW5EZXN0VW5yZWFjaHMiLCBJQ01QNl9NSUJfSU5ERVNUVU5S
RUFDSFMpLAotCVNOTVBfTUlCX0lURU0oIkljbXA2SW5Qa3RUb29CaWdzIiwgSUNNUDZfTUlCX0lO
UEtUVE9PQklHUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZJblRpbWVFeGNkcyIsIElDTVA2X01J
Ql9JTlRJTUVFWENEUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZJblBhcm1Qcm9ibGVtcyIsIElD
TVA2X01JQl9JTlBBUk1QUk9CTEVNUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZJbkVjaG9zIiwg
SUNNUDZfTUlCX0lORUNIT1MpLAotCVNOTVBfTUlCX0lURU0oIkljbXA2SW5FY2hvUmVwbGllcyIs
IElDTVA2X01JQl9JTkVDSE9SRVBMSUVTKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNkluR3JvdXBN
ZW1iUXVlcmllcyIsIElDTVA2X01JQl9JTkdST1VQTUVNQlFVRVJJRVMpLAotCVNOTVBfTUlCX0lU
RU0oIkljbXA2SW5Hcm91cE1lbWJSZXNwb25zZXMiLCBJQ01QNl9NSUJfSU5HUk9VUE1FTUJSRVNQ
T05TRVMpLAotCVNOTVBfTUlCX0lURU0oIkljbXA2SW5Hcm91cE1lbWJSZWR1Y3Rpb25zIiwgSUNN
UDZfTUlCX0lOR1JPVVBNRU1CUkVEVUNUSU9OUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZJblJv
dXRlclNvbGljaXRzIiwgSUNNUDZfTUlCX0lOUk9VVEVSU09MSUNJVFMpLAotCVNOTVBfTUlCX0lU
RU0oIkljbXA2SW5Sb3V0ZXJBZHZlcnRpc2VtZW50cyIsIElDTVA2X01JQl9JTlJPVVRFUkFEVkVS
VElTRU1FTlRTKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNkluTmVpZ2hib3JTb2xpY2l0cyIsIElD
TVA2X01JQl9JTk5FSUdIQk9SU09MSUNJVFMpLAotCVNOTVBfTUlCX0lURU0oIkljbXA2SW5OZWln
aGJvckFkdmVydGlzZW1lbnRzIiwgSUNNUDZfTUlCX0lOTkVJR0hCT1JBRFZFUlRJU0VNRU5UUyks
Ci0JU05NUF9NSUJfSVRFTSgiSWNtcDZJblJlZGlyZWN0cyIsIElDTVA2X01JQl9JTlJFRElSRUNU
UyksCiAJU05NUF9NSUJfSVRFTSgiSWNtcDZPdXRNc2dzIiwgSUNNUDZfTUlCX09VVE1TR1MpLAot
CVNOTVBfTUlCX0lURU0oIkljbXA2T3V0RGVzdFVucmVhY2hzIiwgSUNNUDZfTUlCX09VVERFU1RV
TlJFQUNIUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZPdXRQa3RUb29CaWdzIiwgSUNNUDZfTUlC
X09VVFBLVFRPT0JJR1MpLAotCVNOTVBfTUlCX0lURU0oIkljbXA2T3V0VGltZUV4Y2RzIiwgSUNN
UDZfTUlCX09VVFRJTUVFWENEUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZPdXRQYXJtUHJvYmxl
bXMiLCBJQ01QNl9NSUJfT1VUUEFSTVBST0JMRU1TKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNk91
dEVjaG9SZXBsaWVzIiwgSUNNUDZfTUlCX09VVEVDSE9SRVBMSUVTKSwKLQlTTk1QX01JQl9JVEVN
KCJJY21wNk91dFJvdXRlclNvbGljaXRzIiwgSUNNUDZfTUlCX09VVFJPVVRFUlNPTElDSVRTKSwK
LQlTTk1QX01JQl9JVEVNKCJJY21wNk91dE5laWdoYm9yU29saWNpdHMiLCBJQ01QNl9NSUJfT1VU
TkVJR0hCT1JTT0xJQ0lUUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZPdXROZWlnaGJvckFkdmVy
dGlzZW1lbnRzIiwgSUNNUDZfTUlCX09VVE5FSUdIQk9SQURWRVJUSVNFTUVOVFMpLAotCVNOTVBf
TUlCX0lURU0oIkljbXA2T3V0UmVkaXJlY3RzIiwgSUNNUDZfTUlCX09VVFJFRElSRUNUUyksCi0J
U05NUF9NSUJfSVRFTSgiSWNtcDZPdXRHcm91cE1lbWJSZXNwb25zZXMiLCBJQ01QNl9NSUJfT1VU
R1JPVVBNRU1CUkVTUE9OU0VTKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNk91dEdyb3VwTWVtYlJl
ZHVjdGlvbnMiLCBJQ01QNl9NSUJfT1VUR1JPVVBNRU1CUkVEVUNUSU9OUyksCiAJU05NUF9NSUJf
U0VOVElORUwKIH07CiAKKy8qIFJGQyA0MjkzIHY2IElDTVBNc2dTdGF0c1RhYmxlOyBuYW1lZCBp
dGVtcyBmb3IgUkZDIDI0NjYgY29tcGF0aWJpbGl0eSAqLworc3RhdGljIGNoYXIgKmljbXA2dHlw
ZTJuYW1lWzI1Nl0gPSB7CisJW0lDTVBWNl9ERVNUX1VOUkVBQ0hdID0gIkRlc3RVbnJlYWNocyIs
CisJW0lDTVBWNl9QS1RfVE9PQklHXSA9ICJQa3RUb29CaWdzIiwKKwlbSUNNUFY2X1RJTUVfRVhD
RUVEXSA9ICJUaW1lRXhjZHMiLAorCVtJQ01QVjZfUEFSQU1QUk9CXSA9ICJQYXJtUHJvYmxlbXMi
LAorCVtJQ01QVjZfRUNIT19SRVFVRVNUXSA9ICJFY2hvUmVxdWVzdCIsCisJW0lDTVBWNl9FQ0hP
X1JFUExZXSA9ICJFY2hvUmVwbGllcyIsCisJW0lDTVBWNl9NR01fUVVFUlldID0gIkdyb3VwTWVt
YlF1ZXJpZXMiLAorCVtJQ01QVjZfTUdNX1JFUE9SVF0gPSAiR3JvdXBNZW1iUmVzcG9uc2VzIiwK
KwlbSUNNUFY2X01HTV9SRURVQ1RJT05dID0gIkdyb3VwTWVtYlJlZHVjdGlvbnMiLAorCVtJQ01Q
VjZfTUxEMl9SRVBPUlRdID0gIk1MRHYyUmVwb3J0cyIsCisJW05ESVNDX1JPVVRFUl9BRFZFUlRJ
U0VNRU5UXSA9ICJSb3V0ZXJBZHZlcnRpc2VtZW50cyIsCisJW05ESVNDX1JPVVRFUl9TT0xJQ0lU
QVRJT05dID0gIlJvdXRlclNvbGljaXRzIiwKKwlbTkRJU0NfTkVJR0hCT1VSX0FEVkVSVElTRU1F
TlRdID0gIk5laWdoYm9yQWR2ZXJ0aXNlbWVudHMiLAorCVtORElTQ19ORUlHSEJPVVJfU09MSUNJ
VEFUSU9OXSA9ICJOZWlnaGJvclNvbGljaXRzIiwKKwlbTkRJU0NfUkVESVJFQ1RdID0gIk5laWdo
Ym9yUmVkaXJlY3RzIiwKK307CisKKwogc3RhdGljIHN0cnVjdCBzbm1wX21pYiBzbm1wNl91ZHA2
X2xpc3RbXSA9IHsKIAlTTk1QX01JQl9JVEVNKCJVZHA2SW5EYXRhZ3JhbXMiLCBVRFBfTUlCX0lO
REFUQUdSQU1TKSwKIAlTTk1QX01JQl9JVEVNKCJVZHA2Tm9Qb3J0cyIsIFVEUF9NSUJfTk9QT1JU
UyksCkBAIC0xNDIsNiArMTI4LDQwIEBAIHN0YXRpYyBzdHJ1Y3Qgc25tcF9taWIgc25tcDZfdWRw
bGl0ZTZfbGkKIAlTTk1QX01JQl9TRU5USU5FTAogfTsKIAorc3RhdGljIHZvaWQgc25tcDZfc2Vx
X3Nob3dfaWNtcHY2bXNnKHN0cnVjdCBzZXFfZmlsZSAqc2VxKQoreworCXN0YXRpYyBjaGFyIG5h
bWVbMzJdOworCWludCBpOworCisJLyogcHJpbnQgYnkgbmFtZSAtLSBkZXByZWNhdGVkIGl0ZW1z
ICovCisJZm9yIChpID0gMDsgaSA8IElDTVA2TVNHX01JQl9NQVg7IGkrKykgeworCQlpbnQgaWNt
cHR5cGU7CisJCWNoYXIgKnA7CisKKwkJaWNtcHR5cGUgPSBpICYgMHhmZjsKKwkJcCA9IGljbXA2
dHlwZTJuYW1lW2ljbXB0eXBlXTsKKwkJaWYgKCFwKQkvKiBkb24ndCBwcmludCB1bi1uYW1lZCB0
eXBlcyBoZXJlICovCisJCQljb250aW51ZTsKKwkJKHZvaWQpIHNucHJpbnRmKG5hbWUsIHNpemVv
ZihuYW1lKS0xLCAiSWNtcDYlcyVzIiwKKwkJCWkgJiAweDEwMCA/ICJPdXQiIDogIkluIiwgcCk7
CisJCXNlcV9wcmludGYoc2VxLCAiJS0zMnNcdCVsdVxuIiwgbmFtZSwKKwkJCXNubXBfZm9sZF9m
aWVsZCgodm9pZCAqKikgaWNtcHY2bXNnX3N0YXRpc3RpY3MsIGkpKTsKKwl9CisKKwkvKiBwcmlu
dCBieSBudW1iZXIgKG5vbnplcm8gb25seSkgLSBJQ01QTXNnU3RhdCBmb3JtYXQgKi8KKwlmb3Ig
KGkgPSAwOyBpIDwgSUNNUDZNU0dfTUlCX01BWDsgaSsrKSB7CisJCXVuc2lnbmVkIGxvbmcgdmFs
OworCisJCXZhbCA9IHNubXBfZm9sZF9maWVsZCgodm9pZCAqKikgaWNtcHY2bXNnX3N0YXRpc3Rp
Y3MsIGkpOworCQlpZiAoIXZhbCkKKwkJCWNvbnRpbnVlOworCQkodm9pZCkgc25wcmludGYobmFt
ZSwgc2l6ZW9mKG5hbWUpLTEsICJJY21wNiVzVHlwZSV1IiwKKwkJCWkgJiAweDEwMCA/ICAiT3V0
IiA6ICJJbiIsIGkgJiAweGZmKTsKKwkJc2VxX3ByaW50ZihzZXEsICIlLTMyc1x0JWx1XG4iLCBu
YW1lLCB2YWwpOworCX0KKwlyZXR1cm47Cit9CisKIHN0YXRpYyBpbmxpbmUgdm9pZAogc25tcDZf
c2VxX3Nob3dfaXRlbShzdHJ1Y3Qgc2VxX2ZpbGUgKnNlcSwgdm9pZCAqKm1pYiwgc3RydWN0IHNu
bXBfbWliICppdGVtbGlzdCkKIHsKQEAgLTE2Miw2ICsxODIsNyBAQCBzdGF0aWMgaW50IHNubXA2
X3NlcV9zaG93KHN0cnVjdCBzZXFfZmlsCiAJfSBlbHNlIHsKIAkJc25tcDZfc2VxX3Nob3dfaXRl
bShzZXEsICh2b2lkICoqKWlwdjZfc3RhdGlzdGljcywgc25tcDZfaXBzdGF0c19saXN0KTsKIAkJ
c25tcDZfc2VxX3Nob3dfaXRlbShzZXEsICh2b2lkICoqKWljbXB2Nl9zdGF0aXN0aWNzLCBzbm1w
Nl9pY21wNl9saXN0KTsKKwkJc25tcDZfc2VxX3Nob3dfaWNtcHY2bXNnKHNlcSk7CiAJCXNubXA2
X3NlcV9zaG93X2l0ZW0oc2VxLCAodm9pZCAqKil1ZHBfc3RhdHNfaW42LCBzbm1wNl91ZHA2X2xp
c3QpOwogCQlzbm1wNl9zZXFfc2hvd19pdGVtKHNlcSwgKHZvaWQgKiopdWRwbGl0ZV9zdGF0c19p
bjYsIHNubXA2X3VkcGxpdGU2X2xpc3QpOwogCX0KZGlmZiAtcnVOcCBsaW51eC0yLjYuMjIuNS9u
ZXQvaXB2Ni9yYXcuYyBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cvbmV0L2lwdjYvcmF3LmMKLS0t
IGxpbnV4LTIuNi4yMi41L25ldC9pcHY2L3Jhdy5jCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAw
MDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cvbmV0L2lwdjYvcmF3LmMJMjAw
Ny0wOS0xMCAxNTowOTozNy4wMDAwMDAwMDAgLTA3MDAKQEAgLTU0Myw2ICs1NDMsMTEgQEAgc3Rh
dGljIGludCByYXd2Nl9wdXNoX3BlbmRpbmdfZnJhbWVzKHN0cgogCWlmIChza2Jfc3RvcmVfYml0
cyhza2IsIG9mZnNldCwgJmNzdW0sIDIpKQogCQlCVUcoKTsKIAorCWlmIChmbC0+cHJvdG8gPT0g
SVBQUk9UT19JQ01QVjYpIHsKKwkJSUNNUDZfSU5DX1NUQVRTX0JIKE5VTEwsIElDTVA2X01JQl9P
VVRNU0dTKTsKKwkJSUNNUDZNU0dPVVRfSU5DX1NUQVRTX0JIKGljbXA2X2hkcihza2IpLT5pY21w
Nl90eXBlKTsKKwl9CisKIHNlbmQ6CiAJZXJyID0gaXA2X3B1c2hfcGVuZGluZ19mcmFtZXMoc2sp
Owogb3V0Ogo=

--=_mixed 00118EE488257353_=--
