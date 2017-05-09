From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: do not inherit mc_list from parent
Date: Tue, 09 May 2017 05:17:15 -0700
Message-ID: <1494332235.7796.70.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Pray3r <pray3r.z@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33729 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752049AbdEIMRR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 08:17:17 -0400
Received: by mail-pg0-f42.google.com with SMTP id u187so43529875pgb.0
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 05:17:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syzkaller found a way to trigger double frees from ip_mc_drop_socket()

It turns out that leave a copy of parent mc_list at accept() time,
which is very bad.

Very similar to commit 8b485ce69876 ("tcp: do not inherit
fastopen_req from parent")

Initial report from Pray3r, completed by Andrey one.
Thanks a lot to them !

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Pray3r <pray3r.z@gmail.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
---
Notes:
 - day-0 bug.
 - Not sure if it makes sense for TCP socket to be able to join MC
group ?

 net/ipv4/tcp_minisocks.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 717be4de53248352c758b50557987d898340dd4f..03035e2857fc8b6e4cd8af6e46e81048d4de9105 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -448,6 +448,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 		minmax_reset(&newtp->rtt_min, tcp_time_stamp, ~0U);
 		newicsk->icsk_rto = TCP_TIMEOUT_INIT;
 		newicsk->icsk_ack.lrcvtime = tcp_time_stamp;
+		newicsk->icsk_inet.mc_list = NULL;
 
 		newtp->packets_out = 0;
 		newtp->retrans_out = 0;
