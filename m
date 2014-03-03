From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] net: fix for a race condition in the inet frag code
Date: Mon, 03 Mar 2014 15:43:00 +0100
Message-ID: <531494F4.4030909@redhat.com>
References: <1393855520-18334-1-git-send-email-nikolay@redhat.com> <20140303144026.GH9965@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19506 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754358AbaCCOrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2014 09:47:32 -0500
In-Reply-To: <20140303144026.GH9965@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2014 03:40 PM, Florian Westphal wrote:
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
>> I stumbled upon this very serious bug while hunting for another one,
>> it's a very subtle race condition between inet_frag_evictor,
>> inet_frag_intern and the IPv4/6 frag_queue and expire functions (basically
>> the users of inet_frag_kill/inet_frag_put).
>> What happens is that after a fragment has been added to the hash chain but
>> before it's been added to the lru_list (inet_frag_lru_add), it may get
>> deleted (either by an expired timer if the system load is high or the
>> timer sufficiently low, or by the fraq_queue function for different
>> reasons) before it's added to the lru_list
> 
> Sorry.  Not following here, see below.
> 
>> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
>> index bb075fc9a14f..322dcebfc588 100644
>> --- a/net/ipv4/inet_fragment.c
>> +++ b/net/ipv4/inet_fragment.c
>> @@ -278,9 +278,10 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
>>  
>>  	atomic_inc(&qp->refcnt);
>>  	hlist_add_head(&qp->list, &hb->chain);
>> +	inet_frag_lru_add(nf, qp);
>>  	spin_unlock(&hb->chain_lock);
>>  	read_unlock(&f->lock);
> 
> If I understand correctly your're saying that qp can be free'd on
> another/cpu timer right after dropping the locks.  But how is it
> possible?
> 
> ->refcnt is bumped above when arming the timer (before dropping chain
> lock), so even if the frag_expire timer fires instantly it should not
> free qp.
> 
> What am I missing?
> 
> Thanks,
> Florian
> 
inet_frag_kill when called from the IPv4/6 frag_queue function will remove the
timer refcount, then inet_frag_put afterwards will drop it to 0 and free it and
all of this could happen before the frag was ever added to the LRU list, then it
gets added. This happens much easier for IPv6 because of the dropping of
overlapping fragments in its frag_queue function, the point is we need to have
the timer's refcount removed in any way (it could be the timer itself - there's
an inet_frag_put in the end, or much easier by the frag_queue function).
I think I've explained it badly, I hope this makes it clearer :-)

Cheers,
Nik
