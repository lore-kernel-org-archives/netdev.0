From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next 2/4] bnx2x: add additional regions for CRC
 memory test
Date: Fri, 19 Apr 2013 01:15:15 +0200
Message-ID: <20130418231515.GB10380@electric-eye.fr.zoreil.com>
References: <1366280830-26034-1-git-send-email-dmitry@broadcom.com>
 <1366280830-26034-3-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56781 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab3DRXPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 19:15:21 -0400
Content-Disposition: inline
In-Reply-To: <1366280830-26034-3-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Kravkov <dmitry@broadcom.com> :
[...]
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> index e7e0ac1..65ac870 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
> @@ -2593,14 +2593,138 @@ static int bnx2x_test_ext_loopback(struct bnx2x *bp)
>  	return rc;
>  }
>  
> +struct code_entry {
> +	u32 sram_start_addr;
> +	u32 code_attribute;
> +#define CODE_IMAGE_TYPE_MASK			0xf0800003
> +#define CODE_IMAGE_VNTAG_PROFILES_DATA		0xd0000003
> +#define CODE_IMAGE_LENGTH_MASK			0x007ffffc
> +#define CODE_IMAGE_TYPE_EXTENDED_DIR		0xe0000000
> +	u32 nvm_start_addr;
> +};
> +
> +#define CODE_ENTRY_MAX			16
> +#define CODE_ENTRY_EXTENDED_DIR_IDX	15
> +#define MAX_IMAGES_IN_EXTENDED_DIR	64
> +
>  #define CRC32_RESIDUAL			0xdebb20e3
> +#define CRC_BUFF_SIZE			256
> +
> +static int bnx2x_nvram_crc(struct bnx2x *bp,
> +			   int offset,
> +			   int size,
> +			   u8 *buff)

static int bnx2x_nvram_crc(struct bnx2x *bp, int offset, int size, u8 *buff)

> +{
> +	u32 crc = ~0;
> +	int done = 0;
> +
> +	DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
> +	   "NVRAM CRC from 0x%08x to 0x%08x\n", offset, offset + size);
> +
> +	while (done < size) {
> +		int count = min_t(int, size - done, CRC_BUFF_SIZE);
> +
> +		if (bnx2x_nvram_read(bp, offset + done, buff, count))
> +			return -EIO;

You may propagate the status code from bnx2x_nvram_read.

> +		crc = crc32_le(crc, buff, count);
> +		done += count;
> +	}
> +
> +	if (crc != CRC32_RESIDUAL)
> +		return -EINVAL;
> +
> +	return 0;

A ternary operator could be used. Your choice of style.

> +}
> +
> +static int bnx2x_test_nvram_dir(struct bnx2x *bp,
> +				struct code_entry *entry,
> +				u8 *buff)
> +{
> +	size_t size = entry->code_attribute & CODE_IMAGE_LENGTH_MASK;
> +	u32 type = entry->code_attribute & CODE_IMAGE_TYPE_MASK;
> +	int rc = 0;

Useless init.

> +
> +	/* Zero-length images and AFEX profiles do not have CRC */
> +	if (size == 0 || type == CODE_IMAGE_VNTAG_PROFILES_DATA)
> +		return 0;
> +
> +	rc = bnx2x_nvram_crc(bp, entry->nvm_start_addr, size, buff);
> +	if (rc == -EIO)
> +		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
> +		   "Unable to read image %x\n", type);
> +	else if (rc)
> +		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
> +		   "image %x has wrong crc value\n", type);

It's a bit ugly.

bnx2x_nvram_crc perfectly knowns if a read failure or a crc problem
happened. It can print messages and you won't need to analyze the 
failure status. You may still print some different message in its
callers (here and bnx2x_test_nvram_tbl).

I must stop here, sorry.

-- 
Ueimor
