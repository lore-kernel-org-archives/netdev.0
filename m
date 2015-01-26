From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Mon, 26 Jan 2015 14:30:02 -0800
Message-ID: <54C6BFEA.5020101@gmail.com>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>,
	abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
To: Stathis Voukelatos <stathisv70-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422007621-13567-1-git-send-email-stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 23/01/15 02:07, Stathis Voukelatos wrote:
> This patch adds support the Ethernet Packet Sniffer H/W module
> developed by Linn Products Ltd and found in the IMG Pistachio SoC.
> The module allows Ethernet packets to be parsed, matched against
> a user-defined pattern and timestamped. It sits between a 100M
> Ethernet MAC and PHY and is completely passive with respect to
> Ethernet frames.

Is there any latency penalty involved in capturing (or not) packets as
opposed to having this capture HW unused?

> 
> Matched packet bytes and timestamp values are returned through a
> FIFO. Timestamps are provided to the module through an externally
> generated Gray-encoded counter.
> 
> The command pattern for packet matching is stored in module RAM
> and consists of a sequence of 16-bit entries. Each entry includes
> an 8-bit command code and and 8-bit data value. Valid command
> codes are:
> 0 - Don't care
> 1 - Match: packet data must match command string byte
> 2 - Copy: packet data will be copied to FIFO
> 3 - Match/Stamp: if packet data matches string byte, a timestamp
>                  is copied into the FIFO
> 4 - Copy/Done: packet data will be copied into the FIFO.
>                This command terminates the command string.
> 
> The driver consists of two modules:
> - Core: it provides an API to user space using the Generic Netlink
>         framework. Specific backend implementations, like the
>         Ethernet Packet Sniffer, register one or more channels
>         with the Core. For each channel a Genl family is created.
>         User space can access a channel by sending Genl messages
>         to the Genl family associated with the channel. Packet
>         matching events are multicast.

Instead of having this new generic netlink family to control sniffing,
could we imagine registering a netdevice which does not nothing but
still allows for tools like tcpdump, af_packet and other capture tools
to work transparently and just leverage the HW capture?

> 
> - Ethernet Packet Sniffer backend: provides the driver for the
>         Linn Ethernet Packet Sniffer H/W modules.
> 
> The split between a core and backend modules allows software-only
> implementations to be added for platforms where no H/W support
> is available.
> 
> Based on 3.19-rc5
> 
> Signed-off-by: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> ---
>  .../bindings/net/linn-ether-packet-sniffer.txt     |  27 ++
>  .../devicetree/bindings/vendor-prefixes.txt        |   1 +
>  MAINTAINERS                                        |   7 +
>  drivers/net/Kconfig                                |   2 +
>  drivers/net/Makefile                               |   1 +
>  drivers/net/pkt-sniffer/Kconfig                    |  23 ++
>  drivers/net/pkt-sniffer/Makefile                   |   8 +
>  drivers/net/pkt-sniffer/backends/ether/channel.c   | 366 ++++++++++++++++++
>  drivers/net/pkt-sniffer/backends/ether/channel.h   |  76 ++++
>  drivers/net/pkt-sniffer/backends/ether/hw.h        |  46 +++
>  drivers/net/pkt-sniffer/backends/ether/platform.c  | 231 +++++++++++
>  drivers/net/pkt-sniffer/core/dev_table.c           | 124 ++++++
>  drivers/net/pkt-sniffer/core/module.c              |  37 ++
>  drivers/net/pkt-sniffer/core/nl.c                  | 427 +++++++++++++++++++++
>  drivers/net/pkt-sniffer/core/nl.h                  |  34 ++
>  drivers/net/pkt-sniffer/core/snf_core.h            |  64 +++
>  include/linux/pkt_sniffer.h                        |  89 +++++
>  17 files changed, 1563 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
>  create mode 100644 drivers/net/pkt-sniffer/Kconfig
>  create mode 100644 drivers/net/pkt-sniffer/Makefile
>  create mode 100644 drivers/net/pkt-sniffer/backends/ether/channel.c
>  create mode 100644 drivers/net/pkt-sniffer/backends/ether/channel.h
>  create mode 100644 drivers/net/pkt-sniffer/backends/ether/hw.h
>  create mode 100644 drivers/net/pkt-sniffer/backends/ether/platform.c
>  create mode 100644 drivers/net/pkt-sniffer/core/dev_table.c
>  create mode 100644 drivers/net/pkt-sniffer/core/module.c
>  create mode 100644 drivers/net/pkt-sniffer/core/nl.c
>  create mode 100644 drivers/net/pkt-sniffer/core/nl.h
>  create mode 100644 drivers/net/pkt-sniffer/core/snf_core.h
>  create mode 100644 include/linux/pkt_sniffer.h
> 
> diff --git a/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
> new file mode 100644
> index 0000000..6b6e105
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
> @@ -0,0 +1,27 @@
> +* Linn Products Ethernet Packet Sniffer
> +
> +Required properties:
> +- compatible : must be "linn,eth-sniffer"
> +- reg : physical addresses and sizes of registers. Must contain 3 entries:
> +          first entry: registers memory space
> +          second entry: TX command memory
> +          third entry: RX command memory
> +- reg-names : must contain the following 3 entries:
> +                  "regs", "tx-ram", "rx-ram"
> +- interrupts : sniffer interrupt specifier
> +- clocks : specify the system clock for the peripheral
> +- clock-names : must contain the "sys" entry
> +- fifo-block-words : number of words in one data FIFO entry
> +
> +Example:
> +
> +sniffer@1814a000 {
> +        compatible = "linn,eth-sniffer";
> +        reg = <0x1814a000 0x100>, <0x1814a400 0x400>, <0x1814a800 0x400>;
> +        reg-names = "regs", "tx-ram", "rx-ram";
> +        interrupts = <GIC_SHARED 58 IRQ_TYPE_LEVEL_HIGH>;
> +        interrupt-names = "eth-sniffer-irq";
> +        clocks = <&system_clk>;
> +        clock-names = "sys";
> +        fifo-block-words = <4>;
> +    };
> diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Documentation/devicetree/bindings/vendor-prefixes.txt
> index b1df0ad..2c96f35 100644
> --- a/Documentation/devicetree/bindings/vendor-prefixes.txt
> +++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
> @@ -90,6 +90,7 @@ lacie	LaCie
>  lantiq	Lantiq Semiconductor
>  lenovo	Lenovo Group Ltd.
>  lg	LG Corporation
> +linn	Linn Products Ltd.
>  linux	Linux-specific binding
>  lsi	LSI Corp. (LSI Logic)
>  lltc	Linear Technology Corporation
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 2fa3853..7dbc6e7 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5708,6 +5708,13 @@ M:	Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>  S:	Maintained
>  F:	tools/lib/lockdep/
>  
> +LINN PACKET SNIFFER DRIVER
> +M: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> +S: Maintained
> +F: include/linux/pkt_sniffer.h
> +F: drivers/net/pkt-sniffer/
> +F: Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
> +
>  LINUX FOR IBM pSERIES (RS/6000)
>  M:	Paul Mackerras <paulus-hXjcm30GF6XQT0dZR+AlfA@public.gmane.org>
>  W:	http://www.ibm.com/linux/ltc/projects/ppc
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index d6607ee..219c786 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -380,4 +380,6 @@ config VMXNET3
>  
>  source "drivers/net/hyperv/Kconfig"
>  
> +source "drivers/net/pkt-sniffer/Kconfig"
> +
>  endif # NETDEVICES
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index e25fdd7..441111b 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -66,3 +66,4 @@ obj-$(CONFIG_USB_NET_DRIVERS) += usb/
>  
>  obj-$(CONFIG_HYPERV_NET) += hyperv/
>  obj-$(CONFIG_NTB_NETDEV) += ntb_netdev.o
> +obj-$(CONFIG_PKT_SNIFFER) += pkt-sniffer/
> diff --git a/drivers/net/pkt-sniffer/Kconfig b/drivers/net/pkt-sniffer/Kconfig
> new file mode 100644
> index 0000000..26b4f98
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/Kconfig
> @@ -0,0 +1,23 @@
> +menuconfig PKT_SNIFFER
> +    tristate "Linn packet sniffer support"
> +    ---help---
> +    Say Y to add support for Linn packet sniffer drivers.
> +
> +    The core driver can also be built as a module. If so, the module
> +    will be called snf_core.
> +
> +if PKT_SNIFFER
> +
> +config PKT_SNIFFER_ETHER
> +    tristate "Ethernet packet sniffer"
> +    depends on MIPS
> +    default n
> +    help
> +        Say Y here if you want to use the Linn Ethernet packet sniffer
> +        module. It can be found in the upcoming Pistachio SoC by
> +        Imagination Technologies.
> +
> +        The driver can also be built as a module. If so, the module
> +        will be called snf_ether.
> +
> +endif # PKT_SNIFFER
> diff --git a/drivers/net/pkt-sniffer/Makefile b/drivers/net/pkt-sniffer/Makefile
> new file mode 100644
> index 0000000..07e7339
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/Makefile
> @@ -0,0 +1,8 @@
> +snf_core-y += core/nl.o
> +snf_core-y += core/dev_table.o
> +snf_core-y += core/module.o
> +obj-$(CONFIG_PKT_SNIFFER) += snf_core.o
> +
> +snf_ether-y += backends/ether/platform.o
> +snf_ether-y += backends/ether/channel.o
> +obj-$(CONFIG_PKT_SNIFFER_ETHER) += snf_ether.o
> diff --git a/drivers/net/pkt-sniffer/backends/ether/channel.c b/drivers/net/pkt-sniffer/backends/ether/channel.c
> new file mode 100644
> index 0000000..d483b58
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/backends/ether/channel.c
> @@ -0,0 +1,366 @@
> +/*
> + * Ethernet Mii packet sniffer driver
> + *  - channel functions
> + *
> + * Copyright (C) 2015 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#include <linux/io.h>
> +#include <linux/of.h>
> +#include <linux/pkt_sniffer.h>
> +#include "../../core/snf_core.h"
> +#include "hw.h"
> +#include "channel.h"
> +
> +#define to_ether_snf_chan(dev) container_of(dev, struct ether_snf_chan, chan)
> +
> +static int esnf_start(struct snf_chan *dev);
> +static int esnf_stop(struct snf_chan *dev);
> +static int esnf_set_pattern(struct snf_chan *dev, const u8 *pattern, int count);
> +static int esnf_num_recs_avail(struct snf_chan *dev);
> +static int esnf_max_ptn_entries(struct snf_chan *dev);
> +static int esnf_max_match_bytes(struct snf_chan *dev);
> +static int validate_pattern(
> +			struct ether_snf_chan *ch,
> +			const u8 *buf,
> +			int count);
> +static void read_fifo_data(struct ether_snf_chan *ch);
> +static u32 gray_decode(u32 gray);
> +
> +/* Initialises a sniffer channel */
> +int channel_init(
> +	struct ether_snf_chan *ch,
> +	struct platform_device *pdev,
> +	void *regs,
> +	int fifo_blk_words,
> +	int tx)
> +{
> +	struct resource *res;
> +	u32 *ptr;
> +	int i;
> +
> +	ch->regs = regs;
> +	ch->dev = &pdev->dev;
> +	ch->data_irq_bit = tx ? TX_DATA_IRQ_BIT : RX_DATA_IRQ_BIT;
> +	ch->full_irq_bit = tx ? TX_FULL_IRQ_BIT : RX_FULL_IRQ_BIT;
> +	ch->reg_enable = ch->regs +
> +			 (tx ? TX_SNIFFER_ENABLE : RX_SNIFFER_ENABLE);
> +	ch->reg_occ = ch->regs + (tx ? TX_FIFO_OCC : RX_FIFO_OCC);
> +	ch->reg_fifo = ch->regs + (tx ? TX_FIFO_DAT : RX_FIFO_DAT);
> +
> +	/* Retrieve and remap the address space for the command memory */
> +	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
> +					   tx ? "tx-ram" : "rx-ram");
> +	if (!res)
> +		return -ENOSYS;
> +	ch->cmd_ram = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(ch->cmd_ram))
> +		return PTR_ERR(ch->cmd_ram);
> +
> +	/* It is 2 bytes/command, hence divide by 2 */
> +	ch->max_cmds = resource_size(res) / 2;
> +
> +	/* Initialise the command pattern RAM */
> +	for (i = 0, ptr = ch->cmd_ram; i < resource_size(res); i += 4)
> +		iowrite32((PTN_CMD_DONTCARE << 24) | (PTN_CMD_DONTCARE << 8),
> +			  ptr++);
> +
> +	ch->fifo_blk_words = fifo_blk_words;
> +	ch->started = 0;
> +
> +	/* Register the channel methods */
> +	ch->chan.start = esnf_start;
> +	ch->chan.stop = esnf_stop;
> +	ch->chan.set_pattern = esnf_set_pattern;
> +	ch->chan.num_recs_avail = esnf_num_recs_avail;
> +	ch->chan.max_ptn_entries = esnf_max_ptn_entries;
> +	ch->chan.max_match_bytes = esnf_max_match_bytes;
> +
> +	strncpy(ch->name, tx ? "TX" : "RX", MAX_CHAN_NAME_SIZE - 1);
> +
> +	dev_dbg(ch->dev, "%s channel initialized\n", ch->name);
> +
> +	return 0;
> +}
> +
> +/* Registers the channel with the sniffer core module */
> +int channel_register(struct ether_snf_chan *ch, const char *name)
> +{
> +	int id;
> +
> +	id = snf_channel_add(&ch->chan, name);
> +	if (id < 0)
> +		return id;
> +
> +	ch->id = id;
> +	dev_info(ch->dev, "%s channel added\n", ch->name);
> +	return 0;
> +}
> +
> +/* Unregisters the channel */
> +int channel_unregister(struct ether_snf_chan *ch)
> +{
> +	int ret;
> +
> +	ch->chan.stop(&ch->chan);
> +	ret = snf_channel_remove(ch->id);
> +	if (!ret)
> +		dev_info(ch->dev, "%s channel removed\n", ch->name);
> +	return ret;
> +}
> +
> +/* Process match event data */
> +void channel_data_available(struct ether_snf_chan *ch)
> +{
> +	int ret;
> +
> +	dev_dbg(ch->dev, "%s match event\n", ch->name);
> +
> +	read_fifo_data(ch);
> +	ret = snf_channel_notify_match(&ch->chan, &ch->evt);
> +	if (ret < 0)
> +		dev_err(ch->dev, "%s: event notification failed\n", ch->name);
> +}
> +
> +/* Channel methods */
> +
> +/* Enables the channel */
> +static int esnf_start(struct snf_chan *dev)
> +{
> +	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
> +
> +	if (!ch->started) {
> +		/* Enable interrupts */
> +		iowrite32(ch->data_irq_bit | ch->full_irq_bit,
> +			  ch->regs + SET_INTERRUPT_ENABLE);
> +		/* Enable the packet matching logic */
> +		iowrite32(ENABLE_BIT, ch->reg_enable);
> +
> +		ch->started = 1;
> +		dev_info(ch->dev, "%s channel started\n", ch->name);
> +	} else {
> +		dev_dbg(ch->dev, "%s channel already running\n", ch->name);
> +	}
> +
> +	return 0;
> +}
> +
> +/* Disables the channel */
> +static int esnf_stop(struct snf_chan *dev)
> +{
> +	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
> +
> +	if (ch->started) {
> +		/* Disable interrupts */
> +		iowrite32(ch->data_irq_bit | ch->full_irq_bit,
> +			  ch->regs + CLEAR_INTERRUPT_ENABLE);
> +		/* Stop the sniffer channel */
> +		iowrite32(0, ch->reg_enable);
> +		/* Clear any pending interrupts */
> +		iowrite32(ch->data_irq_bit | ch->full_irq_bit,
> +			  ch->regs + INTERRUPT_STATUS);
> +
> +		ch->started = 0;
> +		dev_info(ch->dev, "%s channel stopped\n", ch->name);
> +	} else {
> +		dev_dbg(ch->dev, "%s channel already stopped\n", ch->name);
> +	}
> +
> +	return 0;
> +}
> +
> +/* Sets the command string (pattern) for the channel
> + * The bytes in the pattern buffer are in the following order:
> + */
> +static int esnf_set_pattern(struct snf_chan *dev, const u8 *pattern, int count)
> +{
> +	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
> +	int i, shift = 0;
> +	u32  val = 0, *ptr;
> +
> +	if (ch->started) {
> +		dev_err(ch->dev,
> +			"cannot apply cmd pattern. %s channel is active\n",
> +			ch->name);
> +		return -EBUSY;
> +	}
> +
> +	if (!validate_pattern(ch, pattern, count)) {
> +		dev_err(ch->dev,
> +			"invalid cmd pattern for %s channel\n",
> +			ch->name);
> +		return -EINVAL;
> +	}
> +
> +	for (ptr = ch->cmd_ram, i = 0, shift = 24; i < (2*count); i++) {
> +		val |= ((u32)pattern[i]) << shift;
> +		if (!shift) {
> +			iowrite32(val, ptr++);
> +			val = 0;
> +			shift = 24;
> +		} else {
> +			shift -= 8;
> +		}
> +	}
> +	if (shift)
> +		iowrite32(val, ptr);
> +
> +	return 0;
> +}
> +
> +/* Returns the number of pending match events that are
> + * available to retrieve
> + */
> +static int esnf_num_recs_avail(struct snf_chan *dev)
> +{
> +	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
> +
> +	return ioread32(ch->reg_occ);
> +}
> +
> +/* Returns max number of commands supported by the channel */
> +static int esnf_max_ptn_entries(struct snf_chan *dev)
> +{
> +	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
> +
> +	return ch->max_cmds;
> +}
> +
> +/* Returns max number of bytes that can be returned by a match */
> +static int esnf_max_match_bytes(struct snf_chan *dev)
> +{
> +	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
> +
> +	/* Subtract the word that may be used for the timestamp */
> +	return (ch->fifo_blk_words - 1) * 4;
> +}
> +
> +/* Checks if the supplied command string is compatible with the
> + * capabilities of the H/W
> + */
> +static int validate_pattern(struct ether_snf_chan *ch, const u8 *buf, int count)
> +{
> +	int i, complete, max_copy_bytes;
> +	int ts = 0;
> +	int copy_before = 0;
> +	int copy_after = 0;
> +
> +	if (count > ch->max_cmds)
> +		return 0;
> +
> +	/* Iterate through the commands in the string */
> +	for (i = 0, complete = 0; (i < count) && !complete; i++) {
> +		u8 cmd = buf[2*i];
> +
> +		switch (cmd) {
> +		case PTN_CMD_DONTCARE:
> +		case PTN_CMD_MATCH:
> +			break;
> +
> +		case PTN_CMD_MATCHSTAMP:
> +			/* The timestamp needs to be word-aligned in the FIFO
> +			 * therefore, the number of 'copy' commands before it
> +			 * needs to be a multiple of 4
> +			 */
> +			if (copy_before & 3)
> +				return 0;
> +			/* Signal that a timestamp will be present */
> +			ts = 1;
> +			break;
> +
> +		case PTN_CMD_COPY:
> +			/* Increment count of bytes that will be returned */
> +			if (ts)
> +				copy_after++;
> +			else
> +				copy_before++;
> +			break;
> +
> +		case PTN_CMD_COPYDONE:
> +			/* Increment count of bytes that will be returned
> +			 * This command terminates the string
> +			 */
> +			if (ts)
> +				copy_after++;
> +			else
> +				copy_before++;
> +			complete = 1;
> +			break;
> +
> +		default:
> +			return 0;
> +		}
> +	}
> +
> +	/* Check if the string was properly terminated
> +	 * and contained valid number of commands
> +	 */
> +	if (complete) {
> +		max_copy_bytes = ch->fifo_blk_words * 4;
> +		if (ts)
> +			max_copy_bytes -= 4;
> +		if ((copy_before + copy_after) > max_copy_bytes)
> +			return 0;
> +		ch->ts_present = ts;
> +		ch->nfb_before = copy_before;
> +		ch->nfb_after = copy_after;
> +		return 1;
> +	} else {
> +		return 0;
> +	}
> +}
> +
> +/* Read a block from the data FIFO */
> +static void read_fifo_data(struct ether_snf_chan *ch)
> +{
> +	int i;
> +	u32 val, *ptr;
> +	int ts = ch->ts_present;
> +	int dw = ch->fifo_blk_words;
> +	int bytes_before = ch->nfb_before;
> +	int bytes_after = ch->nfb_after;
> +
> +	ptr = (u32 *)ch->evt.data;
> +	for (i = 0; i < dw; i++) {
> +		val = ioread32(ch->reg_fifo);
> +		if (bytes_before > 0) {
> +			/* Bytes before the timestamp */
> +			*ptr++ = cpu_to_be32(val);
> +			bytes_before -= 4;
> +		} else if (ts) {
> +			/* Timestamp is Gray encoded */
> +			ch->evt.ts = (u64)gray_decode(val);
> +			ts = 0;
> +		} else if (bytes_after > 0) {
> +			/* Bytes after the timestamp */
> +			*ptr++ = cpu_to_be32(val);
> +			bytes_after -= 4;
> +		}
> +	}
> +
> +	ch->evt.ts_valid = ch->ts_present;
> +	ch->evt.len = ch->nfb_before + ch->nfb_after;
> +}
> +
> +/* Gray decoder */
> +static u32 gray_decode(u32 gray)
> +{
> +	gray ^= (gray >> 16);
> +	gray ^= (gray >> 8);
> +	gray ^= (gray >> 4);
> +	gray ^= (gray >> 2);
> +	gray ^= (gray >> 1);
> +	return gray;
> +}
> +
> diff --git a/drivers/net/pkt-sniffer/backends/ether/channel.h b/drivers/net/pkt-sniffer/backends/ether/channel.h
> new file mode 100644
> index 0000000..4f00b33
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/backends/ether/channel.h
> @@ -0,0 +1,76 @@
> +/*
> + * Ethernet Mii packet sniffer driver
> + *  - channel interface
> + *
> + * Copyright (C) 2015 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#ifndef _ETHER_SNIFFER_CHANNEL_H_
> +#define _ETHER_SNIFFER_CHANNEL_H_
> +
> +#include <linux/platform_device.h>
> +#include "../../core/snf_core.h"
> +
> +#define MAX_CHAN_NAME_SIZE 5
> +
> +struct ether_snf_chan {
> +	/* Sniffer core structure */
> +	struct snf_chan chan;
> +	/* Pointer to device struct */
> +	struct device *dev;
> +	/* Registers */
> +	u8 __iomem *regs;
> +	/* Command string memory */
> +	u32 __iomem *cmd_ram;
> +	/* Bit number for the data IRQ */
> +	int data_irq_bit;
> +	/* Bit number for the FIFO full IRQ */
> +	int full_irq_bit;
> +	/* Channel enable register */
> +	u8 __iomem *reg_enable;
> +	/* Data FIFO register */
> +	u8 __iomem *reg_fifo;
> +	/* FIFO occupancy register */
> +	u8 __iomem *reg_occ;
> +	/* Max number of commands in the string */
> +	int max_cmds;
> +	/* Max matching bytes that can fit in a FIFO block */
> +	int fifo_blk_words;
> +	/* Number of bytes in the FIFO before the timestamp */
> +	int nfb_before;
> +	/* Number of bytes in the FIFO after the timestamp */
> +	int nfb_after;
> +	/* Timestamp present flag */
> +	int ts_present;
> +	/* ID assigned to channel by the sniffer core */
> +	int id;
> +	/* Channel active flag */
> +	int started;
> +	/* Channel name (only used by debug messages) */
> +	char name[MAX_CHAN_NAME_SIZE];
> +	/* Struct to hold data from a packet match */
> +	struct snf_match_evt evt;
> +};
> +
> +int channel_init(
> +		struct ether_snf_chan *ch,
> +		struct platform_device *pdev,
> +		void *regs,
> +		int fifo_blk_words,
> +		int tx);
> +int channel_register(struct ether_snf_chan *ch, const char *name);
> +int channel_unregister(struct ether_snf_chan *ch);
> +void channel_data_available(struct ether_snf_chan *ch);
> +
> +#endif
> diff --git a/drivers/net/pkt-sniffer/backends/ether/hw.h b/drivers/net/pkt-sniffer/backends/ether/hw.h
> new file mode 100644
> index 0000000..edb1093
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/backends/ether/hw.h
> @@ -0,0 +1,46 @@
> +/*
> + * Ethernet Mii packet sniffer driver
> + *  - register map
> + *
> + * Copyright (C) 2015 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#ifndef _ETHER_SNIFFER_HW_H_
> +#define _ETHER_SNIFFER_HW_H_
> +
> +#include <linux/bitops.h>
> +
> +/* Registers */
> +#define INTERRUPT_ENABLE        0x00
> +#define SET_INTERRUPT_ENABLE    0x04
> +#define CLEAR_INTERRUPT_ENABLE  0x08
> +#define INTERRUPT_STATUS        0x0c
> +#define TX_FIFO_DAT             0x10
> +#define RX_FIFO_DAT             0x14
> +#define TX_FIFO_OCC             0x18
> +#define RX_FIFO_OCC             0x1c
> +#define TX_SNIFFER_ENABLE       0x20
> +#define RX_SNIFFER_ENABLE       0x24
> +
> +/* IRQ register bits */
> +#define TX_DATA_IRQ_BIT         BIT(0)
> +#define RX_DATA_IRQ_BIT         BIT(1)
> +#define TX_FULL_IRQ_BIT         BIT(2)
> +#define RX_FULL_IRQ_BIT         BIT(3)
> +
> +/* Enable register bits */
> +#define ENABLE_BIT              BIT(0)
> +
> +#endif
> +
> diff --git a/drivers/net/pkt-sniffer/backends/ether/platform.c b/drivers/net/pkt-sniffer/backends/ether/platform.c
> new file mode 100644
> index 0000000..78e7e1c
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/backends/ether/platform.c
> @@ -0,0 +1,231 @@
> +/*
> + * Ethernet Mii packet sniffer driver
> + *
> + * Copyright (C) 2015 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/interrupt.h>
> +#include <linux/of_device.h>
> +#include <linux/platform_device.h>
> +#include <linux/clk.h>
> +#include "../../core/snf_core.h"
> +#include "hw.h"
> +#include "channel.h"
> +
> +static const char esnf_driver_name[] = "eth-sniffer";
> +
> +/* Names for the TX and RX channel.
> + * User space will used these names to access the channels
> + * through the generic netlink interface
> + */
> +static const char tx_channel_name[] = "snf_ether_tx";
> +static const char rx_channel_name[] = "snf_ether_rx";
> +
> +struct ether_snf {
> +	u8 __iomem *regs;
> +	int irq;
> +	struct clk *sys_clk;
> +	struct ether_snf_chan txc;
> +	struct ether_snf_chan rxc;
> +};
> +
> +/* Interrupt thread function */
> +static irqreturn_t esnf_irq_thread(int irq, void *dev_id)
> +{
> +	struct platform_device *pdev = (struct platform_device *)dev_id;
> +	struct ether_snf *esnf = (struct ether_snf *)platform_get_drvdata(pdev);
> +	u32 irq_status;
> +
> +	if (unlikely(esnf->irq != irq))
> +		return IRQ_NONE;
> +
> +	irq_status = ioread32(esnf->regs + INTERRUPT_STATUS) &
> +				 ioread32(esnf->regs + INTERRUPT_ENABLE);
> +
> +	dev_dbg(&pdev->dev, "irq: 0x%08x\n", irq_status);
> +
> +	/* TX FIFO full */
> +	if (unlikely(irq_status & TX_FULL_IRQ_BIT))
> +		dev_notice(&pdev->dev, "TX FIFO full");
> +
> +	/* RX FIFO full */
> +	if (unlikely(irq_status & RX_FULL_IRQ_BIT))
> +		dev_notice(&pdev->dev, "RX FIFO full");
> +
> +	/* TX match data available */
> +	if (irq_status & TX_DATA_IRQ_BIT) {
> +		dev_dbg(&pdev->dev, "TX data");
> +		channel_data_available(&esnf->txc);
> +	}
> +
> +	/* RX match data available */
> +	if (irq_status & RX_DATA_IRQ_BIT) {
> +		dev_dbg(&pdev->dev, "RX data");
> +		channel_data_available(&esnf->rxc);
> +	}
> +
> +	/* Clear interrupts */
> +	iowrite32(irq_status, esnf->regs + INTERRUPT_STATUS);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +/* Called when the packet sniffer device is bound with the driver */
> +static int esnf_driver_probe(struct platform_device *pdev)
> +{
> +	struct ether_snf *esnf;
> +	struct resource *res;
> +	int ret, irq;
> +	u32 fifo_blk_words;
> +	void __iomem *regs;
> +	struct device_node *ofn = pdev->dev.of_node;
> +
> +	/* Allocate the device data structure */
> +	esnf = devm_kzalloc(&pdev->dev, sizeof(*esnf), GFP_KERNEL);
> +	if (!esnf)
> +		return -ENOMEM;
> +
> +	/* Retrieve and remap register memory space */
> +	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
> +	if (!res)
> +		return -ENODEV;
> +
> +	regs = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(regs))
> +		return PTR_ERR(regs);
> +
> +	esnf->regs = regs;
> +
> +	/* Read the FIFO block size from the DT */
> +	if (!ofn)
> +		return -ENODEV;
> +
> +	ret = of_property_read_u32(
> +				ofn,
> +				"fifo-block-words",
> +				&fifo_blk_words);
> +	if (ret < 0)
> +		return ret;
> +
> +	if (((fifo_blk_words - 1)*4) > MAX_MATCH_BYTES) {
> +		dev_err(&pdev->dev,
> +			"Invalid FIFO block size entry in device tree\n");
> +		return -EINVAL;
> +	}
> +
> +	esnf->sys_clk = devm_clk_get(&pdev->dev, "sys");
> +	if (IS_ERR(esnf->sys_clk)) {
> +		ret = PTR_ERR(esnf->sys_clk);
> +		return ret;
> +	}
> +	ret = clk_prepare_enable(esnf->sys_clk);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* Initialise the TX and RX channels */
> +	ret = channel_init(&esnf->txc, pdev, regs, fifo_blk_words, 1);
> +	if (ret < 0) {
> +		dev_err(&pdev->dev, "Failed to init TX channel (%d)\n", ret);
> +		goto fail1;
> +	}
> +	ret = channel_init(&esnf->rxc, pdev, regs, fifo_blk_words, 0);
> +	if (ret < 0) {
> +		dev_err(&pdev->dev, "Failed to init RX channel (%d)\n", ret);
> +		goto fail1;
> +	}
> +
> +	/* Register the channels with the sniffer core module */
> +	ret = channel_register(&esnf->txc, tx_channel_name);
> +	if (ret < 0) {
> +		dev_err(&pdev->dev, "Failed to register TX chan (%d)\n", ret);
> +		goto fail1;
> +	}
> +	ret = channel_register(&esnf->rxc, rx_channel_name);
> +	if (ret < 0) {
> +		dev_err(&pdev->dev, "Failed to register RX chan (%d)\n", ret);
> +		goto fail2;
> +	}
> +
> +	platform_set_drvdata(pdev, esnf);
> +
> +	/* Register the interrupt handler */
> +	irq = platform_get_irq(pdev, 0);
> +	if (irq < 0)
> +		goto fail3;
> +	esnf->irq = irq;
> +	ret = devm_request_threaded_irq(
> +				&pdev->dev,
> +				irq,
> +				NULL,
> +				esnf_irq_thread,
> +				IRQF_ONESHOT,
> +				esnf_driver_name,
> +				pdev);
> +	if (ret < 0)
> +		goto fail3;
> +
> +	return 0;
> +
> +fail3:
> +	channel_unregister(&esnf->rxc);
> +fail2:
> +	channel_unregister(&esnf->txc);
> +fail1:
> +	clk_disable_unprepare(esnf->sys_clk);
> +	return ret;
> +}
> +
> +/* Called when the packet sniffer device unregisters with the driver */
> +static int esnf_driver_remove(struct platform_device *pdev)
> +{
> +	struct ether_snf *esnf = (struct ether_snf *)platform_get_drvdata(pdev);
> +	int ret;
> +
> +	ret = channel_unregister(&esnf->txc);
> +	if (ret < 0) {
> +		dev_err(&pdev->dev, "Failed to unregister TX chan (%d)\n", ret);
> +		return ret;
> +	}
> +	ret = channel_unregister(&esnf->rxc);
> +	if (ret < 0) {
> +		dev_err(&pdev->dev, "Failed to unregister RX chan (%d)\n", ret);
> +		return ret;
> +	}
> +	clk_disable_unprepare(esnf->sys_clk);
> +	return 0;
> +}
> +
> +static const struct of_device_id esnf_of_match_table[] = {
> +	{ .compatible = "linn,eth-sniffer", .data = NULL },
> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, esnf_of_match_table);
> +
> +static struct platform_driver esnf_platform_driver = {
> +	.driver = {
> +		.name = esnf_driver_name,
> +		.of_match_table = esnf_of_match_table,
> +	},
> +	.probe = esnf_driver_probe,
> +	.remove = esnf_driver_remove,
> +};
> +
> +module_platform_driver(esnf_platform_driver);
> +
> +MODULE_DESCRIPTION("Linn Ethernet Packet Sniffer");
> +MODULE_AUTHOR("Linn Products Ltd");
> +MODULE_LICENSE("GPL v2");
> +
> diff --git a/drivers/net/pkt-sniffer/core/dev_table.c b/drivers/net/pkt-sniffer/core/dev_table.c
> new file mode 100644
> index 0000000..3a07838
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/core/dev_table.c
> @@ -0,0 +1,124 @@
> +/*
> + * Packet sniffer core driver: channel management
> + *
> + * Copyright (C) 2014 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#include <linux/module.h>
> +#include <linux/mutex.h>
> +#include "snf_core.h"
> +#include "nl.h"
> +
> +#define MAX_CHANNELS   256
> +
> +static DEFINE_MUTEX(tlock);
> +
> +static struct snf_chan *dev_tab[MAX_CHANNELS];
> +static unsigned int ref_count[MAX_CHANNELS];
> +
> +static inline int verify_args(int id)
> +{
> +	return (id < MAX_CHANNELS);
> +}
> +
> +/* Registers a sniffer channel and returns and id for it */
> +int snf_channel_add(struct snf_chan *dev, const char *name)
> +{
> +	int i;
> +	int ret = -EEXIST;
> +
> +	mutex_lock(&tlock);
> +
> +	for (i = 0; i < MAX_CHANNELS; i++) {
> +		if (!dev_tab[i]) {
> +			/* Initialise the netlink interface for the channel */
> +			ret = snf_netlink_init(i, dev, name);
> +			if (ret < 0)
> +				goto fail;
> +
> +			dev_tab[i] = dev;
> +			ref_count[i] = 0;
> +			mutex_unlock(&tlock);
> +			return i;
> +		}
> +	}
> +
> +fail:
> +	mutex_unlock(&tlock);
> +	return ret;
> +}
> +EXPORT_SYMBOL(snf_channel_add);
> +
> +/* Removes a sniffer channel */
> +int snf_channel_remove(int id)
> +{
> +	int ret = 0;
> +	struct snf_chan *dev;
> +
> +	if (!verify_args(id))
> +		return -EINVAL;
> +
> +	mutex_lock(&tlock);
> +
> +	dev = dev_tab[id];
> +
> +	if (!dev) {
> +		ret = -ENODEV;
> +		goto fail;
> +	}
> +
> +	if (ref_count[id] > 0) {
> +		ret = -EBUSY;
> +		goto fail;
> +	}
> +
> +	dev_tab[id] = NULL;
> +
> +	/* Release netlink API resources */
> +	snf_netlink_release(dev);
> +
> +fail:
> +	mutex_unlock(&tlock);
> +	return ret;
> +}
> +EXPORT_SYMBOL(snf_channel_remove);
> +
> +/* Returns a pointer to the specified sniffer channel
> + * and increments its reference counter
> + */
> +struct snf_chan *snf_channel_get(int id)
> +{
> +	struct snf_chan *dev;
> +
> +	if (!verify_args(id))
> +		return NULL;
> +
> +	mutex_lock(&tlock);
> +	dev = dev_tab[id];
> +	if (dev)
> +		ref_count[id]++;
> +	mutex_unlock(&tlock);
> +
> +	return dev;
> +}
> +
> +/* Decrements the reference counter for the channel */
> +void snf_channel_put(int id)
> +{
> +	mutex_lock(&tlock);
> +	if (ref_count[id] > 0)
> +		ref_count[id]--;
> +	mutex_unlock(&tlock);
> +}
> +
> diff --git a/drivers/net/pkt-sniffer/core/module.c b/drivers/net/pkt-sniffer/core/module.c
> new file mode 100644
> index 0000000..af6a1aa
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/core/module.c
> @@ -0,0 +1,37 @@
> +/*
> + * Packet sniffer core driver:
> + *  - backend channel management
> + *  - interface to userland via generic netlink
> + *
> + * Copyright (C) 2015 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#include <linux/module.h>
> +#include <linux/init.h>
> +
> +static int __init snf_core_init(void)
> +{
> +	return 0;
> +}
> +
> +static void __exit snf_core_cleanup(void)
> +{
> +}
> +
> +module_init(snf_core_init);
> +module_exit(snf_core_cleanup);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION("Core packet sniffer driver");
> +MODULE_AUTHOR("Linn Products Ltd");
> diff --git a/drivers/net/pkt-sniffer/core/nl.c b/drivers/net/pkt-sniffer/core/nl.c
> new file mode 100644
> index 0000000..6839147
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/core/nl.c
> @@ -0,0 +1,427 @@
> +/*
> + * Packet sniffer core driver: generic netlink interface
> + *
> + * Copyright (C) 2015 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#include <linux/version.h>
> +#include <net/netlink.h>
> +#include <net/genetlink.h>
> +#include <linux/slab.h>
> +#include <linux/module.h>
> +#include <linux/pkt_sniffer.h>
> +#include "snf_core.h"
> +#include "nl.h"
> +
> +/* Netlink API data for a sniffer channel */
> +struct snf_netlink {
> +	/* genl family */
> +	struct genl_family           fml;
> +	/* genl operations */
> +	struct genl_ops             *ops;
> +	/* genl mcast group, where sniffer match
> +	 * events will be sent
> +	 */
> +	struct genl_multicast_group  grp;
> +};
> +
> +/* Attribute policies */
> +static struct nla_policy snf_policy[SNF_ATTR_MAX + 1] = {
> +	[SNF_ATTR_PATTERN] = { .type = NLA_NESTED },
> +};
> +
> +static struct nla_policy snf_ptn_policy[SNF_ATTR_PTN_MAX + 1] = {
> +	[SNF_ATTR_PTN_ENTRY] = { .type = NLA_U16 },
> +};
> +
> +/* Generic Netlink family template definition */
> +static int pre_doit_func(const struct genl_ops *ops,
> +			 struct sk_buff *skb,
> +			 struct genl_info *info);
> +
> +static void post_doit_func(const struct genl_ops *ops,
> +			   struct sk_buff *skb,
> +			   struct genl_info *info);
> +
> +static struct genl_family snf_family_tmpl = {
> +	.id = GENL_ID_GENERATE,
> +	.hdrsize = 0,
> +	.version = SNF_GNL_VERSION,
> +	.maxattr = SNF_ATTR_MAX,
> +	.pre_doit = pre_doit_func,
> +	.post_doit = post_doit_func
> +};
> +
> +static int send_reply_uint32(
> +			struct genl_info *info,
> +			int cmd,
> +			int attr,
> +			u32 val);
> +
> +/* Generic Netlink operations template definition */
> +
> +static int do_it_start(struct sk_buff *skb, struct genl_info *info);
> +static int do_it_stop(struct sk_buff *skb, struct genl_info *info);
> +static int do_it_set_pattern(struct sk_buff *skb, struct genl_info *info);
> +static int do_it_num_rec_avail(struct sk_buff *skb, struct genl_info *info);
> +static int do_it_ptn_max_cmds(struct sk_buff *skb, struct genl_info *info);
> +static int do_it_max_match_bytes(struct sk_buff *skb, struct genl_info *info);
> +
> +#define SNF_GENL_OP(_cmd, _func)	 \
> +	{				 \
> +		.cmd	= _cmd,          \
> +		.policy = snf_policy,    \
> +		.doit   = _func,         \
> +		.dumpit = NULL,          \
> +		.flags  = 0,             \
> +		.internal_flags = 0      \
> +	}
> +
> +#define SNF_CHAN_OPS							   \
> +	{								   \
> +		SNF_GENL_OP(SNF_CMD_START,         do_it_start),	   \
> +		SNF_GENL_OP(SNF_CMD_STOP,          do_it_stop),		   \
> +		SNF_GENL_OP(SNF_CMD_SETPATTERN,    do_it_set_pattern),     \
> +		SNF_GENL_OP(SNF_CMD_NUMRECAVAIL,   do_it_num_rec_avail),   \
> +		SNF_GENL_OP(SNF_CMD_PTNMAXCMDS,    do_it_ptn_max_cmds),    \
> +		SNF_GENL_OP(SNF_CMD_MAXMATCHBYTES, do_it_max_match_bytes)  \
> +	}
> +
> +static struct genl_ops snf_ops_tmpl[] = SNF_CHAN_OPS;
> +
> +#define NUM_GENL_OPS ARRAY_SIZE(snf_ops_tmpl)
> +
> +/* Multicast a netlink event containing data from a sniffer match event.
> + * Data are included in the netlink message as a nested attribute
> + * containing the timestamp (optional) and matching packet bytes
> +*/
> +int snf_channel_notify_match(struct snf_chan *dev, struct snf_match_evt *mt)
> +{
> +	int i, ret = 0;
> +	struct sk_buff *msg = NULL;
> +	void *msg_hdr, *nest_hdr;
> +	struct snf_netlink *nl = (struct snf_netlink *)dev->cstate;
> +
> +	if (!nl) {
> +		ret = -EINVAL;
> +		goto fail;
> +	}
> +
> +	msg = genlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
> +	if (!msg) {
> +		ret = -ENOMEM;
> +		goto fail;
> +	}
> +
> +	msg_hdr = genlmsg_put(msg,
> +			      0,
> +			      0,
> +			      &nl->fml,
> +			      0,
> +			      SNF_CMD_MATCHEVENT);
> +	if (!msg_hdr) {
> +		ret = -EMSGSIZE;
> +		goto fail;
> +	}
> +
> +	/* Add the nested attribute with the data */
> +	if ((mt->ts_valid) || (mt->len > 0)) {
> +		nest_hdr = nla_nest_start(msg, SNF_ATTR_MATCHEVENT);
> +		if (!nest_hdr) {
> +			ret = -EMSGSIZE;
> +			goto fail;
> +		}
> +		if (mt->ts_valid) {
> +			ret = nla_put_u64(msg, SNF_ATTR_MATCH_TS, mt->ts);
> +			if (ret < 0)
> +				goto fail;
> +		}
> +		for (i = 0; i < mt->len; i++) {
> +			ret = nla_put_u8(msg,
> +					 SNF_ATTR_MATCH_PKTBYTE,
> +					 mt->data[i]);
> +			if (ret < 0)
> +				goto fail;
> +		}
> +		nla_nest_end(msg, nest_hdr);
> +	}
> +
> +	ret = genlmsg_end(msg, msg_hdr);
> +	if (ret < 0)
> +		goto fail;
> +	ret = genlmsg_multicast(&nl->fml, msg, 0, 0, GFP_ATOMIC);
> +
> +	/* The ESRCH code is returned when there is no socket listening on the
> +	 * multicast group, so we do not really treat is as an error
> +	 */
> +	if (ret == -ESRCH)
> +		ret = 0;
> +	return ret;
> +
> +fail:
> +	if (msg)
> +		nlmsg_free(msg);
> +	return ret;
> +}
> +EXPORT_SYMBOL(snf_channel_notify_match);
> +
> +/* Initialise the generic netlink API for a sniffer channel
> + * Registers family, ops and multicast group for events
> + */
> +int snf_netlink_init(int id, struct snf_chan *dev, const char *name)
> +{
> +	int i, ret;
> +	struct snf_netlink *nl = NULL;
> +
> +	nl = kmalloc(sizeof(*nl), GFP_KERNEL);
> +	if (!nl) {
> +		ret = -ENOMEM;
> +		goto fail1;
> +	}
> +
> +	nl->fml = snf_family_tmpl;
> +
> +	/* Set the family name */
> +	strncpy(nl->fml.name, name, GENL_NAMSIZ-1);
> +
> +	/* Allocate ops array and copy template data */
> +	nl->ops = kmalloc(sizeof(snf_ops_tmpl), GFP_KERNEL);
> +	if (!nl->ops) {
> +		ret = -ENOMEM;
> +		goto fail2;
> +	}
> +	memcpy(nl->ops, snf_ops_tmpl, sizeof(snf_ops_tmpl));
> +
> +	/* In the internal_flags field we store the id
> +	 * of the device the ops belong to
> +	 */
> +	for (i = 0; i < NUM_GENL_OPS; i++)
> +		nl->ops[i].internal_flags = id;
> +
> +	snprintf(nl->grp.name, GENL_NAMSIZ-1, SNF_EVENT_GRP);
> +
> +	ret = _genl_register_family_with_ops_grps(
> +						&nl->fml,
> +						nl->ops,
> +						NUM_GENL_OPS,
> +						&nl->grp,
> +						1);
> +	if (ret < 0) {
> +		pr_err("%s: failed to register family %s (%d)\n",
> +		       KBUILD_MODNAME, name, ret);
> +		goto fail3;
> +	}
> +
> +	pr_info("%s: registered genl family for channel %d: %s\n",
> +		KBUILD_MODNAME, id, name);
> +	dev->cstate = nl;
> +
> +	return 0;
> +
> +fail3:
> +	kfree(nl->ops);
> +fail2:
> +	kfree(nl);
> +fail1:
> +	return ret;
> +}
> +
> +/* Shuts down the netlink API for a sniffer channel
> + * and frees resources
> + */
> +void snf_netlink_release(struct snf_chan *dev)
> +{
> +	struct snf_netlink *nl = (struct snf_netlink *)dev->cstate;
> +	/* Unregister family and free ops
> +	 * NOTE: this will also unregister the ops and the mcast group
> +	 */
> +	genl_unregister_family(&nl->fml);
> +	pr_info("%s: unregistered genl family: %s\n",
> +		KBUILD_MODNAME, nl->fml.name);
> +
> +	kfree(nl->ops);
> +	kfree(nl);
> +	dev->cstate = NULL;
> +}
> +
> +/* pre_doit function that retrieves a pointer to the sniffer channel device
> + * from the instance and channel number stored in the ops internal_flag field
> + */
> +static int pre_doit_func(const struct genl_ops *ops,
> +			 struct sk_buff *skb,
> +			 struct genl_info *info)
> +{
> +	info->user_ptr[0] = snf_channel_get(ops->internal_flags);
> +	return info->user_ptr[0] ? 0 : -ENODEV;
> +}
> +
> +/* post_doit function that releases a sniffer channel device */
> +static void post_doit_func(const struct genl_ops *ops,
> +			   struct sk_buff *skb,
> +			   struct genl_info *info)
> +{
> +	snf_channel_put(ops->internal_flags);
> +}
> +
> +/* doit command handlers */
> +
> +/* Start the sniffer channel */
> +static int do_it_start(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct snf_chan *dev = (struct snf_chan *)info->user_ptr[0];
> +
> +	return dev->start(dev);
> +}
> +
> +/* Stop the sniffer channel */
> +static int do_it_stop(struct sk_buff *skb, struct genl_info *info)
> +{
> +	int ret;
> +	struct snf_match_evt mt;
> +	struct snf_chan *dev = (struct snf_chan *)info->user_ptr[0];
> +
> +	ret = dev->stop(dev);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* Multicast an empty match event to notify any user-space
> +	 * listeners that the sniffer is stopping
> +	 */
> +	memset(&mt, 0, sizeof(mt));
> +	return snf_channel_notify_match(dev, &mt);
> +}
> +
> +/* Set the command pattern. The string is received in a nested
> + * attribute containing a sequence of 16-bit valued.
> + * Each value consists of a command (8 bits) and data (8 bits)
> +*/
> +static int do_it_set_pattern(struct sk_buff *skb, struct genl_info *info)
> +{
> +	int ret = 0;
> +	int rem, count;
> +	struct nlattr *nla;
> +	u16 entry;
> +	u8 *buf = NULL;
> +	struct snf_chan *dev = (struct snf_chan *)info->user_ptr[0];
> +	int max_entries = dev->max_ptn_entries(dev);
> +
> +	if (!info->attrs[SNF_ATTR_PATTERN]) {
> +		ret = -EINVAL;
> +		goto fail;
> +	}
> +
> +	ret = nla_validate_nested(info->attrs[SNF_ATTR_PATTERN],
> +				  SNF_ATTR_PTN_ENTRY, snf_ptn_policy);
> +	if (ret < 0)
> +		goto fail;
> +
> +	buf = kmalloc(max_entries*2, GFP_KERNEL);
> +	if (!buf) {
> +		ret = -ENOMEM;
> +		goto fail;
> +	}
> +
> +	/* Iterate over the contents of the nested attribute
> +	 * and extract into the buffer
> +	 */
> +	count = 0;
> +	nla_for_each_nested(nla, info->attrs[SNF_ATTR_PATTERN], rem) {
> +		if (count >= max_entries) {
> +			ret = -EINVAL;
> +			goto fail;
> +		}
> +		entry = nla_get_u16(nla);
> +		buf[2*count] = PTNENTRY_CMD(entry);
> +		buf[2*count + 1] = PTNENTRY_DATA(entry);
> +		count++;
> +	}
> +
> +	ret = dev->set_pattern(dev, buf, count);
> +
> +fail:
> +	kfree(buf);
> +	return ret;
> +}
> +
> +/* Number of pending match events */
> +static int do_it_num_rec_avail(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct snf_chan *dev = (struct snf_chan *)info->user_ptr[0];
> +
> +	return send_reply_uint32(
> +			info,
> +			SNF_CMD_NUMRECAVAIL,
> +			SNF_ATTR_NUMRECAVAIL,
> +			dev->num_recs_avail(dev));
> +}
> +
> +/* Max number of commands that are supported in the command pattern */
> +static int do_it_ptn_max_cmds(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct snf_chan *dev = (struct snf_chan *)info->user_ptr[0];
> +
> +	return send_reply_uint32(
> +			info,
> +			SNF_CMD_PTNMAXCMDS,
> +			SNF_ATTR_PTNMAXCMDS,
> +			dev->max_ptn_entries(dev));
> +}
> +
> +/* Max bytes that can be returned by a packet match event */
> +static int do_it_max_match_bytes(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct snf_chan *dev = (struct snf_chan *)info->user_ptr[0];
> +
> +	return send_reply_uint32(
> +			info,
> +			SNF_CMD_MAXMATCHBYTES,
> +			SNF_ATTR_MAXMATCHBYTES,
> +			dev->max_match_bytes(dev));
> +}
> +
> +/* Helper function for sending a reply containing a single u32 attribute */
> +static int send_reply_uint32(struct genl_info *info, int cmd, int attr, u32 val)
> +{
> +	void *hdr;
> +	int ret = 0;
> +	struct sk_buff *msg;
> +	struct snf_chan *dev = (struct snf_chan *)info->user_ptr[0];
> +	struct snf_netlink *nl = (struct snf_netlink *)dev->cstate;
> +
> +	msg = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
> +	if (!msg) {
> +		ret = -ENOMEM;
> +		goto fail;
> +	}
> +
> +	hdr = genlmsg_put_reply(msg, info, &nl->fml, 0, cmd);
> +	if (!hdr) {
> +		ret = -EMSGSIZE;
> +		goto fail;
> +	}
> +	ret = nla_put_u32(msg, attr, val);
> +	if (ret < 0)
> +		goto fail;
> +	ret = genlmsg_end(msg, hdr);
> +	if (ret < 0)
> +		goto fail;
> +
> +	return genlmsg_reply(msg, info);
> +
> +fail:
> +	if (msg)
> +		nlmsg_free(msg);
> +	return ret;
> +}
> +
> diff --git a/drivers/net/pkt-sniffer/core/nl.h b/drivers/net/pkt-sniffer/core/nl.h
> new file mode 100644
> index 0000000..f7bf579
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/core/nl.h
> @@ -0,0 +1,34 @@
> +/*
> + * Packet sniffer core driver: generic netlink interface
> + *
> + * Copyright (C) 2015 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#ifndef __SNF_NL_H
> +#define __SNF_NL_H
> +
> +#include <net/genetlink.h>
> +#include "snf_core.h"
> +
> +/* Initialise netlink interface for a sniffer channel,
> + * register netlink families etc.
> + */
> +int snf_netlink_init(int id, struct snf_chan *dev, const char *name);
> +
> +/* Shutdown netlink interface, unregister
> + * families etc.
> + */
> +void snf_netlink_release(struct snf_chan *dev);
> +
> +#endif
> diff --git a/drivers/net/pkt-sniffer/core/snf_core.h b/drivers/net/pkt-sniffer/core/snf_core.h
> new file mode 100644
> index 0000000..062de70
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/core/snf_core.h
> @@ -0,0 +1,64 @@
> +/*
> + * Packet sniffer core driver
> + * - this header provides the interface to specific backend packet
> + *   sniffer implementations
> + *
> + * Copyright (C) 2015 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#ifndef __SNF_CORE_H
> +#define __SNF_CORE_H
> +
> +#include <linux/types.h>
> +
> +/* This is a global maximum. Each backend will have its own limit */
> +#define MAX_MATCH_BYTES 512
> +
> +/* Sniffer channel data structure */
> +struct snf_chan {
> +	int  (*start)(struct snf_chan *dev);
> +	int  (*stop)(struct snf_chan *dev);
> +	int  (*set_pattern)(struct snf_chan *dev, const u8 *pattern, int count);
> +	int  (*num_recs_avail)(struct snf_chan *dev);
> +	int  (*max_ptn_entries)(struct snf_chan *dev);
> +	int  (*max_match_bytes)(struct snf_chan *dev);
> +
> +	void *cstate;
> +};
> +
> +/* Data from a sniffer match event */
> +struct snf_match_evt {
> +	int ts_valid;     /* flag indicating if timestamp is present */
> +	u64 ts;           /* timestamp value */
> +	u8 data[MAX_MATCH_BYTES]; /* packet data bytes matched by sniffer */
> +	int len;          /* number of valid bytes in the 'data' buffer */
> +};
> +
> +/* Adds a sniffer channel to the registry */
> +int snf_channel_add(struct snf_chan *dev, const char *name);
> +
> +/* Removes the channel with the specified id from the registry */
> +int snf_channel_remove(int id);
> +
> +/* Returns handle to a channel and increments reference count */
> +struct snf_chan *snf_channel_get(int id);
> +
> +/* Decrements reference count for the specified channel */
> +void snf_channel_put(int id);
> +
> +/* Multicast a notification to user space for a sniffer match event */
> +int snf_channel_notify_match(struct snf_chan *dev, struct snf_match_evt *mt);
> +
> +#endif
> +
> diff --git a/include/linux/pkt_sniffer.h b/include/linux/pkt_sniffer.h
> new file mode 100644
> index 0000000..3e73d14
> --- /dev/null
> +++ b/include/linux/pkt_sniffer.h
> @@ -0,0 +1,89 @@
> +/*
> + * Linn packet sniffer driver interface
> + *
> + * Copyright (C) 2015 Linn Products Ltd
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * Written by:
> + * Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> + */
> +#ifndef __PKT_SNIFFER_H
> +#define __PKT_SNIFFER_H
> +
> +/* Commands for the pattern string */
> +#define PTN_CMD_DONTCARE    0
> +#define PTN_CMD_MATCH       1
> +#define PTN_CMD_COPY        2
> +#define PTN_CMD_MATCHSTAMP  3
> +#define PTN_CMD_COPYDONE    4
> +
> +/* Creates an entry for the pattern string.
> + * An entry consists of a command byte and a data byte
> +*/
> +#define MAKE_PTN_ENTRY(cmd, data) (((((int)cmd) & 0xff) << 8) | (data & 0xff))
> +/* Gets the cmd and data portion of a pattern string entry */
> +#define PTNENTRY_CMD(val)        (((val) >> 8) & 0xff)
> +#define PTNENTRY_DATA(val)       ((val) & 0xff)
> +
> +/* Generic Netlink commands */
> +enum {
> +	SNF_CMD_UNSPEC,
> +	SNF_CMD_START,          /* start the sniffer */
> +	SNF_CMD_STOP,           /* stop the sniffer */
> +	SNF_CMD_SETPATTERN,     /* set the command pattern */
> +	SNF_CMD_NUMRECAVAIL,    /* number of pending match events */
> +	SNF_CMD_MATCHEVENT,     /* match event notification */
> +	SNF_CMD_PTNMAXCMDS,     /* max number of commands supported */
> +	SNF_CMD_MAXMATCHBYTES,  /* max number of bytes in match event */
> +	__SNF_CMD_MAX
> +};
> +#define SNF_CMD_MAX (__SNF_CMD_MAX - 1)
> +
> +/* Generic Netlink attributes */
> +enum {
> +	SNF_ATTR_UNSPEC,
> +	SNF_ATTR_PTNMAXCMDS,    /* max number of commands supported */
> +	SNF_ATTR_PATTERN,       /* nested attribute containing commands */
> +	SNF_ATTR_NUMRECAVAIL,   /* number of pending match events */
> +	SNF_ATTR_MATCHEVENT,    /* nested attribute for a match event */
> +	SNF_ATTR_MAXMATCHBYTES, /* max bytes in a match event */
> +	__SNF_ATTR_MAX
> +};
> +#define SNF_ATTR_MAX (__SNF_ATTR_MAX - 1)
> +
> +/* Attributes that are included in the nested attribute
> + * for the command string
> + */
> +enum {
> +	SNF_ATTR_PTN_UNSPEC,
> +	SNF_ATTR_PTN_ENTRY,    /* command entry containing a command id */
> +	__SNF_ATTR_PTN_MAX     /* and data byte */
> +};
> +#define SNF_ATTR_PTN_MAX (__SNF_ATTR_PTN_MAX - 1)
> +
> +/* Attributes included in the nested attribute
> + * of a match event notification
> + */
> +enum {
> +	SNF_ATTR_MATCH_UNSPEC,
> +	SNF_ATTR_MATCH_TS,      /* timestamp (returned with a match event) */
> +	SNF_ATTR_MATCH_PKTBYTE, /* packet data (returned with a match event) */
> +	__SNF_ATTR_MATCH_MAX
> +};
> +#define SNF_ATTR_MATCH_MAX (__SNF_ATTR_MATCH_MAX - 1)
> +
> +/* Family version */
> +#define SNF_GNL_VERSION 1
> +
> +/* Multicast group name */
> +#define SNF_EVENT_GRP    "snf_evt_grp"
> +
> +#endif
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
