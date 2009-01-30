From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 00:50:08 +0300
Message-ID: <20090130215008.GB12210@ioremap.net>
References: <20090130112125.GA9908@ioremap.net> <20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:48499 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752898AbZA3VuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 16:50:11 -0500
Content-Disposition: inline
In-Reply-To: <498349F7.4050300@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 07:41:59PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> Reviewing commit a9d8f9110d7e953c2f2b521087a4179677843c2a
> 
> I see use of a hashinfo->bsockets field that :
> 
> - lacks proper lock/synchronization

It should contain rough number of sockets, there is no need to be very
precise because of this hueristic.

> - suffers from cache line ping pongs on SMP

I used free alignment slot so that socket structure would not be
icreased.

> Also there might be a problem at line 175
> 
> if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0) { 
> 	spin_unlock(&head->lock);
> 	goto again;
> 
> If we entered inet_csk_get_port() with a non null snum, we can "goto again"
> while it was not expected.
> 
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index df8e72f..752c6b2 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -172,7 +172,8 @@ tb_found:
>  		} else {
>  			ret = 1;
>  			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
> -				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0) {
> +				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
> +					smallest_size == -1 &&  --attempts >= 0) {

I think it should be smallest_size != -1, since we really want to goto
to the again label when hueristic is used, which in turn changes
smallest_size.

-- 
	Evgeniy Polyakov
