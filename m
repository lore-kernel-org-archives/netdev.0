From: David Stevens <dlstevens@us.ibm.com>
Subject: Fw: [PATCH]  Add ICMPMsgStats MIB (RFC 4293) [rev 2]
Date: Fri, 14 Sep 2007 15:25:32 -0600
Message-ID: <OF04820EEE.89F4D267-ON88257356.0074B537-88257356.00759E10@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 00759E0C88257356_="
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:56041 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283AbXINVZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 17:25:35 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l8EKHniZ022834
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 16:17:49 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ELPYHu472736
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 15:25:34 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ELPYCL002674
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 15:25:34 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_mixed 00759E0C88257356_=
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
[new to 2nd revision]
6) support per-interface ICMP stats
7) use common macro for per-device stat macros

IPv6 patch attached.

                                        +-DLS

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp linux-2.6.22.5/include/linux/snmp.h 
linux-2.6.22.5_ICMPv6MSG2/include/linux/snmp.h
--- linux-2.6.22.5/include/linux/snmp.h 2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG2/include/linux/snmp.h      2007-09-10 
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
diff -ruNp linux-2.6.22.5/include/net/if_inet6.h 
linux-2.6.22.5_ICMPv6MSG2/include/net/if_inet6.h
--- linux-2.6.22.5/include/net/if_inet6.h       2007-08-22 
16:23:54.000000000 -0700
+++ linux-2.6.22.5_ICMPv6MSG2/include/net/if_inet6.h    2007-09-12 
14:11:49.000000000 -0700
@@ -154,6 +154,7 @@ struct ipv6_devstat {
        struct proc_dir_entry   *proc_dir_entry;
        DEFINE_SNMP_STAT(struct ipstats_mib, ipv6);
        DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6);
+       DEFINE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg);
 };
 
 struct inet6_dev 
diff -ruNp linux-2.6.22.5/include/net/ipv6.h 
linux-2.6.22.5_ICMPv6MSG2/include/net/ipv6.h
--- linux-2.6.22.5/include/net/ipv6.h   2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG2/include/net/ipv6.h        2007-09-13 
15:09:28.000000000 -0700
@@ -111,45 +111,28 @@ struct frag_hdr {
 extern int sysctl_ipv6_bindv6only;
 extern int sysctl_mld_max_msf;
 
-/* MIBs */
-DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
-#define IP6_INC_STATS(idev,field)              ({                      \
+#define _DEVINC(statname, modifier, idev, field)                       \
+({                                                                     \
        struct inet6_dev *_idev = (idev);                               \
        if (likely(_idev != NULL))                                      \
-               SNMP_INC_STATS(_idev->stats.ipv6, field);               \
-       SNMP_INC_STATS(ipv6_statistics, field);                         \
-})
-#define IP6_INC_STATS_BH(idev,field)           ({                      \
-       struct inet6_dev *_idev = (idev);                               \
-       if (likely(_idev != NULL))                                      \
-               SNMP_INC_STATS_BH(_idev->stats.ipv6, field);            \
-       SNMP_INC_STATS_BH(ipv6_statistics, field);                      \
-})
-#define IP6_INC_STATS_USER(idev,field)         ({                      \
-       struct inet6_dev *_idev = (idev);                               \
-       if (likely(_idev != NULL))                                      \
-               SNMP_INC_STATS_USER(_idev->stats.ipv6, field);          \
-       SNMP_INC_STATS_USER(ipv6_statistics, field);                    \
+               SNMP_INC_STATS##modifier((_idev)->stats.statname, 
(field)); \
+       SNMP_INC_STATS##modifier(statname##_statistics, (field));       \
 })
+
+/* MIBs */
+DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
+
+#define IP6_INC_STATS(idev,field)      _DEVINC(ipv6, , idev, field)
+#define IP6_INC_STATS_BH(idev,field)   _DEVINC(ipv6, _BH, idev, field)
+#define IP6_INC_STATS_USER(idev,field) _DEVINC(ipv6, _USER, idev, field)
+
 DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
-#define ICMP6_INC_STATS(idev, field)           ({                      \
-       struct inet6_dev *_idev = (idev);                               \
-       if (likely(_idev != NULL))                                      \
-               SNMP_INC_STATS(idev->stats.icmpv6, field);              \
-       SNMP_INC_STATS(icmpv6_statistics, field);                       \
-})
-#define ICMP6_INC_STATS_BH(idev, field)                ({ \
-       struct inet6_dev *_idev = (idev);                               \
-       if (likely(_idev != NULL))                                      \
-               SNMP_INC_STATS_BH((_idev)->stats.icmpv6, field);        \
-       SNMP_INC_STATS_BH(icmpv6_statistics, field);                    \
-})
-#define ICMP6_INC_STATS_USER(idev, field)      ({                      \
-       struct inet6_dev *_idev = (idev);                               \
-       if (likely(_idev != NULL))                                      \
-               SNMP_INC_STATS_USER(_idev->stats.icmpv6, field);        \
-       SNMP_INC_STATS_USER(icmpv6_statistics, field);                  \
-})
+DECLARE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics);
+
+#define ICMP6_INC_STATS(idev, field)   _DEVINC(icmpv6, , idev, field)
+#define ICMP6_INC_STATS_BH(idev, field)        _DEVINC(icmpv6, _BH, idev, 
field)
+#define ICMP6_INC_STATS_USER(idev, field) _DEVINC(icmpv6, _USER, idev, 
field)
+
 #define ICMP6_INC_STATS_OFFSET_BH(idev, field, offset) ({ \
        struct inet6_dev *_idev = idev; \
        __typeof__(offset) _offset = (offset); \
@@ -157,6 +140,20 @@ DECLARE_SNMP_STAT(struct icmpv6_mib, icm
                SNMP_INC_STATS_OFFSET_BH(_idev->stats.icmpv6, field, 
_offset);       \
        SNMP_INC_STATS_OFFSET_BH(icmpv6_statistics, field, _offset); \
 })
+
+#define ICMP6MSGOUT_INC_STATS(idev, field) \
+       _DEVINC(icmpv6msg, , idev, field +256)
+#define ICMP6MSGOUT_INC_STATS_BH(idev, field) \
+       _DEVINC(icmpv6msg, _BH, idev, field +256)
+#define ICMP6MSGOUT_INC_STATS_USER(idev, field) \
+       _DEVINC(icmpv6msg, _USER, idev, field +256)
+#define ICMP6MSGIN_INC_STATS(idev, field) \
+        _DEVINC(icmpv6msg, , idev, field)
+#define ICMP6MSGIN_INC_STATS_BH(idev, field) \
+       _DEVINC(icmpv6msg, _BH, idev, field)
+#define ICMP6MSGIN_INC_STATS_USER(idev, field) \
+       _DEVINC(icmpv6msg, _USER, idev, field)
+
 DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 #define UDP6_INC_STATS_BH(field, is_udplite)                         do { 
 \
diff -ruNp linux-2.6.22.5/include/net/snmp.h 
linux-2.6.22.5_ICMPv6MSG2/include/net/snmp.h
--- linux-2.6.22.5/include/net/snmp.h   2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG2/include/net/snmp.h        2007-09-10 
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
diff -ruNp linux-2.6.22.5/net/ipv6/addrconf.c 
linux-2.6.22.5_ICMPv6MSG2/net/ipv6/addrconf.c
--- linux-2.6.22.5/net/ipv6/addrconf.c  2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG2/net/ipv6/addrconf.c       2007-09-13 
15:06:33.000000000 -0700
@@ -260,9 +260,15 @@ static int snmp6_alloc_dev(struct inet6_
                          sizeof(struct icmpv6_mib),
                          __alignof__(struct icmpv6_mib)) < 0)
                goto err_icmp;
+       if (snmp_mib_init((void **)idev->stats.icmpv6msg,
+                         sizeof(struct icmpv6msg_mib),
+                         __alignof__(struct icmpv6msg_mib)) < 0)
+               goto err_icmpmsg;
 
        return 0;
 
+err_icmpmsg:
+       snmp_mib_free((void **)idev->stats.icmpv6);
 err_icmp:
        snmp_mib_free((void **)idev->stats.ipv6);
 err_ip:
@@ -271,6 +277,7 @@ err_ip:
 
 static int snmp6_free_dev(struct inet6_dev *idev)
 {
+       snmp_mib_free((void **)idev->stats.icmpv6msg);
        snmp_mib_free((void **)idev->stats.icmpv6);
        snmp_mib_free((void **)idev->stats.ipv6);
        return 0;
diff -ruNp linux-2.6.22.5/net/ipv6/af_inet6.c 
linux-2.6.22.5_ICMPv6MSG2/net/ipv6/af_inet6.c
--- linux-2.6.22.5/net/ipv6/af_inet6.c  2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG2/net/ipv6/af_inet6.c       2007-09-10 
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
linux-2.6.22.5_ICMPv6MSG2/net/ipv6/icmp.c
--- linux-2.6.22.5/net/ipv6/icmp.c      2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG2/net/ipv6/icmp.c   2007-09-14 
13:39:23.000000000 -0700
@@ -69,6 +69,8 @@
 
 DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics) __read_mostly;
 EXPORT_SYMBOL(icmpv6_statistics);
+DEFINE_SNMP_STAT(struct icmpv6msg_mib, icmpv6msg_statistics) 
__read_mostly;
+EXPORT_SYMBOL(icmpv6msg_statistics);
 
 /*
  *     The ICMP socket(s). This is the most convenient way to flow 
control
@@ -456,8 +458,6 @@ void icmpv6_send(struct sk_buff *skb, in
        }
        err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, len + 
sizeof(struct icmp6hdr));
 
-       if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
-               ICMP6_INC_STATS_OFFSET_BH(idev, ICMP6_MIB_OUTDESTUNREACHS, 
type - ICMPV6_DEST_UNREACH);
        ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
 
 out_put:
@@ -547,9 +547,6 @@ static void icmpv6_echo_reply(struct sk_
        }
        err = icmpv6_push_pending_frames(sk, &fl, &tmp_hdr, skb->len + 
sizeof(struct icmp6hdr));
 
-       ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTECHOREPLIES);
-       ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
-
 out_put:
        if (likely(idev != NULL))
                in6_dev_put(idev);
@@ -656,10 +653,7 @@ static int icmpv6_rcv(struct sk_buff **p
 
        type = hdr->icmp6_type;
 
-       if (type >= ICMPV6_DEST_UNREACH && type <= ICMPV6_PARAMPROB)
-               ICMP6_INC_STATS_OFFSET_BH(idev, ICMP6_MIB_INDESTUNREACHS, 
type - ICMPV6_DEST_UNREACH);
-       else if (type >= ICMPV6_ECHO_REQUEST && type <= NDISC_REDIRECT)
-               ICMP6_INC_STATS_OFFSET_BH(idev, ICMP6_MIB_INECHOS, type - 
ICMPV6_ECHO_REQUEST);
+       ICMP6MSGIN_INC_STATS_BH(idev, type);
 
        switch (type) {
        case ICMPV6_ECHO_REQUEST:
diff -ruNp linux-2.6.22.5/net/ipv6/ip6_output.c 
linux-2.6.22.5_ICMPv6MSG2/net/ipv6/ip6_output.c
--- linux-2.6.22.5/net/ipv6/ip6_output.c        2007-08-22 
16:23:54.000000000 -0700
+++ linux-2.6.22.5_ICMPv6MSG2/net/ipv6/ip6_output.c     2007-09-14 
13:47:39.000000000 -0700
@@ -1393,6 +1393,13 @@ int ip6_push_pending_frames(struct sock 
 
        skb->dst = dst_clone(&rt->u.dst);
        IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
+       if (proto == IPPROTO_ICMPV6) {
+               struct inet6_dev *idev = ip6_dst_idev(skb->dst);
+
+               ICMP6MSGOUT_INC_STATS_BH(idev, 
icmp6_hdr(skb)->icmp6_type);
+               ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
+       }
+
        err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, 
skb->dst->dev, dst_output);
        if (err) {
                if (err > 0)
diff -ruNp linux-2.6.22.5/net/ipv6/mcast.c 
linux-2.6.22.5_ICMPv6MSG2/net/ipv6/mcast.c
--- linux-2.6.22.5/net/ipv6/mcast.c     2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG2/net/ipv6/mcast.c  2007-09-13 
15:09:05.000000000 -0700
@@ -1478,10 +1478,11 @@ static void mld_sendpack(struct sk_buff 
        err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
                mld_dev_queue_xmit);
        if (!err) {
-               ICMP6_INC_STATS(idev,ICMP6_MIB_OUTMSGS);
-               IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
+               ICMP6MSGOUT_INC_STATS_BH(idev, ICMPV6_MLD2_REPORT);
+               ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
+               IP6_INC_STATS_BH(idev, IPSTATS_MIB_OUTMCASTPKTS);
        } else
-               IP6_INC_STATS(idev, IPSTATS_MIB_OUTDISCARDS);
+               IP6_INC_STATS_BH(idev, IPSTATS_MIB_OUTDISCARDS);
 
        if (likely(idev != NULL))
                in6_dev_put(idev);
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
+               ICMP6MSGOUT_INC_STATS(idev, type);
                ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
                IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
        } else
diff -ruNp linux-2.6.22.5/net/ipv6/ndisc.c 
linux-2.6.22.5_ICMPv6MSG2/net/ipv6/ndisc.c
--- linux-2.6.22.5/net/ipv6/ndisc.c     2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG2/net/ipv6/ndisc.c  2007-09-12 
14:42:38.000000000 -0700
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
+               ICMP6MSGOUT_INC_STATS(idev, type);
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
+               ICMP6MSGOUT_INC_STATS(idev, NDISC_REDIRECT);
                ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
        }
 
diff -ruNp linux-2.6.22.5/net/ipv6/proc.c 
linux-2.6.22.5_ICMPv6MSG2/net/ipv6/proc.c
--- linux-2.6.22.5/net/ipv6/proc.c      2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPv6MSG2/net/ipv6/proc.c   2007-09-14 
13:41:23.000000000 -0700
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
 
+static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void **mib)
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
+                       snmp_fold_field(mib, i));
+       }
+
+       /* print by number (nonzero only) - ICMPMsgStat format */
+       for (i = 0; i < ICMP6MSG_MIB_MAX; i++) {
+               unsigned long val;
+
+               val = snmp_fold_field(mib, i);
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
@@ -159,9 +179,11 @@ static int snmp6_seq_show(struct seq_fil
                seq_printf(seq, "%-32s\t%u\n", "ifIndex", 
idev->dev->ifindex);
                snmp6_seq_show_item(seq, (void **)idev->stats.ipv6, 
snmp6_ipstats_list);
                snmp6_seq_show_item(seq, (void **)idev->stats.icmpv6, 
snmp6_icmp6_list);
+               snmp6_seq_show_icmpv6msg(seq, (void 
**)idev->stats.icmpv6msg);
        } else {
                snmp6_seq_show_item(seq, (void **)ipv6_statistics, 
snmp6_ipstats_list);
                snmp6_seq_show_item(seq, (void **)icmpv6_statistics, 
snmp6_icmp6_list);
+               snmp6_seq_show_icmpv6msg(seq, (void 
**)icmpv6msg_statistics);
                snmp6_seq_show_item(seq, (void **)udp_stats_in6, 
snmp6_udp6_list);
                snmp6_seq_show_item(seq, (void **)udplite_stats_in6, 
snmp6_udplite6_list);
        }


--=_mixed 00759E0C88257356_=
Content-Type: application/octet-stream; name="icmpmsgmib6-2.patch"
Content-Disposition: attachment; filename="icmpmsgmib6-2.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMjIuNS9pbmNsdWRlL2xpbnV4L3NubXAuaCBsaW51eC0yLjYu
MjIuNV9JQ01QdjZNU0cyL2luY2x1ZGUvbGludXgvc25tcC5oCi0tLSBsaW51eC0yLjYuMjIuNS9p
bmNsdWRlL2xpbnV4L3NubXAuaAkyMDA3LTA4LTIyIDE2OjIzOjU0LjAwMDAwMDAwMCAtMDcwMAor
KysgbGludXgtMi42LjIyLjVfSUNNUHY2TVNHMi9pbmNsdWRlL2xpbnV4L3NubXAuaAkyMDA3LTA5
LTEwIDE1OjAyOjQzLjAwMDAwMDAwMCAtMDcwMApAQCAtOTEsMzUgKzkxLDEyIEBAIGVudW0KIAlJ
Q01QNl9NSUJfTlVNID0gMCwKIAlJQ01QNl9NSUJfSU5NU0dTLAkJCS8qIEluTXNncyAqLwogCUlD
TVA2X01JQl9JTkVSUk9SUywJCQkvKiBJbkVycm9ycyAqLwotCUlDTVA2X01JQl9JTkRFU1RVTlJF
QUNIUywJCS8qIEluRGVzdFVucmVhY2hzICovCi0JSUNNUDZfTUlCX0lOUEtUVE9PQklHUywJCQkv
KiBJblBrdFRvb0JpZ3MgKi8KLQlJQ01QNl9NSUJfSU5USU1FRVhDRFMsCQkJLyogSW5UaW1lRXhj
ZHMgKi8KLQlJQ01QNl9NSUJfSU5QQVJNUFJPQkxFTVMsCQkvKiBJblBhcm1Qcm9ibGVtcyAqLwot
CUlDTVA2X01JQl9JTkVDSE9TLAkJCS8qIEluRWNob3MgKi8KLQlJQ01QNl9NSUJfSU5FQ0hPUkVQ
TElFUywJCS8qIEluRWNob1JlcGxpZXMgKi8KLQlJQ01QNl9NSUJfSU5HUk9VUE1FTUJRVUVSSUVT
LAkJLyogSW5Hcm91cE1lbWJRdWVyaWVzICovCi0JSUNNUDZfTUlCX0lOR1JPVVBNRU1CUkVTUE9O
U0VTLAkJLyogSW5Hcm91cE1lbWJSZXNwb25zZXMgKi8KLQlJQ01QNl9NSUJfSU5HUk9VUE1FTUJS
RURVQ1RJT05TLAkvKiBJbkdyb3VwTWVtYlJlZHVjdGlvbnMgKi8KLQlJQ01QNl9NSUJfSU5ST1VU
RVJTT0xJQ0lUUywJCS8qIEluUm91dGVyU29saWNpdHMgKi8KLQlJQ01QNl9NSUJfSU5ST1VURVJB
RFZFUlRJU0VNRU5UUywJLyogSW5Sb3V0ZXJBZHZlcnRpc2VtZW50cyAqLwotCUlDTVA2X01JQl9J
Tk5FSUdIQk9SU09MSUNJVFMsCQkvKiBJbk5laWdoYm9yU29saWNpdHMgKi8KLQlJQ01QNl9NSUJf
SU5ORUlHSEJPUkFEVkVSVElTRU1FTlRTLAkvKiBJbk5laWdoYm9yQWR2ZXJ0aXNlbWVudHMgKi8K
LQlJQ01QNl9NSUJfSU5SRURJUkVDVFMsCQkJLyogSW5SZWRpcmVjdHMgKi8KIAlJQ01QNl9NSUJf
T1VUTVNHUywJCQkvKiBPdXRNc2dzICovCi0JSUNNUDZfTUlCX09VVERFU1RVTlJFQUNIUywJCS8q
IE91dERlc3RVbnJlYWNocyAqLwotCUlDTVA2X01JQl9PVVRQS1RUT09CSUdTLAkJLyogT3V0UGt0
VG9vQmlncyAqLwotCUlDTVA2X01JQl9PVVRUSU1FRVhDRFMsCQkJLyogT3V0VGltZUV4Y2RzICov
Ci0JSUNNUDZfTUlCX09VVFBBUk1QUk9CTEVNUywJCS8qIE91dFBhcm1Qcm9ibGVtcyAqLwotCUlD
TVA2X01JQl9PVVRFQ0hPUkVQTElFUywJCS8qIE91dEVjaG9SZXBsaWVzICovCi0JSUNNUDZfTUlC
X09VVFJPVVRFUlNPTElDSVRTLAkJLyogT3V0Um91dGVyU29saWNpdHMgKi8KLQlJQ01QNl9NSUJf
T1VUTkVJR0hCT1JTT0xJQ0lUUywJCS8qIE91dE5laWdoYm9yU29saWNpdHMgKi8KLQlJQ01QNl9N
SUJfT1VUTkVJR0hCT1JBRFZFUlRJU0VNRU5UUywJLyogT3V0TmVpZ2hib3JBZHZlcnRpc2VtZW50
cyAqLwotCUlDTVA2X01JQl9PVVRSRURJUkVDVFMsCQkJLyogT3V0UmVkaXJlY3RzICovCi0JSUNN
UDZfTUlCX09VVEdST1VQTUVNQlJFU1BPTlNFUywJLyogT3V0R3JvdXBNZW1iUmVzcG9uc2VzICov
Ci0JSUNNUDZfTUlCX09VVEdST1VQTUVNQlJFRFVDVElPTlMsCS8qIE91dEdyb3VwTWVtYlJlZHVj
dGlvbnMgKi8KIAlfX0lDTVA2X01JQl9NQVgKIH07CiAKKyNkZWZpbmUgX19JQ01QNk1TR19NSUJf
TUFYIDUxMiAvKiBPdXQrSW4gZm9yIGFsbCA4LWJpdCBJQ01QdjYgdHlwZXMgKi8KKwogLyogdGNw
IG1pYiBkZWZpbml0aW9ucyAqLwogLyoKICAqIFJGQyAxMjEzOiAgTUlCLUlJIFRDUCBncm91cApk
aWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L2luY2x1ZGUvbmV0L2lmX2luZXQ2LmggbGludXgtMi42
LjIyLjVfSUNNUHY2TVNHMi9pbmNsdWRlL25ldC9pZl9pbmV0Ni5oCi0tLSBsaW51eC0yLjYuMjIu
NS9pbmNsdWRlL25ldC9pZl9pbmV0Ni5oCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0w
NzAwCisrKyBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cyL2luY2x1ZGUvbmV0L2lmX2luZXQ2LmgJ
MjAwNy0wOS0xMiAxNDoxMTo0OS4wMDAwMDAwMDAgLTA3MDAKQEAgLTE1NCw2ICsxNTQsNyBAQCBz
dHJ1Y3QgaXB2Nl9kZXZzdGF0IHsKIAlzdHJ1Y3QgcHJvY19kaXJfZW50cnkJKnByb2NfZGlyX2Vu
dHJ5OwogCURFRklORV9TTk1QX1NUQVQoc3RydWN0IGlwc3RhdHNfbWliLCBpcHY2KTsKIAlERUZJ
TkVfU05NUF9TVEFUKHN0cnVjdCBpY21wdjZfbWliLCBpY21wdjYpOworCURFRklORV9TTk1QX1NU
QVQoc3RydWN0IGljbXB2Nm1zZ19taWIsIGljbXB2Nm1zZyk7CiB9OwogCiBzdHJ1Y3QgaW5ldDZf
ZGV2IApkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L2luY2x1ZGUvbmV0L2lwdjYuaCBsaW51eC0y
LjYuMjIuNV9JQ01QdjZNU0cyL2luY2x1ZGUvbmV0L2lwdjYuaAotLS0gbGludXgtMi42LjIyLjUv
aW5jbHVkZS9uZXQvaXB2Ni5oCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0wNzAwCisr
KyBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cyL2luY2x1ZGUvbmV0L2lwdjYuaAkyMDA3LTA5LTEz
IDE1OjA5OjI4LjAwMDAwMDAwMCAtMDcwMApAQCAtMTExLDQ1ICsxMTEsMjggQEAgc3RydWN0IGZy
YWdfaGRyIHsKIGV4dGVybiBpbnQgc3lzY3RsX2lwdjZfYmluZHY2b25seTsKIGV4dGVybiBpbnQg
c3lzY3RsX21sZF9tYXhfbXNmOwogCi0vKiBNSUJzICovCi1ERUNMQVJFX1NOTVBfU1RBVChzdHJ1
Y3QgaXBzdGF0c19taWIsIGlwdjZfc3RhdGlzdGljcyk7Ci0jZGVmaW5lIElQNl9JTkNfU1RBVFMo
aWRldixmaWVsZCkJCSh7CQkJXAorI2RlZmluZSBfREVWSU5DKHN0YXRuYW1lLCBtb2RpZmllciwg
aWRldiwgZmllbGQpCQkJXAorKHsJCQkJCQkJCQlcCiAJc3RydWN0IGluZXQ2X2RldiAqX2lkZXYg
PSAoaWRldik7CQkJCVwKIAlpZiAobGlrZWx5KF9pZGV2ICE9IE5VTEwpKQkJCQkJXAotCQlTTk1Q
X0lOQ19TVEFUUyhfaWRldi0+c3RhdHMuaXB2NiwgZmllbGQpOwkJXAotCVNOTVBfSU5DX1NUQVRT
KGlwdjZfc3RhdGlzdGljcywgZmllbGQpOwkJCQlcCi19KQotI2RlZmluZSBJUDZfSU5DX1NUQVRT
X0JIKGlkZXYsZmllbGQpCQkoewkJCVwKLQlzdHJ1Y3QgaW5ldDZfZGV2ICpfaWRldiA9IChpZGV2
KTsJCQkJXAotCWlmIChsaWtlbHkoX2lkZXYgIT0gTlVMTCkpCQkJCQlcCi0JCVNOTVBfSU5DX1NU
QVRTX0JIKF9pZGV2LT5zdGF0cy5pcHY2LCBmaWVsZCk7CQlcCi0JU05NUF9JTkNfU1RBVFNfQkgo
aXB2Nl9zdGF0aXN0aWNzLCBmaWVsZCk7CQkJXAotfSkKLSNkZWZpbmUgSVA2X0lOQ19TVEFUU19V
U0VSKGlkZXYsZmllbGQpCQkoewkJCVwKLQlzdHJ1Y3QgaW5ldDZfZGV2ICpfaWRldiA9IChpZGV2
KTsJCQkJXAotCWlmIChsaWtlbHkoX2lkZXYgIT0gTlVMTCkpCQkJCQlcCi0JCVNOTVBfSU5DX1NU
QVRTX1VTRVIoX2lkZXYtPnN0YXRzLmlwdjYsIGZpZWxkKTsJCVwKLQlTTk1QX0lOQ19TVEFUU19V
U0VSKGlwdjZfc3RhdGlzdGljcywgZmllbGQpOwkJCVwKKwkJU05NUF9JTkNfU1RBVFMjI21vZGlm
aWVyKChfaWRldiktPnN0YXRzLnN0YXRuYW1lLCAoZmllbGQpKTsgXAorCVNOTVBfSU5DX1NUQVRT
IyNtb2RpZmllcihzdGF0bmFtZSMjX3N0YXRpc3RpY3MsIChmaWVsZCkpOwlcCiB9KQorCisvKiBN
SUJzICovCitERUNMQVJFX1NOTVBfU1RBVChzdHJ1Y3QgaXBzdGF0c19taWIsIGlwdjZfc3RhdGlz
dGljcyk7CisKKyNkZWZpbmUgSVA2X0lOQ19TVEFUUyhpZGV2LGZpZWxkKQlfREVWSU5DKGlwdjYs
ICwgaWRldiwgZmllbGQpCisjZGVmaW5lIElQNl9JTkNfU1RBVFNfQkgoaWRldixmaWVsZCkJX0RF
VklOQyhpcHY2LCBfQkgsIGlkZXYsIGZpZWxkKQorI2RlZmluZSBJUDZfSU5DX1NUQVRTX1VTRVIo
aWRldixmaWVsZCkJX0RFVklOQyhpcHY2LCBfVVNFUiwgaWRldiwgZmllbGQpCisKIERFQ0xBUkVf
U05NUF9TVEFUKHN0cnVjdCBpY21wdjZfbWliLCBpY21wdjZfc3RhdGlzdGljcyk7Ci0jZGVmaW5l
IElDTVA2X0lOQ19TVEFUUyhpZGV2LCBmaWVsZCkJCSh7CQkJXAotCXN0cnVjdCBpbmV0Nl9kZXYg
Kl9pZGV2ID0gKGlkZXYpOwkJCQlcCi0JaWYgKGxpa2VseShfaWRldiAhPSBOVUxMKSkJCQkJCVwK
LQkJU05NUF9JTkNfU1RBVFMoaWRldi0+c3RhdHMuaWNtcHY2LCBmaWVsZCk7IAkJXAotCVNOTVBf
SU5DX1NUQVRTKGljbXB2Nl9zdGF0aXN0aWNzLCBmaWVsZCk7CQkJXAotfSkKLSNkZWZpbmUgSUNN
UDZfSU5DX1NUQVRTX0JIKGlkZXYsIGZpZWxkKQkJKHsJCQlcCi0Jc3RydWN0IGluZXQ2X2RldiAq
X2lkZXYgPSAoaWRldik7CQkJCVwKLQlpZiAobGlrZWx5KF9pZGV2ICE9IE5VTEwpKQkJCQkJXAot
CQlTTk1QX0lOQ19TVEFUU19CSCgoX2lkZXYpLT5zdGF0cy5pY21wdjYsIGZpZWxkKTsJXAotCVNO
TVBfSU5DX1NUQVRTX0JIKGljbXB2Nl9zdGF0aXN0aWNzLCBmaWVsZCk7CQkJXAotfSkKLSNkZWZp
bmUgSUNNUDZfSU5DX1NUQVRTX1VTRVIoaWRldiwgZmllbGQpIAkoewkJCVwKLQlzdHJ1Y3QgaW5l
dDZfZGV2ICpfaWRldiA9IChpZGV2KTsJCQkJXAotCWlmIChsaWtlbHkoX2lkZXYgIT0gTlVMTCkp
CQkJCQlcCi0JCVNOTVBfSU5DX1NUQVRTX1VTRVIoX2lkZXYtPnN0YXRzLmljbXB2NiwgZmllbGQp
OwlcCi0JU05NUF9JTkNfU1RBVFNfVVNFUihpY21wdjZfc3RhdGlzdGljcywgZmllbGQpOwkJCVwK
LX0pCitERUNMQVJFX1NOTVBfU1RBVChzdHJ1Y3QgaWNtcHY2bXNnX21pYiwgaWNtcHY2bXNnX3N0
YXRpc3RpY3MpOworCisjZGVmaW5lIElDTVA2X0lOQ19TVEFUUyhpZGV2LCBmaWVsZCkJX0RFVklO
QyhpY21wdjYsICwgaWRldiwgZmllbGQpCisjZGVmaW5lIElDTVA2X0lOQ19TVEFUU19CSChpZGV2
LCBmaWVsZCkJX0RFVklOQyhpY21wdjYsIF9CSCwgaWRldiwgZmllbGQpCisjZGVmaW5lIElDTVA2
X0lOQ19TVEFUU19VU0VSKGlkZXYsIGZpZWxkKSBfREVWSU5DKGljbXB2NiwgX1VTRVIsIGlkZXYs
IGZpZWxkKQorCiAjZGVmaW5lIElDTVA2X0lOQ19TVEFUU19PRkZTRVRfQkgoaWRldiwgZmllbGQs
IG9mZnNldCkJKHsJCQlcCiAJc3RydWN0IGluZXQ2X2RldiAqX2lkZXYgPSBpZGV2OwkJCQkJCVwK
IAlfX3R5cGVvZl9fKG9mZnNldCkgX29mZnNldCA9IChvZmZzZXQpOwkJCQkJXApAQCAtMTU3LDYg
KzE0MCwyMCBAQCBERUNMQVJFX1NOTVBfU1RBVChzdHJ1Y3QgaWNtcHY2X21pYiwgaWNtCiAJCVNO
TVBfSU5DX1NUQVRTX09GRlNFVF9CSChfaWRldi0+c3RhdHMuaWNtcHY2LCBmaWVsZCwgX29mZnNl
dCk7CVwKIAlTTk1QX0lOQ19TVEFUU19PRkZTRVRfQkgoaWNtcHY2X3N0YXRpc3RpY3MsIGZpZWxk
LCBfb2Zmc2V0KTsgICAgCVwKIH0pCisKKyNkZWZpbmUgSUNNUDZNU0dPVVRfSU5DX1NUQVRTKGlk
ZXYsIGZpZWxkKSBcCisJX0RFVklOQyhpY21wdjZtc2csICwgaWRldiwgZmllbGQgKzI1NikKKyNk
ZWZpbmUgSUNNUDZNU0dPVVRfSU5DX1NUQVRTX0JIKGlkZXYsIGZpZWxkKSBcCisJX0RFVklOQyhp
Y21wdjZtc2csIF9CSCwgaWRldiwgZmllbGQgKzI1NikKKyNkZWZpbmUgSUNNUDZNU0dPVVRfSU5D
X1NUQVRTX1VTRVIoaWRldiwgZmllbGQpIFwKKwlfREVWSU5DKGljbXB2Nm1zZywgX1VTRVIsIGlk
ZXYsIGZpZWxkICsyNTYpCisjZGVmaW5lIElDTVA2TVNHSU5fSU5DX1NUQVRTKGlkZXYsIGZpZWxk
KSBcCisJIF9ERVZJTkMoaWNtcHY2bXNnLCAsIGlkZXYsIGZpZWxkKQorI2RlZmluZSBJQ01QNk1T
R0lOX0lOQ19TVEFUU19CSChpZGV2LCBmaWVsZCkgXAorCV9ERVZJTkMoaWNtcHY2bXNnLCBfQkgs
IGlkZXYsIGZpZWxkKQorI2RlZmluZSBJQ01QNk1TR0lOX0lOQ19TVEFUU19VU0VSKGlkZXYsIGZp
ZWxkKSBcCisJX0RFVklOQyhpY21wdjZtc2csIF9VU0VSLCBpZGV2LCBmaWVsZCkKKwogREVDTEFS
RV9TTk1QX1NUQVQoc3RydWN0IHVkcF9taWIsIHVkcF9zdGF0c19pbjYpOwogREVDTEFSRV9TTk1Q
X1NUQVQoc3RydWN0IHVkcF9taWIsIHVkcGxpdGVfc3RhdHNfaW42KTsKICNkZWZpbmUgVURQNl9J
TkNfU1RBVFNfQkgoZmllbGQsIGlzX3VkcGxpdGUpIAkJCSAgICAgIGRvICB7ICBcCmRpZmYgLXJ1
TnAgbGludXgtMi42LjIyLjUvaW5jbHVkZS9uZXQvc25tcC5oIGxpbnV4LTIuNi4yMi41X0lDTVB2
Nk1TRzIvaW5jbHVkZS9uZXQvc25tcC5oCi0tLSBsaW51eC0yLjYuMjIuNS9pbmNsdWRlL25ldC9z
bm1wLmgJMjAwNy0wOC0yMiAxNjoyMzo1NC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4y
Mi41X0lDTVB2Nk1TRzIvaW5jbHVkZS9uZXQvc25tcC5oCTIwMDctMDktMTAgMTU6MDA6MTguMDAw
MDAwMDAwIC0wNzAwCkBAIC04OCw2ICs4OCwxMiBAQCBzdHJ1Y3QgaWNtcHY2X21pYiB7CiAJdW5z
aWduZWQgbG9uZwltaWJzW0lDTVA2X01JQl9NQVhdOwogfSBfX1NOTVBfTUlCX0FMSUdOX187CiAK
KyNkZWZpbmUgSUNNUDZNU0dfTUlCX01BWCAgX19JQ01QNk1TR19NSUJfTUFYCitzdHJ1Y3QgaWNt
cHY2bXNnX21pYiB7CisJdW5zaWduZWQgbG9uZwltaWJzW0lDTVA2TVNHX01JQl9NQVhdOworfSBf
X1NOTVBfTUlCX0FMSUdOX187CisKKwogLyogVENQICovCiAjZGVmaW5lIFRDUF9NSUJfTUFYCV9f
VENQX01JQl9NQVgKIHN0cnVjdCB0Y3BfbWliIHsKZGlmZiAtcnVOcCBsaW51eC0yLjYuMjIuNS9u
ZXQvaXB2Ni9hZGRyY29uZi5jIGxpbnV4LTIuNi4yMi41X0lDTVB2Nk1TRzIvbmV0L2lwdjYvYWRk
cmNvbmYuYwotLS0gbGludXgtMi42LjIyLjUvbmV0L2lwdjYvYWRkcmNvbmYuYwkyMDA3LTA4LTIy
IDE2OjIzOjU0LjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjIyLjVfSUNNUHY2TVNHMi9u
ZXQvaXB2Ni9hZGRyY29uZi5jCTIwMDctMDktMTMgMTU6MDY6MzMuMDAwMDAwMDAwIC0wNzAwCkBA
IC0yNjAsOSArMjYwLDE1IEBAIHN0YXRpYyBpbnQgc25tcDZfYWxsb2NfZGV2KHN0cnVjdCBpbmV0
Nl8KIAkJCSAgc2l6ZW9mKHN0cnVjdCBpY21wdjZfbWliKSwKIAkJCSAgX19hbGlnbm9mX18oc3Ry
dWN0IGljbXB2Nl9taWIpKSA8IDApCiAJCWdvdG8gZXJyX2ljbXA7CisJaWYgKHNubXBfbWliX2lu
aXQoKHZvaWQgKiopaWRldi0+c3RhdHMuaWNtcHY2bXNnLAorCQkJICBzaXplb2Yoc3RydWN0IGlj
bXB2Nm1zZ19taWIpLAorCQkJICBfX2FsaWdub2ZfXyhzdHJ1Y3QgaWNtcHY2bXNnX21pYikpIDwg
MCkKKwkJZ290byBlcnJfaWNtcG1zZzsKIAogCXJldHVybiAwOwogCitlcnJfaWNtcG1zZzoKKwlz
bm1wX21pYl9mcmVlKCh2b2lkICoqKWlkZXYtPnN0YXRzLmljbXB2Nik7CiBlcnJfaWNtcDoKIAlz
bm1wX21pYl9mcmVlKCh2b2lkICoqKWlkZXYtPnN0YXRzLmlwdjYpOwogZXJyX2lwOgpAQCAtMjcx
LDYgKzI3Nyw3IEBAIGVycl9pcDoKIAogc3RhdGljIGludCBzbm1wNl9mcmVlX2RldihzdHJ1Y3Qg
aW5ldDZfZGV2ICppZGV2KQogeworCXNubXBfbWliX2ZyZWUoKHZvaWQgKiopaWRldi0+c3RhdHMu
aWNtcHY2bXNnKTsKIAlzbm1wX21pYl9mcmVlKCh2b2lkICoqKWlkZXYtPnN0YXRzLmljbXB2Nik7
CiAJc25tcF9taWJfZnJlZSgodm9pZCAqKilpZGV2LT5zdGF0cy5pcHY2KTsKIAlyZXR1cm4gMDsK
ZGlmZiAtcnVOcCBsaW51eC0yLjYuMjIuNS9uZXQvaXB2Ni9hZl9pbmV0Ni5jIGxpbnV4LTIuNi4y
Mi41X0lDTVB2Nk1TRzIvbmV0L2lwdjYvYWZfaW5ldDYuYwotLS0gbGludXgtMi42LjIyLjUvbmV0
L2lwdjYvYWZfaW5ldDYuYwkyMDA3LTA4LTIyIDE2OjIzOjU0LjAwMDAwMDAwMCAtMDcwMAorKysg
bGludXgtMi42LjIyLjVfSUNNUHY2TVNHMi9uZXQvaXB2Ni9hZl9pbmV0Ni5jCTIwMDctMDktMTAg
MTQ6MTk6NTcuMDAwMDAwMDAwIC0wNzAwCkBAIC03MTksNiArNzE5LDkgQEAgc3RhdGljIGludCBf
X2luaXQgaW5pdF9pcHY2X21pYnModm9pZCkKIAlpZiAoc25tcF9taWJfaW5pdCgodm9pZCAqKilp
Y21wdjZfc3RhdGlzdGljcywgc2l6ZW9mIChzdHJ1Y3QgaWNtcHY2X21pYiksCiAJCQkgIF9fYWxp
Z25vZl9fKHN0cnVjdCBpY21wdjZfbWliKSkgPCAwKQogCQlnb3RvIGVycl9pY21wX21pYjsKKwlp
ZiAoc25tcF9taWJfaW5pdCgodm9pZCAqKilpY21wdjZtc2dfc3RhdGlzdGljcywKKwkgICAgc2l6
ZW9mIChzdHJ1Y3QgaWNtcHY2bXNnX21pYiksIF9fYWxpZ25vZl9fKHN0cnVjdCBpY21wdjZfbWli
KSkgPCAwKQorCQlnb3RvIGVycl9pY21wbXNnX21pYjsKIAlpZiAoc25tcF9taWJfaW5pdCgodm9p
ZCAqKil1ZHBfc3RhdHNfaW42LCBzaXplb2YgKHN0cnVjdCB1ZHBfbWliKSwKIAkJCSAgX19hbGln
bm9mX18oc3RydWN0IHVkcF9taWIpKSA8IDApCiAJCWdvdG8gZXJyX3VkcF9taWI7CkBAIC03MzAs
NiArNzMzLDggQEAgc3RhdGljIGludCBfX2luaXQgaW5pdF9pcHY2X21pYnModm9pZCkKIGVycl91
ZHBsaXRlX21pYjoKIAlzbm1wX21pYl9mcmVlKCh2b2lkICoqKXVkcF9zdGF0c19pbjYpOwogZXJy
X3VkcF9taWI6CisJc25tcF9taWJfZnJlZSgodm9pZCAqKilpY21wdjZtc2dfc3RhdGlzdGljcyk7
CitlcnJfaWNtcG1zZ19taWI6CiAJc25tcF9taWJfZnJlZSgodm9pZCAqKilpY21wdjZfc3RhdGlz
dGljcyk7CiBlcnJfaWNtcF9taWI6CiAJc25tcF9taWJfZnJlZSgodm9pZCAqKilpcHY2X3N0YXRp
c3RpY3MpOwpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L25ldC9pcHY2L2ljbXAuYyBsaW51eC0y
LjYuMjIuNV9JQ01QdjZNU0cyL25ldC9pcHY2L2ljbXAuYwotLS0gbGludXgtMi42LjIyLjUvbmV0
L2lwdjYvaWNtcC5jCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51
eC0yLjYuMjIuNV9JQ01QdjZNU0cyL25ldC9pcHY2L2ljbXAuYwkyMDA3LTA5LTE0IDEzOjM5OjIz
LjAwMDAwMDAwMCAtMDcwMApAQCAtNjksNiArNjksOCBAQAogCiBERUZJTkVfU05NUF9TVEFUKHN0
cnVjdCBpY21wdjZfbWliLCBpY21wdjZfc3RhdGlzdGljcykgX19yZWFkX21vc3RseTsKIEVYUE9S
VF9TWU1CT0woaWNtcHY2X3N0YXRpc3RpY3MpOworREVGSU5FX1NOTVBfU1RBVChzdHJ1Y3QgaWNt
cHY2bXNnX21pYiwgaWNtcHY2bXNnX3N0YXRpc3RpY3MpIF9fcmVhZF9tb3N0bHk7CitFWFBPUlRf
U1lNQk9MKGljbXB2Nm1zZ19zdGF0aXN0aWNzKTsKIAogLyoKICAqCVRoZSBJQ01QIHNvY2tldChz
KS4gVGhpcyBpcyB0aGUgbW9zdCBjb252ZW5pZW50IHdheSB0byBmbG93IGNvbnRyb2wKQEAgLTQ1
Niw4ICs0NTgsNiBAQCB2b2lkIGljbXB2Nl9zZW5kKHN0cnVjdCBza19idWZmICpza2IsIGluCiAJ
fQogCWVyciA9IGljbXB2Nl9wdXNoX3BlbmRpbmdfZnJhbWVzKHNrLCAmZmwsICZ0bXBfaGRyLCBs
ZW4gKyBzaXplb2Yoc3RydWN0IGljbXA2aGRyKSk7CiAKLQlpZiAodHlwZSA+PSBJQ01QVjZfREVT
VF9VTlJFQUNIICYmIHR5cGUgPD0gSUNNUFY2X1BBUkFNUFJPQikKLQkJSUNNUDZfSU5DX1NUQVRT
X09GRlNFVF9CSChpZGV2LCBJQ01QNl9NSUJfT1VUREVTVFVOUkVBQ0hTLCB0eXBlIC0gSUNNUFY2
X0RFU1RfVU5SRUFDSCk7CiAJSUNNUDZfSU5DX1NUQVRTX0JIKGlkZXYsIElDTVA2X01JQl9PVVRN
U0dTKTsKIAogb3V0X3B1dDoKQEAgLTU0Nyw5ICs1NDcsNiBAQCBzdGF0aWMgdm9pZCBpY21wdjZf
ZWNob19yZXBseShzdHJ1Y3Qgc2tfCiAJfQogCWVyciA9IGljbXB2Nl9wdXNoX3BlbmRpbmdfZnJh
bWVzKHNrLCAmZmwsICZ0bXBfaGRyLCBza2ItPmxlbiArIHNpemVvZihzdHJ1Y3QgaWNtcDZoZHIp
KTsKIAotCUlDTVA2X0lOQ19TVEFUU19CSChpZGV2LCBJQ01QNl9NSUJfT1VURUNIT1JFUExJRVMp
OwotCUlDTVA2X0lOQ19TVEFUU19CSChpZGV2LCBJQ01QNl9NSUJfT1VUTVNHUyk7Ci0KIG91dF9w
dXQ6CiAJaWYgKGxpa2VseShpZGV2ICE9IE5VTEwpKQogCQlpbjZfZGV2X3B1dChpZGV2KTsKQEAg
LTY1NiwxMCArNjUzLDcgQEAgc3RhdGljIGludCBpY21wdjZfcmN2KHN0cnVjdCBza19idWZmICoq
cAogCiAJdHlwZSA9IGhkci0+aWNtcDZfdHlwZTsKIAotCWlmICh0eXBlID49IElDTVBWNl9ERVNU
X1VOUkVBQ0ggJiYgdHlwZSA8PSBJQ01QVjZfUEFSQU1QUk9CKQotCQlJQ01QNl9JTkNfU1RBVFNf
T0ZGU0VUX0JIKGlkZXYsIElDTVA2X01JQl9JTkRFU1RVTlJFQUNIUywgdHlwZSAtIElDTVBWNl9E
RVNUX1VOUkVBQ0gpOwotCWVsc2UgaWYgKHR5cGUgPj0gSUNNUFY2X0VDSE9fUkVRVUVTVCAmJiB0
eXBlIDw9IE5ESVNDX1JFRElSRUNUKQotCQlJQ01QNl9JTkNfU1RBVFNfT0ZGU0VUX0JIKGlkZXYs
IElDTVA2X01JQl9JTkVDSE9TLCB0eXBlIC0gSUNNUFY2X0VDSE9fUkVRVUVTVCk7CisJSUNNUDZN
U0dJTl9JTkNfU1RBVFNfQkgoaWRldiwgdHlwZSk7CiAKIAlzd2l0Y2ggKHR5cGUpIHsKIAljYXNl
IElDTVBWNl9FQ0hPX1JFUVVFU1Q6CmRpZmYgLXJ1TnAgbGludXgtMi42LjIyLjUvbmV0L2lwdjYv
aXA2X291dHB1dC5jIGxpbnV4LTIuNi4yMi41X0lDTVB2Nk1TRzIvbmV0L2lwdjYvaXA2X291dHB1
dC5jCi0tLSBsaW51eC0yLjYuMjIuNS9uZXQvaXB2Ni9pcDZfb3V0cHV0LmMJMjAwNy0wOC0yMiAx
NjoyMzo1NC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4yMi41X0lDTVB2Nk1TRzIvbmV0
L2lwdjYvaXA2X291dHB1dC5jCTIwMDctMDktMTQgMTM6NDc6MzkuMDAwMDAwMDAwIC0wNzAwCkBA
IC0xMzkzLDYgKzEzOTMsMTMgQEAgaW50IGlwNl9wdXNoX3BlbmRpbmdfZnJhbWVzKHN0cnVjdCBz
b2NrIAogCiAJc2tiLT5kc3QgPSBkc3RfY2xvbmUoJnJ0LT51LmRzdCk7CiAJSVA2X0lOQ19TVEFU
UyhydC0+cnQ2aV9pZGV2LCBJUFNUQVRTX01JQl9PVVRSRVFVRVNUUyk7CisJaWYgKHByb3RvID09
IElQUFJPVE9fSUNNUFY2KSB7CisJCXN0cnVjdCBpbmV0Nl9kZXYgKmlkZXYgPSBpcDZfZHN0X2lk
ZXYoc2tiLT5kc3QpOworCisJCUlDTVA2TVNHT1VUX0lOQ19TVEFUU19CSChpZGV2LCBpY21wNl9o
ZHIoc2tiKS0+aWNtcDZfdHlwZSk7CisJCUlDTVA2X0lOQ19TVEFUU19CSChpZGV2LCBJQ01QNl9N
SUJfT1VUTVNHUyk7CisJfQorCiAJZXJyID0gTkZfSE9PSyhQRl9JTkVUNiwgTkZfSVA2X0xPQ0FM
X09VVCwgc2tiLCBOVUxMLCBza2ItPmRzdC0+ZGV2LCBkc3Rfb3V0cHV0KTsKIAlpZiAoZXJyKSB7
CiAJCWlmIChlcnIgPiAwKQpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L25ldC9pcHY2L21jYXN0
LmMgbGludXgtMi42LjIyLjVfSUNNUHY2TVNHMi9uZXQvaXB2Ni9tY2FzdC5jCi0tLSBsaW51eC0y
LjYuMjIuNS9uZXQvaXB2Ni9tY2FzdC5jCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0w
NzAwCisrKyBsaW51eC0yLjYuMjIuNV9JQ01QdjZNU0cyL25ldC9pcHY2L21jYXN0LmMJMjAwNy0w
OS0xMyAxNTowOTowNS4wMDAwMDAwMDAgLTA3MDAKQEAgLTE0NzgsMTAgKzE0NzgsMTEgQEAgc3Rh
dGljIHZvaWQgbWxkX3NlbmRwYWNrKHN0cnVjdCBza19idWZmIAogCWVyciA9IE5GX0hPT0soUEZf
SU5FVDYsIE5GX0lQNl9MT0NBTF9PVVQsIHNrYiwgTlVMTCwgc2tiLT5kZXYsCiAJCW1sZF9kZXZf
cXVldWVfeG1pdCk7CiAJaWYgKCFlcnIpIHsKLQkJSUNNUDZfSU5DX1NUQVRTKGlkZXYsSUNNUDZf
TUlCX09VVE1TR1MpOwotCQlJUDZfSU5DX1NUQVRTKGlkZXYsIElQU1RBVFNfTUlCX09VVE1DQVNU
UEtUUyk7CisJCUlDTVA2TVNHT1VUX0lOQ19TVEFUU19CSChpZGV2LCBJQ01QVjZfTUxEMl9SRVBP
UlQpOworCQlJQ01QNl9JTkNfU1RBVFNfQkgoaWRldiwgSUNNUDZfTUlCX09VVE1TR1MpOworCQlJ
UDZfSU5DX1NUQVRTX0JIKGlkZXYsIElQU1RBVFNfTUlCX09VVE1DQVNUUEtUUyk7CiAJfSBlbHNl
Ci0JCUlQNl9JTkNfU1RBVFMoaWRldiwgSVBTVEFUU19NSUJfT1VURElTQ0FSRFMpOworCQlJUDZf
SU5DX1NUQVRTX0JIKGlkZXYsIElQU1RBVFNfTUlCX09VVERJU0NBUkRTKTsKIAogCWlmIChsaWtl
bHkoaWRldiAhPSBOVUxMKSkKIAkJaW42X2Rldl9wdXQoaWRldik7CkBAIC0xODIxLDEwICsxODIy
LDcgQEAgc3RhdGljIHZvaWQgaWdtcDZfc2VuZChzdHJ1Y3QgaW42X2FkZHIgKgogCWVyciA9IE5G
X0hPT0soUEZfSU5FVDYsIE5GX0lQNl9MT0NBTF9PVVQsIHNrYiwgTlVMTCwgc2tiLT5kZXYsCiAJ
CW1sZF9kZXZfcXVldWVfeG1pdCk7CiAJaWYgKCFlcnIpIHsKLQkJaWYgKHR5cGUgPT0gSUNNUFY2
X01HTV9SRURVQ1RJT04pCi0JCQlJQ01QNl9JTkNfU1RBVFMoaWRldiwgSUNNUDZfTUlCX09VVEdS
T1VQTUVNQlJFRFVDVElPTlMpOwotCQllbHNlCi0JCQlJQ01QNl9JTkNfU1RBVFMoaWRldiwgSUNN
UDZfTUlCX09VVEdST1VQTUVNQlJFU1BPTlNFUyk7CisJCUlDTVA2TVNHT1VUX0lOQ19TVEFUUyhp
ZGV2LCB0eXBlKTsKIAkJSUNNUDZfSU5DX1NUQVRTKGlkZXYsIElDTVA2X01JQl9PVVRNU0dTKTsK
IAkJSVA2X0lOQ19TVEFUUyhpZGV2LCBJUFNUQVRTX01JQl9PVVRNQ0FTVFBLVFMpOwogCX0gZWxz
ZQpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L25ldC9pcHY2L25kaXNjLmMgbGludXgtMi42LjIy
LjVfSUNNUHY2TVNHMi9uZXQvaXB2Ni9uZGlzYy5jCi0tLSBsaW51eC0yLjYuMjIuNS9uZXQvaXB2
Ni9uZGlzYy5jCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0y
LjYuMjIuNV9JQ01QdjZNU0cyL25ldC9pcHY2L25kaXNjLmMJMjAwNy0wOS0xMiAxNDo0MjozOC4w
MDAwMDAwMDAgLTA3MDAKQEAgLTQzMSw3ICs0MzEsNyBAQCBzdGF0aWMgdm9pZCBfX25kaXNjX3Nl
bmQoc3RydWN0IG5ldF9kZXZpCiAJCQkgc3RydWN0IG5laWdoYm91ciAqbmVpZ2gsCiAJCQkgc3Ry
dWN0IGluNl9hZGRyICpkYWRkciwgc3RydWN0IGluNl9hZGRyICpzYWRkciwKIAkJCSBzdHJ1Y3Qg
aWNtcDZoZHIgKmljbXA2aCwgc3RydWN0IGluNl9hZGRyICp0YXJnZXQsCi0JCQkgaW50IGxsaW5m
bywgaW50IGljbXA2X21pYl9vdXRuZCkKKwkJCSBpbnQgbGxpbmZvKQogewogCXN0cnVjdCBmbG93
aSBmbDsKIAlzdHJ1Y3QgZHN0X2VudHJ5ICpkc3Q7CkBAIC00NDEsOSArNDQxLDExIEBAIHN0YXRp
YyB2b2lkIF9fbmRpc2Nfc2VuZChzdHJ1Y3QgbmV0X2RldmkKIAlzdHJ1Y3QgaW5ldDZfZGV2ICpp
ZGV2OwogCWludCBsZW47CiAJaW50IGVycjsKLQl1OCAqb3B0OworCXU4ICpvcHQsIHR5cGU7CisK
Kwl0eXBlID0gaWNtcDZoLT5pY21wNl90eXBlOwogCi0JbmRpc2NfZmxvd19pbml0KCZmbCwgaWNt
cDZoLT5pY21wNl90eXBlLCBzYWRkciwgZGFkZHIsCisJbmRpc2NfZmxvd19pbml0KCZmbCwgdHlw
ZSwgc2FkZHIsIGRhZGRyLAogCQkJZGV2LT5pZmluZGV4KTsKIAogCWRzdCA9IG5kaXNjX2RzdF9h
bGxvYyhkZXYsIG5laWdoLCBkYWRkciwgaXA2X291dHB1dCk7CkBAIC01MDQsNyArNTA2LDcgQEAg
c3RhdGljIHZvaWQgX19uZGlzY19zZW5kKHN0cnVjdCBuZXRfZGV2aQogCiAJZXJyID0gTkZfSE9P
SyhQRl9JTkVUNiwgTkZfSVA2X0xPQ0FMX09VVCwgc2tiLCBOVUxMLCBkc3QtPmRldiwgZHN0X291
dHB1dCk7CiAJaWYgKCFlcnIpIHsKLQkJSUNNUDZfSU5DX1NUQVRTKGlkZXYsIGljbXA2X21pYl9v
dXRuZCk7CisJCUlDTVA2TVNHT1VUX0lOQ19TVEFUUyhpZGV2LCB0eXBlKTsKIAkJSUNNUDZfSU5D
X1NUQVRTKGlkZXYsIElDTVA2X01JQl9PVVRNU0dTKTsKIAl9CiAKQEAgLTU0Miw4ICs1NDQsNyBA
QCBzdGF0aWMgdm9pZCBuZGlzY19zZW5kX25hKHN0cnVjdCBuZXRfZGV2CiAKIAlfX25kaXNjX3Nl
bmQoZGV2LCBuZWlnaCwgZGFkZHIsIHNyY19hZGRyLAogCQkgICAgICZpY21wNmgsIHNvbGljaXRl
ZF9hZGRyLAotCQkgICAgIGluY19vcHQgPyBORF9PUFRfVEFSR0VUX0xMX0FERFIgOiAwLAotCQkg
ICAgIElDTVA2X01JQl9PVVRORUlHSEJPUkFEVkVSVElTRU1FTlRTKTsKKwkJICAgICBpbmNfb3B0
ID8gTkRfT1BUX1RBUkdFVF9MTF9BRERSIDogMCk7CiB9CiAKIHZvaWQgbmRpc2Nfc2VuZF9ucyhz
dHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgbmVpZ2hib3VyICpuZWlnaCwKQEAgLTU2NCw4
ICs1NjUsNyBAQCB2b2lkIG5kaXNjX3NlbmRfbnMoc3RydWN0IG5ldF9kZXZpY2UgKmRlCiAKIAlf
X25kaXNjX3NlbmQoZGV2LCBuZWlnaCwgZGFkZHIsIHNhZGRyLAogCQkgICAgICZpY21wNmgsIHNv
bGljaXQsCi0JCSAgICAgIWlwdjZfYWRkcl9hbnkoc2FkZHIpID8gTkRfT1BUX1NPVVJDRV9MTF9B
RERSIDogMCwKLQkJICAgICBJQ01QNl9NSUJfT1VUTkVJR0hCT1JTT0xJQ0lUUyk7CisJCSAgICAg
IWlwdjZfYWRkcl9hbnkoc2FkZHIpID8gTkRfT1BUX1NPVVJDRV9MTF9BRERSIDogMCk7CiB9CiAK
IHZvaWQgbmRpc2Nfc2VuZF9ycyhzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgaW42X2Fk
ZHIgKnNhZGRyLApAQCAtNTk5LDggKzU5OSw3IEBAIHZvaWQgbmRpc2Nfc2VuZF9ycyhzdHJ1Y3Qg
bmV0X2RldmljZSAqZGUKICNlbmRpZgogCV9fbmRpc2Nfc2VuZChkZXYsIE5VTEwsIGRhZGRyLCBz
YWRkciwKIAkJICAgICAmaWNtcDZoLCBOVUxMLAotCQkgICAgIHNlbmRfc2xsYW8gPyBORF9PUFRf
U09VUkNFX0xMX0FERFIgOiAwLAotCQkgICAgIElDTVA2X01JQl9PVVRST1VURVJTT0xJQ0lUUyk7
CisJCSAgICAgc2VuZF9zbGxhbyA/IE5EX09QVF9TT1VSQ0VfTExfQUREUiA6IDApOwogfQogCiAK
QEAgLTE0NTQsNyArMTQ1Myw3IEBAIHZvaWQgbmRpc2Nfc2VuZF9yZWRpcmVjdChzdHJ1Y3Qgc2tf
YnVmZiAKIAlJUDZfSU5DX1NUQVRTKGlkZXYsIElQU1RBVFNfTUlCX09VVFJFUVVFU1RTKTsKIAll
cnIgPSBORl9IT09LKFBGX0lORVQ2LCBORl9JUDZfTE9DQUxfT1VULCBidWZmLCBOVUxMLCBkc3Qt
PmRldiwgZHN0X291dHB1dCk7CiAJaWYgKCFlcnIpIHsKLQkJSUNNUDZfSU5DX1NUQVRTKGlkZXYs
IElDTVA2X01JQl9PVVRSRURJUkVDVFMpOworCQlJQ01QNk1TR09VVF9JTkNfU1RBVFMoaWRldiwg
TkRJU0NfUkVESVJFQ1QpOwogCQlJQ01QNl9JTkNfU1RBVFMoaWRldiwgSUNNUDZfTUlCX09VVE1T
R1MpOwogCX0KIApkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L25ldC9pcHY2L3Byb2MuYyBsaW51
eC0yLjYuMjIuNV9JQ01QdjZNU0cyL25ldC9pcHY2L3Byb2MuYwotLS0gbGludXgtMi42LjIyLjUv
bmV0L2lwdjYvcHJvYy5jCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0wNzAwCisrKyBs
aW51eC0yLjYuMjIuNV9JQ01QdjZNU0cyL25ldC9pcHY2L3Byb2MuYwkyMDA3LTA5LTE0IDEzOjQx
OjIzLjAwMDAwMDAwMCAtMDcwMApAQCAtODUsNDcgKzg1LDMzIEBAIHN0YXRpYyBzdHJ1Y3Qgc25t
cF9taWIgc25tcDZfaXBzdGF0c19saXMKIH07CiAKIHN0YXRpYyBzdHJ1Y3Qgc25tcF9taWIgc25t
cDZfaWNtcDZfbGlzdFtdID0gewotLyogaWNtcHY2IG1pYiBhY2NvcmRpbmcgdG8gUkZDIDI0NjYK
LQotICAgRXhjZXB0aW9uczogIHtJbnxPdXR9QWRtaW5Qcm9oaWJzIGFyZSByZW1vdmVkLCBiZWNh
dXNlIEkgc2VlCi0JCW5vIGdvb2QgcmVhc29ucyB0byBhY2NvdW50IHRoZW0gc2VwYXJhdGVseQot
CQlvZiBhbm90aGVyIGRlc3QudW5yZWFjaHMuCi0JCU91dEVycnMgaXMgemVybyBpZGVudGljYWxs
eS4KLQkJT3V0RWNob3MgdG9vLgotCQlPdXRSb3V0ZXJBZHZlcnRpc2VtZW50cyB0b28uCi0JCU91
dEdyb3VwTWVtYlF1ZXJpZXMgdG9vLgotICovCisvKiBpY21wdjYgbWliIGFjY29yZGluZyB0byBS
RkMgMjQ2NiAqLwogCVNOTVBfTUlCX0lURU0oIkljbXA2SW5Nc2dzIiwgSUNNUDZfTUlCX0lOTVNH
UyksCiAJU05NUF9NSUJfSVRFTSgiSWNtcDZJbkVycm9ycyIsIElDTVA2X01JQl9JTkVSUk9SUyks
Ci0JU05NUF9NSUJfSVRFTSgiSWNtcDZJbkRlc3RVbnJlYWNocyIsIElDTVA2X01JQl9JTkRFU1RV
TlJFQUNIUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZJblBrdFRvb0JpZ3MiLCBJQ01QNl9NSUJf
SU5QS1RUT09CSUdTKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNkluVGltZUV4Y2RzIiwgSUNNUDZf
TUlCX0lOVElNRUVYQ0RTKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNkluUGFybVByb2JsZW1zIiwg
SUNNUDZfTUlCX0lOUEFSTVBST0JMRU1TKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNkluRWNob3Mi
LCBJQ01QNl9NSUJfSU5FQ0hPUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZJbkVjaG9SZXBsaWVz
IiwgSUNNUDZfTUlCX0lORUNIT1JFUExJRVMpLAotCVNOTVBfTUlCX0lURU0oIkljbXA2SW5Hcm91
cE1lbWJRdWVyaWVzIiwgSUNNUDZfTUlCX0lOR1JPVVBNRU1CUVVFUklFUyksCi0JU05NUF9NSUJf
SVRFTSgiSWNtcDZJbkdyb3VwTWVtYlJlc3BvbnNlcyIsIElDTVA2X01JQl9JTkdST1VQTUVNQlJF
U1BPTlNFUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZJbkdyb3VwTWVtYlJlZHVjdGlvbnMiLCBJ
Q01QNl9NSUJfSU5HUk9VUE1FTUJSRURVQ1RJT05TKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNklu
Um91dGVyU29saWNpdHMiLCBJQ01QNl9NSUJfSU5ST1VURVJTT0xJQ0lUUyksCi0JU05NUF9NSUJf
SVRFTSgiSWNtcDZJblJvdXRlckFkdmVydGlzZW1lbnRzIiwgSUNNUDZfTUlCX0lOUk9VVEVSQURW
RVJUSVNFTUVOVFMpLAotCVNOTVBfTUlCX0lURU0oIkljbXA2SW5OZWlnaGJvclNvbGljaXRzIiwg
SUNNUDZfTUlCX0lOTkVJR0hCT1JTT0xJQ0lUUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZJbk5l
aWdoYm9yQWR2ZXJ0aXNlbWVudHMiLCBJQ01QNl9NSUJfSU5ORUlHSEJPUkFEVkVSVElTRU1FTlRT
KSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNkluUmVkaXJlY3RzIiwgSUNNUDZfTUlCX0lOUkVESVJF
Q1RTKSwKIAlTTk1QX01JQl9JVEVNKCJJY21wNk91dE1zZ3MiLCBJQ01QNl9NSUJfT1VUTVNHUyks
Ci0JU05NUF9NSUJfSVRFTSgiSWNtcDZPdXREZXN0VW5yZWFjaHMiLCBJQ01QNl9NSUJfT1VUREVT
VFVOUkVBQ0hTKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNk91dFBrdFRvb0JpZ3MiLCBJQ01QNl9N
SUJfT1VUUEtUVE9PQklHUyksCi0JU05NUF9NSUJfSVRFTSgiSWNtcDZPdXRUaW1lRXhjZHMiLCBJ
Q01QNl9NSUJfT1VUVElNRUVYQ0RTKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNk91dFBhcm1Qcm9i
bGVtcyIsIElDTVA2X01JQl9PVVRQQVJNUFJPQkxFTVMpLAotCVNOTVBfTUlCX0lURU0oIkljbXA2
T3V0RWNob1JlcGxpZXMiLCBJQ01QNl9NSUJfT1VURUNIT1JFUExJRVMpLAotCVNOTVBfTUlCX0lU
RU0oIkljbXA2T3V0Um91dGVyU29saWNpdHMiLCBJQ01QNl9NSUJfT1VUUk9VVEVSU09MSUNJVFMp
LAotCVNOTVBfTUlCX0lURU0oIkljbXA2T3V0TmVpZ2hib3JTb2xpY2l0cyIsIElDTVA2X01JQl9P
VVRORUlHSEJPUlNPTElDSVRTKSwKLQlTTk1QX01JQl9JVEVNKCJJY21wNk91dE5laWdoYm9yQWR2
ZXJ0aXNlbWVudHMiLCBJQ01QNl9NSUJfT1VUTkVJR0hCT1JBRFZFUlRJU0VNRU5UUyksCi0JU05N
UF9NSUJfSVRFTSgiSWNtcDZPdXRSZWRpcmVjdHMiLCBJQ01QNl9NSUJfT1VUUkVESVJFQ1RTKSwK
LQlTTk1QX01JQl9JVEVNKCJJY21wNk91dEdyb3VwTWVtYlJlc3BvbnNlcyIsIElDTVA2X01JQl9P
VVRHUk9VUE1FTUJSRVNQT05TRVMpLAotCVNOTVBfTUlCX0lURU0oIkljbXA2T3V0R3JvdXBNZW1i
UmVkdWN0aW9ucyIsIElDTVA2X01JQl9PVVRHUk9VUE1FTUJSRURVQ1RJT05TKSwKIAlTTk1QX01J
Ql9TRU5USU5FTAogfTsKIAorLyogUkZDIDQyOTMgdjYgSUNNUE1zZ1N0YXRzVGFibGU7IG5hbWVk
IGl0ZW1zIGZvciBSRkMgMjQ2NiBjb21wYXRpYmlsaXR5ICovCitzdGF0aWMgY2hhciAqaWNtcDZ0
eXBlMm5hbWVbMjU2XSA9IHsKKwlbSUNNUFY2X0RFU1RfVU5SRUFDSF0gPSAiRGVzdFVucmVhY2hz
IiwKKwlbSUNNUFY2X1BLVF9UT09CSUddID0gIlBrdFRvb0JpZ3MiLAorCVtJQ01QVjZfVElNRV9F
WENFRURdID0gIlRpbWVFeGNkcyIsCisJW0lDTVBWNl9QQVJBTVBST0JdID0gIlBhcm1Qcm9ibGVt
cyIsCisJW0lDTVBWNl9FQ0hPX1JFUVVFU1RdID0gIkVjaG9SZXF1ZXN0IiwKKwlbSUNNUFY2X0VD
SE9fUkVQTFldID0gIkVjaG9SZXBsaWVzIiwKKwlbSUNNUFY2X01HTV9RVUVSWV0gPSAiR3JvdXBN
ZW1iUXVlcmllcyIsCisJW0lDTVBWNl9NR01fUkVQT1JUXSA9ICJHcm91cE1lbWJSZXNwb25zZXMi
LAorCVtJQ01QVjZfTUdNX1JFRFVDVElPTl0gPSAiR3JvdXBNZW1iUmVkdWN0aW9ucyIsCisJW0lD
TVBWNl9NTEQyX1JFUE9SVF0gPSAiTUxEdjJSZXBvcnRzIiwKKwlbTkRJU0NfUk9VVEVSX0FEVkVS
VElTRU1FTlRdID0gIlJvdXRlckFkdmVydGlzZW1lbnRzIiwKKwlbTkRJU0NfUk9VVEVSX1NPTElD
SVRBVElPTl0gPSAiUm91dGVyU29saWNpdHMiLAorCVtORElTQ19ORUlHSEJPVVJfQURWRVJUSVNF
TUVOVF0gPSAiTmVpZ2hib3JBZHZlcnRpc2VtZW50cyIsCisJW05ESVNDX05FSUdIQk9VUl9TT0xJ
Q0lUQVRJT05dID0gIk5laWdoYm9yU29saWNpdHMiLAorCVtORElTQ19SRURJUkVDVF0gPSAiTmVp
Z2hib3JSZWRpcmVjdHMiLAorfTsKKworCiBzdGF0aWMgc3RydWN0IHNubXBfbWliIHNubXA2X3Vk
cDZfbGlzdFtdID0gewogCVNOTVBfTUlCX0lURU0oIlVkcDZJbkRhdGFncmFtcyIsIFVEUF9NSUJf
SU5EQVRBR1JBTVMpLAogCVNOTVBfTUlCX0lURU0oIlVkcDZOb1BvcnRzIiwgVURQX01JQl9OT1BP
UlRTKSwKQEAgLTE0Miw2ICsxMjgsNDAgQEAgc3RhdGljIHN0cnVjdCBzbm1wX21pYiBzbm1wNl91
ZHBsaXRlNl9saQogCVNOTVBfTUlCX1NFTlRJTkVMCiB9OwogCitzdGF0aWMgdm9pZCBzbm1wNl9z
ZXFfc2hvd19pY21wdjZtc2coc3RydWN0IHNlcV9maWxlICpzZXEsIHZvaWQgKiptaWIpCit7CisJ
c3RhdGljIGNoYXIgbmFtZVszMl07CisJaW50IGk7CisKKwkvKiBwcmludCBieSBuYW1lIC0tIGRl
cHJlY2F0ZWQgaXRlbXMgKi8KKwlmb3IgKGkgPSAwOyBpIDwgSUNNUDZNU0dfTUlCX01BWDsgaSsr
KSB7CisJCWludCBpY21wdHlwZTsKKwkJY2hhciAqcDsKKworCQlpY21wdHlwZSA9IGkgJiAweGZm
OworCQlwID0gaWNtcDZ0eXBlMm5hbWVbaWNtcHR5cGVdOworCQlpZiAoIXApCS8qIGRvbid0IHBy
aW50IHVuLW5hbWVkIHR5cGVzIGhlcmUgKi8KKwkJCWNvbnRpbnVlOworCQkodm9pZCkgc25wcmlu
dGYobmFtZSwgc2l6ZW9mKG5hbWUpLTEsICJJY21wNiVzJXMiLAorCQkJaSAmIDB4MTAwID8gIk91
dCIgOiAiSW4iLCBwKTsKKwkJc2VxX3ByaW50ZihzZXEsICIlLTMyc1x0JWx1XG4iLCBuYW1lLAor
CQkJc25tcF9mb2xkX2ZpZWxkKG1pYiwgaSkpOworCX0KKworCS8qIHByaW50IGJ5IG51bWJlciAo
bm9uemVybyBvbmx5KSAtIElDTVBNc2dTdGF0IGZvcm1hdCAqLworCWZvciAoaSA9IDA7IGkgPCBJ
Q01QNk1TR19NSUJfTUFYOyBpKyspIHsKKwkJdW5zaWduZWQgbG9uZyB2YWw7CisKKwkJdmFsID0g
c25tcF9mb2xkX2ZpZWxkKG1pYiwgaSk7CisJCWlmICghdmFsKQorCQkJY29udGludWU7CisJCSh2
b2lkKSBzbnByaW50ZihuYW1lLCBzaXplb2YobmFtZSktMSwgIkljbXA2JXNUeXBlJXUiLAorCQkJ
aSAmIDB4MTAwID8gICJPdXQiIDogIkluIiwgaSAmIDB4ZmYpOworCQlzZXFfcHJpbnRmKHNlcSwg
IiUtMzJzXHQlbHVcbiIsIG5hbWUsIHZhbCk7CisJfQorCXJldHVybjsKK30KKwogc3RhdGljIGlu
bGluZSB2b2lkCiBzbm1wNl9zZXFfc2hvd19pdGVtKHN0cnVjdCBzZXFfZmlsZSAqc2VxLCB2b2lk
ICoqbWliLCBzdHJ1Y3Qgc25tcF9taWIgKml0ZW1saXN0KQogewpAQCAtMTU5LDkgKzE3OSwxMSBA
QCBzdGF0aWMgaW50IHNubXA2X3NlcV9zaG93KHN0cnVjdCBzZXFfZmlsCiAJCXNlcV9wcmludGYo
c2VxLCAiJS0zMnNcdCV1XG4iLCAiaWZJbmRleCIsIGlkZXYtPmRldi0+aWZpbmRleCk7CiAJCXNu
bXA2X3NlcV9zaG93X2l0ZW0oc2VxLCAodm9pZCAqKilpZGV2LT5zdGF0cy5pcHY2LCBzbm1wNl9p
cHN0YXRzX2xpc3QpOwogCQlzbm1wNl9zZXFfc2hvd19pdGVtKHNlcSwgKHZvaWQgKiopaWRldi0+
c3RhdHMuaWNtcHY2LCBzbm1wNl9pY21wNl9saXN0KTsKKwkJc25tcDZfc2VxX3Nob3dfaWNtcHY2
bXNnKHNlcSwgKHZvaWQgKiopaWRldi0+c3RhdHMuaWNtcHY2bXNnKTsKIAl9IGVsc2UgewogCQlz
bm1wNl9zZXFfc2hvd19pdGVtKHNlcSwgKHZvaWQgKiopaXB2Nl9zdGF0aXN0aWNzLCBzbm1wNl9p
cHN0YXRzX2xpc3QpOwogCQlzbm1wNl9zZXFfc2hvd19pdGVtKHNlcSwgKHZvaWQgKiopaWNtcHY2
X3N0YXRpc3RpY3MsIHNubXA2X2ljbXA2X2xpc3QpOworCQlzbm1wNl9zZXFfc2hvd19pY21wdjZt
c2coc2VxLCAodm9pZCAqKilpY21wdjZtc2dfc3RhdGlzdGljcyk7CiAJCXNubXA2X3NlcV9zaG93
X2l0ZW0oc2VxLCAodm9pZCAqKil1ZHBfc3RhdHNfaW42LCBzbm1wNl91ZHA2X2xpc3QpOwogCQlz
bm1wNl9zZXFfc2hvd19pdGVtKHNlcSwgKHZvaWQgKiopdWRwbGl0ZV9zdGF0c19pbjYsIHNubXA2
X3VkcGxpdGU2X2xpc3QpOwogCX0K

--=_mixed 00759E0C88257356_=--
