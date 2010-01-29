From: Patrick McHardy <kaber@trash.net>
Subject: Re: fwmark based routing stopped working in 2.6.32
Date: Fri, 29 Jan 2010 14:21:23 +0100
Message-ID: <4B62E0D3.8040207@trash.net>
References: <4B62DF02.4010405@trpkovic.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090301010806080804030209"
Cc: linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Nebojsa Trpkovic <nebojsa@trpkovic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39771 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060Ab0A2NV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 08:21:29 -0500
In-Reply-To: <4B62DF02.4010405@trpkovic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090301010806080804030209
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Nebojsa Trpkovic wrote:
> hello.
> 
> I have two ADSL links on eth2 and eth3.
> 
> ADSL1 (eth2) with IP 10.5.18.18 is default gateway in main routing table.
> 
> ADSL2 (eth3) with IP 10.5.18.22 is used just for marked packets:
> ###################################################
> #!/bin/bash
> ip route add default via 10.5.18.22 dev eth3 table 20
> ip rule add fwmark 0x351 table 20
> ip rule add fwmark 0x352 table 20
> ip rule add fwmark 0x353 table 20
> ip route flush cache
> ###################################################
> 
> everything worked fine for years using kernels 2.6.24 and 2.6.29.
> recently I upgraded to 2.6.32-r2 and traffic through ADSL2 stopped.
> 
> the moment I delete table 20 and ip rules, everything works fine:
> I can set both ADSL1 or ADSL2 as default gateway and they will work.
> 
> again, the moment I start making routing decision considering firewall
> marks, I get traffic only on ADSL1 (main table default gw) interface.
> 
> I've found out that when I mark ICMP protocol with 0x351 fwmark and try
> too ping something, ping packets are sent via eth3 indeed:
> iptraf detailed eth3 statistics shows that there are constatnly outgoing
> ICMP packages.
> 
> even more interesting is fact that there is exactly the same number of
> incoming ICMP packages, but my ping output is empty:
> there is no "Destination Host Unreachable" or similar - nothing.
> 
> this leeds me to believe that ICMP packages are routed right, I receive
> some answer, but those answer packages are discarded.
> 
> so, I've flushed all firewall rules except marking for ICMP, and added
> explicit
> ###################################################
> iptables -t mangle -A OUTPUT -p ICMP -j MARK --set-mark 0x351
> ###################################################
> that didn't help.
> 
> I've added explicit rule
> ###################################################
> iptables -I INPUT -i eth3 -j ACCEPT
> ###################################################
> that didn't help.
> 
> I've checked, and my source route verification is turned off for these
> ifaces:
> ###################################################
> etc # sysctl net.ipv4.conf.default.rp_filter
> net.ipv4.conf.default.rp_filter = 1
> etc # sysctl net.ipv4.conf.eth2.rp_filter
> net.ipv4.conf.eth2.rp_filter = 0
> etc # sysctl net.ipv4.conf.eth3.rp_filter
> net.ipv4.conf.eth3.rp_filter = 0
> ###################################################
> changing that to "=1" doesn't solve the problem.
> 
> tcpdump on eth3 after 3 pings to 216.239.34.10
> ###################################################
> ping -I eth3 -c3 216.239.34.10
> PING 216.239.34.10 (216.239.34.10) from 10.5.18.21 eth3: 56(84) bytes of
> data.
> 
> --- 216.239.34.10 ping statistics ---
> 3 packets transmitted, 0 received, 100% packet loss, time 2006ms
> ###################################################
> ###################################################
> 13:24:23.556436 00:23:54:07:e9:6a > 00:90:d0:da:d2:06, ethertype IPv4
> (0x0800), length 98: 10.5.18.21 > 216.239.34.10: ICMP echo request, id
> 51300, seq 1, length 64
> 13:24:23.605304 00:90:d0:da:d2:06 > 00:23:54:07:e9:6a, ethertype IPv4
> (0x0800), length 98: 216.239.34.10 > 10.5.18.21: ICMP echo reply, id
> 51300, seq 1, length 64
> 13:24:24.555536 00:23:54:07:e9:6a > 00:90:d0:da:d2:06, ethertype IPv4
> (0x0800), length 98: 10.5.18.21 > 216.239.34.10: ICMP echo request, id
> 51300, seq 2, length 64
> 13:24:24.603520 00:90:d0:da:d2:06 > 00:23:54:07:e9:6a, ethertype IPv4
> (0x0800), length 98: 216.239.34.10 > 10.5.18.21: ICMP echo reply, id
> 51300, seq 2, length 64
> 13:24:25.563105 00:23:54:07:e9:6a > 00:90:d0:da:d2:06, ethertype IPv4
> (0x0800), length 98: 10.5.18.21 > 216.239.34.10: ICMP echo request, id
> 51300, seq 3, length 64
> 13:24:25.610497 00:90:d0:da:d2:06 > 00:23:54:07:e9:6a, ethertype IPv4
> (0x0800), length 98: 216.239.34.10 > 10.5.18.21: ICMP echo reply, id
> 51300, seq 3, length 64
> ###################################################
> 
> so, I'm definitely getting those packets back, but system ignoress them.
> 
> any idea what could go wrong and why does my system discard packages
> from eth3 if they are not routed by main ruting table?
> 
> any info on what could be changed between kernels 2.6.29 and 2.6.32
> regarding this issue?

Please try this patch. It might need a few minor changes to apply
cleanly.

--------------090301010806080804030209
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 28f6aeea3f12d37bd258b2c0d5ba891bff4ec479
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Fri Dec 25 17:30:22 2009 -0800

    net: restore ip source validation
    
    when using policy routing and the skb mark:
    there are cases where a back path validation requires us
    to use a different routing table for src ip validation than
    the one used for mapping ingress dst ip.
    One such a case is transparent proxying where we pretend to be
    the destination system and therefore the local table
    is used for incoming packets but possibly a main table would
    be used on outbound.
    Make the default behavior to allow the above and if users
    need to turn on the symmetry via sysctl src_valid_mark
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 699e85c..b230492 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -81,6 +81,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_FORWARD(in_dev)		IN_DEV_CONF_GET((in_dev), FORWARDING)
 #define IN_DEV_MFORWARD(in_dev)		IN_DEV_ANDCONF((in_dev), MC_FORWARDING)
 #define IN_DEV_RPFILTER(in_dev)		IN_DEV_MAXCONF((in_dev), RP_FILTER)
+#define IN_DEV_SRC_VMARK(in_dev)    	IN_DEV_ORCONF((in_dev), SRC_VMARK)
 #define IN_DEV_SOURCE_ROUTE(in_dev)	IN_DEV_ANDCONF((in_dev), \
 						       ACCEPT_SOURCE_ROUTE)
 #define IN_DEV_ACCEPT_LOCAL(in_dev)	IN_DEV_ORCONF((in_dev), ACCEPT_LOCAL)
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 877ba03..bd27fbc 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -482,6 +482,7 @@ enum
 	NET_IPV4_CONF_ARP_ACCEPT=21,
 	NET_IPV4_CONF_ARP_NOTIFY=22,
 	NET_IPV4_CONF_ACCEPT_LOCAL=23,
+	NET_IPV4_CONF_SRC_VMARK=24,
 	__NET_IPV4_CONF_MAX
 };
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5cdbc10..040c4f0 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1397,6 +1397,7 @@ static struct devinet_sysctl_table {
 		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_SOURCE_ROUTE,
 					"accept_source_route"),
 		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_LOCAL, "accept_local"),
+		DEVINET_SYSCTL_RW_ENTRY(SRC_VMARK, "src_valid_mark"),
 		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP, "proxy_arp"),
 		DEVINET_SYSCTL_RW_ENTRY(MEDIUM_ID, "medium_id"),
 		DEVINET_SYSCTL_RW_ENTRY(BOOTP_RELAY, "bootp_relay"),
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 3323168..82dbf71 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -252,6 +252,8 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 		no_addr = in_dev->ifa_list == NULL;
 		rpf = IN_DEV_RPFILTER(in_dev);
 		accept_local = IN_DEV_ACCEPT_LOCAL(in_dev);
+		if (mark && !IN_DEV_SRC_VMARK(in_dev))
+			fl.mark = 0;
 	}
 	rcu_read_unlock();
 

--------------090301010806080804030209--
