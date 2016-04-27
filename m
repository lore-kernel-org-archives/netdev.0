From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Wed, 27 Apr 2016 11:28:33 +0200
Message-ID: <9959575.BZQKgEZNvs@wuerfel>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com> <20160426194102.GF30107@lunn.ch> <CAALAos_bPnT96xA883mkkjwUTut=_NJymUZKM=-0ZujdDxNEkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Device Tree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Suzuki K Poulose <suzuki.poulose-5wv7dgnIgG8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Punit Agrawal <punit.agrawal-5wv7dgnIgG8@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	BCM Kernel Feedback <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Linux ARM Kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
To: Anup Patel <anup.patel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAALAos_bPnT96xA883mkkjwUTut=_NJymUZKM=-0ZujdDxNEkA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 27 April 2016 10:16:40 Anup Patel wrote:

> It is really interesting to see the evolution of MDIO bus:
> 
> 1. Traditionally, MDIO controller used to be part of each ethernet controller
> itself so each ethernet controller used to have it's own 2 wire MDIO bus
> 
> 2. Next, we saw SoC with multiple ethernet controllers sharing same MDIO
> bus. In other words, we saw multiple MDIO bus being muxed over single
> MDIO bus with additional bus select lines (I think this is when
> drivers/net/phy/mdio-mux.c APIs were implemented but at this point all
> PHYs on muxed MDIO bus were ethernet PHYs).
> 
> 3. Then, we saw SoC with ethernet switch devices also accessible over
> shared MDIO bus (or Muxed MDIO bus) along with ethernet PHYs (I guess
> this is why we have drivers/net/phy/mdio_device.c which adds
> "mdio_device" for non-ethernet-PHY devices on MDIO bus).
> 
> 4. Now, we have SoC with SATA PHYs, PCIe PHYs, USB PHYs, and Ethernet
> PHYs all accessible over same shared MDIO bus (or Muxed MDIO bus). The
> SATA PHYs and PCIe PHYs are registered to "Generic PHY framework". For
> USB PHYs, we can either register to "Generic PHY framework" or "USB PHY
> framework". For Ethernet PHYs, we register MDIO bus instance to "Ethernet
> MDIO framework".

Thanks for the extra background information.

> The devices on ARM64 SoC has to be within first 4GB and RAM has to start
> from first 4GB to be ARM compliant because ARM64 CPUs have 32bit mode and
> all devices and RAM should be available to 32bit mode with MMU disabled.
> This means that we only have 4GB to fit all devices registers and some
> portion of RAM. Some of these non-Ethernet PHYs have tons of registers so
> as number of PHYs increase in a SoC they will eat-up lot of first 4GB
> address space. Using same MDIO bus for all types of PHYs (SATA, PCIe, USB,
> and Ethernet) is actually a good approach because it actually saves lot of
> first 4GB address space. In future, more devices will be moved to a shared
> MDIO bus which are less frequently accessed.

I think it remains to be seen if anyone other than Broadcom follows
this model. I have no idea if that's likely or not, perhaps everyone
does this, perhaps you are the only ones.

> For Broadcom iProc SoCs, the design choice has already been made to use
> shared MDIO bus for all PHYs. In fact, Broadcom iProc NS2 SoC already has
> a shared MDIO bus for SATA PHYs, USB PHYs, PCIe PHYs, and Ethernet
> PHYs and more Broadcom iProc SoCs are on their way. Of course, there are
> few exceptions in iProc SoCs such as SATA PHYs where we also have memory
> mapped registers to access PHYs but other PHYs don't have such memory
> mapped registers.
> 
> Clearly from above, the traditional 2 wire MDIO bus is now a shared MDIO
> bus with 2-wire plus additional select lines. Also, now we have SoCs (such
> as Broadcom iProc SoCs) which has such shared MDIO bus and I think
> in-future we will have SoCs with a shared MDIO bus for variety of devices.
> 
> For long term, we really need a clean solution to fit shared MDIO based
> PHY drivers in Linux kernel. Also, shared MDIO based PHY drivers should
> not be dependent on any particular IO subsystem (such as Linux Ethernet)
> because there are lot of use-cases where people want strip down kernel
> image by not-compiling IO subsystems which are not required.
> 
> IMHO, we have several options in front of us:
> 1. Use some light-weight framework (such as shared_mdio.c implemented
> by this patchset) under drivers/bus

I think this has been sufficiently NAKed by everyone

> 2. Extend "Generic PHY framework" to allow something like shared MDIO
> bus (as-per Arnd's suggestion)
> 3. Move-out "MDIO-mux APIs" from drivers/net/phy to something like
> drivers/mdio-mux and make it independent of "Linux Ethernet subsystem".
> (... may be more options ...)

while these two really describe the same thing. I think as a first
step, we can reorganize the Kconfig structure to put ethernet PHY
and the MDIO bus as two separate submenus in drivers/phy/Kconfig,
and make the latter independent of CONFIG_NETDEVICES, see patch
below. With that, you should already be able to write a generic
phy driver that registers itself as an MDIO device driver.

We can also debate moving files from drivers/net/phy and
drivers/usb/phy into drivers/phy/{net,mdio,usb}/ as a follow-up,
but the file location is really not all that important here.

	Arnd


diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index befd67df08e1..c58b60e70ab2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -356,8 +356,6 @@ config NET_SB1000
 
 	  If you don't have this card, of course say N.
 
-source "drivers/net/phy/Kconfig"
-
 source "drivers/net/plip/Kconfig"
 
 source "drivers/net/ppp/Kconfig"
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 2ffd63463299..2e2491b344d9 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -11,9 +11,6 @@ menuconfig ETHERNET
 
 if ETHERNET
 
-config MDIO
-	tristate
-
 config SUNGEM_PHY
 	tristate
 
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6dad9a9c356c..58447866fe64 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -3,8 +3,9 @@
 #
 
 menuconfig PHYLIB
-	tristate "PHY Device support and infrastructure"
+	tristate "Ethernet PHY Device support and infrastructure"
 	depends on NETDEVICES
+	select MDIO
 	help
 	  Ethernet controllers are usually attached to PHY
 	  devices.  This option provides infrastructure for
@@ -164,6 +165,16 @@ config FIXED_PHY
 	  PHYs that are not connected to the real MDIO bus.
 
 	  Currently tested with mpc866ads and mpc8349e-mitx.
+endif # PHYLIB
+
+config MDIO
+	tristate
+	help
+	  The MDIO bus is typically used ethernet PHYs, but can also be
+	  used by other PHY drivers.
+
+menu "MDIO bus drivers"
+	depends on MDIO
 
 config MDIO_BITBANG
 	tristate "Support for bitbanged MDIO buses"
@@ -271,7 +282,7 @@ config MDIO_BCM_IPROC
 	  This module provides a driver for the MDIO busses found in the
 	  Broadcom iProc SoC's.
 
-endif # PHYLIB
+endmenu # MDIO
 
 config MICREL_KS8995MA
 	tristate "Micrel KS8995MA 5-ports 10/100 managed Ethernet switch"
diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig
index ce29c17359e9..298893744a17 100644
--- a/drivers/phy/Kconfig
+++ b/drivers/phy/Kconfig
@@ -2,7 +2,9 @@
 # PHY
 #
 
-menu "PHY Subsystem"
+menu "PHY drivers"
+
+menu "Generic PHY subsystem"
 
 config GENERIC_PHY
 	bool "PHY Core"
@@ -425,3 +427,7 @@ config PHY_CYGNUS_PCIE
 source "drivers/phy/tegra/Kconfig"
 
 endmenu
+
+source "drivers/net/phy/Kconfig"
+
+endmenu

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
