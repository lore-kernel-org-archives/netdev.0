From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: net: vrf: Handle ipv6 multicast and link-local addresses
Date: Thu, 4 Aug 2016 11:43:25 +0200
Message-ID: <CAMuHMdWd1mYcPFU6Xntr96AkHoiZ_gOC61Oe_pnHcq1mWfoRdA@mail.gmail.com>
References: <20160727215224.EB4E26611D4@gitolite.kernel.org>
 <CAMuHMdU6zpowkWgUW0+8Fhx7BmwTn=FvVBoTKXUgNzLeBpFrHg@mail.gmail.com>
 <1d0eb1d8-708f-2238-37c9-b75004804065@cumulusnetworks.com>
 <CAMuHMdWGX3owP=xr-hhr6gE9PFRFc55Rzsc1M1JVoFLHdmuUYQ@mail.gmail.com>
 <b23bf44d-1334-cbbc-6fa3-e1705a8e06f0@cumulusnetworks.com>
 <CAMuHMdUJj3SMrizMDxBPdDwmZRivasyfMUmA1ik7h2QxY5KKgw@mail.gmail.com> <b8b9a578-2a69-1b99-f919-f7d2e937846c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b8b9a578-2a69-1b99-f919-f7d2e937846c@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Thu, Aug 4, 2016 at 7:01 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Does making the code the same between those 2 functions matter?

Yes, it does make the warning go away.

> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index 1ce7420322ee..3951a2c98431 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -862,15 +862,17 @@ static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
>                               int ifindex)
>  {
>         const struct ipv6hdr *iph = ipv6_hdr(skb);
> +       struct net *net = dev_net(vrf_dev);
>         struct flowi6 fl6 = {
> +               .flowi6_oif     = 0,
> +               .flowi6_iif     = ifindex,
>                 .daddr          = iph->daddr,
>                 .saddr          = iph->saddr,
>                 .flowlabel      = ip6_flowinfo(iph),
>                 .flowi6_mark    = skb->mark,
>                 .flowi6_proto   = iph->nexthdr,
> -               .flowi6_iif     = ifindex,
> +               .flowi6_flags   = 0,
>         };
> -       struct net *net = dev_net(vrf_dev);
>         struct rt6_info *rt6;

The critical change seems to be moving the initialization of
.flowi6_iif: if that
is done before the initialization of .flowlabel, there's no compiler warning.

The generated asm output is identical, though, so I think this is some sort of
false positive or compiler bug. Hence let's ignore it.

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
