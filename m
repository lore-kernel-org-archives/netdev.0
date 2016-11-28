From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: hns: Fix to conditionally convey RX
 checksum flag to stack
Date: Mon, 28 Nov 2016 12:12:40 -0500 (EST)
Message-ID: <20161128.121240.1321057221950786765.davem@davemloft.net>
References: <20161125133240.1264224-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932669AbcK1RMm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:12:42 -0500
In-Reply-To: <20161125133240.1264224-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salil Mehta <salil.mehta@huawei.com>
Date: Fri, 25 Nov 2016 13:32:40 +0000

> @@ -778,6 +778,35 @@ int hns_ae_get_regs_len(struct hnae_handle *handle)
>  	return total_num;
>  }
>  
> +static bool hns_ae_is_l3l4_csum_err(struct hnae_handle *handle)
> +{
> +	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
> +	u32 regval;
> +	bool retval = false;
> +
> +	/* read PPE_HIS_PRO_ERR register and check for the checksum errors */
> +	regval = dsaf_read_dev(ppe_cb, PPE_HIS_PRO_ERR_REG);
> +

I don't see how a single register can properly provide error status for a ring
of pending received packets.

No matter how this register is implemented, it is either going to result in
packets erroneously being marked as having errors, or error status being
lost when multiple packets in a row have such errors.

For example, if you receive several packets in a row that have errors,
you'll read this register for the first one.  If this read clears the error
status, which I am guessing it does, then you won't see the error status
for the next packet that had one of these errors as well.

If you don't have something which is provided on a per-packet basis
then you can't determine the error properly.  Therefore you will just
have to always ignore the checksum if there is any error indicated in
the ring descriptor.
