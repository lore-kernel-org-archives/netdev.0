From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v7 4/8] thunderbolt: Communication with the ICM (firmware)
Date: Tue, 27 Sep 2016 16:11:15 +0200
Message-ID: <20160927141115.GB21133@kroah.com>
References: <1474983821-2313-1-git-send-email-amir.jer.levy@intel.com>
 <1474983821-2313-5-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37037 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933380AbcI0OLZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 10:11:25 -0400
Content-Disposition: inline
In-Reply-To: <1474983821-2313-5-git-send-email-amir.jer.levy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 04:43:37PM +0300, Amir Levy wrote:
> This patch provides the communication protocol between the
> Intel Connection Manager(ICM) firmware that is operational in the
> Thunderbolt controller in non-Apple hardware.
> The ICM firmware-based controller is used for establishing and maintaining
> the Thunderbolt Networking connection - we need to be able to communicate
> with it.
> 
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> ---
>  drivers/thunderbolt/Makefile      |    1 +
>  drivers/thunderbolt/icm/Makefile  |    2 +
>  drivers/thunderbolt/icm/icm_nhi.c | 1324 +++++++++++++++++++++++++++++++++++++
>  drivers/thunderbolt/icm/icm_nhi.h |   92 +++
>  drivers/thunderbolt/icm/net.h     |  227 +++++++
>  5 files changed, 1646 insertions(+)
>  create mode 100644 drivers/thunderbolt/icm/Makefile
>  create mode 100644 drivers/thunderbolt/icm/icm_nhi.c
>  create mode 100644 drivers/thunderbolt/icm/icm_nhi.h
>  create mode 100644 drivers/thunderbolt/icm/net.h
> 
> diff --git a/drivers/thunderbolt/Makefile b/drivers/thunderbolt/Makefile
> index 7a85bd1..b6aa6a3 100644
> --- a/drivers/thunderbolt/Makefile
> +++ b/drivers/thunderbolt/Makefile
> @@ -1,3 +1,4 @@
>  obj-${CONFIG_THUNDERBOLT_APPLE} := thunderbolt.o
>  thunderbolt-objs := nhi.o ctl.o tb.o switch.o cap.o path.o tunnel_pci.o eeprom.o
>  
> +obj-${CONFIG_THUNDERBOLT_ICM} += icm/
> diff --git a/drivers/thunderbolt/icm/Makefile b/drivers/thunderbolt/icm/Makefile
> new file mode 100644
> index 0000000..f0d0fbb
> --- /dev/null
> +++ b/drivers/thunderbolt/icm/Makefile
> @@ -0,0 +1,2 @@
> +obj-${CONFIG_THUNDERBOLT_ICM} += thunderbolt-icm.o
> +thunderbolt-icm-objs := icm_nhi.o
> diff --git a/drivers/thunderbolt/icm/icm_nhi.c b/drivers/thunderbolt/icm/icm_nhi.c
> new file mode 100644
> index 0000000..984aa7c
> --- /dev/null
> +++ b/drivers/thunderbolt/icm/icm_nhi.c
> @@ -0,0 +1,1324 @@
> +/*******************************************************************************
> + *
> + * Intel Thunderbolt(TM) driver
> + * Copyright(c) 2014 - 2016 Intel Corporation.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program.  If not, see <http://www.gnu.org/licenses/>.

Why is this sentence needed?

> + *
> + * The full GNU General Public License is included in this distribution in
> + * the file called "COPYING".

Why is this sentence needed?

> + *
> + * Contact Information:
> + * Intel Thunderbolt Mailing List <thunderbolt-software@lists.01.org>

Shouldn't this just be in the MAINTAINERS file?

> + * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497

Unless you are going to track the address of Intel for the next 40+
years, don't put it in a source comment.  Please just drop it.

> + *
> + ******************************************************************************/
> +
> +#include <linux/printk.h>
> +#include <linux/crc32.h>
> +#include <linux/delay.h>
> +#include <linux/dmi.h>
> +#include "icm_nhi.h"
> +#include "net.h"
> +
> +#define NHI_GENL_VERSION 1
> +#define NHI_GENL_NAME "thunderbolt"
> +
> +#define DEVICE_DATA(num_ports, dma_port, nvm_ver_offset, nvm_auth_on_boot,\
> +		    support_full_e2e) \
> +	((num_ports) | ((dma_port) << 4) | ((nvm_ver_offset) << 10) | \
> +	 ((nvm_auth_on_boot) << 22) | ((support_full_e2e) << 23))
> +#define DEVICE_DATA_NUM_PORTS(device_data) ((device_data) & 0xf)
> +#define DEVICE_DATA_DMA_PORT(device_data) (((device_data) >> 4) & 0x3f)
> +#define DEVICE_DATA_NVM_VER_OFFSET(device_data) (((device_data) >> 10) & 0xfff)
> +#define DEVICE_DATA_NVM_AUTH_ON_BOOT(device_data) (((device_data) >> 22) & 0x1)
> +#define DEVICE_DATA_SUPPORT_FULL_E2E(device_data) (((device_data) >> 23) & 0x1)
> +
> +#define USEC_TO_256_NSECS(usec) DIV_ROUND_UP((usec) * NSEC_PER_USEC, 256)
> +
> +/* NHI genetlink commands */
> +enum {
> +	NHI_CMD_UNSPEC,
> +	NHI_CMD_SUBSCRIBE,
> +	NHI_CMD_UNSUBSCRIBE,
> +	NHI_CMD_QUERY_INFORMATION,
> +	NHI_CMD_MSG_TO_ICM,
> +	NHI_CMD_MSG_FROM_ICM,
> +	NHI_CMD_MAILBOX,
> +	NHI_CMD_APPROVE_TBT_NETWORKING,
> +	NHI_CMD_ICM_IN_SAFE_MODE,
> +	__NHI_CMD_MAX,
> +};
> +#define NHI_CMD_MAX (__NHI_CMD_MAX - 1)
> +
> +/* NHI genetlink policy */
> +static const struct nla_policy nhi_genl_policy[NHI_ATTR_MAX + 1] = {
> +	[NHI_ATTR_DRV_VERSION]		= { .type = NLA_NUL_STRING, },
> +	[NHI_ATTR_NVM_VER_OFFSET]	= { .type = NLA_U16, },
> +	[NHI_ATTR_NUM_PORTS]		= { .type = NLA_U8, },
> +	[NHI_ATTR_DMA_PORT]		= { .type = NLA_U8, },
> +	[NHI_ATTR_SUPPORT_FULL_E2E]	= { .type = NLA_FLAG, },
> +	[NHI_ATTR_MAILBOX_CMD]		= { .type = NLA_U32, },
> +	[NHI_ATTR_PDF]			= { .type = NLA_U32, },
> +	[NHI_ATTR_MSG_TO_ICM]		= { .type = NLA_BINARY,
> +					.len = TBT_ICM_RING_MAX_FRAME_SIZE },
> +	[NHI_ATTR_MSG_FROM_ICM]		= { .type = NLA_BINARY,
> +					.len = TBT_ICM_RING_MAX_FRAME_SIZE },
> +};
> +
> +/* NHI genetlink family */
> +static struct genl_family nhi_genl_family = {
> +	.id		= GENL_ID_GENERATE,
> +	.hdrsize	= FIELD_SIZEOF(struct tbt_nhi_ctxt, id),
> +	.name		= NHI_GENL_NAME,
> +	.version	= NHI_GENL_VERSION,
> +	.maxattr	= NHI_ATTR_MAX,
> +};
> +
> +static LIST_HEAD(controllers_list);
> +static DEFINE_MUTEX(controllers_list_mutex);
> +static atomic_t subscribers = ATOMIC_INIT(0);
> +static u32 portid;

This is really odd, why have a global single portid?

> +
> +static bool nhi_nvm_authenticated(struct tbt_nhi_ctxt *nhi_ctxt)
> +{
> +	enum icm_operation_mode op_mode;
> +	u32 *msg_head, port_id, reg;
> +	struct sk_buff *skb;
> +	int i;
> +
> +	if (!nhi_ctxt->nvm_auth_on_boot)
> +		return true;
> +
> +	/*
> +	 * The check for NVM authentication can take time for iCM,
> +	 * especially in low power configuration.
> +	 */
> +	for (i = 0; i < 5; i++) {
> +		u32 status = ioread32(nhi_ctxt->iobase + REG_FW_STS);
> +
> +		if (status & REG_FW_STS_NVM_AUTH_DONE)
> +			break;
> +
> +		msleep(30);
> +	}
> +	/*
> +	 * The check for authentication is done after checking if iCM
> +	 * is present so it shouldn't reach the max tries (=5).
> +	 * Anyway, the check for full functionality below covers the error case.
> +	 */
> +	reg = ioread32(nhi_ctxt->iobase + REG_OUTMAIL_CMD);
> +	op_mode = (reg & REG_OUTMAIL_CMD_OP_MODE_MASK) >>
> +		  REG_OUTMAIL_CMD_OP_MODE_SHIFT;
> +	if (op_mode == FULL_FUNCTIONALITY)
> +		return true;
> +
> +	dev_warn(&nhi_ctxt->pdev->dev, "controller id %#x is in operation mode %#x status %#lx\n",
> +		 nhi_ctxt->id, op_mode,
> +		 (reg & REG_OUTMAIL_CMD_STS_MASK)>>REG_OUTMAIL_CMD_STS_SHIFT);
> +
> +	skb = genlmsg_new(NLMSG_ALIGN(nhi_genl_family.hdrsize), GFP_KERNEL);
> +	if (!skb) {
> +		dev_err(&nhi_ctxt->pdev->dev, "genlmsg_new failed: not enough memory to send controller operational mode\n");
> +		return false;
> +	}
> +
> +	/* keeping port_id into a local variable for next use */
> +	port_id = portid;
> +	msg_head = genlmsg_put(skb, port_id, 0, &nhi_genl_family, 0,
> +			       NHI_CMD_ICM_IN_SAFE_MODE);
> +	if (!msg_head) {
> +		nlmsg_free(skb);
> +		dev_err(&nhi_ctxt->pdev->dev, "genlmsg_put failed: not enough memory to send controller operational mode\n");
> +		return false;
> +	}
> +
> +	*msg_head = nhi_ctxt->id;
> +
> +	genlmsg_end(skb, msg_head);
> +
> +	genlmsg_unicast(&init_net, skb, port_id);
> +
> +	return false;
> +}
> +
> +int nhi_send_message(struct tbt_nhi_ctxt *nhi_ctxt, enum pdf_value pdf,
> +		     u32 msg_len, const void *msg, bool ignore_icm_resp)
> +{
> +	u32 prod_cons, prod, cons, attr;
> +	struct tbt_icm_ring_shared_memory *shared_mem;
> +	void __iomem *reg = TBT_RING_CONS_PROD_REG(nhi_ctxt->iobase,
> +						   REG_TX_RING_BASE,
> +						   TBT_ICM_RING_NUM);
> +
> +	dev_dbg(&nhi_ctxt->pdev->dev,
> +		"send msg: controller id %#x pdf %u cmd %hhu msg len %u\n",
> +		nhi_ctxt->id, pdf, ((u8 *)msg)[3], msg_len);

Don't put trace debug calls in your code, either use a real tracepoint,
or just use ftrace.  Delete these, they aren't needed once you want to
submit the code for merging as it should not be needed.

You do this in a lot of other places as well, please fix all of them.

> +
> +	if (nhi_ctxt->d0_exit) {
> +		dev_notice(&nhi_ctxt->pdev->dev,
> +			   "controller id %#x is exiting D0\n",
> +			   nhi_ctxt->id);

What can a user do about this?


> +		return -ENODEV;
> +	}
> +
> +	prod_cons = ioread32(reg);
> +	prod = TBT_REG_RING_PROD_EXTRACT(prod_cons);
> +	cons = TBT_REG_RING_CONS_EXTRACT(prod_cons);
> +	if (prod >= TBT_ICM_RING_NUM_TX_BUFS) {
> +		dev_warn(&nhi_ctxt->pdev->dev,
> +			 "controller id %#x producer %u out of range\n",
> +			 nhi_ctxt->id, prod);

What can a user do about this?

> +		return -ENODEV;
> +	}
> +	if (TBT_TX_RING_FULL(prod, cons, TBT_ICM_RING_NUM_TX_BUFS)) {
> +		dev_err(&nhi_ctxt->pdev->dev,
> +			"controller id %#x TX ring full\n",
> +			nhi_ctxt->id);

What can a user do about this?

> +		return -ENOSPC;
> +	}
> +
> +	attr = (msg_len << DESC_ATTR_LEN_SHIFT) & DESC_ATTR_LEN_MASK;
> +	attr |= (pdf << DESC_ATTR_EOF_SHIFT) & DESC_ATTR_EOF_MASK;
> +
> +	shared_mem = nhi_ctxt->icm_ring_shared_mem;
> +	shared_mem->tx_buf_desc[prod].attributes = cpu_to_le32(attr);
> +
> +	memcpy(shared_mem->tx_buf[prod], msg, msg_len);

No zero-copy, sad :(

> +
> +	prod_cons &= ~REG_RING_PROD_MASK;
> +	prod_cons |= (((prod + 1) % TBT_ICM_RING_NUM_TX_BUFS) <<
> +		      REG_RING_PROD_SHIFT) & REG_RING_PROD_MASK;
> +
> +	if (likely(!nhi_ctxt->wait_for_icm_resp))
> +		nhi_ctxt->wait_for_icm_resp = true;

Can you measure the speed difference with likely() here?  If so, great,
if not, drop it as the cpu can guess this better than you or I can.

> +	else
> +		dev_dbg(&nhi_ctxt->pdev->dev,
> +			"controller id %#x wait_for_icm_resp should have been cleared\n",
> +			nhi_ctxt->id);

Huh?  So this isn't a real issue?

> +
> +	nhi_ctxt->ignore_icm_resp = ignore_icm_resp;
> +
> +	iowrite32(prod_cons, reg);
> +
> +	return 0;
> +}

thanks,

greg k-h
