From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 1/3] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Tue, 30 Jul 2013 07:00:59 -0700
Message-ID: <20130730140059.GE27962@kroah.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
 <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, nic_swsd@realtek.com
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 30, 2013 at 04:28:54PM +0800, Hayes Wang wrote:
> Allocate the transfer buffer in probe(), and use the buffer for
> usb control transfer.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r815x.c | 117 +++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 90 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/net/usb/r815x.c b/drivers/net/usb/r815x.c
> index 8523922..89ad63f 100644
> --- a/drivers/net/usb/r815x.c
> +++ b/drivers/net/usb/r815x.c
> @@ -21,37 +21,52 @@
>  #define R815x_PHY_ID		32
>  #define REALTEK_VENDOR_ID	0x0bda
>  
> +struct r815x {
> +	struct mutex transfer_mutex;
> +	__le32 *transfer_buf;
> +};

Really?  Why not just allocate it the times you need to send the data?
Is it really all that often that you need to do this?

> -static int pla_read_word(struct usb_device *udev, u16 index)
> +static int pla_read_word(struct usbnet *dev, u16 index)
>  {
> -	int data, ret;
> +	struct r815x *tp = dev->driver_priv;
> +	struct usb_device *udev = dev->udev;
> +	int ret;
>  	u8 shift = index & 2;
> -	__le32 ocp_data;
> +	__le32 *tmp;
> +
> +	mutex_lock(&tp->transfer_mutex);
> +	tmp = tp->transfer_buf;
>  
>  	index &= ~3;
>  
>  	ret = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
>  			      RTL815x_REQ_GET_REGS, RTL815x_REQT_READ,
> -			      index, MCU_TYPE_PLA, &ocp_data, sizeof(ocp_data),
> -			      500);
> +			      index, MCU_TYPE_PLA, tmp, sizeof(*tmp), 500);

This call is so slow, you can afford to make a call to kmalloc for the
data, as it sure just did for other structures it needed :)

So just do a kmalloc call for the data before this function, same for
your other patches in this series, no need for a lock for your "transfer
data" buffer, and a global one at all.

thanks,

greg k-h
