From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix bogus RTT for CC when retransmissions
 are acked
Date: Fri, 10 Apr 2015 17:50:11 -0700
Message-ID: <1428713411.25985.334.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428711469-5328-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:33916 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293AbbDKAuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 20:50:15 -0400
Received: by iget9 with SMTP id t9so23767460ige.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 17:50:14 -0700 (PDT)
In-Reply-To: <1428711469-5328-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-11 at 02:17 +0200, Kenneth Klette Jonassen wrote:
> Since retransmitted segments are not used for RTT estimation, previously
> SACKed segments present in the rtx queue are used. This estimation can be
> several times larger than the actual RTT. When a cumulative ack covers both
> previously SACKed and retransmitted segments, CC may thus get a bogus RTT.
> 
> Such segments previously had an RTT estimation in tcp_sacktag_one(), so it
> seems reasonable to not reuse them in tcp_clean_rtx_queue() at all.
> 
> Afaik, this has had no effect on SRTT/RTO because of Karn's check.
> 
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
> ---
>  net/ipv4/tcp_input.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 031cf72..a7ef679 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3099,17 +3099,15 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
>  			if (sacked & TCPCB_SACKED_RETRANS)
>  				tp->retrans_out -= acked_pcount;
>  			flag |= FLAG_RETRANS_DATA_ACKED;
> -		} else {
> +		} else if (!(sacked & TCPCB_SACKED_ACKED)) {
>  			last_ackt = skb->skb_mstamp;
>  			WARN_ON_ONCE(last_ackt.v64 == 0);
>  			if (!first_ackt.v64)
>  				first_ackt = last_ackt;
>  
> -			if (!(sacked & TCPCB_SACKED_ACKED)) {
> -				reord = min(pkts_acked, reord);
> -				if (!after(scb->end_seq, tp->high_seq))
> -					flag |= FLAG_ORIG_SACK_ACKED;
> -			}
> +			reord = min(pkts_acked, reord);
> +			if (!after(scb->end_seq, tp->high_seq))
> +				flag |= FLAG_ORIG_SACK_ACKED;
>  		}
>  
>  		if (sacked & TCPCB_SACKED_ACKED)

Any particular reason you did not CC authors of this recent patch ?

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=666b805150efd62f05810ff0db08f44a2370c937

Thanks.
