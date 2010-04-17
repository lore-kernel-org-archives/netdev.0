From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] TCP: avoid to send keepalive probes if it is receiving data
Date: Sat, 17 Apr 2010 14:28:25 -0300
Message-ID: <1271525305-28423-1-git-send-email-fleitner@redhat.com>
References: <20100416150644.GA2641@sysclose.org>
Cc: Flavio Leitner <fleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752902Ab0DQR3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Apr 2010 13:29:04 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o3HHT2Wg002940
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 13:29:02 -0400
In-Reply-To: <20100416150644.GA2641@sysclose.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 1122 says the following:
...
  Keep-alive packets MUST only be sent when no data or
  acknowledgement packets have been received for the
  connection within an interval.
...

Fix this by storing the timestamp of last received data
packet and checking for it when the keepalive timer expires.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 include/linux/tcp.h  |    1 +
 net/ipv4/tcp_input.c |    3 +++
 net/ipv4/tcp_timer.c |    8 ++++++++
 3 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..405678f 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -314,6 +314,7 @@ struct tcp_sock {
  	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
 	u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
+	u32	lrcvtime;	/* timestamp of last received data packet (for keepalives) */
 
 	/* Data for direct copy to user */
 	struct {
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f240f57..60d2980 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5391,6 +5391,8 @@ no_ack:
 				__kfree_skb(skb);
 			else
 				sk->sk_data_ready(sk, 0);
+
+			tp->lrcvtime = tcp_time_stamp;
 			return 0;
 		}
 	}
@@ -5421,6 +5423,7 @@ step5:
 
 	tcp_data_snd_check(sk);
 	tcp_ack_snd_check(sk);
+	tp->lrcvtime = tcp_time_stamp;
 	return 0;
 
 csum_error:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 8a0ab29..74dd804 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -554,6 +554,14 @@ static void tcp_keepalive_timer (unsigned long data)
 	if (tp->packets_out || tcp_send_head(sk))
 		goto resched;
 
+	elapsed = tcp_time_stamp - tp->lrcvtime;
+	
+	/* receiving data means alive */
+	if (elapsed < keepalive_time_when(tp)) {
+		elapsed = keepalive_time_when(tp) - elapsed;
+		goto resched;
+	}
+
 	elapsed = tcp_time_stamp - tp->rcv_tstamp;
 
 	if (elapsed >= keepalive_time_when(tp)) {
-- 
1.6.6.1

