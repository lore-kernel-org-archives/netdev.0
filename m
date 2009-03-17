From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 0/6] netfilter: ctnetlink allocation improvement
Date: Tue, 17 Mar 2009 05:35:47 +0100
Message-ID: <49BF28A3.3010606@trash.net>
References: <20090316220659.756862181@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Holger Eitzenberger <holger@eitzenberger.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090316220659.756862181@jonathan.eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Holger Eitzenberger wrote:
> what follows is a small patchset against net-next-2.6 which tries to
> improve the way ctnetlink events are allocated.  By allocating the
> ctnetlink skbs roughly the size of the message we prevent the skb from
> later being reallocated in netlink_trim().
> 
> Though I haven't got any hard performance numbers yet I think this
> might introduce a noticable performance gain.
> 
> The overall idea of these patches is to compute the proto independant
> attribute sizes at compile time, the proto-dependant parts are
> computed at registration of the actual proto helpers.  This is
> achieved by introducing nla_policy_len(), which computes the max.
> length of a nla_policy.
> 
> I also have to introduce NF_CT_HELPER_NAME_LEN as an upper limit for
> the conntrack protcol helper names, which is not much of a problem
> because all names in mainline are actually shorter than that.

The helper name change is fine. We currently have a limit of 30
in the helper match, but that is just as arbitrary and 16 does
seem like enough. In fact I need the same change for nftables :)

> It would be great to have that being merged.  Please share youre
> comments.

These patches look almost perfect, there's just one minor thing
that should be fixed from my perspective (from patch 4):

> +	l3proto = nf_ct_l3proto_find_get(tuple->src.l3num);
> +	len += l3proto->nla_size;
> +	nf_ct_l3proto_put(l3proto);
> +
> +	l4proto = nf_ct_l4proto_find_get(tuple->src.l3num, tuple->dst.protonum);
> +	len += l4proto->nla_size;
> +	nf_ct_l4proto_put(l4proto);
> +
> +	return alloc_skb(len, gfp);

Its preferrable not to use module reference counting during packet
processing, the protocols can be accessed safely using RCU. I thought
I had fixed all those areas, but I now notice that ctnetlink is full
of similar spots and takes and drops module references quite
excessively. So just leave it as it is I guess, this should be fully
fixed anyways.

I'll wait a few hours for others to comment before applying your
patches.
