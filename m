From: Tien Hock Loh <thloh@altera.com>
Subject: Re: [PATCH v3 1/1] net: ethernet: Add TSE PCS support to
 dwmac-socfpga
Date: Thu, 9 Jun 2016 23:12:25 -0700
Message-ID: <1465539145.4467.42.camel@ubuntu>
References: <1465268516-31480-1-git-send-email-thloh@altera.com>
	 <ab65dd4e-830a-c774-c8fa-1adfb3be1a69@st.com>
	 <1465451310.4467.21.camel@ubuntu>
	 <ac036ba2-c9ce-1fb4-89e3-9af499954907@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <thloh85@gmail.com>,
	Chee Nouk Phoon <cnphoon@altera.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ac036ba2-c9ce-1fb4-89e3-9af499954907@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peppe, 

On Wed, 2016-06-08 at 23:20 +0000, Giuseppe CAVALLARO wrote:
> Hello Tien Hock
> 
> On 6/9/2016 7:48 AM, Tien Hock Loh wrote:
> 
> [snip]
> 
> >>>  .../devicetree/bindings/net/socfpga-dwmac.txt      |   4 +
> >>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   2 +-
> >>>  .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 140 +++++++++--
> >>>  drivers/net/ethernet/stmicro/stmmac/tse_pcs.c      | 261 +++++++++++++++++++++
> >>>  drivers/net/ethernet/stmicro/stmmac/tse_pcs.h      |  36 +++
> >>>  5 files changed, 419 insertions(+), 24 deletions(-)
> >>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/tse_pcs.c
> >>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/tse_pcs.h
> >>
> >> I just wonder if it could make sense to rename the
> >> tse_pcs.[hc] files or creating a sub-directory for altera devel.
> >> It seems that tse_pcs.[hc] are common files but this support
> >> is for Altera.
> >> Anyway, I let you decide and I also ask you to update the stmmac.txt
> >> file.
> >
> > Yeah the PCS support for TSE is Altera. To avoid confusion, let's rename
> > them, would altr_tse_pcs.[hc] be good? I don't think creating a
> > sub-directory with only 2 files is necessary though.
> 
> ok for two files w/o sub-dir.
> 
> >
> > I see that stmmac.txt is generic, and other vendor's PCS support
> > documents their specific uses in their own *-dwmac.txt (eg.
> > rockchip-dwmac.txt). Is this not the case?
> 
> yes you can use this name convention. I let you decide.

What I meant was we've documented the bindings in socfpga-dwmac.txt for
platform specific bindings, and I won't be updating stmmac.txt because
that is the generic driver binding. Agree?

> 
> [snip]
> 
> 
> >>> +
> >>> +		index = of_property_match_string(np_sgmii_adapter, "reg-names",
> >>> +						 "eth_tse_control_port");
> >>
> >> reg-names looks to be specific and mandatory, IMO they should be
> >> documented in the binding.
> >
> > That's the binding for the adapter (the phandle to the sgmii adapter),
> > not the stmac binding itself. Do you mean I should document the sgmii
> > adapter as well?
> 
> no I just meant for the adapter binding, I had understood that
> eth_tse_control_port and gmii_to_sgmii_adapter_avalon_slave
> were not documented and these seem to be mandatory.

OK noted.

> 
> [snip]
> 
> >>> +
> >>> +static void auto_nego_timer_callback(unsigned long data)
> >>> +{
> >>> +	u16 val = 0;
> >>> +	u16 speed = 0;
> >>> +	u16 duplex = 0;
> >>> +
> >>> +	struct tse_pcs *pcs = (struct tse_pcs *)data;
> >>> +	void __iomem *tse_pcs_base = pcs->tse_pcs_base;
> >>> +	void __iomem *sgmii_adapter_base = pcs->sgmii_adapter_base;
> >>> +
> >>> +	val = readw(tse_pcs_base + TSE_PCS_STATUS_REG);
> >>> +	val &=  TSE_PCS_STATUS_AN_COMPLETED_MASK;
> 
> [snip]
> 
> >>
> >> ANE is completed but speed or duplex is NOK. Any failure to signalling?
> >> I see that you then enable the adpter in any case.
> >>
> >> Maybe we could try to restart ANE again or force it (reducing the speed)
> >> I wonder what happens if, for some reason, there is some hw problem. In
> >> that case the timer is always running signalling an invalid Parter
> >> speed. Anyway, this is jus a question... I expect that this error will
> >> always point us to a problem to debug further (if occurs).
> >
> > Let me look at how we can handle the case. Perhaps we could do a restart
> > and register the timer again. I'm just worried it will go into an
> > infinite timer registering hogging up the kernel if the hardware really
> > fails. Maybe I can do a n-time retry here. Looking into this. Let me
> > know if you have any opinions on this.
> >
> > I haven't been able to check for this behaviour though, negative testing
> > on this code isn't too easy to simulate.
> 
> yes and I expect this can occur on hw / conf problems. Take a look at
> how the Physical Abstraction Layer manages this.
> Indeed, we can try to restart ANE for a while and then just report the
> failure (dev_err). Or we can try to fix other speed or duplex. But not
> sure this is a good solution. We just mask a problem.

Done some read up on the generic PHY in Physical Abstraction Layer and
it halts the PHY on aneg failure. I guess we can do do the same then, to
not enable the SGMII adapter.

> 
> [snip]
> 
> >>> +
> >>> +		setup_timer(&pcs->an_timer,
> >>> +			    auto_nego_timer_callback,
> >>> +			    (unsigned long)pcs);
> >>> +		mod_timer(&pcs->an_timer, jiffies +
> >>> +			  msecs_to_jiffies(AUTONEGO_TIMER));
> >>> +	} else if (phy_dev->autoneg == AUTONEG_DISABLE) {
> >>> +		val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
> >>> +		val &= ~TSE_PCS_CONTROL_AN_EN_MASK;
> >>> +		writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
> >>> +
> >>> +		val = readw(tse_pcs_base + TSE_PCS_IF_MODE_REG);
> >>> +		val &= ~TSE_PCS_USE_SGMII_AN_MASK;
> >>> +		writew(val, tse_pcs_base + TSE_PCS_IF_MODE_REG);
> >>> +
> >>> +		val = readw(tse_pcs_base + TSE_PCS_IF_MODE_REG);
> >>> +		val &= ~TSE_PCS_SGMII_SPEED_MASK;
> >>> +
> >>> +		switch (speed) {
> >>> +		case 1000:
> >>> +			val |= TSE_PCS_SGMII_SPEED_1000;
> >>> +			break;
> >>> +		case 100:
> >>> +			val |= TSE_PCS_SGMII_SPEED_100;
> >>> +			break;
> >>> +		case 10:
> >>> +			val |= TSE_PCS_SGMII_SPEED_10;
> >>> +			break;
> >>> +		default:
> >>> +			return;
> >>> +		}
> >>> +		writew(val, tse_pcs_base + TSE_PCS_IF_MODE_REG);
> >>> +
> >>> +		tse_pcs_reset(tse_pcs_base, pcs);
> >>> +
> >>> +		setup_timer(&pcs->link_timer,
> >>> +			    pcs_link_timer_callback,
> >>> +					(unsigned long)pcs);
> >>> +		mod_timer(&pcs->link_timer, jiffies +
> >>> +			  msecs_to_jiffies(LINK_TIMER));
> >>
> >> I wonder if we can have just one timer to manage ANE and LINK.
> >>
> >
> > That would increase the complexity of the code because we would need to
> > check the callback type on when the callback is triggered and call the
> > correct function.
> 
> hmm, in that case, you have two timers and no lock protection:
> I suspect there could be some hidden problem. The link goes down
> and a timer polls this then another one try to restart ANE and
> both timers read the TSE_PCS_STATUS_REG.
> IMO, a timer is enough and you could keep the code to manage ANE and
> LINK in two different functions. Pls take a look at if this is feasible.

Yeah you're right about the lock protection. I'll patch them to use one
timer.

> 
> Peppe

Tien Hock
