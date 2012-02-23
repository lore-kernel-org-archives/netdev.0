From: Christian Riesch <christian.riesch@omicron.at>
Subject: davinci_emac/mdio: SOFT_RESET of EMAC module resets MDIO on AM1808
Date: Thu, 23 Feb 2012 10:09:49 +0100
Message-ID: <CABkLObpZ52yVnq-wqnm8nC=bSnzz41RnC=wbQD3U7NRmr2SRBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, cyril@ti.com,
	anantgole@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51675 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601Ab2BWJJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 04:09:50 -0500
Received: by yhoo21 with SMTP id o21so466336yho.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 01:09:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I observed this behavior on a Texas Instruments AM1808 SoC (AM1808
experimenter's kit) running the current mainline kernel:

# ifconfig eth0 down
# ifconfig eth0 up
davinci_mdio davinci_mdio.0: resetting idled controller
net eth0: attached PHY driver [Generic PHY] (mii_bus:phy_addr=davinci_mdio-0:00)
# PHY: davinci_mdio-0:00 - Link is Up - 100/Full

After each ifconfig eth0 up I get this 'resetting idled controller'
warning. I added a few debug messages to the davinci_mdio driver and
noticed that the MDIO control register was set to its reset value
(clock divider 0xff and MDIO turned off) after an ifconfig eth0 up.
Therefore, this warning is issued and a reconfiguration of the MDIO
controller is done by the driver.

Now the question was: Who is turning off the MDIO controller? After a
bit of debugging I found out that the reset of the MDIO controller
seems to be caused by these lines in the davinci_emac driver in
emac_hw_enable() in drivers/net/ethernet/ti/davinci_emac.c:

emac_write(EMAC_SOFTRESET, 1);
while (emac_read(EMAC_SOFTRESET))
        cpu_relax();

According to the AM1808 Technical Reference Manual (sections 18.2.14.1
and 18.3.3.34 in [1]), writing a 1 to the EMAC_SOFTRESET register
resets the EMAC module, but not the MDIO module. However, when I
comment out the code above, the MDIO control register is not affected
and the warning 'resetting idled controller' disappears.

Is this an error in the documentation? Or in hardware? Or did I miss
something here? I already asked this questions in TI's E2E forum [2]
but did not get an answer yet. I would like to ask all the TI people
out there to help me getting an answer to this question. Thanks you!

Anyway, I think this should be fixed since it's bad when a driver
(davinci_emac) resets another driver's (davinci_mdio's) hardware.

Best regards,
Christian

[1] http://www.ti.com/litv/pdf/spruh82a
[2] http://e2e.ti.com/support/dsp/omap_applications_processors/f/42/t/164314.aspx
