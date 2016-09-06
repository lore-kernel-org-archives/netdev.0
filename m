From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [v11, 7/8] base: soc: introduce soc_device_match() interface
Date: Tue, 06 Sep 2016 14:46:08 +0200
Message-ID: <6515108.aCEls7dUuW@wuerfel>
References: <1473150503-9550-1-git-send-email-yangbo.lu@nxp.com> <1473150503-9550-8-git-send-email-yangbo.lu@nxp.com> <CAPDyKFrvg3Qr5m3xXvywsCoVvaiF7ggHAj0Aw=WCOXg65Pt0PQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>,
        linux-mmc <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>,
        "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-clk <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
        Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
        Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>,
        Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
        Bhupesh Sharm
To: Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPDyKFrvg3Qr5m3xXvywsCoVvaiF7ggHAj0Aw=WCOXg65Pt0PQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday, September 6, 2016 1:44:23 PM CEST Ulf Hansson wrote:
> On 6 September 2016 at 10:28, Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org> wrote:
> > We keep running into cases where device drivers want to know the exact
> > version of the a SoC they are currently running on. In the past, this has
> > usually been done through a vendor specific API that can be called by a
> > driver, or by directly accessing some kind of version register that is
> > not part of the device itself but that belongs to a global register area
> > of the chip.

Please add "From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>" as the first line, to
preserve authorship. If you use "git send-email" or "git format-patch",
that should happen automatically if the author field is set right
(if not, use 'git commit --amend --author="Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>"'
to fix it).

> > +
> > +/*
> > + * soc_device_match - identify the SoC in the machine
> > + * @matches: zero-terminated array of possible matches
> 
> Perhaps also express the constraint on the matching entries. As you
> need at least one of the ->machine(), ->family(), ->revision() or
> ->soc_id() callbacks implemented, right!?

They are not callbacks, just strings. Having an empty entry indicates
the end of the array, and this is not called.

> > + *
> > + * returns the first matching entry of the argument array, or NULL
> > + * if none of them match.
> > + *
> > + * This function is meant as a helper in place of of_match_node()
> > + * in cases where either no device tree is available or the information
> > + * in a device node is insufficient to identify a particular variant
> > + * by its compatible strings or other properties. For new devices,
> > + * the DT binding should always provide unique compatible strings
> > + * that allow the use of of_match_node() instead.
> > + *
> > + * The calling function can use the .data entry of the
> > + * soc_device_attribute to pass a structure or function pointer for
> > + * each entry.
> 
> I don't get the use case behind this, could you elaborate?
> 
> Perhaps we should postpone adding the .data entry until we actually
> see a need for it?

I think the interface is rather useless without a way to figure
out which entry you got. Almost all users of of_match_node()
actually use the returned ->data field, and I expect this to
be the same here.

> > + */
> > +const struct soc_device_attribute *soc_device_match(
> > +       const struct soc_device_attribute *matches)
> > +{
> > +       struct device *dev;
> > +       int ret;
> > +
> > +       for (ret = 0; ret == 0; matches++) {
> 
> This loop looks a bit weird and unsafe.

Ah, and I thought I was being clever ;-)

> 1) Perhaps using a while loop makes this more readable?
> 2) As this is an exported API, I guess validation of the ->matches
> pointer needs to be done before accessing it.

Sounds fine.

> > +               if (!(matches->machine || matches->family ||
> > +                     matches->revision || matches->soc_id))
> > +                       return NULL;
> > +               dev = NULL;
> 
> There's no need to use a struct device just to assign it to NULL.
> Instead just provide the function below with NULL.
>
> > +               ret = bus_for_each_dev(&soc_bus_type, dev, (void *)matches,
> > +                                      soc_device_match_one);


I don't remember what led to this, I think you are right, we should
just pass NULL as most other callers.

Thanks for the review.

	ARnd

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
