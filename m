From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Wed, 17 Mar 2010 16:50:16 -0700
Message-ID: <4BA16AB8.3090800@google.com>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>	 <4B9FC7F1.5010507@google.com>	 <1268773227.2932.34.camel@edumazet-laptop>	 <20100316.141311.262178287.davem@davemloft.net>	 <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>	 <1268809673.2932.62.camel@edumazet-laptop>	 <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>	 <1268834957.2899.352.camel@edumazet-laptop> <65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:8239 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754320Ab0CQXuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 19:50:23 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o2HNoM1N022857
	for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 16:50:22 -0700
Received: from qw-out-1920.google.com (qwc5.prod.google.com [10.241.193.133])
	by kpbe14.cbf.corp.google.com with ESMTP id o2HNo0T4006964
	for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 16:50:21 -0700
Received: by qw-out-1920.google.com with SMTP id 5so239323qwc.34
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 16:50:20 -0700 (PDT)
In-Reply-To: <65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>
>> # echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps_map
>> # cat /sys/class/net/eth0/queues/rx-0/rps_cpus
>> 3
>> # cat /sys/class/net/eth0/queues/rx-0/rps_map
>> 0 1 0 1 0 1 1 1 1 1
>> # echo 3 >/sys/class/net/eth0/queues/rx-0/rps_cpus
>> # cat /sys/class/net/eth0/queues/rx-0/rps_map
>> 0 1
> 
> Alternatively, the rps_map could be specified explicitly, which will
> allow weighting.  For example "0 0 0 0 2 10 10 10"  would select CPUs
> 0, 2, 10 for the map with weights four, one, and three respectively.
> This would go back to have sysfs files with multiple values in them,
> so it might not be the right interface.

Here is a patch for this...

Allow specification of CPUs in rps to be done with a vector instead of a bit map.  This allows relative weighting of CPUs in the map by repeating ones to give higher weight.

For example "echo 0 0 0 3 4 4 4 4 > /sys/class/net/eth0/queues/rx-0/rps_cpus"

assigns CPUs 0, 3, and 4 to the RPS mask with relative weights 3, 1, and 4 respectively.

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7a46343..41956a5 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -17,6 +17,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/wireless.h>
 #include <net/wext.h>
+#include <linux/ctype.h>
 
 #include "net-sysfs.h"
 
@@ -514,30 +515,20 @@ static ssize_t show_rps_map(struct netdev_rx_queue *queue,
 			    struct rx_queue_attribute *attribute, char *buf)
 {
 	struct rps_map *map;
-	cpumask_var_t mask;
 	size_t len = 0;
 	int i;
 
-	if (!zalloc_cpumask_var(&mask, GFP_KERNEL))
-		return -ENOMEM;
-
 	rcu_read_lock();
+
 	map = rcu_dereference(queue->rps_map);
 	if (map)
 		for (i = 0; i < map->len; i++)
-			cpumask_set_cpu(map->cpus[i], mask);
+			len += snprintf(buf + len, PAGE_SIZE - len, "%u%s",
+			    map->cpus[i], i + 1 < map->len ? " " : "\n");
 
-	len += cpumask_scnprintf(buf + len, PAGE_SIZE, mask);
-	if (PAGE_SIZE - len < 3) {
-		rcu_read_unlock();
-		free_cpumask_var(mask);
-		return -EINVAL;
-	}
 	rcu_read_unlock();
 
-	free_cpumask_var(mask);
-	len += sprintf(buf + len, "\n");
-	return len;
+	return len < PAGE_SIZE ? len : -EINVAL;
 }
 
 static void rps_map_release(struct rcu_head *rcu)
@@ -552,41 +543,50 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
 		      const char *buf, size_t len)
 {
 	struct rps_map *old_map, *map;
-	cpumask_var_t mask;
-	int err, cpu, i;
+	int i, count = 0;
+	unsigned int val;
 	static DEFINE_SPINLOCK(rps_map_lock);
+	char *tbuf;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
-		return -ENOMEM;
+	/* Validate and count the number of CPUs in the input list. */
+	tbuf = (char *)buf;
+	while (tbuf < buf + len) {
+		char *rbuf;
 
-	err = bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits);
-	if (err) {
-		free_cpumask_var(mask);
-		return err;
-	}
+		if (isspace(*tbuf)) {
+			tbuf++;
+			continue;
+		}
 
-	map = kzalloc(max_t(unsigned,
-	    RPS_MAP_SIZE(cpumask_weight(mask)), L1_CACHE_BYTES),
-	    GFP_KERNEL);
-	if (!map) {
-		free_cpumask_var(mask);
-		return -ENOMEM;
-	}
+		val = simple_strtoul(tbuf, &rbuf, 0);
 
-	i = 0;
-	for_each_cpu_and(cpu, mask, cpu_online_mask)
-		map->cpus[i++] = cpu;
+		if ((tbuf == rbuf) || (val >= num_possible_cpus()))
+			return -EINVAL;
 
-	if (i)
-		map->len = i;
-	else {
-		kfree(map);
-		map = NULL;
+		tbuf = rbuf;
+		count++;
 	}
 
+	if (count) {
+		map = kzalloc(max_t(unsigned, RPS_MAP_SIZE(count),
+		    L1_CACHE_BYTES), GFP_KERNEL);
+		if (!map)
+			return -ENOMEM;
+
+		tbuf = (char *)buf;
+		for (i = 0; i < count; i++) {
+			while (isspace(*tbuf))
+				tbuf++;
+			map->cpus[i] = simple_strtoul(tbuf, &tbuf, 0);
+		}
+		map->len = count;
+	} else
+		map = NULL;
+
+
 	spin_lock(&rps_map_lock);
 	old_map = queue->rps_map;
 	rcu_assign_pointer(queue->rps_map, map);
@@ -595,7 +595,6 @@ ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	if (old_map)
 		call_rcu(&old_map->rcu, rps_map_release);
 
-	free_cpumask_var(mask);
 	return len;
 }
