From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: add SNMP counters tracking incoming ECN bits
Date: Thu, 01 Aug 2013 08:26:31 -0700
Message-ID: <1375370791.10515.154.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:48031 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365Ab3HAP0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 11:26:34 -0400
Received: by mail-pa0-f49.google.com with SMTP id bi5so2252884pad.36
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 08:26:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With GRO/LRO processing, there is a problem because Ip[6]InReceives SNMP
counters do not count the number of frames, but number of aggregated
segments.

Its probably too late to change this now.

This patch adds four new counters, tracking number of frames, regardless
of LRO/GRO, and on a per ECN status basis, for IPv4 and IPv6.

Ip[6]NoECTPkts : Number of packets received with NOECT
Ip[6]ECT1Pkts  : Number of packets received with ECT(1)
Ip[6]ECT0Pkts  : Number of packets received with ECT(0)
Ip[6]CEPkts    : Number of packets received with Congestion Experimented

lph37:~# nstat | egrep "Pkts|InReceive"
IpInReceives                    1634137            0.0
Ip6InReceives                   3714107            0.0
Ip6InNoECTPkts                  19205              0.0
Ip6InECT0Pkts                   52651828           0.0
IpExtInNoECTPkts                33630              0.0
IpExtInECT0Pkts                 15581379           0.0
IpExtInCEPkts                   6                  0.0

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/snmp.h |    4 ++++
 net/ipv4/ip_input.c       |    8 ++++++++
 net/ipv4/proc.c           |    7 ++++++-
 net/ipv6/ip6_input.c      |    6 +++++-
 net/ipv6/proc.c           |    4 ++++
 5 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index af0a674..60601d2 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -51,6 +51,10 @@ enum
 	IPSTATS_MIB_INBCASTOCTETS,		/* InBcastOctets */
 	IPSTATS_MIB_OUTBCASTOCTETS,		/* OutBcastOctets */
 	IPSTATS_MIB_CSUMERRORS,			/* InCsumErrors */
+	IPSTATS_MIB_NOECTPKTS,			/* InNoECTPkts */
+	IPSTATS_MIB_ECT1PKTS,			/* InECT1Pkts */
+	IPSTATS_MIB_ECT0PKTS,			/* InECT0Pkts */
+	IPSTATS_MIB_CEPKTS,			/* InCEPkts */
 	__IPSTATS_MIB_MAX
 };
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 15e3e68..054a3e9 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -141,6 +141,7 @@
 #include <net/icmp.h>
 #include <net/raw.h>
 #include <net/checksum.h>
+#include <net/inet_ecn.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/xfrm.h>
 #include <linux/mroute.h>
@@ -410,6 +411,13 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	if (iph->ihl < 5 || iph->version != 4)
 		goto inhdr_error;
 
+	BUILD_BUG_ON(IPSTATS_MIB_ECT1PKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_ECT_1);
+	BUILD_BUG_ON(IPSTATS_MIB_ECT0PKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_ECT_0);
+	BUILD_BUG_ON(IPSTATS_MIB_CEPKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_CE);
+	IP_ADD_STATS_BH(dev_net(dev),
+			IPSTATS_MIB_NOECTPKTS + (iph->tos & INET_ECN_MASK),
+			max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
+
 	if (!pskb_may_pull(skb, iph->ihl*4))
 		goto inhdr_error;
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 6577a11..5f5fa61 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -111,7 +111,7 @@ static const struct snmp_mib snmp4_ipstats_list[] = {
 	SNMP_MIB_SENTINEL
 };
 
-/* Following RFC4293 items are displayed in /proc/net/netstat */
+/* Following items are displayed in /proc/net/netstat */
 static const struct snmp_mib snmp4_ipextstats_list[] = {
 	SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
 	SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
@@ -125,7 +125,12 @@ static const struct snmp_mib snmp4_ipextstats_list[] = {
 	SNMP_MIB_ITEM("OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
 	SNMP_MIB_ITEM("InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
 	SNMP_MIB_ITEM("OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
+	/* Non RFC4293 fields */
 	SNMP_MIB_ITEM("InCsumErrors", IPSTATS_MIB_CSUMERRORS),
+	SNMP_MIB_ITEM("InNoECTPkts", IPSTATS_MIB_NOECTPKTS),
+	SNMP_MIB_ITEM("InECT1Pkts", IPSTATS_MIB_ECT1PKTS),
+	SNMP_MIB_ITEM("InECT0Pkts", IPSTATS_MIB_ECT0PKTS),
+	SNMP_MIB_ITEM("InCEPkts", IPSTATS_MIB_CEPKTS),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 2bab2aa..302d6fb 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -44,7 +44,7 @@
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
 #include <net/xfrm.h>
-
+#include <net/inet_ecn.h>
 
 
 int ip6_rcv_finish(struct sk_buff *skb)
@@ -109,6 +109,10 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	if (hdr->version != 6)
 		goto err;
 
+	IP6_ADD_STATS_BH(dev_net(dev), idev,
+			 IPSTATS_MIB_NOECTPKTS +
+				(ipv6_get_dsfield(hdr) & INET_ECN_MASK),
+			 max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
 	/*
 	 * RFC4291 2.5.3
 	 * A packet received on an interface with a destination address
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 51c3285..091d066 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -91,6 +91,10 @@ static const struct snmp_mib snmp6_ipstats_list[] = {
 	SNMP_MIB_ITEM("Ip6InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
 	SNMP_MIB_ITEM("Ip6OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
 	/* IPSTATS_MIB_CSUMERRORS is not relevant in IPv6 (no checksum) */
+	SNMP_MIB_ITEM("Ip6InNoECTPkts", IPSTATS_MIB_NOECTPKTS),
+	SNMP_MIB_ITEM("Ip6InECT1Pkts", IPSTATS_MIB_ECT1PKTS),
+	SNMP_MIB_ITEM("Ip6InECT0Pkts", IPSTATS_MIB_ECT0PKTS),
+	SNMP_MIB_ITEM("Ip6InCEPkts", IPSTATS_MIB_CEPKTS),
 	SNMP_MIB_SENTINEL
 };
 
