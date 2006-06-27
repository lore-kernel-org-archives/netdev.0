From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 15:30:06 +0200
Message-ID: <200606271530.06749.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <44A09289.4040200@garzik.org> <44A097AA.6080809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49325
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932396AbWF0NbJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 09:31:09 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44A097AA.6080809@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 June 2006 04:27, Larry Finger wrote:
> Jeff Garzik wrote:
> > John W. Linville wrote:
> >> +    assert(bcm->mac_suspended >= 0);
> >> +    if (bcm->mac_suspended == 0) {
> >> +        bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
> >> +        bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
> >> +                        bcm43xx_read32(bcm, 
> >> BCM43xx_MMIO_STATUS_BITFIELD)
> >> +                & ~BCM43xx_SBF_MAC_ENABLED);
> >> +        bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy 
> >> read */
> >> +        for (i = 100000; i; i--) {
> >> +            tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
> >> +            if (tmp & BCM43xx_IRQ_READY)
> >> +                goto out;
> >> +            udelay(10);
> >> +        }
> >> +        printkl(KERN_ERR PFX "MAC suspend failed\n");
> >>      }
> > 
> > 
> > NAK this super-long delay...  should be done in a workqueue, looks like?
> > 
> > ACK everything else.
> > 
> 
> That delay was set to try to accommodate my interface when it refused to suspend the MAC, which 
> resulted in transmit errors. That problem has since been cured by reworking the periodic work 
> handlers - thus such a long delay should not be needed. The original spec from the clean-room group 
> was a delay loop of 1000. I'm currently testing that value now. If it passes the test, would a for 
> (i=1000; i; i--) be acceptable?

Short: Don't touch it. Fullstop.

Long: The delay will _never_ be exhausted. Actually the for-counter
is only there to not lock up the machine, if there is a Bug in the
driver. (__much__ easier debugging).
The loop will only iterate a few times, typically.
Actually, _if_ we want to change something, we should do this:

for (i = 1000000; i; i--) {
	...
	udelay(1);
}

(max loop multiplied by 10, delay value divided by 10).
This will shorten the whole delay by a few usecs (up to 10).
I will send a patch for this, if it is desired.

But lowering the loop counter value is NACKed by me,
because it simply does not make sense.

-- 
Greetings Michael.
