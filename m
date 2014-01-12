From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get (v3)
Date: Sun, 12 Jan 2014 12:21:14 -0800
Message-ID: <1389558074.31367.187.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389188841.26646.87.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1389549033-23523-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389549033-23523-1-git-send-email-avagin@openvz.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-01-12 at 21:50 +0400, Andrey Vagin wrote:
> Lets look at destroy_conntrack:
> 
> hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
> ...
> nf_conntrack_free(ct)
> 	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
> 
> net->ct.nf_conntrack_cachep is created with SLAB_DESTROY_BY_RCU.
> 
> The hash is protected by rcu, so readers look up conntracks without
> locks.
> A conntrack is removed from the hash, but in this moment a few readers
> still can use the conntrack. Then this conntrack is released and another
> thread creates conntrack with the same address and the equal tuple.
> After this a reader starts to validate the conntrack:
> * It's not dying, because a new conntrack was created
> * nf_ct_tuple_equal() returns true.
...


> v2: move nf_ct_is_confirmed into the unlikely() annotation
> v3: Eric suggested to fix refcnt, so that it becomes zero before adding
>     in a hash, but we can't find a way how to do that. Another way is to
>     interpret the confirm bit as part of a search key and check it in
>     ____nf_conntrack_find() too.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Andrey !


