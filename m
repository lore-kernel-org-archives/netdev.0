From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred probe
 from init
Date: Tue, 29 Jul 2014 16:14:22 -0700
Message-ID: <20140729231422.GA14494@kroah.com>
References: <1406572110-26823-1-git-send-email-mcgrof@do-not-panic.com>
 <1406572110-26823-3-git-send-email-mcgrof@do-not-panic.com>
 <20140728185538.GB17609@kroah.com>
 <CAB=NE6VebcR7=UA1n0wNVLr5FFukzq6aW5CkeB3nf5FixV=3cA@mail.gmail.com>
 <CAB=NE6Xmi2zUCis22q+X8_AKRcwMrAtmx-aqSSvTB70Xjet6VQ@mail.gmail.com>
 <20140728234644.GA18729@kroah.com>
 <CAB=NE6UzK1ZEzm+54dwSyPwHGrAWCPtiNtxwhQuJF6tM9NbnYw@mail.gmail.com>
 <20140729003501.GA17020@kroah.com>
 <CAB=NE6XMzU+zJ0RMDKaPuSxfXBvN2vZ1DnbgxCjWHJquTD1iqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Santosh Rastapur <santosh@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Takashi Iwai <tiwai@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
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
	MPT-FusionLinux.pdl@avagotech.com,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6XMzU+zJ0RMDKaPuSxfXBvN2vZ1DnbgxCjWHJquTD1iqg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2014 at 06:13:43PM -0700, Luis R. Rodriguez wrote:
> >> > Why not just put the initial "register the device" in a single-shot
> >> > workqueue or thread or something like that so that modprobe returns
> >> > instantly back with a success and all is fine?
> >>
> >> That surely is possible but why not a general solution for such kludges?
> >
> > Because the driver should be fixed.  How hard would it be to do what I
> > just suggested here, 20 lines added at most?
> 
> I appreciate the feedback, but don't look at me, I'd happy to go nutty
> on ripping things apart from hairy drivers, however Chelsie folks
> expressed concerns over major rework on the driver... so even if we
> did have something I expect things to take a while to bake / gain
> confidence from others.

"rework"?  Heh, here's a patch that adds 10 lines to the mptsas driver
that should also work for any other driver as well.  Why not just do
this instead?

> This also just addresses this *one* Ethernet driver, there was that
> SCSI driver that created the original report -- Canonical merged
> Joseph's fix as a work around,

What fix was that?

> there is no general solution for this yet, and again with that work
> around you won't find which drivers run into this issue.

Great, fix them as they are found, that's fine.  Again, don't add stuff
to the driver core to paper over crappy drivers, I'm not going to take
that type of change.  I _only_ took the defer binding code as there was
no other way for an individual driver to deal with things if it's
resources were not present yet due to binding order in the system.

So, anyone care to test the patch below on a system that has this
problem to let me know if it would work or not?  Odds are, this should
be a workqueue, to make it cleaner, but a kthread is just so easy to
use...

thanks,

greg k-h

diff --git a/drivers/message/fusion/mptsas.c b/drivers/message/fusion/mptsas.c
index 711fcb5cec87..4fd4f36a2d9e 100644
--- a/drivers/message/fusion/mptsas.c
+++ b/drivers/message/fusion/mptsas.c
@@ -51,6 +51,7 @@
 #include <linux/jiffies.h>
 #include <linux/workqueue.h>
 #include <linux/delay.h>	/* for mdelay */
+#include <linux/kthread.h>
 
 #include <scsi/scsi.h>
 #include <scsi/scsi_cmnd.h>
@@ -5393,8 +5394,7 @@ static struct pci_driver mptsas_driver = {
 #endif
 };
 
-static int __init
-mptsas_init(void)
+static int mptsas_real_init(void *data)
 {
 	int error;
 
@@ -5429,9 +5429,19 @@ mptsas_init(void)
 	return error;
 }
 
+static struct task_struct *init_thread;
+
+static int __init
+mptsas_init(void)
+{
+	init_thread = kthread_run(mptsas_real_init, NULL, "mptsas_init");
+	return 0;
+}
+
 static void __exit
 mptsas_exit(void)
 {
+	kthread_stop(init_thread);
 	pci_unregister_driver(&mptsas_driver);
 	sas_release_transport(mptsas_transport_template);
 
