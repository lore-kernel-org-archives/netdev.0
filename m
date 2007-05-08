From: Michael-Luke Jones <mlj28@cam.ac.uk>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - NPE
Date: Tue, 8 May 2007 08:02:15 +0100
Message-ID: <8CA5FD65-BEE1-4769-B1DF-81CA82210F61@cam.ac.uk>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain> <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk> <m33b289zku.fsf@maximus.localdomain> <m33b285exl.fsf_-_@maximus.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppsw-2.csi.cam.ac.uk ([131.111.8.132]:58501 "EHLO
	ppsw-2.csi.cam.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755456AbXEHHCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 03:02:54 -0400
In-Reply-To: <m33b285exl.fsf_-_@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 8 May 2007, at 01:36, Krzysztof Halasa wrote:

> Adds a driver for built-in IXP4xx Network Processor Engines.
> This patch requires IXP4xx Queue Manager driver and the "fuses" patch.
>
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

[snip]

> diff --git a/arch/arm/mach-ixp4xx/ixp4xx_npe.c b/arch/arm/mach- 
> ixp4xx/ixp4xx_npe.c
> new file mode 100644
> index 0000000..4c77d8a
> --- /dev/null
> +++ b/arch/arm/mach-ixp4xx/ixp4xx_npe.c

Already in mach-ixp4xx, so can just be called npe.c

> @@ -0,0 +1,737 @@
> +/*
> + * Intel IXP4xx Network Processor Engine driver for Linux
> + *
> + * Copyright (C) 2007 Krzysztof Halasa <khc@pm.waw.pl>
> + *
> + * This program is free software; you can redistribute it and/or  
> modify it
> + * under the terms of version 2 of the GNU General Public License
> + * as published by the Free Software Foundation.
> + *
> + * The code is based on publicly available information:
> + * - Intel IXP4xx Developer's Manual and other e-papers
> + * - Intel IXP400 Access Library Software (BSD license)
> + * - previous works by Christian Hohnstaedt  
> <chohnstaedt@innominate.com>
> + *   Thanks, Christian.
> + */

[snip]

> +int npe_load_firmware(struct npe *npe, const char *name, struct  
> device *dev)
> +{
> +	const struct firmware *fw_entry;
> +
> +	struct dl_block {
> +		u32 type;
> +		u32 offset;
> +	} *blk;
> +
> +	struct dl_image {
> +		u32 magic;
> +		u32 id;
> +		u32 size;
> +		union {
> +			u32 data[0];
> +			struct dl_block blocks[0];
> +		};
> +	} *image;
> +
> +	struct dl_codeblock {
> +		u32 npe_addr;
> +		u32 size;
> +		u32 data[0];
> +	} *cb;
> +
> +	int i, j, err, data_size, instr_size, blocks, table_end;
> +	u32 cmd;
> +
> +	if ((err = request_firmware(&fw_entry, name, dev)) != 0)
> +		return err;
> +
> +	err = -EINVAL;
> +	if (fw_entry->size < sizeof(struct dl_image)) {
> +		print_npe(KERN_ERR, npe, "incomplete firmware file\n");
> +		goto err;
> +	}
> +	image = (struct dl_image*)fw_entry->data;
> +
> +#if DEBUG_FW
> +	print_npe(KERN_DEBUG, npe, "firmware: %08X %08X %08X (0x%X bytes) 
> \n",
> +		  image->magic, image->id, image->size, image->size * 4);
> +#endif
> +
> +	if (image->magic == swab32(FW_MAGIC)) { /* swapped file */
> +		image->id = swab32(image->id);
> +		image->size = swab32(image->size);
> +	} else if (image->magic != FW_MAGIC) {
> +		print_npe(KERN_ERR, npe, "bad firmware file magic: 0x%X\n",
> +			  image->magic);
> +		goto err;
> +	}
> +	if ((image->size * 4 + sizeof(struct dl_image)) != fw_entry->size) {
> +		print_npe(KERN_ERR, npe,
> +			  "inconsistent size of firmware file\n");
> +		goto err;
> +	}
> +	if (((image->id >> 24) & 0xF /* NPE ID */) != npe->id) {
> +		print_npe(KERN_ERR, npe, "firmware file NPE ID mismatch\n");
> +		goto err;
> +	}
> +	if (image->magic == swab32(FW_MAGIC))
> +		for (i = 0; i < image->size; i++)
> +			image->data[i] = swab32(image->data[i]);
> +
> +	if (!cpu_is_ixp46x() && ((image->id >> 28) & 0xF /* device ID */)) {
> +		print_npe(KERN_INFO, npe, "IXP46x firmware ignored on "
> +			  "IXP42x\n");
> +		goto err;
> +	}
> +
> +	if (npe_running(npe)) {
> +		print_npe(KERN_INFO, npe, "unable to load firmware, NPE is "
> +			  "already running\n");
> +		err = -EBUSY;
> +		goto err;
> +	}
> +#if 0
> +	npe_stop(npe);
> +	npe_reset(npe);
> +#endif

Debugging code? Can this go?

> +	print_npe(KERN_INFO, npe, "firmware functionality 0x%X, "
> +		  "revision 0x%X:%X\n", (image->id >> 16) & 0xFF,
> +		  (image->id >> 8) & 0xFF, image->id & 0xFF);
> +
> +	if (!cpu_is_ixp46x()) {
> +		if (!npe->id)
> +			instr_size = NPE_A_42X_INSTR_SIZE;
> +		else
> +			instr_size = NPE_B_AND_C_42X_INSTR_SIZE;
> +		data_size = NPE_42X_DATA_SIZE;
> +	} else {
> +		instr_size = NPE_46X_INSTR_SIZE;
> +		data_size = NPE_46X_DATA_SIZE;
> +	}
> +
> +	for (blocks = 0; blocks * sizeof(struct dl_block) / 4 < image->size;
> +	     blocks++)
> +		if (image->blocks[blocks].type == FW_BLOCK_TYPE_EOF)
> +			break;
> +	if (blocks * sizeof(struct dl_block) / 4 >= image->size) {
> +		print_npe(KERN_INFO, npe, "firmware EOF block marker not "
> +			  "found\n");
> +		goto err;
> +	}
> +
> +#if DEBUG_FW
> +	print_npe(KERN_DEBUG, npe, "%i firmware blocks found\n", blocks);
> +#endif
> +
> +	table_end = blocks * sizeof(struct dl_block) / 4 + 1 /* EOF  
> marker */;
> +	for (i = 0, blk = image->blocks; i < blocks; i++, blk++) {
> +		if (blk->offset > image->size - sizeof(struct dl_codeblock) / 4
> +		    || blk->offset < table_end) {
> +			print_npe(KERN_INFO, npe, "invalid offset 0x%X of "
> +				  "firmware block #%i\n", blk->offset, i);
> +			goto err;
> +		}
> +
> +		cb = (struct dl_codeblock*)&image->data[blk->offset];
> +		if (blk->type == FW_BLOCK_TYPE_INSTR) {
> +			if (cb->npe_addr + cb->size > instr_size)
> +				goto too_big;
> +			cmd = CMD_WR_INS_MEM;
> +		} else if (blk->type == FW_BLOCK_TYPE_DATA) {
> +			if (cb->npe_addr + cb->size > data_size)
> +				goto too_big;
> +			cmd = CMD_WR_DATA_MEM;
> +		} else {
> +			print_npe(KERN_INFO, npe, "invalid firmware block #%i "
> +				  "type 0x%X\n", i, blk->type);
> +			goto err;
> +		}
> +		if (blk->offset + sizeof(*cb) / 4 + cb->size > image->size) {
> +			print_npe(KERN_INFO, npe, "firmware block #%i doesn't "
> +				  "fit in firmware image: type %c, start 0x%X,"
> +				  " length 0x%X\n", i,
> +				  blk->type == FW_BLOCK_TYPE_INSTR ? 'I' : 'D',
> +				  cb->npe_addr, cb->size);
> +			goto err;
> +		}
> +
> +		for (j = 0; j < cb->size; j++)
> +			npe_cmd_write(npe, cb->npe_addr + j, cmd, cb->data[j]);
> +	}
> +
> +	npe_start(npe);
> +	if (!npe_running(npe))
> +		print_npe(KERN_ERR, npe, "unable to start\n");
> +	release_firmware(fw_entry);
> +	return 0;
> +
> +too_big:
> +	print_npe(KERN_INFO, npe, "firmware block #%i doesn't fit in NPE "
> +		  "memory: type %c, start 0x%X, length 0x%X\n", i,
> +		  blk->type == FW_BLOCK_TYPE_INSTR ? 'I' : 'D',
> +		  cb->npe_addr, cb->size);
> +err:
> +	release_firmware(fw_entry);
> +	return err;
> +}

[snip]

> +module_init(npe_init_module);
> +module_exit(npe_cleanup_module);
> +
> +MODULE_AUTHOR("Krzysztof Halasa");
> +MODULE_LICENSE("GPL v2");
> +
> +EXPORT_SYMBOL(npe_names);
> +EXPORT_SYMBOL(npe_running);
> +EXPORT_SYMBOL(npe_request);
> +EXPORT_SYMBOL(npe_release);
> +EXPORT_SYMBOL(npe_load_firmware);
> +EXPORT_SYMBOL(npe_send_message);
> +EXPORT_SYMBOL(npe_recv_message);
> +EXPORT_SYMBOL(npe_send_recv_message);
> diff --git a/include/asm-arm/arch-ixp4xx/npe.h b/include/asm-arm/ 
> arch-ixp4xx/npe.h
> new file mode 100644
> index 0000000..fd20bf5
> --- /dev/null
> +++ b/include/asm-arm/arch-ixp4xx/npe.h
> @@ -0,0 +1,41 @@
> +#ifndef __IXP4XX_NPE_H
> +#define __IXP4XX_NPE_H
> +
> +#include <linux/etherdevice.h>
> +#include <linux/kernel.h>
> +#include <asm/io.h>
> +
> +extern const char *npe_names[];
> +
> +struct npe_regs {
> +	u32 exec_addr, exec_data, exec_status_cmd, exec_count;
> +	u32 action_points[4];
> +	u32 watchpoint_fifo, watch_count;
> +	u32 profile_count;
> +	u32 messaging_status, messaging_control;
> +	u32 mailbox_status, /*messaging_*/ in_out_fifo;
> +};
> +
> +struct npe {
> +	struct resource *mem_res;
> +	struct npe_regs __iomem *regs;
> +	u32 regs_phys;
> +	int id;
> +	int valid;
> +};
> +
> +
> +static inline const char *npe_name(struct npe *npe)
> +{
> +	return npe_names[npe->id];
> +}
> +
> +int npe_running(struct npe *npe);
> +int npe_send_message(struct npe *npe, const void *msg, const char  
> *what);
> +int npe_recv_message(struct npe *npe, void *msg, const char *what);
> +int npe_send_recv_message(struct npe *npe, void *msg, const char  
> *what);
> +int npe_load_firmware(struct npe *npe, const char *name, struct  
> device *dev);
> +struct npe *npe_request(int id);
> +void npe_release(struct npe *npe);
> +
> +#endif /* __IXP4XX_NPE_H */

It may be a matter of taste, but could some of the many definitions  
at the top of ixp4xx_npe.c go in the header file here?

Michael-Luke

