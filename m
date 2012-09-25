From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH net-next] tcp: avoid tcp loop connection on lo device
Date: Tue, 25 Sep 2012 16:12:34 +0800
Message-ID: <50616772.8040704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:43720 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753726Ab2IYIMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 04:12:39 -0400
Received: by dady13 with SMTP id y13so285619dad.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 01:12:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tcp supports simultaneous Connection, but we meat odd phenomenon that tcp client can receive what 
send by itself. tcp client and tcp server communicate through loop device. tcp server selects
port 40000 to listen which is in local port range. But after tcp server program is killed, tcp client
still can connect successfully. 


  Client                    Server
connect  <-----OK--------->   listen:127.0.0.1,port:40000
send(d1) ----------------->   recv
recv(d2) <-----------------   send(d2)  
 

         -----------------    killed(40000 not listened)

connect  <-----OK--------->   
send(d1) ----------------->  
recv(d1) <-----------------  

The simultaneous connection has no meaning for lo device, and for this case,
tcp client don't know whether server is listen on port 40000.
Just fix it sending reset to keep consistent state machine.  


Reproduced step:
1. while true ; do  nc 127.0.0.1 40001 ;done
2.  ss -nt dst 127.0.0.1
    State      Recv-Q Send-Q                                  Local Address:Port                                    Peer Address:Port 
    ESTAB      0      0                                           127.0.0.1:40001                                      127.0.0.1:40001 


Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 net/ipv4/tcp_input.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e037697..a2f5a10 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5659,6 +5659,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	struct tcp_fastopen_cookie foc = { .len = -1 };
 	int saved_clamp = tp->rx_opt.mss_clamp;
+	struct inet_sock *isk = inet_sk(sk);
 
 	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0, &foc);
 
@@ -5832,8 +5833,13 @@ discard:
 	if (th->syn) {
 		/* We see SYN without ACK. It is attempt of
 		 * simultaneous connect with crossed SYNs.
-		 * Particularly, it can be connect to self.
+		 * But, avoid tcp loop connection on single socket.
 		 */
+
+		if (isk->inet_dport == isk->inet_sport &&
+		    isk->inet_saddr == isk->inet_daddr)
+			goto reset_and_undo;
+
 		tcp_set_state(sk, TCP_SYN_RECV);
 
 		if (tp->rx_opt.saw_tstamp) {
-- 
1.7.1
