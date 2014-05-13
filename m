From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/5] net: tcp: add flag for ca to indicate that ECN is
 required
Date: Tue, 13 May 2014 11:18:42 +0200
Message-ID: <20140513091842.GB13945@breakpoint.cc>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
 <1399928384-24143-3-git-send-email-fw@strlen.de>
 <1399938695.7973.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Glenn Judd <glenn.judd@morganstanley.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57720 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759949AbaEMJSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 05:18:45 -0400
Content-Disposition: inline
In-Reply-To: <1399938695.7973.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > +static inline bool tcp_ca_needs_ecn(const struct sock *sk)
> > +{
> > +	const struct inet_connection_sock *icsk = inet_csk(sk);
> > +
> > +	return icsk->icsk_ca_ops->flags & TCP_CONG_NEEDS_ECN;
> > +}
> > +
> >  static inline void tcp_ca_event(struct sock *sk, const enum tcp_ca_event event)
> >  {
> >  	const struct inet_connection_sock *icsk = inet_csk(sk);
> > @@ -856,6 +847,26 @@ static inline void tcp_ca_event(struct sock *sk, const enum tcp_ca_event event)
> >  		icsk->icsk_ca_ops->cwnd_event(sk, event);
> >  }
> >  
> > +/* RFC3168 : 6.1.1 SYN packets must not have ECT/ECN bits set
> > + *
> > + * If we receive a SYN packet with these bits set, it means a network is
> > + * playing bad games with TOS bits. In order to avoid possible false congestion
> > + * notifications, we disable TCP ECN negociation.
> > + */
> 
> looks like comment needs a change.

Right, thanks for catching this.

> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index 694711a..1f983dd 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -331,7 +331,8 @@ static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
> >  	struct tcp_sock *tp = tcp_sk(sk);
> >  
> >  	tp->ecn_flags = 0;
> > -	if (sock_net(sk)->ipv4.sysctl_tcp_ecn == 1) {
> > +	if (sock_net(sk)->ipv4.sysctl_tcp_ecn == 1 ||
> > +	    tcp_ca_needs_ecn(sk)) {
> >  		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ECE | TCPHDR_CWR;
> >  		tp->ecn_flags = TCP_ECN_OK;
> >  	}
> > @@ -953,6 +954,9 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
> >  	if (likely((tcb->tcp_flags & TCPHDR_SYN) == 0))
> >  		TCP_ECN_send(sk, skb, tcp_header_size);
> >  
> > +	if (tcp_ca_needs_ecn(sk))
> > +		INET_ECN_xmit(sk);
> 
> Why do we need this every time we send a packet ?

Indeed...  I'll change it.

> Its normally done in TCP_ECN_send(), where it probably makes sense to
> change the logic and add a comment why DCTCP sets ECT even for rtx
> packets ?

Sounds like an excellent suggestion, thanks Eric.
