From: Christian Riesch <christian.riesch@omicron.at>
Subject: RE: davinci_emac/mdio: SOFT_RESET of EMAC module resets MDIO on AM1808
Date: Fri, 24 Feb 2012 15:15:23 +0100
Message-ID: <1330092923-10899-1-git-send-email-christian.riesch@omicron.at>
References: <B6A220404B6BFC4BBD2AB91C54D39DF431775E1B@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>, <cyril@ti.com>,
	<anantgole@ti.com>, Christian Riesch <christian.riesch@omicron.at>
To: <sudhakar.raj@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:36424 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330Ab2BXOPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 09:15:44 -0500
In-Reply-To: <B6A220404B6BFC4BBD2AB91C54D39DF431775E1B@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sudhakar,

On Fri, Feb 24, 2012 at 2:02 PM, Rajashekhara, Sudhakar <sudhakar.raj@ti.com> wrote:
> On Thu, Feb 23, 2012 at 14:39:49, Christian Riesch wrote:
>> Hi,
>> I observed this behavior on a Texas Instruments AM1808 SoC (AM1808
>> experimenter's kit) running the current mainline kernel:
>>
>> # ifconfig eth0 down
>> # ifconfig eth0 up
>> davinci_mdio davinci_mdio.0: resetting idled controller
>> net eth0: attached PHY driver [Generic PHY] (mii_bus:phy_addr=davinci_mdio-0:00)
>> # PHY: davinci_mdio-0:00 - Link is Up - 100/Full
>>
>
> I also observed this issue with the kernel from linux-davinci tree from
> gitorious.
>
>> After each ifconfig eth0 up I get this 'resetting idled controller'
>> warning. I added a few debug messages to the davinci_mdio driver and
>> noticed that the MDIO control register was set to its reset value
>> (clock divider 0xff and MDIO turned off) after an ifconfig eth0 up.
>> Therefore, this warning is issued and a reconfiguration of the MDIO
>> controller is done by the driver.
>>
>> Now the question was: Who is turning off the MDIO controller? After a
>> bit of debugging I found out that the reset of the MDIO controller
>> seems to be caused by these lines in the davinci_emac driver in
>> emac_hw_enable() in drivers/net/ethernet/ti/davinci_emac.c:
>>
>> emac_write(EMAC_SOFTRESET, 1);
>> while (emac_read(EMAC_SOFTRESET))
>>         cpu_relax();
>>
>> According to the AM1808 Technical Reference Manual (sections 18.2.14.1
>> and 18.3.3.34 in [1]), writing a 1 to the EMAC_SOFTRESET register
>> resets the EMAC module, but not the MDIO module. However, when I
>> comment out the code above, the MDIO control register is not affected
>> and the warning 'resetting idled controller' disappears.
>>
>
> But this was not the case for me. Even after commenting out the above lines,
> I could still see that MDIO was getting reset.

Uh, I am sorry. I forgot to mention that there is a second
emac_write(EMAC_SOFTRESET,1); in emac_dev_stop() in davinci_emac.c. 
This one must also be commented out to make the resetting idled controller 
message go away.

The patch below shows that changes that I did. May I please ask you to try
again with these changes?

Regards, Christian

>
> During eth0 up, the smsc_phy_config_init() function calls the mdiobus_read()
> function. During this sequence if the MDIO state machine is in IDLE state,
> then MDIO is reset causing the above warning message to appear.
>
> In summary, EMAC reset is not causing the MDIO reset to happen.

---
 drivers/net/ethernet/ti/davinci_emac.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 4b2f545..733d538 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1290,10 +1290,10 @@ static int emac_hw_enable(struct emac_priv *priv)
 	u32 val, mbp_enable, mac_control;
 
 	/* Soft reset */
-	emac_write(EMAC_SOFTRESET, 1);
+/*	emac_write(EMAC_SOFTRESET, 1);
 	while (emac_read(EMAC_SOFTRESET))
 		cpu_relax();
-
+*/
 	/* Disable interrupt & Set pacing for more interrupts initially */
 	emac_int_disable(priv);
 
@@ -1672,7 +1672,7 @@ static int emac_dev_stop(struct net_device *ndev)
 	netif_carrier_off(ndev);
 	emac_int_disable(priv);
 	cpdma_ctlr_stop(priv->dma);
-	emac_write(EMAC_SOFTRESET, 1);
+/*	emac_write(EMAC_SOFTRESET, 1);*/
 
 	if (priv->phydev)
 		phy_disconnect(priv->phydev);
-- 
1.7.0.4
