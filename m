From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH] Updated 8139too with NAPI
Date: Fri, 31 Oct 2003 02:12:41 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <873cdaabue.fsf@devron.myhome.or.jp>
References: <3F9070B6.9090306@pobox.com> <873cdqbt6z.fsf@devron.myhome.or.jp>
	<20031020131106.6862e951.shemminger@osdl.org>
	<877k2ysohc.fsf@devron.myhome.or.jp>
	<20031028114707.1d234da6.shemminger@osdl.org>
	<3FA01629.2080202@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FA01629.2080202@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> writes:

> I'd like to apply this to net-drivers-2.[45]-exp, but it doesn't apply
> cleanly.  Can you wait a bit, for my posting of those queues, and then
> resend?

Probably more tester/reviewer is always welcome, so I think it's good.


Stephen Hemminger <shemminger@osdl.org> writes:

> +	/* Receive packets are processed by poll routine.
> +	   If not running start it now. */
> +	if (status & RxAckBits){
> +		if (netif_rx_schedule_prep(dev)) {
> +			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
> +			__netif_rx_schedule (dev);
>  		}

I think that this style is common issues of NIC drivers for "NAPI
support and intr-mask" handling. Looks like __netif_poll_disable()
also has the following problem.

For example,

	in ISR
		[...]
		if (status & RxAckBits){
			if (netif_rx_schedule_prep(dev)) {
				RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
				__netif_rx_schedule (dev);
			}
		}
		[...]

	in dev_close()
		[...]
		while (test_bit(__LINK_STATE_RX_SCHED, &dev->state)) {
			/* No hurry. */
			current->state = TASK_INTERRUPTIBLE;
			schedule_timeout(1);
		}
		  --------- (*)
		if (dev->stop)
			dev->stop(dev);
		[...]

If Rx interrupt happen on (*) point, ISR can't ack or disable.
Then it will start busy Rx interrupt loop. So if this happen, it's
seriously problem on UP system.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
