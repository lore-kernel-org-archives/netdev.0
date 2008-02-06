From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Make the synchronization interval controllable
Date: Thu,  7 Feb 2008 00:57:43 +0100
Message-ID: <1202342263-25176-1-git-send-email-sven.wegener@stealer.net>
References: <Pine.LNX.4.64.0802062329150.15729@titan.stealer.net>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:34614 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764474AbYBFX5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 18:57:47 -0500
In-Reply-To: <Pine.LNX.4.64.0802062329150.15729@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default synchronization interval of 1000 milliseconds is too high for a
heavily loaded director. Collecting the connection information from one second
and then sending it out in a burst will overflow the socket buffer and lead to
synchronization information being dropped. Make the interval controllable by a
sysctl variable so that users can tune it. We enforce a lower limit of 0 and an
upper limit of 2000 ms on the interval. A too large interval can make the
synchronization buffer consume too much memory and will also delay the exit of
the kernel threads.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---

Changes from the last version include the addition of the range enforcement.
Also place the definitions of the variables where all other ipvs sysctl
variables are.

Documentation/networking/ipvs-sysctl.txt |   10 ++++++++++
 include/net/ip_vs.h                      |    1 +
 net/ipv4/ipvs/ip_vs_ctl.c                |   12 ++++++++++++
 net/ipv4/ipvs/ip_vs_sync.c               |    4 ++--
 4 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 4ccdbca..bb4eb9a 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -141,3 +141,13 @@ sync_threshold - INTEGER
         synchronized, every time the number of its incoming packets
         modulus 50 equals the threshold. The range of the threshold is
         from 0 to 49.
+
+sync_interval - INTEGER
+	default 1000
+
+	The information from synchronization is buffered and sent out at a
+	regular interval by a kernel thread. The interval (in ms) is
+	controlled by this value. The default is too high for a heavily loaded
+	director. If you get a lot of "ip_vs_send_async error" messages from
+	your kernel, then you should lower this value. The value of the
+	interval can be chosen from the range from 0 to 2000.
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 56f3c94..9c4498b 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -854,6 +854,7 @@ extern int sysctl_ip_vs_cache_bypass;
 extern int sysctl_ip_vs_expire_nodest_conn;
 extern int sysctl_ip_vs_expire_quiescent_template;
 extern int sysctl_ip_vs_sync_threshold[2];
+extern int sysctl_ip_vs_sync_interval;
 extern int sysctl_ip_vs_nat_icmp_send;
 extern struct ip_vs_stats ip_vs_stats;
 extern struct ctl_path net_vs_ctl_path[];
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 94c5767..c6322f7 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -80,8 +80,11 @@ int sysctl_ip_vs_cache_bypass = 0;
 int sysctl_ip_vs_expire_nodest_conn = 0;
 int sysctl_ip_vs_expire_quiescent_template = 0;
 int sysctl_ip_vs_sync_threshold[2] = { 3, 50 };
+int sysctl_ip_vs_sync_interval = 1000;
 int sysctl_ip_vs_nat_icmp_send = 0;
 
+static int ip_vs_sync_interval_min = 0;
+static int ip_vs_sync_interval_max = 2000;
 
 #ifdef CONFIG_IP_VS_DEBUG
 static int sysctl_ip_vs_debug_level = 0;
@@ -1582,6 +1585,15 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_sync_threshold,
 	},
 	{
+		.procname	= "sync_interval",
+		.data		= &sysctl_ip_vs_sync_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.extra1		= &ip_vs_sync_interval_min,
+		.extra2		= &ip_vs_sync_interval_max,
+	},
+	{
 		.procname	= "nat_icmp_send",
 		.data		= &sysctl_ip_vs_nat_icmp_send,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 948378d..10ab1b7 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -701,7 +701,7 @@ static void sync_master_loop(void)
 		if (stop_master_sync)
 			break;
 
-		msleep_interruptible(1000);
+		msleep_interruptible(sysctl_ip_vs_sync_interval);
 	}
 
 	/* clean up the sync_buff queue */
@@ -758,7 +758,7 @@ static void sync_backup_loop(void)
 		if (stop_backup_sync)
 			break;
 
-		msleep_interruptible(1000);
+		msleep_interruptible(sysctl_ip_vs_sync_interval);
 	}
 
 	/* release the sending multicast socket */
-- 
1.5.4

