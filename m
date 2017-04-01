From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] tcp: minimize false-positives on TCP/GRO check
Date: Sat,  1 Apr 2017 11:00:21 -0300
Message-ID: <47c94077ffa8988118a19514389b42fccdc2f6ef.1491054871.git.marcelo.leitner@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Jon Maxwell <jmaxwell37@gmail.com>,
        Markus Trippelsdorf <markus@trippelsdorf.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33429 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751437AbdDAOAj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 10:00:39 -0400
Received: by mail-qk0-f195.google.com with SMTP id p22so13875821qka.0
        for <netdev@vger.kernel.org>; Sat, 01 Apr 2017 07:00:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Trippelsdorf reported that after commit dcb17d22e1c2 ("tcp: warn
on bogus MSS and try to amend it") the kernel started logging the
warning for a NIC driver that doesn't even support GRO.

It was diagnosed that it was possibly caused on connections that were
using TCP Timestamps but some packets lacked the Timestamps option. As
we reduce rcv_mss when timestamps are used, the lack of them would cause
the packets to be bigger than expected, although this is a valid case.

As this warning is more as a hint, getting a clean-cut on the
threshold is probably not worth the execution time spent on it. This
patch thus alleviates the false-positives with 2 quick checks: by
accounting for the entire TCP option space and also checking against the
interface MTU if it's available.

These changes, specially the MTU one, might mask some real positives,
though if they are really happening, it's possible that sooner or later
it will be triggered anyway.

Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/ipv4/tcp_input.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c43119726a62e494063fd940001b483215d0fe26..97ac6776e47d36ea5c59051714a0f77e3eeb46fc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -126,7 +126,8 @@ int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 #define REXMIT_LOST	1 /* retransmit packets marked lost */
 #define REXMIT_NEW	2 /* FRTO-style transmit of unsent/new packets */
 
-static void tcp_gro_dev_warn(struct sock *sk, const struct sk_buff *skb)
+static void tcp_gro_dev_warn(struct sock *sk, const struct sk_buff *skb,
+			     unsigned int len)
 {
 	static bool __once __read_mostly;
 
@@ -137,8 +138,9 @@ static void tcp_gro_dev_warn(struct sock *sk, const struct sk_buff *skb)
 
 		rcu_read_lock();
 		dev = dev_get_by_index_rcu(sock_net(sk), skb->skb_iif);
-		pr_warn("%s: Driver has suspect GRO implementation, TCP performance may be compromised.\n",
-			dev ? dev->name : "Unknown driver");
+		if (!dev || len >= dev->mtu)
+			pr_warn("%s: Driver has suspect GRO implementation, TCP performance may be compromised.\n",
+				dev ? dev->name : "Unknown driver");
 		rcu_read_unlock();
 	}
 }
@@ -161,8 +163,10 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 	if (len >= icsk->icsk_ack.rcv_mss) {
 		icsk->icsk_ack.rcv_mss = min_t(unsigned int, len,
 					       tcp_sk(sk)->advmss);
-		if (unlikely(icsk->icsk_ack.rcv_mss != len))
-			tcp_gro_dev_warn(sk, skb);
+		/* Account for possibly-removed options */
+		if (unlikely(len > icsk->icsk_ack.rcv_mss +
+				   MAX_TCP_OPTION_SPACE))
+			tcp_gro_dev_warn(sk, skb, len);
 	} else {
 		/* Otherwise, we make more careful check taking into account,
 		 * that SACKs block is variable.
-- 
2.9.3
