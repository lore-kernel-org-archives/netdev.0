From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 2/3] net/usb/r8152: replace USB buffer from stack to
 DMA-able
Date: Tue, 30 Jul 2013 07:01:52 -0700
Message-ID: <20130730140152.GF27962@kroah.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
 <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
 <1375172936-4145-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, nic_swsd@realtek.com
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:40458 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754394Ab3G3OAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 10:00:34 -0400
Content-Disposition: inline
In-Reply-To: <1375172936-4145-2-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 30, 2013 at 04:28:55PM +0800, Hayes Wang wrote:
> Allocate the required transfer buffer for usb_control_msg.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 91 +++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 66 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index ee13f9e..93a7baa 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -282,6 +282,8 @@ enum rtl_register_content {
>  #define RTL8152_RMS		(VLAN_ETH_FRAME_LEN + VLAN_HLEN)
>  #define RTL8152_TX_TIMEOUT	(HZ)
>  
> +#define RTL8152_MAX_TRANSFER_SIZE	8
> +
>  /* rtl8152 flags */
>  enum rtl8152_flags {
>  	RTL8152_UNPLUG = 0,
> @@ -324,8 +326,10 @@ struct r8152 {
>  	struct sk_buff *tx_skb, *rx_skb;
>  	struct delayed_work schedule;
>  	struct mii_if_info mii;
> +	struct mutex transfer_mutex;
>  	u32 msg_enable;
>  	u16 ocp_base;
> +	u8 *transfer_buf;
>  	u8 version;
>  	u8 speed;
>  };
> @@ -344,17 +348,59 @@ static const int multicast_filter_limit = 32;
>  static
>  int get_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
>  {
> -	return usb_control_msg(tp->udev, usb_rcvctrlpipe(tp->udev, 0),
> +	int ret;
> +	void *tmp;
> +
> +	if (size > RTL8152_MAX_TRANSFER_SIZE || !tp->transfer_buf) {
> +		tmp = kmalloc(size, GFP_KERNEL);
> +		if (!tmp)
> +			return -ENOMEM;
> +	} else {
> +		mutex_lock(&tp->transfer_mutex);
> +		tmp = tp->transfer_buf;
> +	}
> +
> +	ret = usb_control_msg(tp->udev, usb_rcvctrlpipe(tp->udev, 0),
>  			       RTL8152_REQ_GET_REGS, RTL8152_REQT_READ,
> -			       value, index, data, size, 500);
> +			       value, index, tmp, size, 500);

Same here, no need for your "transfer buf" structure, just always
kmalloc the data, copy it in, and make the call.  It's _really_ slow
anyway, you will never notice any speed overhead by doing this.

thanks,

greg k-h
