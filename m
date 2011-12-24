From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] rfs: better sizing of dev_flow_table
Date: Sat, 24 Dec 2011 17:56:49 +0100
Message-ID: <1324745809.2915.52.camel@edumazet-laptop>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
	 <4EF3BEBA.4040402@gmail.com> <1324613414.2674.2.camel@edumazet-laptop>
	 <C0DC969A-A32B-4CC8-B565-FF741E9D75DA@gmail.com>
	 <1324616007.2674.8.camel@edumazet-laptop>
	 <ACB00AE8-CFEF-4535-9242-1B5C44F05C13@gmail.com>
	 <1324617390.2674.13.camel@edumazet-laptop>
	 <1324618555.10854.4.camel@edumazet-laptop>
	 <4DA4756B-0654-49F4-B135-9A9F89BC7D21@gmail.com>
	 <1324645592.2223.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <EC59D18E-82F6-4409-BB29-D7434D63B0C9@gmail.com>
	 <1324652031.2223.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <C6E2C6E1-A4DA-45F8-A94F-D3B78AFA018F@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Laurent Chavey <chavey@google.com>, Xi Wang <xi.wang@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:51028 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906Ab1LXQ4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Dec 2011 11:56:55 -0500
Received: by werm1 with SMTP id m1so4455722wer.19
        for <netdev@vger.kernel.org>; Sat, 24 Dec 2011 08:56:54 -0800 (PST)
In-Reply-To: <C6E2C6E1-A4DA-45F8-A94F-D3B78AFA018F@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Aim of this patch is to provide full range of rps_flow_cnt on 64bit arches.

Theorical limit on number of flows is 2^32

Fix some buggy RPS/RFS macros as well.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
CC: Xi Wang <xi.wang@gmail.com>
CC: Laurent Chavey <chavey@google.com>
---
 include/linux/netdevice.h |    8 +++---
 net/core/net-sysfs.c      |   44 ++++++++++++++++++++++--------------
 2 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6037308..a776a67 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -597,7 +597,7 @@ struct rps_map {
 	struct rcu_head rcu;
 	u16 cpus[0];
 };
-#define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + (_num * sizeof(u16)))
+#define RPS_MAP_SIZE(_num) (sizeof(struct rps_map) + ((_num) * sizeof(u16)))
 
 /*
  * The rps_dev_flow structure contains the mapping of a flow to a CPU, the
@@ -621,7 +621,7 @@ struct rps_dev_flow_table {
 	struct rps_dev_flow flows[0];
 };
 #define RPS_DEV_FLOW_TABLE_SIZE(_num) (sizeof(struct rps_dev_flow_table) + \
-    (_num * sizeof(struct rps_dev_flow)))
+    ((_num) * sizeof(struct rps_dev_flow)))
 
 /*
  * The rps_sock_flow_table contains mappings of flows to the last CPU
@@ -632,7 +632,7 @@ struct rps_sock_flow_table {
 	u16 ents[0];
 };
 #define	RPS_SOCK_FLOW_TABLE_SIZE(_num) (sizeof(struct rps_sock_flow_table) + \
-    (_num * sizeof(u16)))
+    ((_num) * sizeof(u16)))
 
 #define RPS_NO_CPU 0xffff
 
@@ -684,7 +684,7 @@ struct xps_map {
 	struct rcu_head rcu;
 	u16 queues[0];
 };
-#define XPS_MAP_SIZE(_num) (sizeof(struct xps_map) + (_num * sizeof(u16)))
+#define XPS_MAP_SIZE(_num) (sizeof(struct xps_map) + ((_num) * sizeof(u16)))
 #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map))	\
     / sizeof(u16))
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 4b4d0b0..abf4393 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -622,15 +622,15 @@ static ssize_t show_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 					   char *buf)
 {
 	struct rps_dev_flow_table *flow_table;
-	unsigned int val = 0;
+	unsigned long val = 0;
 
 	rcu_read_lock();
 	flow_table = rcu_dereference(queue->rps_flow_table);
 	if (flow_table)
-		val = flow_table->mask + 1;
+		val = (unsigned long)flow_table->mask + 1;
 	rcu_read_unlock();
 
-	return sprintf(buf, "%u\n", val);
+	return sprintf(buf, "%lu\n", val);
 }
 
 static void rps_dev_flow_table_release_work(struct work_struct *work)
@@ -654,36 +654,46 @@ static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 				     struct rx_queue_attribute *attr,
 				     const char *buf, size_t len)
 {
-	unsigned int count;
-	char *endp;
+	unsigned long mask, count;
 	struct rps_dev_flow_table *table, *old_table;
 	static DEFINE_SPINLOCK(rps_dev_flow_lock);
+	int rc;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	count = simple_strtoul(buf, &endp, 0);
-	if (endp == buf)
-		return -EINVAL;
+	rc = kstrtoul(buf, 0, &count);
+	if (rc < 0)
+		return rc;
 
 	if (count) {
-		int i;
-
-		if (count > INT_MAX)
+		mask = count - 1;
+		/* mask = roundup_pow_of_two(count) - 1;
+		 * without overflows...
+		 */
+		while ((mask | (mask >> 1)) != mask)
+			mask |= (mask >> 1);
+		/* On 64 bit arches, must check mask fits in table->mask (u32),
+		 * and on 32bit arches, must check RPS_DEV_FLOW_TABLE_SIZE(mask + 1)
+		 * doesnt overflow.
+		 */
+#if BITS_PER_LONG > 32
+		if (mask > (unsigned long)(u32)mask)
 			return -EINVAL;
-		count = roundup_pow_of_two(count);
-		if (count > (ULONG_MAX - sizeof(struct rps_dev_flow_table))
+#else
+		if (mask > (ULONG_MAX - RPS_DEV_FLOW_TABLE_SIZE(1))
 				/ sizeof(struct rps_dev_flow)) {
 			/* Enforce a limit to prevent overflow */
 			return -EINVAL;
 		}
-		table = vmalloc(RPS_DEV_FLOW_TABLE_SIZE(count));
+#endif
+		table = vmalloc(RPS_DEV_FLOW_TABLE_SIZE(mask + 1));
 		if (!table)
 			return -ENOMEM;
 
-		table->mask = count - 1;
-		for (i = 0; i < count; i++)
-			table->flows[i].cpu = RPS_NO_CPU;
+		table->mask = mask;
+		for (count = 0; count <= mask; count++)
+			table->flows[count].cpu = RPS_NO_CPU;
 	} else
 		table = NULL;
 
