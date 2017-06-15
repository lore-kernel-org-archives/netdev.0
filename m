From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: Toggling link state breaks network connectivity
Date: Thu, 15 Jun 2017 11:19:28 +0100
Message-ID: <yw1xk24dr1sf.fsf@unicorn.mansr.com>
References: <927c2f12-0d1b-1e80-fede-ad9abe807222@free.fr>
        <2c12bc7a-fd57-3d3d-7dc0-f522cfadd042@gmail.com>
        <b3d1fd0c-281a-dd5a-d0e8-75f42475a248@free.fr>
        <17e1e9c3-7adb-05fe-18cd-ce6db4ac792d@gmail.com>
        <51eb8306-64e5-f528-d663-be80c73098f1@free.fr>
        <6edad982-713a-1b38-d9f0-e763c70c4f95@gmail.com>
        <f99f714e-2522-3b6e-6619-7a82db2b76db@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:51326 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752092AbdFOKZy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 06:25:54 -0400
In-Reply-To: <f99f714e-2522-3b6e-6619-7a82db2b76db@free.fr> (Mason's message
        of "Wed, 14 Jun 2017 16:49:37 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> [   33.393332] ENTER nb8800_stop
> [   33.421731] nb8800_mdio_write: reg=9 val=0200	# by genphy_config_aneg()
> [   33.444062] nb8800_mdio_write: reg=0 val=1200	# by genphy_restart_aneg()
> [   33.466411] nb8800_mdio_write: reg=18 val=0000	# by at803x_config_intr() from phy_stop()

Those are from the phy_stop() call.

The following is the ridiculous dance required to stop rx dma in
nb8800_dma_stop():

> [   33.488859] ++ETH++ gw8  0xf0026004 0x03		# ETH_MAC_CORE_RECEIVE_CONTROL
Disable address filter.

> [   33.492805] ++ETH++ gw8  0xf0026044 0x04		# ETH_MAC_CORE_MAC_MODE  *WHY ??*
Enable loopback.

> [   33.496748] ++ETH++ gw32 0xf002610c 0x9dcac000	\
> [   33.501217] ++ETH++ gw32 0xf0026100 0x000002ff	|
Send frame.

> [   33.505750] ++ETH++ gw32 0xf0026104 0x00000004	| IRQ?
> [   33.510213] ++ETH++ gw32 0xf0026204 0x00000004	| 
> [   33.514674] ++ETH++ gw32 0xf0026218 0x003cc4a4	|
> [   33.519146] ++ETH++ gw32 0xf0026104 0x00000001	/
Handle resulting interrupt(s).

> [   33.605719] ++ETH++ gw32 0xf002610c 0x9dcac000	\
> [   33.610187] ++ETH++ gw32 0xf0026100 0x000002ff	|
Send frame.

> [   33.614717] ++ETH++ gw32 0xf0026104 0x00000004	| ANOTHER IRQ?
> [   33.619178] ++ETH++ gw32 0xf0026204 0x00000004	|
> [   33.623637] ++ETH++ gw32 0xf0026218 0x003cc4a4	|
> [   33.628106] ++ETH++ gw32 0xf0026104 0x00000001	/
Handle interrupt(s).

> [   33.714689] ++ETH++ gw32 0xf002610c 0x9dcac000	|
> [   33.719156] ++ETH++ gw32 0xf0026100 0x000002ff	| ANOTHER IRQ?
Send frame.

> [   33.723686] ++ETH++ gw32 0xf0026104 0x00000004	|
Handle tx interrupt.

> [   33.724625] ++ETH++ gw8  0xf0026004 0x23		# ETH_MAC_CORE_RECEIVE_CONTROL
Enable address filter.

> [   33.724627] ++ETH++ gw8  0xf0026044 0x00		# ETH_MAC_CORE_MAC_MODE *AGAIN ??*
Disable loopback.

> [   33.724640] ++ETH++ gw32 0xf002620c 0x9de36000
>From nb8800_dma_reset().

> [   33.724642] ++ETH++ gw8  0xf0026004 0x22		# ETH_MAC_CORE_RECEIVE_CONTROL AGAIN
Disable rx.

> [   33.724644] ++ETH++ gw8  0xf0026000 0x1c		# ETH_MAC_CORE_TRANSMIT_CONTROL
Disable tx.

> [   33.724690] nb8800_mdio_write: reg=18 val=0000	# by at803x_config_intr() from phy_disable_interrupts()
> [   33.724913] nb8800_mdio_write: reg=0 val=1800	# by at803x_suspend() from phy_suspend()

> [   33.819562] ++ETH++ gw32 0xf0026204 0x00000004
> [   33.824021] ++ETH++ gw32 0xf0026218 0x003cc4a4
Handle rx interrupt, probably from the last loopback frame sent earlier.

> [   33.828518] EXIT  nb8800_stop

Now I did notice one thing.  When the interrupts from the loopback
frames are handled, the rx interrupt is all but disabled for NAPI poll
mode.  Of course, NAPI isn't active, so the rx interrupt never gets
re-enabled.  We should probably do this in ndo_open just to be sure.

Try this patch:

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index e078d8da978c..f968468076b9 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -969,6 +969,7 @@ static int nb8800_open(struct net_device *dev)
 	if (err)
 		goto err_free_dma;
 
+	nb8800_writel(priv, NB8800_RX_ITR, priv->rx_itr_irq);
 	nb8800_mac_rx(dev, true);
 	nb8800_mac_tx(dev, true);
 


-- 
Måns Rullgård
