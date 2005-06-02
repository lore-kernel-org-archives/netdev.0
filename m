From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Locking model for NAPI drivers
Date: Thu, 02 Jun 2005 12:56:52 -0700
Message-ID: <1117742212.22670.24.camel@rh4>
References: <20050531.154847.63995530.davem@davemloft.net>
 <1117658019.4310.58.camel@rh4>
 <20050601.152134.120445266.davem@davemloft.net>
 <1117661650.4310.62.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1117661650.4310.62.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-06-01 at 14:34 -0700, Michael Chan wrote:
> On Wed, 2005-06-01 at 15:21 -0700, David S. Miller wrote:
> > Since the caller shuts down NAPI ->poll(), after setting the SYNC bit
> > we can just check the MAILBOX register, and if a '1' is there just
> > return.  Does one need to mask out the upper bits of the regiser in
> > order to avoid seeing the IRQ tag in such a comparison?
> > 
> No, just check for the value 1 since that's the value we use to disable
> interrupts. The value read back will always be 1 if 1 was previously
> written to it.
> 
One more race condition:

CPU1                                 CPU2

tg3_poll()
 __netif_rx_complete()
                                     tg3_netif_stop()
                                      netif_poll_disable()
                                     tg3_full_lock()
                                      tg3_irq_quiesce()
 tg3_restart_ints()
  BUG_ON(tp->irq_state)

This race condition is somewhat harmless but I think we need to take
care of it for correctness. Any simple ways to fix it?
