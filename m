From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: e100 shutdown breaks e100 probing when using kexec
Date: Wed, 22 Apr 2009 21:55:57 +0200
Message-ID: <200904222155.57724.rjw@sisk.pl>
References: <20090422183242.GH4691@vespa.holoscopio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:36112 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140AbZDVT4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2009 15:56:46 -0400
In-Reply-To: <20090422183242.GH4691@vespa.holoscopio.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 22 April 2009, Thadeu Lima de Souza Cascardo wrote:
> Hello, folks.

Hi,

> As seen recently, I've sent a bugfix for the e100 shutdown in the same
> lines as the patches proposed by RWJ to e1000, e1000e and some other
> network devices.
> 
> I would like to get some light about the need to disable wake when
> suspending if there is no WOL support, if most, if not all, resume and
> probe code already do it. If it is really needed, perhaps, an utility
> helper function could be written and most drivers migrated to it.

If I understand the problem correctly, e100 sometimes doesn't proble
successfully after kexec if it was put into D3 before.  If that's really the
case, I don't think it's related to wake-up at all.  The very same issue has
been obseverd for some other devices and I don't think we know the root cause
of it.  Still, the solution seems to be not to put devices into D3 on shutdown
unless we're going to power off the entire system.

> But another issue is that, in some particular cases, although the device
> was put in D3 state with wake enabled, I could get it back working even
> when using kexec. In particular, when the system resumes, it can get it
> back working anyway. So there should be something we could do while
> probing to wake up these devices. This would allow people running old
> systems to kexec into new ones. If there's little or no drawback in the
> approach, I think added robustness for probing a PCI device is a plus
> anyway.

This may be unrelated to the probing of PCI devices or at least not directly
related to it.  There may be something we need to do to the host bridge or
generally to the chipset for things to actually work.

> So, I will tell what I've done while looking for the problem so there is
> some hidden hint in there. If I am in a wild-goose chase here or there's
> no use or interest in something like this, please tell me so and I'll
> stop bothering you all. :-)
> 
> Since the PCI code already sets the power state to D0 and disable wake
> before calling probe function, there was no use doing the following in
> probe.
> 
>         pci_set_power_state(pdev, PCI_D0);
>         pci_enable_wake(pdev, 0, 0);
> 
> I've tested it and it did not work.
> 
> Doing pci_restore_state, which should not work at all, in probe, seemed
> to work, but perhaps it was because of some of the other reasons below.
> Don't trust this information. It's stupid anyway.
> 
> Most configurations with earlier releases like 2.6.29 did work. I had
> problems when some commits were introduced that I've found out while
> bisecting. In particular, one patch changing how uevent_helper is called
> and configuring the helper to empty did activate the bug in earlier
> releases.
> 
> kobject: don't block for each kobject_uevent
> [ upstream commit: f520360d93cdc37de5d972dac4bf3bdef6a7f6a7 ]
> 
> This commit is the one that seemed to start it all. It has already been
> reverted in v2.6.30-rc2, AFAIK.
> 
> CONFIG_UEVENT_HELPER_PATH=""
> 
> This configuration also had an effect. With that, I could hit the bug
> with releases earlier than v2.6.29. This all with a minimal, almost
> allnoconfig. When adding some things, like initramfs or other drivers,
> the probe went well and the device at least registered.
> 
> I thought this could be related to some delay or some race condition.

The race need not be in there.

> I've used some msleep or udelay (this is UP) in the probe, but with no
> success.
> 
> I've also noticed my e100 device is after a bridge. Since I didn't know
> much about PCI PM, I thought this could be related, but could find
> nothing about it.
> 
> Any thoughts on that?

Well, please send the output of dmesg and /proc/iomem from the box.

Thanks,
Rafael
