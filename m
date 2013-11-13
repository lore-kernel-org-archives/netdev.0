From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH V2] usbnet: fix race condition caused spinlock bad magic
 issue
Date: Wed, 13 Nov 2013 08:58:18 +0100
Message-ID: <1384329498.5724.4.camel@linux-fkkt.site>
References: <1384305085.19509.5.camel@wangbiao>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo.kernel.org@gmail.com>,
	akpm@linux-foundation.org, mingo@elte.hu, a.p.zijlstra@chello.nl,
	rusty@rustcorp.com.au, william.douglas@intel.com,
	di.zhang@intel.com
To: wangbiao <biao.wang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38022 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758434Ab3KMH6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 02:58:22 -0500
In-Reply-To: <1384305085.19509.5.camel@wangbiao>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 09:11 +0800, wangbiao wrote:

Hi,

> 2, for the same reason,dev->wait should be judged again before use it,
> as between the judge point(if(dev->wait)) and use point(wakeup(dev->wait)),
> the dev->wait may be set NULL by another cpu.
> 
> for issue 1, declare  unlink_wakeup in global section instead of on stack.
> for issue 2, use a temporary local var to keep the value of dev->wait
> in stack and judge it before using.
> 
> Signed-off-by: wang, biao <biao.wang@intel.com>
> Acked-by: Ingo Molnar <mingo.kernel.org@gmail.com>
> Acked-by: Oliver Neukum <oneukum@suse.de>

Well, I didn't exactly ack this version. I requested a change
to the last version, which you did, but you did also other things.

> Acked-by: Zhang, Di <di.zhang@intel.com>
> ---
>  drivers/net/usb/usbnet.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 90a429b..0603ef6 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -86,6 +86,7 @@ static const char driver_name [] = "usbnet";
>  
>  /* use ethtool to change the level for any given device */
>  static int msg_level = -1;
> +static DECLARE_WAIT_QUEUE_HEAD(unlink_wakeup);
>  module_param (msg_level, int, 0);
>  MODULE_PARM_DESC (msg_level, "Override default message level");
>  
> @@ -761,7 +762,6 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);
>  // precondition: never called in_interrupt
>  static void usbnet_terminate_urbs(struct usbnet *dev)
>  {
> -	DECLARE_WAIT_QUEUE_HEAD_ONSTACK(unlink_wakeup);
>  	DECLARE_WAITQUEUE(wait, current);
>  	int temp;

That solves the first problem.
 
> @@ -1449,7 +1449,9 @@ static void usbnet_bh (unsigned long param)
>  	// waiting for all pending urbs to complete?
>  	if (dev->wait) {
>  		if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
> -			wake_up (dev->wait);
> +			wait_queue_head_t *wait_d = dev->wait;
> +			if (wait_d)

Here's the window. Either it can be freed or not. Moving the check
won't help.

> +				wake_up(wait_d);
>  		}
>  
>  	// or are we maybe short a few urbs?

	Regards
		Oliver
