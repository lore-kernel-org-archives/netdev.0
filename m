From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: timestamp SYN+DATA messages
Date: Sun, 09 Mar 2014 17:36:02 -0700
Message-ID: <1394411762.20149.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:57371 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaCJAgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 20:36:05 -0400
Received: by mail-pd0-f179.google.com with SMTP id w10so6347376pde.38
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 17:36:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

All skb in socket write queue should be properly timestamped.

In case of FastOpen, we special case the SYN+DATA 'message' as we
queue in socket wrote queue the two fallback skbs: 

1) SYN message by itself.
2) DATA segment by itself.

We should make sure these skbs have proper timestamps.

Add a WARN_ON_ONCE() to eventually catch future violations.

Fixes: 740b0f1841f6 ("tcp: switch rtt estimations to usec resolution")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c  |    1 +
 net/ipv4/tcp_output.c |    6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b99003f556d8..e1661f46fd19 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3067,6 +3067,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			flag |= FLAG_RETRANS_DATA_ACKED;
 		} else {
 			last_ackt = skb->skb_mstamp;
+			WARN_ON_ONCE(last_ackt.v64 == 0);
 			if (!first_ackt.v64)
 				first_ackt = last_ackt;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bc0fb0fc7552..a64c51d6f9b6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2972,6 +2972,12 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	tcp_connect_queue_skb(sk, data);
 	fo->copied = data->len;
 
+	/* syn_data is about to be sent, we need to take current time stamps
+	 * for the packets that are in write queue : SYN packet and DATA
+	 */
+	skb_mstamp_get(&syn->skb_mstamp);
+	data->skb_mstamp = syn->skb_mstamp;
+
 	if (tcp_transmit_skb(sk, syn_data, 0, sk->sk_allocation) == 0) {
 		tp->syn_data = (fo->copied > 0);
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPORIGDATASENT);
