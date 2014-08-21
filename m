From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 2/2] net: exit busy loop when another process is runnable
Date: Thu, 21 Aug 2014 16:05:10 +0800
Message-ID: <1408608310-13579-2-git-send-email-jasowang@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408608310-13579-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rx busy loop does not scale well in the case when several parallel
sessions is active. This is because we keep looping even if there's
another process is runnable. For example, if that process is about to
send packet, keep busy polling in current process will brings extra
delay and damage the performance.

This patch solves this issue by exiting the busy loop when there's
another process is runnable in current cpu. Simple test that pin two
netperf sessions in the same cpu in receiving side shows obvious
improvement:

Before:
netperf -H 192.168.100.2 -T 0,0 -t TCP_RR -P 0 & \
netperf -H 192.168.100.2 -T 1,0 -t TCP_RR -P 0
16384  87380  1        1       10.00    15513.74
16384  87380
16384  87380  1        1       10.00    15092.78
16384  87380

After:
netperf -H 192.168.100.2 -T 0,0 -t TCP_RR -P 0 & \
netperf -H 192.168.100.2 -T 1,0 -t TCP_RR -P 0
16384  87380  1        1       10.00    23334.53
16384  87380
16384  87380  1        1       10.00    23327.58
16384  87380

Benchmark was done through two 8 cores Xeon machine back to back connected
with mlx4 through netperf TCP_RR test (busy_read were set to 50):

sessions/bytes/before/after/+improvement%/busy_read=0/
1/1/30062.10/30034.72/+0%/20228.96/
16/1/214719.83/307669.01/+43%/268997.71/
32/1/231252.81/345845.16/+49%/336157.442/
64/512/212467.39/373464.93/+75%/397449.375/

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/net/busy_poll.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 1d67fb6..8a33fb2 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -109,7 +109,8 @@ static inline bool sk_busy_loop(struct sock *sk, int nonblock)
 		cpu_relax();
 
 	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
-		 !need_resched() && !busy_loop_timeout(end_time));
+		 !need_resched() && !busy_loop_timeout(end_time) &&
+		 nr_running_this_cpu() < 2);
 
 	rc = !skb_queue_empty(&sk->sk_receive_queue);
 out:
-- 
1.8.3.1
