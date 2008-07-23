From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] Probable bug in icsk_probes_out handling ?
Date: Wed, 23 Jul 2008 16:34:44 -0700 (PDT)
Message-ID: <20080723.163444.165532483.davem@davemloft.net>
References: <48873397.5040409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54338
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754700AbYGWXeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 19:34:44 -0400
In-Reply-To: <48873397.5040409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 23 Jul 2008 15:35:19 +0200

> Apparently, we can in some situations reset TCP connections in a couple of seconds when some frames are lost.

I think it is some optimization that went in between 2.2.x and 2.4.x
which took things a little bit too far.

Please try this patch:

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1f5e604..75efd24 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3292,6 +3292,7 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	 * log. Something worked...
 	 */
 	sk->sk_err_soft = 0;
+	icsk->icsk_probes_out = 0;
 	tp->rcv_tstamp = tcp_time_stamp;
 	prior_packets = tp->packets_out;
 	if (!prior_packets)
@@ -3324,8 +3325,6 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	return 1;
 
 no_queue:
-	icsk->icsk_probes_out = 0;
-
 	/* If this ack opens up a zero window, clear backoff.  It was
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
