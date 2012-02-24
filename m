From: "Rajashekhara, Sudhakar" <sudhakar.raj@ti.com>
Subject: RE: davinci_emac/mdio: SOFT_RESET of EMAC module resets MDIO on
 AM1808
Date: Fri, 24 Feb 2012 13:02:00 +0000
Message-ID: <B6A220404B6BFC4BBD2AB91C54D39DF431775E1B@DBDE01.ent.ti.com>
References: <CABkLObpZ52yVnq-wqnm8nC=bSnzz41RnC=wbQD3U7NRmr2SRBQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Christian Riesch <christian.riesch@omicron.at>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	"Gole, Anant" <anantgole@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:33291 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756170Ab2BXNCP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 08:02:15 -0500
In-Reply-To: <CABkLObpZ52yVnq-wqnm8nC=bSnzz41RnC=wbQD3U7NRmr2SRBQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christian,

On Thu, Feb 23, 2012 at 14:39:49, Christian Riesch wrote:
> Hi,
> I observed this behavior on a Texas Instruments AM1808 SoC (AM1808
> experimenter's kit) running the current mainline kernel:
> 
> # ifconfig eth0 down
> # ifconfig eth0 up
> davinci_mdio davinci_mdio.0: resetting idled controller
> net eth0: attached PHY driver [Generic PHY] (mii_bus:phy_addr=davinci_mdio-0:00)
> # PHY: davinci_mdio-0:00 - Link is Up - 100/Full
> 

I also observed this issue with the kernel from linux-davinci tree from
gitorious.

> After each ifconfig eth0 up I get this 'resetting idled controller'
> warning. I added a few debug messages to the davinci_mdio driver and
> noticed that the MDIO control register was set to its reset value
> (clock divider 0xff and MDIO turned off) after an ifconfig eth0 up.
> Therefore, this warning is issued and a reconfiguration of the MDIO
> controller is done by the driver.
> 
> Now the question was: Who is turning off the MDIO controller? After a
> bit of debugging I found out that the reset of the MDIO controller
> seems to be caused by these lines in the davinci_emac driver in
> emac_hw_enable() in drivers/net/ethernet/ti/davinci_emac.c:
> 
> emac_write(EMAC_SOFTRESET, 1);
> while (emac_read(EMAC_SOFTRESET))
>         cpu_relax();
> 
> According to the AM1808 Technical Reference Manual (sections 18.2.14.1
> and 18.3.3.34 in [1]), writing a 1 to the EMAC_SOFTRESET register
> resets the EMAC module, but not the MDIO module. However, when I
> comment out the code above, the MDIO control register is not affected
> and the warning 'resetting idled controller' disappears.
> 

But this was not the case for me. Even after commenting out the above lines,
I could still see that MDIO was getting reset.

During eth0 up, the smsc_phy_config_init() function calls the mdiobus_read()
function. During this sequence if the MDIO state machine is in IDLE state,
then MDIO is reset causing the above warning message to appear.

In summary, EMAC reset is not causing the MDIO reset to happen.

Thanks,
Sudhakar
