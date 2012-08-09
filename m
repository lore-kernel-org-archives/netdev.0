From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 19/19] netfilter: ip6tables: add stateless IPv6-to-IPv6
 Network Prefix Translation target
Date: Fri, 10 Aug 2012 00:25:36 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208100000140.26308@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
 <1344542943-11588-20-git-send-email-kaber@trash.net>
 <alpine.LNX.2.01.1208092337220.10514@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1208092337220.10514@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Aug 2012, Jan Engelhardt wrote:

>
> On Thursday 2012-08-09 22:09, kaber@trash.net wrote:
>> +config IP6_NF_TARGET_NPT
>> +	tristate "NPT (Network Prefix translation) target support"
>> +	depends on NETFILTER_ADVANCED
>> +	help
>> +	  This option adda `SNPT' and `DNPT' target, which perform stateless
>> +	  IPv6-to-IPv6 Network Prefix Translation (RFC 6296).
>
> Fixes/suggestion in the help text (near "adda" and subsequent).
>
> config IP6_NF_TARGET_NPT
> 	tristate "NPT (Network Prefix translation) target support"
> 	depends on NETFILTER_ADVANCED
> 	---help---
> 	This option adds the "SNPT" and "DNPT" targets, which perform stateless
> 	IPv6-to-IPv6 Network Prefix Translation per RFC 6296.

Thanks, changes.

>> +/*
>> + * Copyright (c) 2011, 2012 Patrick McHardy <kaber@trash.net>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License version 2 as
>> + * published by the Free Software Foundation.
>> + */
>
> GNU sometimes has a strange way of expressing their (C) lines,
> listing all years separately, as if "1989-1991,1994-1999,2001-2005" was not
> sufficient. In your case, would "2011-2012" work?
>
> Any objection to adding a "(or later)" clause to the set?

Yeah this is a stupid habit that doesn't matter anyway, in all
jurisdictions I care about copyright duration is based on the
lifetime of the author. I'll try to find out whether just adding
a copyright statement without any specific year would be fine
for my purposes.

>> +static int ip6t_npt_checkentry(const struct xt_tgchk_param *par)
>> +{
>> +	struct ip6t_npt_tginfo *npt = par->targinfo;
>> +	__sum16 src_sum = 0, dst_sum = 0;
>> +	unsigned int i;
>> +
>> +	if (npt->src_pfx_len > 64 || npt->dst_pfx_len > 64)
>> +		return -EINVAL;
>
> While the RFC probably only specifies masks up to /64,
> the general algorithm is sustainable up to at least /96.
>
> Extending the RFC's section 3.6 ("/48 Prefix Mapping") example,
> fd01:0203:0405:0001:0000:0000:0000:1234/112 (specification per `ip
> addr`) would become 2001:0db8:0001:0000:0000:0000:d550:1234.
>
> Not everybody runs exclusively on EUI64-SLAAC / PRIVACY addresses :)

I'll think about it. If you want to send a patch, please go ahead ;)

>> +static struct xt_target ip6t_npt_target_reg[] __read_mostly = {
>> +	{
>> +		.name		= "SNPT",
>
> IETF did quite a job again... NPT as an acronym is quite
> close to NAPT - too close.
> Since it's essentially NETMAP, having something in that ballpark
> may seem more fitting. NPMAP? (Translation is mapping -
> henceforh "Network Prefix Mapping")

So we'd have SNPMAP and DNPMAP. I like NPMAP, but SNPMAP and DNPMAP
don't sound that much better, so I think I prefer keeping the currently
used abrevation of Network Prefix Translation. I don't care much though.

> I would hint towards choosing a different name; the P in NPT
> may be (mis)understood as port (due to the common "NAPT")
> keyword.

Well, I think people using computers are used to tons of similar
sounding acronyms and abrevations. They'll manage ;)

>> +		.target		= ip6t_snpt_tg,
>> +		.targetsize	= sizeof(struct ip6t_npt_tginfo),
>> +		.checkentry	= ip6t_npt_checkentry,
>> +		.family		= NFPROTO_IPV6,
>> +		.hooks		= (1 << NF_INET_LOCAL_IN) |
>> +				  (1 << NF_INET_POST_ROUTING),
>> +		.me		= THIS_MODULE,
>
> Should perhaps a  .table = "mangle"  be added?

I've been proposing to lift the mangle restriction on all targets
for years. Basically the only special thing about the mangle table
is rerouting on mark changes. Everything else works just fine in
other tables (with NAT being somewhat special as well), even marking
packets if you don't need rerouting, its even more performant in that
case since no extra routing lookups need to be done. So I don't see
a reason to impose artificial limitations.

> Are any tricks on the userspace side needed to use SNPT/SNPMAP?
> Since I spot no code telling conntrack about the address mingling,
> one would have to use -j CT --notrack or the rawpost table, like
> it's done for RAWSNAT in xtables-addons, would he not?

Yes, if connection tracking is used (which is not necessary of course)
its best to exclude the translated packets from tracking. There's
actually a lot of potential for improvement here. One thing is telling
connection tracking, if its used, about the translations, so it can
properly track packets. Another thing is, with stateless translation
you still need ALGs to take care of addresses in layer 7 protocols.
I've been thinking about how to make the existing NAT helpers work
without conntrack and NAT, but its not easy and requires a lot of
restructuring of the existing code. Its something we can still add
later, its something that just affects the kernel.

