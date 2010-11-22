From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH v2] tcp: restrict net.ipv4.tcp_adv_win_scale (#20312)
Date: Tue, 23 Nov 2010 00:54:21 +0200
Message-ID: <20101122225421.GA7372@core2.telecom.by>
References: <20101114151825.GA25137@core2.telecom.by>
 <1289764183.2743.94.camel@edumazet-laptop>
 <20101114201458.GA28181@core2.telecom.by>
 <1289830722.2586.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:56791 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166Ab0KVWyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 17:54:33 -0500
Received: by ewy5 with SMTP id 5so2104358ewy.19
        for <netdev@vger.kernel.org>; Mon, 22 Nov 2010 14:54:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1289830722.2586.5.camel@bwh-desktop>
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

Indeed, if sysctl_tcp_adv_win_scale is exactly 32,
space >> 32 equals space and function returns 0.

Which means we busyloop in tcp_fixup_rcvbuf().

Restrict net.ipv4.tcp_adv_win_scale to [-31, 31].

Fix https://bugzilla.kernel.org/show_bug.cgi?id=20312

Steps to reproduce:

      echo 32 >/proc/sys/net/ipv4/tcp_adv_win_scale
      wget www.kernel.org
      [softlockup]

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 Documentation/networking/ip-sysctl.txt |    1 +
 net/ipv4/sysctl_net_ipv4.c             |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -144,6 +144,7 @@ tcp_adv_win_scale - INTEGER
 	Count buffering overhead as bytes/2^tcp_adv_win_scale
 	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
 	if it is <= 0.
+	Possible values are [-31, 31], inclusive.
 	Default: 2
 
 tcp_allowed_congestion_control - STRING
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -26,6 +26,8 @@ static int zero;
 static int tcp_retr1_max = 255;
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
+static int tcp_adv_win_scale_min = -31;
+static int tcp_adv_win_scale_max = 31;
 
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
@@ -426,7 +428,9 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_adv_win_scale,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &tcp_adv_win_scale_min,
+		.extra2		= &tcp_adv_win_scale_max,
 	},
 	{
 		.procname	= "tcp_tw_reuse",
