From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
 driver.
Date: Sat, 10 Oct 2009 13:01:48 +0200
Message-ID: <1255172508.19127.22.camel@localhost.localdomain>
References: <1253662724-16497-1-git-send-email-tomas.winkler@intel.com>
	 <1253662724-16497-2-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	guy.cohen-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253662724-16497-2-git-send-email-tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tomas,

> This patch adds Intel Wireless MultiCom 3200 top driver.
> IWMC3200 is 4Wireless Com CHIP (GPS/BT/WiFi/WiMAX).
> Top driver is responsible for device initialization and firmware download.
> Firmware handled by top is responsible for top itself and
> as well as bluetooth and GPS coms. (Wifi and WiMax provide their own
> firmware)
> In addition top driver is used to retrieve firmware logs
> and supports other debugging features
> 
> Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/misc/Kconfig                   |    1 +
>  drivers/misc/Makefile                  |    1 +
>  drivers/misc/iwmc3200top/Kconfig       |   20 +
>  drivers/misc/iwmc3200top/Makefile      |   29 ++
>  drivers/misc/iwmc3200top/debugfs.c     |  145 +++++++
>  drivers/misc/iwmc3200top/debugfs.h     |   61 +++
>  drivers/misc/iwmc3200top/fw-download.c |  359 ++++++++++++++++
>  drivers/misc/iwmc3200top/fw-msg.h      |  113 +++++
>  drivers/misc/iwmc3200top/iwmc3200top.h |  202 +++++++++
>  drivers/misc/iwmc3200top/log.c         |  339 +++++++++++++++
>  drivers/misc/iwmc3200top/log.h         |  158 +++++++
>  drivers/misc/iwmc3200top/main.c        |  702 ++++++++++++++++++++++++++++++++
>  12 files changed, 2130 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/misc/iwmc3200top/Kconfig
>  create mode 100644 drivers/misc/iwmc3200top/Makefile
>  create mode 100644 drivers/misc/iwmc3200top/debugfs.c
>  create mode 100644 drivers/misc/iwmc3200top/debugfs.h
>  create mode 100644 drivers/misc/iwmc3200top/fw-download.c
>  create mode 100644 drivers/misc/iwmc3200top/fw-msg.h
>  create mode 100644 drivers/misc/iwmc3200top/iwmc3200top.h
>  create mode 100644 drivers/misc/iwmc3200top/log.c
>  create mode 100644 drivers/misc/iwmc3200top/log.h
>  create mode 100644 drivers/misc/iwmc3200top/main.c
> 
> diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
> index 68ab39d..6f85b43 100644
> --- a/drivers/misc/Kconfig
> +++ b/drivers/misc/Kconfig
> @@ -236,5 +236,6 @@ config ISL29003
>  source "drivers/misc/c2port/Kconfig"
>  source "drivers/misc/eeprom/Kconfig"
>  source "drivers/misc/cb710/Kconfig"
> +source "drivers/misc/iwmc3200top/Kconfig"
>  
>  endif # MISC_DEVICES
> diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
> index 36f733c..97f5303 100644
> --- a/drivers/misc/Makefile
> +++ b/drivers/misc/Makefile
> @@ -20,5 +20,6 @@ obj-$(CONFIG_SGI_GRU)		+= sgi-gru/
>  obj-$(CONFIG_HP_ILO)		+= hpilo.o
>  obj-$(CONFIG_ISL29003)		+= isl29003.o
>  obj-$(CONFIG_C2PORT)		+= c2port/
> +obj-$(CONFIG_IWMC3200TOP)      += iwmc3200top/
>  obj-y				+= eeprom/
>  obj-y				+= cb710/
> diff --git a/drivers/misc/iwmc3200top/Kconfig b/drivers/misc/iwmc3200top/Kconfig
> new file mode 100644
> index 0000000..9e4b88f
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/Kconfig
> @@ -0,0 +1,20 @@
> +config IWMC3200TOP
> +        tristate "Intel Wireless MultiCom Top Driver"
> +        depends on MMC && EXPERIMENTAL
> +        select FW_LOADER
> +	---help---
> +	  Intel Wireless MultiCom 3200 Top driver is responsible for
> +	  for firmware load and enabled coms enumeration
> +
> +config IWMC3200TOP_DEBUG
> +	bool "Enable full debug output of iwmc3200top Driver"
> +	depends on IWMC3200TOP
> +	---help---
> +	  Enable full debug output of iwmc3200top Driver
> +
> +config IWMC3200TOP_DEBUGFS
> +	bool "Enable Debugfs debugging interface for iwmc3200top"
> +	depends on IWMC3200TOP
> +	---help---
> +	  Enable creation of debugfs files for iwmc3200top
> +
> diff --git a/drivers/misc/iwmc3200top/Makefile b/drivers/misc/iwmc3200top/Makefile
> new file mode 100644
> index 0000000..fbf53fb
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/Makefile
> @@ -0,0 +1,29 @@
> +# iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
> +# drivers/misc/iwmc3200top/Makefile
> +#
> +# Copyright (C) 2009 Intel Corporation. All rights reserved.
> +#
> +# This program is free software; you can redistribute it and/or
> +# modify it under the terms of the GNU General Public License version
> +# 2 as published by the Free Software Foundation.
> +#
> +# This program is distributed in the hope that it will be useful,
> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> +# GNU General Public License for more details.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write to the Free Software
> +# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> +# 02110-1301, USA.
> +#
> +#
> +# Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> +#  -
> +#
> +#
> +
> +obj-$(CONFIG_IWMC3200TOP)	+= iwmc3200top.o
> +iwmc3200top-objs	:= main.o fw-download.o
> +iwmc3200top-$(CONFIG_IWMC3200TOP_DEBUG) += log.o
> +iwmc3200top-$(CONFIG_IWMC3200TOP_DEBUGFS) += debugfs.o
> diff --git a/drivers/misc/iwmc3200top/debugfs.c b/drivers/misc/iwmc3200top/debugfs.c
> new file mode 100644
> index 0000000..a531f6c
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/debugfs.c
> @@ -0,0 +1,145 @@
> +/*
> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
> + * drivers/misc/iwmc3200top/debufs.c
> + *
> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + *
> + *
> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> + *  -
> + *
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/ctype.h>
> +#include <linux/mmc/sdio_func.h>
> +#include <linux/mmc/sdio.h>
> +
> +#include "iwmc3200top.h"
> +#include "log.h"
> +#include "fw-msg.h"
> +#include "debugfs.h"
> +
> +/*      Constants definition        */
> +#define HEXADECIMAL_RADIX	16
> +
> +/*      Functions definition        */
> +
> +
> +/*      Debugfs macros       */
> +#define DEBUGFS_ADD_DIR(name, parent) do {			\
> +	dbgfs->dir_##name = debugfs_create_dir(#name, parent);	\
> +	if (!(dbgfs->dir_##name))				\
> +		goto err;					\
> +} while (0)
> +
> +#define DEBUGFS_ADD_FILE(name, parent) do {				\
> +	dbgfs->dbgfs_##parent##_files.file_##name =                     \
> +	debugfs_create_file(#name, 0644, dbgfs->dir_##parent, priv,     \
> +				&iwmct_dbgfs_##name##_ops);               \
> +	if (!(dbgfs->dbgfs_##parent##_files.file_##name))		\
> +		goto err;						\
> +} while (0)
> +
> +#define DEBUGFS_REMOVE(name)  do {	\
> +	debugfs_remove(name);		\
> +	name = NULL;			\
> +} while (0)
> +
> +#define DEBUGFS_READ_FUNC(name)						\
> +ssize_t iwmct_dbgfs_##name##_read(struct file *file,			\
> +				  char __user *user_buf,		\
> +				  size_t count, loff_t *ppos);
> +
> +#define DEBUGFS_WRITE_FUNC(name)					\
> +ssize_t iwmct_dbgfs_##name##_write(struct file *file,			\
> +				   const char __user *user_buf,		\
> +				   size_t count, loff_t *ppos);
> +
> +#define DEBUGFS_READ_FILE_OPS(name)					\
> +	DEBUGFS_READ_FUNC(name)						\
> +	static const struct file_operations iwmct_dbgfs_##name##_ops = {  \
> +		.read = iwmct_dbgfs_##name##_read,			\
> +		.open = iwmct_dbgfs_open_file_generic,			\
> +	};
> +
> +#define DEBUGFS_WRITE_FILE_OPS(name)					\
> +	DEBUGFS_WRITE_FUNC(name)					\
> +	static const struct file_operations iwmct_dbgfs_##name##_ops = {  \
> +		.write = iwmct_dbgfs_##name##_write,			\
> +		.open = iwmct_dbgfs_open_file_generic,			\
> +	};
> +
> +#define DEBUGFS_READ_WRITE_FILE_OPS(name)				\
> +	DEBUGFS_READ_FUNC(name)						\
> +	DEBUGFS_WRITE_FUNC(name)					\
> +	static const struct file_operations iwmct_dbgfs_##name##_ops = {\
> +		.write = iwmct_dbgfs_##name##_write,			\
> +		.read = iwmct_dbgfs_##name##_read,			\
> +		.open = iwmct_dbgfs_open_file_generic,			\
> +	};
> +
> +
> +/*      Debugfs file ops definitions        */
> +
> +/*      Debugfs registration functions        */
> +
> +/*
> + * Create the debugfs files and directories
> + *
> + */

so for me the whole debug infrastructure is way too much overhead for
what this driver has to achieve. What is the benefit of having all these
debugfs support. What is it trying to achieve?

Also all these macros really obfuscate the code for no real benefit. If
you wanna keep debugfs support, then just use the functions directly.
They are not that complicated that an extra abstraction layer is needed.

> +void iwmct_dbgfs_register(struct iwmct_priv *priv, const char *name)
> +{
> +	struct iwmct_debugfs *dbgfs;
> +
> +	dbgfs = kzalloc(sizeof(struct iwmct_debugfs), GFP_KERNEL);
> +	if (!dbgfs) {
> +		LOG_ERROR(priv, DEBUGFS, "failed to allocate %zd bytes\n",
> +					sizeof(struct iwmct_debugfs));
> +		goto err;
> +	}
> +
> +	priv->dbgfs = dbgfs;
> +	dbgfs->name = name;
> +	dbgfs->dir_drv = debugfs_create_dir(name, NULL);
> +	if (!dbgfs->dir_drv) {
> +		LOG_ERROR(priv, DEBUGFS, "failed to create debugfs dir\n");
> +		goto err;
> +	}
> +
> +
> +err:
> +	return;
> +}

goto err. Seriously. Just call return in the error case. And also there
is a memory leak if the debugfs_create_dir fails.

> +/**
> + * Remove the debugfs files and directories
> + *
> + */
> +void iwmct_dbgfs_unregister(struct iwmct_debugfs *dbgfs)
> +{
> +	if (!dbgfs)
> +		return;
> +
> +
> +	DEBUGFS_REMOVE(dbgfs->dir_drv);
> +	kfree(dbgfs);
> +
> +	dbgfs = NULL;
> +}
> +
> diff --git a/drivers/misc/iwmc3200top/debugfs.h b/drivers/misc/iwmc3200top/debugfs.h
> new file mode 100644
> index 0000000..24b1369
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/debugfs.h
> @@ -0,0 +1,61 @@
> +/*
> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
> + * drivers/misc/iwmc3200top/debufs.h
> + *
> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + *
> + *
> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> + *  -
> + *
> + */
> +
> +#ifndef __DEBUGFS_H__
> +#define __DEBUGFS_H__
> +
> +
> +#ifdef CONFIG_IWMC3200TOP_DEBUGFS
> +
> +#include <linux/debugfs.h>
> +
> +struct iwmct_debugfs {
> +	const char *name;
> +	struct dentry *dir_drv;
> +	struct dir_drv_files {
> +	} dbgfs_drv_files;
> +};
> +
> +void iwmct_dbgfs_register(struct iwmct_priv *priv, const char *name);
> +void iwmct_dbgfs_unregister(struct iwmct_debugfs *dbgfs);
> +
> +#else /* CONFIG_IWMC3200TOP_DEBUGFS */
> +
> +/* struct iwmct_debugfs is empty if CONFIG_IWMC3200TOP_DEBUGFS is not defined */
> +struct iwmct_debugfs {
> +};

If struct iwmct_debugfs is never referenced directly then a simple
forward struct imwct_debugfs; declaration is good enough.

> +
> +static inline void
> +iwmct_dbgfs_register(struct iwmct_priv *priv, const char *name)
> +{}
> +
> +static inline void iwmct_dbgfs_unregister(struct iwmct_debugfs *dbgfs)
> +{}
> +
> +#endif /* CONFIG_IWMC3200TOP_DEBUGFS */
> +
> +#endif /* __DEBUGFS_H__ */
> +
> diff --git a/drivers/misc/iwmc3200top/fw-download.c b/drivers/misc/iwmc3200top/fw-download.c
> new file mode 100644
> index 0000000..33cb693
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/fw-download.c
> @@ -0,0 +1,359 @@
> +/*
> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
> + * drivers/misc/iwmc3200top/fw-download.c
> + *
> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + *
> + *
> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> + *  -
> + *
> + */
> +
> +#include <linux/firmware.h>
> +#include <linux/mmc/sdio_func.h>
> +#include <asm/unaligned.h>
> +
> +#include "iwmc3200top.h"
> +#include "log.h"
> +#include "fw-msg.h"
> +
> +#define CHECKSUM_BYTES_NUM sizeof(u32)
> +
> +/**
> +  init parser struct with file
> + */
> +static int iwmct_fw_parser_init(struct iwmct_priv *priv, const u8 *file,
> +			      size_t file_size, size_t block_size)
> +{
> +	struct iwmct_parser *parser = &priv->parser;
> +	struct iwmct_fw_hdr *fw_hdr = &parser->versions;
> +
> +	LOG_INFOEX(priv, INIT, "-->\n");
> +
> +	LOG_INFO(priv, FW_DOWNLOAD, "file_size=%zd\n", file_size);

This logging is overkill. Can we just hide this via pr_debug and then
use just simply dynamic_printk support.

> +
> +	parser->file = file;
> +	parser->file_size = file_size;
> +	parser->cur_pos = 0;
> +	parser->buf = NULL;
> +
> +	parser->buf = kzalloc(block_size, GFP_KERNEL);
> +	if (!parser->buf) {
> +		LOG_ERROR(priv, FW_DOWNLOAD, "kzalloc error\n");
> +		return -ENOMEM;
> +	}
> +	parser->buf_size = block_size;
> +
> +	/* extract fw versions */
> +	memcpy(fw_hdr, parser->file, sizeof(struct iwmct_fw_hdr));
> +	LOG_INFO(priv, FW_DOWNLOAD, "fw versions are:\n"
> +		"top %u.%u.%u gps %u.%u.%u bt %u.%u.%u tic %s\n",
> +		fw_hdr->top_major, fw_hdr->top_minor, fw_hdr->top_revision,
> +		fw_hdr->gps_major, fw_hdr->gps_minor, fw_hdr->gps_revision,
> +		fw_hdr->bt_major, fw_hdr->bt_minor, fw_hdr->bt_revision,
> +		fw_hdr->tic_name);
> +
> +	parser->cur_pos += sizeof(struct iwmct_fw_hdr);
> +
> +	LOG_INFOEX(priv, INIT, "<--\n");
> +	return 0;
> +}
> +
> +static bool iwmct_checksum(struct iwmct_priv *priv)
> +{
> +	struct iwmct_parser *parser = &priv->parser;
> +	__le32 *file = (__le32 *)parser->file;
> +	int i, pad, steps;
> +	u32 accum = 0;
> +	u32 checksum;
> +	u32 mask = 0xffffffff;
> +
> +	pad = (parser->file_size - CHECKSUM_BYTES_NUM) % 4;
> +	steps =  (parser->file_size - CHECKSUM_BYTES_NUM) / 4;
> +
> +	LOG_INFO(priv, FW_DOWNLOAD, "pad=%d steps=%d\n", pad, steps);
> +
> +	for (i = 0; i < steps; i++)
> +		accum += le32_to_cpu(file[i]);
> +
> +	if (pad) {
> +		mask <<= 8 * (4 - pad);
> +		accum += le32_to_cpu(file[steps]) & mask;
> +	}
> +
> +	checksum = get_unaligned_le32((__le32 *)(parser->file +
> +			parser->file_size - CHECKSUM_BYTES_NUM));

The access to file and parser->file. One with unaligned access and the
other with, looks wrong. And it looks way to complicated.

Can we just not have a proper __le32 type of parser->file to begin with.

> +
> +	LOG_INFO(priv, FW_DOWNLOAD,
> +		"compare checksum accum=0x%x to checksum=0x%x\n",
> +		accum, checksum);
> +
> +	return checksum == accum;
> +}
> +
> +static int iwmct_parse_next_section(struct iwmct_priv *priv, const u8 **p_sec,
> +				  size_t *sec_size, __le32 *sec_addr)
> +{
> +	struct iwmct_parser *parser = &priv->parser;
> +	struct iwmct_dbg *dbg = &priv->dbg;
> +	struct iwmct_fw_sec_hdr *sec_hdr;
> +
> +	LOG_INFOEX(priv, INIT, "-->\n");
> +
> +	while (parser->cur_pos + sizeof(struct iwmct_fw_sec_hdr)
> +		<= parser->file_size) {
> +
> +		sec_hdr = (struct iwmct_fw_sec_hdr *)
> +				(parser->file + parser->cur_pos);
> +		parser->cur_pos += sizeof(struct iwmct_fw_sec_hdr);
> +
> +		LOG_INFO(priv, FW_DOWNLOAD,
> +			"sec hdr: type=%s addr=0x%x size=%d\n",
> +			sec_hdr->type, sec_hdr->target_addr,
> +			sec_hdr->data_size);
> +
> +		if (strcmp(sec_hdr->type, "ENT") == 0)
> +			parser->entry_point = le32_to_cpu(sec_hdr->target_addr);
> +		else if (strcmp(sec_hdr->type, "LBL") == 0)
> +			strcpy(dbg->label_fw, parser->file + parser->cur_pos);
> +		else if (((strcmp(sec_hdr->type, "TOP") == 0) &&
> +			  (priv->barker & BARKER_DNLOAD_TOP_MSK)) ||
> +			 ((strcmp(sec_hdr->type, "GPS") == 0) &&
> +			  (priv->barker & BARKER_DNLOAD_GPS_MSK)) ||
> +			 ((strcmp(sec_hdr->type, "BTH") == 0) &&
> +			  (priv->barker & BARKER_DNLOAD_BT_MSK))) {
> +			*sec_addr = sec_hdr->target_addr;
> +			*sec_size = le32_to_cpu(sec_hdr->data_size);
> +			*p_sec = parser->file + parser->cur_pos;
> +			parser->cur_pos += le32_to_cpu(sec_hdr->data_size);
> +			return 1;

This if statement is unreadable. This indentation gives me a headache.

Also this function better return bool and not int.

> +		} else if (strcmp(sec_hdr->type, "LOG") != 0)
> +			LOG_WARNING(priv, FW_DOWNLOAD,
> +				    "skipping section type %s\n",
> +				    sec_hdr->type);
> +
> +		parser->cur_pos += le32_to_cpu(sec_hdr->data_size);
> +		LOG_INFO(priv, FW_DOWNLOAD,
> +			"finished with section cur_pos=%zd\n", parser->cur_pos);
> +	}
> +
> +	LOG_INFOEX(priv, INIT, "<--\n");
> +	return 0;
> +}
> +
> +static int iwmct_download_section(struct iwmct_priv *priv, const u8 *p_sec,
> +				size_t sec_size, __le32 addr)
> +{
> +	struct iwmct_parser *parser = &priv->parser;
> +	struct iwmct_fw_load_hdr *hdr = (struct iwmct_fw_load_hdr *)parser->buf;
> +	const u8 *cur_block = p_sec;
> +	size_t sent = 0;
> +	int cnt = 0;
> +	int ret = 0;
> +	u32 cmd = 0;
> +
> +	LOG_INFOEX(priv, INIT, "-->\n");
> +	LOG_INFO(priv, FW_DOWNLOAD, "Download address 0x%x size 0x%zx\n",
> +				addr, sec_size);
> +
> +	while (sent < sec_size) {
> +		int i;
> +		u32 chksm = 0;
> +		u32 reset = atomic_read(&priv->reset);
> +		/* actual FW data */
> +		u32 data_size = min(parser->buf_size - sizeof(*hdr),
> +				    sec_size - sent);
> +		/* Pad to block size */
> +		u32 trans_size = (data_size + sizeof(*hdr) +
> +				  IWMC_SDIO_BLK_SIZE - 1) &
> +				  ~(IWMC_SDIO_BLK_SIZE - 1);
> +		++cnt;
> +
> +		/* in case of reset, interrupt FW DOWNLAOD */
> +		if (reset) {
> +			LOG_INFO(priv, FW_DOWNLOAD,
> +				 "Reset detected. Abort FW download!!!");
> +			ret = -ECANCELED;
> +			goto exit;
> +		}
> +
> +		memset(parser->buf, 0, parser->buf_size);
> +		cmd |= IWMC_OPCODE_WRITE << CMD_HDR_OPCODE_POS;
> +		cmd |= IWMC_CMD_SIGNATURE << CMD_HDR_SIGNATURE_POS;
> +		cmd |= (priv->dbg.direct ? 1 : 0) << CMD_HDR_DIRECT_ACCESS_POS;
> +		cmd |= (priv->dbg.checksum ? 1 : 0) << CMD_HDR_USE_CHECKSUM_POS;
> +		hdr->data_size = cpu_to_le32(data_size);
> +		hdr->target_addr = addr;
> +
> +		/* checksum is allowed for sizes divisible by 4 */
> +		if (data_size & 0x3)
> +			cmd &= ~CMD_HDR_USE_CHECKSUM_MSK;
> +
> +		memcpy(hdr->data, cur_block, data_size);
> +
> +
> +		if (cmd & CMD_HDR_USE_CHECKSUM_MSK) {
> +
> +			chksm = data_size + le32_to_cpu(addr) + cmd;
> +			for (i = 0; i < data_size >> 2; i++)
> +				chksm += ((u32 *)cur_block)[i];
> +
> +			hdr->block_chksm = cpu_to_le32(chksm);
> +			LOG_INFO(priv, FW_DOWNLOAD, "Checksum = 0x%X\n",
> +				 hdr->block_chksm);
> +		}
> +
> +		LOG_INFO(priv, FW_DOWNLOAD, "trans#%d, len=%d, sent=%zd, "
> +				"sec_size=%zd, startAddress 0x%X\n",
> +				cnt, trans_size, sent, sec_size, addr);
> +
> +		if (priv->dbg.dump)
> +			LOG_HEXDUMP(FW_DOWNLOAD, parser->buf, trans_size);
> +
> +
> +		hdr->cmd = cpu_to_le32(cmd);
> +		/* send it down */
> +		/* TODO: add more proper sending and error checking */
> +		ret = iwmct_tx(priv, 0, parser->buf, trans_size);
> +		if (ret != 0) {
> +			LOG_INFO(priv, FW_DOWNLOAD,
> +				"iwmct_tx returned %d\n", ret);
> +			goto exit;
> +		}
> +
> +		addr = cpu_to_le32(le32_to_cpu(addr) + data_size);
> +		sent += data_size;
> +		cur_block = p_sec + sent;
> +
> +		if (priv->dbg.blocks && (cnt + 1) >= priv->dbg.blocks) {
> +			LOG_INFO(priv, FW_DOWNLOAD,
> +				"Block number limit is reached [%d]\n",
> +				priv->dbg.blocks);
> +			break;
> +		}
> +	}
> +
> +	if (sent < sec_size)
> +		ret = -EINVAL;
> +exit:
> +	LOG_INFOEX(priv, INIT, "<--\n");
> +	return ret;
> +}
> +
> +static int iwmct_kick_fw(struct iwmct_priv *priv, bool jump)
> +{
> +	struct iwmct_parser *parser = &priv->parser;
> +	struct iwmct_fw_load_hdr *hdr = (struct iwmct_fw_load_hdr *)parser->buf;
> +	int ret;
> +	u32 cmd;
> +
> +	LOG_INFOEX(priv, INIT, "-->\n");
> +
> +	memset(parser->buf, 0, parser->buf_size);
> +	cmd = IWMC_CMD_SIGNATURE << CMD_HDR_SIGNATURE_POS;
> +	if (jump) {
> +		cmd |= IWMC_OPCODE_JUMP << CMD_HDR_OPCODE_POS;
> +		hdr->target_addr = cpu_to_le32(parser->entry_point);
> +		LOG_INFO(priv, FW_DOWNLOAD, "jump address 0x%x\n",
> +				parser->entry_point);
> +	} else {
> +		cmd |= IWMC_OPCODE_LAST_COMMAND << CMD_HDR_OPCODE_POS;
> +		LOG_INFO(priv, FW_DOWNLOAD, "last command\n");
> +	}
> +
> +	hdr->cmd = cpu_to_le32(cmd);
> +
> +	LOG_HEXDUMP(FW_DOWNLOAD, parser->buf, sizeof(*hdr));
> +	/* send it down */
> +	/* TODO: add more proper sending and error checking */
> +	ret = iwmct_tx(priv, 0, parser->buf, IWMC_SDIO_BLK_SIZE);
> +	if (ret)
> +		LOG_INFO(priv, FW_DOWNLOAD, "iwmct_tx returned %d", ret);
> +
> +	LOG_INFOEX(priv, INIT, "<--\n");
> +	return 0;
> +}
> +
> +int iwmct_fw_load(struct iwmct_priv *priv)
> +{
> +	const struct firmware *raw = NULL;
> +	__le32 addr;
> +	size_t len;
> +	const u8 *pdata;
> +	const u8 *name = "iwmc3200top.1.fw";
> +	int ret = 0;
> +
> +	/* clear parser struct */
> +	memset(&priv->parser, 0, sizeof(struct iwmct_parser));
> +	if (!name) {
> +		ret = -EINVAL;
> +		goto exit;
> +	}
> +
> +	/* get the firmware */
> +	ret = request_firmware(&raw, name, &priv->func->dev);
> +	if (ret < 0) {
> +		LOG_ERROR(priv, FW_DOWNLOAD, "%s request_firmware failed %d\n",
> +			  name, ret);
> +		goto exit;
> +	}
> +
> +	if (raw->size < sizeof(struct iwmct_fw_sec_hdr)) {
> +		LOG_ERROR(priv, FW_DOWNLOAD, "%s smaller then (%zd) (%zd)\n",
> +			  name, sizeof(struct iwmct_fw_sec_hdr), raw->size);
> +		goto exit;
> +	}
> +
> +	LOG_INFO(priv, FW_DOWNLOAD, "Read firmware '%s'\n", name);
> +
> +	ret = iwmct_fw_parser_init(priv, raw->data, raw->size, priv->trans_len);
> +	if (ret < 0) {
> +		LOG_ERROR(priv, FW_DOWNLOAD,
> +			  "iwmct_parser_init failed: Reason %d\n", ret);
> +		goto exit;
> +	}
> +
> +	/* checksum  */
> +	if (!iwmct_checksum(priv)) {
> +		LOG_ERROR(priv, FW_DOWNLOAD, "checksum error\n");
> +		ret = -EINVAL;
> +		goto exit;
> +	}
> +
> +	/* download firmware to device */
> +	while (iwmct_parse_next_section(priv, &pdata, &len, &addr)) {
> +		if (iwmct_download_section(priv, pdata, len, addr)) {
> +			LOG_ERROR(priv, FW_DOWNLOAD,
> +				  "%s download section failed\n", name);
> +			ret = -EIO;
> +			goto exit;
> +		}
> +	}
> +
> +	iwmct_kick_fw(priv, !!(priv->barker & BARKER_DNLOAD_JUMP_MSK));
> +
> +exit:
> +	kfree(priv->parser.buf);
> +
> +	if (raw)
> +		release_firmware(raw);
> +
> +	raw = NULL;
> +
> +	return ret;
> +}
> diff --git a/drivers/misc/iwmc3200top/fw-msg.h b/drivers/misc/iwmc3200top/fw-msg.h
> new file mode 100644
> index 0000000..9e26b75
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/fw-msg.h
> @@ -0,0 +1,113 @@
> +/*
> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
> + * drivers/misc/iwmc3200top/fw-msg.h
> + *
> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + *
> + *
> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> + *  -
> + *
> + */
> +
> +#ifndef __FWMSG_H__
> +#define __FWMSG_H__
> +
> +#define COMM_TYPE_D2H           	0xFF
> +#define COMM_TYPE_H2D           	0xEE
> +
> +#define COMM_CATEGORY_OPERATIONAL      	0x00
> +#define COMM_CATEGORY_DEBUG            	0x01
> +#define COMM_CATEGORY_TESTABILITY      	0x02
> +#define COMM_CATEGORY_DIAGNOSTICS      	0x03
> +
> +#define OP_DBG_ZSTR_MSG			cpu_to_le16(0x1A)
> +
> +#define FW_LOG_SRC_MAX			32
> +#define FW_LOG_SRC_ALL			255
> +
> +#define FW_STRING_TABLE_ADDR		cpu_to_le32(0x0C000000)
> +
> +#define CMD_DBG_LOG_LEVEL		cpu_to_le16(0x0001)
> +#define CMD_TST_DEV_RESET		cpu_to_le16(0x0060)
> +#define CMD_TST_FUNC_RESET		cpu_to_le16(0x0062)
> +#define CMD_TST_IFACE_RESET		cpu_to_le16(0x0064)
> +#define CMD_TST_CPU_UTILIZATION		cpu_to_le16(0x0065)
> +#define CMD_TST_TOP_DEEP_SLEEP		cpu_to_le16(0x0080)
> +#define CMD_TST_WAKEUP			cpu_to_le16(0x0081)
> +#define CMD_TST_FUNC_WAKEUP		cpu_to_le16(0x0082)
> +#define CMD_TST_FUNC_DEEP_SLEEP_REQUEST	cpu_to_le16(0x0083)
> +#define CMD_TST_GET_MEM_DUMP		cpu_to_le16(0x0096)
> +
> +#define OP_OPR_ALIVE			cpu_to_le16(0x0010)
> +#define OP_OPR_CMD_ACK			cpu_to_le16(0x001F)
> +#define OP_OPR_CMD_NACK			cpu_to_le16(0x0020)
> +#define OP_TST_MEM_DUMP			cpu_to_le16(0x0043)
> +
> +#define CMD_FLAG_PADDING_256		0x80
> +
> +#define FW_HCMD_BLOCK_SIZE      	256
> +
> +struct msg_hdr {
> +	u8 type;
> +	u8 category;
> +	__le16 opcode;
> +	u8 seqnum;
> +	u8 flags;
> +	__le16 length;
> +} __attribute__((__packed__));
> +
> +struct log_hdr {
> +	__le32 timestamp;
> +	u8 severity;
> +	u8 logsource;
> +	__le16 reserved;
> +} __attribute__((__packed__));
> +
> +struct mdump_hdr {
> +	u8 dmpid;
> +	u8 frag;
> +	__le16 size;
> +	__le32 addr;
> +} __attribute__((__packed__));
> +
> +struct top_msg {
> +	struct msg_hdr hdr;
> +	union {
> +		/* D2H messages */
> +		struct {
> +			struct log_hdr log_hdr;
> +			u8 data[1];
> +		} __attribute__((__packed__)) log;
> +
> +		struct {
> +			struct log_hdr log_hdr;
> +			struct mdump_hdr md_hdr;
> +			u8 data[1];
> +		} __attribute__((__packed__)) mdump;
> +
> +		/* H2D messages */
> +		struct {
> +			u8 logsource;
> +			u8 sevmask;
> +		} __attribute__((__packed__)) logdefs[FW_LOG_SRC_MAX];
> +		struct mdump_hdr mdump_req;
> +	} u;
> +} __attribute__((__packed__));
> +
> +
> +#endif /* __FWMSG_H__ */
> diff --git a/drivers/misc/iwmc3200top/iwmc3200top.h b/drivers/misc/iwmc3200top/iwmc3200top.h
> new file mode 100644
> index 0000000..59e4b7a
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/iwmc3200top.h
> @@ -0,0 +1,202 @@
> +/*
> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
> + * drivers/misc/iwmc3200top/iwmc3200top.h
> + *
> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + *
> + *
> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> + *  -
> + *
> + */
> +
> +#ifndef __IWMC3200TOP_H__
> +#define __IWMC3200TOP_H__
> +
> +#define DRV_NAME "iwmc3200top"
> +
> +#define IWMC_SDIO_BLK_SIZE			256
> +#define IWMC_DEFAULT_TR_BLK			64
> +#define IWMC_SDIO_DATA_ADDR			0x0
> +#define IWMC_SDIO_INTR_ENABLE_ADDR		0x14
> +#define IWMC_SDIO_INTR_STATUS_ADDR		0x13
> +#define IWMC_SDIO_INTR_CLEAR_ADDR		0x13
> +#define IWMC_SDIO_INTR_GET_SIZE_ADDR		0x2C
> +
> +#define COMM_HUB_HEADER_LENGTH 16
> +#define LOGGER_HEADER_LENGTH   10
> +
> +
> +#define BARKER_DNLOAD_BT_POS		0
> +#define BARKER_DNLOAD_BT_MSK		BIT(BARKER_DNLOAD_BT_POS)
> +#define BARKER_DNLOAD_GPS_POS		1
> +#define BARKER_DNLOAD_GPS_MSK		BIT(BARKER_DNLOAD_GPS_POS)
> +#define BARKER_DNLOAD_TOP_POS		2
> +#define BARKER_DNLOAD_TOP_MSK		BIT(BARKER_DNLOAD_TOP_POS)
> +#define BARKER_DNLOAD_RESERVED1_POS	3
> +#define BARKER_DNLOAD_RESERVED1_MSK	BIT(BARKER_DNLOAD_RESERVED1_POS)
> +#define BARKER_DNLOAD_JUMP_POS		4
> +#define BARKER_DNLOAD_JUMP_MSK		BIT(BARKER_DNLOAD_JUMP_POS)
> +#define BARKER_DNLOAD_SYNC_POS		5
> +#define BARKER_DNLOAD_SYNC_MSK		BIT(BARKER_DNLOAD_SYNC_POS)
> +#define BARKER_DNLOAD_RESERVED2_POS	6
> +#define BARKER_DNLOAD_RESERVED2_MSK	(0x3 << BARKER_DNLOAD_RESERVED2_POS)
> +#define BARKER_DNLOAD_BARKER_POS	8
> +#define BARKER_DNLOAD_BARKER_MSK	(0xffffff << BARKER_DNLOAD_BARKER_POS)
> +
> +#define IWMC_BARKER_REBOOT 	(0xdeadbe << BARKER_DNLOAD_BARKER_POS)
> +/* whole field barker */
> +#define IWMC_BARKER_ACK 	0xfeedbabe
> +
> +#define IWMC_CMD_SIGNATURE 	0xcbbc
> +
> +#define CMD_HDR_OPCODE_POS		0
> +#define CMD_HDR_OPCODE_MSK_MSK		(0xf << CMD_HDR_OPCODE_MSK_POS)
> +#define CMD_HDR_RESPONSE_CODE_POS	4
> +#define CMD_HDR_RESPONSE_CODE_MSK	(0xf << CMD_HDR_RESPONSE_CODE_POS)
> +#define CMD_HDR_USE_CHECKSUM_POS	8
> +#define CMD_HDR_USE_CHECKSUM_MSK	BIT(CMD_HDR_USE_CHECKSUM_POS)
> +#define CMD_HDR_RESPONSE_REQUIRED_POS	9
> +#define CMD_HDR_RESPONSE_REQUIRED_MSK	BIT(CMD_HDR_RESPONSE_REQUIRED_POS)
> +#define CMD_HDR_DIRECT_ACCESS_POS	10
> +#define CMD_HDR_DIRECT_ACCESS_MSK	BIT(CMD_HDR_DIRECT_ACCESS_POS)
> +#define CMD_HDR_RESERVED_POS		11
> +#define CMD_HDR_RESERVED_MSK		BIT(0x1f << CMD_HDR_RESERVED_POS)
> +#define CMD_HDR_SIGNATURE_POS		16
> +#define CMD_HDR_SIGNATURE_MSK		BIT(0xffff << CMD_HDR_SIGNATURE_POS)
> +
> +enum {
> +	IWMC_OPCODE_PING = 0,
> +	IWMC_OPCODE_READ = 1,
> +	IWMC_OPCODE_WRITE = 2,
> +	IWMC_OPCODE_JUMP = 3,
> +	IWMC_OPCODE_REBOOT = 4,
> +	IWMC_OPCODE_PERSISTENT_WRITE = 5,
> +	IWMC_OPCODE_PERSISTENT_READ = 6,
> +	IWMC_OPCODE_READ_MODIFY_WRITE = 7,
> +	IWMC_OPCODE_LAST_COMMAND = 15
> +};
> +
> +struct iwmct_fw_load_hdr {
> +	__le32 cmd;
> +	__le32 target_addr;
> +	__le32 data_size;
> +	__le32 block_chksm;
> +	u8 data[0];
> +};
> +
> +/**
> + * struct iwmct_fw_hdr
> + * holds all sw components versions
> + */
> +struct iwmct_fw_hdr {
> +	u8 top_major;
> +	u8 top_minor;
> +	u8 top_revision;
> +	u8 gps_major;
> +	u8 gps_minor;
> +	u8 gps_revision;
> +	u8 bt_major;
> +	u8 bt_minor;
> +	u8 bt_revision;
> +	u8 tic_name[31];
> +};
> +
> +/**
> + * struct iwmct_fw_sec_hdr
> + * @type: function type
> + * @data_size: section's data size
> + * @target_addr: download address
> + */
> +struct iwmct_fw_sec_hdr {
> +	u8 type[4];
> +	__le32 data_size;
> +	__le32 target_addr;
> +};
> +
> +/**
> + * struct iwmct_parser
> + * @file: fw image
> + * @file_size: fw size
> + * @cur_pos: position in file
> + * @buf: temp buf for download
> + * @buf_size: size of buf
> + * @entry_point: address to jump in fw kick-off
> + */
> +struct iwmct_parser {
> +	const u8 *file;
> +	size_t file_size;
> +	size_t cur_pos;
> +	u8 *buf;
> +	size_t buf_size;
> +	u32 entry_point;
> +	struct iwmct_fw_hdr versions;
> +};
> +
> +
> +struct iwmct_work_struct {
> +	struct list_head list;
> +	ssize_t iosize;
> +};
> +
> +struct iwmct_dbg {
> +	int blocks;
> +	bool dump;
> +	bool jump;
> +	bool direct;
> +	bool checksum;
> +	bool fw_download;
> +	int block_size;
> +	int download_trans_blks;
> +
> +	char label_fw[256];
> +};
> +
> +struct iwmct_priv {
> +	struct sdio_func *func;
> +	struct iwmct_debugfs *dbgfs;
> +	struct iwmct_parser parser;
> +	atomic_t reset;
> +	atomic_t dev_sync;
> +	u32 trans_len;
> +	u32 barker;
> +	struct iwmct_dbg dbg;
> +
> +	/* drivers work queue */
> +	struct workqueue_struct *wq;
> +	struct workqueue_struct *bus_rescan_wq;
> +	struct work_struct bus_rescan_worker;
> +	struct work_struct isr_worker;
> +
> +	/* drivers wait queue */
> +	wait_queue_head_t wait_q;
> +
> +	/* rx request list */
> +	struct list_head read_req_list;
> +};
> +
> +extern int iwmct_tx(struct iwmct_priv *priv, unsigned int addr,
> +		void *src, int count);
> +
> +extern int iwmct_fw_load(struct iwmct_priv *priv);
> +
> +extern void iwmct_dbg_init_params(struct iwmct_priv *drv);
> +extern void iwmct_dbg_init_drv_attrs(struct device_driver *drv);
> +extern void iwmct_dbg_remove_drv_attrs(struct device_driver *drv);
> +extern int iwmct_send_hcmd(struct iwmct_priv *priv, u8 *cmd, u16 len);
> +
> +#endif  /*  __IWMC3200TOP_H__  */
> diff --git a/drivers/misc/iwmc3200top/log.c b/drivers/misc/iwmc3200top/log.c
> new file mode 100644
> index 0000000..96b5e4a
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/log.c
> @@ -0,0 +1,339 @@
> +/*
> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
> + * drivers/misc/iwmc3200top/log.c
> + *
> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + *
> + *
> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> + *  -
> + *
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/mmc/sdio_func.h>
> +#include <linux/ctype.h>
> +#include "fw-msg.h"
> +#include "iwmc3200top.h"
> +#include "log.h"
> +
> +/* Maximal hexadecimal string size of the FW memdump message */
> +#define LOG_MSG_SIZE_MAX		12400
> +
> +/* iwmct_logdefs is a global used by log macros */
> +u8 iwmct_logdefs[LOG_SRC_MAX];
> +static u8 iwmct_fw_logdefs[FW_LOG_SRC_MAX];
> +
> +
> +static int _log_set_log_filter(u8 *logdefs, int size, u8 src, u8 logmask)
> +{
> +	int i;
> +
> +	if (src < size)
> +		logdefs[src] = logmask;
> +	else if (src == LOG_SRC_ALL)
> +		for (i = 0; i < size; i++)
> +			logdefs[i] = logmask;
> +	else
> +		return -1;
> +
> +	return 0;
> +}
> +
> +
> +int iwmct_log_set_filter(u8 src, u8 logmask)
> +{
> +	return _log_set_log_filter(iwmct_logdefs, LOG_SRC_MAX, src, logmask);
> +}
> +
> +
> +int iwmct_log_set_fw_filter(u8 src, u8 logmask)
> +{
> +	return _log_set_log_filter(iwmct_fw_logdefs,
> +				   FW_LOG_SRC_MAX, src, logmask);
> +}
> +
> +
> +static int log_msg_format_hex(char *str, int slen, u8 *ibuf,
> +			      int ilen, char *pref)
> +{
> +	int pos = 0;
> +	int i;
> +	int len;
> +
> +	for (pos = 0, i = 0; pos < slen - 2 && pref[i] != '\0'; i++, pos++)
> +		str[pos] = pref[i];
> +
> +	for (i = 0; pos < slen - 2 && i < ilen; pos += len, i++)
> +		len = snprintf(&str[pos], slen - pos - 1, " %2.2X", ibuf[i]);
> +
> +	if (i < ilen)
> +		return -1;
> +
> +	return 0;
> +}
> +
> +/*	NOTE: This function is not thread safe.
> +	Currently it's called only from sdio rx worker - no race there
> +*/
> +void iwmct_log_top_message(struct iwmct_priv *priv, u8 *buf, int len)
> +{
> +	struct top_msg *msg;
> +	static char logbuf[LOG_MSG_SIZE_MAX];
> +
> +	msg = (struct top_msg *)buf;
> +
> +	if (len < sizeof(msg->hdr) + sizeof(msg->u.log.log_hdr)) {
> +		LOG_ERROR(priv, FW_MSG, "Log message from TOP "
> +			  "is too short %d (expected %zd)\n",
> +			  len, sizeof(msg->hdr) + sizeof(msg->u.log.log_hdr));
> +		return;
> +	}
> +
> +	if (!(iwmct_fw_logdefs[msg->u.log.log_hdr.logsource] &
> +		BIT(msg->u.log.log_hdr.severity)) ||
> +	    !(iwmct_logdefs[LOG_SRC_FW_MSG] & BIT(msg->u.log.log_hdr.severity)))
> +		return;
> +
> +	switch (msg->hdr.category) {
> +	case COMM_CATEGORY_TESTABILITY:
> +		if (!(iwmct_logdefs[LOG_SRC_TST] &
> +		      BIT(msg->u.log.log_hdr.severity)))
> +			return;
> +		if (log_msg_format_hex(logbuf, LOG_MSG_SIZE_MAX, buf,
> +				       le16_to_cpu(msg->hdr.length) +
> +				       sizeof(msg->hdr), "<TST>"))
> +			LOG_WARNING(priv, TST,
> +				  "TOP TST message is too long, truncating...");
> +		LOG_WARNING(priv, TST, "%s\n", logbuf);
> +		break;
> +	case COMM_CATEGORY_DEBUG:
> +		if (msg->hdr.opcode == OP_DBG_ZSTR_MSG)
> +			LOG_INFO(priv, FW_MSG, "%s %s", "<DBG>",
> +				       ((u8 *)msg) + sizeof(msg->hdr)
> +					+ sizeof(msg->u.log.log_hdr));
> +		else {
> +			if (log_msg_format_hex(logbuf, LOG_MSG_SIZE_MAX, buf,
> +					le16_to_cpu(msg->hdr.length)
> +						+ sizeof(msg->hdr),
> +					"<DBG>"))
> +				LOG_WARNING(priv, FW_MSG,
> +					"TOP DBG message is too long,"
> +					"truncating...");
> +			LOG_WARNING(priv, FW_MSG, "%s\n", logbuf);
> +		}
> +		break;
> +	default:
> +		break;
> +	}
> +}
> +
> +static int _log_get_filter_str(u8 *logdefs, int logdefsz, char *buf, int size)
> +{
> +	int i, pos, len;
> +	for (i = 0, pos = 0; (pos < size-1) && (i < logdefsz); i++) {
> +		len = snprintf(&buf[pos], size - pos - 1, "0x%02X%02X,",
> +				i, logdefs[i]);
> +		pos += len;
> +	}
> +	buf[pos-1] = '\n';
> +	buf[pos] = '\0';
> +
> +	if (i < logdefsz)
> +		return -1;
> +	return 0;
> +}
> +
> +int log_get_filter_str(char *buf, int size)
> +{
> +	return _log_get_filter_str(iwmct_logdefs, LOG_SRC_MAX, buf, size);
> +}
> +
> +int log_get_fw_filter_str(char *buf, int size)
> +{
> +	return _log_get_filter_str(iwmct_fw_logdefs, FW_LOG_SRC_MAX, buf, size);
> +}
> +
> +#define HEXADECIMAL_RADIX	16
> +#define LOG_SRC_FORMAT		7 /* log level is in format of "0xXXXX," */
> +
> +ssize_t show_iwmct_log_level(struct device *d,
> +				struct device_attribute *attr, char *buf)
> +{
> +	struct iwmct_priv *priv = d->driver_data;
> +	char *str_buf;
> +	int buf_size;
> +	ssize_t ret = -EAGAIN;
> +
> +	buf_size = (LOG_SRC_FORMAT * LOG_SRC_MAX) + 1;
> +	str_buf = kzalloc(buf_size, GFP_KERNEL);
> +	if (!str_buf) {
> +		LOG_ERROR(priv, DEBUGFS,
> +			"failed to allocate %d bytes\n", buf_size);
> +		goto exit;
> +	}
> +
> +	if (log_get_filter_str(str_buf, buf_size) < 0)
> +		goto exit;
> +
> +	ret = sprintf(buf, "%s", str_buf);
> +
> +exit:
> +	kfree(str_buf);
> +	return ret;
> +}
> +
> +ssize_t store_iwmct_log_level(struct device *d,
> +			struct device_attribute *attr,
> +			const char *buf, size_t count)
> +{
> +	struct iwmct_priv *priv = d->driver_data;
> +	char *token, *str_buf = NULL;
> +	long val;
> +	u8 src, mask;
> +
> +	if (!count)
> +		goto err;
> +
> +	str_buf = kzalloc(count, GFP_KERNEL);
> +	if (!str_buf) {
> +		LOG_ERROR(priv, DEBUGFS,
> +			"failed to allocate %zd bytes\n", count);
> +		goto err;
> +	}
> +
> +	memcpy(str_buf, buf, count);
> +
> +	while ((token = strsep(&str_buf, ",")) != NULL) {
> +		while (isspace(*token))
> +			++token;
> +		if (strict_strtol(token, HEXADECIMAL_RADIX, &val)) {
> +			LOG_ERROR(priv, DEBUGFS,
> +				  "failed to convert string to long %s\n",
> +				  token);
> +			goto err;
> +		}
> +
> +		mask  = val & 0xFF;
> +		src = (val & 0XFF00) >> 8;
> +		iwmct_log_set_filter(src, mask);
> +	}
> +
> +	kfree(str_buf);
> +	return count;
> +
> +err:
> +	kfree(str_buf);
> +	return -EAGAIN;
> +}
> +
> +ssize_t show_iwmct_log_level_fw(struct device *d,
> +			struct device_attribute *attr, char *buf)
> +{
> +	struct iwmct_priv *priv = d->driver_data;
> +	char *str_buf;
> +	int buf_size;
> +	ssize_t ret = -EAGAIN;
> +
> +	buf_size = (LOG_SRC_FORMAT * FW_LOG_SRC_MAX) + 2;
> +
> +	str_buf = kzalloc(buf_size, GFP_KERNEL);
> +	if (!str_buf) {
> +		LOG_ERROR(priv, DEBUGFS,
> +			"failed to allocate %d bytes\n", buf_size);
> +		goto exit;
> +	}
> +
> +	if (log_get_fw_filter_str(str_buf, buf_size) < 0)
> +		goto exit;
> +
> +	ret = sprintf(buf, "%s", str_buf);
> +
> +exit:
> +	kfree(str_buf);
> +	return ret;
> +}
> +
> +ssize_t store_iwmct_log_level_fw(struct device *d,
> +			struct device_attribute *attr,
> +			const char *buf, size_t count)
> +{
> +	struct iwmct_priv *priv = d->driver_data;
> +	char *token, *str_buf = NULL;
> +	long val;
> +	u8 src, mask;
> +	struct top_msg cmd;
> +	u16 cmdlen = 0;
> +	int i, rc;
> +
> +	if (!count)
> +		goto err;
> +
> +	str_buf = kzalloc(count, GFP_KERNEL);
> +	if (!str_buf) {
> +		LOG_ERROR(priv, DEBUGFS,
> +			"failed to allocate %zd bytes\n", count);
> +		goto err;
> +	}
> +
> +	memcpy(str_buf, buf, count);
> +
> +	cmd.hdr.type = COMM_TYPE_H2D;
> +	cmd.hdr.category = COMM_CATEGORY_DEBUG;
> +	cmd.hdr.opcode = CMD_DBG_LOG_LEVEL;
> +
> +	for (i = 0; ((token = strsep(&str_buf, ",")) != NULL) &&
> +		     (i < FW_LOG_SRC_MAX); i++) {
> +
> +		while (isspace(*token))
> +			++token;
> +
> +		if (strict_strtol(token, HEXADECIMAL_RADIX, &val)) {
> +			LOG_ERROR(priv, DEBUGFS,
> +				  "failed to convert string to long %s\n",
> +				  token);
> +			goto err;
> +		}
> +
> +		mask  = val & 0xFF; /* LSB */
> +		src = (val & 0XFF00) >> 8; /* 2nd least significant byte. */
> +		iwmct_log_set_fw_filter(src, mask);
> +
> +		cmd.u.logdefs[i].logsource = src;
> +		cmd.u.logdefs[i].sevmask = mask;
> +	}
> +
> +	cmd.hdr.length = cpu_to_le16(i * sizeof(cmd.u.logdefs[0]));
> +	cmdlen = (i * sizeof(cmd.u.logdefs[0]) + sizeof(cmd.hdr));
> +
> +	rc = iwmct_send_hcmd(priv, (u8 *) &cmd, cmdlen);
> +	if (rc) {
> +		LOG_ERROR(priv, DEBUGFS,
> +			  "Failed to send %d bytes of fwcmd, rc=%d\n",
> +			  cmdlen, rc);
> +		goto err;
> +	} else
> +		LOG_INFO(priv, DEBUGFS, "fwcmd sent (%d bytes)\n", cmdlen);
> +
> +	kfree(str_buf);
> +	return count;
> +
> +err:
> +	kfree(str_buf);
> +	return -EAGAIN;
> +}
> +
> diff --git a/drivers/misc/iwmc3200top/log.h b/drivers/misc/iwmc3200top/log.h
> new file mode 100644
> index 0000000..aba8121
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/log.h
> @@ -0,0 +1,158 @@
> +/*
> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
> + * drivers/misc/iwmc3200top/log.h
> + *
> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + *
> + *
> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> + *  -
> + *
> + */
> +
> +#ifndef __LOG_H__
> +#define __LOG_H__
> +
> +
> +/* log severity:
> + * The log levels here match FW log levels
> + * so values need to stay as is */
> +#define LOG_SEV_CRITICAL		0
> +#define LOG_SEV_ERROR			1
> +#define LOG_SEV_WARNING			2
> +#define LOG_SEV_INFO			3
> +#define LOG_SEV_INFOEX			4
> +
> +#define LOG_SEV_FILTER_ALL		\
> +	(BIT(LOG_SEV_CRITICAL) |	\
> +	 BIT(LOG_SEV_ERROR)    |	\
> +	 BIT(LOG_SEV_WARNING)  | 	\
> +	 BIT(LOG_SEV_INFO)     |	\
> +	 BIT(LOG_SEV_INFOEX))
> +
> +/* log source */
> +#define LOG_SRC_INIT			0
> +#define LOG_SRC_DEBUGFS			1
> +#define LOG_SRC_FW_DOWNLOAD		2
> +#define LOG_SRC_FW_MSG			3
> +#define LOG_SRC_TST			4
> +#define LOG_SRC_IRQ			5
> +
> +#define	LOG_SRC_MAX			6
> +#define	LOG_SRC_ALL			0xFF
> +
> +/**
> + * Default intitialization runtime log level
> + */
> +#ifndef LOG_SEV_FILTER_RUNTIME
> +#define LOG_SEV_FILTER_RUNTIME			\
> +	(BIT(LOG_SEV_CRITICAL)	|		\
> +	 BIT(LOG_SEV_ERROR)	|		\
> +	 BIT(LOG_SEV_WARNING))
> +#endif
> +
> +#ifndef FW_LOG_SEV_FILTER_RUNTIME
> +#define FW_LOG_SEV_FILTER_RUNTIME	LOG_SEV_FILTER_ALL
> +#endif
> +
> +#ifdef CONFIG_IWMC3200TOP_DEBUG
> +/**
> + * Log macros
> + */
> +
> +#define priv2dev(priv) (&(priv->func)->dev)
> +
> +#define LOG_CRITICAL(priv, src, fmt, args...)				\
> +do {									\
> +	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_CRITICAL))	\
> +		dev_crit(priv2dev(priv), "%s %d: " fmt,			\
> +			__func__, __LINE__, ##args);			\
> +} while (0)
> +
> +#define LOG_ERROR(priv, src, fmt, args...)				\
> +do {									\
> +	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_ERROR))	\
> +		dev_err(priv2dev(priv), "%s %d: " fmt,			\
> +			__func__, __LINE__, ##args);			\
> +} while (0)
> +
> +#define LOG_WARNING(priv, src, fmt, args...)				\
> +do {									\
> +	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_WARNING))	\
> +		dev_warn(priv2dev(priv), "%s %d: " fmt,			\
> +			 __func__, __LINE__, ##args);			\
> +} while (0)
> +
> +#define LOG_INFO(priv, src, fmt, args...)				\
> +do {									\
> +	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_INFO))		\
> +		dev_info(priv2dev(priv), "%s %d: " fmt,			\
> +			 __func__, __LINE__, ##args);			\
> +} while (0)
> +
> +#define LOG_INFOEX(priv, src, fmt, args...)				\
> +do {									\
> +	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_INFOEX))	\
> +		dev_dbg(priv2dev(priv), "%s %d: " fmt,			\
> +			 __func__, __LINE__, ##args);			\
> +} while (0)
> +
> +#define LOG_HEXDUMP(src, ptr, len)					\
> +do {									\
> +	if (iwmct_logdefs[LOG_SRC_ ## src] & BIT(LOG_SEV_INFOEX))	\
> +		print_hex_dump(KERN_DEBUG, "", DUMP_PREFIX_NONE,	\
> +				16, 1, ptr, len, false);		\
> +} while (0)
> +
> +void iwmct_log_top_message(struct iwmct_priv *priv, u8 *buf, int len);
> +
> +extern u8 iwmct_logdefs[];
> +
> +int iwmct_log_set_filter(u8 src, u8 logmask);
> +int iwmct_log_set_fw_filter(u8 src, u8 logmask);
> +
> +ssize_t show_iwmct_log_level(struct device *d,
> +			struct device_attribute *attr, char *buf);
> +ssize_t store_iwmct_log_level(struct device *d,
> +			struct device_attribute *attr,
> +			const char *buf, size_t count);
> +ssize_t show_iwmct_log_level_fw(struct device *d,
> +			struct device_attribute *attr, char *buf);
> +ssize_t store_iwmct_log_level_fw(struct device *d,
> +			struct device_attribute *attr,
> +			const char *buf, size_t count);
> +
> +#else
> +
> +#define LOG_CRITICAL(priv, src, fmt, args...)
> +#define LOG_ERROR(priv, src, fmt, args...)
> +#define LOG_WARNING(priv, src, fmt, args...)
> +#define LOG_INFO(priv, src, fmt, args...)
> +#define LOG_INFOEX(priv, src, fmt, args...)
> +#define LOG_HEXDUMP(src, ptr, len)
> +
> +static inline void iwmct_log_top_message(struct iwmct_priv *priv,
> +					 u8 *buf, int len) {}
> +static inline int iwmct_log_set_filter(u8 src, u8 logmask) { return 0; }
> +static inline int iwmct_log_set_fw_filter(u8 src, u8 logmask) { return 0; }
> +
> +#endif /* CONFIG_IWMC3200TOP_DEBUG */
> +
> +int log_get_filter_str(char *buf, int size);
> +int log_get_fw_filter_str(char *buf, int size);
> +
> +#endif /* __LOG_H__ */

Seriously. Please just use dynamic_printk and lets remove all this log
infrastructure. It is way too much overhead for too little benefit.

> diff --git a/drivers/misc/iwmc3200top/main.c b/drivers/misc/iwmc3200top/main.c
> new file mode 100644
> index 0000000..09f8d06
> --- /dev/null
> +++ b/drivers/misc/iwmc3200top/main.c
> @@ -0,0 +1,702 @@
> +/*
> + * iwmc3200top - Intel Wireless MultiCom 3200 Top Driver
> + * drivers/misc/iwmc3200top/main.c
> + *
> + * Copyright (C) 2009 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License version
> + * 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
> + * 02110-1301, USA.
> + *
> + *
> + * Author Name: Maxim Grabarnik <maxim.grabarnink-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> + *  -
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/mmc/sdio_ids.h>
> +#include <linux/mmc/sdio_func.h>
> +#include <linux/mmc/sdio.h>
> +
> +#include "iwmc3200top.h"
> +#include "log.h"
> +#include "fw-msg.h"
> +#include "debugfs.h"
> +
> +
> +#define DRIVER_DESCRIPTION "Intel(R) IWMC 3200 Top Driver"
> +#define DRIVER_COPYRIGHT "Copyright (c) 2008 Intel Corporation."
> +
> +#define IWMCT_VERSION "0.1.62"
> +
> +#ifdef REPOSITORY_LABEL
> +#define RL REPOSITORY_LABEL
> +#else
> +#define RL ""
> +#endif
> +
> +#ifdef CONFIG_IWMC3200TOP_DEBUG
> +#define VD "-d"
> +#else
> +#define VD
> +#endif
> +
> +#define DRIVER_VERSION IWMCT_VERSION "-"  __stringify(RL) VD
> +
> +MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
> +MODULE_VERSION(DRIVER_VERSION);
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR(DRIVER_COPYRIGHT);
> +
> +
> +#ifndef SDIO_DEVICE_ID_INTEL_IWMC3200TOP
> +#define SDIO_DEVICE_ID_INTEL_IWMC3200TOP	0x1404
> +#endif
> +
> +/*
> + * This workers main task is to wait for OP_OPR_ALIVE
> + * from TOP FW until ALIVE_MSG_TIMOUT timeout is elapsed.
> + * When OP_OPR_ALIVE received it will issue
> + * a call to "bus_rescan_devices".
> + */
> +static void iwmct_rescan_worker(struct work_struct *ws)
> +{
> +	struct iwmct_priv *priv;
> +	int ret;
> +
> +	priv = container_of(ws, struct iwmct_priv, bus_rescan_worker);
> +
> +	LOG_INFO(priv, FW_MSG, "Calling bus_rescan\n");
> +
> +	ret = bus_rescan_devices(priv->func->dev.bus);
> +	if (ret < 0)
> +		LOG_INFO(priv, FW_DOWNLOAD, "bus_rescan_devices FAILED!!!\n");
> +}
> +
> +static void op_top_message(struct iwmct_priv *priv, struct top_msg *msg)
> +{
> +	switch (msg->hdr.opcode) {
> +	case OP_OPR_ALIVE:
> +		LOG_INFO(priv, FW_MSG, "Got ALIVE from device, wake rescan\n");
> +		queue_work(priv->bus_rescan_wq, &priv->bus_rescan_worker);
> +		break;
> +	default:
> +		LOG_INFO(priv, FW_MSG, "Received msg opcode 0x%X\n",
> +			msg->hdr.opcode);
> +		break;
> +	}
> +}
> +
> +
> +static void handle_top_message(struct iwmct_priv *priv, u8 *buf, int len)
> +{
> +	struct top_msg *msg;
> +
> +	msg = (struct top_msg *)buf;
> +
> +	if (msg->hdr.type != COMM_TYPE_D2H) {
> +		LOG_ERROR(priv, FW_MSG,
> +			"Message from TOP with invalid message type 0x%X\n",
> +			msg->hdr.type);
> +		return;
> +	}
> +
> +	if (len < sizeof(msg->hdr)) {
> +		LOG_ERROR(priv, FW_MSG,
> +			"Message from TOP is too short for message header "
> +			"received %d bytes, expected at least %zd bytes\n",
> +			len, sizeof(msg->hdr));
> +		return;
> +	}
> +
> +	if (len < le16_to_cpu(msg->hdr.length) + sizeof(msg->hdr)) {
> +		LOG_ERROR(priv, FW_MSG,
> +			"Message length (%d bytes) is shorter than "
> +			"in header (%d bytes)\n",
> +			len, le16_to_cpu(msg->hdr.length));
> +		return;
> +	}
> +
> +	switch (msg->hdr.category) {
> +	case COMM_CATEGORY_OPERATIONAL:
> +		op_top_message(priv, (struct top_msg *)buf);
> +		break;
> +
> +	case COMM_CATEGORY_DEBUG:
> +	case COMM_CATEGORY_TESTABILITY:
> +	case COMM_CATEGORY_DIAGNOSTICS:
> +		iwmct_log_top_message(priv, buf, len);
> +		break;
> +
> +	default:
> +		LOG_ERROR(priv, FW_MSG,
> +			"Message from TOP with unknown category 0x%X\n",
> +			msg->hdr.category);
> +		break;
> +	}
> +}
> +
> +int iwmct_send_hcmd(struct iwmct_priv *priv, u8 *cmd, u16 len)
> +{
> +	int ret;
> +	u8 *buf;
> +
> +	LOG_INFOEX(priv, FW_MSG, "Sending hcmd:\n");
> +
> +	/* add padding to 256 for IWMC */
> +	((struct top_msg *)cmd)->hdr.flags |= CMD_FLAG_PADDING_256;
> +
> +	LOG_HEXDUMP(FW_MSG, cmd, len);
> +
> +	if (len > FW_HCMD_BLOCK_SIZE) {
> +		LOG_ERROR(priv, FW_MSG, "size %d exceeded hcmd max size %d\n",
> +			  len, FW_HCMD_BLOCK_SIZE);
> +		return -1;
> +	}
> +
> +	buf = kzalloc(FW_HCMD_BLOCK_SIZE, GFP_KERNEL);
> +	if (!buf) {
> +		LOG_ERROR(priv, FW_MSG, "kzalloc error, buf size %d\n",
> +			  FW_HCMD_BLOCK_SIZE);
> +		return -1;
> +	}
> +
> +	memcpy(buf, cmd, len);
> +
> +	sdio_claim_host(priv->func);
> +	ret = sdio_memcpy_toio(priv->func, IWMC_SDIO_DATA_ADDR, buf,
> +			       FW_HCMD_BLOCK_SIZE);
> +	sdio_release_host(priv->func);
> +
> +	kfree(buf);
> +	return ret;
> +}
> +
> +int iwmct_tx(struct iwmct_priv *priv, unsigned int addr,
> +	void *src, int count)
> +{
> +	int ret;
> +
> +	sdio_claim_host(priv->func);
> +	ret = sdio_memcpy_toio(priv->func, addr, src, count);
> +	sdio_release_host(priv->func);
> +
> +	return ret;
> +}
> +
> +static void iwmct_irq_read_worker(struct work_struct *ws)
> +{
> +	struct iwmct_priv *priv;
> +	struct iwmct_work_struct *read_req;
> +	__le32 *buf = NULL;
> +	int ret, val, i;
> +	int iosize;
> +	u32 barker;
> +
> +	priv = container_of(ws, struct iwmct_priv, isr_worker);
> +
> +	LOG_INFO(priv, IRQ, "enter iwmct_irq_read_worker %p\n", ws);
> +
> +	/* --------------------- Handshake with device -------------------- */
> +	sdio_claim_host(priv->func);
> +
> +	/* all list manipulations have to be protected by
> +	 * sdio_claim_host/sdio_release_host */
> +	if (list_empty(&priv->read_req_list)) {
> +		LOG_ERROR(priv, IRQ, "read_req_list empty in read worker\n");
> +		goto exit_release;
> +	}
> +
> +	read_req = list_entry(priv->read_req_list.next,
> +			      struct iwmct_work_struct, list);
> +
> +	list_del(&read_req->list);
> +	iosize = read_req->iosize;
> +	kfree(read_req);
> +
> +	buf = kzalloc(iosize, GFP_KERNEL);
> +	if (!buf) {
> +		LOG_ERROR(priv, IRQ, "kzalloc error, buf size %d\n", iosize);
> +		goto exit_release;
> +	}
> +
> +	LOG_INFO(priv, IRQ, "iosize=%d, buf=%p, func=%d\n",
> +				iosize, buf, priv->func->num);
> +
> +	/* read from device */
> +	ret = sdio_memcpy_fromio(priv->func, buf, IWMC_SDIO_DATA_ADDR, iosize);
> +	if (ret) {
> +		LOG_ERROR(priv, IRQ, "error %d reading buffer\n", ret);
> +		goto exit_release;
> +	}
> +
> +	LOG_HEXDUMP(IRQ, (u8 *)buf, iosize);
> +
> +	barker = le32_to_cpu(buf[0]);
> +	if (barker != IWMC_BARKER_ACK &&
> +	   (barker & BARKER_DNLOAD_BARKER_MSK) != IWMC_BARKER_REBOOT) {
> +		/* Handle Top Commhub message.
> +		 * Current handling - treat all message as
> +		 * logger messages and print the context as a string. */
> +		sdio_release_host(priv->func);
> +		handle_top_message(priv, (u8 *)buf, iosize);
> +		goto exit;
> +	}
> +
> +	/* verify basic barker sanity */
> +	for (i = 1; i < 4; i++)
> +		if (buf[i] != buf[0]) {
> +			LOG_ERROR(priv, IRQ, "Corrupted barker,"
> +					     "buf[%d]=%x buf[0]=%x\n",
> +					     i, buf[i], buf[0]);
> +			goto exit_release;
> +		}
> +
> +	val = atomic_read(&priv->dev_sync);
> +
> +	switch (val) {
> +	case 0:
> +		/* we expect to recieve REBOOT BARKER */
> +		if ((barker & BARKER_DNLOAD_BARKER_MSK) != IWMC_BARKER_REBOOT) {
> +			LOG_ERROR(priv, IRQ, "Expecting for reboot barker %x,"
> +					"but got %x\n",
> +					IWMC_BARKER_REBOOT,
> +					(barker & BARKER_DNLOAD_BARKER_MSK));
> +			goto exit_release;
> +		}
> +
> +		LOG_INFO(priv, IRQ, "Recieved reboot barker: %x\n", barker);
> +		priv->barker = barker;
> +
> +		if (barker & BARKER_DNLOAD_SYNC_MSK) {
> +			/* Send the same barker back */
> +			ret = sdio_memcpy_toio(priv->func, IWMC_SDIO_DATA_ADDR,
> +					       buf, iosize);
> +			if (ret) {
> +				LOG_ERROR(priv, IRQ,
> +					 "error %d echoing barker\n", ret);
> +				goto exit_release;
> +			}
> +			LOG_INFO(priv, IRQ, "Echoing barker to device\n");
> +			atomic_inc(&priv->dev_sync);
> +			goto exit_release;
> +		}
> +		break;
> +
> +	case 1:
> +		/* we expect to recieve ACK BARKER */
> +		if (barker != IWMC_BARKER_ACK) {
> +			LOG_INFO(priv, IRQ, "Expecting for ACK barker[%x],"
> +				 "got this instead %x\n",
> +				 IWMC_BARKER_ACK, barker);
> +			goto exit_release;
> +		}
> +		kfree(buf);
> +		atomic_set(&priv->dev_sync, 0);
> +		atomic_set(&priv->reset, 0);
> +		break;
> +
> +	default:
> +		LOG_INFO(priv, IRQ, "Wrong dev_sync %d\n", val);
> +		break;
> +	}
> +
> +	sdio_release_host(priv->func);
> +
> +
> +	LOG_INFO(priv, IRQ, "barker download request 0x%x is:\n", priv->barker);
> +	LOG_INFO(priv, IRQ, "*******  Top FW %s requested ********\n",
> +			(priv->barker & BARKER_DNLOAD_TOP_MSK) ? "was" : "not");
> +	LOG_INFO(priv, IRQ, "*******  GPS FW %s requested ********\n",
> +			(priv->barker & BARKER_DNLOAD_GPS_MSK) ? "was" : "not");
> +	LOG_INFO(priv, IRQ, "*******  BT FW %s requested ********\n",
> +			(priv->barker & BARKER_DNLOAD_BT_MSK) ? "was" : "not");
> +
> +	if (priv->dbg.fw_download)
> +		iwmct_fw_load(priv);
> +	else
> +		LOG_ERROR(priv, IRQ, "FW download not allowed\n");
> +
> +	return;
> +
> +exit_release:
> +	sdio_release_host(priv->func);
> +exit:
> +	kfree(buf);
> +	LOG_INFO(priv, IRQ, "exit iwmct_irq_read_worker\n");
> +}
> +
> +static void iwmct_irq(struct sdio_func *func)
> +{
> +	struct iwmct_priv *priv;
> +	int val, ret;
> +	int iosize;
> +	int addr = IWMC_SDIO_INTR_GET_SIZE_ADDR;
> +	struct iwmct_work_struct *read_req;
> +
> +	priv = sdio_get_drvdata(func);
> +
> +	LOG_INFO(priv, IRQ, "enter iwmct_irq\n");
> +
> +	/* read the function's status register */
> +	val = sdio_readb(func, IWMC_SDIO_INTR_STATUS_ADDR, &ret);
> +
> +	LOG_INFO(priv, IRQ, "iir value = %d, ret=%d\n", val, ret);
> +
> +	if (!val) {
> +		LOG_ERROR(priv, IRQ, "iir = 0, exiting ISR\n");
> +		goto exit_clear_intr;
> +	}
> +
> +
> +	/*
> +	 * read 2 bytes of the transaction size
> +	 * IMPORTANT: sdio transaction size has to be read before clearing
> +	 * sdio interrupt!!!
> +	 */
> +	val = sdio_readb(priv->func, addr++, &ret);
> +	iosize = val;
> +	val = sdio_readb(priv->func, addr++, &ret);
> +	iosize += val << 8;
> +
> +	LOG_INFO(priv, IRQ, "READ size %d\n", iosize);
> +
> +	if (iosize == 0) {
> +		LOG_ERROR(priv, IRQ, "READ size %d, exiting ISR\n", iosize);
> +		goto exit_clear_intr;
> +	}
> +
> +	/* allocate a work structure to pass iosize to the worker */
> +	read_req = kzalloc(sizeof(struct iwmct_work_struct), GFP_KERNEL);
> +	if (!read_req) {
> +		LOG_ERROR(priv, IRQ, "failed to allocate read_req, exit ISR\n");
> +		goto exit_clear_intr;
> +	}
> +
> +	INIT_LIST_HEAD(&read_req->list);
> +	read_req->iosize = iosize;
> +
> +	list_add_tail(&priv->read_req_list, &read_req->list);
> +
> +	/* clear the function's interrupt request bit (write 1 to clear) */
> +	sdio_writeb(func, 1, IWMC_SDIO_INTR_CLEAR_ADDR, &ret);
> +
> +	queue_work(priv->wq, &priv->isr_worker);
> +
> +	LOG_INFO(priv, IRQ, "exit iwmct_irq\n");
> +
> +	return;
> +
> +exit_clear_intr:
> +	/* clear the function's interrupt request bit (write 1 to clear) */
> +	sdio_writeb(func, 1, IWMC_SDIO_INTR_CLEAR_ADDR, &ret);
> +}
> +
> +
> +static int blocks;
> +module_param(blocks, int, 0604);
> +MODULE_PARM_DESC(blocks, "max_blocks_to_send");
> +
> +static int dump;
> +module_param(dump, bool, 0604);
> +MODULE_PARM_DESC(dump, "dump_hex_content");
> +
> +static int jump = 1;
> +module_param(jump, bool, 0604);
> +
> +static int direct = 1;
> +module_param(direct, bool, 0604);
> +
> +static int checksum = 1;
> +module_param(checksum, bool, 0604);
> +
> +static int fw_download = 1;
> +module_param(fw_download, bool, 0604);
> +
> +static int block_size = IWMC_SDIO_BLK_SIZE;
> +module_param(block_size, int, 0404);
> +
> +static int download_trans_blks = IWMC_DEFAULT_TR_BLK;
> +module_param(download_trans_blks, int, 0604);
> +
> +static int rubbish_barker;
> +module_param(rubbish_barker, bool, 0604);

Most of them are missing descriptions. And do we really need them? What
cases are they trying to work around?

> +
> +#ifdef CONFIG_IWMC3200TOP_DEBUG
> +static int log_level[LOG_SRC_MAX];
> +static unsigned int log_level_argc;
> +module_param_array(log_level, int, &log_level_argc, 0604);
> +MODULE_PARM_DESC(log_level, "log_level");
> +
> +static int log_level_fw[FW_LOG_SRC_MAX];
> +static unsigned int log_level_fw_argc;
> +module_param_array(log_level_fw, int, &log_level_fw_argc, 0604);
> +MODULE_PARM_DESC(log_level_fw, "log_level_fw");
> +#endif
> +
> +void iwmct_dbg_init_params(struct iwmct_priv *priv)
> +{
> +#ifdef CONFIG_IWMC3200TOP_DEBUG
> +	int i;
> +
> +	for (i = 0; i < log_level_argc; i++) {
> +		dev_notice(&priv->func->dev, "log_level[%d]=0x%X\n",
> +						i, log_level[i]);
> +		iwmct_log_set_filter((log_level[i] >> 8) & 0xFF,
> +			       log_level[i] & 0xFF);
> +	}
> +	for (i = 0; i < log_level_fw_argc; i++) {
> +		dev_notice(&priv->func->dev, "log_level_fw[%d]=0x%X\n",
> +						i, log_level_fw[i]);
> +		iwmct_log_set_fw_filter((log_level_fw[i] >> 8) & 0xFF,
> +				  log_level_fw[i] & 0xFF);
> +	}
> +#endif
> +
> +	priv->dbg.blocks = blocks;
> +	LOG_INFO(priv, INIT, "blocks=%d\n", blocks);
> +	priv->dbg.dump = (bool)dump;
> +	LOG_INFO(priv, INIT, "dump=%d\n", dump);
> +	priv->dbg.jump = (bool)jump;
> +	LOG_INFO(priv, INIT, "jump=%d\n", jump);
> +	priv->dbg.direct = (bool)direct;
> +	LOG_INFO(priv, INIT, "direct=%d\n", direct);
> +	priv->dbg.checksum = (bool)checksum;
> +	LOG_INFO(priv, INIT, "checksum=%d\n", checksum);
> +	priv->dbg.fw_download = (bool)fw_download;
> +	LOG_INFO(priv, INIT, "fw_download=%d\n", fw_download);
> +	priv->dbg.block_size = block_size;
> +	LOG_INFO(priv, INIT, "block_size=%d\n", block_size);
> +	priv->dbg.download_trans_blks = download_trans_blks;
> +	LOG_INFO(priv, INIT, "download_trans_blks=%d\n", download_trans_blks);
> +}
> +
> +/*****************************************************************************
> + *
> + * sysfs attributes
> + *
> + *****************************************************************************/
> +static ssize_t show_iwmct_fw_version(struct device *d,
> +				  struct device_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%s\n",
> +		       ((struct iwmct_priv *)d->driver_data)->dbg.label_fw);
> +}
> +static DEVICE_ATTR(cc_label_fw, S_IRUGO, show_iwmct_fw_version, NULL);
> +
> +#ifdef CONFIG_IWMC3200TOP_DEBUG
> +static DEVICE_ATTR(log_level, S_IWUSR | S_IRUGO,
> +		   show_iwmct_log_level, store_iwmct_log_level);
> +static DEVICE_ATTR(log_level_fw, S_IWUSR | S_IRUGO,
> +		   show_iwmct_log_level_fw, store_iwmct_log_level_fw);
> +#endif

First module parameters and now device attributes. Why?

> +
> +static struct attribute *iwmct_sysfs_entries[] = {
> +	&dev_attr_cc_label_fw.attr,
> +#ifdef CONFIG_IWMC3200TOP_DEBUG
> +	&dev_attr_log_level.attr,
> +	&dev_attr_log_level_fw.attr,
> +#endif
> +	NULL
> +};
> +
> +static struct attribute_group iwmct_attribute_group = {
> +	.name = NULL,		/* put in device directory */
> +	.attrs = iwmct_sysfs_entries,
> +};
> +
> +
> +static int iwmct_probe(struct sdio_func *func,
> +			   const struct sdio_device_id *id)
> +{
> +	struct iwmct_priv *priv;
> +	int ret;
> +	int val = 1;
> +	int addr = IWMC_SDIO_INTR_ENABLE_ADDR;
> +
> +	dev_info(&func->dev, "enter iwmct_probe\n");
> +
> +	dev_info(&func->dev, "IRQ polling period id %u msecs, HZ is %d\n",
> +		jiffies_to_msecs(2147483647), HZ);

This is debug code. Don't use dev_info().

> +
> +	priv = kzalloc(sizeof(struct iwmct_priv), GFP_KERNEL);
> +	if (!priv) {
> +		dev_err(&func->dev, "kzalloc error\n");
> +		return -ENOMEM;
> +	}
> +	priv->func = func;
> +	sdio_set_drvdata(func, priv);
> +
> +	LOG_INFO(priv, INIT, "HIDR supported\n");
> +
> +	/* create drivers work queue */
> +	priv->wq = create_workqueue(DRV_NAME "_wq");
> +	priv->bus_rescan_wq = create_workqueue(DRV_NAME "_rescan_wq");
> +	INIT_WORK(&priv->bus_rescan_worker, iwmct_rescan_worker);
> +	INIT_WORK(&priv->isr_worker, iwmct_irq_read_worker);
> +
> +	init_waitqueue_head(&priv->wait_q);
> +
> +	sdio_claim_host(func);
> +	/* FIXME: Remove after it is fixed in the Boot ROM upgrade */
> +	func->enable_timeout = 10;
> +
> +	/* In our HW, setting the block size also wakes up the boot rom. */
> +	ret = sdio_set_block_size(func, priv->dbg.block_size);
> +	if (ret) {
> +		LOG_ERROR(priv, INIT,
> +			"sdio_set_block_size() failure: %d\n", ret);
> +		goto error_sdio_enable;
> +	}
> +
> +	ret = sdio_enable_func(func);
> +	if (ret) {
> +		LOG_ERROR(priv, INIT, "sdio_enable_func() failure: %d\n", ret);
> +		goto error_sdio_enable;
> +	}
> +
> +	/* init reset and dev_sync states */
> +	atomic_set(&priv->reset, 0);
> +	atomic_set(&priv->dev_sync, 0);
> +
> +	/* init read req queue */
> +	INIT_LIST_HEAD(&priv->read_req_list);
> +
> +	/* process configurable parameters */
> +	iwmct_dbg_init_params(priv);
> +	ret = sysfs_create_group(&func->dev.kobj, &iwmct_attribute_group);
> +	if (ret) {
> +		LOG_ERROR(priv, INIT, "Failed to register attributes and "
> +			 "initialize module_params\n");
> +		goto error_dev_attrs;
> +	}
> +
> +	iwmct_dbgfs_register(priv, DRV_NAME);
> +
> +	if (!priv->dbg.direct && priv->dbg.download_trans_blks > 8) {
> +		LOG_INFO(priv, INIT,
> +			 "Reducing transaction to 8 blocks = 2K (from %d)\n",
> +			 priv->dbg.download_trans_blks);
> +		priv->dbg.download_trans_blks = 8;
> +	}
> +	priv->trans_len = priv->dbg.download_trans_blks * priv->dbg.block_size;
> +	LOG_INFO(priv, INIT, "Transaction length = %d\n", priv->trans_len);
> +
> +	ret = sdio_claim_irq(func, iwmct_irq);
> +	if (ret) {
> +		LOG_ERROR(priv, INIT, "sdio_claim_irq() failure: %d\n", ret);
> +		goto error_claim_irq;
> +	}
> +
> +
> +	/* Enable function's interrupt */
> +	sdio_writeb(priv->func, val, addr, &ret);
> +	if (ret) {
> +		LOG_ERROR(priv, INIT, "Failure writing to "
> +			  "Interrupt Enable Register (%d): %d\n", addr, ret);
> +		goto error_enable_int;
> +	}
> +
> +	sdio_release_host(func);
> +
> +	LOG_INFO(priv, INIT, "exit iwmct_probe\n");
> +
> +	return ret;
> +
> +error_enable_int:
> +	sdio_release_irq(func);
> +error_claim_irq:
> +	sdio_disable_func(func);
> +error_dev_attrs:
> +	iwmct_dbgfs_unregister(priv->dbgfs);
> +	sysfs_remove_group(&func->dev.kobj, &iwmct_attribute_group);
> +error_sdio_enable:
> +	sdio_release_host(func);
> +	return ret;
> +}
> +
> +static void iwmct_remove(struct sdio_func *func)
> +{
> +	struct iwmct_work_struct *read_req;
> +	struct iwmct_priv *priv = sdio_get_drvdata(func);
> +
> +	priv = sdio_get_drvdata(func);
> +
> +	LOG_INFO(priv, INIT, "enter\n");
> +
> +	sdio_claim_host(func);
> +	sdio_release_irq(func);
> +	sdio_release_host(func);
> +
> +	/* Safely destroy osc workqueue */
> +	destroy_workqueue(priv->bus_rescan_wq);
> +	destroy_workqueue(priv->wq);
> +
> +	sdio_claim_host(func);
> +	sdio_disable_func(func);
> +	sysfs_remove_group(&func->dev.kobj, &iwmct_attribute_group);
> +	iwmct_dbgfs_unregister(priv->dbgfs);
> +	sdio_release_host(func);
> +
> +	/* free read requests */
> +	while (!list_empty(&priv->read_req_list)) {
> +		read_req = list_entry(priv->read_req_list.next,
> +			struct iwmct_work_struct, list);
> +
> +		list_del(&read_req->list);
> +		kfree(read_req);
> +	}
> +
> +	kfree(priv);
> +}
> +
> +
> +static const struct sdio_device_id iwmct_ids[] = {
> +	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL, SDIO_DEVICE_ID_INTEL_IWMC3200TOP)},
> +	{ /* end: all zeroes */	},
> +};
> +
> +MODULE_DEVICE_TABLE(sdio, iwmct_ids);
> +
> +static struct sdio_driver iwmct_driver = {
> +	.probe		= iwmct_probe,
> +	.remove		= iwmct_remove,
> +	.name		= DRV_NAME,
> +	.id_table	= iwmct_ids,
> +};
> +
> +static int __init iwmct_init(void)
> +{
> +	int rc;
> +
> +	/* Default log filter settings */
> +	iwmct_log_set_filter(LOG_SRC_ALL, LOG_SEV_FILTER_RUNTIME);
> +	iwmct_log_set_filter(LOG_SRC_FW_MSG, LOG_SEV_FILTER_ALL);
> +	iwmct_log_set_fw_filter(LOG_SRC_ALL, FW_LOG_SEV_FILTER_RUNTIME);
> +
> +	rc = sdio_register_driver(&iwmct_driver);
> +
> +	return rc;
> +}

Actually return sdio_register_driver() would do the same trick.

> +
> +static void __exit iwmct_exit(void)
> +{
> +	sdio_unregister_driver(&iwmct_driver);
> +}
> +
> +module_init(iwmct_init);
> +module_exit(iwmct_exit);
> +

At some point I got lost in this code. It contains more debug statements
and infrastructure than actual code as it seems. Can you please clean
this up. I mentioned it above. Just use dynamic_printk and you should be
have something clean and simple.

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
