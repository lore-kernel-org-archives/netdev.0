From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH 2/2] net: mv643xx_eth: proper initialization for Kirkwood
 SoCs
Date: Thu, 23 May 2013 13:01:40 -0600
Message-ID: <20130523190140.GA4010@obsidianresearch.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369253042-15082-2-git-send-email-sebastian.hesselbarth@gmail.com>
 <20130522201607.GA18823@obsidianresearch.com>
 <20130523160111.GP31290@titan.lakedaemon.net>
 <20130523171112.GB31281@obsidianresearch.com>
 <20130523172339.GQ31290@titan.lakedaemon.net>
 <20130523175357.GB2821@obsidianresearch.com>
 <20130523184028.GU31290@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130523184028.GU31290@titan.lakedaemon.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 23, 2013 at 02:40:28PM -0400, Jason Cooper wrote:

> > But there is a larger problem here then just this one bit.
> > 
> > The PSC1 register must be set properly for the board layout, and today
> > we rely on the bootloader to set it. In fact, even with Sebastian's
> > change the ethernet port won't work without bootloader
> > intervention. The PortReset bit should also be cleared by the driver
> > (and it is only present on some variants of this IP block,
> > apparently).
> > 
> > We know that some Marvell SOC's wack the ethernet registers when they
> > clock gate, and the flip of Clk125Bypass is another symptom of this
> > general problem.
> > 
> > So, long term, the PSC1 must be fully set by the driver, based on DT
> > information describing the board (eg RGMII/MII/1000Base-X [SFP] Phy
> > type), and the layout of this register seems to vary on a SOC by SOC
> > basis.
> > 
> > Thus, I think it is appropriate to call this variant of the eth IP
> > 'marvell,kirkwood-eth' which indicates that the register block follows
> > the kirkwood manual and the PSC1 register specifically has the
> > kirkwood layout.
> 
> Ok, so mv643xx_eth would match both "marvell,orion-eth" and
> "marvell,kirkwood-eth", then write to PSC1 iff it sees a node matching
> "marvell,kirkwood-eth".  I'm not too keen on that, however, the matching
> of the machine doesn't look to good, either.

Why are you not keen on this? It seems like normal device driver
practice, that is what the data field of of_device_id is typically
used for..

There are more compatible strings than just kirkwood and orion in this
driver, the whole TX_BW_CONTROL_OLD_LAYOUT/TX_BW_CONTROL_NEW_LAYOUT
buisness (affecting PPC/MIPS) should also someday be captured with
compatible strings rather than auto-detection too..

> > The question is what other Marvell SOCs have the same PSC1 layout as
> > kirkwood?
> 
> I think marvell,psc1_reset = <>; gives us the most flexibility in
> accurately describing the hardware.

Agree, providing psc1_reset value is a good idea to setup the phy
modes. If all 'orion' SOCs have the PSC1 value then we don't need the
kirkwood differentiators, especially if things like the reset bit are
in the same place.

The same trick Sebastian used to capture the mac address could be used
to capture the PSC1 value from the bootloader.

Basically, I think any IP variants that have idential register layouts
can share a compatible string, otherwise different layouts need
different compatible strings, so the general format:

 compatible = "marvell,SOCNAME-eth", "marvell,<something>-eth";

Seems very sane to me. At least this way if we discover more changes
then the driver can match on the SOCNAME compatible string to find
them.

<someting> = orion for TX_BW_CONTROL_NEW_LAYOUT variants also seems
reasonable..

No idea what to call TX_BW_CONTROL_OLD_LAYOUT variants, or the PPC
variants, not important right now it seems.

(BTW, I wonder if the driver should ideally toggle PSC1 reset at some
point????)

Jason
