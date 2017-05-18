From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Thu, 18 May 2017 18:33:28 +0200
Message-ID: <20170518163328.GD707@lunn.ch>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
 <20170518160943.GC707@lunn.ch>
 <CAMuHMdW_ZSn_nXSNRTHQwFioRD5UTotxKgm1eMqAP06n+cWv+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert+renesas-gXvu3+zWzMSzQB+pC5nmwQ@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux-Renesas <linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdW_ZSn_nXSNRTHQwFioRD5UTotxKgm1eMqAP06n+cWv+g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> >>               phy = get_phy_device(mdio, addr, is_c45);
> >>       if (IS_ERR(phy))
> >> -             return;
> >> +             return PTR_ERR(phy);
> >>
> >> -     rc = irq_of_parse_and_map(child, 0);
> >> +     rc = of_irq_get(child, 0);
> >> +     if (rc == -EPROBE_DEFER) {
> >> +             phy_device_free(phy);
> >> +             return rc;
> >> +     }
> >
> > Maybe this should be consistent. All other places there is an error,
> > you return it. Here however, you only return the error if it is
> > EPROBE_DEFER.
> 
> That's because of the "else" branch in the code below:
> 
>         if (rc > 0) {
>                 phy->irq = rc;
>                 mdio->irq[addr] = rc;
>         } else {
>                 phy->irq = mdio->irq[addr];
>         }
> 
> cfr. the marked part of the patch description.
> I didn't want to change that behavior, as it's not clear to me why it's handled
> that way.

So there seems to be 3 conditions that need handling:

1) of_irq_get() gives us an interrupt number.
2) of_irq_get() indicates there is no irq in the device tree.
3) of_irq_get() indicates a real error

1) We have.

2) We should fall back to using the mdio busses irq for the
device. There are a couple of mdio drivers which do this, e.g.
stmicro/stmmac/stmmac_mdio.c. mdiobus_alloc() ensures it is set to
PHY_POLL, so if the driver does not set it, we poll.

3) This is new. We have two choices. Ignore the error and poll. Or
return the error. Historically we have ignored the error. But should
we? I would probably return the error, now that we can. But...

Florian?

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
