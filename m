From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 01/10] qed: Add module with basic common
 support
Date: Sat, 24 Oct 2015 05:11:49 -0700 (PDT)
Message-ID: <20151024.051149.1911984823506391327.davem@davemloft.net>
References: <1445490417-8845-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1445490417-8845-2-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbbJXLzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 07:55:17 -0400
In-Reply-To: <1445490417-8845-2-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 22 Oct 2015 08:06:48 +0300

> diff --git a/drivers/net/ethernet/qlogic/qed/Makefile b/drivers/net/ethernet/qlogic/qed/Makefile
> new file mode 100644
> index 0000000..5bbe0c7
> --- /dev/null
> +++ b/drivers/net/ethernet/qlogic/qed/Makefile
> @@ -0,0 +1,3 @@
> +obj-$(CONFIG_QED) := qed.o
> +
> +qed-y := qed_cxt.o qed_dev.o qed_hw.o qed_init_fw_funcs.o qed_init_ops.o qed_int.o qed_main.o qed_mcp.o qed_sp_commands.o qed_spq.o

Please break this qed-y assignment into multiple lines using "\".

> +#ifndef _QED_H
> +#define _QED_H
> +#include <linux/types.h>

Please put an empty line after "#define _QED_H"

> +/* helpers */
> +static inline u32 DB_ADDR(u32 cid, u32 DEMS)
> +{
> +	u32 db_addr = FIELD_VALUE(DB_LEGACY_ADDR_DEMS, DEMS) |
> +		      FIELD_VALUE(DB_LEGACY_ADDR_ICID, cid);
> +
> +	return db_addr;
> +}

Generally speaking, inline functions should be named with lowercase
letters, CPP macros that act like functions can be uppercase.

> +#define MAP_WORD_SIZE sizeof(unsigned long)
> +#define BITS_PER_MAP_WORD (MAP_WORD_SIZE * 8)

Please don't reimplement something as fundamental as a bitmap of words, use
the faciltiies and helpers in linux/bitmap.h instead.

> +/* counts the iids for the CDU/CDUC ILT client configuration */
> +struct qed_cdu_iids {
> +	u32	pf_cids;
> +};

This one member structure is excessive, it's only ever instantiated
as a local variable in this file, so just use "u32" directly.

> +	p_info->p_cxt = (u8 *)p_mngr->ilt_shadow[line].p_virt +
> +			      p_info->iid % cxts_per_p * conn_cxt_size;

p_virt is a void pointer, therefore you don't need to cast it to have
arithmatic on it work properly.

> +	if (qed_mcp_is_init(p_hwfn)) {
> +		ether_addr_copy(p_hwfn->hw_info.hw_mac_addr,
> +				p_hwfn->mcp_info->func_info.mac);
> +	} else {
> +		static u8 mcp_hw_mac[6] = { 0, 2, 3, 4, 5, 6 };
> +
> +		ether_addr_copy(p_hwfn->hw_info.hw_mac_addr, mcp_hw_mac);
> +		p_hwfn->hw_info.hw_mac_addr[5] = p_hwfn->abs_pf_id;
> +	}

In this else branch you should probably use a random ethernet address.
If that is not correct here, this is not expected and requires a
detailed comment explaining why this fixed ethernet address is being
used.

> +static int qed_get_dev_info(struct qed_dev *cdev)
 ...
> +	return 0;

This never returns anything other than zero, make it return void.

> +int qed_hw_prepare(struct qed_dev	*cdev,
> +		   int			personality)

Please do not declare function variables with tab characters
separating the type from the variable name.  Likewise when these
functions are externally declared in header files.

> +		void __iomem *p_regview, *p_doorbell;
> +
> +		p_regview = (void __iomem *)
> +			    ((u8 __iomem *)cdev->regview + i *

Again, void pointers do not need to be cast to "u8 *" in order
to perform byte arithmatic on them.
