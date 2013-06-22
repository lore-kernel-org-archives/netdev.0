From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Sat, 22 Jun 2013 12:17:58 +0200
Message-ID: <20130622101758.GA5427@sig21.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
 <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
 <1371764438.8333.20.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	mcgrof@do-not-panic.com, kvalo@adurom.com, adrian.chadd@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:41489 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586Ab3FVKTp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jun 2013 06:19:45 -0400
Content-Disposition: inline
In-Reply-To: <1371764438.8333.20.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 11:40:38PM +0200, Johannes Berg wrote:
> 
> On Tue, 2013-06-18 at 02:18 +0100, Ben Hutchings wrote:

> > > +	/* Workaround for PCI problem when BIOS sets MMRBC incorrectly. */
> > > +	pci_read_config_word(hw->pdev, PCI_COMMAND, &val16);
> > > +	if (!(val16 & ALX_PCI_CMD) || (val16 & PCI_COMMAND_INTX_DISABLE)) {
> > > +		val16 = (val16 | ALX_PCI_CMD) & ~PCI_COMMAND_INTX_DISABLE;
> > > +		pci_write_config_word(hw->pdev, PCI_COMMAND, val16);
> > > +	}
> > [...]
> > 
> > I don't understand what this is trying to work around but it looks
> > extremely dodgy.  The driver already appears to be doing
> > pci_{save,restore}_state() in suspend/resume which is the right thing to
> > do.
> 
> I have no idea, but ~PCI_COMMAND_INTX_DISABLE seems really just like
> what we do with PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG... maybe this was
> some sort of workaround for that.
> 
> Johannes, can you try to remove this chunk of code and see if your
> device still works? If so I'd just kill it.

I removed it and did a full power cycle, alx still works.
Also tried suspend-to-RAM and alx still works.  However,
since the comment for this code is about BIOS bugs it might
be that it is required on some other machine?  Not sure
if it is wise to remove it...

Another thing: When testing suspend-to-RAM my machine immediately
woke up.  ethtool said wol is enabled by default:
        Supports Wake-on: pg
	Wake-on: pg
but even after "ethtool -s eth0 wol d" it still woke up.
I did a few experiments, it seems that once the alx driver
is loaded, even when the interface is down, the other end
of the link (laptop with e1000e) reports the link goes
into 10Mbit/s speed during suspend (actually it goes
1G -> down -> 10M), I have to unplug the cable to
prevent the wakeup.  Even after "ifconfig eth down"
and "rmmod alx" the link is still up.

  # ethtool -s eth0 wol d
  # ifconfig eth0 down
  # ethtool eth0
  ...
         Wake-on: d
         Link detected: no

But the link LEDs are still on and the other side says
"Link detected: yes" and it can't get some sleep.

I think hw->sleep_ctrl should be initialized to 0 in alx_init_sw(),
but I cannot find why the link stays up after "ifconfig eth0 down".


Thanks,
Johannes
