From: Andrey Wagin <avagin@gmail.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get
Date: Fri, 10 Jan 2014 01:46:10 +0400
Message-ID: <CANaxB-zmYUVZO=wb-FXZ52S-SqvFFhFUu2AnbUYHm4Zhg78eEg@mail.gmail.com>
References: <1389090711-15843-1-git-send-email-avagin@openvz.org>
	<1389107305.26646.20.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140109052454.GA16743@gmail.com>
	<1389281025.31367.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	vvs@openvz.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389281025.31367.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014/1/9 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2014-01-09 at 09:24 +0400, Andrew Vagin wrote:
>
>> I have one more question. Looks like I found another problem.
>>
>> init_conntrack:
>>         hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
>>                       &net->ct.unconfirmed);
>>
>> __nf_conntrack_hash_insert:
>>       hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
>>                  &net->ct.hash[hash]);
>>
>> We use one hlist_nulls_node to add a conntrack into two different lists.
>> As far as I understand, it's unacceptable in case of
>> SLAB_DESTROY_BY_RCU.
>
> I guess you missed :
>
> net/netfilter/nf_conntrack_core.c:1598: INIT_HLIST_NULLS_HEAD(&net->ct.unconfirmed, UNCONFIRMED_NULLS_VAL);

but we can look up something suitable and return this value, but it
will be unconfirmed. Ok, I see. This situation is fixed by this patch
too.

I don't understand the result of your discussion with Florian.  Here
are a few states of conntracts: it can be used and it's initialized.
The sign of the first state is non-zero refcnt and the sign of the
second state is the confirmed bit.

In the first state conntrack is attached to skb and inserted in the
unconfirmed list. In this state the use count can be incremented in
ctnetlink_dump_list() and skb_clone().

In the second state conntrack may be attached to a few skb-s and
inserted to net->ct.hash.

I have read all emails again and I can't understand when this patch
doesn't work.  Maybe you could give a sequence of actions? Thanks.

>
>
>>
>> Lets imagine that we have two threads. The first one enumerates objects
>> from a first list, the second one recreates an object and insert it in a
>> second list.  If a first thread in this moment stays on the object, it
>> can read "next", when it's in the second list, so it will continue
>> to enumerate objects from the second list. It is not what we want, isn't
>> it?
>>
>> cpu1                          cpu2
>>                               hlist_nulls_for_each_entry_rcu(ct)
>> destroy_conntrack
>>  kmem_cache_free
>>
>> init_conntrack
>>  hlist_nulls_add_head_rcu
>>                               ct = ct->next
>>
>
> This will be fine.
>
> I think we even have a counter to count number of occurrence of this
> rare event. (I personally never read a non null search_restart value)
>
>  NF_CT_STAT_INC(net, search_restart);

Thank you for explanation.
