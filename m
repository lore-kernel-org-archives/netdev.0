From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: introduce read_pnet() and write_pnet() functions
Date: Fri, 7 Nov 2008 20:41:00 +0300
Message-ID: <20081107174100.GA3469@x200.localdomain>
References: <49146265.8040301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:9828 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbYKGRhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 12:37:41 -0500
Received: by nf-out-0910.google.com with SMTP id d3so676072nfc.21
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 09:37:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49146265.8040301@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 07, 2008 at 04:44:37PM +0100, Eric Dumazet wrote:
> CONFIG_NET_NS is not a widespread option, we can reduce kernel size
> not declaring useless "struct net" pointers in several structures.

This can be done separatedly for each offending "struct net *".

> This patch declares three helper to clean various "ifdef CONFIG_NET_NS"
> that we have in many places.

There is an implicit assumption, that all such ifdefs are bad, while if fact
there are nothing wrong with them:

	#ifdef CONFIG_NET_NS
		struct net *ct_net;
	#endif

> #ifdef CONFIG_NET_NS
>
> #define DECLARE_PNET(name) struct net *name;

One more macro, instead of immediately understandable thing.

> static inline void write_pnet(struct net **pnet, struct net *net)
> {
>        *pnet = net;
> }
>
> static inline struct net *read_pnet(struct net * const *pnet)
> {
>        return *pnet;
> }
> #else
>
> #define DECLARE_PNET(name)
> #define write_pnet(pnet, net)   do { (void)(net);} while (0)
> #define read_pnet(pnet)         (&init_net)
>
> #endif
>
> In particular, using these helpers permits a shrink of inet_bind_bucket
> (16 bytes instead of 32 on 32bit arches, and 32 bytes instead of 64 on 64bits)

Why not just fix exactly bind bucket issue.

As I posted earlier, ->dst_net can go after IPv6 dst_ops can be embedded
directly into struct netns_ipv6, but header dependencies aren't trivial.

As for netns comparisons, use net_eq() to amortize the cost somewhat.
