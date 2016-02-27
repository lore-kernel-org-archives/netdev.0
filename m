From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/5] vxlan: implement GPE in L2 mode
Date: Sat, 27 Feb 2016 12:54:52 -0800
Message-ID: <CALx6S358JT6HRR70SgJrNOsTg4LbnTXERpW6n0DDiXKqxg--Yg@mail.gmail.com>
References: <cover.1456472746.git.jbenc@redhat.com>
	<6fe53252314d644e994950522d4320bc54ced928.1456472746.git.jbenc@redhat.com>
	<CALx6S34vm6nqce481mcH_S3sfc4B5ift7YwJmTba4Vvdvnmj3w@mail.gmail.com>
	<20160227203142.5b7309f3@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35213 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756728AbcB0Uyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 15:54:53 -0500
Received: by mail-io0-f177.google.com with SMTP id g203so153212665iof.2
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 12:54:53 -0800 (PST)
In-Reply-To: <20160227203142.5b7309f3@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 27, 2016 at 11:31 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Fri, 26 Feb 2016 15:51:29 -0800, Tom Herbert wrote:
>> I don't think this is right. VXLAN-GPE is a separate protocol than
>> VXLAN, they are not compatible on the wire and don't share flags or
>> fields (for instance GPB uses bits in VXLAN that hold the next
>> protocol in VXLAN-GPE). Neither is there a VXLAN_F_GPE flag defined in
>> VXLAN to differentiate the two. So VXLAN-GPE would be used on a
>> different port
>
> Yes, and that's exactly what this patchset does. If there's the
> VXLAN_F_GPE flag defined while creating the interface, the used UDP
> port defaults to the VXLAN-GPE UDP port (but can be overriden) and the
> driver expects that all packets received are VXLAN-GPE.
>
> Note also that you can't define both GPE and GBP together, because as
> you noted, they're not compatible. The driver correctly refuses such
> combination.
>
Yes, but RCO has not been specified for VXLAN-GPE either so the patch
does not correctly refuse setting those two together. Inevitably
though, those and other extensions will defined for VXLAN-GPE and new
ones for VXLAN. Again, the protocols are fundamentally incompatible,
so instead of trying to enforce each valid combination at
configuration or performing multiple checks for flavor each time we
look at a packet, it seems easier to split the parsing with at most
one check for the protocol variant. For instance in
vxlan_udp_encap_recv just do:

if (vs->flags & VXLAN_F_GPE)
               if (!vxlan_parse_gpe_hdr(&unparsed, skb, vs->flags))
                       goto drop;
else
               if (!vxlan_parse_gpe(&unparsed, skb, vs->flags))
                       goto drop;

And then move REMCSUM and GPB and other protocol specific checks to
the right function.

Tom
