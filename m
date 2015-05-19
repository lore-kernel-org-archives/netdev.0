From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] irda: irda-usb: use msecs_to_jiffies for conversions
Date: Tue, 19 May 2015 14:09:07 -0700
Message-ID: <1432069747.2870.215.camel@perches.com>
References: <1432032711-7020-1-git-send-email-hofrat@osadl.org>
	 <1432045935.2870.152.camel@perches.com>
	 <20150519.164555.1631069770118420652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hofrat@osadl.org, samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150519.164555.1631069770118420652.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-19 at 16:45 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 19 May 2015 07:32:15 -0700
> 
> > On Tue, 2015-05-19 at 12:51 +0200, Nicholas Mc Guire wrote:
> >> Converting milliseconds to jiffies by "val * HZ / 1000" is technically
> >> is not a clean solution as it does not handle all corner cases correctly.
> >> By changing the conversion to use msecs_to_jiffies(val) conversion is
> >> correct in all cases.
> >> 
> >> in the current code: 
> >>   mod_timer(&self->rx_defer_timer, jiffies + (10 * HZ / 1000));
> >> for HZ < 100 (e.g. CONFIG_HZ == 64|32 in alpha) this effectively results 
> >> in no delay at all.
> > []
> >> diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
> > []
> >> @@ -848,7 +848,9 @@ static void irda_usb_receive(struct urb *urb)
> >>  		 * Jean II */
> >>  		self->rx_defer_timer.function = irda_usb_rx_defer_expired;
> >>  		self->rx_defer_timer.data = (unsigned long) urb;
> >> -		mod_timer(&self->rx_defer_timer, jiffies + (10 * HZ / 1000));
> >> +		mod_timer(&self->rx_defer_timer,
> >> +			  jiffies + (msecs_to_jiffies(10)));
> > 
> > The unnecessary () around msecs_to_jiffies could be removed.

The other thing that could be done is to use
	max(1ul, msecs_to_jiffies())
so that there's always some delay even if HZ <= 50
