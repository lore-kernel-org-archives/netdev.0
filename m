From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCHv3 (net.git) 2/2] stmmac: fix MDIO settings
Date: Tue, 15 Mar 2016 01:54:14 +0100
Message-ID: <56E75D36.2030201@suse.de>
References: <1457703196-15008-1-git-send-email-peppe.cavallaro@st.com>
 <1457703196-15008-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gabriel.fernandez@linaro.org,
	fschaefer.oss@googlemail.com, dinh.linux@gmail.com,
	davem@davemloft.net, preid@electromag.com.au
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59068 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933111AbcCOAyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 20:54:19 -0400
In-Reply-To: <1457703196-15008-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

Am 11.03.2016 um 14:33 schrieb Giuseppe Cavallaro:
> Initially the phy_bus_name was added to manipulate the
> driver name but It was recently just used to manage the

"it"

> fixed-link and then to take some decision at run-time
> inside the main (for example to skip EEE).

Word missing after "main"? ("function"?)

> So the patch uses the is_pseudo_fixed_link and removes
> removes the phy_bus_name variable not necessary anymore.

Duplicate "removes".

>=20
> The driver can manage the mdio registration by using phy-handle,
> dwmac-mdio and own parameter e.g. snps,phy-addr.
> This patch takes care about all these possible configurations
> and fixes the mdio registration in case of there is a real
> transceiver or a switch (that needs to be managed by using
> fixed-link).
>=20
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Reviewed-by: Andreas F=C3=A4rber <afaerber@suse.de>
> Tested-by: Frank Sch=C3=A4fer <fschaefer.oss@googlemail.com>
> Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>
> Cc: Dinh Nguyen <dinh.linux@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Phil Reid <preid@electromag.com.au>
> ---
>=20
> V2: use is_pseudo_fixed_link
> V3: parse device-tree driver parameters to allocate PHY resources con=
sidering
>     DSA case (+ fixed-link).

=46or next-20160314 I needed "i2c: immediately mark ourselves as
registered" plus this build fix:

--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -866,9 +866,8 @@ static int stmmac_init_phy(struct net_device *dev)
        }

        /* If attached to a switch, there is no reason to poll phy
handler */
-       if (priv->plat->phy_bus_name)
-               if (!strcmp(priv->plat->phy_bus_name, "fixed"))
-                       phydev->irq =3D PHY_IGNORE_INTERRUPT;
+       if (phydev->is_pseudo_fixed_link)
+               phydev->irq =3D PHY_IGNORE_INTERRUPT;

        pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
                 " Link =3D %d\n", dev->name, phydev->phy_id, phydev->l=
ink);

It then fixes the PHY error on GeekBox, so for this mini-series:

Tested-by: Andreas F=C3=A4rber <afaerber@suse.de>


The connectivity issue still remains. Kernel log snippet:

[  +0.001117] rk_gmac-dwmac ff290000.ethernet: Looking up phy-supply
from device tree
[  +0.000028] rk808 0-001b: Looking up vcc12-supply from device tree
[  +0.000014] vcc_lan: supplied by vcc_io
[  +0.000101] rk_gmac-dwmac ff290000.ethernet: clock input or output?
(input).
[  +0.000009] rk_gmac-dwmac ff290000.ethernet: TX delay(0x30).
[  +0.000008] rk_gmac-dwmac ff290000.ethernet: RX delay(0x10).
[  +0.000014] rk_gmac-dwmac ff290000.ethernet: init for RGMII
[  +0.000104] rk_gmac-dwmac ff290000.ethernet: clock input from PHY
[  +0.005063] rk_gmac-dwmac ff290000.ethernet: no reset control found
[  +0.000007] stmmac - user ID: 0x10, Synopsys ID: 0x35
[  +0.000002]  Ring mode enabled
[  +0.000006]  DMA HW capability register supported
[  +0.000000]  Normal descriptors
[  +0.000003]  RX Checksum Offload Engine supported (type 2)
[  +0.000002]  TX Checksum insertion supported
[  +0.000002]  Wake-Up On Lan supported
[  +0.000053]  Enable RX Mitigation via HW Watchdog Timer
[  +0.000771] of_get_named_gpiod_flags: can't parse 'snps,reset-gpio'
property of node '/ethernet@ff290000[0]'
[  +0.004250] libphy: stmmac: probed
[  +0.000009] eth0: PHY ID 001cc915 at 0 IRQ POLL (stmmac-0:00) active
[  +0.000005] eth0: PHY ID 001cc915 at 1 IRQ POLL (stmmac-0:01)

As before, reverting "stmmac: first frame prep at the end of xmit
routine" fixes it. My test cases are `ping 192.168.1.1` and `zypper up`=
=2E

Regards,
Andreas

--=20
SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg, Germany
GF: Felix Imend=C3=B6rffer, Jane Smithard, Graham Norton; HRB 21284 (AG=
 N=C3=BCrnberg)
