From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: Re: [PATCH] drivers: net: cpsw: fix RMII/RGMII mode when used with
 fixed-link PHY
Date: Mon, 14 Dec 2015 13:04:46 -0500
Message-ID: <20151214130446.1e14fbb8.drivshin.allworx@gmail.com>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com>
	<6416396.ZOturxhSar@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:34363 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685AbbLNSEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 13:04:49 -0500
In-Reply-To: <6416396.ZOturxhSar@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Dec 2015 16:44:19 +0100
Markus Brunner <systemprogrammierung.brunner@gmail.com> wrote:

> On Wednesday 09 December 2015 22:31:15 David Rivshin wrote:
> ...
> > This patch was originally developed in parallel with 1f71e8c96fc6 to
> > accomplish the same goal. When I replaced this patch with
> > 1f71e8c96fc6, I found that it did not work on my hardware (which
> > uses RGMII), so I am submitting this patch now as a bugfix. 
> 
> Your patch works fine on my board, which uses MII and dual_emac with
> a fixed_phy and a real one. 

Thanks for checking. The only dual_emac board I have available is the 
EVMSK, which has two real PHYs. I'm not sure of the usual etiquette 
(and Google was  unhelpful), should I add a Tested-by on the next 
version?

> > Besides fixing the bug mentioned in the commit log, there are a few
> > other differences to note:
> >  * If both "phy_id" and a "fixed-link" subnode are present this
> > patch will use the "phy_id" property. This should preserve current
> > behavior with existing devicetrees that might incorrectly have
> > both. This motivates the biggest difference in code organization
> > from 1f71e8c96fc6.
> >  * Some error messages have been tweaked to reflect the slightly
> > changed meanings of the checks.
> 
> I wanted to keep changes small and didn't spend too much thinking
> about already broken devicetrees. Since my patch is quite new, I

I'm honestly not sure it's an important consideration myself. Most
patches I've seen in this area for this or other drivers do not take 
such behavior into account (e.g. the phy-handle parsing that went in 
to cpsw in 4.3).
I would generally feel more comfortable with such a behavior tweak
(minor as it is) before 4.4 is released, to avoid ping-ponging the
behavior. But given how far along the cycle is, I'm not sure about 
the chances of that.

> don't see any problems with subtle changes like that. However you
> should update the documentation as well. 

Your patch already updated .../bindings/net/cpsw.txt, which this
patch left alone. Are you referring to some other documentation, 
or do you think I should update the binding documentation to state
that phy_id takes precedence over fixed-link? I figured that such
devicetrees were still officially malformed, so I thought the 
existing text was appropriate.

> >  * of_node_get() is called on slave_node before passing the result
> > to of_phy_find_device(). This increments the reference count, which
> > I believe is correct for this situation, but I'm not certain of
> > that.
> I think you are right. At least most other drivers calling
> of_phy_register_fixed_link(), call of_node_get afterwards. I can't
> remember where I got my "inspiration" for the patch. I made it almost
> a year ago and now 3 other guys tinker with the same feature? What a
> coincidence ;-)

Perhaps not a complete coincidence. I first wrote this patch a few 
months ago against 4.1. While I had always intended on submitting when 
time allowed, testing your patch gave me an extra push.

[...]

> > --- a/drivers/net/ethernet/ti/cpsw.c
> > +++ b/drivers/net/ethernet/ti/cpsw.c
> > @@ -26,6 +26,7 @@
> >  #include <linux/netdevice.h>
> >  #include <linux/net_tstamp.h>
> >  #include <linux/phy.h>
> > +#include <linux/phy_fixed.h>
> 
> The prototypes for of_*_fixed_link are in linux/of_mdio.h, which is
> already included.

You are correct; I forget why I had originally included that. I will 
remove it for v2.
