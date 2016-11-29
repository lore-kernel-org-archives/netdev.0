From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-netx] net: lan78xx: add LAN7801 MAC-only support
Date: Tue, 29 Nov 2016 10:58:41 -0800
Message-ID: <dcabc07f-ab5f-ad25-5beb-09f717c06e4e@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D4096E268@CHN-SV-EXMX02.mchp-main.com>
 <007d0bc0-378c-da93-d730-28f7b5b5073a@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D4096FC85@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, davem@davemloft.net, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36637 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754329AbcK2S6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:58:44 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so17173986pgx.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 10:58:44 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D4096FC85@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 10:49 AM, Woojung.Huh@microchip.com wrote:
>>> +	/* LED2/PME_N/IRQ_N/RGMII_ID pin to IRQ_N mode */
>>> +	buf = phy_read_mmd_indirect(phydev, 32784, 3);
>>> +	buf &= ~0x1800;
>>> +	buf |= 0x0800;
>>> +	phy_write_mmd_indirect(phydev, 32784, 3, buf);
>>
>> Using decimal numbers for register addresses is a bit unusual.
> 
> OK. Will change it.
> 
>>> +
>>> +	/* RGMII MAC TXC Delay Enable */
>>> +	ret = lan78xx_write_reg(dev, MAC_RGMII_ID,
>>> +				MAC_RGMII_ID_TXC_DELAY_EN_);
>>> +
>>> +	/* RGMII TX DLL Tune Adjust */
>>> +	ret = lan78xx_write_reg(dev, RGMII_TX_BYP_DLL, 0x3D00);
>>> +
>>> +	*interface = PHY_INTERFACE_MODE_RGMII_TXID;
>>> +}
>>> +
>>> +static void ksz9031rnx_pre_config(struct lan78xx_net *dev,
>>> +				  struct phy_device *phydev,
>>> +				  phy_interface_t *interface)
>>> +{
>>> +	/* Micrel9301RNX PHY configuration */
>>> +	/* RGMII Control Signal Pad Skew */
>>> +	phy_write_mmd_indirect(phydev, 4, 2, 0x0077);
>>> +	/* RGMII RX Data Pad Skew */
>>> +	phy_write_mmd_indirect(phydev, 5, 2, 0x7777);
>>> +	/* RGMII RX Clock Pad Skew */
>>> +	phy_write_mmd_indirect(phydev, 8, 2, 0x1FF);
>>> +
>>> +	*interface = PHY_INTERFACE_MODE_RGMII_RXID;
>>> +}
>>
>> This should really belong in the respective PHY drivers for these PHYs,
>> is there a particular reason you decided to do this here?
> 
> Main reason is because these are MAC dependent.
> In case these are in PHY driver, I expect some parameters/defines may need to be passed to it.
> Trying to keep PHY driver as generic as possible.

There are two ways to get these settings propagated to the PHY driver:

- using a board fixup which is going to be invoked during
drv->config_init() time

- specifying a phydev->dev_flags and reading it from the PHY driver to
act upon and configure the PHY based on that value, there are only
32-bits available though, and you need to make sure they are not
conflicting with other potential users in tree

My preference would go with 1, since you could just register it in your
PHY driver and re-use the code you are proposing to include here.
-- 
Florian
