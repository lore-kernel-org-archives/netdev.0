From: Rahul Jain <rahul.jain@samsung.com>
Subject: [PATCH] net : To avoid execution of extra instructions in NET RX path
 when rps_map is not set but rps_needed is true.
Date: Wed, 09 Dec 2015 16:05:21 +0530
Message-ID: <1449657321-3797-1-git-send-email-rahul.jain@samsung.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	k.ashutosh@samsung.com
To: davem@davemloft.net, edumazet@google.com, ast@plumgrid.com,
	jiri@mellanox.com, daniel@iogearbox.net,
	makita.toshiaki@lab.ntt.co.jp, noureddine@arista.com,
	herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ashutosh Kaushik <k.ashutosh@samsung.com>

The patch fixes the issues with check of global flag "rps_needed" in RX Path (which process packets in TCP/IP stack like netif_rx and netif_receive_skb functions)
These functions have flag CONFIG RPS which is enabled default in kernel and to enter in RPS mode, it depends on variable rps_needed.
This variable is updated whenever value in /sys/class/net/<device>/queues/rx-0/rps_cpus is being changed.
There are 2 scenarios where it is executing extra piece of code even when results would be same every time:-

1) Suppose in system more than one networking devices are connected i.e. wired (eth0) and wireless (wlan0). 
   If I enable RPS using above method for wlan0, then it sets atomic variable in rps_needed flag which is global.
   Now,whenever traffic uses wired network, then it will execute that extra piece of code in RX path because of only dependency on global rps_needed variable as below:
  #ifdef CONFIG_RPS
        if (static_key_false(&rps_needed)) {
                struct rps_dev_flow voidflow, *rflow = &voidflow;
                int cpu = get_rps_cpu(skb->dev, skb, &rflow);

                if (cpu >= 0) {
                        ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
                        rcu_read_unlock();
                        return ret;
                }
        }
  #endif
 
	while every time, value returned from get_rps_cpu will be < 0 as rps_map value is not set for this network device using /sys/class/net/device/queues/rx-0/rps_cpus.
	And it will every time execute get_rps_cpu function with fail case in IF condition which will be an extra overhead for packet processing.
	
2) Another scenario is as: Suppose that we have enable RPS for wireless device say wlan0 using above specified method which will set value of rps_needed. 
   After doing test with set value of rps_cpus in sysfs, we do rmmod driver of wireless device.
   Next time again when we do insmod without rebooting system, it always hit below code with fail case:
   #ifdef CONFIG_RPS
        if (static_key_false(&rps_needed)) {
                struct rps_dev_flow voidflow, *rflow = &voidflow;
                int cpu;

                preempt_disable();
                rcu_read_lock();

                cpu = get_rps_cpu(skb->dev, skb, &rflow);
                if (cpu < 0)
                        cpu = smp_processor_id();

                ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);

                rcu_read_unlock();
                preempt_enable();
        } else
   #endif
   The reason behind this overhead of hitting this code with false case is same because before doing rmmod, we enabled RPS which set rps_needed flag.
   Next time when we do insmod, it will just create entry for network device in sysfs with default value which is 0 for rps_cpus. It implies that RPS is disable for that device.
   But due to unchanged value of rps_needed variable, it goes into IF condition every time (which is failed in get_rps_cpu function) even rps_cpus is 0.
   Because if we do not enable RPS for that network device, rps_map is not set.
   
The patch adds a check to these two RX functions which will check RPS availability locally for device specific.
 
Signed-off-by: Ashutosh Kaushik <k.ashutosh@samsung.com>
---
 net/core/dev.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5df6cbc..1aa4402 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3531,12 +3531,14 @@ drop:
 static int netif_rx_internal(struct sk_buff *skb)
 {
 	int ret;
+	struct netdev_rx_queue *dev_rxqueue = skb->dev->_rx;
 
 	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
 	trace_netif_rx(skb);
 #ifdef CONFIG_RPS
-	if (static_key_false(&rps_needed)) {
+	if (static_key_false(&rps_needed) &&
+	    dev_rxqueue->rps_map && dev_rxqueue->rps_map->len) {
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
 		int cpu;
 
@@ -3986,6 +3988,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 static int netif_receive_skb_internal(struct sk_buff *skb)
 {
 	int ret;
+	struct netdev_rx_queue *dev_rxqueue = skb->dev->_rx;
 
 	net_timestamp_check(netdev_tstamp_prequeue, skb);
 
@@ -3995,7 +3998,8 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
 	rcu_read_lock();
 
 #ifdef CONFIG_RPS
-	if (static_key_false(&rps_needed)) {
+	if (static_key_false(&rps_needed) &&
+	    dev_rxqueue->rps_map && dev_rxqueue->rps_map->len) {
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
 		int cpu = get_rps_cpu(skb->dev, skb, &rflow);
 
-- 
1.9.1
