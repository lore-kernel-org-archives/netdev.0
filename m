From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] gianfar: Fix race in TBI/SerDes configuration
Date: Fri, 31 Oct 2008 01:00:09 -0400
Message-ID: <490A90D9.1080406@garzik.org>
References: <Pine.LNX.4.64.0810301738020.3943@t2.domain.actdsltmp> <1225415827-8167-1-git-send-email-tpiepho@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Nate Case <ncase@xes-inc.com>
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40059 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751271AbYJaFAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 01:00:13 -0400
In-Reply-To: <1225415827-8167-1-git-send-email-tpiepho@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trent Piepho wrote:
> The init_phy() function attaches to the PHY, then configures the
> SerDes<->TBI link (in SGMII mode).  The TBI is on the MDIO bus with the PHY
> (sort of) and is accessed via the gianfar's MDIO registers, using the
> functions gfar_local_mdio_read/write(), which don't do any locking.
> 
> The previously attached PHY will start a work-queue on a timer, and
> probably an irq handler as well, which will talk to the PHY and thus use
> the MDIO bus.  This uses phy_read/write(), which have locking, but not
> against the gfar_local_mdio versions.
> 
> The result is that PHY code will try to use the MDIO bus at the same time
> as the SerDes setup code, corrupting the transfers.
> 
> Setting up the SerDes before attaching to the PHY will insure that there is
> no race between the SerDes code and *our* PHY, but doesn't fix everything.
> Typically the PHYs for all gianfar devices are on the same MDIO bus, which
> is associated with the first gianfar device.  This means that the first
> gianfar's SerDes code could corrupt the MDIO transfers for a different
> gianfar's PHY.
> 
> The lock used by phy_read/write() is contained in the mii_bus structure,
> which is pointed to by the PHY.  This is difficult to access from the
> gianfar drivers, as there is no link between a gianfar device and the
> mii_bus which shares the same MDIO registers.  As far as the device layer
> and drivers are concerned they are two unrelated devices (which happen to
> share registers).
> 
> Generally all gianfar devices' PHYs will be on the bus associated with the
> first gianfar.  But this might not be the case, so simply locking the
> gianfar's PHY's mii bus might not lock the mii bus that the SerDes setup
> code is going to use.
> 
> We solve this by having the code that creates the gianfar platform device
> look in the device tree for an mdio device that shares the gianfar's
> registers.  If one is found the ID of its platform device is saved in the
> gianfar's platform data.
> 
> A new function in the gianfar mii code, gfar_get_miibus(), can use the bus
> ID to search through the platform devices for a gianfar_mdio device with
> the right ID.  The platform device's driver data is the mii_bus structure,
> which the SerDes setup code can use to lock the current bus.
> 
> Signed-off-by: Trent Piepho <tpiepho@freescale.com>
> CC: Andy Fleming <afleming@freescale.com>
> ---
>  arch/powerpc/sysdev/fsl_soc.c |   26 ++++++++++++++++++++++++++
>  drivers/net/gianfar.c         |    7 +++++++
>  drivers/net/gianfar_mii.c     |   21 +++++++++++++++++++++
>  drivers/net/gianfar_mii.h     |    3 +++
>  include/linux/fsl_devices.h   |    3 ++-
>  5 files changed, 59 insertions(+), 1 deletions(-)

applied 1-2


