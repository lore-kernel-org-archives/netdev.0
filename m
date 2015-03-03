From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ath9k_htc: avoid memcpy when downloading firmware
Date: Mon, 02 Mar 2015 22:00:07 -0800
Message-ID: <1425362407.5130.161.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425356643-2707-1-git-send-email-fred.chou.nd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ath9k-devel@qca.qualcomm.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Fred Chou <fred.chou.nd@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425356643-2707-1-git-send-email-fred.chou.nd@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 12:24 +0800, Fred Chou wrote:
> From: Fred Chou <fred.chou.nd@gmail.com>
> 
> The temporary buffer to hold firmware data is not really needed,
> and memcpy can be avoided by using data pointer instead.
> 
> Signed-off-by: Fred Chou <fred.chou.nd@gmail.com>
> ---
>  drivers/net/wireless/ath/ath9k/hif_usb.c | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
> index 10c02f5..0bc35a8 100644
> --- a/drivers/net/wireless/ath/ath9k/hif_usb.c
> +++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
> @@ -986,30 +986,22 @@ static int ath9k_hif_usb_download_fw(struct hif_device_usb *hif_dev)
>  	const void *data = hif_dev->fw_data;

Here data can be vmalloc() backed.

>  	size_t len = hif_dev->fw_size;
>  	u32 addr = AR9271_FIRMWARE;
> -	u8 *buf = kzalloc(4096, GFP_KERNEL);

Here buf is kmalloc() backed.

>  	u32 firm_offset;
>  
> -	if (!buf)
> -		return -ENOMEM;
> -
>  	while (len) {
>  		transfer = min_t(size_t, len, 4096);
> -		memcpy(buf, data, transfer);
>  
>  		err = usb_control_msg(hif_dev->udev,
>  				      usb_sndctrlpipe(hif_dev->udev, 0),
>  				      FIRMWARE_DOWNLOAD, 0x40 | USB_DIR_OUT,
> -				      addr >> 8, 0, buf, transfer, HZ);


Are you sure usb_control_msg() accepts vmalloc()ed buffers ?

My guess is the answer is no.
