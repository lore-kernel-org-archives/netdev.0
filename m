From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Wed, 29 Oct 2008 13:25:06 -0700
Message-ID: <20081029132506.55b93555@extreme>
References: <20081029202027.GH12879@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54491 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753721AbYJ2UZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 16:25:12 -0400
In-Reply-To: <20081029202027.GH12879@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Oct 2008 13:20:27 -0700
Ira Snyder <iws@ovro.caltech.edu> wrote:

> This adds support to Linux for a virtual ethernet interface which uses the
> PCI bus as its transport mechanism. It creates a simple, familiar, and fast
> method of communication for two devices connected by a PCI interface.
> 
> I have implemented client support for the Freescale MPC8349EMDS board,
> which is capable of running in PCI Agent mode (It acts like a PCI card, but
> is a complete PowerPC computer, running Linux). It is almost certainly
> trivially ported to any MPC83xx system. It should be a relatively small
> effort to port it to any chip that can generate PCI interrupts and has at
> least one PCI accessible scratch register.
> 
> It was developed to work in a CompactPCI crate of computers, one of which
> is a relatively standard x86 system (acting as the host) and many PowerPC
> systems (acting as clients).
> 
> RFC v1 -> RFC v2:
>   * remove vim modelines
>   * use net_device->name in request_irq(), for irqbalance
>   * remove unnecessary wqt_get_stats(), use default get_stats() instead
>   * use dev_printk() and friends
>   * add message unit to MPC8349EMDS dts file
> 
> Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
> ---
> 
> This is the third posting of this driver. I got some feedback, and have
> corrected the problems. Stephen, thanks for the review! I also got some
> off-list feedback from a potential user, so I believe this is worth getting
> into mainline.
> 
> I'll post up a revised version about once a week as long as the changes are
> minor. If they are more substantial, I'll post them as needed.
> 
> GregKH: is this worth putting into the staging tree? (I left you out of the
> CC list to keep your email traffic down)
> 
> The remaining issues I see in this driver:
> 1) ==== Naming ====
>    The name wqt originally stood for "workqueue-test" and somewhat evolved
>    over time into the current driver. I'm looking for suggestions for a
>    better name. It should be the same between the host and client drivers,
>    to make porting the code between them easier. The drivers are /very/
>    similar other than the setup code.
> 2) ==== IMMR Usage ====
>    In the Freescale client driver, I use the whole set of board control
>    registers (AKA IMMR registers). I only need a very small subset of them,
>    during startup to set up the DMA window. I used the full set of
>    registers so that I could share the register offsets between the drivers
>    (in pcinet_hw.h)
> 3) ==== ioremap() of a physical address ====
>    In the Freescale client driver, I called ioremap() with the physical
>    address of the IMMR registers, 0xe0000000. I don't know a better way to
>    get them. They are somewhat exposed in the Flat Device Tree. Suggestions
>    on how to extract them are welcome.
> 4) ==== Hardcoded DMA Window Address ====
>    In the Freescale client driver, I just hardcoded the address of the
>    outbound PCI window into the DMA transfer code. It is 0x80000000.
>    Suggestions on how to get this value at runtime are welcome.
> 
> 
> Rationale behind some decisions:
> 1) ==== Usage of the PCINET_NET_REGISTERS_VALID bit ====
>    I want to be able to use this driver from U-Boot to tftp a kernel over
>    the PCI backplane, and then boot up the board. This means that the
>    device descriptor memory, which lives in the client RAM, becomes invalid
>    during boot.
> 2) ==== Buffer Descriptors in client memory ====
>    I chose to put the buffer descriptors in client memory rather than host
>    memory. It seemed more logical to me at the time. In my application,
>    I'll have 19 boards + 1 host per cPCI chassis. The client -> host
>    direction will see most of the traffic, and so I thought I would cut
>    down on the number of PCI accesses needed. I'm willing to change this.
> 3) ==== Usage of client DMA controller for all data transfer ====
>    This was done purely for speed. I tried using the CPU to transfer all
>    data, and it is very slow: ~3MB/sec. Using the DMA controller gets me to
>    ~40MB/sec (as tested with netperf).
> 4) ==== Static 1GB DMA window ====
>    Maintaining a window while DMA's in flight, and then changing it seemed
>    too complicated. Also, testing showed that using a static window gave me
>    a ~10MB/sec speedup compared to moving the window for each skb.
> 5) ==== The serial driver ====
>    Yes, there are two essentially separate drivers here. I needed a method
>    to communicate with the U-Boot bootloader on these boards without
>    plugging in a serial cable. With 19 clients + 1 host per chassis, the
>    cable clutter is worth avoiding. Since everything is connected via the
>    PCI bus anyway, I used that. A virtual serial port was simple to
>    implement using the messaging unit hardware that I used for the network
>    driver.
> 
> I'll post both U-Boot drivers to their mailing list once this driver is
> finalized.
> 
> Thanks,
> Ira
> 
> 
>  arch/powerpc/boot/dts/mpc834x_mds.dts |    7 +
>  drivers/net/Kconfig                   |   34 +
>  drivers/net/Makefile                  |    3 +
>  drivers/net/pcinet.h                  |   75 ++
>  drivers/net/pcinet_fsl.c              | 1351 ++++++++++++++++++++++++++++++++
>  drivers/net/pcinet_host.c             | 1383 +++++++++++++++++++++++++++++++++
>  drivers/net/pcinet_hw.h               |   77 ++
>  7 files changed, 2930 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/pcinet.h
>  create mode 100644 drivers/net/pcinet_fsl.c
>  create mode 100644 drivers/net/pcinet_host.c
>  create mode 100644 drivers/net/pcinet_hw.h
> 
> diff --git a/arch/powerpc/boot/dts/mpc834x_mds.dts b/arch/powerpc/boot/dts/mpc834x_mds.dts
> index c986c54..3bc8975 100644
> --- a/arch/powerpc/boot/dts/mpc834x_mds.dts
> +++ b/arch/powerpc/boot/dts/mpc834x_mds.dts
> @@ -104,6 +104,13 @@
>  			mode = "cpu";
>  		};
>  
> +		message-unit@8030 {
> +			compatible = "fsl,mpc8349-mu";
> +			reg = <0x8030 0xd0>;
> +			interrupts = <69 0x8>;
> +			interrupt-parent = <&ipic>;
> +		};
> +
>  		dma@82a8 {
>  			#address-cells = <1>;
>  			#size-cells = <1>;
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f749b40..eef7af7 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2279,6 +2279,40 @@ config UGETH_TX_ON_DEMAND
>  	bool "Transmit on Demand support"
>  	depends on UCC_GETH
>  
> +config PCINET_FSL
> +	tristate "PCINet Virtual Ethernet over PCI support (Freescale)"
> +	depends on MPC834x_MDS && !PCI
> +	select DMA_ENGINE
> +	select FSL_DMA
> +	help
> +	  When running as a PCI Agent, this driver will create a virtual
> +	  ethernet link running over the PCI bus, allowing simplified
> +	  communication with the host system. The host system will need
> +	  to use the corresponding driver.
> +
> +	  If in doubt, say N.
> +
> +config PCINET_HOST
> +	tristate "PCINet Virtual Ethernet over PCI support (Host)"
> +	depends on PCI
> +	help
> +	  This driver will let you communicate with a PCINet client device
> +	  using a virtual ethernet link running over the PCI bus. This
> +	  allows simplified communication with the client system.
> +
> +	  This is inteded for use in a system that has a crate full of
> +	  computers running Linux, all connected by a PCI backplane.
> +
> +	  If in doubt, say N.
> +
> +config PCINET_DISABLE_CHECKSUM
> +	bool "Disable packet checksumming"
> +	depends on PCINET_FSL || PCINET_HOST
> +	default n
> +	help
> +	  Disable packet checksumming on packets received by the PCINet
> +	  driver. This gives a possible speed boost.
> +
>  config MV643XX_ETH
>  	tristate "Marvell Discovery (643XX) and Orion ethernet support"
>  	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) || PLAT_ORION
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index f19acf8..c6fbafc 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -30,6 +30,9 @@ gianfar_driver-objs := gianfar.o \
>  obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
>  ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o ucc_geth_ethtool.o
>  
> +obj-$(CONFIG_PCINET_FSL) += pcinet_fsl.o
> +obj-$(CONFIG_PCINET_HOST) += pcinet_host.o
> +
>  #
>  # link order important here
>  #
> diff --git a/drivers/net/pcinet.h b/drivers/net/pcinet.h
> new file mode 100644
> index 0000000..66d2cba
> --- /dev/null
> +++ b/drivers/net/pcinet.h
> @@ -0,0 +1,75 @@
> +/*
> + * Shared Definitions for the PCINet / PCISerial drivers
> + *
> + * Copyright (c) 2008 Ira W. Snyder <iws@ovro.caltech.edu>
> + *
> + * Heavily inspired by the drivers/net/fs_enet driver
> + *
> + * This file is licensed under the terms of the GNU General Public License
> + * version 2. This program is licensed "as is" without any warranty of any
> + * kind, whether express or implied.
> + */
> +
> +#ifndef PCINET_H
> +#define PCINET_H
> +
> +#include <linux/kernel.h>
> +#include <linux/if_ether.h>
> +
> +/* Ring and Frame size -- these must match between the drivers */
> +#define PH_RING_SIZE	(64)
> +#define PH_MAX_FRSIZE	(64 * 1024)
> +#define PH_MAX_MTU	(PH_MAX_FRSIZE - ETH_HLEN)
> +
> +struct circ_buf_desc {
> +	__le32 sc;
> +	__le32 len;
> +	__le32 addr;
> +} __attribute__((__packed__));
> +typedef struct circ_buf_desc cbd_t;

Don't use typedef. See chapter 5 of Documentation/CodingStyle

Do you really need packed here, sometime gcc generates much worse code
on needlessly packed structures?
