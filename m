From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] e1000: Avoid that e1000_netpoll() triggers a kernel warning
Date: Thu, 09 Apr 2015 11:08:22 -0700
Message-ID: <5526C016.2090508@redhat.com>
References: <55266885.6010905@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org
To: Bart Van Assche <bart.vanassche@sandisk.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932815AbbDISJC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 14:09:02 -0400
In-Reply-To: <55266885.6010905@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2015 04:54 AM, Bart Van Assche wrote:
> console_cont_flush(), which is called by console_unlock(), calls
> call_console_drivers() and hence also the netconsole function
> write_msg() with local interrupts disabled. This means that it is
> not allowed to call disable_irq() from inside a netpoll callback
> function. Hence eliminate the disable_irq() / enable_irq() pair
> from the e1000 netpoll function. This patch avoids that the e1000
> networking driver triggers the following complaint:
>
> BUG: sleeping function called from invalid context at kernel/irq/manage.c:104
>
> Call Trace:
>   [<ffffffff814d1ec5>] dump_stack+0x4c/0x65
>   [<ffffffff8107bcc5>] ___might_sleep+0x175/0x230
>   [<ffffffff8107bdba>] __might_sleep+0x3a/0xa0
>   [<ffffffff810a78c8>] synchronize_irq+0x38/0xa0
>   [<ffffffff810a7a20>] disable_irq+0x20/0x30
>   [<ffffffffa04b4442>] e1000_netpoll+0x102/0x130 [e1000e]
>   [<ffffffff813ffff2>] netpoll_poll_dev+0x72/0x350
>   [<ffffffff81400489>] netpoll_send_skb_on_dev+0x1b9/0x2b0
>   [<ffffffff81400842>] netpoll_send_udp+0x2c2/0x430
>   [<ffffffffa058187f>] write_msg+0xcf/0x120 [netconsole]
>   [<ffffffff810a4682>] call_console_drivers.constprop.25+0xc2/0x250
>   [<ffffffff810a5588>] console_unlock+0x328/0x4c0
>   [<ffffffff810a59f0>] vprintk_emit+0x2d0/0x570
>   [<ffffffff810a5def>] vprintk_default+0x1f/0x30
>   [<ffffffff814cf680>] printk+0x46/0x48
>
> See also "[RFC PATCH net-next 00/11] net: remove disable_irq() from
> ->ndo_poll_controller" (http://thread.gmane.org/gmane.linux.network/342096).
>
> See also patch "sched/wait: Add might_sleep() checks" (kernel v3.19-rc1;
> commit e22b886a8a43).
>
> Reported-by: Sabrina Dubroca <sd@queasysnail.net>
> Signed-off-by: Bart Van Assche <bvanassche@acm.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: <stable@vger.kernel.org>
> ---
>   drivers/net/ethernet/intel/e1000/e1000.h      |  5 +++++
>   drivers/net/ethernet/intel/e1000/e1000_main.c | 27 ++++++++++++++++++++++-----
>   2 files changed, 27 insertions(+), 5 deletions(-)
>

Instead of adding all of this complexity why not just simplify things 
and replace the call to e1000_intr with just the bits that matter?  You 
should be able to just copy the napi_schedule_prep, stats reset, and the 
call to __napi_schedule and you should then be all set to do this 
without needing to add all the extra locking.

- Alex
