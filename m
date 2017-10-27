From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: refresh tp timestamp before tcp_mtu_probe()
Date: Thu, 26 Oct 2017 21:21:40 -0700
Message-ID: <1509078100.11887.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:43325 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdJ0EVm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:21:42 -0400
Received: by mail-pf0-f193.google.com with SMTP id a8so4078103pfc.0
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:21:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In the unlikely event tcp_mtu_probe() is sending a packet, we
want tp->tcp_mstamp being as accurate as possible. 

This means we need to call tcp_mstamp_refresh() a bit earlier in
tcp_write_xmit().

Fixes: 385e20706fac ("tcp: use tp->tcp_mstamp in output path")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1151870018e345592853b035a0902121c41e268d..ae60dd3faed0adc71731bc686f878afd4c628d32 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2239,6 +2239,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 
 	sent_pkts = 0;
 
+	tcp_mstamp_refresh(tp);
 	if (!push_one) {
 		/* Do MTU probing. */
 		result = tcp_mtu_probe(sk);
@@ -2250,7 +2251,6 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	}
 
 	max_segs = tcp_tso_segs(sk, mss_now);
-	tcp_mstamp_refresh(tp);
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
