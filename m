From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] hso_create_bulk_serial_device(): fix a double free
Date: Sat, 13 Sep 2008 15:56:13 -0400
Message-ID: <48CC1ADD.7070101@pobox.com>
References: <20080827220236.GL11734@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52830 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599AbYIMT4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:56:18 -0400
In-Reply-To: <20080827220236.GL11734@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> hso_serial_common_free() mustn't be called if
> hso_serial_common_create() fails.
> 
> Reported-by: Adrian Bunk <bunk@kernel.org>
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/usb/hso.c |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> d7557f8eda806e6888232bae1b86dfdd8b6cf330 
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 1b7cac7..8c11295 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -2206,39 +2206,40 @@ static struct hso_device *hso_create_bulk_serial_device(
>  	if (hso_serial_common_create(serial, num_urbs, BULK_URB_RX_SIZE,
>  				     BULK_URB_TX_SIZE))
>  		goto exit;
>  
>  	serial->in_endp = hso_get_ep(interface, USB_ENDPOINT_XFER_BULK,
>  				     USB_DIR_IN);
>  	if (!serial->in_endp) {
>  		dev_err(&interface->dev, "Failed to find BULK IN ep\n");
> -		goto exit;
> +		goto exit2;
>  	}
>  
>  	if (!
>  	    (serial->out_endp =
>  	     hso_get_ep(interface, USB_ENDPOINT_XFER_BULK, USB_DIR_OUT))) {
>  		dev_err(&interface->dev, "Failed to find BULK IN ep\n");
> -		goto exit;
> +		goto exit2;
>  	}
>  
>  	serial->write_data = hso_std_serial_write_data;
>  
>  	/* and record this serial */
>  	set_serial_by_index(serial->minor, serial);
>  
>  	/* setup the proc dirs and files if needed */
>  	hso_log_port(hso_dev);
>  
>  	/* done, return it */
>  	return hso_dev;
> +
> +exit2:
> +	hso_serial_common_free(serial);
>  exit:
> -	if (hso_dev && serial)
> -		hso_serial_common_free(serial);
>  	kfree(serial);
>  	hso_free_device(hso_dev);
>  	return NULL;
>  }
>  
>  /* Creates a multiplexed AT channel */
>  static

applied


