From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH]: Tigon3 new NAPI locking v2
Date: Fri, 03 Jun 2005 16:23:07 -0400
Message-ID: <42A0BC2B.4020409@pobox.com>
References: <20050603.122558.88474819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050603.122558.88474819.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> [TG3]: Eliminate all hw IRQ handler spinlocks.
> 
> Move all driver spinlocks to be taken at sw IRQ
> context only.
> 
> This fixes the skb_copy() we were doing with hw
> IRQs disabled (which is illegal and triggers a
> BUG() with HIGHMEM enabled).  It also simplifies
> the locking all over the driver tremendously.
> 
> We accomplish this feat by creating a special
> sequence to synchronize with the hw IRQ handler
> using a 2-bit atomic state.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

overall, pretty spiffy :)

As further work, I would like to see how much (alot? all?) of the timer 
code could be moved into a workqueue, where we could kill the last of 
the horrible-udelay loops in the driver.  Particularly awful is

         while (++tick < 195000) {
                 status = tg3_fiber_aneg_smachine(tp, &aninfo);
                 if (status == ANEG_DONE || status == ANEG_FAILED)
                         break;

                 udelay(1);
         }

where you could freeze a uniprocess box (lock out everything but 
interrupts) for over 1 second.  IOW, the slower the phy, the more these 
slow-path delays can affect the overall system.

This is a MINOR, low priority issue; but long delays are uglies that 
should be fixed, if its relatively painless.


> +static void tg3_irq_quiesce(struct tg3 *tp)
> +{
> +	BUG_ON(test_bit(TG3_IRQSTATE_SYNC, &tp->irq_state));
> +
> +	set_bit(TG3_IRQSTATE_SYNC, &tp->irq_state);
> +	smp_mb();
> +	tw32(GRC_LOCAL_CTRL,
> +	     tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
> +
> +	while (!test_bit(TG3_IRQSTATE_COMPLETE, &tp->irq_state)) {
> +		u32 val = tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
> +
> +		if (val == 0x00000001)
> +			break;
> +
> +		cpu_relax();
> +	}
> +}

* This loop makes me nervous...  If there's a fault on the PCI bus or 
the hardware is unplugged, val will equal 0xffffffff.

* A few comments for normal humans like "force an interrupt" and "wait 
for interrupt handler to complete" might be nice.

* a BUG_ON(if-interrupts-are-disabled) line might be nice


> +static inline int tg3_irq_sync(struct tg3 *tp)
> +{
> +	if (test_bit(TG3_IRQSTATE_SYNC, &tp->irq_state)) {
> +		set_bit(TG3_IRQSTATE_COMPLETE, &tp->irq_state);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +/* Fully shutdown all tg3 driver activity elsewhere in the system.
> + * If irq_sync is non-zero, then the IRQ handler must be synchronized
> + * with as well.  Most of the time, this is not necessary except when
> + * shutting down the device.
> + */
> +static inline void tg3_full_lock(struct tg3 *tp, int irq_sync)
> +{
> +	if (irq_sync)
> +		tg3_irq_quiesce(tp);
> +	spin_lock_bh(&tp->lock);
> +	spin_lock(&tp->tx_lock);
> +}

Rather than an 'irq_sync' arg, my instinct would have been to create 
tg3_full_lock() and tg3_full_lock_sync().  This makes the action -much- 
more obvious to the reader, and since its inline doesn't cost anything 
(compiler's optimizer even does a tiny bit less work my way).

	Jeff
