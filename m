From: "Jesse Huang" <jesse@icplus.com.tw>
Subject: Re: [PATCH 1/4] IP100A: Fix TX Pause bug (reset_tx, intr_handler)
Date: Mon, 18 Sep 2006 19:11:29 +0800
Message-ID: <00b801c6db13$312b9840$4964a8c0@icplus.com.tw>
References: <20060915114448.GA7329@ingate.macqel.be> <005101c6dad4$47b1e2c0$4964a8c0@icplus.com.tw> <20060918094113.GA4873@ingate.macqel.be>
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr17.hinet.net ([168.95.4.117]:49836 "EHLO msr17.hinet.net")
	by vger.kernel.org with ESMTP id S932165AbWIRLLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 07:11:42 -0400
To: "Philippe De Muyter" <phdm@macqel.be>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Philippe:
(1)Because this is a patent issue, we are not allow to use it again, even it
is in Data Sheet.

(2)Ok, sorry for this, I will add it back.

Should I resent those 4 patches? Or generate this as a new patch?

Thanks very much!

Best Regards,
Jesse Huang.

----- Original Message ----- 
From: "Philippe De Muyter" <phdm@macqel.be>
To: "Jesse Huang" <jesse@icplus.com.tw>
Cc: <netdev@vger.kernel.org>
Sent: Monday, September 18, 2006 5:41 PM
Subject: Re: [PATCH 1/4] IP100A: Fix TX Pause bug (reset_tx, intr_handler)


On Mon, Sep 18, 2006 at 11:41:09AM +0800, Jesse Huang wrote:
> Dear Philippe:
>
> (1) We are not allow to support register TxStartThresh and, RxEarlyThresh,
> so
> we remove it.

Could you develop ?
- What do you mean by `We are not allow'
- Is it specific to the IP100A chip ?

Those register are documented in the Sundance Technology ST201 Data Sheet
and when modified with fine-tuned values, they can have a real positive
effect on the overall throughput on a loaded system.

>
> (2) Your consideration is right. But reset_tx is workaround for customer's
> embedded system, I don't have this
> enviroment now. I can't sure it will work fine if I removed this.

On DFE-580TX boards, the reset_tx way did not work.  The ports remained
blocked until a power-cycle.  I do not know if the TxUnderrun problem ever
happened with earlier (one port) boards, so I doubt that the reset_tx way
ever worked.  Is was even commented as not being tested.  On DFE-580TX
boards, the current way has been verified by me and others to work, so
please do not break it.

Best regards

Philippe

>
> Thanks you very mutch.
>
> Best Regards,
> Jesse Huang.
>
> ----- Original Message ----- 
> From: "Philippe De Muyter" <phdm@macqel.be>
> To: "Jesse Huang" <jesse@icplus.com.tw>
> Cc: <netdev@vger.kernel.org>
> Sent: Friday, September 15, 2006 7:44 PM
> Subject: Re: [PATCH 1/4] IP100A: Fix TX Pause bug (reset_tx, intr_handler)
>
>
> On Thu, Sep 14, 2006 at 12:58:30AM +0000, Jesse Huang wrote:
> [...]
> > @@ -262,8 +262,6 @@ enum alta_offsets {
> >  ASICCtrl = 0x30,
> >  EEData = 0x34,
> >  EECtrl = 0x36,
> > - TxStartThresh = 0x3c,
> > - RxEarlyThresh = 0x3e,
>
> Why ?
>
> >  FlashAddr = 0x40,
> >  FlashData = 0x44,
> >  TxStatus = 0x46,
> [...]
> > @@ -1156,29 +1160,29 @@ static irqreturn_t intr_handler(int irq,
> >  np->stats.tx_fifo_errors++;
> >  if (tx_status & 0x02)
> >  np->stats.tx_window_errors++;
> > - /*
> > - ** This reset has been verified on
> > - ** DFE-580TX boards ! phdm@macqel.be.
> > - */
> > - if (tx_status & 0x10) { /* TxUnderrun */
> > - unsigned short txthreshold;
> > -
> > - txthreshold = ioread16 (ioaddr + TxStartThresh);
> > - /* Restart Tx FIFO and transmitter */
> > - sundance_reset(dev, (NetworkReset|FIFOReset|TxReset) << 16);
> > - iowrite16 (txthreshold, ioaddr + TxStartThresh);
> > - /* No need to reset the Tx pointer here */
> > +
> > + /* FIFO ERROR need to be reset tx */
> > + if (tx_status & 0x10) { /* Reset the Tx. */
> > + spin_lock(&np->lock);
> > + reset_tx(dev);
> > + spin_unlock(&np->lock);
> > + }
>
> Just as the comments say, on DFE-580TX 4 port boards, where it is easy to
> reproduce TxUnderrun problems, just resetting on the chip the Tx FIFO and
> transmitter is enough.
> There is no need to call reset_tx, which discards all pending messages and
> frees all the skb's.  It is also not necessary to reload the Tx pointer.
>
> Is it different with newer versions of the chip ?
>
> Philippe
>

--


