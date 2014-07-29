From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred probefrom init
Date: Tue, 29 Jul 2014 21:07:24 +0900
Message-ID: <201407292107.EGB64066.OOQMFSHLJVtFFO@I-love.SAKURA.ne.jp>
References: <20140728234644.GA18729@kroah.com>
	<CAB=NE6UzK1ZEzm+54dwSyPwHGrAWCPtiNtxwhQuJF6tM9NbnYw@mail.gmail.com>
	<20140729003501.GA17020@kroah.com>
	<CAB=NE6XMzU+zJ0RMDKaPuSxfXBvN2vZ1DnbgxCjWHJquTD1iqg@mail.gmail.com>
	<53D744E3.10500@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh@chelsio.com, hariprasad@chelsio.com, tiwai@suse.de,
	linux-kernel@vger.kernel.org, joseph.salisbury@canonical.com,
	kay@vrfy.org, gnomes@lxorguk.ukuu.org.uk,
	tim.gardner@canonical.com, pierre-fersing@pierref.org,
	akpm@linux-foundation.org, oleg@redhat.com, bpoirier@suse.de,
	nagalakshmi.nandigama@avagotech.com,
	praveen.krishnamoorthy@avagotech.com,
	sreekanth.reddy@avagotech.com, abhijit.mahajan@avagotech.com,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: hare@suse.de, mcgrof@suse.com, gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53D744E3.10500@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> On Mon, Jul 28, 2014 at 5:35 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Mon, Jul 28, 2014 at 05:26:34PM -0700, Luis R. Rodriguez wrote:
> >> To ignore SIGKILL ?
> >
> > Sorry, I thought this was a userspace change that caused this.
> >
> > As it's a kernel change, well, maybe that patch should be reverted...
> 
> That's certainly viable. Oleg?

I don't want to revert that patch.

I'm trying to reduce use of blocking operations that wait in unkillable state,
for the OOM killer is optimistic enough to wait forever even if the OOM-killed
process cannot be terminated due to having dependency on other threads that are
waiting the OOM-killed process to terminate and release memory. Linux kernel is
too optimistic about memory reclaim; memory allocation/reclaim deadlock is not
detectable.

> 
> If its reverted we won't know which drivers are hitting over the new
> 30 second limit requirement imposed by userspace, which the culprit
> commit forces failure on probe now. This series at least would allow
> us to annotate which drivers are brake the 30 second init limit, and
> enable a work around alternative if we wish to not revert the commit.
> This  series essentially should be considered an alternative solution
> to what was proposed initially by Joseph Salisbury, it may not be
> perfect but its a proposal. I welcome others.
(...snipped...)
> This also just addresses this *one* Ethernet driver, there was that
> SCSI driver that created the original report -- Canonical merged
> Joseph's fix as a work around, there is no general solution for this
> yet, and again with that work around you won't find which drivers run
> into this issue. There may be others found later so this is why I
> resorted to the deferred workqueue as a solution for now and to enable
> us to annotate which drivers need fixing as I expect getting the fix
> done / everyone happy can take time.

If you want to know which drivers are hitting over the new 30 second
limit requirement but don't want to break the boot, I think we can do
"what Ubuntu chose as a work around" + "a warning message" like below.

diff --git a/kernel/kthread.c b/kernel/kthread.c
index c2390f4..43da2b1 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -292,6 +292,26 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 	 * new kernel thread.
 	 */
 	if (unlikely(wait_for_completion_killable(&done))) {
+		int i = 0;
+
+		/*
+		 * I got SIGKILL, but wait for 10 more seconds for completion
+		 * unless chosen by the OOM killer. This delay is there as a
+		 * workaround for boot failure caused by SIGKILL upon device
+		 * driver initialization timeout.
+		 */
+		if (!test_tsk_thread_flag(current, TIF_MEMDIE)) {
+			pr_warn("I already got SIGKILL but ignoring it up to "
+				"10 seconds, in case the caller can't survive "
+				"fail-immediately-upon-SIGKILL event. "
+				"Please make sure that the caller can survive "
+				"this event, for this delay will be removed "
+				"in the future.\n");
+			dump_stack();
+		}
+		while (i++ < 10 && !test_tsk_thread_flag(current, TIF_MEMDIE))
+			if (wait_for_completion_timeout(&done, HZ))
+				goto ready;
 		/*
 		 * If I was SIGKILLed before kthreadd (or new kernel thread)
 		 * calls complete(), leave the cleanup of this structure to
@@ -305,6 +325,7 @@ struct task_struct *kthread_create_on_node(int (*threadfn)(void *data),
 		 */
 		wait_for_completion(&done);
 	}
+ready:
 	task = create->result;
 	if (!IS_ERR(task)) {
 		static const struct sched_param param = { .sched_priority = 0 };

Hannes Reinecke wrote:
> Well ... from my POV there are two issues here:
> 
> The one is that systemd essentially nailed its internal worker 
> timeout to 30 seconds. And there is no way of modifying that short 
> of recompiling. Which should be fixed, so that at least one can
> modify this timeout.
> 
> The other one is that systemd killing a worker by sending SIGKILL, 
> which will kill modprobe terminally.
> Which definitely needs to be fixed.
> 
> But if we have both issues resolved (eg by allowing udevd to use a 
> longer timeout and revert the latter patch) we can identify the 
> offending drivers _and_ get the system to boot by simply adding a 
> kernel commandline parameter.
> Which is _far_ preferrable from a maintenance perspective.
> Users tend to become annoyed if their system doesn't boot ...

The proposal which allows longer timeout was expired.
https://bugs.launchpad.net/bugs/1297248
