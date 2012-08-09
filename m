From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 19/19] netfilter: ip6tables: add stateless IPv6-to-IPv6
 Network Prefix Translation target
Date: Thu, 9 Aug 2012 23:55:03 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1208092337220.10514@frira.zrqbmnf.qr>
References: <1344542943-11588-1-git-send-email-kaber@trash.net> <1344542943-11588-20-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([5.9.24.206]:35941 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132Ab2HIVzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 17:55:06 -0400
In-Reply-To: <1344542943-11588-20-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2012-08-09 22:09, kaber@trash.net wrote:
>+config IP6_NF_TARGET_NPT
>+	tristate "NPT (Network Prefix translation) target support"
>+	depends on NETFILTER_ADVANCED
>+	help
>+	  This option adda `SNPT' and `DNPT' target, which perform stateless
>+	  IPv6-to-IPv6 Network Prefix Translation (RFC 6296).

Fixes/suggestion in the help text (near "adda" and subsequent).

config IP6_NF_TARGET_NPT
	tristate "NPT (Network Prefix translation) target support"
	depends on NETFILTER_ADVANCED
	---help---
	This option adds the "SNPT" and "DNPT" targets, which perform stateless
	IPv6-to-IPv6 Network Prefix Translation per RFC 6296.

>+/*
>+ * Copyright (c) 2011, 2012 Patrick McHardy <kaber@trash.net>
>+ *
>+ * This program is free software; you can redistribute it and/or modify
>+ * it under the terms of the GNU General Public License version 2 as
>+ * published by the Free Software Foundation.
>+ */

GNU sometimes has a strange way of expressing their (C) lines,
listing all years separately, as if "1989-1991,1994-1999,2001-2005" was not
sufficient. In your case, would "2011-2012" work?

Any objection to adding a "(or later)" clause to the set?

>+static int ip6t_npt_checkentry(const struct xt_tgchk_param *par)
>+{
>+	struct ip6t_npt_tginfo *npt = par->targinfo;
>+	__sum16 src_sum = 0, dst_sum = 0;
>+	unsigned int i;
>+
>+	if (npt->src_pfx_len > 64 || npt->dst_pfx_len > 64)
>+		return -EINVAL;

While the RFC probably only specifies masks up to /64,
the general algorithm is sustainable up to at least /96.

Extending the RFC's section 3.6 ("/48 Prefix Mapping") example,
fd01:0203:0405:0001:0000:0000:0000:1234/112 (specification per `ip
addr`) would become 2001:0db8:0001:0000:0000:0000:d550:1234.

Not everybody runs exclusively on EUI64-SLAAC / PRIVACY addresses :)


>+static struct xt_target ip6t_npt_target_reg[] __read_mostly = {
>+	{
>+		.name		= "SNPT",

IETF did quite a job again... NPT as an acronym is quite
close to NAPT - too close.
Since it's essentially NETMAP, having something in that ballpark
may seem more fitting. NPMAP? (Translation is mapping -
henceforh "Network Prefix Mapping")



I would hint towards choosing a different name; the P in NPT
may be (mis)understood as port (due to the common "NAPT")
keyword.

>+		.target		= ip6t_snpt_tg,
>+		.targetsize	= sizeof(struct ip6t_npt_tginfo),
>+		.checkentry	= ip6t_npt_checkentry,
>+		.family		= NFPROTO_IPV6,
>+		.hooks		= (1 << NF_INET_LOCAL_IN) |
>+				  (1 << NF_INET_POST_ROUTING),
>+		.me		= THIS_MODULE,

Should perhaps a  .table = "mangle"  be added?


Are any tricks on the userspace side needed to use SNPT/SNPMAP?
Since I spot no code telling conntrack about the address mingling,
one would have to use -j CT --notrack or the rawpost table, like
it's done for RAWSNAT in xtables-addons, would he not?
