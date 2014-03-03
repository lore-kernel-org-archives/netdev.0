From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: fix for a race condition in the inet frag code
Date: Mon, 3 Mar 2014 15:40:26 +0100
Message-ID: <20140303144026.GH9965@breakpoint.cc>
References: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51402 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754711AbaCCOk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 09:40:29 -0500
Content-Disposition: inline
In-Reply-To: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> I stumbled upon this very serious bug while hunting for another one,
> it's a very subtle race condition between inet_frag_evictor,
> inet_frag_intern and the IPv4/6 frag_queue and expire functions (basically
> the users of inet_frag_kill/inet_frag_put).
> What happens is that after a fragment has been added to the hash chain but
> before it's been added to the lru_list (inet_frag_lru_add), it may get
> deleted (either by an expired timer if the system load is high or the
> timer sufficiently low, or by the fraq_queue function for different
> reasons) before it's added to the lru_list

Sorry.  Not following here, see below.

> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index bb075fc9a14f..322dcebfc588 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -278,9 +278,10 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
>  
>  	atomic_inc(&qp->refcnt);
>  	hlist_add_head(&qp->list, &hb->chain);
> +	inet_frag_lru_add(nf, qp);
>  	spin_unlock(&hb->chain_lock);
>  	read_unlock(&f->lock);

If I understand correctly your're saying that qp can be free'd on
another/cpu timer right after dropping the locks.  But how is it
possible?

->refcnt is bumped above when arming the timer (before dropping chain
lock), so even if the frag_expire timer fires instantly it should not
free qp.

What am I missing?

Thanks,
Florian
