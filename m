From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v5 2/2] netfilter: save the hash of the tuple in the original
 direction for latter use
Date: Thu, 16 Sep 2010 08:18:38 +0200
Message-ID: <4C91B6BE.8020300@trash.net>
References: <1282344540-5306-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282344540-5306-1-git-send-email-xiaosuo@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.08.2010 00:49, Changli Gao wrote:
> Since we don't change the tuple in the original direction, we can save it
> in ct->tuplehash[IP_CT_DIR_REPLY].hnode.pprev for __nf_conntrack_confirm()
> use.

I like this idea. We could actually do the same for the reply tuple
and invalidate the saved hash in case the reply tuple is changed
(nf_conntrack_alter_reply()), which only happens when NAT is used.

> __hash_conntrack() is split into two steps: ____hash_conntrack() is used
> to get the raw hash, and __hash_bucket() is used to get the bucket id.

This patch uses underscores a bit excessively, how about renaming:

- ____hash_conntrack() => hash_conntrack_raw()
- __hash variables => hash
- hash variables => bucket

> @@ -408,7 +438,8 @@ __nf_conntrack_confirm(struct sk_buff *skb)
>  		return NF_ACCEPT;
>  
>  	zone = nf_ct_zone(ct);
> -	hash = hash_conntrack(net, zone, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
> +	/* reuse the __hash saved before */
> +	hash = hash_bucket(*(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev, net);

Please try to stay at least close to the 80 characters limit.
