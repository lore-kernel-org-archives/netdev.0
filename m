From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] net: fix for a race condition in the inet frag code
Date: Mon, 03 Mar 2014 16:34:32 +0100
Message-ID: <5314A108.5070509@redhat.com>
References: <1393855520-18334-1-git-send-email-nikolay@redhat.com>	<20140303144026.GH9965@breakpoint.cc>	<53149694.6070603@redhat.com> <20140303163133.25b24121@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754099AbaCCPjC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2014 10:39:02 -0500
In-Reply-To: <20140303163133.25b24121@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2014 04:31 PM, Jesper Dangaard Brouer wrote:
> On Mon, 03 Mar 2014 15:49:56 +0100
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> On 03/03/2014 03:40 PM, Florian Westphal wrote:
>>> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
>>>> I stumbled upon this very serious bug while hunting for another one,
>>>> it's a very subtle race condition between inet_frag_evictor,
>>>> inet_frag_intern and the IPv4/6 frag_queue and expire functions (basically
>>>> the users of inet_frag_kill/inet_frag_put).
>>>> What happens is that after a fragment has been added to the hash chain but
>>>> before it's been added to the lru_list (inet_frag_lru_add), it may get
>>>> deleted (either by an expired timer if the system load is high or the
>>>> timer sufficiently low, or by the fraq_queue function for different
>>>> reasons) before it's added to the lru_list
>>>
>>> Sorry.  Not following here, see below.
>>>
>>>> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
>>>> index bb075fc9a14f..322dcebfc588 100644
>>>> --- a/net/ipv4/inet_fragment.c
>>>> +++ b/net/ipv4/inet_fragment.c
>>>> @@ -278,9 +278,10 @@ static struct inet_frag_queue *inet_frag_intern(struct netns_frags *nf,
>>>>  
>>>>  	atomic_inc(&qp->refcnt);
>>>>  	hlist_add_head(&qp->list, &hb->chain);
>>>> +	inet_frag_lru_add(nf, qp);
>>>>  	spin_unlock(&hb->chain_lock);
>>>>  	read_unlock(&f->lock);
>>>
>>> If I understand correctly your're saying that qp can be free'd on
>>> another/cpu timer right after dropping the locks.  But how is it
>>> possible?
>>>
>>> ->refcnt is bumped above when arming the timer (before dropping chain
>>> lock), so even if the frag_expire timer fires instantly it should not
>>> free qp.
>>>
>>> What am I missing?
>>>
>>> Thanks,
>>> Florian
>>>
>> An important point is that inet_frag_kill removes both the timer's refcnt and
>> has an unconditional atomic_dec to remove the original/guarding refcnt, so it
>> basically removes everything that's in the way.
>  
> It sound like we might have a refcnt problem...
> Do we need an extra refcnt for maintaining elements the LRU list?
> 
I don't think so, if you keep the lru_add separated from the chain addition as
before you still got a race condition when frags are seen by the fq_find
functions but are not in the LRU list yet unless you add the refcnt before
adding to the lru list while holding the chain lock (or before that) which will
alter the behaviour, but still if inet_frag_kill gets called it should remove
that refcnt and thus put us in the same position as now if we want to keep the
behaviour as it's now.

Nik
