From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] tcp: restrict net.ipv4.tcp_adv_min_scale (#20312)
Date: Sun, 14 Nov 2010 17:18:25 +0200
Message-ID: <20101114151825.GA25137@core2.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:47388 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755826Ab0KNPSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 10:18:32 -0500
Received: by ewy8 with SMTP id 8so389252ewy.19
        for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 07:18:31 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_win_from_space() does the following:

	if (sysctl_tcp_adv_win_scale <= 0)
		return space >> (-sysctl_tcp_adv_win_scale);
	else
		return space - (space >> sysctl_tcp_adv_win_scale);

"space" is int.

As per C99 6.5.7 (3) shifting int for 32 or more bits is
undefined behaviour.

Indeed, if sysctl_tcp_adv_win_scale is exactly 32, space >> 32 equals
space and function returns 0;

Which means we busyloop in tcp_fixup_rcvbuf().

Restrict net.ipv4.tcp_adv_win_scale to [-31, 31].

Fix https://bugzilla.kernel.org/show_bug.cgi?id=20312

Steps to reproduce:

	echo 32 >/proc/sys/net/ipv4/tcp_adv_win_scale
	wget www.kernel.org
	[softlockup]

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -26,6 +26,8 @@ static int zero;
 static int tcp_retr1_max = 255;
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
+static int _minus_31 = -31;
+static int _31 = 31;
 
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
@@ -426,7 +428,9 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_adv_win_scale,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &_minus_31,
+		.extra2		= &_31,
 	},
 	{
 		.procname	= "tcp_tw_reuse",
