From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: should drop incoming frames without ACK flag set
Date: Wed, 26 Dec 2012 14:44:34 -0800
Message-ID: <1356561874.20133.21098.camel@edumazet-glaptop>
References: <1356541801.20133.20615.camel@edumazet-glaptop>
	 <20121226.141154.115080358245263295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zhiyunq@umich.edu, nanditad@google.com,
	ncardwell@google.com, john.dykstra1@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:51564 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab2LZWoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 17:44:37 -0500
Received: by mail-da0-f44.google.com with SMTP id z20so4054510dae.17
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2012 14:44:36 -0800 (PST)
In-Reply-To: <20121226.141154.115080358245263295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Wed, 2012-12-26 at 14:11 -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 26 Dec 2012 09:10:01 -0800
> 
> > @@ -5540,6 +5540,9 @@ no_ack:
> >  	}
> >  
> >  slow_path:
> > +	if (!th->ack)
> > +			goto discard;
> 
> One too many tabs there on that last line :-)

Hmm, yes :(

> 
> > +
> >  	if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
> >  		goto csum_error;
> >  
> > @@ -5551,7 +5554,7 @@ slow_path:
> 
> 
> Also, I would say that this checksum test should come first, because
> that takes priority since you could be testing the ACK bit of a
> corrupted packet.
> 
> Better to get the statistic bump on the bad checksum then a silent
> drop on the ACK being cleared.

Indeed, good catch.

> 
> > @@ -5984,11 +5987,15 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
> >  		if (tcp_check_req(sk, skb, req, NULL, true) == NULL)
> >  			goto discard;
> >  	}
> > +
> > +	if (!th->ack)
> > +		goto discard;
> > +
> 
> And that is effectively what is going to happen in this case since
> the caller has already done the checksum checks.
> 

That makes perfect sense.

Thanks !

[PATCH v2] tcp: should drop incoming frames without ACK flag set

In commit 96e0bf4b5193d (tcp: Discard segments that ack data not yet
sent) John Dykstra enforced a check against ack sequences.

In commit 354e4aa391ed5 (tcp: RFC 5961 5.2 Blind Data Injection Attack
Mitigation) I added more safety tests.

But we missed fact that these tests are not performed if ACK bit is
not set.

RFC 793 3.9 mandates TCP should drop a frame without ACK flag set.

" fifth check the ACK field,
      if the ACK bit is off drop the segment and return"

Not doing so permits an attacker to only guess an acceptable sequence
number, evading stronger checks.

Many thanks to Zhiyun Qian for bringing this issue to our attention.

See :
http://web.eecs.umich.edu/~zhiyunq/pub/ccs12_TCP_sequence_number_inference.pdf

Reported-by: Zhiyun Qian <zhiyunq@umich.edu>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: John Dykstra <john.dykstra1@gmail.com>
---
V2: moves the th->ack check after checksum one
 
 net/ipv4/tcp_input.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a136925..a28e4db 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5543,6 +5543,9 @@ slow_path:
 	if (len < (th->doff << 2) || tcp_checksum_complete_user(sk, skb))
 		goto csum_error;
 
+	if (!th->ack)
+		goto discard;
+
 	/*
 	 *	Standard slow path.
 	 */
@@ -5551,7 +5554,7 @@ slow_path:
 		return 0;
 
 step5:
-	if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
+	if (tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
 		goto discard;
 
 	/* ts_recent update must be made after we are sure that the packet
@@ -5984,11 +5987,15 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		if (tcp_check_req(sk, skb, req, NULL, true) == NULL)
 			goto discard;
 	}
+
+	if (!th->ack)
+		goto discard;
+
 	if (!tcp_validate_incoming(sk, skb, th, 0))
 		return 0;
 
 	/* step 5: check the ACK field */
-	if (th->ack) {
+	if (true) {
 		int acceptable = tcp_ack(sk, skb, FLAG_SLOWPATH) > 0;
 
 		switch (sk->sk_state) {
@@ -6138,8 +6145,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			}
 			break;
 		}
-	} else
-		goto discard;
+	}
 
 	/* ts_recent update must be made after we are sure that the packet
 	 * is in window.
