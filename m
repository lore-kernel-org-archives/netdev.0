From: Sven Wegener <sven.wegener@stealer.net>
Subject: [PATCH] ipvs: Make the synchronization interval controllable
Date: Wed,  6 Feb 2008 22:39:50 +0100
Message-ID: <1202333990-19359-1-git-send-email-sven.wegener@stealer.net>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758795AbYBFVkK@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The default synchronization interval of 1000 milliseconds is too high for a
heavily loaded director. Collecting the connection information from one second
and then sending it out in a burst will overflow the socket buffer and lead to
synchronization information being dropped. Make the interval controllable by a
sysctl variable so that users can tune it.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 Documentation/networking/ipvs-sysctl.txt |    9 +++++++++
 net/ipv4/ipvs/ip_vs_ctl.c                |    9 ++++++++-
 net/ipv4/ipvs/ip_vs_sync.c               |    6 ++++--
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
index 4ccdbca..1389e2f 100644
--- a/Documentation/networking/ipvs-sysctl.txt
+++ b/Documentation/networking/ipvs-sysctl.txt
@@ -141,3 +141,12 @@ sync_threshold - INTEGER
         synchronized, every time the number of its incoming packets
         modulus 50 equals the threshold. The range of the threshold is
         from 0 to 49.
+
+sync_interval - INTEGER
+	default 1000
+
+	The information from synchronization is buffered and sent out at
+	regular intervals by a kernel thread. The interval (in ms) is
+	controlled by this value. The default is too high for a heavily loaded
+	director. If you get a lot of "ip_vs_send_async error" messages from
+	your kernel, then you should lower this value.
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 94c5767..2781505 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -81,7 +81,7 @@ int sysctl_ip_vs_expire_nodest_conn = 0;
 int sysctl_ip_vs_expire_quiescent_template = 0;
 int sysctl_ip_vs_sync_threshold[2] = { 3, 50 };
 int sysctl_ip_vs_nat_icmp_send = 0;
-
+extern int sysctl_ip_vs_sync_interval;
 
 #ifdef CONFIG_IP_VS_DEBUG
 static int sysctl_ip_vs_debug_level = 0;
@@ -1582,6 +1582,13 @@ static struct ctl_table vs_vars[] = {
 		.proc_handler	= &proc_do_sync_threshold,
 	},
 	{
+		.procname	= "sync_interval",
+		.data		= &sysctl_ip_vs_sync_interval,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.procname	= "nat_icmp_send",
 		.data		= &sysctl_ip_vs_nat_icmp_send,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index 948378d..9b57ad3 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -143,6 +143,8 @@ char ip_vs_backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
 /* multicast addr */
 static struct sockaddr_in mcast_addr;
 
+/* milliseconds between synchronization runs */
+int sysctl_ip_vs_sync_interval = 1000;
 
 static inline void sb_queue_tail(struct ip_vs_sync_buff *sb)
 {
@@ -701,7 +703,7 @@ static void sync_master_loop(void)
 		if (stop_master_sync)
 			break;
 
-		msleep_interruptible(1000);
+		msleep_interruptible(sysctl_ip_vs_sync_interval);
 	}
 
 	/* clean up the sync_buff queue */
@@ -758,7 +760,7 @@ static void sync_backup_loop(void)
 		if (stop_backup_sync)
 			break;
 
-		msleep_interruptible(1000);
+		msleep_interruptible(sysctl_ip_vs_sync_interval);
 	}
 
 	/* release the sending multicast socket */
-- 
1.5.4
