From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] tcp: better retrans tracking for defer-accept
Date: Sun, 28 Oct 2012 01:29:22 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210272324020.1628@ja.ssi.bg>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>  <1351339032.30380.222.camel@edumazet-glaptop>  <alpine.LFD.2.00.1210271556250.1628@ja.ssi.bg>  <1351344725.30380.286.camel@edumazet-glaptop>
 <1351347537.30380.315.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:37934 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759498Ab2J0WXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Oct 2012 18:23:05 -0400
In-Reply-To: <1351347537.30380.315.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 27 Oct 2012, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> For passive TCP connections using TCP_DEFER_ACCEPT facility,
> we incorrectly increment req->retrans each time timeout triggers
> while no SYNACK is sent.
> 
> SYNACK are not sent for TCP_DEFER_ACCEPT that were established (for wich
> we received the ACK from client). Only the last SYNACK is
> sent so that we can receive again an ACK from client, to move the
> req into accept queue. We plan to change this later to avoid
> the useless retransmit (and potential problem as this SYNACK could be
> lost)
> 
> TCP_INFO later gives wrong information to user, claiming imaginary
> retransmits.
> 
> Decouple req->retrans field into two independent fields :
> 
> num_retrans : number of retransmit
> num_timeout : number of timeouts
> 
> num_timeout is the counter that is incremented at each timeout,
> regardless of actual SYNACK being sent or not, and used to
> compute the exponential timeout.
> 
> Introduce inet_rtx_syn_ack() helper to increment num_retrans
> only if ->rtx_syn_ack() succeeded.
> 
> Use inet_rtx_syn_ack() from tcp_check_req() to increment num_retrans
> when we re-send a SYNACK in answer to a (retransmitted) SYN.
> Prior to this patch, we were not counting these retransmits.
> 
> Change tcp_v[46]_rtx_synack() to increment TCP_MIB_RETRANSSEGS
> only if a synack packet was successfully queued.
> 
> Reported-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Vijay Subramanian <subramanian.vijay@gmail.com>
> Cc: Elliott Hughes <enh@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> ---

> diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
> index ba48e79..b236ef0 100644
> --- a/net/ipv4/syncookies.c
> +++ b/net/ipv4/syncookies.c
> @@ -340,7 +340,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
>  	}
>  
>  	req->expires	= 0UL;
> -	req->retrans	= 0;
> +	req->num_retrans = 0;

	also req->num_timeout = 0; ?

>  
>  	/*
>  	 * We need to lookup the route here to get at the correct

> diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
> index 182ab9a..4016197 100644
> --- a/net/ipv6/syncookies.c
> +++ b/net/ipv6/syncookies.c
> @@ -214,7 +214,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
>  		ireq6->iif = inet6_iif(skb);
>  
>  	req->expires = 0UL;
> -	req->retrans = 0;
> +	req->num_retrans = 0;

	also req->num_timeout = 0; ?

>  	ireq->ecn_ok		= ecn_ok;
>  	ireq->snd_wscale	= tcp_opt.snd_wscale;
>  	ireq->sack_ok		= tcp_opt.sack_ok;

> @@ -1866,7 +1869,7 @@ static void get_openreq6(struct seq_file *seq,
>  		   0,0, /* could print option size, but that is af dependent. */
>  		   1,   /* timers active (only the expire timer) */
>  		   jiffies_to_clock_t(ttd),
> -		   req->retrans,
> +		   req->num_timeout,

	num_timeout already noted by Neal

>  		   from_kuid_munged(seq_user_ns(seq), uid),
>  		   0,  /* non standard timer */
>  		   0, /* open_requests have no inode */

	I don't see any problems with such patch, just
check if it is for correct tree, I see some atomic operations
with qlen_young in patch.

	One thing to finally decide: should we use limit for
retransmissions or for timeout, is the following better?:

	if (!rskq_defer_accept) {
		*expire = req->num_retrans >= thresh;
			       ^^^^^^^^^^^
		*resend = 1;
		return;
	}
	*expire = req->num_retrans >= thresh &&
		       ^^^^^^^^^^^
		  (!inet_rsk(req)->acked || req->num_timeout >= max_retries);

	Same in tcp_fastopen_synack_timer:

	if (req->num_retrans >= max_retries) {
		 ^^^^^^^^^^^

	By this way limit (thresh) is for retransmissions while
defer period should be time based as before.

	Documentation/networking/ip-sysctl.txt compares
the tcp_synack_retries with timeout, so I'm not sure
which variant is better to use. OTOH, include/net/tcp.h
does not specify minimum in seconds for TCP_SYNACK_RETRIES,
so what should we prefer, the count or its time form?
May be count (num_retrans) is better against SYN attacks.

Regards

--
Julian Anastasov <ja@ssi.bg>
