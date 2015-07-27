From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: Re: [PATCH] rsi: Fix failure to load firmware after memory leak fix
 and fix the leak
Date: Mon, 27 Jul 2015 14:55:09 +0700
Message-ID: <55B5E3DD.303@ispras.ru>
References: <1437975813-3285-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Mike Looijmans <mike.looijmans@topic.nl>,
	linux-wireless@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1437975813-3285-1-git-send-email-mike.looijmans@topic.nl>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reviewed-by: Alexey Khoroshilov <khoroshilov@ispras.ru> with small
suggestion. If we restore kmemdup() call, we have to handle ENOMEM
situations:

	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
	if (!fw)
		return -ENOMEM;


On 27.07.2015 12:43, Mike Looijmans wrote:
> Fixes commit eae79b4f3e82ca63a53478a161b190a0d38fe526 ("rsi: fix memory leak
> in rsi_load_ta_instructions()") which stopped the driver from functioning.
> 
> Firmware data has been allocated using vmalloc(), resulting in memory
> that cannot be used for DMA. Hence the firmware was first copied to a
> buffer allocated with kmalloc() in the original code. This patch reverts
> the commit and only calls "kfree()" to release the buffer after sending
> the data. This fixes the memory leak without breaking the driver.
> 
> Add a comment to the kmemdup() calls to explain why this is done.
> 
> Tested on a Topic Miami-Florida board which contains the rsi SDIO chip.
> 
> Also added the same kfree() call to the USB glue driver. This was not
> tested on actual hardware though, as I only have the SDIO version.
> 
> Signed-off-by: Mike Looijmans <mike.looijmans@topic.nl>
> Cc: stable@vger.kernel.org
> ---
>  drivers/net/wireless/rsi/rsi_91x_sdio_ops.c | 6 +++++-
>  drivers/net/wireless/rsi/rsi_91x_usb_ops.c  | 2 ++
>  2 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
> index b6cc9ff..5c37a71 100644
> --- a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
> +++ b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
> @@ -172,6 +172,7 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
>  		(struct rsi_91x_sdiodev *)adapter->rsi_dev;
>  	u32 len;
>  	u32 num_blocks;
> +	const u8 *fw;
>  	const struct firmware *fw_entry = NULL;
>  	u32 block_size = dev->tx_blk_size;
>  	int status = 0;
> @@ -200,6 +201,8 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
>  		return status;
>  	}
>  
> +	/* Copy firmware into DMA-accessible memory */
> +	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
>  	len = fw_entry->size;
>  
>  	if (len % 4)
> @@ -210,7 +213,8 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
>  	rsi_dbg(INIT_ZONE, "%s: Instruction size:%d\n", __func__, len);
>  	rsi_dbg(INIT_ZONE, "%s: num blocks: %d\n", __func__, num_blocks);
>  
> -	status = rsi_copy_to_card(common, fw_entry->data, len, num_blocks);
> +	status = rsi_copy_to_card(common, fw, len, num_blocks);
> +	kfree(fw);
>  	release_firmware(fw_entry);
>  	return status;
>  }
> diff --git a/drivers/net/wireless/rsi/rsi_91x_usb_ops.c b/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
> index 1106ce7..088e28e 100644
> --- a/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
> +++ b/drivers/net/wireless/rsi/rsi_91x_usb_ops.c
> @@ -146,6 +146,7 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
>  		return status;
>  	}
>  
> +	/* Copy firmware into DMA-accessible memory */
>  	fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
>  	len = fw_entry->size;
>  
> @@ -158,6 +159,7 @@ static int rsi_load_ta_instructions(struct rsi_common *common)
>  	rsi_dbg(INIT_ZONE, "%s: num blocks: %d\n", __func__, num_blocks);
>  
>  	status = rsi_copy_to_card(common, fw, len, num_blocks);
> +	kfree(fw);
>  	release_firmware(fw_entry);
>  	return status;
>  }
> 
