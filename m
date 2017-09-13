From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: gen_estimator: fix scaling error in
 bytes/packets samples
Date: Wed, 13 Sep 2017 11:16:45 -0700
Message-ID: <1505326605.15310.193.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
         <d2aee52fda21d8f668ca012333ef3677@nuclearcat.com>
         <1505319370.15310.169.camel@edumazet-glaptop3.roam.corp.google.com>
         <9b8cdc2b39fdd2d0be7b5f559b2034e7@nuclearcat.com>
         <1505320949.15310.173.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37693 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751312AbdIMSQr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 14:16:47 -0400
Received: by mail-pg0-f68.google.com with SMTP id v5so460772pgn.4
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 11:16:47 -0700 (PDT)
In-Reply-To: <1505320949.15310.173.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Denys reported wrong rate estimations with HTB classes.

It appears the bug was added in linux-4.10, since my tests
where using intervals of one second only.

HTB using 4 sec default rate estimators, reported rates
were 4x higher.

We need to properly scale the bytes/packets samples before
integrating them in EWMA.

Tested:
 echo 1 >/sys/module/sch_htb/parameters/htb_rate_est

 Setup HTB with one class with a rate/cail of 5Gbit

 Generate traffic on this class

 tc -s -d cl sh dev eth0 classid 7002:11 
class htb 7002:11 parent 7002:1 prio 5 quantum 200000 rate 5Gbit ceil
5Gbit linklayer ethernet burst 80000b/1 mpu 0b cburst 80000b/1 mpu 0b
level 0 rate_handle 1 
 Sent 1488215421648 bytes 982969243 pkt (dropped 0, overlimits 0
requeues 0) 
 rate 5Gbit 412814pps backlog 136260b 2p requeues 0 
 TCP pkts/rtx 982969327/45 bytes 1488215557414/68130
 lended: 22732826 borrowed: 0 giants: 0
 tokens: -1684 ctokens: -1684
 
Fixes: 1c0d32fde5bd ("net_sched: gen_estimator: complete rewrite of rate estimators")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
---
 net/core/gen_estimator.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 0385dece1f6fe5e26df1ce5f40956a79a2eebbf4..7c1ffd6f950172c1915d8e5fa2b5e3f77e4f4c78 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -83,10 +83,10 @@ static void est_timer(unsigned long arg)
 	u64 rate, brate;
 
 	est_fetch_counters(est, &b);
-	brate = (b.bytes - est->last_bytes) << (8 - est->ewma_log);
+	brate = (b.bytes - est->last_bytes) << (10 - est->ewma_log - est->intvl_log);
 	brate -= (est->avbps >> est->ewma_log);
 
-	rate = (u64)(b.packets - est->last_packets) << (8 - est->ewma_log);
+	rate = (u64)(b.packets - est->last_packets) << (10 - est->ewma_log - est->intvl_log);
 	rate -= (est->avpps >> est->ewma_log);
 
 	write_seqcount_begin(&est->seq);
