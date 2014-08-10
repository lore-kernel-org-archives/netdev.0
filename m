From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred probe
 from init
Date: Sun, 10 Aug 2014 20:43:31 +0800
Message-ID: <20140810124331.GE30451@kroah.com>
References: <1406572110-26823-1-git-send-email-mcgrof@do-not-panic.com>
 <1406572110-26823-3-git-send-email-mcgrof@do-not-panic.com>
 <20140730.151107.1328294951387764830.davem@davemloft.net>
 <20140809164119.GI21930@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mcgrof@do-not-panic.com,
	tiwai@suse.de, linux-kernel@vger.kernel.org,
	penguin-kernel@I-love.SAKURA.ne.jp, joseph.salisbury@canonical.com,
	kay@vrfy.org, gnomes@lxorguk.ukuu.org.uk,
	tim.gardner@canonical.com, pierre-fersing@pierref.org,
	akpm@linux-foundation.org, oleg@redhat.com, bpoirier@suse.de,
	nagalakshmi.nandigama@avagotech.com,
	praveen.krishnamoorthy@avagotech.com,
	sreekanth.reddy@avagotech.com, abhijit.mahajan@avagotech.com,
	hariprasad@chelsio.com, santosh@chelsio.com,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:42934 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbaHJMoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 08:44:07 -0400
Content-Disposition: inline
In-Reply-To: <20140809164119.GI21930@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 09, 2014 at 06:41:19PM +0200, Luis R. Rodriguez wrote:
> On Wed, Jul 30, 2014 at 03:11:07PM -0700, David Miller wrote:
> > From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
> > Date: Mon, 28 Jul 2014 11:28:28 -0700
> > 
> > > Tetsuo bisected and found that commit 786235ee "kthread: make
> > > kthread_create() killable" modified kthread_create() to bail as
> > > soon as SIGKILL is received. This is causing some issues with
> > > some drivers and at times boot. Joseph then found that failures
> > > occur as the systemd-udevd process sends SIGKILL to modprobe if
> > > probe on a driver takes over 30 seconds. When this happens probe
> > > will fail on any driver, its why booting on some system will fail
> > > if the driver happens to be a storage related driver. Some folks
> > > have suggested fixing this by modifying kthread_create() to not
> > > leave upon SIGKILL [3], upon review Oleg rejected this change and
> > > the discussion was punted out to systemd to see if the default
> > > timeout could be increased from 30 seconds to 120. The opinion of
> > > the systemd maintainers is that the driver's behavior should
> > > be fixed [4]. Linus seems to agree [5], however more recently even
> > > networking drivers have been reported to fail on probe since just
> > > writing the firmware to a device and kicking it can take easy over
> > > 60 seconds [6]. Benjamim was able to trace the issues recently
> > > reported on cxgb4 down to the same systemd-udevd 30 second timeout [6].
> > > 
> > > This is an alternative solution which enables drivers that are
> > > known to take long to use deferred probe workqueue. This avoids
> > > the 30 second timeout and lets us annotate drivers with long
> > > init sequences.
> > > 
> > > As drivers determine a component is not yet available and needs
> > > to defer probe you'll be notified this happen upon init for each
> > > device but now with a message such as:
> > > 
> > > pci 0000:03:00.0: Driver cxgb4 requests probe deferral on init
> > > 
> > > You should see one of these per struct device probed.
> > 
> > It seems we're still discussing this.
> > 
> > I think I understand all of the underlying issues, and what I'll say
> > is that perhaps we should use what Greg KH requested but via a helper
> > that is easy to grep for.
> > 
> > I don't care if it's something like "module_long_probe_init()" and
> > "module_long_probe_exit()", but it just needs to be some properly
> > named interface which does the whole kthread or whatever bit.
> 
> I've tested the alternative kthread_run() proposal but unfortunately it
> does not help resolve the issue, the timeout is still hit and a SIGKILL
> still kills the driver probe. Please let me know how you'd all like us
> to proceed, these defer probe patches do help cure the issue though.

Why doesn't it work?  Doesn't modprobe come right back and the init
sequence still takes a while to run?  What exactly fails?

thanks,

greg k-h
