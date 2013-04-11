From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Thu, 11 Apr 2013 08:57:01 -0700
Message-ID: <1365695821.3887.167.camel@edumazet-glaptop>
References: <5166BDAA.3000603@acm.org>
	 <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bart Van Assche <bvanassche@acm.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:56135 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3DKP5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 11:57:06 -0400
Received: by mail-pb0-f51.google.com with SMTP id rr4so926490pbb.10
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 08:57:05 -0700 (PDT)
In-Reply-To: <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-11 at 11:18 -0400, Neil Horman wrote:
> Bart, this patch should fix your problem.  Could you please test it and confirm?
> 
> Bart Van Assche recently reported a warning to me:
> 
> <IRQ>  [<ffffffff8103d79f>] warn_slowpath_common+0x7f/0xc0
>  [<ffffffff8103d7fa>] warn_slowpath_null+0x1a/0x20
>  [<ffffffff814761dd>] mutex_trylock+0x16d/0x180
>  [<ffffffff813968c9>] netpoll_poll_dev+0x49/0xc30
>  [<ffffffff8136a2d2>] ? __alloc_skb+0x82/0x2a0
>  [<ffffffff81397715>] netpoll_send_skb_on_dev+0x265/0x410
>  [<ffffffff81397c5a>] netpoll_send_udp+0x28a/0x3a0
>  [<ffffffffa0541843>] ? write_msg+0x53/0x110 [netconsole]
>  [<ffffffffa05418bf>] write_msg+0xcf/0x110 [netconsole]
>  [<ffffffff8103eba1>] call_console_drivers.constprop.17+0xa1/0x1c0
>  [<ffffffff8103fb76>] console_unlock+0x2d6/0x450
>  [<ffffffff8104011e>] vprintk_emit+0x1ee/0x510
>  [<ffffffff8146f9f6>] printk+0x4d/0x4f
>  [<ffffffffa0004f1d>] scsi_print_command+0x7d/0xe0 [scsi_mod]
> 
> This resulted from my commit ca99ca14c which introduced a mutex_trylock
> operation in a path that could execute in interrupt context.  When mutex
> debugging is enabled, the above warns the user when we are in fact exectuting in
> interrupt context.
> 
> I think this is a false positive however.  The check is intended to catch users
> who might be issuing sleeping calls in irq context, but the use of mutex_trylock
> here is guaranteed not to sleep.
> 
> We could fix this by replacing the DEBUG_LOCK_WARN_ON check in spin_lock_mutex
> with a __might_sleep call in the appropriate parent mutex operations, but for
> the sake of effiency (which It seems is why the check was put in the spin lock
> code only when debug is enabled), lets split the spin_lock_mutex call into two
> components, where the outer component does the debug checking.  Then
> mutex_trylock can just call the inner part as its callable from irq context
> safely.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Bart Van Assche <bvanassche@acm.org>
> CC: Bart Van Assche <bvanassche@acm.org>
> CC: David Miller <davem@davemloft.net>
> CC: netdev@vger.kernel.org

Please post your patch to lkml ?

Thanks !
