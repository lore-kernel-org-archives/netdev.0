From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/6] netfilter: xt_LOG: fix bogus extra layer-4 logging information
Date: Tue,  6 Mar 2012 00:19:44 +0100
Message-ID: <1330989588-26833-3-git-send-email-richard@nod.at>
References: <1330989588-26833-1-git-send-email-richard@nod.at>
Cc: jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org,
	Richard Weinberger <richard@nod.at>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330989588-26833-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In 16059b5 netfilter: merge ipt_LOG and ip6_LOG into xt_LOG, we have
merged ipt_LOG and ip6t_LOG.

However:

IN=wlan0 OUT= MAC=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
SRC=213.150.61.61 DST=192.168.1.133 LEN=40 TOS=0x00 PREC=0x00 TTL=117
ID=10539 DF PROTO=TCP SPT=80 DPT=49013 WINDOW=0 RES=0x00 ACK RST
URGP=0 PROTO=UDPLITE SPT=80 DPT=49013 LEN=45843 PROTO=ICMP TYPE=0
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Several missing break in the code led to including bogus layer-4
information. This patch fixes this problem.

Signed-off-by: Richard Weinberger <richard@nod.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_LOG.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 1595608..f99f8de 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -216,12 +216,14 @@ static void dump_ipv4_packet(struct sbuff *m,
 				    ntohs(ih->frag_off) & IP_OFFSET,
 				    iphoff+ih->ihl*4, logflags))
 			return;
+		break;
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 		if (dump_udp_header(m, skb, ih->protocol,
 				    ntohs(ih->frag_off) & IP_OFFSET,
 				    iphoff+ih->ihl*4))
 			return;
+		break;
 	case IPPROTO_ICMP: {
 		struct icmphdr _icmph;
 		const struct icmphdr *ich;
@@ -649,10 +651,12 @@ static void dump_ipv6_packet(struct sbuff *m,
 		if (dump_tcp_header(m, skb, currenthdr, fragment, ptr,
 		    logflags))
 			return;
+		break;
 	case IPPROTO_UDP:
 	case IPPROTO_UDPLITE:
 		if (dump_udp_header(m, skb, currenthdr, fragment, ptr))
 			return;
+		break;
 	case IPPROTO_ICMPV6: {
 		struct icmp6hdr _icmp6h;
 		const struct icmp6hdr *ic;
-- 
1.7.7.3
