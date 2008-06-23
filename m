From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/25] netns ct: per-netns conntrack hash
Date: Mon, 23 Jun 2008 12:22:17 +0200
Message-ID: <485F7959.9000901@trash.net>
References: <20080622010605.GG5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080622010605.GG5392@martell.zuzino.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> netns is given personal conntrack hash. Another way is to have one hash
> and give tuplehashes ->ct_net pointer. I tried that at some point, it's
> more ugly and more non-obvious.

I think is makes more sense your way, otherwise eviction becomes much
more complicated or people can easily DoS other namespaces.

> Functions that search by tuple (numerical data) get netns argument
> to know where to search as well as conntrack flush functions gets netns
> argument propagated.
> 
> Everybody is stubbed to init_net, except trivial places.
> 
> --- a/include/net/netns/conntrack.h
> +++ b/include/net/netns/conntrack.h
> @@ -5,5 +5,7 @@
>  
>  struct netns_ct {
>  	atomic_t	count;
> +	struct hlist_head	*hash;
> +	int			hash_vmalloc;

Shouldn't the lock also be per namespace?

> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -49,15 +49,11 @@ EXPORT_SYMBOL_GPL(nf_conntrack_htable_size);
>  int nf_conntrack_max __read_mostly;
>  EXPORT_SYMBOL_GPL(nf_conntrack_max);
>  
> -struct hlist_head *nf_conntrack_hash __read_mostly;
> -EXPORT_SYMBOL_GPL(nf_conntrack_hash);
> -
>  struct nf_conn nf_conntrack_untracked __read_mostly;
>  EXPORT_SYMBOL_GPL(nf_conntrack_untracked);

Just a general comments, maybe its done in a later patch. But
for nf_conntrack_cleanup(), you also need to put the untrack
entry in a namespace, otherwise different use in different
namespaces will prevent cleanup from completing.
