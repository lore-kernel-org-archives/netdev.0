From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred probe
 from init
Date: Mon, 28 Jul 2014 11:55:38 -0700
Message-ID: <20140728185538.GB17609@kroah.com>
References: <1406572110-26823-1-git-send-email-mcgrof@do-not-panic.com>
 <1406572110-26823-3-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tiwai@suse.de, linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1406572110-26823-3-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2014 at 11:28:28AM -0700, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> Tetsuo bisected and found that commit 786235ee "kthread: make
> kthread_create() killable" modified kthread_create() to bail as
> soon as SIGKILL is received. This is causing some issues with
> some drivers and at times boot. Joseph then found that failures
> occur as the systemd-udevd process sends SIGKILL to modprobe if
> probe on a driver takes over 30 seconds.

Because no driver should ever take that long for their probe function to
return.  Why not fix those drivers?

> When this happens probe will fail on any driver, its why booting on
> some system will fail if the driver happens to be a storage related
> driver. Some folks
> have suggested fixing this by modifying kthread_create() to not
> leave upon SIGKILL [3], upon review Oleg rejected this change and
> the discussion was punted out to systemd to see if the default
> timeout could be increased from 30 seconds to 120. The opinion of
> the systemd maintainers is that the driver's behavior should
> be fixed [4]. Linus seems to agree [5], however more recently even
> networking drivers have been reported to fail on probe since just
> writing the firmware to a device and kicking it can take easy over
> 60 seconds [6]. Benjamim was able to trace the issues recently
> reported on cxgb4 down to the same systemd-udevd 30 second timeout [6].

Then use the async firmware interface, why is any driver taking longer
than less than a second in their init function?

> This is an alternative solution which enables drivers that are
> known to take long to use deferred probe workqueue. This avoids
> the 30 second timeout and lets us annotate drivers with long
> init sequences.
> 
> As drivers determine a component is not yet available and needs
> to defer probe you'll be notified this happen upon init for each
> device but now with a message such as:
> 
> pci 0000:03:00.0: Driver cxgb4 requests probe deferral on init
> 
> You should see one of these per struct device probed.

I'm all for abusing kernel interfaces, but please, no, don't try to use
the deferred init code to cover up for broken drivers.  Just fix them
properly, we have the interfaces to handle it properly (i.e. async
firmware loading), please use it.

And no PCI driver should ever need "deferred init" as the resources for
such a device is already present in the system.  Now if userspace is up
and running yet is a different issue, one that deferred init is not
there for at all, sorry.

So, what drivers are having problems in their init sequence, and why
aren't they using async firmware loading?

thanks,

greg k-h
