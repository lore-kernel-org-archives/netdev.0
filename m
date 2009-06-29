From: Andreas Jaggi <aj@open.ch>
Subject: [PATCH] gre: copy ToS/DiffServ bits to outer IP header
Date: Mon, 29 Jun 2009 15:07:14 +0200
Message-ID: <4A48BC82.6040801@open.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.open.ch ([213.156.224.131]:55131 "EHLO mail6.open.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755AbZF2NZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 09:25:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tunneling IP traffic with GRE this patch makes it possible to export the ToS/DiffServ information to the outer IP header.
This is particularly useful in a scenario with ESP/AH where the inner IP header is encrypted but the packet priority/DiffServ information
should still be respected by the transporting routers (for example in an MPLS backbone network).

The feature is disabled by default and can be enabled on a per-interface basis (/proc/sys/net/ipv4/conf/ethX/gre_copy_tos).

Also does this bring Linux back in the game, as JunOS/IOS provide this for quite some time:
http://www.cisco.com/en/US/docs/ios/11_3/feature/guide/greqos.html
http://www.juniper.net/techpubs/software/junos/junos94/swconfig-services/configuring-a-gre-tunnel-to-copy-tos-bits-to-the-outer-ip-header.html

Signed-off-by: Andreas Jaggi <aj@open.ch>

diff -urN vanilla-linux-2.6.29.4/include/linux/sysctl.h gre-copy-tos/include/linux/sysctl.h
--- vanilla-linux-2.6.29.4/include/linux/sysctl.h	2009-05-19 01:52:34.000000000 +0200
+++ gre-copy-tos/include/linux/sysctl.h	2009-06-29 14:23:07.000000000 +0200
@@ -490,6 +490,7 @@
 	NET_IPV4_CONF_ARP_IGNORE=19,
 	NET_IPV4_CONF_PROMOTE_SECONDARIES=20,
 	NET_IPV4_CONF_ARP_ACCEPT=21,
+	NET_IPV4_CONF_GRE_COPY_TOS=22,
 	__NET_IPV4_CONF_MAX
 };
 
diff -urN vanilla-linux-2.6.29.4/kernel/sysctl_check.c gre-copy-tos/kernel/sysctl_check.c
--- vanilla-linux-2.6.29.4/kernel/sysctl_check.c	2009-05-19 01:52:34.000000000 +0200
+++ gre-copy-tos/kernel/sysctl_check.c	2009-06-29 14:23:07.000000000 +0200
@@ -219,6 +219,7 @@
 	{ NET_IPV4_CONF_ARP_IGNORE,		"arp_ignore" },
 	{ NET_IPV4_CONF_PROMOTE_SECONDARIES,	"promote_secondaries" },
 	{ NET_IPV4_CONF_ARP_ACCEPT,		"arp_accept" },
+	{ NET_IPV4_CONF_GRE_COPY_TOS,		"gre_copy_tos" },
 	{}
 };
 
diff -urN vanilla-linux-2.6.29.4/net/ipv4/devinet.c gre-copy-tos/net/ipv4/devinet.c
--- vanilla-linux-2.6.29.4/net/ipv4/devinet.c	2009-05-19 01:52:34.000000000 +0200
+++ gre-copy-tos/net/ipv4/devinet.c	2009-06-29 14:23:07.000000000 +0200
@@ -1439,6 +1439,7 @@
 		DEVINET_SYSCTL_RW_ENTRY(ARP_ANNOUNCE, "arp_announce"),
 		DEVINET_SYSCTL_RW_ENTRY(ARP_IGNORE, "arp_ignore"),
 		DEVINET_SYSCTL_RW_ENTRY(ARP_ACCEPT, "arp_accept"),
+		DEVINET_SYSCTL_RW_ENTRY(GRE_COPY_TOS, "gre_copy_tos"),
 
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
diff -urN vanilla-linux-2.6.29.4/net/ipv4/ip_gre.c gre-copy-tos/net/ipv4/ip_gre.c
--- vanilla-linux-2.6.29.4/net/ipv4/ip_gre.c	2009-05-19 01:52:34.000000000 +0200
+++ gre-copy-tos/net/ipv4/ip_gre.c	2009-06-29 14:23:24.000000000 +0200
@@ -610,6 +610,7 @@
 	struct net_device_stats *stats = &tunnel->dev->stats;
 	struct iphdr  *old_iph = ip_hdr(skb);
 	struct iphdr  *tiph;
+	struct in_device *in_dev;
 	u8     tos;
 	__be16 df;
 	struct rtable *rt;     			/* Route to the other host */
@@ -677,11 +678,13 @@
 	}
 
 	tos = tiph->tos;
-	if (tos&1) {
+	in_dev = in_dev_get(dev);
+	if ((in_dev && IN_DEV_ORCONF(in_dev, GRE_COPY_TOS)) || tos&1) {
 		if (skb->protocol == htons(ETH_P_IP))
 			tos = old_iph->tos;
 		tos &= ~1;
 	}
+	in_dev_put(in_dev);
 
 	{
 		struct flowi fl = { .oif = tunnel->parms.link,
