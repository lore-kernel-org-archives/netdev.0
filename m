From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCHv3 (net.git) 2/2] stmmac: fix MDIO settings
Date: Tue, 15 Mar 2016 16:53:23 +0100
Message-ID: <56E82FF3.5010402@st.com>
References: <1457703196-15008-1-git-send-email-peppe.cavallaro@st.com> <1457703196-15008-3-git-send-email-peppe.cavallaro@st.com> <56E75D36.2030201@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------090103080600010208000003"
Cc: <netdev@vger.kernel.org>, <gabriel.fernandez@linaro.org>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	Tomeu Vizoso <tomeu@tomeuvizoso.net>
To: =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:62582 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751150AbcCOPxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 11:53:43 -0400
In-Reply-To: <56E75D36.2030201@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------090103080600010208000003
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit

Hi Andreas

On 3/15/2016 1:54 AM, Andreas Färber wrote:
> Hi Peppe,
>
> Am 11.03.2016 um 14:33 schrieb Giuseppe Cavallaro:
>> Initially the phy_bus_name was added to manipulate the
>> driver name but It was recently just used to manage the
>
> "it"
>
>> fixed-link and then to take some decision at run-time
>> inside the main (for example to skip EEE).
>
> Word missing after "main"? ("function"?)
>
>> So the patch uses the is_pseudo_fixed_link and removes
>> removes the phy_bus_name variable not necessary anymore.
>
> Duplicate "removes".

Sure I will fix them in the v4

>
>>
>> The driver can manage the mdio registration by using phy-handle,
>> dwmac-mdio and own parameter e.g. snps,phy-addr.
>> This patch takes care about all these possible configurations
>> and fixes the mdio registration in case of there is a real
>> transceiver or a switch (that needs to be managed by using
>> fixed-link).
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> Reviewed-by: Andreas Färber <afaerber@suse.de>
>> Tested-by: Frank Schäfer <fschaefer.oss@googlemail.com>
>> Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>
>> Cc: Dinh Nguyen <dinh.linux@gmail.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Phil Reid <preid@electromag.com.au>
>> ---
>>
>> V2: use is_pseudo_fixed_link
>> V3: parse device-tree driver parameters to allocate PHY resources considering
>>      DSA case (+ fixed-link).
>
> For next-20160314 I needed "i2c: immediately mark ourselves as
> registered" plus this build fix:

yes I will send it in a separate set for net-next.

>
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -866,9 +866,8 @@ static int stmmac_init_phy(struct net_device *dev)
>          }
>
>          /* If attached to a switch, there is no reason to poll phy
> handler */
> -       if (priv->plat->phy_bus_name)
> -               if (!strcmp(priv->plat->phy_bus_name, "fixed"))
> -                       phydev->irq = PHY_IGNORE_INTERRUPT;
> +       if (phydev->is_pseudo_fixed_link)
> +               phydev->irq = PHY_IGNORE_INTERRUPT;
>
>          pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
>                   " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
>
> It then fixes the PHY error on GeekBox, so for this mini-series:
>
> Tested-by: Andreas Färber <afaerber@suse.de>

thx a lot for having tested it.
>
> The connectivity issue still remains. Kernel log snippet:
>
> [  +0.001117] rk_gmac-dwmac ff290000.ethernet: Looking up phy-supply
> from device tree
> [  +0.000028] rk808 0-001b: Looking up vcc12-supply from device tree
> [  +0.000014] vcc_lan: supplied by vcc_io
> [  +0.000101] rk_gmac-dwmac ff290000.ethernet: clock input or output?
> (input).
> [  +0.000009] rk_gmac-dwmac ff290000.ethernet: TX delay(0x30).
> [  +0.000008] rk_gmac-dwmac ff290000.ethernet: RX delay(0x10).
> [  +0.000014] rk_gmac-dwmac ff290000.ethernet: init for RGMII
> [  +0.000104] rk_gmac-dwmac ff290000.ethernet: clock input from PHY
> [  +0.005063] rk_gmac-dwmac ff290000.ethernet: no reset control found
> [  +0.000007] stmmac - user ID: 0x10, Synopsys ID: 0x35
> [  +0.000002]  Ring mode enabled
> [  +0.000006]  DMA HW capability register supported
> [  +0.000000]  Normal descriptors

                  ^^^^^^^^^^^^^^^^^^

> [  +0.000003]  RX Checksum Offload Engine supported (type 2)
> [  +0.000002]  TX Checksum insertion supported
> [  +0.000002]  Wake-Up On Lan supported
> [  +0.000053]  Enable RX Mitigation via HW Watchdog Timer
> [  +0.000771] of_get_named_gpiod_flags: can't parse 'snps,reset-gpio'
> property of node '/ethernet@ff290000[0]'
> [  +0.004250] libphy: stmmac: probed
> [  +0.000009] eth0: PHY ID 001cc915 at 0 IRQ POLL (stmmac-0:00) active
> [  +0.000005] eth0: PHY ID 001cc915 at 1 IRQ POLL (stmmac-0:01)
>
> As before, reverting "stmmac: first frame prep at the end of xmit
> routine" fixes it. My test cases are `ping 192.168.1.1` and `zypper up`.

so on your side, this revert fixes the issue and you do not see any
tx watchdog as Tomeu's raised.

I have fixed some problems on top of
"stmmac: first frame prep at the end of xmit ..." please
see patch attached for net-next.

Indeed, the normal tx descriptors are well filled w/o
"stmmac: first frame prep at the end of xmit ..."

I wonder if you could try the attachment in order to understand if we
have to  actually revert the patch (I ask you to not revert the
patch "stmmac: first frame...").

I cannot test on an HW with Normal descriptors, unfortunately.
I am continuing to review the code to try to find other issues
on this configuration.

Let me know.

Regards
peppe

>
> Regards,
> Andreas
>


--------------090103080600010208000003
Content-Type: text/x-patch; name="0001-stmmac-fix-TX-normal-DESC.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-stmmac-fix-TX-normal-DESC.patch"

>From 036b21b0396d6df42bd8e507be1449fbc7935bce Mon Sep 17 00:00:00 2001
From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 15 Mar 2016 16:54:51 +0100
Subject: [PATCH (net-next.git)] stmmac: fix TX normal DESC

This patch is to fix the normal descriptor that has
a broken len and the OWN bit never set.

Signed-off-by: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index e13228f..011386f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -199,11 +199,6 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 {
 	unsigned int tdes1 = p->des1;
 
-	if (mode == STMMAC_CHAIN_MODE)
-		norm_set_tx_desc_len_on_chain(p, len);
-	else
-		norm_set_tx_desc_len_on_ring(p, len);
-
 	if (is_fs)
 		tdes1 |= TDES1_FIRST_SEGMENT;
 	else
@@ -217,10 +212,15 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 	if (ls)
 		tdes1 |= TDES1_LAST_SEGMENT;
 
-	if (tx_own)
-		tdes1 |= TDES0_OWN;
-
 	p->des1 = tdes1;
+
+	if (mode == STMMAC_CHAIN_MODE)
+		norm_set_tx_desc_len_on_chain(p, len);
+	else
+		norm_set_tx_desc_len_on_ring(p, len);
+
+	if (tx_own)
+		p->des0 |= TDES0_OWN;
 }
 
 static void ndesc_set_tx_ic(struct dma_desc *p)
-- 
1.7.4.4


--------------090103080600010208000003--
