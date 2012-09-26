From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 2/2] net: ti cpsw ethernet: set IFCTL_{A,B} bits for
 RMII mode
Date: Wed, 26 Sep 2012 18:50:50 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9EBB74@DBDE01.ent.ti.com>
References: <1348680268-8194-1-git-send-email-zonque@gmail.com>
 <1348680268-8194-2-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"Hiremath, Vaibhav" <hvaibhav@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: Daniel Mack <zonque@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56506 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758069Ab2IZSvB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 14:51:01 -0400
In-Reply-To: <1348680268-8194-2-git-send-email-zonque@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Daniel Mack [mailto:zonque@gmail.com]
> Sent: Wednesday, September 26, 2012 10:54 PM
> To: netdev@vger.kernel.org
> Cc: devicetree-discuss@lists.ozlabs.org; Daniel Mack; N, Mugunthan V;
> Hiremath, Vaibhav; David S. Miller
> Subject: [PATCH 2/2] net: ti cpsw ethernet: set IFCTL_{A,B} bits for
> RMII mode
> 
> For RMII mode operation in 100Mbps, the CPSW needs to set the
> IFCTL_A / IFCTL_B bits in the MACCONTROL register.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: Vaibhav Hiremath <hvaibhav@ti.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c
> b/drivers/net/ethernet/ti/cpsw.c
> index 3d7594e..d88dbfa 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -386,6 +386,12 @@ static void _cpsw_adjust_link(struct cpsw_slave
> *slave,
>  			mac_control |= BIT(7);	/* GIGABITEN	*/
>  		if (phy->duplex)
>  			mac_control |= BIT(0);	/* FULLDUPLEXEN	*/
> +
> +		/* set speed_in input in case RMII mode is used in >10Mbps
> */
> +		if (phy->speed > 10 && slave->slave_num < 2 &&
> +		    phy->interface == PHY_INTERFACE_MODE_RMII)
> +			mac_control |= BIT(15 + slave->slave_num);

Mac control register is separate for both the slaves and has same bit definitions,
Bit 15 has to be set for 100Mbps link for RMII and RGMII Phy interface to control
the RMII/RGMII gasket and in GMII this bit is Un-used by CPSW.
For slave 1, Bit 16 is set with the above code which is not used control the
RMII/RGMII gasket control. So it is not required to pass the Phy mode from DT.
This patch has to be reworked to set Bit 15 with any Phy mode connected.

The original driver present was tested with GMII (Beagle Bone A5) and
RGMII (AM3358 EVM) phy , but CPSW works fine without setting this bit in
RGMII phymode so this issue was not caught in testing.

Regards
Mugunthan V N

> +
>  		*link = true;
>  	} else {
>  		mac_control = 0;
> --
> 1.7.11.4
