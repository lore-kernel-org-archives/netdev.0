From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Sun, 2 Jul 2017 22:37:45 +0200
Message-ID: <CAMuHMdW8yzREzTE4GiW_8HU9h-T-fdDmLtZAXYkJrjuypN8BDg@mail.gmail.com>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
 <f0ed61c3-062b-cec6-fe19-7412231e8ef1@gmail.com> <CAMuHMdWYeSzofU57LmT_M3KkcHhvjfJy7nkHvcXkKzOYmvhqqA@mail.gmail.com>
 <20170518193453.GB13759@lunn.ch> <CAMuHMdV+jfh=EGt3SvjtrtVfWQ6P8ofp_JxeQZjRrSEfDWs5hA@mail.gmail.com>
 <08a89dd5-b707-8b8f-b8e1-e20b9ed630b7@gmail.com> <CAMuHMdWWfaP8=H7H+UzrmOYpydi2mGLFGzuk9FQWJtEOug6u5g@mail.gmail.com>
 <CAMuHMdUt6yOQ9=02z_7WG58YGxFYD=_zn7SeLEqGmfTrNBFJXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux-Renesas <linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMuHMdUt6yOQ9=02z_7WG58YGxFYD=_zn7SeLEqGmfTrNBFJXw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 6, 2017 at 11:43 AM, Geert Uytterhoeven
<geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> wrote:
> On Tue, May 23, 2017 at 11:36 AM, Geert Uytterhoeven
> <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org> wrote:
>> On Fri, May 19, 2017 at 12:21 AM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> On 05/18/2017 01:36 PM, Geert Uytterhoeven wrote:
>>>> On Thu, May 18, 2017 at 9:34 PM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
>>>>>>> This most certainly works fine in the simple case where you have one PHY
>>>>>>> hanging off the MDIO bus, now what happens if you have several?
>>>>>>>
>>>>>>> Presumably, the first PHY that returns EPROBE_DEFER will make the entire
>>>>>>> bus registration return EPROB_DEFER as well, and so on, and so forth,
>>>>>>> but I am not sure if we will be properly unwinding the successful
>>>>>>> registration of PHYs that either don't have an interrupt, or did not
>>>>>>> return EPROBE_DEFER.
>>>>>>>
>>>>>>> It should be possible to mimic this behavior by using the fixed PHY, and
>>>>>>> possibly the dsa_loop.c driver which would create 4 ports, expecting 4
>>>>>>> fixed PHYs to be present.
>>>>>>
>>>>>> mdiobus_unregister(), called from of_mdiobus_register() on failure,
>>>>>> should do the unwinding, right?
>>>>>>
>>>>>> And when the driver is reprobed, all PHYs are reprobed, until they all
>>>>>> succeed.
>>>>>
>>>>> That is the theory. I looked at that while reviewing the patch. But
>>>>> this has probably not been tested in anger. It would be good to test
>>>>> this properly, with not just the first PHY returning -EPROBE_DEFER, to
>>>>> really test the unwind.
>>>>
>>>> Unfortunately I don't have a board with multiple PHYs, so I cannot test
>>>> that case.
>>
>> I tried adding a few dummy PHYs in DT, but that didn't work.
>>
>> So how can we proceed?
>>
>> I think the only way my patch can cause issues is because some systems
>> may rely on EPROBE_DEFER errors being ignored.
>>
>>>> Does unbinding/rebinding a network driver with multiple PHYs currently
>>>> work? Or module unload/reload?
>>>
>>> Usually there is a strict 1:1 mapping between a network device (not
>>> driver) and a PHY device, switch drivers however, would have multiple
>>> PHYs (one per port, aka net_deice).
>>>
>>> NB: binding and unbinding of PHYs is pretty broken at the moment though,
>>> because there is a complete disconnect between what the Ethernet MAC
>>> expects, and the state in which the PHY is. I had some patches to fix
>>> that, but this turned out to be playing whack-a-mole which I typically
>>> suck at.
>>
>> I didn't mean unbinding the PHY, but the network device.
>> Don't you have the same issue with the state of PHYs as left by the bootloader?
>
> Anyone who can test the behavior on an Ethernet device with multiple PHYs,
> e.g. by faking an -EPROBE_DEFER somewhere in the middle?
>
> I'd like to get this issue fixed in v4.13, to avoid a regression when migrating
> several systems to a new and better clock driver in v4.14, which will trigger
> EPROBE_DEFER.

Ping?

This patch fixes a real issue.

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
