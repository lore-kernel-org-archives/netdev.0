From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Thu, 17 Mar 2016 14:41:34 +0100
Message-ID: <20160317134134.GA24913@lunn.ch>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
 <CAGm1_kufFr0SsVwVcABXkL0ABJahiwz4EZ70=ywrtC9Bffbfng@mail.gmail.com>
 <20160316161848.GE2393@lunn.ch>
 <CAGm1_kuMQrECdb6_NpZ83Nm4RFSn6sQMhMK6392PLyaFFxCs1A@mail.gmail.com>
 <20160316230505.GA18161@lunn.ch>
 <CAGm1_kv7eia4LPWT5TxUJp1NV+eFZj6gBQc-pHwxbygoF03EYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shaohui ??? <shh.xie@gmail.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, drivshin@allworx.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49333 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932614AbcCQNlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 09:41:39 -0400
Content-Disposition: inline
In-Reply-To: <CAGm1_kv7eia4LPWT5TxUJp1NV+eFZj6gBQc-pHwxbygoF03EYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 09:14:17AM +0100, Yegor Yefremov wrote:
> On Thu, Mar 17, 2016 at 12:05 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> > On Wed, Mar 16, 2016 at 11:23:59PM +0100, Yegor Yefremov wrote:
> >> Hi Andrew,
> >>
> >> On Wed, Mar 16, 2016 at 5:18 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> >> > On Wed, Mar 16, 2016 at 04:59:23PM +0100, Yegor Yefremov wrote:
> >> >
> >> >> This patch breaks my am335x based board, where one of the CPSW slaves
> >> >> is connected to IP175D switch chip via RMII interface. Since this
> >> >> patch packet reception is not working.
> >> >
> >> > Hi Yegor
> >> >
> >> > Which phy is causing the problem? A PHY inside the switch?
> >> >
> >> > Do you have two back to back PHYs between the MAC and the switch, or
> >> > is the CPSW RMII connected directly to the switch?
> >>
> >> CPSW RMII is connected directly to the switch.
> >
> > So which PHY is causing you problems?

Hi Yegor

Thanks for the details. This helps explain what is going on.

I'm looking at:

http://www.icplus.com.tw/pp-IP175D.html

> First of all this is the system in question [1]. am335x CPSW has two
> slaves and in this particular configuration CPSW is working in Dual
> EMAC mode, so that both slaves are independent interfaces eth0 and
> eth1.
> 
> eth1 is connected to Atheros 8035 PHY via RGMII channel and is working
> as expected. eth0 is connected to ICPlus IP175D via RMII interface, so
> from CPSW point of view ICPlus IP175D is just an ordinary PHY.  Both
> Atheros 8035 and ICPlus IP175D are connected via MDIO, so that both of
> them will be detected at runtime:
> 
> davinci_mdio 4a101000.mdio: davinci mdio revision 1.6
> davinci_mdio 4a101000.mdio: detected phy mask f00fff00
> Atheros 8035 ethernet 4a101000.mdio:07: GPIO lookup for consumer reset
> Atheros 8035 ethernet 4a101000.mdio:07: using lookup tables for GPIO lookup
> Atheros 8035 ethernet 4a101000.mdio:07: lookup for GPIO reset failed
> libphy: 4a101000.mdio: probed
> davinci_mdio 4a101000.mdio: phy[0]: device 4a101000.mdio:00, driver
> ICPlus IP175C
> davinci_mdio 4a101000.mdio: phy[1]: device 4a101000.mdio:01, driver
> ICPlus IP175C
> davinci_mdio 4a101000.mdio: phy[2]: device 4a101000.mdio:02, driver
> ICPlus IP175C
> davinci_mdio 4a101000.mdio: phy[3]: device 4a101000.mdio:03, driver
> ICPlus IP175C
> davinci_mdio 4a101000.mdio: phy[4]: device 4a101000.mdio:04, driver
> ICPlus IP175C

So here we see the 5 PHYs connected to the switch. What we don't see
is what phy it connected to eth0. Since there is no PHY connected to
eth0, you should have a fixed_link node in your device tree.

I assume you are using am335x-baltos-ir5221.dts?

&cpsw_emac0 {
        phy_id = <&davinci_mdio>, <0>;
        phy-mode = "rmii";
        dual_emac_res_vlan = <1>;
};

I'm assuming this means use the PHY at address 0 on the MDIO bus. This
is your problem. You have logically connected PHY0 to the eth0. So if
PHY0 is down, the MAC logically has no carrier. Hence you don't see
any packets. You should be able to quickly prove this. See what
happens when you connect a peer to port0 so the link comes up.

In reality, your hardware does not have a PHY connected to the MAC. It
goes straight to the switch. So you should be using a fixed-link here.

Try something like:

&cpsw_emac0 {
	ixed-link {
        	speed = <100>;
        	full-duplex;
        };

        phy-mode = "rmii";
        dual_emac_res_vlan = <1>;
};

	Andrew
