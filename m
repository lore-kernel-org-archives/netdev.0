From: Greg KH <greg@kroah.com>
Subject: Re: use-after-free in usbnet
Date: Wed, 21 Mar 2012 07:44:41 -0700
Message-ID: <20120321144441.GB14043@kroah.com>
References: <20120319151224.GA16031@redhat.com>
 <CACVXFVN5O2S0hsnzHoi=LX+KAnccHc_F0SXq9-hMOXnaoUOdkg@mail.gmail.com>
 <CACVXFVP9-Ao_UyBoxkxzq5dg8TfkZ9CECqEUFW5bD_JRzfQybw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53634 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755084Ab2CUOon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 10:44:43 -0400
Received: from compute6.internal (compute6.nyi.mail.srv.osa [10.202.2.46])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id E8CDD21949
	for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 10:44:42 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <CACVXFVP9-Ao_UyBoxkxzq5dg8TfkZ9CECqEUFW5bD_JRzfQybw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 21, 2012 at 09:04:15AM +0800, Ming Lei wrote:
> On Tue, Mar 20, 2012 at 5:40 PM, Ming Lei <tom.leiming@gmail.com> wrote:
> > Hi,
> >
> > On Mon, Mar 19, 2012 at 11:12 PM, Dave Jones <davej@redhat.com> wrote:
> >> We've had two reports of this use after free in Fedora now recently..
> >
> > Could you provide output of 'dmesg' and 'lsusb -v' from the reported machine?
> 
> Looks I have figured out why your problem is triggered.
> 
> If the URB being unlinked is freed before usb_put_dev
> inside usb_hcd_unlink_urb, the use-after-free will be triggered.
> And the below patch[1] should fix the problem.

With the reference counting we have, how can the urb be freed at this
point in time?  Is the driver doing wierd things with the urb reference
counts?

> Also there is another bug in tx_complete() of usbnet, the line below
> 
>                 urb->dev = NULL;
> 
> should be removed to avoid possible oops or memory leak in unlink path.
> 
> Please test the patch if you can reproduce the problem.
> 
> [1],
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 59681f0..4f4e028 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -592,7 +592,9 @@ static int unlink_urbs (struct usbnet *dev, struct
> sk_buff_head *q)
>  		spin_unlock_irqrestore(&q->lock, flags);
>  		// during some PM-driven resume scenarios,
>  		// these (async) unlinks complete immediately
> +		local_bh_disable();
>  		retval = usb_unlink_urb (urb);
> +		local_bh_enable();

That doesn't seem right, as you point out in your follow-up message.
This shouldn't be needed, unless you are doing some really wierd things
with the urb :(

greg k-h
