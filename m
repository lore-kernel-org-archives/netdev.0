From: Vladimir Kondratiev <qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] wil6210: Fix potential memory leaks on error paths
Date: Sun, 30 Nov 2014 10:28:39 +0200
Message-ID: <3345120.HXl93bohCX@lx-wigig-72>
References: <1417139239-32602-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<ahmedtamrawi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417139239-32602-1-git-send-email-LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday, November 28, 2014 02:47:19 AM Lino Sanfilippo wrote:
> Fix missing memory deallocation on error paths in wil_write_file_wmi()
> and wil_write_file_txmgmt().
> 
> Reported-by: Ahmed Tamrawi <ahmedtamrawi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
> ---
>  drivers/net/wireless/ath/wil6210/debugfs.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/wil6210/debugfs.c b/drivers/net/wireless/ath/wil6210/debugfs.c
> index 54a6ddc..4e6e145 100644
> --- a/drivers/net/wireless/ath/wil6210/debugfs.c
> +++ b/drivers/net/wireless/ath/wil6210/debugfs.c
> @@ -573,8 +573,10 @@ static ssize_t wil_write_file_txmgmt(struct file *file, const char __user *buf,
>  	if (!frame)
>  		return -ENOMEM;
>  
> -	if (copy_from_user(frame, buf, len))
> +	if (copy_from_user(frame, buf, len)) {
> +		kfree(frame);
>  		return -EIO;
> +	}
>  
>  	params.buf = frame;
>  	params.len = len;
> @@ -614,8 +616,10 @@ static ssize_t wil_write_file_wmi(struct file *file, const char __user *buf,
>  		return -ENOMEM;
>  
>  	rc = simple_write_to_buffer(wmi, len, ppos, buf, len);
> -	if (rc < 0)
> +	if (rc < 0) {
> +		kfree(wmi);
>  		return rc;
> +	}
>  
>  	cmd = &wmi[1];
>  	cmdid = le16_to_cpu(wmi->id);
> 

Lino and Ahmed: thanks for that. Here is my
Signed-off-by: Vladimir Kondratiev <qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>

John: please merge
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
