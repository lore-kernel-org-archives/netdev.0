From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 17:25:25 +0200
Message-ID: <200606271725.26037.mb@bu3sch.de>
References: <20060626212547.GE30706@tuxdriver.com> <200606271530.06749.mb@bu3sch.de> <44A13C81.2050503@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:13798
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161097AbWF0PZc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 11:25:32 -0400
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

Ok, I did a testrun. Here's the result:

[   68.711243] bcm43xx_d80211: Chip ID 0x4306, rev 0x3
[   68.712662] bcm43xx_d80211: Number of cores: 5
[   68.714023] bcm43xx_d80211: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
[   68.715536] bcm43xx_d80211: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
[   68.717062] bcm43xx_d80211: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
[   68.718575] bcm43xx_d80211: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
[   68.720089] bcm43xx_d80211: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
[   68.724897] bcm43xx_d80211: PHY connected
[   68.726154] bcm43xx_d80211: Detected PHY: Version: 2, Type 2, Revision 2
[   68.727638] bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
[   68.729232] bcm43xx_d80211: Radio turned off
[   68.730512] bcm43xx_d80211: Radio turned off
[   68.745153] wmaster0: Selected rate control algorithm 'simple'
[   69.853876] bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 7, MAC: 00:11:24:a0:de:8b)
[   69.861872] bcm43xx_d80211: PHY connected
[   70.000713] bcm43xx_d80211: Radio turned on
[   70.190153] bcm43xx_d80211: Chip initialized
[   70.192051] bcm43xx_d80211: DMA initialized
[   70.193987] bcm43xx_d80211: 80211 cores initialized
[   70.195550] bcm43xx_d80211: Keys cleared
[   70.212565] wmaster0: Does not support passive scan, disabled
[   70.252321] bcm43xx_d80211: mac_suspend() took 1 loops == 10 usec
[   70.542160] NET: Registered protocol family 17
[   70.692256] sta0: starting scan
[   70.702234] HW CONFIG: channel=1 freq=2412 phymode=3
[   70.762225] HW CONFIG: channel=2 freq=2417 phymode=3
[   70.822227] HW CONFIG: channel=3 freq=2422 phymode=3
[   70.882225] HW CONFIG: channel=4 freq=2427 phymode=3
[   70.942225] HW CONFIG: channel=5 freq=2432 phymode=3
[   71.002285] HW CONFIG: channel=6 freq=2437 phymode=3
[   71.062229] HW CONFIG: channel=7 freq=2442 phymode=3
[   71.122230] HW CONFIG: channel=8 freq=2447 phymode=3
[   71.182239] HW CONFIG: channel=9 freq=2452 phymode=3
[   71.242226] HW CONFIG: channel=10 freq=2457 phymode=3
[   71.302226] HW CONFIG: channel=11 freq=2462 phymode=3
[   71.512225] HW CONFIG: channel=1 freq=2412 phymode=3
[   71.520066] sta0: scan completed
[   71.523437] HW CONFIG: channel=6 freq=2437 phymode=3
[   71.531600] sta0: Initial auth_alg=0
[   71.531806] sta0: authenticate with AP 00:90:4c:60:04:00
[   71.533279] sta0: RX authentication from 00:90:4c:60:04:00 (alg=0 transaction=2 status=0)
[   71.533292] sta0: authenticated
[   71.533301] sta0: associate with AP 00:90:4c:60:04:00
[   71.536264] sta0: RX AssocResp from 00:90:4c:60:04:00 (capab=0x411 status=0 aid=1)
[   71.536276] sta0: associated
[   71.536352] wmaster0: Added STA 00:90:4c:60:04:00
[  130.292251] bcm43xx_d80211: mac_suspend() took 1 loops == 10 usec
[  190.322251] bcm43xx_d80211: mac_suspend() took 1 loops == 10 usec
[  250.362252] bcm43xx_d80211: mac_suspend() took 0 loops == 0 usec
[  310.392278] bcm43xx_d80211: mac_suspend() took 1 loops == 10 usec

So, I will submit a patch to lower the udelay(10) to udelay(1)
and we can close the discussion? ;)

-- 
Greetings Michael.
