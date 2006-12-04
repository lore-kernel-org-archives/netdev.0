From: weidong <weid@nanjing-fnst.com>
Subject: [patch] Fix SNMPv2 "ipOutNoRoutes" counter error
Date: Mon, 4 Dec 2006 07:10:31 +0000 (UTC)
Message-ID: <1165337386.2545.4.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:54732 "EHLO proxy.fnst.com.cn")
	by vger.kernel.org with ESMTP id S1758807AbWLDHKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 02:10:17 -0500
To: netdev@vger.kernel.org
Date: Tue, 05 Dec 2006 11:49:46 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All:
    When I tested linux kernel 2.6.18.3, and find that kernel statistics
about IPSTATS_MIB_OUTNOROUTES which exsits in file /proc/net/snmp
doesn't increase correctly.  The criteria conform to RFC2011:

  ipOutNoRoutes OBJECT-TYPE
    SYNTAX      Counter32
    MAX-ACCESS  read-only
    STATUS      current
    DESCRIPTION
            "The number of IP datagrams discarded because no route could
            be found to transmit them to their destination.  Note that
            this counter includes any packets counted in ipForwDatagrams
            which meet this `no-route' criterion.  Note that this
            includes any datagrams which a host cannot route because all
            of its default routers are down."
    ::= { ip 12 }

When a host received an IP packet, but the destination address is not
this host. The kernel just discards the IP packet but with no increment
for this counter.

When a router received an IP packet that this router can't forward due
to no route found. Kernel just simply invoke ip_error(), and send ICMP
packet. Also do nothing for this counter.

Signed-off-by: Wei Dong <weid@nanjing-fnst.com>

diff -ruN old/net/ipv4/icmp.c new/net/ipv4/icmp.c
--- old/net/ipv4/icmp.c	2006-09-20 00:42:06.000000000 -0300
+++ new/net/ipv4/icmp.c	2006-12-04 11:46:39.000000000 -0300
@@ -580,6 +580,9 @@
 		icmp_param.data_len = room;
 	icmp_param.head_len = sizeof(struct icmphdr);
 
+	if (code == ICMP_NET_UNREACH)
+		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+
 	icmp_push_reply(&icmp_param, &ipc, rt);
 ende:
 	ip_rt_put(rt);
diff -ruN old/net/ipv4/ip_input.c new/net/ipv4/ip_input.c
--- old/net/ipv4/ip_input.c	2006-09-20 00:42:06.000000000 -0300
+++ new/net/ipv4/ip_input.c	2006-11-29 11:15:52.000000000 -0300
@@ -340,8 +340,10 @@
 		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
 					 skb->dev);
 		if (unlikely(err)) {
-			if (err == -EHOSTUNREACH)
+			if (err == -EHOSTUNREACH) {
 				IP_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+				IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+			}
 			goto drop; 
 		}
 	}


