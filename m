From: Liping Zhang <zlpnobody@163.com>
Subject: [PATCH net-next] net: rps: don't skip offline cpus when set rps_cpus
Date: Mon, 15 May 2017 20:55:52 +0800
Message-ID: <20170515125552.2971-1-zlpnobody@163.com>
Cc: netdev@vger.kernel.org, therbert@google.com,
        Liping Zhang <zlpnobody@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:48993 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932721AbdEOM4k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 08:56:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

On our 4-core system, sometimes I can enable all CPUs to process packets.
But sometimes I can't, if all the CPUs become offline except core 0, I
will get the following result, which is really annoying for my script:
 # echo f > /sys/class/net/eth0/queues/rx-0/rps_cpus
 # cat /sys/class/net/eth0/queues/rx-0/rps_cpus
 1

Since we won't steer the packets to these offline cpus, it's reasonable
to enable all configed cpus to the rps_map, even if they are offline for
the time being.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
---
 net/core/net-sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 65ea0ff..8adb36d 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -731,7 +731,7 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	}
 
 	i = 0;
-	for_each_cpu_and(cpu, mask, cpu_online_mask)
+	for_each_cpu_and(cpu, mask, cpu_possible_mask)
 		map->cpus[i++] = cpu;
 
 	if (i)
-- 
2.9.3
