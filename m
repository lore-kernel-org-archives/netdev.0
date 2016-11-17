From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: nsid cannot be allocated for a dead netns
Date: Wed, 16 Nov 2016 23:17:22 -0500 (EST)
Message-ID: <20161116.231722.2198167385156796830.davem@davemloft.net>
References: <201611161759.tCk5fdCO%fengguang.wu@intel.com>
        <1479289775-1715-1-git-send-email-nicolas.dichtel@6wind.com>
        <CAM_iQpXzp54gOyiRu4PUcJhLEB3T+TTEL+JLE2PL+oB31ZuCJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, avagin@gmail.com, netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32988 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbcKQERY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 23:17:24 -0500
In-Reply-To: <CAM_iQpXzp54gOyiRu4PUcJhLEB3T+TTEL+JLE2PL+oB31ZuCJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 16 Nov 2016 09:29:29 -0800

> On Wed, Nov 16, 2016 at 1:49 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index f61c0e02a413..63f65387f4e1 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -159,6 +159,9 @@ static int alloc_netid(struct net *net, struct net *peer, int reqid)
>>                 max = reqid + 1;
>>         }
>>
>> +       if (!atomic_read(&net->count) || !atomic_read(&peer->count))
>> +               return -EINVAL;
>> +
>>         return idr_alloc(&net->netns_ids, peer, min, max, GFP_ATOMIC);
>>  }
> 
> 
> There is already a check in peernet2id_alloc(), so why not just the following?
> 
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index f61c0e0..7001da9 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -219,6 +219,8 @@ int peernet2id_alloc(struct net *net, struct net *peer)
>         bool alloc;
>         int id;
> 
> +       if (atomic_read(&net->count) == 0)
> +               return NETNSA_NSID_NOT_ASSIGNED;
>         spin_lock_irqsave(&net->nsid_lock, flags);
>         alloc = atomic_read(&peer->count) == 0 ? false : true;
>         id = __peernet2id_alloc(net, peer, &alloc);

Indeed, this looks cleaner, Nicolas?
