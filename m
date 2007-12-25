From: Andreas Henriksson <andreas@fatal.se>
Subject: [RFC] old stuff - Kernel Bug Tracker Bug 7398
Date: Tue, 25 Dec 2007 01:27:12 +0100
Message-ID: <1198542433.4379.74.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pierre Ynard <linkfanel@yahoo.fr>, 394780@bugs.debian.org
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:32857 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbXLYAYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 19:24:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

While looking over the old remaining bugs reported against iproute in
Debian I came across http://bugs.debian.org/394780 which has also been
reported as http://bugzilla.kernel.org/show_bug.cgi?id=7398 (please see
the old comments here).

As there seems to be a question remaining which still hasn't been
answered (read: shot down), I thought I'd try to give this a push a last
time.

The bugs last comment was from Pierre asking about a patch he provided:
> I am sorry, I didn't mean to break anything... What about a sysctl option, to
> give the user the possibility to disable the hack? See attached patch. I can't
> really see any drawback to that. Please review and consider re-opening the bug.

The patch (which probably doesn't even apply anymore) is available from
http://andrea.via.ecp.fr/mc-src-strict.patch but also quoted below for
your convenience...

It would be nice to have some comments on this so we can put this issue
to rest without leaving any loose ends.



(Btw, I'm a bit surprised by the comment about backwards compatability
before proper functionality. If this hack has been in the kernel for 11
years, isn't it soon time to say that the applications has been given
enough time to fix their problems and remove it? I thought thats how it
usually worked around here.... I guess I was wrong.)



diff -urNp linux-2.6.18/Documentation/filesystems/proc.txt linux-2.6.18/Documentation/filesystems/proc.txt
--- linux-2.6.18/Documentation/filesystems/proc.txt	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18/Documentation/filesystems/proc.txt	2006-10-26 05:13:15.000000000 -0700
@@ -1758,6 +1758,15 @@ max_delay, min_delay
 
 Delays for flushing the routing cache.
 
+mc_src_strict
+-------------
+
+There is a hack in the kernel router which provides compatibility for old
+multicast applications such as vic, vat and friends. Unfortunately, this
+hack also breaks normal behavior of preferred source address selection
+(iproute2 "src" field) with multicast and limited broadcast. Enabling this
+option disables this hack and restores normal (strict) behavior.
+
 redirect_load, redirect_number
 ------------------------------
 
diff -urNp linux-2.6.18/include/linux/sysctl.h linux-2.6.18/include/linux/sysctl.h
--- linux-2.6.18/include/linux/sysctl.h	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18/include/linux/sysctl.h	2006-10-26 04:25:00.000000000 -0700
@@ -433,6 +433,7 @@ enum {
 	NET_IPV4_ROUTE_MIN_ADVMSS=17,
 	NET_IPV4_ROUTE_SECRET_INTERVAL=18,
 	NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS=19,
+	NET_IPV4_ROUTE_MC_SRC_STRICT=20,
 };
 
 enum
diff -urNp linux-2.6.18/net/ipv4/route.c linux-2.6.18/net/ipv4/route.c
--- linux-2.6.18/net/ipv4/route.c	2006-09-19 20:42:06.000000000 -0700
+++ linux-2.6.18/net/ipv4/route.c	2006-10-26 05:11:00.000000000 -0700
@@ -132,6 +132,7 @@ static int ip_rt_mtu_expires		= 10 * 60 
 static int ip_rt_min_pmtu		= 512 + 20 + 20;
 static int ip_rt_min_advmss		= 256;
 static int ip_rt_secret_interval	= 10 * 60 * HZ;
+static int ip_rt_mc_src_strict		= 0;
 static unsigned long rt_deadline;
 
 #define RTprint(a...)	printk(KERN_DEBUG a)
@@ -2416,7 +2417,7 @@ static int ip_route_output_slow(struct r
 		      of another iface. --ANK
 		 */
 
-		if (oldflp->oif == 0
+		if (!ip_rt_mc_src_strict && oldflp->oif == 0
 		    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == 0xFFFFFFFF)) {
 			/* Special hack: user can direct multicasts
 			   and limited broadcast via necessary interface
@@ -2431,6 +2432,12 @@ static int ip_route_output_slow(struct r
 			   cannot know, that ttl is zero, so that packet
 			   will not leave this host and route is valid).
 			   Luckily, this hack is good workaround.
+
+			   Unfortunately, it also breaks normal behavior of
+			   source address preference, so I added a sysctl option
+			   to let the user disable this hack and restore normal
+			   behavior. By default, the hack is still enabled (old
+			   compatibility behavior). -- PY
 			 */
 
 			fl.oif = dev_out->ifindex;
@@ -3057,6 +3064,15 @@ ctl_table ipv4_route_table[] = {
 		.proc_handler	= &proc_dointvec_jiffies,
 		.strategy	= &sysctl_jiffies,
 	},
+	{
+		.ctl_name	= NET_IPV4_ROUTE_MC_SRC_STRICT,
+		.procname	= "mc_src_strict",
+		.data		= &ip_rt_mc_src_strict,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &ipv4_doint_and_flush,
+		.strategy	= &ipv4_doint_and_flush_strategy,
+	},
 	{ .ctl_name = 0 }
 };
 #endif




-- 
Regards,
Andreas Henriksson

