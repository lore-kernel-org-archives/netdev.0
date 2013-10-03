From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Thu, 03 Oct 2013 11:06:35 -0700
Message-ID: <1380823595.19002.220.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
	 <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
	 <1380660769.19002.40.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002173422.GA7824@sbohrermbp13-local.rgmadvisors.com>
	 <1380737365.19002.110.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002203507.GB7824@sbohrermbp13-local.rgmadvisors.com>
	 <1380748118.19002.125.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002212436.GC7824@sbohrermbp13-local.rgmadvisors.com>
	 <1380749932.19002.127.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131003173946.GA5684@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:64376 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754372Ab3JCSGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 14:06:37 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so2820698pdj.17
        for <netdev@vger.kernel.org>; Thu, 03 Oct 2013 11:06:37 -0700 (PDT)
In-Reply-To: <20131003173946.GA5684@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 12:39 -0500, Shawn Bohrer wrote:
> On Wed, Oct 02, 2013 at 02:38:52PM -0700, Eric Dumazet wrote:
> > I suggested that for unicast, you do a limited lookup to the first
> > socket found in bucket.
> > 
> > If its an exact match, you take the socket.
> > 
> > If not, you give up, and do not scan the whole chain.
> 
> So something like the following?
> 
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 02185a5..d202e5b 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1849,7 +1849,42 @@ begin:
>  	}
>  	rcu_read_unlock();
>  	return result;
> +}
>  
> +/* For unicast we should only early demux connected sockets or we can
> + * break forwarding setups.  The chains here can be long so only check
> + * if the first socket is an exact match and if not move on.
> + */
> +static struct sock *__udp4_lib_demux_lookup(struct net *net,
> +					    __be16 loc_port, __be32 loc_addr,
> +					    __be16 rmt_port, __be32 rmt_addr,
> +					    int dif)
> +{
> +	struct sock *sk, *result;
> +	struct hlist_nulls_node *node;
> +	unsigned short hnum = ntohs(loc_port);
> +	unsigned int slot = udp_hashfn(net, hnum, udp_table.mask);
> +	struct udp_hslot *hslot = &udp_table.hash[slot];
> +	const int exact_match = 18;
> +	int score;
> +
> +	rcu_read_lock();
> +	result = NULL;
> +	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
> +		score = compute_score(sk, net, rmt_addr, hnum, rmt_port,
> +				      loc_addr, loc_port, dif);
> +		if (score == exact_match)
> +			result = sk;
> +		/* Only check first socket in chain */
> +		break;
> +	}
> +
> +	if (result) {
> +		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
> +			result = NULL;
> +	}
> +	rcu_read_unlock();
> +	return result;
>  }
>  

Just do the tuple comparison instead of compute_score(),
since you know we want full L4 match.

The standard way is to use the INET_MATCH() macro
