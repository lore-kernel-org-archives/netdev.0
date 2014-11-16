From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 01/14] net: provide a per host RSS key generic infrastructure
Date: Sun, 16 Nov 2014 06:23:05 -0800
Message-ID: <1416147798-16561-2-git-send-email-edumazet@google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:51543 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875AbaKPObp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:31:45 -0500
Received: by mail-yk0-f201.google.com with SMTP id 142so67919ykq.4
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:31:44 -0800 (PST)
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RSS (Receive Side Scaling) typically uses Toeplitz hash and a 40 or 52 bytes
RSS key.

Some drivers use a constant (and well known key), some drivers use a random
key per port, making bonding setups hard to tune. Well known keys increase
attack surface, considering that number of queues is usually a power of two.

This patch provides infrastructure to help drivers doing the right thing.

netdev_rss_key_fill() should be used by drivers to initialize their RSS key,
even if they provide ethtool -X support to let user redefine the key later.

A new /proc/sys/net/core/netdev_rss_key file can be used to get the host
RSS key even for drivers not providing ethtool -x support, in case some
applications want to precisely setup flows to match some RX queues.

Tested:

myhost:~# cat /proc/sys/net/core/netdev_rss_key
11:63:99:bb:79:fb:a5:a7:07:45:b2:20:bf:02:42:2d:08:1a:dd:19:2b:6b:23:ac:56:28:9d:70:c3:ac:e8:16:4b:b7:c1:10:53:a4:78:41:36:40:74:b6:15:ca:27:44:aa:b3:4d:72

myhost:~# ethtool -x eth0
RX flow hash indirection table for eth0 with 8 RX ring(s):
    0:      0     1     2     3     4     5     6     7
RSS hash key:
11:63:99:bb:79:fb:a5:a7:07:45:b2:20:bf:02:42:2d:08:1a:dd:19:2b:6b:23:ac:56:28:9d:70:c3:ac:e8:16:4b:b7:c1:10:53:a4:78:41

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 Documentation/sysctl/net.txt | 22 ++++++++++++++++++++++
 include/linux/netdevice.h    |  6 ++++++
 net/core/ethtool.c           | 11 +++++++++++
 net/core/sysctl_net_core.c   | 19 +++++++++++++++++++
 4 files changed, 58 insertions(+)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index e26c607468a6..666594b43cff 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -142,6 +142,28 @@ netdev_max_backlog
 Maximum number  of  packets,  queued  on  the  INPUT  side, when the interface
 receives packets faster than kernel can process them.
 
+netdev_rss_key
+--------------
+
+RSS (Receive Side Scaling) enabled drivers use a 40 bytes host key that is
+randomly generated.
+Some user space might need to gather its content even if drivers do not
+provide ethtool -x support yet.
+
+myhost:~# cat /proc/sys/net/core/netdev_rss_key
+84:50:f4:00:a8:15:d1:a7:e9:7f:1d:60:35:c7:47:25:42:97:74:ca:56:bb:b6:a1:d8: ... (52 bytes total)
+
+File contains nul bytes if no driver ever called netdev_rss_key_fill() function.
+Note:
+/proc/sys/net/core/netdev_rss_key contains 52 bytes of key,
+but most drivers only use 40 bytes of it.
+
+myhost:~# ethtool -x eth0
+RX flow hash indirection table for eth0 with 8 RX ring(s):
+    0:    0     1     2     3     4     5     6     7
+RSS hash key:
+84:50:f4:00:a8:15:d1:a7:e9:7f:1d:60:35:c7:47:25:42:97:74:ca:56:bb:b6:a1:d8:43:e3:c9:0c:fd:17:55:c2:3a:4d:69:ed:f1:42:89
+
 netdev_tstamp_prequeue
 ----------------------
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4a6f770377d3..db63cf459ba1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3422,6 +3422,12 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 void netdev_adjacent_rename_links(struct net_device *dev, char *oldname);
 void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev);
+
+/* RSS keys are 40 or 52 bytes long */
+#define NETDEV_RSS_KEY_LEN 52
+extern u8 netdev_rss_key[NETDEV_RSS_KEY_LEN];
+void netdev_rss_key_fill(void *buffer, size_t len);
+
 int dev_get_nest_level(struct net_device *dev,
 		       bool (*type_check)(struct net_device *dev));
 int skb_checksum_help(struct sk_buff *skb);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b0f84f5ddda8..715f51f321e9 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -25,6 +25,7 @@
 #include <linux/slab.h>
 #include <linux/rtnetlink.h>
 #include <linux/sched.h>
+#include <linux/net.h>
 
 /*
  * Some useful ethtool_ops methods that're device independent.
@@ -573,6 +574,16 @@ static int ethtool_copy_validate_indir(u32 *indir, void __user *useraddr,
 	return 0;
 }
 
+u8 netdev_rss_key[NETDEV_RSS_KEY_LEN];
+
+void netdev_rss_key_fill(void *buffer, size_t len)
+{
+	BUG_ON(len > sizeof(netdev_rss_key));
+	net_get_random_once(netdev_rss_key, sizeof(netdev_rss_key));
+	memcpy(buffer, netdev_rss_key, len);
+}
+EXPORT_SYMBOL(netdev_rss_key_fill);
+
 static noinline_for_stack int ethtool_get_rxfh_indir(struct net_device *dev,
 						     void __user *useraddr)
 {
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index f93f092fe226..31baba2a71ce 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -217,6 +217,18 @@ static int set_default_qdisc(struct ctl_table *table, int write,
 }
 #endif
 
+static int proc_do_rss_key(struct ctl_table *table, int write,
+			   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table fake_table;
+	char buf[NETDEV_RSS_KEY_LEN * 3];
+
+	snprintf(buf, sizeof(buf), "%*phC", NETDEV_RSS_KEY_LEN, netdev_rss_key);
+	fake_table.data = buf;
+	fake_table.maxlen = sizeof(buf);
+	return proc_dostring(&fake_table, write, buffer, lenp, ppos);
+}
+
 static struct ctl_table net_core_table[] = {
 #ifdef CONFIG_NET
 	{
@@ -265,6 +277,13 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "netdev_rss_key",
+		.data		= &netdev_rss_key,
+		.maxlen		= sizeof(int),
+		.mode		= 0444,
+		.proc_handler	= proc_do_rss_key,
+	},
 #ifdef CONFIG_BPF_JIT
 	{
 		.procname	= "bpf_jit_enable",
-- 
2.1.0.rc2.206.gedb03e5
