From: Per Hurtig <per.hurtig@kau.se>
Subject: tcp: fixing TLP's FIN recovery
Date: Fri, 6 Jun 2014 20:46:26 +0200
Message-ID: <20140606184626.GA13509@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, anna.brunstrom@kau.se,
	mohammad.rajiullah@kau.se
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.38]:58653 "EHLO tiger.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751924AbaFFSyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 14:54:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From ab1b16ef8aba4300b1a6e965c3ab7d0cb269bb2a Mon Sep 17 00:00:00 2001
From: Per Hurtig <per.hurtig@kau.se>
Date: Fri, 6 Jun 2014 18:36:19 +0200
Subject: [PATCH 1/1] tcp: fixing TLP's FIN recovery

Fix to a problem observed when losing a FIN segment that does not
contain data.  In such situations, TLP is unable to recover from
*any* tail loss and instead adds at least PTO ms to the
retransmission process, i.e., RTO = RTO + PTO.

Signed-off-by: Per Hurtig <per.hurtig@kau.se>
---
 net/ipv4/tcp_output.c | 5 +++--
  1 file changed, 3 insertions(+), 2 deletions(-)

  diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
  index d463c35..2c29926 100644
  --- a/net/ipv4/tcp_output.c
  +++ b/net/ipv4/tcp_output.c
  @@ -2130,8 +2130,9 @@ void tcp_send_loss_probe(struct sock *sk)
    if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
	    goto rearm_timer;
	     
	     -	/* Probe with zero data doesn't trigger fast recovery.
		*/
		-	if (skb->len > 0)
		+	/* Probe with zero data doesn't trigger fast
		recovery, unless
		+	 * FIN flag is set. */
		+	if ((skb->len > 0) ||
		(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
			err = __tcp_retransmit_skb(sk, skb);
			 
			    /* Record snd_nxt for loss detection. */
			    -- 
			    1.9.1
