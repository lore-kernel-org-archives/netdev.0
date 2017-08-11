From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 2/2] drivers: add vpls support
Date: Fri, 11 Aug 2017 14:55:47 +0200
Message-ID: <20170811125547.GZ773745@eidolon>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-3-git-send-email-amine.kherbouche@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:56238 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752631AbdHKMzu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 08:55:50 -0400
Content-Disposition: inline
In-Reply-To: <1502396917-14848-3-git-send-email-amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 10:28:37PM +0200, Amine Kherbouche wrote:
> This commit introduces the support of VPLS virtual device, that allows
> performing  L2VPN multipoint to multipoint communication over MPLS PSN.
> 
> VPLS device encap received ethernet frame over mpls packet and send it the
> output device, in the other direction, when receiving the right configured
> mpls packet, the matched mpls route calls the handler vpls function,
> then pulls out the mpls header and send it back the entry point via
> netif_rx().
> 
> Two functions, mpls_entry_encode() and mpls_output_possible() are
> exported from mpls/internal.h to be able to use them inside vpls driver.
> 
> Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>

This code is derivative of code that I authored;  while you
significantly changed it I'd appreciate if you kept a hint of that.

Unfortunately, I also have some concerns with this patch...

> +#define VPLS_MAX_ID		256	/* Max VPLS WireID (arbitrary) */

There is no point in keeping a VPLS wire ID.  Again, this was in the
README that accompanied my patchset:

- I made a design mistake with the wire ID.  It's simply not needed.  A
  pseudowire can be identified by its incoming label.  There is also some
  really ugly code keeping an array of wires...

I don't even see where you're using the wire ID anymore at this point,
it might be a dead leftover from my code.

[...]
> +union vpls_nh {
> +	struct in6_addr		addr6;
> +	struct in_addr		addr;
> +};
> +
> +struct vpls_dst {
> +	struct net_device	*dev;
> +	union vpls_nh		addr;
> +	u32			label_in, label_out;
> +	u32			id;
> +	u16			vlan_id;

I looked at VLAN support and decided against it because the bridge layer
can handle this perfectly fine by using the bridge's vlan support to tag
a port's pvid.

> +	u8			via_table;
> +	u8			flags;
> +	u8			ttl;
> +};

[...]
> +struct vpls_priv {
> +	struct net		*encap_net;
> +	struct vpls_dst		dst;
> +};
> +
> +static struct nla_policy vpls_policy[IFLA_VPLS_MAX + 1] = {
> +	[IFLA_VPLS_ID]		= { .type = NLA_U32 },
> +	[IFLA_VPLS_IN_LABEL]	= { .type = NLA_U32 },
> +	[IFLA_VPLS_OUT_LABEL]	= { .type = NLA_U32 },
> +	[IFLA_VPLS_OIF]		= { .type = NLA_U32 },
> +	[IFLA_VPLS_TTL]		= { .type = NLA_U8  },
> +	[IFLA_VPLS_VLANID]	= { .type = NLA_U8 },
> +	[IFLA_VPLS_NH]		= { .type = NLA_U32 },
> +	[IFLA_VPLS_NH6]		= { .len = sizeof(struct in6_addr) },
> +};

The original patchset was point-to-multipoint in a single netdev, and
had some starts on optimized multicast support (which, admittedly, is a
bit of a fringe thing, but still.)

This patch implements a single pseudowire (so the name is kind of
misleading; it's a VLL / VPWS, multiple of which you'd use to build full
VPLS).  However, you are now missing split-horizon ethernet bridging
support.  How is that done here?


-David


P.S.: for anyone curious, the original patchset is at
https://github.com/eqvinox/vpls-linux-kernel
I didn't go ahead with posting it because I felt there were several
things where I'd want to change the design, hence this README:
https://github.com/eqvinox/vpls-linux-kernel/commit/81c809d6f9c40c0332098e13fcad65144aa51795
