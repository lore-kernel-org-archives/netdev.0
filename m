From: <liujian56@huawei.com>
Subject: [PATCH] tcp: TCP_USER_TIMEOUT can not work in tcp_probe_timer()
Date: Mon, 11 Sep 2017 14:27:42 +0800
Message-ID: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <liujian56@huawei.com>,
        <weiyongjun1@huawei.com>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
        <yoshfuji@linux-ipv6.org>, <edumazet@google.com>,
        <ycheng@google.com>, <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:6002 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750742AbdIKG3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 02:29:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: liujian <liujian56@huawei.com>

After the tcp socket go to ESTABLISHED stat, change IP address (server
side),
then the tcp socket will go tcp_probe_timer process.

[root@localhost net]# netstat -toe
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      Timer
tcp        0   1104 9.81.254:personal-agent 9.84.201.213:23597      ESTABLISHED root       12819      probe (4.36/0/7)
[root@localhost net]# cat /proc/net/tcp
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode                                                     
   3: B1FE5109:15B3 D5C95409:5C2D 01 00000495:00000000 04:0000005E 00000000     0        7 12819 2 ffff95cdcf45a000 20 4 1 10 -1 

In my test case, tcp_write_queue_head(sk) and tcp_send_head(sk) is  same
SKB.
And ((s32)(tcp_time_stamp(tp) - start_ts) >
jiffies_to_msecs(icsk->icsk_user_timeout))
 always is false.
 Here use keepalive_time_elapsed(tp) to do the compare as
tcp_keepalive_timer do.

Signed-off-by: liujian <liujian56@huawei.com>
---
 net/ipv4/tcp_timer.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 655dd8d..2a28a03 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -325,7 +325,7 @@ static void tcp_probe_timer(struct sock *sk)
 	if (!start_ts)
 		tcp_send_head(sk)->skb_mstamp = tp->tcp_mstamp;
 	else if (icsk->icsk_user_timeout &&
-		 (s32)(tcp_time_stamp(tp) - start_ts) >
+		 keepalive_time_elapsed(tp) >=
 		 jiffies_to_msecs(icsk->icsk_user_timeout))
 		goto abort;
 
-- 
1.8.3.1
