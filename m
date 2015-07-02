From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: gen_estimator: extend pps limit
Date: Thu, 02 Jul 2015 15:57:19 +0200
Message-ID: <1435845439.11970.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37926 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbbGBN50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 09:57:26 -0400
Received: by wibdq8 with SMTP id dq8so74498244wib.1
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 06:57:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

rate estimators are limited to 4 Mpps, which was fine years ago, but
too small with current hardware generation.

Lets use 2^5 scaling instead of 2^10 to get 128 Mpps new limit.

On 64bit arch, use an "unsigned long" for temp storage and remove limit.
(We do not expect 32bit arches to be able to reach this point)

Tested:

tc -s -d filter sh dev eth0 parent ffff:

filter protocol ip pref 1 u32 
filter protocol ip pref 1 u32 fh 800: ht divisor 1 
filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:15 
  match 07000000/ff000000 at 12
	action order 1: gact action drop
	 random type none pass val 0
	 index 1 ref 1 bind 1 installed 166 sec
 	Action statistics:
	Sent 39734251496 bytes 863788076 pkt (dropped 863788117, overlimits 0 requeues 0) 
	rate 4067Mbit 11053596pps backlog 0b 0p requeues 0 

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/gen_estimator.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 9dfb88a933e7..92d886f4adcb 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -66,7 +66,7 @@
 
    NOTES.
 
-   * avbps is scaled by 2^5, avpps is scaled by 2^10.
+   * avbps and avpps are scaled by 2^5.
    * both values are reported as 32 bit unsigned values. bps can
      overflow for fast links : max speed being 34360Mbit/sec
    * Minimal interval is HZ/4=250msec (it is the greatest common divisor
@@ -85,10 +85,10 @@ struct gen_estimator
 	struct gnet_stats_rate_est64	*rate_est;
 	spinlock_t		*stats_lock;
 	int			ewma_log;
+	u32			last_packets;
+	unsigned long		avpps;
 	u64			last_bytes;
 	u64			avbps;
-	u32			last_packets;
-	u32			avpps;
 	struct rcu_head		e_rcu;
 	struct rb_node		node;
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
@@ -118,8 +118,8 @@ static void est_timer(unsigned long arg)
 	rcu_read_lock();
 	list_for_each_entry_rcu(e, &elist[idx].list, list) {
 		struct gnet_stats_basic_packed b = {0};
+		unsigned long rate;
 		u64 brate;
-		u32 rate;
 
 		spin_lock(e->stats_lock);
 		read_lock(&est_lock);
@@ -133,10 +133,11 @@ static void est_timer(unsigned long arg)
 		e->avbps += (brate >> e->ewma_log) - (e->avbps >> e->ewma_log);
 		e->rate_est->bps = (e->avbps+0xF)>>5;
 
-		rate = (b.packets - e->last_packets)<<(12 - idx);
+		rate = b.packets - e->last_packets;
+		rate <<= (7 - idx);
 		e->last_packets = b.packets;
 		e->avpps += (rate >> e->ewma_log) - (e->avpps >> e->ewma_log);
-		e->rate_est->pps = (e->avpps+0x1FF)>>10;
+		e->rate_est->pps = (e->avpps + 0xF) >> 5;
 skip:
 		read_unlock(&est_lock);
 		spin_unlock(e->stats_lock);
