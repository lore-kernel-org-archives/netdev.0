From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH][1/2] Add ICMPMsgStats MIB (RFC 4293)
Date: Mon, 10 Sep 2007 20:25:01 -0600
Message-ID: <OF518737FC.14030306-ON8825731E.0083949F-88257353.000D3327@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 000D332088257353_="
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:46501 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760701AbXIKCZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 22:25:04 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l8B1HQwr027470
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 21:17:26 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8B2P3W9154418
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 20:25:03 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8B2P3eg021157
	for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 20:25:03 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=_mixed 000D332088257353_=
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

IPv4 patch attached, IPv6 patch to follow.

                                        +-DLS

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp linux-2.6.22.5/include/linux/snmp.h 
linux-2.6.22.5_ICMPMSG/include/linux/snmp.h
--- linux-2.6.22.5/include/linux/snmp.h 2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPMSG/include/linux/snmp.h 2007-08-23 
15:32:29.000000000 -0700
@@ -82,6 +82,8 @@ enum
        __ICMP_MIB_MAX
 };
 
+#define __ICMPMSG_MIB_MAX 512  /* Out+In for all 8-bit ICMP types */
+
 /* icmp6 mib definitions */
 /*
  * RFC 2466:  ICMPv6-MIB
diff -ruNp linux-2.6.22.5/include/net/icmp.h 
linux-2.6.22.5_ICMPMSG/include/net/icmp.h
--- linux-2.6.22.5/include/net/icmp.h   2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPMSG/include/net/icmp.h   2007-08-23 
15:56:45.000000000 -0700
@@ -30,9 +30,16 @@ struct icmp_err {
 
 extern struct icmp_err icmp_err_convert[];
 DECLARE_SNMP_STAT(struct icmp_mib, icmp_statistics);
+DECLARE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics);
 #define ICMP_INC_STATS(field)          SNMP_INC_STATS(icmp_statistics, 
field)
 #define ICMP_INC_STATS_BH(field)       SNMP_INC_STATS_BH(icmp_statistics, 
field)
 #define ICMP_INC_STATS_USER(field) SNMP_INC_STATS_USER(icmp_statistics, 
field)
+#define ICMPMSGOUT_INC_STATS(field)    SNMP_INC_STATS(icmpmsg_statistics, 
field+256)
+#define ICMPMSGOUT_INC_STATS_BH(field) 
SNMP_INC_STATS_BH(icmpmsg_statistics, field+256)
+#define ICMPMSGOUT_INC_STATS_USER(field) 
SNMP_INC_STATS_USER(icmpmsg_statistics, field+256)
+#define ICMPMSGIN_INC_STATS(field)     SNMP_INC_STATS(icmpmsg_statistics, 
field)
+#define ICMPMSGIN_INC_STATS_BH(field) 
SNMP_INC_STATS_BH(icmpmsg_statistics, field)
+#define ICMPMSGIN_INC_STATS_USER(field) 
SNMP_INC_STATS_USER(icmpmsg_statistics, field)
 
 struct dst_entry;
 struct net_proto_family;
@@ -42,6 +49,7 @@ extern void   icmp_send(struct sk_buff *sk
 extern int     icmp_rcv(struct sk_buff *skb);
 extern int     icmp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern void    icmp_init(struct net_proto_family *ops);
+extern void    icmp_out_count(unsigned char type);
 
 /* Move into dst.h ? */
 extern int     xrlim_allow(struct dst_entry *dst, int timeout);
diff -ruNp linux-2.6.22.5/include/net/snmp.h 
linux-2.6.22.5_ICMPMSG/include/net/snmp.h
--- linux-2.6.22.5/include/net/snmp.h   2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPMSG/include/net/snmp.h   2007-08-23 
14:42:50.000000000 -0700
@@ -82,6 +82,11 @@ struct icmp_mib {
        unsigned long   mibs[ICMP_MIB_MAX];
 } __SNMP_MIB_ALIGN__;
 
+#define ICMPMSG_MIB_MAX        __ICMPMSG_MIB_MAX
+struct icmpmsg_mib {
+       unsigned long   mibs[ICMPMSG_MIB_MAX];
+} __SNMP_MIB_ALIGN__;
+
 /* ICMP6 (IPv6-ICMP) */
 #define ICMP6_MIB_MAX  __ICMP6_MIB_MAX
 struct icmpv6_mib {
diff -ruNp linux-2.6.22.5/net/ipv4/af_inet.c 
linux-2.6.22.5_ICMPMSG/net/ipv4/af_inet.c
--- linux-2.6.22.5/net/ipv4/af_inet.c   2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPMSG/net/ipv4/af_inet.c   2007-08-23 
14:47:26.000000000 -0700
@@ -1296,6 +1296,10 @@ static int __init init_ipv4_mibs(void)
                          sizeof(struct icmp_mib),
                          __alignof__(struct icmp_mib)) < 0)
                goto err_icmp_mib;
+       if (snmp_mib_init((void **)icmpmsg_statistics,
+                         sizeof(struct icmpmsg_mib),
+                         __alignof__(struct icmpmsg_mib)) < 0)
+               goto err_icmpmsg_mib;
        if (snmp_mib_init((void **)tcp_statistics,
                          sizeof(struct tcp_mib),
                          __alignof__(struct tcp_mib)) < 0)
@@ -1318,6 +1322,8 @@ err_udplite_mib:
 err_udp_mib:
        snmp_mib_free((void **)tcp_statistics);
 err_tcp_mib:
+       snmp_mib_free((void **)icmpmsg_statistics);
+err_icmpmsg_mib:
        snmp_mib_free((void **)icmp_statistics);
 err_icmp_mib:
        snmp_mib_free((void **)ip_statistics);
diff -ruNp linux-2.6.22.5/net/ipv4/icmp.c 
linux-2.6.22.5_ICMPMSG/net/ipv4/icmp.c
--- linux-2.6.22.5/net/ipv4/icmp.c      2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPMSG/net/ipv4/icmp.c      2007-08-23 
15:57:07.000000000 -0700
@@ -115,6 +115,7 @@ struct icmp_bxm {
  *     Statistics
  */
 DEFINE_SNMP_STAT(struct icmp_mib, icmp_statistics) __read_mostly;
+DEFINE_SNMP_STAT(struct icmpmsg_mib, icmpmsg_statistics) __read_mostly;
 
 /* An array of errno for error messages from dest unreach. */
 /* RFC 1122: 3.2.2.1 States that NET_UNREACH, HOST_UNREACH and SR_FAILED 
MUST be considered 'transient errs'. */
@@ -214,8 +215,6 @@ int sysctl_icmp_errors_use_inbound_ifadd
  */
 
 struct icmp_control {
-       int output_entry;       /* Field for increment on output */
-       int input_entry;        /* Field for increment on input */
        void (*handler)(struct sk_buff *skb);
        short   error;          /* This ICMP is classed as an error 
message */
 };
@@ -316,12 +315,10 @@ out:
 /*
  *     Maintain the counters used in the SNMP statistics for outgoing 
ICMP
  */
-static void icmp_out_count(int type)
+void icmp_out_count(unsigned char type)
 {
-       if (type <= NR_ICMP_TYPES) {
-               ICMP_INC_STATS(icmp_pointers[type].output_entry);
-               ICMP_INC_STATS(ICMP_MIB_OUTMSGS);
-       }
+       ICMPMSGOUT_INC_STATS(type);
+       ICMP_INC_STATS(ICMP_MIB_OUTMSGS);
 }
 
 /*
@@ -390,7 +387,6 @@ static void icmp_reply(struct icmp_bxm *
                return;
 
        icmp_param->data.icmph.checksum = 0;
-       icmp_out_count(icmp_param->data.icmph.type);
 
        inet->tos = ip_hdr(skb)->tos;
        daddr = ipc.addr = rt->rt_src;
@@ -952,6 +948,7 @@ int icmp_rcv(struct sk_buff *skb)
 
        icmph = icmp_hdr(skb);
 
+       ICMPMSGIN_INC_STATS_BH(icmph->type);
        /*
         *      18 is the highest 'known' ICMP type. Anything else is a 
mystery
         *
@@ -986,7 +983,6 @@ int icmp_rcv(struct sk_buff *skb)
                }
        }
 
-       ICMP_INC_STATS_BH(icmp_pointers[icmph->type].input_entry);
        icmp_pointers[icmph->type].handler(skb);
 
 drop:
@@ -1002,109 +998,71 @@ error:
  */
 static const struct icmp_control icmp_pointers[NR_ICMP_TYPES + 1] = {
        [ICMP_ECHOREPLY] = {
-               .output_entry = ICMP_MIB_OUTECHOREPS,
-               .input_entry = ICMP_MIB_INECHOREPS,
                .handler = icmp_discard,
        },
        [1] = {
-               .output_entry = ICMP_MIB_DUMMY,
-               .input_entry = ICMP_MIB_INERRORS,
                .handler = icmp_discard,
                .error = 1,
        },
        [2] = {
-               .output_entry = ICMP_MIB_DUMMY,
-               .input_entry = ICMP_MIB_INERRORS,
                .handler = icmp_discard,
                .error = 1,
        },
        [ICMP_DEST_UNREACH] = {
-               .output_entry = ICMP_MIB_OUTDESTUNREACHS,
-               .input_entry = ICMP_MIB_INDESTUNREACHS,
                .handler = icmp_unreach,
                .error = 1,
        },
        [ICMP_SOURCE_QUENCH] = {
-               .output_entry = ICMP_MIB_OUTSRCQUENCHS,
-               .input_entry = ICMP_MIB_INSRCQUENCHS,
                .handler = icmp_unreach,
                .error = 1,
        },
        [ICMP_REDIRECT] = {
-               .output_entry = ICMP_MIB_OUTREDIRECTS,
-               .input_entry = ICMP_MIB_INREDIRECTS,
                .handler = icmp_redirect,
                .error = 1,
        },
        [6] = {
-               .output_entry = ICMP_MIB_DUMMY,
-               .input_entry = ICMP_MIB_INERRORS,
                .handler = icmp_discard,
                .error = 1,
        },
        [7] = {
-               .output_entry = ICMP_MIB_DUMMY,
-               .input_entry = ICMP_MIB_INERRORS,
                .handler = icmp_discard,
                .error = 1,
        },
        [ICMP_ECHO] = {
-               .output_entry = ICMP_MIB_OUTECHOS,
-               .input_entry = ICMP_MIB_INECHOS,
                .handler = icmp_echo,
        },
        [9] = {
-               .output_entry = ICMP_MIB_DUMMY,
-               .input_entry = ICMP_MIB_INERRORS,
                .handler = icmp_discard,
                .error = 1,
        },
        [10] = {
-               .output_entry = ICMP_MIB_DUMMY,
-               .input_entry = ICMP_MIB_INERRORS,
                .handler = icmp_discard,
                .error = 1,
        },
        [ICMP_TIME_EXCEEDED] = {
-               .output_entry = ICMP_MIB_OUTTIMEEXCDS,
-               .input_entry = ICMP_MIB_INTIMEEXCDS,
                .handler = icmp_unreach,
                .error = 1,
        },
        [ICMP_PARAMETERPROB] = {
-               .output_entry = ICMP_MIB_OUTPARMPROBS,
-               .input_entry = ICMP_MIB_INPARMPROBS,
                .handler = icmp_unreach,
                .error = 1,
        },
        [ICMP_TIMESTAMP] = {
-               .output_entry = ICMP_MIB_OUTTIMESTAMPS,
-               .input_entry = ICMP_MIB_INTIMESTAMPS,
                .handler = icmp_timestamp,
        },
        [ICMP_TIMESTAMPREPLY] = {
-               .output_entry = ICMP_MIB_OUTTIMESTAMPREPS,
-               .input_entry = ICMP_MIB_INTIMESTAMPREPS,
                .handler = icmp_discard,
        },
        [ICMP_INFO_REQUEST] = {
-               .output_entry = ICMP_MIB_DUMMY,
-               .input_entry = ICMP_MIB_DUMMY,
                .handler = icmp_discard,
        },
        [ICMP_INFO_REPLY] = {
-               .output_entry = ICMP_MIB_DUMMY,
-               .input_entry = ICMP_MIB_DUMMY,
                .handler = icmp_discard,
        },
        [ICMP_ADDRESS] = {
-               .output_entry = ICMP_MIB_OUTADDRMASKS,
-               .input_entry = ICMP_MIB_INADDRMASKS,
                .handler = icmp_address,
        },
        [ICMP_ADDRESSREPLY] = {
-               .output_entry = ICMP_MIB_OUTADDRMASKREPS,
-               .input_entry = ICMP_MIB_INADDRMASKREPS,
                .handler = icmp_address_reply,
        },
 };
@@ -1146,4 +1104,5 @@ void __init icmp_init(struct net_proto_f
 EXPORT_SYMBOL(icmp_err_convert);
 EXPORT_SYMBOL(icmp_send);
 EXPORT_SYMBOL(icmp_statistics);
+EXPORT_SYMBOL(icmpmsg_statistics);
 EXPORT_SYMBOL(xrlim_allow);
diff -ruNp linux-2.6.22.5/net/ipv4/ip_output.c 
linux-2.6.22.5_ICMPMSG/net/ipv4/ip_output.c
--- linux-2.6.22.5/net/ipv4/ip_output.c 2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPMSG/net/ipv4/ip_output.c 2007-08-23 
15:54:45.000000000 -0700
@@ -1258,6 +1258,10 @@ int ip_push_pending_frames(struct sock *
        skb->priority = sk->sk_priority;
        skb->dst = dst_clone(&rt->u.dst);
 
+       if (iph->protocol == IPPROTO_ICMP)
+               icmp_out_count(((struct icmphdr *)
+                       skb_transport_header(skb))->type);
+
        /* Netfilter gets whole the not fragmented skb. */
        err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
                      skb->dst->dev, dst_output);
diff -ruNp linux-2.6.22.5/net/ipv4/proc.c 
linux-2.6.22.5_ICMPMSG/net/ipv4/proc.c
--- linux-2.6.22.5/net/ipv4/proc.c      2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPMSG/net/ipv4/proc.c      2007-08-23 
15:58:42.000000000 -0700
@@ -123,33 +123,30 @@ static const struct snmp_mib snmp4_ipext
 static const struct snmp_mib snmp4_icmp_list[] = {
        SNMP_MIB_ITEM("InMsgs", ICMP_MIB_INMSGS),
        SNMP_MIB_ITEM("InErrors", ICMP_MIB_INERRORS),
-       SNMP_MIB_ITEM("InDestUnreachs", ICMP_MIB_INDESTUNREACHS),
-       SNMP_MIB_ITEM("InTimeExcds", ICMP_MIB_INTIMEEXCDS),
-       SNMP_MIB_ITEM("InParmProbs", ICMP_MIB_INPARMPROBS),
-       SNMP_MIB_ITEM("InSrcQuenchs", ICMP_MIB_INSRCQUENCHS),
-       SNMP_MIB_ITEM("InRedirects", ICMP_MIB_INREDIRECTS),
-       SNMP_MIB_ITEM("InEchos", ICMP_MIB_INECHOS),
-       SNMP_MIB_ITEM("InEchoReps", ICMP_MIB_INECHOREPS),
-       SNMP_MIB_ITEM("InTimestamps", ICMP_MIB_INTIMESTAMPS),
-       SNMP_MIB_ITEM("InTimestampReps", ICMP_MIB_INTIMESTAMPREPS),
-       SNMP_MIB_ITEM("InAddrMasks", ICMP_MIB_INADDRMASKS),
-       SNMP_MIB_ITEM("InAddrMaskReps", ICMP_MIB_INADDRMASKREPS),
        SNMP_MIB_ITEM("OutMsgs", ICMP_MIB_OUTMSGS),
        SNMP_MIB_ITEM("OutErrors", ICMP_MIB_OUTERRORS),
-       SNMP_MIB_ITEM("OutDestUnreachs", ICMP_MIB_OUTDESTUNREACHS),
-       SNMP_MIB_ITEM("OutTimeExcds", ICMP_MIB_OUTTIMEEXCDS),
-       SNMP_MIB_ITEM("OutParmProbs", ICMP_MIB_OUTPARMPROBS),
-       SNMP_MIB_ITEM("OutSrcQuenchs", ICMP_MIB_OUTSRCQUENCHS),
-       SNMP_MIB_ITEM("OutRedirects", ICMP_MIB_OUTREDIRECTS),
-       SNMP_MIB_ITEM("OutEchos", ICMP_MIB_OUTECHOS),
-       SNMP_MIB_ITEM("OutEchoReps", ICMP_MIB_OUTECHOREPS),
-       SNMP_MIB_ITEM("OutTimestamps", ICMP_MIB_OUTTIMESTAMPS),
-       SNMP_MIB_ITEM("OutTimestampReps", ICMP_MIB_OUTTIMESTAMPREPS),
-       SNMP_MIB_ITEM("OutAddrMasks", ICMP_MIB_OUTADDRMASKS),
-       SNMP_MIB_ITEM("OutAddrMaskReps", ICMP_MIB_OUTADDRMASKREPS),
        SNMP_MIB_SENTINEL
 };
 
+static struct {
+       char *name;
+       int index;
+} icmpmibmap[] = {
+       { "DestUnreachs", ICMP_DEST_UNREACH },
+       { "TimeExcds", ICMP_TIME_EXCEEDED },
+       { "ParmProbs", ICMP_PARAMETERPROB },
+       { "SrcQuenchs", ICMP_SOURCE_QUENCH },
+       { "Redirects", ICMP_REDIRECT },
+       { "Echos", ICMP_ECHO },
+       { "EchoReps", ICMP_ECHOREPLY },
+       { "Timestamps", ICMP_TIMESTAMP },
+       { "TimestampReps", ICMP_TIMESTAMPREPLY },
+       { "AddrMasks", ICMP_ADDRESS },
+       { "AddrMaskReps", ICMP_ADDRESSREPLY },
+       { 0, 0 }
+};
+
+
 static const struct snmp_mib snmp4_tcp_list[] = {
        SNMP_MIB_ITEM("RtoAlgorithm", TCP_MIB_RTOALGORITHM),
        SNMP_MIB_ITEM("RtoMin", TCP_MIB_RTOMIN),
@@ -247,6 +244,72 @@ static const struct snmp_mib snmp4_net_l
        SNMP_MIB_SENTINEL
 };
 
+static void icmpmsg_put(struct seq_file *seq)
+{
+#define PERLINE        16
+
+       int j, i, count;
+       static int out[PERLINE];
+
+       count = 0;
+       for (i = 0; i < ICMPMSG_MIB_MAX; i++) {
+
+               if (snmp_fold_field((void **) icmpmsg_statistics, i))
+                       out[count++] = i;
+               if (count < PERLINE)
+                       continue;
+
+               seq_printf(seq, "\nIcmpMsg:");
+               for (j = 0; j < PERLINE; ++j)
+                       seq_printf(seq, " %sType%u", i & 0x100 ? "Out" : 
"In",
+                                       i & 0xff);
+               seq_printf(seq, "\nIcmpMsg: ");
+               for (j = 0; j < PERLINE; ++j)
+                       seq_printf(seq, " %lu",
+                               snmp_fold_field((void **) 
icmpmsg_statistics,
+                               out[j]));
+               seq_putc(seq, '\n');
+       }
+       if (count) {
+               seq_printf(seq, "\nIcmpMsg:");
+               for (j = 0; j < count; ++j)
+                       seq_printf(seq, " %sType%u", out[j] & 0x100 ? 
"Out" :
+                               "In", out[j] & 0xff);
+               seq_printf(seq, "\nIcmpMsg:");
+               for (j = 0; j < count; ++j)
+                       seq_printf(seq, " %lu", snmp_fold_field((void **)
+                               icmpmsg_statistics, out[j]));
+       }
+
+#undef PERLINE
+}
+
+static void icmp_put(struct seq_file *seq)
+{
+       int i;
+
+       seq_puts(seq, "\nIcmp: InMsgs InErrors");
+       for (i=0; icmpmibmap[i].name != NULL; i++)
+               seq_printf(seq, " In%s", icmpmibmap[i].name);
+       seq_printf(seq, " OutMsgs OutErrors");
+       for (i=0; icmpmibmap[i].name != NULL; i++)
+               seq_printf(seq, " Out%s", icmpmibmap[i].name);
+       seq_printf(seq, "\nIcmp: %lu %lu",
+               snmp_fold_field((void **) icmp_statistics, 
ICMP_MIB_INMSGS),
+               snmp_fold_field((void **) icmp_statistics, 
ICMP_MIB_INERRORS));
+       for (i=0; icmpmibmap[i].name != NULL; i++)
+               seq_printf(seq, " %lu",
+                       snmp_fold_field((void **) icmpmsg_statistics,
+                               icmpmibmap[i].index));
+       seq_printf(seq, " %lu %lu",
+               snmp_fold_field((void **) icmp_statistics, 
ICMP_MIB_OUTMSGS),
+               snmp_fold_field((void **) icmp_statistics, 
ICMP_MIB_OUTERRORS));
+       for (i=0; icmpmibmap[i].name != NULL; i++)
+               seq_printf(seq, " %lu",
+                       snmp_fold_field((void **) icmpmsg_statistics,
+                               icmpmibmap[i].index));
+}
+
 /*
  *     Called from the PROCfs module. This outputs /proc/net/snmp.
  */
@@ -267,15 +330,8 @@ static int snmp_seq_show(struct seq_file
                           snmp_fold_field((void **)ip_statistics,
                                           snmp4_ipstats_list[i].entry));
 
-       seq_puts(seq, "\nIcmp:");
-       for (i = 0; snmp4_icmp_list[i].name != NULL; i++)
-               seq_printf(seq, " %s", snmp4_icmp_list[i].name);
-
-       seq_puts(seq, "\nIcmp:");
-       for (i = 0; snmp4_icmp_list[i].name != NULL; i++)
-               seq_printf(seq, " %lu",
-                          snmp_fold_field((void **)icmp_statistics,
-                                          snmp4_icmp_list[i].entry));
+       icmp_put(seq);  /* RFC 2011 compatibility */
+       icmpmsg_put(seq);
 
        seq_puts(seq, "\nTcp:");
        for (i = 0; snmp4_tcp_list[i].name != NULL; i++)
@@ -332,6 +388,8 @@ static const struct file_operations snmp
        .release = single_release,
 };
 
+
+
 /*
  *     Output /proc/net/netstat
  */
diff -ruNp linux-2.6.22.5/net/ipv4/raw.c 
linux-2.6.22.5_ICMPMSG/net/ipv4/raw.c
--- linux-2.6.22.5/net/ipv4/raw.c       2007-08-22 16:23:54.000000000 
-0700
+++ linux-2.6.22.5_ICMPMSG/net/ipv4/raw.c       2007-08-23 
15:54:12.000000000 -0700
@@ -313,6 +313,9 @@ static int raw_send_hdrinc(struct sock *
 
                iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
        }
+       if (iph->protocol == IPPROTO_ICMP)
+               icmp_out_count(((struct icmphdr *)
+                       skb_transport_header(skb))->type);
 
        err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
                      dst_output);


--=_mixed 000D332088257353_=
Content-Type: application/octet-stream; name="icmpmsgmib4.patch"
Content-Disposition: attachment; filename="icmpmsgmib4.patch"
Content-Transfer-Encoding: base64

ZGlmZiAtcnVOcCBsaW51eC0yLjYuMjIuNS9pbmNsdWRlL2xpbnV4L3NubXAuaCBsaW51eC0yLjYu
MjIuNV9JQ01QTVNHL2luY2x1ZGUvbGludXgvc25tcC5oCi0tLSBsaW51eC0yLjYuMjIuNS9pbmNs
dWRlL2xpbnV4L3NubXAuaAkyMDA3LTA4LTIyIDE2OjIzOjU0LjAwMDAwMDAwMCAtMDcwMAorKysg
bGludXgtMi42LjIyLjVfSUNNUE1TRy9pbmNsdWRlL2xpbnV4L3NubXAuaAkyMDA3LTA4LTIzIDE1
OjMyOjI5LjAwMDAwMDAwMCAtMDcwMApAQCAtODIsNiArODIsOCBAQCBlbnVtCiAJX19JQ01QX01J
Ql9NQVgKIH07CiAKKyNkZWZpbmUgX19JQ01QTVNHX01JQl9NQVggNTEyCS8qIE91dCtJbiBmb3Ig
YWxsIDgtYml0IElDTVAgdHlwZXMgKi8KKwogLyogaWNtcDYgbWliIGRlZmluaXRpb25zICovCiAv
KgogICogUkZDIDI0NjY6ICBJQ01QdjYtTUlCCmRpZmYgLXJ1TnAgbGludXgtMi42LjIyLjUvaW5j
bHVkZS9uZXQvaWNtcC5oIGxpbnV4LTIuNi4yMi41X0lDTVBNU0cvaW5jbHVkZS9uZXQvaWNtcC5o
Ci0tLSBsaW51eC0yLjYuMjIuNS9pbmNsdWRlL25ldC9pY21wLmgJMjAwNy0wOC0yMiAxNjoyMzo1
NC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4yMi41X0lDTVBNU0cvaW5jbHVkZS9uZXQv
aWNtcC5oCTIwMDctMDgtMjMgMTU6NTY6NDUuMDAwMDAwMDAwIC0wNzAwCkBAIC0zMCw5ICszMCwx
NiBAQCBzdHJ1Y3QgaWNtcF9lcnIgewogCiBleHRlcm4gc3RydWN0IGljbXBfZXJyIGljbXBfZXJy
X2NvbnZlcnRbXTsKIERFQ0xBUkVfU05NUF9TVEFUKHN0cnVjdCBpY21wX21pYiwgaWNtcF9zdGF0
aXN0aWNzKTsKK0RFQ0xBUkVfU05NUF9TVEFUKHN0cnVjdCBpY21wbXNnX21pYiwgaWNtcG1zZ19z
dGF0aXN0aWNzKTsKICNkZWZpbmUgSUNNUF9JTkNfU1RBVFMoZmllbGQpCQlTTk1QX0lOQ19TVEFU
UyhpY21wX3N0YXRpc3RpY3MsIGZpZWxkKQogI2RlZmluZSBJQ01QX0lOQ19TVEFUU19CSChmaWVs
ZCkJU05NUF9JTkNfU1RBVFNfQkgoaWNtcF9zdGF0aXN0aWNzLCBmaWVsZCkKICNkZWZpbmUgSUNN
UF9JTkNfU1RBVFNfVVNFUihmaWVsZCkgCVNOTVBfSU5DX1NUQVRTX1VTRVIoaWNtcF9zdGF0aXN0
aWNzLCBmaWVsZCkKKyNkZWZpbmUgSUNNUE1TR09VVF9JTkNfU1RBVFMoZmllbGQpCVNOTVBfSU5D
X1NUQVRTKGljbXBtc2dfc3RhdGlzdGljcywgZmllbGQrMjU2KQorI2RlZmluZSBJQ01QTVNHT1VU
X0lOQ19TVEFUU19CSChmaWVsZCkJU05NUF9JTkNfU1RBVFNfQkgoaWNtcG1zZ19zdGF0aXN0aWNz
LCBmaWVsZCsyNTYpCisjZGVmaW5lIElDTVBNU0dPVVRfSU5DX1NUQVRTX1VTRVIoZmllbGQpIAlT
Tk1QX0lOQ19TVEFUU19VU0VSKGljbXBtc2dfc3RhdGlzdGljcywgZmllbGQrMjU2KQorI2RlZmlu
ZSBJQ01QTVNHSU5fSU5DX1NUQVRTKGZpZWxkKQlTTk1QX0lOQ19TVEFUUyhpY21wbXNnX3N0YXRp
c3RpY3MsIGZpZWxkKQorI2RlZmluZSBJQ01QTVNHSU5fSU5DX1NUQVRTX0JIKGZpZWxkKQlTTk1Q
X0lOQ19TVEFUU19CSChpY21wbXNnX3N0YXRpc3RpY3MsIGZpZWxkKQorI2RlZmluZSBJQ01QTVNH
SU5fSU5DX1NUQVRTX1VTRVIoZmllbGQpIFNOTVBfSU5DX1NUQVRTX1VTRVIoaWNtcG1zZ19zdGF0
aXN0aWNzLCBmaWVsZCkKIAogc3RydWN0IGRzdF9lbnRyeTsKIHN0cnVjdCBuZXRfcHJvdG9fZmFt
aWx5OwpAQCAtNDIsNiArNDksNyBAQCBleHRlcm4gdm9pZAlpY21wX3NlbmQoc3RydWN0IHNrX2J1
ZmYgKnNrCiBleHRlcm4gaW50CWljbXBfcmN2KHN0cnVjdCBza19idWZmICpza2IpOwogZXh0ZXJu
IGludAlpY21wX2lvY3RsKHN0cnVjdCBzb2NrICpzaywgaW50IGNtZCwgdW5zaWduZWQgbG9uZyBh
cmcpOwogZXh0ZXJuIHZvaWQJaWNtcF9pbml0KHN0cnVjdCBuZXRfcHJvdG9fZmFtaWx5ICpvcHMp
OworZXh0ZXJuIHZvaWQJaWNtcF9vdXRfY291bnQodW5zaWduZWQgY2hhciB0eXBlKTsKIAogLyog
TW92ZSBpbnRvIGRzdC5oID8gKi8KIGV4dGVybiBpbnQgCXhybGltX2FsbG93KHN0cnVjdCBkc3Rf
ZW50cnkgKmRzdCwgaW50IHRpbWVvdXQpOwpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L2luY2x1
ZGUvbmV0L3NubXAuaCBsaW51eC0yLjYuMjIuNV9JQ01QTVNHL2luY2x1ZGUvbmV0L3NubXAuaAot
LS0gbGludXgtMi42LjIyLjUvaW5jbHVkZS9uZXQvc25tcC5oCTIwMDctMDgtMjIgMTY6MjM6NTQu
MDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMjIuNV9JQ01QTVNHL2luY2x1ZGUvbmV0L3Nu
bXAuaAkyMDA3LTA4LTIzIDE0OjQyOjUwLjAwMDAwMDAwMCAtMDcwMApAQCAtODIsNiArODIsMTEg
QEAgc3RydWN0IGljbXBfbWliIHsKIAl1bnNpZ25lZCBsb25nCW1pYnNbSUNNUF9NSUJfTUFYXTsK
IH0gX19TTk1QX01JQl9BTElHTl9fOwogCisjZGVmaW5lIElDTVBNU0dfTUlCX01BWAlfX0lDTVBN
U0dfTUlCX01BWAorc3RydWN0IGljbXBtc2dfbWliIHsKKwl1bnNpZ25lZCBsb25nCW1pYnNbSUNN
UE1TR19NSUJfTUFYXTsKK30gX19TTk1QX01JQl9BTElHTl9fOworCiAvKiBJQ01QNiAoSVB2Ni1J
Q01QKSAqLwogI2RlZmluZSBJQ01QNl9NSUJfTUFYCV9fSUNNUDZfTUlCX01BWAogc3RydWN0IGlj
bXB2Nl9taWIgewpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L25ldC9pcHY0L2FmX2luZXQuYyBs
aW51eC0yLjYuMjIuNV9JQ01QTVNHL25ldC9pcHY0L2FmX2luZXQuYwotLS0gbGludXgtMi42LjIy
LjUvbmV0L2lwdjQvYWZfaW5ldC5jCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0wNzAw
CisrKyBsaW51eC0yLjYuMjIuNV9JQ01QTVNHL25ldC9pcHY0L2FmX2luZXQuYwkyMDA3LTA4LTIz
IDE0OjQ3OjI2LjAwMDAwMDAwMCAtMDcwMApAQCAtMTI5Niw2ICsxMjk2LDEwIEBAIHN0YXRpYyBp
bnQgX19pbml0IGluaXRfaXB2NF9taWJzKHZvaWQpCiAJCQkgIHNpemVvZihzdHJ1Y3QgaWNtcF9t
aWIpLAogCQkJICBfX2FsaWdub2ZfXyhzdHJ1Y3QgaWNtcF9taWIpKSA8IDApCiAJCWdvdG8gZXJy
X2ljbXBfbWliOworCWlmIChzbm1wX21pYl9pbml0KCh2b2lkICoqKWljbXBtc2dfc3RhdGlzdGlj
cywKKwkJCSAgc2l6ZW9mKHN0cnVjdCBpY21wbXNnX21pYiksCisJCQkgIF9fYWxpZ25vZl9fKHN0
cnVjdCBpY21wbXNnX21pYikpIDwgMCkKKwkJZ290byBlcnJfaWNtcG1zZ19taWI7CiAJaWYgKHNu
bXBfbWliX2luaXQoKHZvaWQgKiopdGNwX3N0YXRpc3RpY3MsCiAJCQkgIHNpemVvZihzdHJ1Y3Qg
dGNwX21pYiksCiAJCQkgIF9fYWxpZ25vZl9fKHN0cnVjdCB0Y3BfbWliKSkgPCAwKQpAQCAtMTMx
OCw2ICsxMzIyLDggQEAgZXJyX3VkcGxpdGVfbWliOgogZXJyX3VkcF9taWI6CiAJc25tcF9taWJf
ZnJlZSgodm9pZCAqKil0Y3Bfc3RhdGlzdGljcyk7CiBlcnJfdGNwX21pYjoKKwlzbm1wX21pYl9m
cmVlKCh2b2lkICoqKWljbXBtc2dfc3RhdGlzdGljcyk7CitlcnJfaWNtcG1zZ19taWI6CiAJc25t
cF9taWJfZnJlZSgodm9pZCAqKilpY21wX3N0YXRpc3RpY3MpOwogZXJyX2ljbXBfbWliOgogCXNu
bXBfbWliX2ZyZWUoKHZvaWQgKiopaXBfc3RhdGlzdGljcyk7CmRpZmYgLXJ1TnAgbGludXgtMi42
LjIyLjUvbmV0L2lwdjQvaWNtcC5jIGxpbnV4LTIuNi4yMi41X0lDTVBNU0cvbmV0L2lwdjQvaWNt
cC5jCi0tLSBsaW51eC0yLjYuMjIuNS9uZXQvaXB2NC9pY21wLmMJMjAwNy0wOC0yMiAxNjoyMzo1
NC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIuNi4yMi41X0lDTVBNU0cvbmV0L2lwdjQvaWNt
cC5jCTIwMDctMDgtMjMgMTU6NTc6MDcuMDAwMDAwMDAwIC0wNzAwCkBAIC0xMTUsNiArMTE1LDcg
QEAgc3RydWN0IGljbXBfYnhtIHsKICAqCVN0YXRpc3RpY3MKICAqLwogREVGSU5FX1NOTVBfU1RB
VChzdHJ1Y3QgaWNtcF9taWIsIGljbXBfc3RhdGlzdGljcykgX19yZWFkX21vc3RseTsKK0RFRklO
RV9TTk1QX1NUQVQoc3RydWN0IGljbXBtc2dfbWliLCBpY21wbXNnX3N0YXRpc3RpY3MpIF9fcmVh
ZF9tb3N0bHk7CiAKIC8qIEFuIGFycmF5IG9mIGVycm5vIGZvciBlcnJvciBtZXNzYWdlcyBmcm9t
IGRlc3QgdW5yZWFjaC4gKi8KIC8qIFJGQyAxMTIyOiAzLjIuMi4xIFN0YXRlcyB0aGF0IE5FVF9V
TlJFQUNILCBIT1NUX1VOUkVBQ0ggYW5kIFNSX0ZBSUxFRCBNVVNUIGJlIGNvbnNpZGVyZWQgJ3Ry
YW5zaWVudCBlcnJzJy4gKi8KQEAgLTIxNCw4ICsyMTUsNiBAQCBpbnQgc3lzY3RsX2ljbXBfZXJy
b3JzX3VzZV9pbmJvdW5kX2lmYWRkCiAgKi8KIAogc3RydWN0IGljbXBfY29udHJvbCB7Ci0JaW50
IG91dHB1dF9lbnRyeTsJLyogRmllbGQgZm9yIGluY3JlbWVudCBvbiBvdXRwdXQgKi8KLQlpbnQg
aW5wdXRfZW50cnk7CS8qIEZpZWxkIGZvciBpbmNyZW1lbnQgb24gaW5wdXQgKi8KIAl2b2lkICgq
aGFuZGxlcikoc3RydWN0IHNrX2J1ZmYgKnNrYik7CiAJc2hvcnQgICBlcnJvcjsJCS8qIFRoaXMg
SUNNUCBpcyBjbGFzc2VkIGFzIGFuIGVycm9yIG1lc3NhZ2UgKi8KIH07CkBAIC0zMTYsMTIgKzMx
NSwxMCBAQCBvdXQ6CiAvKgogICoJTWFpbnRhaW4gdGhlIGNvdW50ZXJzIHVzZWQgaW4gdGhlIFNO
TVAgc3RhdGlzdGljcyBmb3Igb3V0Z29pbmcgSUNNUAogICovCi1zdGF0aWMgdm9pZCBpY21wX291
dF9jb3VudChpbnQgdHlwZSkKK3ZvaWQgaWNtcF9vdXRfY291bnQodW5zaWduZWQgY2hhciB0eXBl
KQogewotCWlmICh0eXBlIDw9IE5SX0lDTVBfVFlQRVMpIHsKLQkJSUNNUF9JTkNfU1RBVFMoaWNt
cF9wb2ludGVyc1t0eXBlXS5vdXRwdXRfZW50cnkpOwotCQlJQ01QX0lOQ19TVEFUUyhJQ01QX01J
Ql9PVVRNU0dTKTsKLQl9CisJSUNNUE1TR09VVF9JTkNfU1RBVFModHlwZSk7CisJSUNNUF9JTkNf
U1RBVFMoSUNNUF9NSUJfT1VUTVNHUyk7CiB9CiAKIC8qCkBAIC0zOTAsNyArMzg3LDYgQEAgc3Rh
dGljIHZvaWQgaWNtcF9yZXBseShzdHJ1Y3QgaWNtcF9ieG0gKgogCQlyZXR1cm47CiAKIAlpY21w
X3BhcmFtLT5kYXRhLmljbXBoLmNoZWNrc3VtID0gMDsKLQlpY21wX291dF9jb3VudChpY21wX3Bh
cmFtLT5kYXRhLmljbXBoLnR5cGUpOwogCiAJaW5ldC0+dG9zID0gaXBfaGRyKHNrYiktPnRvczsK
IAlkYWRkciA9IGlwYy5hZGRyID0gcnQtPnJ0X3NyYzsKQEAgLTk1Miw2ICs5NDgsNyBAQCBpbnQg
aWNtcF9yY3Yoc3RydWN0IHNrX2J1ZmYgKnNrYikKIAogCWljbXBoID0gaWNtcF9oZHIoc2tiKTsK
IAorCUlDTVBNU0dJTl9JTkNfU1RBVFNfQkgoaWNtcGgtPnR5cGUpOwogCS8qCiAJICoJMTggaXMg
dGhlIGhpZ2hlc3QgJ2tub3duJyBJQ01QIHR5cGUuIEFueXRoaW5nIGVsc2UgaXMgYSBteXN0ZXJ5
CiAJICoKQEAgLTk4Niw3ICs5ODMsNiBAQCBpbnQgaWNtcF9yY3Yoc3RydWN0IHNrX2J1ZmYgKnNr
YikKIAkJfQogCX0KIAotCUlDTVBfSU5DX1NUQVRTX0JIKGljbXBfcG9pbnRlcnNbaWNtcGgtPnR5
cGVdLmlucHV0X2VudHJ5KTsKIAlpY21wX3BvaW50ZXJzW2ljbXBoLT50eXBlXS5oYW5kbGVyKHNr
Yik7CiAKIGRyb3A6CkBAIC0xMDAyLDEwOSArOTk4LDcxIEBAIGVycm9yOgogICovCiBzdGF0aWMg
Y29uc3Qgc3RydWN0IGljbXBfY29udHJvbCBpY21wX3BvaW50ZXJzW05SX0lDTVBfVFlQRVMgKyAx
XSA9IHsKIAlbSUNNUF9FQ0hPUkVQTFldID0gewotCQkub3V0cHV0X2VudHJ5ID0gSUNNUF9NSUJf
T1VURUNIT1JFUFMsCi0JCS5pbnB1dF9lbnRyeSA9IElDTVBfTUlCX0lORUNIT1JFUFMsCiAJCS5o
YW5kbGVyID0gaWNtcF9kaXNjYXJkLAogCX0sCiAJWzFdID0gewotCQkub3V0cHV0X2VudHJ5ID0g
SUNNUF9NSUJfRFVNTVksCi0JCS5pbnB1dF9lbnRyeSA9IElDTVBfTUlCX0lORVJST1JTLAogCQku
aGFuZGxlciA9IGljbXBfZGlzY2FyZCwKIAkJLmVycm9yID0gMSwKIAl9LAogCVsyXSA9IHsKLQkJ
Lm91dHB1dF9lbnRyeSA9IElDTVBfTUlCX0RVTU1ZLAotCQkuaW5wdXRfZW50cnkgPSBJQ01QX01J
Ql9JTkVSUk9SUywKIAkJLmhhbmRsZXIgPSBpY21wX2Rpc2NhcmQsCiAJCS5lcnJvciA9IDEsCiAJ
fSwKIAlbSUNNUF9ERVNUX1VOUkVBQ0hdID0gewotCQkub3V0cHV0X2VudHJ5ID0gSUNNUF9NSUJf
T1VUREVTVFVOUkVBQ0hTLAotCQkuaW5wdXRfZW50cnkgPSBJQ01QX01JQl9JTkRFU1RVTlJFQUNI
UywKIAkJLmhhbmRsZXIgPSBpY21wX3VucmVhY2gsCiAJCS5lcnJvciA9IDEsCiAJfSwKIAlbSUNN
UF9TT1VSQ0VfUVVFTkNIXSA9IHsKLQkJLm91dHB1dF9lbnRyeSA9IElDTVBfTUlCX09VVFNSQ1FV
RU5DSFMsCi0JCS5pbnB1dF9lbnRyeSA9IElDTVBfTUlCX0lOU1JDUVVFTkNIUywKIAkJLmhhbmRs
ZXIgPSBpY21wX3VucmVhY2gsCiAJCS5lcnJvciA9IDEsCiAJfSwKIAlbSUNNUF9SRURJUkVDVF0g
PSB7Ci0JCS5vdXRwdXRfZW50cnkgPSBJQ01QX01JQl9PVVRSRURJUkVDVFMsCi0JCS5pbnB1dF9l
bnRyeSA9IElDTVBfTUlCX0lOUkVESVJFQ1RTLAogCQkuaGFuZGxlciA9IGljbXBfcmVkaXJlY3Qs
CiAJCS5lcnJvciA9IDEsCiAJfSwKIAlbNl0gPSB7Ci0JCS5vdXRwdXRfZW50cnkgPSBJQ01QX01J
Ql9EVU1NWSwKLQkJLmlucHV0X2VudHJ5ID0gSUNNUF9NSUJfSU5FUlJPUlMsCiAJCS5oYW5kbGVy
ID0gaWNtcF9kaXNjYXJkLAogCQkuZXJyb3IgPSAxLAogCX0sCiAJWzddID0gewotCQkub3V0cHV0
X2VudHJ5ID0gSUNNUF9NSUJfRFVNTVksCi0JCS5pbnB1dF9lbnRyeSA9IElDTVBfTUlCX0lORVJS
T1JTLAogCQkuaGFuZGxlciA9IGljbXBfZGlzY2FyZCwKIAkJLmVycm9yID0gMSwKIAl9LAogCVtJ
Q01QX0VDSE9dID0gewotCQkub3V0cHV0X2VudHJ5ID0gSUNNUF9NSUJfT1VURUNIT1MsCi0JCS5p
bnB1dF9lbnRyeSA9IElDTVBfTUlCX0lORUNIT1MsCiAJCS5oYW5kbGVyID0gaWNtcF9lY2hvLAog
CX0sCiAJWzldID0gewotCQkub3V0cHV0X2VudHJ5ID0gSUNNUF9NSUJfRFVNTVksCi0JCS5pbnB1
dF9lbnRyeSA9IElDTVBfTUlCX0lORVJST1JTLAogCQkuaGFuZGxlciA9IGljbXBfZGlzY2FyZCwK
IAkJLmVycm9yID0gMSwKIAl9LAogCVsxMF0gPSB7Ci0JCS5vdXRwdXRfZW50cnkgPSBJQ01QX01J
Ql9EVU1NWSwKLQkJLmlucHV0X2VudHJ5ID0gSUNNUF9NSUJfSU5FUlJPUlMsCiAJCS5oYW5kbGVy
ID0gaWNtcF9kaXNjYXJkLAogCQkuZXJyb3IgPSAxLAogCX0sCiAJW0lDTVBfVElNRV9FWENFRURF
RF0gPSB7Ci0JCS5vdXRwdXRfZW50cnkgPSBJQ01QX01JQl9PVVRUSU1FRVhDRFMsCi0JCS5pbnB1
dF9lbnRyeSA9IElDTVBfTUlCX0lOVElNRUVYQ0RTLAogCQkuaGFuZGxlciA9IGljbXBfdW5yZWFj
aCwKIAkJLmVycm9yID0gMSwKIAl9LAogCVtJQ01QX1BBUkFNRVRFUlBST0JdID0gewotCQkub3V0
cHV0X2VudHJ5ID0gSUNNUF9NSUJfT1VUUEFSTVBST0JTLAotCQkuaW5wdXRfZW50cnkgPSBJQ01Q
X01JQl9JTlBBUk1QUk9CUywKIAkJLmhhbmRsZXIgPSBpY21wX3VucmVhY2gsCiAJCS5lcnJvciA9
IDEsCiAJfSwKIAlbSUNNUF9USU1FU1RBTVBdID0gewotCQkub3V0cHV0X2VudHJ5ID0gSUNNUF9N
SUJfT1VUVElNRVNUQU1QUywKLQkJLmlucHV0X2VudHJ5ID0gSUNNUF9NSUJfSU5USU1FU1RBTVBT
LAogCQkuaGFuZGxlciA9IGljbXBfdGltZXN0YW1wLAogCX0sCiAJW0lDTVBfVElNRVNUQU1QUkVQ
TFldID0gewotCQkub3V0cHV0X2VudHJ5ID0gSUNNUF9NSUJfT1VUVElNRVNUQU1QUkVQUywKLQkJ
LmlucHV0X2VudHJ5ID0gSUNNUF9NSUJfSU5USU1FU1RBTVBSRVBTLAogCQkuaGFuZGxlciA9IGlj
bXBfZGlzY2FyZCwKIAl9LAogCVtJQ01QX0lORk9fUkVRVUVTVF0gPSB7Ci0JCS5vdXRwdXRfZW50
cnkgPSBJQ01QX01JQl9EVU1NWSwKLQkJLmlucHV0X2VudHJ5ID0gSUNNUF9NSUJfRFVNTVksCiAJ
CS5oYW5kbGVyID0gaWNtcF9kaXNjYXJkLAogCX0sCiAJW0lDTVBfSU5GT19SRVBMWV0gPSB7Ci0J
CS5vdXRwdXRfZW50cnkgPSBJQ01QX01JQl9EVU1NWSwKLQkJLmlucHV0X2VudHJ5ID0gSUNNUF9N
SUJfRFVNTVksCiAJCS5oYW5kbGVyID0gaWNtcF9kaXNjYXJkLAogCX0sCiAJW0lDTVBfQUREUkVT
U10gPSB7Ci0JCS5vdXRwdXRfZW50cnkgPSBJQ01QX01JQl9PVVRBRERSTUFTS1MsCi0JCS5pbnB1
dF9lbnRyeSA9IElDTVBfTUlCX0lOQUREUk1BU0tTLAogCQkuaGFuZGxlciA9IGljbXBfYWRkcmVz
cywKIAl9LAogCVtJQ01QX0FERFJFU1NSRVBMWV0gPSB7Ci0JCS5vdXRwdXRfZW50cnkgPSBJQ01Q
X01JQl9PVVRBRERSTUFTS1JFUFMsCi0JCS5pbnB1dF9lbnRyeSA9IElDTVBfTUlCX0lOQUREUk1B
U0tSRVBTLAogCQkuaGFuZGxlciA9IGljbXBfYWRkcmVzc19yZXBseSwKIAl9LAogfTsKQEAgLTEx
NDYsNCArMTEwNCw1IEBAIHZvaWQgX19pbml0IGljbXBfaW5pdChzdHJ1Y3QgbmV0X3Byb3RvX2YK
IEVYUE9SVF9TWU1CT0woaWNtcF9lcnJfY29udmVydCk7CiBFWFBPUlRfU1lNQk9MKGljbXBfc2Vu
ZCk7CiBFWFBPUlRfU1lNQk9MKGljbXBfc3RhdGlzdGljcyk7CitFWFBPUlRfU1lNQk9MKGljbXBt
c2dfc3RhdGlzdGljcyk7CiBFWFBPUlRfU1lNQk9MKHhybGltX2FsbG93KTsKZGlmZiAtcnVOcCBs
aW51eC0yLjYuMjIuNS9uZXQvaXB2NC9pcF9vdXRwdXQuYyBsaW51eC0yLjYuMjIuNV9JQ01QTVNH
L25ldC9pcHY0L2lwX291dHB1dC5jCi0tLSBsaW51eC0yLjYuMjIuNS9uZXQvaXB2NC9pcF9vdXRw
dXQuYwkyMDA3LTA4LTIyIDE2OjIzOjU0LjAwMDAwMDAwMCAtMDcwMAorKysgbGludXgtMi42LjIy
LjVfSUNNUE1TRy9uZXQvaXB2NC9pcF9vdXRwdXQuYwkyMDA3LTA4LTIzIDE1OjU0OjQ1LjAwMDAw
MDAwMCAtMDcwMApAQCAtMTI1OCw2ICsxMjU4LDEwIEBAIGludCBpcF9wdXNoX3BlbmRpbmdfZnJh
bWVzKHN0cnVjdCBzb2NrICoKIAlza2ItPnByaW9yaXR5ID0gc2stPnNrX3ByaW9yaXR5OwogCXNr
Yi0+ZHN0ID0gZHN0X2Nsb25lKCZydC0+dS5kc3QpOwogCisJaWYgKGlwaC0+cHJvdG9jb2wgPT0g
SVBQUk9UT19JQ01QKQorCQlpY21wX291dF9jb3VudCgoKHN0cnVjdCBpY21waGRyICopCisJCQlz
a2JfdHJhbnNwb3J0X2hlYWRlcihza2IpKS0+dHlwZSk7CisKIAkvKiBOZXRmaWx0ZXIgZ2V0cyB3
aG9sZSB0aGUgbm90IGZyYWdtZW50ZWQgc2tiLiAqLwogCWVyciA9IE5GX0hPT0soUEZfSU5FVCwg
TkZfSVBfTE9DQUxfT1VULCBza2IsIE5VTEwsCiAJCSAgICAgIHNrYi0+ZHN0LT5kZXYsIGRzdF9v
dXRwdXQpOwpkaWZmIC1ydU5wIGxpbnV4LTIuNi4yMi41L25ldC9pcHY0L3Byb2MuYyBsaW51eC0y
LjYuMjIuNV9JQ01QTVNHL25ldC9pcHY0L3Byb2MuYwotLS0gbGludXgtMi42LjIyLjUvbmV0L2lw
djQvcHJvYy5jCTIwMDctMDgtMjIgMTY6MjM6NTQuMDAwMDAwMDAwIC0wNzAwCisrKyBsaW51eC0y
LjYuMjIuNV9JQ01QTVNHL25ldC9pcHY0L3Byb2MuYwkyMDA3LTA4LTIzIDE1OjU4OjQyLjAwMDAw
MDAwMCAtMDcwMApAQCAtMTIzLDMzICsxMjMsMzAgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBzbm1w
X21pYiBzbm1wNF9pcGV4dAogc3RhdGljIGNvbnN0IHN0cnVjdCBzbm1wX21pYiBzbm1wNF9pY21w
X2xpc3RbXSA9IHsKIAlTTk1QX01JQl9JVEVNKCJJbk1zZ3MiLCBJQ01QX01JQl9JTk1TR1MpLAog
CVNOTVBfTUlCX0lURU0oIkluRXJyb3JzIiwgSUNNUF9NSUJfSU5FUlJPUlMpLAotCVNOTVBfTUlC
X0lURU0oIkluRGVzdFVucmVhY2hzIiwgSUNNUF9NSUJfSU5ERVNUVU5SRUFDSFMpLAotCVNOTVBf
TUlCX0lURU0oIkluVGltZUV4Y2RzIiwgSUNNUF9NSUJfSU5USU1FRVhDRFMpLAotCVNOTVBfTUlC
X0lURU0oIkluUGFybVByb2JzIiwgSUNNUF9NSUJfSU5QQVJNUFJPQlMpLAotCVNOTVBfTUlCX0lU
RU0oIkluU3JjUXVlbmNocyIsIElDTVBfTUlCX0lOU1JDUVVFTkNIUyksCi0JU05NUF9NSUJfSVRF
TSgiSW5SZWRpcmVjdHMiLCBJQ01QX01JQl9JTlJFRElSRUNUUyksCi0JU05NUF9NSUJfSVRFTSgi
SW5FY2hvcyIsIElDTVBfTUlCX0lORUNIT1MpLAotCVNOTVBfTUlCX0lURU0oIkluRWNob1JlcHMi
LCBJQ01QX01JQl9JTkVDSE9SRVBTKSwKLQlTTk1QX01JQl9JVEVNKCJJblRpbWVzdGFtcHMiLCBJ
Q01QX01JQl9JTlRJTUVTVEFNUFMpLAotCVNOTVBfTUlCX0lURU0oIkluVGltZXN0YW1wUmVwcyIs
IElDTVBfTUlCX0lOVElNRVNUQU1QUkVQUyksCi0JU05NUF9NSUJfSVRFTSgiSW5BZGRyTWFza3Mi
LCBJQ01QX01JQl9JTkFERFJNQVNLUyksCi0JU05NUF9NSUJfSVRFTSgiSW5BZGRyTWFza1JlcHMi
LCBJQ01QX01JQl9JTkFERFJNQVNLUkVQUyksCiAJU05NUF9NSUJfSVRFTSgiT3V0TXNncyIsIElD
TVBfTUlCX09VVE1TR1MpLAogCVNOTVBfTUlCX0lURU0oIk91dEVycm9ycyIsIElDTVBfTUlCX09V
VEVSUk9SUyksCi0JU05NUF9NSUJfSVRFTSgiT3V0RGVzdFVucmVhY2hzIiwgSUNNUF9NSUJfT1VU
REVTVFVOUkVBQ0hTKSwKLQlTTk1QX01JQl9JVEVNKCJPdXRUaW1lRXhjZHMiLCBJQ01QX01JQl9P
VVRUSU1FRVhDRFMpLAotCVNOTVBfTUlCX0lURU0oIk91dFBhcm1Qcm9icyIsIElDTVBfTUlCX09V
VFBBUk1QUk9CUyksCi0JU05NUF9NSUJfSVRFTSgiT3V0U3JjUXVlbmNocyIsIElDTVBfTUlCX09V
VFNSQ1FVRU5DSFMpLAotCVNOTVBfTUlCX0lURU0oIk91dFJlZGlyZWN0cyIsIElDTVBfTUlCX09V
VFJFRElSRUNUUyksCi0JU05NUF9NSUJfSVRFTSgiT3V0RWNob3MiLCBJQ01QX01JQl9PVVRFQ0hP
UyksCi0JU05NUF9NSUJfSVRFTSgiT3V0RWNob1JlcHMiLCBJQ01QX01JQl9PVVRFQ0hPUkVQUyks
Ci0JU05NUF9NSUJfSVRFTSgiT3V0VGltZXN0YW1wcyIsIElDTVBfTUlCX09VVFRJTUVTVEFNUFMp
LAotCVNOTVBfTUlCX0lURU0oIk91dFRpbWVzdGFtcFJlcHMiLCBJQ01QX01JQl9PVVRUSU1FU1RB
TVBSRVBTKSwKLQlTTk1QX01JQl9JVEVNKCJPdXRBZGRyTWFza3MiLCBJQ01QX01JQl9PVVRBRERS
TUFTS1MpLAotCVNOTVBfTUlCX0lURU0oIk91dEFkZHJNYXNrUmVwcyIsIElDTVBfTUlCX09VVEFE
RFJNQVNLUkVQUyksCiAJU05NUF9NSUJfU0VOVElORUwKIH07CiAKK3N0YXRpYyBzdHJ1Y3Qgewor
CWNoYXIgKm5hbWU7CisJaW50IGluZGV4OworfSBpY21wbWlibWFwW10gPSB7CisJeyAiRGVzdFVu
cmVhY2hzIiwgSUNNUF9ERVNUX1VOUkVBQ0ggfSwKKwl7ICJUaW1lRXhjZHMiLCBJQ01QX1RJTUVf
RVhDRUVERUQgfSwKKwl7ICJQYXJtUHJvYnMiLCBJQ01QX1BBUkFNRVRFUlBST0IgfSwKKwl7ICJT
cmNRdWVuY2hzIiwgSUNNUF9TT1VSQ0VfUVVFTkNIIH0sCisJeyAiUmVkaXJlY3RzIiwgSUNNUF9S
RURJUkVDVCB9LAorCXsgIkVjaG9zIiwgSUNNUF9FQ0hPIH0sCisJeyAiRWNob1JlcHMiLCBJQ01Q
X0VDSE9SRVBMWSB9LAorCXsgIlRpbWVzdGFtcHMiLCBJQ01QX1RJTUVTVEFNUCB9LAorCXsgIlRp
bWVzdGFtcFJlcHMiLCBJQ01QX1RJTUVTVEFNUFJFUExZIH0sCisJeyAiQWRkck1hc2tzIiwgSUNN
UF9BRERSRVNTIH0sCisJeyAiQWRkck1hc2tSZXBzIiwgSUNNUF9BRERSRVNTUkVQTFkgfSwKKwl7
IDAsIDAgfQorfTsKKworCiBzdGF0aWMgY29uc3Qgc3RydWN0IHNubXBfbWliIHNubXA0X3RjcF9s
aXN0W10gPSB7CiAJU05NUF9NSUJfSVRFTSgiUnRvQWxnb3JpdGhtIiwgVENQX01JQl9SVE9BTEdP
UklUSE0pLAogCVNOTVBfTUlCX0lURU0oIlJ0b01pbiIsIFRDUF9NSUJfUlRPTUlOKSwKQEAgLTI0
Nyw2ICsyNDQsNzIgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBzbm1wX21pYiBzbm1wNF9uZXRfbAog
CVNOTVBfTUlCX1NFTlRJTkVMCiB9OwogCitzdGF0aWMgdm9pZCBpY21wbXNnX3B1dChzdHJ1Y3Qg
c2VxX2ZpbGUgKnNlcSkKK3sKKyNkZWZpbmUgUEVSTElORQkxNgorCisJaW50IGosIGksIGNvdW50
OworCXN0YXRpYyBpbnQgb3V0W1BFUkxJTkVdOworCisJY291bnQgPSAwOworCWZvciAoaSA9IDA7
IGkgPCBJQ01QTVNHX01JQl9NQVg7IGkrKykgeworCisJCWlmIChzbm1wX2ZvbGRfZmllbGQoKHZv
aWQgKiopIGljbXBtc2dfc3RhdGlzdGljcywgaSkpCisJCQlvdXRbY291bnQrK10gPSBpOworCQlp
ZiAoY291bnQgPCBQRVJMSU5FKQorCQkJY29udGludWU7CisKKwkJc2VxX3ByaW50ZihzZXEsICJc
bkljbXBNc2c6Iik7CisJCWZvciAoaiA9IDA7IGogPCBQRVJMSU5FOyArK2opCisJCQlzZXFfcHJp
bnRmKHNlcSwgIiAlc1R5cGUldSIsIGkgJiAweDEwMCA/ICJPdXQiIDogIkluIiwKKwkJCQkJaSAm
IDB4ZmYpOworCQlzZXFfcHJpbnRmKHNlcSwgIlxuSWNtcE1zZzogIik7CisJCWZvciAoaiA9IDA7
IGogPCBQRVJMSU5FOyArK2opCisJCQlzZXFfcHJpbnRmKHNlcSwgIiAlbHUiLAorCQkJCXNubXBf
Zm9sZF9maWVsZCgodm9pZCAqKikgaWNtcG1zZ19zdGF0aXN0aWNzLAorCQkJCW91dFtqXSkpOwor
CQlzZXFfcHV0YyhzZXEsICdcbicpOworCX0KKwlpZiAoY291bnQpIHsKKwkJc2VxX3ByaW50Zihz
ZXEsICJcbkljbXBNc2c6Iik7CisJCWZvciAoaiA9IDA7IGogPCBjb3VudDsgKytqKQorCQkJc2Vx
X3ByaW50ZihzZXEsICIgJXNUeXBlJXUiLCBvdXRbal0gJiAweDEwMCA/ICJPdXQiIDoKKwkJCQki
SW4iLCBvdXRbal0gJiAweGZmKTsKKwkJc2VxX3ByaW50ZihzZXEsICJcbkljbXBNc2c6Iik7CisJ
CWZvciAoaiA9IDA7IGogPCBjb3VudDsgKytqKQorCQkJc2VxX3ByaW50ZihzZXEsICIgJWx1Iiwg
c25tcF9mb2xkX2ZpZWxkKCh2b2lkICoqKQorCQkJCWljbXBtc2dfc3RhdGlzdGljcywgb3V0W2pd
KSk7CisJfQorCisjdW5kZWYgUEVSTElORQorfQorCitzdGF0aWMgdm9pZCBpY21wX3B1dChzdHJ1
Y3Qgc2VxX2ZpbGUgKnNlcSkKK3sKKwlpbnQgaTsKKworCXNlcV9wdXRzKHNlcSwgIlxuSWNtcDog
SW5Nc2dzIEluRXJyb3JzIik7CisJZm9yIChpPTA7IGljbXBtaWJtYXBbaV0ubmFtZSAhPSBOVUxM
OyBpKyspCisJCXNlcV9wcmludGYoc2VxLCAiIEluJXMiLCBpY21wbWlibWFwW2ldLm5hbWUpOwor
CXNlcV9wcmludGYoc2VxLCAiIE91dE1zZ3MgT3V0RXJyb3JzIik7CisJZm9yIChpPTA7IGljbXBt
aWJtYXBbaV0ubmFtZSAhPSBOVUxMOyBpKyspCisJCXNlcV9wcmludGYoc2VxLCAiIE91dCVzIiwg
aWNtcG1pYm1hcFtpXS5uYW1lKTsKKwlzZXFfcHJpbnRmKHNlcSwgIlxuSWNtcDogJWx1ICVsdSIs
CisJCXNubXBfZm9sZF9maWVsZCgodm9pZCAqKikgaWNtcF9zdGF0aXN0aWNzLCBJQ01QX01JQl9J
Tk1TR1MpLAorCQlzbm1wX2ZvbGRfZmllbGQoKHZvaWQgKiopIGljbXBfc3RhdGlzdGljcywgSUNN
UF9NSUJfSU5FUlJPUlMpKTsKKwlmb3IgKGk9MDsgaWNtcG1pYm1hcFtpXS5uYW1lICE9IE5VTEw7
IGkrKykKKwkJc2VxX3ByaW50ZihzZXEsICIgJWx1IiwKKwkJCXNubXBfZm9sZF9maWVsZCgodm9p
ZCAqKikgaWNtcG1zZ19zdGF0aXN0aWNzLAorCQkJCWljbXBtaWJtYXBbaV0uaW5kZXgpKTsKKwlz
ZXFfcHJpbnRmKHNlcSwgIiAlbHUgJWx1IiwKKwkJc25tcF9mb2xkX2ZpZWxkKCh2b2lkICoqKSBp
Y21wX3N0YXRpc3RpY3MsIElDTVBfTUlCX09VVE1TR1MpLAorCQlzbm1wX2ZvbGRfZmllbGQoKHZv
aWQgKiopIGljbXBfc3RhdGlzdGljcywgSUNNUF9NSUJfT1VURVJST1JTKSk7CisJZm9yIChpPTA7
IGljbXBtaWJtYXBbaV0ubmFtZSAhPSBOVUxMOyBpKyspCisJCXNlcV9wcmludGYoc2VxLCAiICVs
dSIsCisJCQlzbm1wX2ZvbGRfZmllbGQoKHZvaWQgKiopIGljbXBtc2dfc3RhdGlzdGljcywKKwkJ
CQlpY21wbWlibWFwW2ldLmluZGV4KSk7Cit9CisKIC8qCiAgKglDYWxsZWQgZnJvbSB0aGUgUFJP
Q2ZzIG1vZHVsZS4gVGhpcyBvdXRwdXRzIC9wcm9jL25ldC9zbm1wLgogICovCkBAIC0yNjcsMTUg
KzMzMCw4IEBAIHN0YXRpYyBpbnQgc25tcF9zZXFfc2hvdyhzdHJ1Y3Qgc2VxX2ZpbGUKIAkJCSAg
IHNubXBfZm9sZF9maWVsZCgodm9pZCAqKilpcF9zdGF0aXN0aWNzLAogCQkJCQkgICBzbm1wNF9p
cHN0YXRzX2xpc3RbaV0uZW50cnkpKTsKIAotCXNlcV9wdXRzKHNlcSwgIlxuSWNtcDoiKTsKLQlm
b3IgKGkgPSAwOyBzbm1wNF9pY21wX2xpc3RbaV0ubmFtZSAhPSBOVUxMOyBpKyspCi0JCXNlcV9w
cmludGYoc2VxLCAiICVzIiwgc25tcDRfaWNtcF9saXN0W2ldLm5hbWUpOwotCi0Jc2VxX3B1dHMo
c2VxLCAiXG5JY21wOiIpOwotCWZvciAoaSA9IDA7IHNubXA0X2ljbXBfbGlzdFtpXS5uYW1lICE9
IE5VTEw7IGkrKykKLQkJc2VxX3ByaW50ZihzZXEsICIgJWx1IiwKLQkJCSAgIHNubXBfZm9sZF9m
aWVsZCgodm9pZCAqKilpY21wX3N0YXRpc3RpY3MsCi0JCQkJCSAgIHNubXA0X2ljbXBfbGlzdFtp
XS5lbnRyeSkpOworCWljbXBfcHV0KHNlcSk7CS8qIFJGQyAyMDExIGNvbXBhdGliaWxpdHkgKi8K
KwlpY21wbXNnX3B1dChzZXEpOwogCiAJc2VxX3B1dHMoc2VxLCAiXG5UY3A6Iik7CiAJZm9yIChp
ID0gMDsgc25tcDRfdGNwX2xpc3RbaV0ubmFtZSAhPSBOVUxMOyBpKyspCkBAIC0zMzIsNiArMzg4
LDggQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBmaWxlX29wZXJhdGlvbnMgc25tcAogCS5yZWxlYXNl
ID0gc2luZ2xlX3JlbGVhc2UsCiB9OwogCisKKwogLyoKICAqCU91dHB1dCAvcHJvYy9uZXQvbmV0
c3RhdAogICovCmRpZmYgLXJ1TnAgbGludXgtMi42LjIyLjUvbmV0L2lwdjQvcmF3LmMgbGludXgt
Mi42LjIyLjVfSUNNUE1TRy9uZXQvaXB2NC9yYXcuYwotLS0gbGludXgtMi42LjIyLjUvbmV0L2lw
djQvcmF3LmMJMjAwNy0wOC0yMiAxNjoyMzo1NC4wMDAwMDAwMDAgLTA3MDAKKysrIGxpbnV4LTIu
Ni4yMi41X0lDTVBNU0cvbmV0L2lwdjQvcmF3LmMJMjAwNy0wOC0yMyAxNTo1NDoxMi4wMDAwMDAw
MDAgLTA3MDAKQEAgLTMxMyw2ICszMTMsOSBAQCBzdGF0aWMgaW50IHJhd19zZW5kX2hkcmluYyhz
dHJ1Y3Qgc29jayAqCiAKIAkJaXBoLT5jaGVjayA9IGlwX2Zhc3RfY3N1bSgodW5zaWduZWQgY2hh
ciAqKWlwaCwgaXBoLT5paGwpOwogCX0KKwlpZiAoaXBoLT5wcm90b2NvbCA9PSBJUFBST1RPX0lD
TVApCisJCWljbXBfb3V0X2NvdW50KCgoc3RydWN0IGljbXBoZHIgKikKKwkJCXNrYl90cmFuc3Bv
cnRfaGVhZGVyKHNrYikpLT50eXBlKTsKIAogCWVyciA9IE5GX0hPT0soUEZfSU5FVCwgTkZfSVBf
TE9DQUxfT1VULCBza2IsIE5VTEwsIHJ0LT51LmRzdC5kZXYsCiAJCSAgICAgIGRzdF9vdXRwdXQp
Owo=

--=_mixed 000D332088257353_=--
