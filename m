From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH v5] NET: Add ezchip ethernet driver
Date: Mon, 22 Jun 2015 19:47:51 -0400
Message-ID: <20150622234749.GA21581@windriver.com>
References: <1434263193-16877-1-git-send-email-noamc@ezchip.com>
 <1434465342-7412-1-git-send-email-noamc@ezchip.com>
 <CAF2d9jgQRatz_wL5+xk7fH=gAXTixb1yNVZGnenmKwR9RoSQLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Noam Camus <noamc@ezchip.com>,
	linux-netdev <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <Alexey.Brodkin@synopsys.com>,
	<vgupta@synopsys.com>, <giladb@ezchip.com>, <cmetcalf@ezchip.com>,
	Tal Zilcer <talz@ezchip.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:37284 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbbFVXt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 19:49:59 -0400
Content-Disposition: inline
In-Reply-To: <CAF2d9jgQRatz_wL5+xk7fH=gAXTixb1yNVZGnenmKwR9RoSQLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH v5] NET: Add ezchip ethernet driver] On 22/06/2015 (Mon 10:45) Mahesh Bandewar wrote:

> On Tue, Jun 16, 2015 at 7:35 AM, Noam Camus <noamc@ezchip.com> wrote:
> >
> > From: Noam Camus <noamc@ezchip.com>
> >
> > Simple LAN device for debug or management purposes.
> > Device supports interrupts for RX and TX(completion).
> > Device does not have DMA ability.
> >
> > Signed-off-by: Noam Camus <noamc@ezchip.com>
> > Signed-off-by: Tal Zilcer <talz@ezchip.com>
> > Acked-by: Alexey Brodkin <abrodkin@synopsys.com>
> > ---
> > Change log for v5:
> > Basically its all based on Florian comments.
> > Main items are:
> > 1) Move all interrupt chore to bottom-half
> > 2) use memcpy_toio/fromio
> > 3) dev_kfree_skb() moved to bottom-half
> > 4) add set_rx_mode callback
> > 5) use platform api toward non-DT platforms
> > ---

[...]

> > diff --git a/drivers/net/ethernet/ezchip/Kconfig b/drivers/net/ethernet/ezchip/Kconfig
> > new file mode 100644
> > index 0000000..d031177
> > --- /dev/null
> > +++ b/drivers/net/ethernet/ezchip/Kconfig
> > @@ -0,0 +1,27 @@
> > +#
> > +# EZchip network device configuration
> > +#
> > +
> > +config NET_VENDOR_EZCHIP
> > +       bool "EZchip devices"
> > +       default y
> >
> Why this has to be included in the default build? Shouldn't it be
> either "m" or "N" by default?
> 

Mahesh, in the future please don't quote 1200 lines of code in its
entirety just to add these two lines of comment, which in this case
happen to also be incorrect.  It is a NET_VENDOR_<name> option which
is just the lead in as it clearly states below if we go look...

> > +       ---help---
> > +         If you have a network (Ethernet) device belonging to this class, say Y
> > +         and read the Ethernet-HOWTO, available from
> > +         <http://www.tldp.org/docs.html#howto>.

Noam, since you are unlikely to get this in final from before net-next
closes (happening any time now), please delete the Howto reference when
you resubmit in two weeks, assuming that my cleanup here:

   https://patchwork.ozlabs.org/patch/487080/

gets applied to this release.

> > +
> > +         Note that the answer to this question doesn't directly affect the
> > +         kernel: saying N will just cause the configurator to skip all
> > +         the questions about EZchip devices. If you say Y, you will be asked for
> > +         your specific device in the following questions.

Mahesh, here above.  So he's not doing a "default y" on an actual driver
(which, if he were, yes that would be wrong.)  What worries me more
though, is that ...

> > +
> > +if NET_VENDOR_EZCHIP
> > +
> > +config EZCHIP_NPS_MANAGEMENT_ENET
> > +       tristate "EZchip NPS management enet support"

...there is no dependency line here.  None.  Noam - this implicitly
means that you expect this to build on all arch for all combinations of
.config files.  At a quick glance I see a dts fragment, and I also see a
call to of_get_mac_address() so I'm thinking there needs to be some
dependency here, on OF or OF_NET, or... ?

Paul.
--

> > +       ---help---
> > +         Simple LAN device for debug or management purposes.
> > +         Device supports interrupts for RX and TX(completion).
> > +         Device does not have DMA ability.
> > +
> > +endif
> > diff --git a/drivers/net/ethernet/ezchip/Makefile b/drivers/net/ethernet/ezchip/Makefile
> > new file mode 100644
> > index 0000000..e490176
> > --- /dev/null
> > +++ b/drivers/net/ethernet/ezchip/Makefile

[snip]
