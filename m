From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Locking model for NAPI drivers
Date: Wed, 01 Jun 2005 13:33:39 -0700
Message-ID: <1117658019.4310.58.camel@rh4>
References: <20050531.154847.63995530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050531.154847.63995530.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-31 at 15:48 -0700, David S. Miller wrote:

> Once we make this transformation, we need some way to synchronize
> with the IRQ handler when shutting down the device or making major
> configuration changes to the chip.
> 
> The idea I came up with is a two-bit atomic bitmask.  When base
> level code wants to quiesce interrupt processing, it takes the
> necessary driver spinlocks, sets the "SYNC" bit in the bitmask,
> forces and IRQ to be asserted by the tg3 card, then waits for the
> COMPLETE bit to get set by the interrupt handler.
> 

During light testing, I found a race condition that caused
tg3_irq_quiesce() to spin forever. The race condition is shown below.

CPU1                                CPU2

tg3_interrupt_tagged()
                                    tg3_netif_stop()
                                    netif_poll_disable()
netif_rx_schedule() will do nothing

                                    tg3_full_lock()
                                    tg3_irq_quiesce()

Because netif_poll_disable() is called, netif_rx_schedule() will do
nothing in the interrupt handler. As a result, tg3_poll() will never be
called to re-enable interrupts. Since interrupts are disabled,
tg3_irq_quiesce() will not be able to set the interrupts and cause the
interrupt handler to be called again, and therefore will wait forever.

Even adding another call to tg3_irq_sync() at the end of the interrupt
handler does not eliminate the race condition.

I suppose we can enable interrupts in tg3_irq_quiesce() after setting
the SYNC bit.
