From: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 0/6] Add Shared MDIO framework for iProc based SoCs
Date: Thu, 21 Apr 2016 14:48:37 +0530
Message-ID: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
Cc: BCM Kernel Feedback <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Suzuki K Poulose <suzuki.poulose-5wv7dgnIgG8@public.gmane.org>,
	Punit Agrawal <punit.agrawal-5wv7dgnIgG8@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Broadcom iProc based SoCs uses MDIO bus for programming PHYs belonging to
different I/O subsystem like USB, SATA, PCIe, ETHERNET etc. Every subsystem
is referred as "Master" When a master is selected, all PHYs belonging to
this subsystem get active on the MDIO bus and responds to MDIO transaction.
In this way one MDIO controller is shared among all masters hence named as
"Shared MDIO controller".

We have two important entities in "Shared MDIO Bus" framework:
1) shared_mdio_master and
2) shared_mdio_driver.

The shared MDIO controller driver is registered as platform driver and it
creates shared_mdio_master instances and adds them to "Shared MDIO Bus"
framework. The "Shared MDIO Bus" framework will try to match-n-probe each
shared_mdio_master instance with all available shared_mdio_driver based on
DT matching. The shared_mdio_driver will acts as phy provider for
respective PHY frameworks and it will access PHY registers only using
"Shared MDIO Bus" framework APIs. All PHY read/write from
shared_mdio_driver will eventually reach shared MDIO controller driver
(who originally created shared_mdio_master instances) and shared MDIO
controller driver will serialized these PHY read/write as required.

This patch set includes Shared MDIO Bus framework, Shared MDIO block driver
and one Shared MDIO driver, ETHERNET PHY provider driver.

shared_mdio.c: This is the bus framework where all masters are registered
via shared MDIO block driver.

iproc_shared_mdio.c: Represent the shared MDIO block driver. The driver
registers all masters to shared mdio bus framework.

mdio-bcm-iproc-shared.c: Master driver which registers ETHERNET phy to
legacy MII framework.

In future there will be more driver for SATA, USB, PCIe masters which will
register phys for their subsystem.

Patch series is developed based on Linux v4.6-rc1 and available at:
repo: https://github.com/Broadcom/arm64-linux.git
branch: shared_mdio_v0

Pramod Kumar (6):
  bus: Add shared MDIO bus framework
  Documentation: DT binding doc for iProc Shared MDIO Controller.
  bus: Add platform driver for iProc shared MDIO Controller
  dt: Add Shared MDIO Controller node for NS2
  Documentation: Binding doc for ethernet master in NS2
  net:phy: Add Ethernet Master for iProc Shared MDIO Controller

 .../bindings/bus/brcm,iproc-shared-mdio.txt        |  76 ++++++
 .../bindings/net/brcm,iproc-mdio-shared.txt        |  32 +++
 arch/arm64/boot/dts/broadcom/ns2-svk.dts           |  15 ++
 arch/arm64/boot/dts/broadcom/ns2.dtsi              |   8 +
 drivers/bus/Kconfig                                |  22 ++
 drivers/bus/Makefile                               |   2 +
 drivers/bus/iproc_shared_mdio.c                    | 287 +++++++++++++++++++++
 drivers/bus/shared_mdio.c                          | 179 +++++++++++++
 drivers/net/phy/Kconfig                            |  11 +
 drivers/net/phy/Makefile                           |   1 +
 drivers/net/phy/mdio-bcm-iproc-shared.c            | 116 +++++++++
 include/linux/shared_mdio.h                        | 123 +++++++++
 12 files changed, 872 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
 create mode 100644 Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
 create mode 100644 drivers/bus/iproc_shared_mdio.c
 create mode 100644 drivers/bus/shared_mdio.c
 create mode 100644 drivers/net/phy/mdio-bcm-iproc-shared.c
 create mode 100644 include/linux/shared_mdio.h

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
