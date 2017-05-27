From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: phy: Create sysfs reciprocal links for
 attached_dev/phydev
Date: Fri, 26 May 2017 17:33:49 -0700
Message-ID: <05a159af-6689-70db-9506-09059a09f1a5@gmail.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-2-f.fainelli@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAA2@CHN-SV-EXMX02.mchp-main.com>
 <d2d97683-3fcc-6603-09e1-13818464de18@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DACE@CHN-SV-EXMX02.mchp-main.com>
 <44f24fbd-5093-faa2-02cd-f8d4d835b59d@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAF6@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch
To: Woojung.Huh@microchip.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35313 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948888AbdE0Ad4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 20:33:56 -0400
Received: by mail-pg0-f68.google.com with SMTP id i63so124549pgd.2
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 17:33:56 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A9DAF6@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2017 05:20 PM, Woojung.Huh@microchip.com wrote:
>> OK, I am confused now. You are describing what is going on with your
>> platform right? Can you describe a bit further here what is happening
>> and with which type of interface? Is this with the CPU interface or
>> something?
> 
> Yes. It's on our platform.
> Like your platform, fixed phy is used to connect switch CPU port/master netdev.
> GMAC of SoC is cadence/macb.c with fixed phy modification.
> 
> static int macb_mii_probe(struct net_device *dev)
> {
> 	...
> 	phydev = phy_find_first(bp->mii_bus);
> 	if (!phydev) {
> 		phydev = fixed_phy_register(PHY_POLL, &fphy_status, -1, NULL);
> 		if (IS_ERR(phydev)) {
> 			netdev_err(dev, "no PHY found\n");
> 			return -ENXIO;
> 		}> 	}
> 	...
> When failed to find phydev from phy_find_first(), it forces to fixed phy.
> 	...
> 	/* attach the mac to the phy */
> 	ret = phy_connect_direct(dev, phydev, &macb_handle_link_change,
> 				 bp->phy_interface);
> 
> sysfs_create_lin() inside of phy_connect_direct() fails.

OK, so here is what is happening: macb_mii_init() calls macb_mii_probe()
and so by the time we call phy_connect_direct(), we have not called
register_netdevice() yet, netdev_register_kobject() has not been called
either, and so sysfs_create_link() fails....

Let me think about a way to solve that, even though I am leaning towards
ignoring the errors from sysfs_create_link() rather than fixing each and
every Ethernet driver to make it probe its MII bus *after* calling
register_netdevice()....

> 
> What is driver you are testing? I can check the file.

Drivers involved are the following:

drivers/net/ethernet/broadcom/bcmsysport.c,
drivers/net/dsa/bcm_sf2.c
drivers/net/ethernet/broadcom/genet/
drivers/net/phy/bcm7xxx.c
-- 
Florian
