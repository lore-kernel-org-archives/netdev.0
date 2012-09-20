From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Thu, 20 Sep 2012 19:06:52 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1209201859140.14078@stinky-local.trash.net>
References: <1347357081.3928.32.camel@localhost> <20120912213627.GJ14750@breakpoint.cc>
 <20120914120750.GA5764@1984> <Pine.GSO.4.63.1209141511020.11622@stinky-local.trash.net>
 <1348058791.2761.94.camel@localhost> <Pine.GSO.4.63.1209200855500.8409@stinky-local.trash.net>
 <20120920100859.GB20828@1984> <Pine.GSO.4.63.1209201212480.1775@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, yongjun_wei@trendmicro.com.cn
To: Pablo Neira Ayuso <pablo@gnumonks.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1209201212480.1775@stinky-local.trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Sep 2012, Patrick McHardy wrote:

>>> diff --git a/net/netfilter/nf_conntrack_core.c 
>>> b/net/netfilter/nf_conntrack_core.c
>>> index dcb2791..0f241be 100644
>>> --- a/net/netfilter/nf_conntrack_core.c
>>> +++ b/net/netfilter/nf_conntrack_core.c
>>> @@ -1224,6 +1224,8 @@ get_next_corpse(struct net *net, int (*iter)(struct 
>>> nf_conn *i, void *data),
>>>  	spin_lock_bh(&nf_conntrack_lock);
>>>  	for (; *bucket < net->ct.htable_size; (*bucket)++) {
>>>  		hlist_nulls_for_each_entry(h, n, &net->ct.hash[*bucket], 
>>> hnnode) {
>>> +			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
>>> +				continue;
>> 
>> I think this will make the deletion of entries via `conntrack -F'
>> slowier as we'll have to iterate over more entries (we won't delete
>> entries for the reply tuple).
>
> Slightly maybe, but I doubt it makes much of a difference.
>
>> I think I prefer Florian's patch, it's fairly small and it does not
>> change the current nf_ct_iterate behaviour or adding some
>> nf_nat_iterate cleanup.
>
> I don't think I've received it. Could you forward it to me please?

Florian forwarded the patch to me. While it fixes the problem, it
is a workaround and it certainly is inelegant to do the
list_del_rcu_init() and memset up to *four* times for a single conntrack.

The correct thing IMO is to invoke the callbacks exactly once per
conntrack, either through my nf_ct_iterate_cleanup() change or through
a new iteration function for callers that don't kill conntracks. As
soon as we start generating events for NAT section cleanup this will be
needed in any case.

Unless I'm missing something, conntrack flushing is also a really rare 
operation anyways and for large tables where this might make a small
difference will take a quite large time anyway.
