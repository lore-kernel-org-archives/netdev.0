From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH tcp-2.6] [TCP]: Access to highest_sack obsoletes forward_cnt_hint
Date: Fri, 4 May 2007 10:01:00 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705040959010.4235@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-199635964-1178262060=:4235"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60860 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbXEDHBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 03:01:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-199635964-1178262060=:4235
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    1 -
 net/ipv4/tcp_output.c |   16 +++-------------
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 728321f..06c29a8 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -344,7 +344,6 @@ #endif
 
 	int     fastpath_cnt_hint;
 	int     retransmit_cnt_hint;
-	int     forward_cnt_hint;
 
 	u16	advmss;		/* Advertised MSS			*/
 	u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ac9362d..b4e4f4a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1942,27 +1942,17 @@ void tcp_xmit_retransmit_queue(struct so
 	if (tcp_may_send_now(sk))
 		return;
 
-	if (tp->forward_skb_hint) {
+	if (tp->forward_skb_hint)
 		skb = tp->forward_skb_hint;
-		packet_cnt = tp->forward_cnt_hint;
-	} else{
+	else
 		skb = tcp_write_queue_head(sk);
-		packet_cnt = 0;
-	}
 
 	tcp_for_write_queue_from(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
-		tp->forward_cnt_hint = packet_cnt;
 		tp->forward_skb_hint = skb;
 
-		/* Similar to the retransmit loop above we
-		 * can pretend that the retransmitted SKB
-		 * we send out here will be composed of one
-		 * real MSS sized packet because tcp_retransmit_skb()
-		 * will fragment it if necessary.
-		 */
-		if (++packet_cnt > tp->fackets_out)
+		if (after(TCP_SKB_CB(skb)->seq, tp->highest_sack))
 			break;
 
 		if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
-- 
1.4.2

---696243703-199635964-1178262060=:4235--
