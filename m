From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] e1000: Avoid that e1000_netpoll() triggers a kernel
 warning
Date: Thu, 9 Apr 2015 21:18:45 +0200
Message-ID: <20150409191845.GA1712@kria>
References: <55266885.6010905@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org
To: Bart Van Assche <bart.vanassche@sandisk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:49357 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933058AbbDITSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 15:18:55 -0400
Content-Disposition: inline
In-Reply-To: <55266885.6010905@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-04-09, 13:54:45 +0200, Bart Van Assche wrote:
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
>  [<ffffffff814d1ec5>] dump_stack+0x4c/0x65
>  [<ffffffff8107bcc5>] ___might_sleep+0x175/0x230
>  [<ffffffff8107bdba>] __might_sleep+0x3a/0xa0
>  [<ffffffff810a78c8>] synchronize_irq+0x38/0xa0
>  [<ffffffff810a7a20>] disable_irq+0x20/0x30
>  [<ffffffffa04b4442>] e1000_netpoll+0x102/0x130 [e1000e]
>  [<ffffffff813ffff2>] netpoll_poll_dev+0x72/0x350
>  [<ffffffff81400489>] netpoll_send_skb_on_dev+0x1b9/0x2b0
>  [<ffffffff81400842>] netpoll_send_udp+0x2c2/0x430
>  [<ffffffffa058187f>] write_msg+0xcf/0x120 [netconsole]
>  [<ffffffff810a4682>] call_console_drivers.constprop.25+0xc2/0x250
>  [<ffffffff810a5588>] console_unlock+0x328/0x4c0
>  [<ffffffff810a59f0>] vprintk_emit+0x2d0/0x570
>  [<ffffffff810a5def>] vprintk_default+0x1f/0x30
>  [<ffffffff814cf680>] printk+0x46/0x48
> 
> See also "[RFC PATCH net-next 00/11] net: remove disable_irq() from
> ->ndo_poll_controller" (http://thread.gmane.org/gmane.linux.network/342096).

That approach was NACKed by David Miller is this exact thread.

Peter Zijlstra added disable_hardirq in commit 02cea3958664
("genirq: Provide disable_hardirq()")
and I have prepared patches that use this function in drivers/net, but
this commit is not in David Miller's trees yet.

Or use Alex's suggestion.

-- 
Sabrina
