From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v2] ath6kl: Use vmalloc to allocate ar->fw for api1 method
Date: Wed, 02 Dec 2015 05:20:33 -0800
Message-ID: <1449062433.32764.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1449029898-15209-1-git-send-email-motobud@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kvalo@qca.qualcomm.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath6kl@lists.infradead.org
To: Brent Taylor <motobud@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449029898-15209-1-git-send-email-motobud@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-12-01 at 22:18 -0600, Brent Taylor wrote:
> Since commit 8437754c8335 ("ath6kl: Use vmalloc instead of kmalloc for
> fw") ar->fw is expected to be pointing to memory allocated by vmalloc.
> If the api1 method (via ath6kl_fetch_fw_api1) is used to allocate memory
> for ar->fw, then kmemdup is used.  This patch checks if the firmware being
> loaded is the 'fw' image, then use vmalloc, otherwise use kmalloc.
> 
> Signed-off-by: Brent Taylor <motobud@gmail.com>
> ---
> v2: Fix commit message and code formatting (use tab instaed of spaces)
> 
>  drivers/net/wireless/ath/ath6kl/init.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
> index 6ae0734..4f16bd8 100644
> --- a/drivers/net/wireless/ath/ath6kl/init.c
> +++ b/drivers/net/wireless/ath/ath6kl/init.c
> @@ -673,10 +673,15 @@ static int ath6kl_get_fw(struct ath6kl *ar, const char *filename,
>  		return ret;
>  
>  	*fw_len = fw_entry->size;
> -	*fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
> +	if (&ar->fw == fw)
> +		*fw = vmalloc(fw_entry->size);
> +	else
> +		*fw = kmalloc(fw_entry->size, GFP_KERNEL);
>  
>  	if (*fw == NULL)
>  		ret = -ENOMEM;
> +	else
> +		memcpy(*fw, fw_entry->data, fw_entry->size);
>  
>  	release_firmware(fw_entry);
>  

This looks very odd.

Why not using kvfree() in ath6kl_core_cleanup() ?

If you switch to vmalloc() here because the kmemdup() was potentially
failing, then the changelog should say it !

Using vmalloc() instead of kmalloc() should be driven by the allocation
size, not the legacy code doing the freeing.
