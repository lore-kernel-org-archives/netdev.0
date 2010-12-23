From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: add disable and re-enable Rx int to
 de-assert interrupt pin
Date: Thu, 23 Dec 2010 09:59:17 -0800 (PST)
Message-ID: <20101223.095917.59696176.davem@davemloft.net>
References: <1293100993-3956-1-git-send-email-jason77.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	linux-omap@vger.kernel.org
To: jason77.wang@gmail.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1293100993-3956-1-git-send-email-jason77.wang@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jason77.wang@gmail.com>
Date: Thu, 23 Dec 2010 18:43:13 +0800

> When kernel enters irqhanlder, it will check the Rx interrupt status
> bit, if Rx status is set but can't call napi_schedule(), it will do
> nothing and directly return form irqhandler. This situation is prone
> to be produced when we repeatly call irqhandler through netpoll
> interface(i.e kgdboe connecting).
> 
> This is a potential risk for those level triggered platforms(i.e
> ti_omap3evm), because if we don't handle Rx int and just return from
> irqhandler, the irq pin will be keeping asserted, the level triggered
> platforms will have no chance to jump out from the Rx irq. The whole
> system will hung into the irq subsystem.
> 
> To solve it, we add a disable/re-enable Rx int operation for this
> situation, this operation can de-assert interrupt pin for this time
> and will leave the received data and status in the FIFO for later
> interrupts to handle.
> 
> Signed-off-by: Jason Wang <jason77.wang@gmail.com>

You absolutely cannot do this.

You now can race with the NAPI completion code turning the RX
interrupts back on, and you'll leave the chip with RX interrupts
disabled.

You must solve your level triggered interrupt some other way, every
NAPI based device must manage the interrupt disabling carefully and
only when the napi POLL is successfully scheduled in order to avoid
races.

And especially you must not make a crazy hack like this for obscure
things like kgdboe.
