From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: better retrans tracking for defer-accept
Date: Sun, 28 Oct 2012 21:02:48 +0100
Message-ID: <1351454568.30380.630.camel@edumazet-glaptop>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
	 <1351339032.30380.222.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210271556250.1628@ja.ssi.bg>
	 <1351344725.30380.286.camel@edumazet-glaptop>
	 <1351347537.30380.315.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210272324020.1628@ja.ssi.bg>
	 <1351415713.30380.398.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210281657050.9279@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:50954 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156Ab2J1UCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 16:02:53 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1457301eaa.19
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 13:02:52 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1210281657050.9279@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-28 at 18:51 +0200, Julian Anastasov wrote:

> 	In fact, my concern was for a case where client can
> flood us with same SYN. My idea was if 5 SYN-ACKs were
> sent in first second, request_sock to expire even when
> num_timeout is changing from 0 to 1. I.e. request_sock
> to expire based on SYN-ACK count, not on fixed time.
> 
> 	But I'm not sure what is better here,
> to expire request_sock immediately when SYN-ACK reaches
> limit or to keep it 63 secs so that we can reduce our
> SYN-ACK rate under such SYN attacks. And not only
> under attack.
> 
> 	Here is what happens if we add DROP rule for
> SYN-ACKs. We can see that every SYN retransmission is
> followed by 2 SYN-ACKs, here is example with loopback:
> 
> Initial SYN and SYN-ACK:
> 12:21:45.773023 IP 127.0.0.1.38450 > 127.0.0.1.22: Flags [S], seq 2096477888, win 32792, options [mss 16396,sackOK,TS val 7978589 ecr 0,nop,wscale 6], length 0
> 12:21:45.773051 IP 127.0.0.1.22 > 127.0.0.1.38450: Flags [S.], seq 1774312921, ack 2096477889, win 32768, options [mss 16396,sackOK,TS val 7978589 ecr 7978589,nop,wscale 6], length 0
> 
> SYN retr 1:
> 12:21:46.775816 IP 127.0.0.1.38450 > 127.0.0.1.22: Flags [S], seq 2096477888, win 32792, options [mss 16396,sackOK,TS val 7979592 ecr 0,nop,wscale 6], length 0
> immediate SYN-ACK from tcp_check_req:
> 12:21:46.775843 IP 127.0.0.1.22 > 127.0.0.1.38450: Flags [S.], seq 1774312921, ack 2096477889, win 32768, options [mss 16396,sackOK,TS val 7979592 ecr 7978589,nop,wscale 6], length 0
> SYN-ACK from inet_csk_reqsk_queue_prune timer:
> 12:21:46.975807 IP 127.0.0.1.22 > 127.0.0.1.38450: Flags [S.], seq 1774312921, ack 2096477889, win 32768, options [mss 16396,sackOK,TS val 7979792 ecr 7978589,nop,wscale 6], length 0
> 
> same for retr 2..5:
> 12:21:48.779809 IP 127.0.0.1.38450 > 127.0.0.1.22: Flags [S], seq 2096477888, win 32792, options [mss 16396,sackOK,TS val 7981596 ecr 0,nop,wscale 6], length 0
> 12:21:48.779837 IP 127.0.0.1.22 > 127.0.0.1.38450: Flags [S.], seq 1774312921, ack 2096477889, win 32768, options [mss 16396,sackOK,TS val 7981596 ecr 7978589,nop,wscale 6], length 0
> 12:21:48.975789 IP 127.0.0.1.22 > 127.0.0.1.38450: Flags [S.], seq 1774312921, ack 2096477889, win 32768, options [mss 16396,sackOK,TS val 7981792 ecr 7978589,nop,wscale 6], length 0
> 
> 	This is a waste of bandwidth too. It is true that
> client can use different TCP_TIMEOUT_INIT value and this timing
> may look different if both sides use different value.
> The most silly change I can think of is to add something
> like this in syn_ack_recalc (not tested at all):
> 
> 	/* Avoid double SYN-ACK if client is resending SYN faster:
> 	 * (num_timeout - num_retrans) >= 0
> 	 */
> 	*resend = !((req->num_timeout - req->num_retrans) & 0x40);
> 
> 	if (!rskq_defer_accept) {
> 		*expire = req->num_timeout >= thresh;
> 		return;
> 	}
> 	*expire = req->num_timeout >= thresh &&
> 		  (!inet_rsk(req)->acked || req->num_timeout >= max_retries);
> 	/*
> 	 * Do not resend while waiting for data after ACK,
> 	 * start to resend on end of deferring period to give
> 	 * last chance for data or ACK to create established socket.
> 	 */
> 	if (inet_rsk(req)->acked)
> 		*resend = req->num_timeout >= rskq_defer_accept - 1;
> 
> 	If we add some checks in tcp_check_req we can also
> restrict the immediate SYN-ACKs up to tcp_synack_retries.
> 
> 	The idea is:
> 
> - expire request_sock as before, based on num_timeout with
> the idea to catch many SYN retransmissions and to reduce
> SYN-ACK rate from 2*SYN_rate to 1*SYN_rate, up to
> tcp_synack_retries SYN-ACKs
> 
> - num_retrans accounts sent SYN-ACKs, they can be sent in
> response to SYN retr or from timer. If num_retrans increases
> faster than num_timeout it means client uses lower
> TCP_TIMEOUT_INIT value and sending SYN-ACKs from
> tcp_check_req is enough because we apply tcp_synack_retries
> once as a SYN-ACK limit and second time as expiration
> period.
> 
> - If we get 10 SYNs in 1 second, we will send 5 SYN-ACKs
> immediately (will be restricted in tcp_check_req), from
> second +1 to +31 we will not send SYN-ACKs if
> tcp_synack_retries is reached, we will wait for ACK and
> for more SYNs to drop, silently. Finally, at +63 we expire
> the request_sock. inet_csk_reqsk_queue_prune still
> can reduce the expiration period (thresh value) under load.
> 
> 	Of course, this is material for separate patch,
> if idea is liked at all.
> 
> Regards

On a SYNFLOOD attack, we end up sending one SYNACK per SYN message
anyway ?

If we want to address a non SYNFLOOD attack, why not resetting
req->expire when we send a SYNACK to a retransmitted SYN ?

tcp_check_req()
...
	if (!inet_rtx_syn_ack(sk, req)) {
		req->expire = jiffies +
			min(TCP_TIMEOUT_INIT << req->num_timeout,
			    TCP_RTO_MAX);
	}
