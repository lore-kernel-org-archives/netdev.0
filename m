From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH net-next] avoid to hang up on sending since sysctl configuration overflow.
Date: Thu, 24 Jan 2013 14:35:28 +0800
Message-ID: <1359009328-24582-1-git-send-email-bingtian.ly@taobao.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, panweiping3@gmail.com,
	bingtian.ly@taobao.com, Li Yu <raise.sail@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:60594 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab3AXGfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 01:35:45 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so5319770pad.16
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 22:35:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: bingtian.ly@taobao.com

    I found if we write large than 4GB value to some sysctl variables,
the sending syscall will hang up forever, because of these variables
are 32 bits, such large value bring them overflow to 0 or negative.

    This patch try to fix overflow or prevent from zero value setup
of below sysctl variables:

net.core.wmem_default
net.core.rmem_default

net.core.rmem_max
net.core.wmem_max

net.ipv4.udp_rmem_min
net.ipv4.udp_wmem_min

net.ipv4.tcp_wmem
net.ipv4.tcp_rmem

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Li Yu <raise.sail@gmail.com>
---
 core/sysctl_net_core.c |   14 ++++++++++----
 ipv4/sysctl_net_ipv4.c |   11 +++++++----
 2 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index d1b0804..cfdb46a 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -20,6 +20,8 @@
 #include <net/sock.h>
 #include <net/net_ratelimit.h>
 
+static int one = 1;
+
 #ifdef CONFIG_RPS
 static int rps_sock_flow_sysctl(ctl_table *table, int write,
 				void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -92,28 +94,32 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_wmem_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
 	},
 	{
 		.procname	= "rmem_max",
 		.data		= &sysctl_rmem_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
 	},
 	{
 		.procname	= "wmem_default",
 		.data		= &sysctl_wmem_default,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
 	},
 	{
 		.procname	= "rmem_default",
 		.data		= &sysctl_rmem_default,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
 	},
 	{
 		.procname	= "dev_weight",
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a25e1d2..2622707 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -27,6 +27,7 @@
 #include <net/tcp_memcontrol.h>
 
 static int zero;
+static int one = 1;
 static int two = 2;
 static int tcp_retr1_max = 255;
 static int ip_local_port_range_min[] = { 1, 1 };
@@ -549,14 +550,16 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_wmem,
 		.maxlen		= sizeof(sysctl_tcp_wmem),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
 	},
 	{
 		.procname	= "tcp_rmem",
 		.data		= &sysctl_tcp_rmem,
 		.maxlen		= sizeof(sysctl_tcp_rmem),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
 	},
 	{
 		.procname	= "tcp_app_win",
@@ -779,7 +782,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_udp_rmem_min),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero
+		.extra1		= &one
 	},
 	{
 		.procname	= "udp_wmem_min",
@@ -787,7 +790,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_udp_wmem_min),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero
+		.extra1		= &one
 	},
 	{ }
 };
