From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 16:36:08 +0200
Message-ID: <200606271636.08473.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <200606271530.06749.mb@bu3sch.de> <44A13C81.2050503@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47569
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161071AbWF0Ogj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:36:39 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44A13C81.2050503@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 June 2006 16:11, Jeff Garzik wrote:
> Michael Buesch wrote:
> > On Tuesday 27 June 2006 04:27, Larry Finger wrote:
> >> Jeff Garzik wrote:
> >>> John W. Linville wrote:
> >>>> +    assert(bcm->mac_suspended >= 0);
> >>>> +    if (bcm->mac_suspended == 0) {
> >>>> +        bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
> >>>> +        bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
> >>>> +                        bcm43xx_read32(bcm, 
> >>>> BCM43xx_MMIO_STATUS_BITFIELD)
> >>>> +                & ~BCM43xx_SBF_MAC_ENABLED);
> >>>> +        bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy 
> >>>> read */
> >>>> +        for (i = 100000; i; i--) {
> >>>> +            tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
> >>>> +            if (tmp & BCM43xx_IRQ_READY)
> >>>> +                goto out;
> >>>> +            udelay(10);
> >>>> +        }
> >>>> +        printkl(KERN_ERR PFX "MAC suspend failed\n");
> >>>>      }
> >>>
> >>> NAK this super-long delay...  should be done in a workqueue, looks like?
> >>>
> >>> ACK everything else.
> >>>
> >> That delay was set to try to accommodate my interface when it refused to suspend the MAC, which 
> >> resulted in transmit errors. That problem has since been cured by reworking the periodic work 
> >> handlers - thus such a long delay should not be needed. The original spec from the clean-room group 
> >> was a delay loop of 1000. I'm currently testing that value now. If it passes the test, would a for 
> >> (i=1000; i; i--) be acceptable?
> > 
> > Short: Don't touch it. Fullstop.
> > 
> > Long: The delay will _never_ be exhausted. Actually the for-counter
> > is only there to not lock up the machine, if there is a Bug in the
> > driver. (__much__ easier debugging).
> > The loop will only iterate a few times, typically.
> > Actually, _if_ we want to change something, we should do this:
> > 
> > for (i = 1000000; i; i--) {
> > 	...
> > 	udelay(1);
> > }
> > 
> > (max loop multiplied by 10, delay value divided by 10).
> > This will shorten the whole delay by a few usecs (up to 10).
> > I will send a patch for this, if it is desired.
> > 
> > But lowering the loop counter value is NACKed by me,
> > because it simply does not make sense.
> 
> 
> My overriding concern was that this type of loop spins the CPU at 100% 
> until the hardware condition is satisfied, which starves all other 
> kernel work on that CPU, and is very unfriendly to power consumption 
> (though I believe monitor/mwait/cpu_relax helps on x86).
> 
> Overall, bcm43xx is _really really bad_ about this sort of thing.  Just 
> grepping for udelay in bcm43xx_radio.c shows some of the worst 
> offenders.  bcm43xx_radio_init2060() and bcm43xx_radio_selectchannel() 
> both look like candidates for using msleep() rather than udelay().

This is _all_ at initialization time.
select_channel.... How often do you select a channel?

I recently reworked the periodically exectuted workhandlers,
so that they are preemptible.

mac_suspend():
It is always called in atomic context with IRQs disabled.
We need to wait for the device here to signal "OK, MAC is down
now and you can count on it". This takes a few usecs. I guess
it sends out all queued packets, or whatever. We don't know
really.
I can actually measure how long it takes, if you really desire
it.
We _need_ to wait there. It is something like synchronize_irq(), or
whatever. It is a synchronizing function and we need it to be
synchronizing.
And I don't think it is worth the pain to insert a preemption
point there (or doing even fancier things with workqueues and
completions).

Overall, I don't think bcm43xx is still so bad at
wasting CPU. Maybe we should still insert some voluntary
preemption points, if the bcm43xx user does not run a fully
preemptible kernel. But if a fully preemptible kernel is run,
I think it is all OK.

-- 
Greetings Michael.
