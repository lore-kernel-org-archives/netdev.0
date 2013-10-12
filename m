From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: fix incorrect ca_state in tail loss probe
Date: Sat, 12 Oct 2013 10:16:27 -0700
Message-ID: <1381598187-9681-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, michael@sterretts.net,
	jwboyer@fedoraproject.org, sesse@google.com, dormando@rydia.net,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f74.google.com ([209.85.160.74]:35839 "EHLO
	mail-pb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493Ab3JLRRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 13:17:18 -0400
Received: by mail-pb0-f74.google.com with SMTP id rq2so543459pbb.1
        for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 10:17:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On receiving an ACK that covers the loss probe sequence, TLP
immediately sets the congestion state to Open, even though some packets
are not recovered and retransmisssion are on the way.  The later ACks
may trigger a WARN_ON check in step D of tcp_fastretrans_alert(), e.g.,
https://bugzilla.redhat.com/show_bug.cgi?id=989251

The fix is to follow the similar procedure in recovery by calling
tcp_try_keep_open(). The sender switches to Open state if no packets
are retransmissted. Otherwise it goes to Disorder and let subsequent
ACKs move the state to Recovery or Open.

Reported-By: Michael Sterrett <michael@sterretts.net>
Tested-By: Dormando <dormando@rydia.net>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 113dc5f..53974c7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3291,7 +3291,7 @@ static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag)
 			tcp_init_cwnd_reduction(sk, true);
 			tcp_set_ca_state(sk, TCP_CA_CWR);
 			tcp_end_cwnd_reduction(sk);
-			tcp_set_ca_state(sk, TCP_CA_Open);
+			tcp_try_keep_open(sk);
 			NET_INC_STATS_BH(sock_net(sk),
 					 LINUX_MIB_TCPLOSSPROBERECOVERY);
 		}
-- 
1.8.4
