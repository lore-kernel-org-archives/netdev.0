From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [net-next 1/2] net: ethernet: slicoss: add slicoss gigabit
 ethernet driver
Date: Tue, 15 Nov 2016 21:46:57 +0100
Message-ID: <69558f55-824a-7063-d9b3-ccc0a6113b87@gmx.de>
References: <1479012453-19410-1-git-send-email-LinoSanfilippo@gmx.de>
 <1479012453-19410-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161113195544.GA18258@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, charrer@alacritech.com, liodot@gmail.com,
        gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:57622 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751985AbcKOUrT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 15:47:19 -0500
In-Reply-To: <20161113195544.GA18258@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


On 13.11.2016 20:55, Andrew Lunn wrote:
>> +static const char slic_stats_strings[][ETH_GSTRING_LEN] = {
>> +	"rx_packets     ",
>> +	"rx_bytes       ",
>> +	"rx_multicasts  ",
>> +	"rx_errors      ",
>> +	"rx_buff_miss   ",
>> +	"rx_tp_csum     ",
>> +	"rx_tp_oflow    ",
>> +	"rx_tp_hlen     ",
>> +	"rx_ip_csum     ",
>> +	"rx_ip_len      ",
> 
> Are there any other drivers which pad the statistics strings?
> 

First off, thank you for the review!

I took a look into a few drivers and most of them do not pad the statistic strings.
Actually there are some that do (e.g. the chelsio drivers cxgb4, cxgb3, xcgb4v), 
but this seems to be rather the minority, so I will remove it. Thank you for the hint.

>> +static void slic_set_link_autoneg(struct slic_device *sdev)
>> +{
>> +	unsigned int subid = sdev->pdev->subsystem_device;
>> +	u32 val;
>> +
>> +	if (sdev->is_fiber) {
>> +		/* We've got a fiber gigabit interface, and register 4 is
>> +		 * different in fiber mode than in copper mode.
>> +		 */
>> +		/* advertise FD only @1000 Mb */
>> +		val = MII_ADVERTISE << 16 | SLIC_PAR_ADV1000XFD |
>> +		      SLIC_PAR_ASYMPAUSE_FIBER;
>> +		/* enable PAUSE frames */
>> +		slic_write(sdev, SLIC_REG_WPHY, val);
>> +		/* reset phy, enable auto-neg  */
>> +		val = MII_BMCR << 16 | SLIC_PCR_RESET | SLIC_PCR_AUTONEG |
>> +		      SLIC_PCR_AUTONEG_RST;
>> +		slic_write(sdev, SLIC_REG_WPHY, val);
>> +	} else {	/* copper gigabit */
>> +		/* We've got a copper gigabit interface, and register 4 is
>> +		 * different in copper mode than in fiber mode.
>> +		 */
>> +		/* advertise 10/100 Mb modes   */
>> +		val = MII_ADVERTISE << 16 | SLIC_PAR_ADV100FD |
>> +		      SLIC_PAR_ADV100HD | SLIC_PAR_ADV10FD | SLIC_PAR_ADV10HD;
>> +		/* enable PAUSE frames  */
>> +		val |= SLIC_PAR_ASYMPAUSE;
>> +		/* required by the Cicada PHY  */
>> +		val |= SLIC_PAR_802_3;
>> +		slic_write(sdev, SLIC_REG_WPHY, val);
>> +
>> +		/* advertise FD only @1000 Mb  */
>> +		val = MII_CTRL1000 << 16 | SLIC_PGC_ADV1000FD;
>> +		slic_write(sdev, SLIC_REG_WPHY, val);
>> +
>> +		if (subid != PCI_SUBDEVICE_ID_ALACRITECH_CICADA) {
>> +			 /* if a Marvell PHY enable auto crossover */
>> +			val = SLIC_MIICR_REG_16 | SLIC_MRV_REG16_XOVERON;
>> +			slic_write(sdev, SLIC_REG_WPHY, val);
>> +
>> +			/* reset phy, enable auto-neg  */
>> +			val = MII_BMCR << 16 | SLIC_PCR_RESET |
>> +			      SLIC_PCR_AUTONEG | SLIC_PCR_AUTONEG_RST;
>> +			slic_write(sdev, SLIC_REG_WPHY, val);
>> +		} else {
>> +			/* enable and restart auto-neg (don't reset)  */
>> +			val = MII_BMCR << 16 | SLIC_PCR_AUTONEG |
>> +			      SLIC_PCR_AUTONEG_RST;
>> +			slic_write(sdev, SLIC_REG_WPHY, val);
>> +		}
>> +	}
>> +	sdev->autoneg = true;
>> +}
> 
> Could this be pulled out into a standard PHY driver? All the SLIC
> SLIC_PCR_ defines seems to be the same as those in mii.h. This could
> be a standard PHY hidden behind a single register.
> 
>    Andrew

You are right, the driver should really use the defines in mii.h. I will fix this in
 a v2.

Concerning the use of the PHY API: What would be the advantage of using it? Note that the
 phy is always internal and not interchangeable. Is not the interchangeability of PHYs
the main reason for using this API?

Regards,
Lino
