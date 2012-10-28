From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: better retrans tracking for defer-accept
Date: Sun, 28 Oct 2012 10:15:13 +0100
Message-ID: <1351415713.30380.398.camel@edumazet-glaptop>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
	 <1351339032.30380.222.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210271556250.1628@ja.ssi.bg>
	 <1351344725.30380.286.camel@edumazet-glaptop>
	 <1351347537.30380.315.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210272324020.1628@ja.ssi.bg>
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
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57937 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab2J1JPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 05:15:18 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1630096eek.19
        for <netdev@vger.kernel.org>; Sun, 28 Oct 2012 02:15:17 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.00.1210272324020.1628@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-28 at 01:29 +0300, Julian Anastasov wrote:
> 	Hello,
> 
> On Sat, 27 Oct 2012, Eric Dumazet wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > For passive TCP connections using TCP_DEFER_ACCEPT facility,
> > we incorrectly increment req->retrans each time timeout triggers
> > while no SYNACK is sent.
> > 
> > SYNACK are not sent for TCP_DEFER_ACCEPT that were established (for wich
> > we received the ACK from client). Only the last SYNACK is
> > sent so that we can receive again an ACK from client, to move the
> > req into accept queue. We plan to change this later to avoid
> > the useless retransmit (and potential problem as this SYNACK could be
> > lost)
> > 
> > TCP_INFO later gives wrong information to user, claiming imaginary
> > retransmits.
> > 
> > Decouple req->retrans field into two independent fields :
> > 
> > num_retrans : number of retransmit
> > num_timeout : number of timeouts
> > 
> > num_timeout is the counter that is incremented at each timeout,
> > regardless of actual SYNACK being sent or not, and used to
> > compute the exponential timeout.
> > 
> > Introduce inet_rtx_syn_ack() helper to increment num_retrans
> > only if ->rtx_syn_ack() succeeded.
> > 
> > Use inet_rtx_syn_ack() from tcp_check_req() to increment num_retrans
> > when we re-send a SYNACK in answer to a (retransmitted) SYN.
> > Prior to this patch, we were not counting these retransmits.
> > 
> > Change tcp_v[46]_rtx_synack() to increment TCP_MIB_RETRANSSEGS
> > only if a synack packet was successfully queued.
> > 
> > Reported-by: Yuchung Cheng <ycheng@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Julian Anastasov <ja@ssi.bg>
> > Cc: Vijay Subramanian <subramanian.vijay@gmail.com>
> > Cc: Elliott Hughes <enh@google.com>
> > Cc: Neal Cardwell <ncardwell@google.com>
> > ---
> 
> > diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
> > index ba48e79..b236ef0 100644
> > --- a/net/ipv4/syncookies.c
> > +++ b/net/ipv4/syncookies.c
> > @@ -340,7 +340,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
> >  	}
> >  
> >  	req->expires	= 0UL;
> > -	req->retrans	= 0;
> > +	req->num_retrans = 0;
> 
> 	also req->num_timeout = 0; ?

This is not needed here.

We construct a temporary req only to be able to use get_cookie_sock()
and build a full socket with :
 icsk->icsk_af_ops->syn_recv_sock(sk, skb, req, dst);

By definition this req wont ever be used in SYN_RECV state, and never be
part of the timer wheel.

We init req->num_retrans to 0 because this field will be the source of

newtp->total_retrans = req->num_retrans;

in tcp_v{4|6}_syn_recv_sock()

> 
> >  
> >  	/*
> >  	 * We need to lookup the route here to get at the correct
> 
> > diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
> > index 182ab9a..4016197 100644
> > --- a/net/ipv6/syncookies.c
> > +++ b/net/ipv6/syncookies.c
> > @@ -214,7 +214,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
> >  		ireq6->iif = inet6_iif(skb);
> >  
> >  	req->expires = 0UL;
> > -	req->retrans = 0;
> > +	req->num_retrans = 0;
> 
> 	also req->num_timeout = 0; ?
> 


Same thing : this is not needed

> >  	ireq->ecn_ok		= ecn_ok;
> >  	ireq->snd_wscale	= tcp_opt.snd_wscale;
> >  	ireq->sack_ok		= tcp_opt.sack_ok;
> 
> > @@ -1866,7 +1869,7 @@ static void get_openreq6(struct seq_file *seq,
> >  		   0,0, /* could print option size, but that is af dependent. */
> >  		   1,   /* timers active (only the expire timer) */
> >  		   jiffies_to_clock_t(ttd),
> > -		   req->retrans,
> > +		   req->num_timeout,
> 
> 	num_timeout already noted by Neal
> 

Yes, thanks. source patch was fine, I messed the rebase.

> >  		   from_kuid_munged(seq_user_ns(seq), uid),
> >  		   0,  /* non standard timer */
> >  		   0, /* open_requests have no inode */
> 
> 	I don't see any problems with such patch, just
> check if it is for correct tree, I see some atomic operations
> with qlen_young in patch.
> 

Arg, my net-next tree got some stuff I forgot to revert, sorry, will
cleanup.

> 	One thing to finally decide: should we use limit for
> retransmissions or for timeout, is the following better?:
> 
> 	if (!rskq_defer_accept) {
> 		*expire = req->num_retrans >= thresh;
> 			       ^^^^^^^^^^^
> 		*resend = 1;
> 		return;
> 	}

Not sure it matters and if this decision is part of this patch.

If a retransmit fails, it seems we zap the request anyway ?

inet_rtx_syn_ack() returns an error and inet_rsk(req)->acked is false ->
we remove the req from queue.

We dont remove the req only if we got a listen queue overflow in
tcp_check_req() : we set acked to 1 in this case.

listen_overflow:
	if (!sysctl_tcp_abort_on_overflow) {
		inet_rsk(req)->acked = 1;
		return NULL;
	}

Using number of timeouts seems better to me. There is no point holding a
req forever if we fail to retransmit SYNACKS.
Client probably gave up.

Thanks a lot for the review !
