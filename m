From: Daniel Mack <zonque@gmail.com>
Subject: Re: A reliable kernel panic (3.6.2) and system crash when visiting
 a particular website
Date: Mon, 22 Oct 2012 17:30:02 +0200
Message-ID: <5085667A.70408@gmail.com>
References: <Pine.LNX.4.44L0.1210221116040.1724-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Artem S. Tashkinov" <t.artem@lycos.com>, bp@alien8.de,
	pavel@ucw.cz, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, linux-media@vger.kernel.org,
	linux-usb@vger.kernel.org, alsa-devel@alsa-project.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1210221116040.1724-100000@iolanthe.rowland.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22.10.2012 17:17, Alan Stern wrote:
> On Sun, 21 Oct 2012, Artem S. Tashkinov wrote:
> 
>> dmesg messages up to a crash can be seen here: https://bugzilla.kernel.org/attachment.cgi?id=84221
> 
> The first problem in the log is endpoint list corruption.  Here's a 
> debugging patch which should provide a little more information.

Maybe add a BUG() after each of these dev_err() so we stop at the first
occurance and also see where we're coming from?




>  drivers/usb/core/hcd.c |   36 ++++++++++++++++++++++++++++++++++++
>  1 file changed, 36 insertions(+)
> 
> Index: usb-3.6/drivers/usb/core/hcd.c
> ===================================================================
> --- usb-3.6.orig/drivers/usb/core/hcd.c
> +++ usb-3.6/drivers/usb/core/hcd.c
> @@ -1083,6 +1083,8 @@ EXPORT_SYMBOL_GPL(usb_calc_bus_time);
>  
>  /*-------------------------------------------------------------------------*/
>  
> +static bool list_error;
> +
>  /**
>   * usb_hcd_link_urb_to_ep - add an URB to its endpoint queue
>   * @hcd: host controller to which @urb was submitted
> @@ -1126,6 +1128,20 @@ int usb_hcd_link_urb_to_ep(struct usb_hc
>  	 */
>  	if (HCD_RH_RUNNING(hcd)) {
>  		urb->unlinked = 0;
> +
> +		{
> +			struct list_head *cur = &urb->ep->urb_list;
> +			struct list_head *prev = cur->prev;
> +
> +			if (prev->next != cur && !list_error) {
> +				list_error = true;
> +				dev_err(&urb->dev->dev,
> +					"ep %x list add corruption: %p %p %p\n",
> +					urb->ep->desc.bEndpointAddress,
> +					cur, prev, prev->next);
> +			}
> +		}
> +
>  		list_add_tail(&urb->urb_list, &urb->ep->urb_list);
>  	} else {
>  		rc = -ESHUTDOWN;
> @@ -1193,6 +1209,26 @@ void usb_hcd_unlink_urb_from_ep(struct u
>  {
>  	/* clear all state linking urb to this dev (and hcd) */
>  	spin_lock(&hcd_urb_list_lock);
> +	{
> +		struct list_head *cur = &urb->urb_list;
> +		struct list_head *prev = cur->prev;
> +		struct list_head *next = cur->next;
> +
> +		if (prev->next != cur && !list_error) {
> +			list_error = true;
> +			dev_err(&urb->dev->dev,
> +				"ep %x list del corruption prev: %p %p %p\n",
> +				urb->ep->desc.bEndpointAddress,
> +				cur, prev, prev->next);
> +		}
> +		if (next->prev != cur && !list_error) {
> +			list_error = true;
> +			dev_err(&urb->dev->dev,
> +				"ep %x list del corruption next: %p %p %p\n",
> +				urb->ep->desc.bEndpointAddress,
> +				cur, next, next->prev);
> +		}
> +	}
>  	list_del_init(&urb->urb_list);
>  	spin_unlock(&hcd_urb_list_lock);
>  }
> 
