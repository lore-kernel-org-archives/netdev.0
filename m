From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get
Date: Thu, 09 Jan 2014 07:23:45 -0800
Message-ID: <1389281025.31367.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389090711-15843-1-git-send-email-avagin@openvz.org>
	 <1389107305.26646.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140109052454.GA16743@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, Andrey Vagin <avagin@openvz.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Andrew Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:61851 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaAIPXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 10:23:47 -0500
In-Reply-To: <20140109052454.GA16743@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 09:24 +0400, Andrew Vagin wrote:

> I have one more question. Looks like I found another problem.
> 
> init_conntrack:
>         hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
>                       &net->ct.unconfirmed);
> 
> __nf_conntrack_hash_insert:
> 	hlist_nulls_add_head_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
> 		   &net->ct.hash[hash]);
> 
> We use one hlist_nulls_node to add a conntrack into two different lists.
> As far as I understand, it's unacceptable in case of
> SLAB_DESTROY_BY_RCU.

I guess you missed :

net/netfilter/nf_conntrack_core.c:1598: INIT_HLIST_NULLS_HEAD(&net->ct.unconfirmed, UNCONFIRMED_NULLS_VAL);


> 
> Lets imagine that we have two threads. The first one enumerates objects
> from a first list, the second one recreates an object and insert it in a
> second list.  If a first thread in this moment stays on the object, it
> can read "next", when it's in the second list, so it will continue
> to enumerate objects from the second list. It is not what we want, isn't
> it?
> 
> cpu1				cpu2
> 				hlist_nulls_for_each_entry_rcu(ct)
> destroy_conntrack
>  kmem_cache_free
> 
> init_conntrack
>  hlist_nulls_add_head_rcu
> 				ct = ct->next
> 

This will be fine.

I think we even have a counter to count number of occurrence of this
rare event. (I personally never read a non null search_restart value)

 NF_CT_STAT_INC(net, search_restart); 
