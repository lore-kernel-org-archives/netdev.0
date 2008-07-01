From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] icmp: fix units for ratelimit
Date: Tue, 1 Jul 2008 15:38:20 -0700
Message-ID: <20080701153820.235faa72@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:48740 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763648AbYGAWnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 18:43:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the sysctl values for icmp ratelimit to use milliseconds instead
of jiffies which is based on kernel configured HZ.
Internal kernel jiffies are not a proper unit for any userspace API.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next-2.6

--- a/Documentation/networking/ip-sysctl.txt	2008-07-01 14:11:39.000000000 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2008-07-01 14:14:15.000000000 -0700
@@ -548,8 +548,9 @@ icmp_echo_ignore_broadcasts - BOOLEAN
 icmp_ratelimit - INTEGER
 	Limit the maximal rates for sending ICMP packets whose type matches
 	icmp_ratemask (see below) to specific targets.
-	0 to disable any limiting, otherwise the maximal rate in jiffies(1)
-	Default: 100
+	0 to disable any limiting,
+	otherwise the minimal space between responses in milliseconds.
+	Default: 1000
 
 icmp_ratemask - INTEGER
 	Mask made of ICMP types for which rates are being limited.
@@ -1027,8 +1028,9 @@ max_addresses - INTEGER
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
-	0 to disable any limiting, otherwise the maximal rate in jiffies(1)
-	Default: 100
+	0 to disable any limiting,
+	otherwise the minimal space between responses in milliseconds.
+	Default: 1000
 
 
 IPv6 Update by:
--- a/net/ipv4/sysctl_net_ipv4.c	2008-07-01 14:14:34.000000000 -0700
+++ b/net/ipv4/sysctl_net_ipv4.c	2008-07-01 14:17:10.000000000 -0700
@@ -793,7 +793,8 @@ static struct ctl_table ipv4_net_table[]
 		.data		= &init_net.ipv4.sysctl_icmp_ratelimit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_ms_jiffies,
+		.strategy	= &sysctl_ms_jiffies
 	},
 	{
 		.ctl_name	= NET_IPV4_ICMP_RATEMASK,
--- a/net/ipv6/icmp.c	2008-07-01 14:15:37.000000000 -0700
+++ b/net/ipv6/icmp.c	2008-07-01 14:17:06.000000000 -0700
@@ -954,7 +954,8 @@ ctl_table ipv6_icmp_table_template[] = {
 		.data		= &init_net.ipv6.sysctl.icmpv6_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &proc_dointvec_ms_jiffies,
+		.strategy	= &sysctl_ms_jiffies
 	},
 	{ .ctl_name = 0 },
 };
