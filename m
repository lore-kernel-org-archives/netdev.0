From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Mon, 23 Jan 2012 10:12:41 +0100
Message-ID: <20120123091241.GA23374@1984>
References: <1326448338-13416-1-git-send-email-hans.schillstrom@ericsson.com>
 <1326448338-13416-3-git-send-email-hans.schillstrom@ericsson.com>
 <20120122214434.GA20543@1984>
 <201201230020.20857.hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, kaber@trash.net,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201201230020.20857.hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 23, 2012 at 12:20:15AM +0100, Hans Schillstrom wrote:
> The text should clarify that this is valid for the fragments not the "flow"
> 
> > I've got one scenario that may break with this assumption:
> > 
> > 1) your traffic follows one path over router A and B to reach your
> >    firewall F which requires no fragmentation at all.
> > 2) path to router B becomes broken while there are established flows
> >    with firewall F.
> > 3) router A decides to forward packets to router C, which fragment
> >    packets because it is using smaller MTU than router A.
> > 4) packets arrive to firewall F, then hashing is calculated based on
> >    addresses, not ports, and you load-sharing becomes inconsistent.
> > 
> > This can rarely happen, but it does, it would break.
> > 
> > To fix this, I think that HMARK requires that you have to specify the
> > hashing strategy. If you want to support fragments, use only
> > addresses. If you're sure you will not get fragments, use layer 3 and
> > layer 4 information.
> 
> I know but if you use conntrack, fragments will not be seen by HMARK
> (except for IPv6 until Patric has fix the IPv6 defrag)

Please, read the scenario, I'm not talking about conntrack this time.

> We handle this by not having stateful FW:s when connected to external routers.
> Fragments will take an extra turn to a container with conntrack and there
> HMARK works as on the unfragmented packets in the flow.

Yes, I got the idea. Indeed HMARK can be very useful in other situations,
like cluster-based OSPF setups with stateful firewalls following a
similar approach.

However, you don't reply to my scenario. What I'm telling is that,
even with conntrack disabled, HMARK is not consistent if you start
receiving fragments at some point.

[...]
> > > +/*
> > > + * ICMP, get inner header so calc can be made on the source message
> > > + *
> > > + * iphsz: ip header size in bytes
> > > + * nhoff: network header offset
> > > + * return; updated nhoff if an icmp error
> > > + */
> > 
> > Please, remove these comments:
> 
> No problems

Thanks.

> > > +struct _icmpv6_errh {
> > > +	__u8		icmp6_type;
> > > +	__u8		icmp6_code;
> > > +	__u16		icmp6_cksum;
> > > +	__u32		icmp6_nu;
> > > +};
> > 
> > Interesting, by quick search, I don't find this structure defined
> > elsewhere, why?
> > 
> I have no idea ...
> the closest is "struct icmp6hdr" but it contains everythingi

have a look at offsetof, you can use the existing structure but tell
skb_copy_header to copy only the part you're interested. Add a comment
telling what you're only copying part of the header to warn others (in
this case, the comment becomes useful since it clarifies something
that you may not notice at a first glance by looking at the code).

[...]
> > > +	if (!info->hmod)
> > > +		return XT_CONTINUE;
> > 
> > why this? check in user-space that libxt_HMARK does not send this to
> > kernel-space and check it again in checkentry().
> 
> Well, better safe than ... divide by zero
> 
> OK, it very very unlikely that it becomes zero
> so if you want I can remove that check.

*Extremely unlikely*, I'd say :-). If you double check that hmod is
non-zero in user-space and checkentry(), we will not hit that branch
ever. Moreover, that branch is in the hot path while the others are
only configure-time paths.
