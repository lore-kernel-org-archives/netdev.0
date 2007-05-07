From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] Add 93cx6 eeprom library
Date: Mon, 7 May 2007 09:53:12 +0200
Message-ID: <200705070953.13153.IvDoorn@gmail.com>
References: <200705070346.04982.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
To: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705070346.04982.flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 07 May 2007 09:46, Michael Wu wrote:
> From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> This patch adds a library for reading from and writing to 93cx6 eeproms.
> 
> Signed-off-by: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>

Signed-off-by: Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> ---
> 
>  drivers/misc/Kconfig         |    6 +
>  drivers/misc/Makefile        |    1 
>  drivers/misc/eeprom_93cx6.c  |  347 ++++++++++++++++++++++++++++++++++++++++++
>  include/linux/eeprom_93cx6.h |   77 +++++++++
>  4 files changed, 431 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
> index a3c525b..607a180 100644
> --- a/drivers/misc/Kconfig
> +++ b/drivers/misc/Kconfig
> @@ -178,4 +178,10 @@ config THINKPAD_ACPI_BAY
>  
>  	  If you are not sure, say Y here.
>  
> +config EEPROM_93CX6
> +	tristate "EEPROM 93CX6 support"
> +	---help---
> +	  This is a driver for the EEPROM chipsets 93c46 and 93c66.
> +	  The driver supports both read as well as write commands.
> +
>  endmenu
> diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
> index e325164..42b34a9 100644
> --- a/drivers/misc/Makefile
> +++ b/drivers/misc/Makefile
> @@ -13,3 +13,4 @@ obj-$(CONFIG_TIFM_7XX1)       	+= tifm_7
>  obj-$(CONFIG_SGI_IOC4)		+= ioc4.o
>  obj-$(CONFIG_SONY_LAPTOP)	+= sony-laptop.o
>  obj-$(CONFIG_THINKPAD_ACPI)	+= thinkpad_acpi.o
> +obj-$(CONFIG_EEPROM_93CX6)	+= eeprom_93cx6.o
> diff --git a/drivers/misc/eeprom_93cx6.c b/drivers/misc/eeprom_93cx6.c
> new file mode 100644
> index 0000000..a948ddc
> --- /dev/null
> +++ b/drivers/misc/eeprom_93cx6.c
> @@ -0,0 +1,347 @@
> +/*
> +	Copyright (C) 2004 - 2006 rt2x00 SourceForge Project
> +	<http://rt2x00.serialmonkey.com>
> +
> +	This program is free software; you can redistribute it and/or modify
> +	it under the terms of the GNU General Public License as published by
> +	the Free Software Foundation; either version 2 of the License, or
> +	(at your option) any later version.
> +
> +	This program is distributed in the hope that it will be useful,
> +	but WITHOUT ANY WARRANTY; without even the implied warranty of
> +	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> +	GNU General Public License for more details.
> +
> +	You should have received a copy of the GNU General Public License
> +	along with this program; if not, write to the
> +	Free Software Foundation, Inc.,
> +	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
> + */
> +
> +/*
> +	Module: eeprom_93cx6
> +	Abstract: EEPROM reader routines for 93cx6 chipsets.
> +	Supported chipsets: 93c46 & 93c66.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/version.h>
> +#include <linux/delay.h>
> +#include <linux/eeprom_93cx6.h>
> +
> +MODULE_AUTHOR("http://rt2x00.serialmonkey.com");
> +MODULE_VERSION("1.0");
> +MODULE_DESCRIPTION("EEPROM 93cx6 chip driver");
> +MODULE_LICENSE("GPL");
> +
> +static inline void eeprom_93cx6_pulse_high(struct eeprom_93cx6 *eeprom)
> +{
> +	eeprom->reg_data_clock = 1;
> +	eeprom->register_write(eeprom);
> +	udelay(1);
> +}
> +
> +static inline void eeprom_93cx6_pulse_low(struct eeprom_93cx6 *eeprom)
> +{
> +	eeprom->reg_data_clock = 0;
> +	eeprom->register_write(eeprom);
> +	udelay(1);
> +}
> +
> +static void eeprom_93cx6_startup(struct eeprom_93cx6 *eeprom)
> +{
> +	/*
> +	 * Clear all flags, and enable chip select.
> +	 */
> +	eeprom->register_read(eeprom);
> +	eeprom->reg_data_in = 0;
> +	eeprom->reg_data_out = 0;
> +	eeprom->reg_data_clock = 0;
> +	eeprom->reg_chip_select = 1;
> +	eeprom->register_write(eeprom);
> +
> +	/*
> +	 * kick a pulse.
> +	 */
> +	eeprom_93cx6_pulse_high(eeprom);
> +	eeprom_93cx6_pulse_low(eeprom);
> +}
> +
> +static void eeprom_93cx6_cleanup(struct eeprom_93cx6 *eeprom)
> +{
> +	/*
> +	 * Clear chip_select and data_in flags.
> +	 */
> +	eeprom->register_read(eeprom);
> +	eeprom->reg_data_in = 0;
> +	eeprom->reg_chip_select = 0;
> +	eeprom->register_write(eeprom);
> +
> +	/*
> +	 * kick a pulse.
> +	 */
> +	eeprom_93cx6_pulse_high(eeprom);
> +	eeprom_93cx6_pulse_low(eeprom);
> +}
> +
> +static void eeprom_93cx6_write_bits(struct eeprom_93cx6 *eeprom,
> +	const u16 data, const u16 count)
> +{
> +	unsigned int i;
> +
> +	eeprom->register_read(eeprom);
> +
> +	/*
> +	 * Clear data flags.
> +	 */
> +	eeprom->reg_data_in = 0;
> +	eeprom->reg_data_out = 0;
> +
> +	/*
> +	 * Start writing all bits.
> +	 */
> +	for (i = count; i > 0; i--) {
> +		/*
> +		 * Check if this bit needs to be set.
> +		 */
> +		eeprom->reg_data_in = !!(data & (1 << (i - 1)));
> +
> +		/*
> +		 * Write the bit to the eeprom register.
> +		 */
> +		eeprom->register_write(eeprom);
> +
> +		/*
> +		 * Kick a pulse.
> +		 */
> +		eeprom_93cx6_pulse_high(eeprom);
> +		eeprom_93cx6_pulse_low(eeprom);
> +	}
> +
> +	eeprom->reg_data_in = 0;
> +	eeprom->register_write(eeprom);
> +}
> +
> +static void eeprom_93cx6_read_bits(struct eeprom_93cx6 *eeprom,
> +	u16 *data, const u16 count)
> +{
> +	unsigned int i;
> +	u16 buf = 0;
> +
> +	eeprom->register_read(eeprom);
> +
> +	/*
> +	 * Clear data flags.
> +	 */
> +	eeprom->reg_data_in = 0;
> +	eeprom->reg_data_out = 0;
> +
> +	/*
> +	 * Start reading all bits.
> +	 */
> +	for (i = count; i > 0; i--) {
> +		eeprom_93cx6_pulse_high(eeprom);
> +
> +		eeprom->register_read(eeprom);
> +
> +		/*
> +		 * Clear data_in flag.
> +		 */
> +		eeprom->reg_data_in = 0;
> +
> +		/*
> +		 * Read if the bit has been set.
> +		 */
> +		if (eeprom->reg_data_out)
> +			buf |= (1 << (i - 1));
> +
> +		eeprom_93cx6_pulse_low(eeprom);
> +	}
> +
> +	*data = buf;
> +}
> +
> +static void eeprom_93cx6_ewen(struct eeprom_93cx6 *eeprom)
> +{
> +	/*
> +	 * Initialize the eeprom register
> +	 */
> +	eeprom_93cx6_startup(eeprom);
> +
> +	/*
> +	 * Select the read opcode and the word to be read.
> +	 */
> +	eeprom_93cx6_write_bits(eeprom, PCI_EEPROM_EWEN_OPCODE, 5);
> +	eeprom_93cx6_write_bits(eeprom, 0, 6);
> +
> +	/*
> +	 * Cleanup eeprom register.
> +	 */
> +	eeprom_93cx6_cleanup(eeprom);
> +}
> +
> +static void eeprom_93cx6_ewds(struct eeprom_93cx6 *eeprom)
> +{
> +	/*
> +	 * Initialize the eeprom register
> +	 */
> +	eeprom_93cx6_startup(eeprom);
> +
> +	/*
> +	 * Select the read opcode and the word to be read.
> +	 */
> +	eeprom_93cx6_write_bits(eeprom, PCI_EEPROM_EWDS_OPCODE, 5);
> +	eeprom_93cx6_write_bits(eeprom, 0, 6);
> +
> +	/*
> +	 * Cleanup eeprom register.
> +	 */
> +	eeprom_93cx6_cleanup(eeprom);
> +}
> +
> +/**
> + * eeprom_93cx6_read - Read multiple words from eeprom
> + * @eeprom: Pointer to eeprom structure
> + * @word: Word index from where we should start reading
> + * @data: target pointer where the information will have to be stored
> + *
> + * This function will read the eeprom data as host-endian word
> + * into the given data pointer.
> + */
> +void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom, const u8 word,
> +	u16 *data)
> +{
> +	u16 command;
> +
> +	/*
> +	 * Initialize the eeprom register
> +	 */
> +	eeprom_93cx6_startup(eeprom);
> +
> +	/*
> +	 * Select the read opcode and the word to be read.
> +	 */
> +	command = (PCI_EEPROM_READ_OPCODE << eeprom->width) | word;
> +	eeprom_93cx6_write_bits(eeprom, command,
> +		PCI_EEPROM_WIDTH_OPCODE + eeprom->width);
> +
> +	/*
> +	 * Read the requested 16 bits.
> +	 */
> +	eeprom_93cx6_read_bits(eeprom, data, 16);
> +
> +	/*
> +	 * Cleanup eeprom register.
> +	 */
> +	eeprom_93cx6_cleanup(eeprom);
> +}
> +EXPORT_SYMBOL_GPL(eeprom_93cx6_read);
> +
> +/**
> + * eeprom_93cx6_multiread - Read multiple words from eeprom
> + * @eeprom: Pointer to eeprom structure
> + * @word: Word index from where we should start reading
> + * @data: target pointer where the information will have to be stored
> + * @words: Number of words that should be read.
> + *
> + * This function will read all requested words from the eeprom,
> + * this is done by calling eeprom_93cx6_read() multiple times.
> + * But with the additional change that while the eeprom_93cx6_read
> + * will return host ordered bytes, this method will return little
> + * endian words.
> + */
> +void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom, const u8 word,
> +	__le16 *data, const u16 words)
> +{
> +	unsigned int i;
> +	u16 tmp;
> +
> +	for (i = 0; i < words; i++) {
> +		tmp = 0;
> +		eeprom_93cx6_read(eeprom, word + i, &tmp);
> +		data[i] = cpu_to_le16(tmp);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(eeprom_93cx6_multiread);
> +
> +/**
> + * eeprom_93cx6_write - Write multiple words to the eeprom
> + * @eeprom: Pointer to eeprom structure
> + * @word: Word index from where we should start writing
> + * @data: Data that will be written
> + *
> + * This function will write the eeprom data as host-endian word
> + * from the given data pointer.
> + */
> +void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom, const u8 word,
> +	u16 data)
> +{
> +	u16 command;
> +
> +	/*
> +	 * select the ewen opcode.
> +	 */
> +	eeprom_93cx6_ewen(eeprom);
> +
> +	/*
> +	 * Initialize the eeprom register
> +	 */
> +	eeprom_93cx6_startup(eeprom);
> +
> +	/*
> +	 * Select the write opcode and the word to be read.
> +	 */
> +	command = (PCI_EEPROM_WRITE_OPCODE << eeprom->width) | word;
> +	eeprom_93cx6_write_bits(eeprom, command,
> +		PCI_EEPROM_WIDTH_OPCODE + eeprom->width);
> +
> +	/*
> +	 * Write the requested 16 bits.
> +	 */
> +	eeprom_93cx6_write_bits(eeprom, data, 16);
> +
> +	/*
> +	 * Cleanup eeprom register.
> +	 */
> +	eeprom_93cx6_cleanup(eeprom);
> +
> +	/*
> +	 * Take a short break.
> +	 */
> +	msleep(10000);
> +
> +	/*
> +	 * select the ewen opcode.
> +	 */
> +	eeprom_93cx6_ewds(eeprom);
> +
> +	/*
> +	 * Cleanup eeprom register.
> +	 */
> +	eeprom_93cx6_cleanup(eeprom);
> +}
> +EXPORT_SYMBOL_GPL(eeprom_93cx6_write);
> +
> +
> +/**
> + * eeprom_93cx6_multiwrite - Write multiple words to the eeprom
> + * @eeprom: Pointer to eeprom structure
> + * @word: Word index from where we should start writing
> + * @data: Pointer where the information will be read from
> + * @words: Number of words that should be written.
> + *
> + * This function will write all requested words to the eeprom,
> + * this is done by calling eeprom_93cx6_write() multiple times.
> + * This method accepts little endian data, so it will first be
> + * converted into host endian.
> + */
> +void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom, const u8 word,
> +	__le16 *data, const u16 words)
> +{
> +	unsigned int i;
> +
> +	for (i = 0; i < words; i++)
> +		eeprom_93cx6_write(eeprom, word + i, le16_to_cpu(data[i]));
> +}
> +EXPORT_SYMBOL_GPL(eeprom_93cx6_multiwrite);
> diff --git a/include/linux/eeprom_93cx6.h b/include/linux/eeprom_93cx6.h
> new file mode 100644
> index 0000000..4b9be59
> --- /dev/null
> +++ b/include/linux/eeprom_93cx6.h
> @@ -0,0 +1,77 @@
> +/*
> +	Copyright (C) 2004 - 2006 rt2x00 SourceForge Project
> +	<http://rt2x00.serialmonkey.com>
> +
> +	This program is free software; you can redistribute it and/or modify
> +	it under the terms of the GNU General Public License as published by
> +	the Free Software Foundation; either version 2 of the License, or
> +	(at your option) any later version.
> +
> +	This program is distributed in the hope that it will be useful,
> +	but WITHOUT ANY WARRANTY; without even the implied warranty of
> +	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> +	GNU General Public License for more details.
> +
> +	You should have received a copy of the GNU General Public License
> +	along with this program; if not, write to the
> +	Free Software Foundation, Inc.,
> +	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
> + */
> +
> +/*
> +	Module: eeprom_93cx6
> +	Abstract: EEPROM reader datastructures for 93cx6 chipsets.
> +	Supported chipsets: 93c46 & 93c66.
> + */
> +
> +/*
> + * EEPROM operation defines.
> + */
> +#define PCI_EEPROM_WIDTH_93C46	6
> +#define PCI_EEPROM_WIDTH_93C66	8
> +#define PCI_EEPROM_WIDTH_OPCODE	3
> +#define PCI_EEPROM_WRITE_OPCODE	0x05
> +#define PCI_EEPROM_READ_OPCODE	0x06
> +#define PCI_EEPROM_EWDS_OPCODE	0x10
> +#define PCI_EEPROM_EWEN_OPCODE	0x13
> +
> +/**
> + * struct eeprom_93cx6 - control structure for setting the commands
> + * for reading the eeprom data.
> + * @data: private pointer for the driver.
> + * @register_read(struct eeprom_93cx6 *eeprom): handler to
> + * read the eeprom register, this function should set all reg_* fields.
> + * @register_write(struct eeprom_93cx6 *eeprom): handler to
> + * write to the eeprom register by using all reg_* fields.
> + * @width: eeprom width, should be one of the PCI_EEPROM_WIDTH_* defines
> + * @reg_data_in: register field to indicate data input
> + * @reg_data_out: register field to indicate data output
> + * @reg_data_clock: register field to set the data clock
> + * @reg_chip_select: register field to set the chip select
> + *
> + * This structure is used for the communication between the driver
> + * and the eeprom_93cx6 handlers for reading the eeprom.
> + */
> +struct eeprom_93cx6 {
> +	void *data;
> +
> +	void (*register_read)(struct eeprom_93cx6 *eeprom);
> +	void (*register_write)(struct eeprom_93cx6 *eeprom);
> +
> +	int width;
> +
> +	char reg_data_in;
> +	char reg_data_out;
> +	char reg_data_clock;
> +	char reg_chip_select;
> +};
> +
> +extern void eeprom_93cx6_read(struct eeprom_93cx6 *eeprom,
> +	const u8 word, u16 *data);
> +extern void eeprom_93cx6_multiread(struct eeprom_93cx6 *eeprom,
> +	const u8 word, __le16 *data, const u16 words);
> +
> +extern void eeprom_93cx6_write(struct eeprom_93cx6 *eeprom,
> +	const u8 word, u16 data);
> +extern void eeprom_93cx6_multiwrite(struct eeprom_93cx6 *eeprom,
> +	const u8 word, __le16 *data, const u16 words);
> 
> 
