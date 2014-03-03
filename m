From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] net: fix for a race condition in the inet frag code
Date: Mon, 3 Mar 2014 18:13:40 +0100
Message-ID: <20140303181340.25d38bd4@redhat.com>
References: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
	<20140303144026.GH9965@breakpoint.cc>
	<531494F4.4030909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, brouer@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752726AbaCCRNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2014 12:13:46 -0500
In-Reply-To: <531494F4.4030909@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 03 Mar 2014 15:43:00 +0100
Nikolay Aleksandrov <nikolay@redhat.com> wrote:

> On 03/03/2014 03:40 PM, Florian Westphal wrote:
> > Nikolay Aleksandrov <nikolay@redhat.com> wrote:

[...]
> >> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> >> index bb075fc9a14f..322dcebfc588 100644
> >> --- a/net/ipv4/inet_fragment.c
> >> +++ b/net/ipv4/inet_fragment.c
> >> @@ -278,9 +278,10 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
> >>  
> >>  	atomic_inc(&qp->refcnt);
> >>  	hlist_add_head(&qp->list, &hb->chain);
> >> +	inet_frag_lru_add(nf, qp);
> >>  	spin_unlock(&hb->chain_lock);
> >>  	read_unlock(&f->lock);
> > 
[...]
> > 
> inet_frag_kill when called from the IPv4/6 frag_queue function will remove the
> timer refcount, then inet_frag_put afterwards will drop it to 0 and free it and
> all of this could happen before the frag was ever added to the LRU list, then it
> gets added. This happens much easier for IPv6 because of the dropping of
> overlapping fragments in its frag_queue function, the point is we need to have
> the timer's refcount removed in any way (it could be the timer itself - there's
> an inet_frag_put in the end, or much easier by the frag_queue function).
> I think I've explained it badly, I hope this makes it clearer :-)

I like this desc better.

After some IRC discussions with Nik and Florian, I acknowledge this is
real race condition.

The real solution is the remove the LRU list system (which will also
solve a scalability problem), but short-term we need Nik's fix, which I
guess should be a stable fix.

Thanks Nik!
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
