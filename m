From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Thu, 17 Mar 2016 09:14:17 +0100
Message-ID: <CAGm1_kv7eia4LPWT5TxUJp1NV+eFZj6gBQc-pHwxbygoF03EYg@mail.gmail.com>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
 <CAGm1_kufFr0SsVwVcABXkL0ABJahiwz4EZ70=ywrtC9Bffbfng@mail.gmail.com>
 <20160316161848.GE2393@lunn.ch> <CAGm1_kuMQrECdb6_NpZ83Nm4RFSn6sQMhMK6392PLyaFFxCs1A@mail.gmail.com>
 <20160316230505.GA18161@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "shaohui ???" <shh.xie@gmail.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, drivshin@allworx.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:32818 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756201AbcCQIOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 04:14:38 -0400
Received: by mail-vk0-f42.google.com with SMTP id k1so92906618vkb.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 01:14:37 -0700 (PDT)
In-Reply-To: <20160316230505.GA18161@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 12:05 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Mar 16, 2016 at 11:23:59PM +0100, Yegor Yefremov wrote:
>> Hi Andrew,
>>
>> On Wed, Mar 16, 2016 at 5:18 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> > On Wed, Mar 16, 2016 at 04:59:23PM +0100, Yegor Yefremov wrote:
>> >
>> >> This patch breaks my am335x based board, where one of the CPSW slaves
>> >> is connected to IP175D switch chip via RMII interface. Since this
>> >> patch packet reception is not working.
>> >
>> > Hi Yegor
>> >
>> > Which phy is causing the problem? A PHY inside the switch?
>> >
>> > Do you have two back to back PHYs between the MAC and the switch, or
>> > is the CPSW RMII connected directly to the switch?
>>
>> CPSW RMII is connected directly to the switch.
>
> So which PHY is causing you problems?

First of all this is the system in question [1]. am335x CPSW has two
slaves and in this particular configuration CPSW is working in Dual
EMAC mode, so that both slaves are independent interfaces eth0 and
eth1.

eth1 is connected to Atheros 8035 PHY via RGMII channel and is working
as expected. eth0 is connected to ICPlus IP175D via RMII interface, so
from CPSW point of view ICPlus IP175D is just an ordinary PHY. Both
Atheros 8035 and ICPlus IP175D are connected via MDIO, so that both of
them will be detected at runtime:

davinci_mdio 4a101000.mdio: davinci mdio revision 1.6
davinci_mdio 4a101000.mdio: detected phy mask f00fff00
Atheros 8035 ethernet 4a101000.mdio:07: GPIO lookup for consumer reset
Atheros 8035 ethernet 4a101000.mdio:07: using lookup tables for GPIO lookup
Atheros 8035 ethernet 4a101000.mdio:07: lookup for GPIO reset failed
libphy: 4a101000.mdio: probed
davinci_mdio 4a101000.mdio: phy[0]: device 4a101000.mdio:00, driver
ICPlus IP175C
davinci_mdio 4a101000.mdio: phy[1]: device 4a101000.mdio:01, driver
ICPlus IP175C
davinci_mdio 4a101000.mdio: phy[2]: device 4a101000.mdio:02, driver
ICPlus IP175C
davinci_mdio 4a101000.mdio: phy[3]: device 4a101000.mdio:03, driver
ICPlus IP175C
davinci_mdio 4a101000.mdio: phy[4]: device 4a101000.mdio:04, driver
ICPlus IP175C
davinci_mdio 4a101000.mdio: phy[5]: device 4a101000.mdio:05, driver unknown
davinci_mdio 4a101000.mdio: phy[6]: device 4a101000.mdio:06, driver unknown
davinci_mdio 4a101000.mdio: phy[7]: device 4a101000.mdio:07, driver
Atheros 8035 ethernet
davinci_mdio 4a101000.mdio: phy[20]: device 4a101000.mdio:14, driver unknown
davinci_mdio 4a101000.mdio: phy[21]: device 4a101000.mdio:15, driver unknown
davinci_mdio 4a101000.mdio: phy[22]: device 4a101000.mdio:16, driver unknown
davinci_mdio 4a101000.mdio: phy[23]: device 4a101000.mdio:17, driver unknown
davinci_mdio 4a101000.mdio: phy[24]: device 4a101000.mdio:18, driver unknown
davinci_mdio 4a101000.mdio: phy[25]: device 4a101000.mdio:19, driver unknown
davinci_mdio 4a101000.mdio: phy[26]: device 4a101000.mdio:1a, driver unknown
davinci_mdio 4a101000.mdio: phy[27]: device 4a101000.mdio:1b, driver unknown

>From ICPlus IP175D point of view eth0 is just a fifth port in the
switch. ICPlus IP175D is in its default configuration, i.e. just acts
as an unmanaged Ethernet switch. As soon as eth0 will be brought up it
has constant 100Mbps connection. I assume, that from MDIO signalling
this connection differs from physical cable insertion.

In prior kernels when I make ip link set eth0 up I get:

cpsw 4a100000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off

After this patch I don't get this state message. Though I cannot see
differences in "ethtool eth0" or "ip addr show eth0" for both kernels.
So I assume, that ICPlus IP175D stays in PHY_RUNNING state.

Let me know, what additional info do you need.

[1] http://www.visionsystems.de/produkte/baltos-ir-5221.html

Yegor
