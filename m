From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-2.6 PATCH 6/10] Neterion: New driver: Hardware init &
	configuration
Date: Mon, 16 Mar 2009 21:42:04 +0000
Message-ID: <1237239724.3106.68.camel@achroite>
References: <1237018885.4966.431.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:41959 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754098AbZCPVmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 17:42:15 -0400
In-Reply-To: <1237018885.4966.431.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-03-14 at 00:21 -0800, Ramkrishna Vepa wrote:
> This patch takes care of Initialization and configuration steps of
> Neterion Inc's X3100 Series 10GbE PCIe I/O Virtualized Server Adapter=
=2E
> - Device Initialization.
> - Verification and setting of device config parameters.
> - Allocation of Tx FIFO and Rx Ring descriptors (DTR).
> - APIs to get various type of hw stats
> - APIs to configure RTS (Receive Traffic Steering)
>=20
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -urpN patch_5/drivers/net/vxge/vxge-config.c patch_6/drivers/net=
/vxge/vxge-config.c
> --- patch_5/drivers/net/vxge/vxge-config.c	1969-12-31 16:00:00.000000=
000 -0800
> +++ patch_6/drivers/net/vxge/vxge-config.c	2009-03-13 00:11:27.000000=
000 -0700
> @@ -0,0 +1,7576 @@
> +/*******************************************************************=
***********
> + * This software may be used and distributed according to the terms =
of
> + * the GNU General Public License (GPL), incorporated herein by refe=
rence.
> + * Drivers based on or derived from this code fall under the GPL and=
 must
> + * retain the authorship, copyright and license notice.  This file i=
s not
> + * a complete program and may only be used when the entire operating
> + * system is licensed under the GPL.
> + * See the file COPYING in this distribution for more information.
> + *******************************************************************=
***********/
> +/*******************************************************************=
************
> + * vxge-config.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe =
I/O
> + *                Virtualized Server Adapter.
> + * Copyright(c) 2002-2009 Neterion Inc.
> + *******************************************************************=
***********/
> +#include <linux/version.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/pci.h>
> +#include <linux/delay.h>
> +
> +#include "vxge-traffic.h"
> +#include "vxge-config.h"
> +
> +/*

You need to start a comment with "/**" to make it a kernel-doc comment.

> + * __hw_channel_allocate - Allocate memory for channel
> + * @devh: Handle to the device object
> + * @vph: Handle to Virtual Path
> + * @type: Type of channel
> + * @length: Lengths of arrays
> + * @alloc_work_array: Flag to specify if work array is required
> + * @alloc_free_array: Flag to specify if free array is required
> + * @alloc_reserve_array: Flag to specify if reserve array is require=
d
> + * @per_dtr_space: driver requested per dtr space to be allocated in=
 priv
> + * @userdata: User data to be passed back in the callback
> + *
> + * This function allocates required memory for the channel and vario=
us arrays
> + * in the channel
> + */
> +struct __hw_channel*
> +__hw_channel_allocate(

Drivers in the kernel tree are not necessarily compiled as modules, so
their external symbols must be globally unique.  You should use a
driver- specific prefix, presumably "vxge" (possibly with "__" in front
of that).

[...]
> +/*
> + * __hw_channel_free - Free memory allocated for channel
> + * @channel: channel to be freed
> + *
> + * This function deallocates memory from the channel and various arr=
ays
> + * in the channel
> + */
> +void
> +__hw_channel_free(
> +	struct __hw_channel *channel)
> +{
> +	u32	vp_id =3D 0;
> +	struct __hw_device  *hldev;
> +
> +	vxge_assert(channel !=3D NULL);
> +
> +	hldev =3D (struct __hw_device  *)channel->devh;
> +
> +	vp_id =3D ((struct __hw_vpath_handle *)channel->vph)->vpath->vp_id;
> +
> +	if (channel->work_arr) {
> +		vfree(channel->work_arr);
> +		channel->work_arr =3D NULL;

Why bother clearing members of *channel just before you free it?

[...]
> +/*
> + * __hw_channel_initialize - Initialize a channel
> + * @channel: channel to be initialized
> + *
> + * This function initializes a channel by properly setting the
> + * various references
> + */
> +enum vxge_hw_status
> +__hw_channel_initialize(
> +	struct __hw_channel *channel)
> +{
> +	u32 i;
> +	struct __hw_virtualpath *vpath;
> +
> +	vxge_assert(channel !=3D NULL);
> +
> +	vpath =3D (struct __hw_virtualpath *)((struct __hw_vpath_handle *) =
\
> +						channel->vph)->vpath;

Why are you using backslashes in multi-line statements?  This is only
necessary in macro definitions.

[...]
> +/*
> + * __hw_device_pci_caps_list_process
> + * @hldev: HW device handle.
> + *
> + * Process PCI capabilities and initialize the offsets
> + */
> +void
> +__hw_device_pci_caps_list_process(struct __hw_device *hldev)

This is redundant with pci_find_capability().

[...]
> +/*
> + * __hw_device_pci_e_init
> + * @hldev: HW device handle.
> + *
> + * Initialize certain PCI/PCI-X configuration registers
> + * with recommended values. Save config space for future hw resets.
> + */
> +void
> +__hw_device_pci_e_init(struct __hw_device *hldev)#
> +{
> +	int i;
> +	u16 cmd =3D 0;
> +	u16 device_id;
> +	u8  revision;
> +
> +	vxge_assert(hldev !=3D NULL);
> +
> +	/* Store PCI device ID and revision for future references where in =
we
> +	 * decide Xena revision using PCI sub system ID */
> +	pci_read_config_word(hldev->pdev,
> +			vxge_offsetof(struct vxge_hw_pci_config_le, device_id),
> +			&device_id);
> +
> +	pci_read_config_byte(hldev->pdev, vxge_offsetof(
> +				struct vxge_hw_pci_config_le, revision),
> +				&revision);

This information is in *hldev->pdev already.

> +	/* save original PCI config space to restore it on device_terminate=
() */
> +	for (i =3D 0; i < VXGE_HW_PCI_CONFIG_SPACE_SIZE/4; i++) {
> +		pci_read_config_dword(hldev->pdev, i * 4,
> +				(u32 *)&hldev->pci_config_space_bios  +  i);
> +	}

Since you only change two bits in the command register, maybe you shoul=
d
just save those bits.  Or not bother.

> +	__hw_device_pci_caps_list_process(hldev);
> +
> +	/* Set the PErr Repconse bit and SERR in PCI command register. */
> +	pci_read_config_word(hldev->pdev,
> +			vxge_offsetof(struct vxge_hw_pci_config_le, command),
> +			&cmd);
> +	cmd |=3D 0x140;
> +	pci_write_config_word(hldev->pdev,
> +			vxge_offsetof(struct vxge_hw_pci_config_le, command),
> +			cmd);
> +
> +	/* save PCI config space for future resets */
> +	for (i =3D 0; i < VXGE_HW_PCI_CONFIG_SPACE_SIZE/4; i++) {
> +		pci_read_config_dword(hldev->pdev, i * 4,
> +					(u32 *)&hldev->pci_config_space  +  i);
> +	}
=EF=BB=BF
=EF=BB=BFYou should use pci_save_state() and pci_restore_state() around=
 resets
instead.

> +	return;
> +}
> +
> +/*
> + * __hw_device_register_poll
> + * @reg: register to poll for
> + * @op: 0 - bit reset, 1 - bit set
> + * @mask: mask for logical "and" condition based on %op
> + * @max_millis: maximum time to try to poll in milliseconds
> + *
> + * Will poll certain register for specified amount of time.
> + * Will poll until masked bit is not cleared.
> + */
> +enum vxge_hw_status
> +__hw_device_register_poll(u64		*reg,
> +			u32		op,
> +			u64		mask,
> +			u32		max_millis)
> +{
> +	u64 val64;
> +	u32 i =3D 0;
> +	enum vxge_hw_status ret =3D VXGE_HW_FAIL;
> +
> +	vxge_os_udelay(10);
> +
> +	do {
> +		val64 =3D readq(reg);
> +		if (op =3D=3D 0 && !(val64 & mask))
> +			return VXGE_HW_OK;
> +		else if (op =3D=3D 1 && (val64 & mask) =3D=3D mask)
> +			return VXGE_HW_OK;
> +		vxge_os_udelay(100);

udelay(100)

> +	} while (++i <=3D 9);

You need to reset i to 0 or 1 after this, since you've waited 910 us no=
t
9 ms.

> +	do {
> +		val64 =3D readq(reg);
> +		if (op =3D=3D 0 && !(val64 & mask))
> +			return VXGE_HW_OK;
> +		else if (op =3D=3D 1 && (val64 & mask) =3D=3D mask)
> +			return VXGE_HW_OK;
> +		vxge_os_udelay(1000);

mdelay(1)

> +	} while (++i < max_millis);

This should probably be a while() not a do...while().

> +	return ret;
> +}
> +
> +/*
> + * __hw_device_toc_get
> + * @bar0: Address of BAR0 in PCI config
> + *
> + * This routine sets the sapper and reads the toc pointer and return=
s the

Based on the function call below I'm guessing "sapper" should be
"swapper".

> + * memory mapped address of the toc
> + */
> +struct vxge_hw_toc_reg *
> +__hw_device_toc_get(u8 *bar0)
> +{
> +	u64 val64;
> +	struct vxge_hw_toc_reg *toc =3D NULL;
> +	enum vxge_hw_status status;
> +	struct vxge_hw_legacy_reg *legacy_reg =3D
> +		(struct vxge_hw_legacy_reg *)bar0;
> +
> +	status =3D __hw_legacy_swapper_set(legacy_reg);
> +	if (status !=3D VXGE_HW_OK)
> +		goto exit;
> +
> +	val64 =3D	readq(&legacy_reg->toc_first_pointer);
> +
> +	toc =3D (struct vxge_hw_toc_reg *)(bar0+val64);
> +
> +exit:
> +
> +	return toc;
> +}
> +
> +/*
> + * __hw_device_reg_addr_get
> + * @hldev: HW Device object.
> + *
> + * This routine sets the swapper and reads the toc pointer and initi=
alizes the
> + * register location pointers in the device object. It waits until t=
he ric is
> + * completed initializing registers.
> + */
> +enum vxge_hw_status
> +__hw_device_reg_addr_get(struct __hw_device *hldev)
> +{
> +	u64 val64;
> +	u32 i;
> +	enum vxge_hw_status status =3D VXGE_HW_OK;
> +
> +	vxge_assert(hldev);
> +
> +	hldev->legacy_reg =3D (struct vxge_hw_legacy_reg *)hldev->bar0;
> +
> +	hldev->toc_reg =3D __hw_device_toc_get(hldev->bar0);
> +	if (hldev->toc_reg  =3D=3D NULL) {
> +		status =3D VXGE_HW_FAIL;
> +		goto exit;
> +	}
> +
> +	val64 =3D readq(&hldev->toc_reg->toc_common_pointer);
> +
> +	hldev->common_reg =3D
> +		(struct vxge_hw_common_reg *)(hldev->bar0  +  val64);
> +
> +	val64 =3D readq(&hldev->toc_reg->toc_memrepair_pointer);
> +
> +	hldev->memrepair_reg =3D
> +		(struct vxge_hw_memrepair_reg *)(hldev->bar0  +  val64);
> +
> +	for (i =3D 0; i < VXGE_HW_TITAN_PCICFGMGMT_REG_SPACES; i++) {
> +
> +		val64 =3D readq(&hldev->toc_reg->toc_pcicfgmgmt_pointer[i]);
> +
> +		hldev->pcicfgmgmt_reg[i] =3D (struct vxge_hw_pcicfgmgmt_reg *) \
> +						(hldev->bar0  +  val64);
> +
> +	}

This function

might have=20

too much

vertical whitespace.

[...]
> +/**
> + * __hw_device_get_vpd_data - Getting vpd_data.
> + *
> + *   @hldev: HW device handle.
> + *
> + *   Getting  product name and serial number from vpd capabilites st=
ructure
> + *
> + */
> +void
> +__hw_device_get_vpd_data(struct __hw_device *hldev)
> +{
> +	u8   *vpd_data;
> +	u16  data;
> +	u32  data32;
> +	u32  index =3D 0, i, count, fail =3D 0;
> +	u32  addr_offset;
> +	u32  data_offset;
> +	u32  max_count =3D hldev->config.device_poll_millis * 10;
> +
> +	vxge_assert(hldev);
> +
> +	addr_offset =3D hldev->pci_caps.vpd_cap_offset  +
> +		vxge_offsetof(struct vxge_hw_vpid_capability_le, vpd_address);
> +
> +	data_offset =3D hldev->pci_caps.vpd_cap_offset  +
> +		vxge_offsetof(struct vxge_hw_vpid_capability_le, vpd_data);
> +	strcpy((char *) hldev->vpd_data.product_name,
> +		"10 Gigabit Ethernet Adapter");
> +
> +	strcpy((char *) hldev->vpd_data.serial_num, "not available");
> +
> +	if ((hldev->host_type !=3D VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION) ||
> +			(hldev->func_id !=3D 0)) {
> +		strcpy((char *) hldev->vpd_data.serial_num,
> +				"not supported");
> +		strcpy((char *) hldev->vpd_data.product_name,
> +				"not supported");
> +		return;
> +	}
> +	vpd_data =3D (u8 *) vmalloc(VXGE_HW_VPD_BUFFER_SIZE  +  16);
> +	if (vpd_data =3D=3D 0)
> +		return;
> +	for (index =3D 0; index < VXGE_HW_VPD_BUFFER_SIZE; index +=3D 4) {

Use pci_read_vpd() instead of this loop.

[...]
> +/*
> + * vxge_hw_wrr_rebalance - Rebalance the RX_WRR and KDFC_WRR calanda=
rs.
> + * @devh: HW device handle.
> + *
> + * Rebalance the RX_WRR and KDFC_WRR calandars.
> + *
> + */
> +enum vxge_hw_status vxge_hw_wrr_rebalance(struct __hw_device *hldev)
> +{
> +	u64 val64;
> +	u32 calender[176];
[...]

Why 176?  This value should have at least a comment, but preferably a
name or explicit formula.

Also should this variable be called "calendar"?

This is as far as I got.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

