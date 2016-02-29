From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 1/5] vxlan: implement GPE in L2 mode
Date: Mon, 29 Feb 2016 11:23:22 +0100
Message-ID: <20160229112322.4da0f0c0@griffin>
References: <cover.1456472746.git.jbenc@redhat.com>
	<6fe53252314d644e994950522d4320bc54ced928.1456472746.git.jbenc@redhat.com>
	<CALx6S34vm6nqce481mcH_S3sfc4B5ift7YwJmTba4Vvdvnmj3w@mail.gmail.com>
	<20160227203142.5b7309f3@griffin>
	<CALx6S358JT6HRR70SgJrNOsTg4LbnTXERpW6n0DDiXKqxg--Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752305AbcB2KX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 05:23:28 -0500
In-Reply-To: <CALx6S358JT6HRR70SgJrNOsTg4LbnTXERpW6n0DDiXKqxg--Yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 Feb 2016 12:54:52 -0800, Tom Herbert wrote:
> Yes, but RCO has not been specified for VXLAN-GPE either

As far as I can see, RCO will just work with VXLAN-GPE. But I have no
problem disallowing them to be set together, if you prefer that.

> so the patch
> does not correctly refuse setting those two together. Inevitably
> though, those and other extensions will defined for VXLAN-GPE and new
> ones for VXLAN. Again, the protocols are fundamentally incompatible,
> so instead of trying to enforce each valid combination at
> configuration

We need to do the checking in either case. If we accepted unsupported
combinations and then just silently ignored them, we'd be in troubles
later when such combination becomes defined/supported. There would be
no way for the userspace tools to detect whether a particular kernel
supports the combination or not.

So, we need to check for supported combination of options during
configuration anyway.

And when we have that, I don't really see the reason for doing that
kind of code duplication that you suggest.

> or performing multiple checks for flavor each time we
> look at a packet, it seems easier to split the parsing with at most
> one check for the protocol variant. For instance in
> vxlan_udp_encap_recv just do:
> 
> if (vs->flags & VXLAN_F_GPE)
>                if (!vxlan_parse_gpe_hdr(&unparsed, skb, vs->flags))
>                        goto drop;
> else
>                if (!vxlan_parse_gpe(&unparsed, skb, vs->flags))
>                        goto drop;

Most of the code of these two functions will be identical. To
consolidate that as much as possible, you'll end up with what I have or
something very similar.

> And then move REMCSUM and GPB and other protocol specific checks to
> the right function.

And when RCO is defined for GPE, we copy the code? Doesn't make sense,
sorry.

If you look at the code in the current net-next (and the code after
this patchset), the extension handling has been made generic and each
extension gets its own handler function, leading to clean separation in
the code. There's no reason to split the vxlan_rcv into two functions
doing the same things but with slightly different calls to extensions.

 Jiri
