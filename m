From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v2 2/4] driver core: enable drivers to use deferred
	probefrom init
Date: Wed, 30 Jul 2014 16:26:53 +0200
Message-ID: <20140730142653.GT21930@wotan.suse.de>
References: <20140728234644.GA18729@kroah.com> <CAB=NE6UzK1ZEzm+54dwSyPwHGrAWCPtiNtxwhQuJF6tM9NbnYw@mail.gmail.com> <20140729003501.GA17020@kroah.com> <CAB=NE6XMzU+zJ0RMDKaPuSxfXBvN2vZ1DnbgxCjWHJquTD1iqg@mail.gmail.com> <53D744E3.10500@suse.de> <201407292107.EGB64066.OOQMFSHLJVtFFO@I-love.SAKURA.ne.jp> <20140729222529.GC21140@f1.synalogic.ca> <20140730001434.GS21930@wotan.suse.de> <201407300222.s6U2MElj035655@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hare@suse.de, gregkh@linuxfoundation.org, santosh@chelsio.com,
	hariprasad@chelsio.com, tiwai@suse.de,
	linux-kernel@vger.kernel.org, joseph.salisbury@canonical.com,
	kay@vrfy.org, gnomes@lxorguk.ukuu.org.uk,
	tim.gardner@canonical.com, pierre-fersing@pierref.org,
	akpm@linux-foundation.org, oleg@redhat.com,
	nagalakshmi.nandigama@avagotech.com,
	praveen.krishnamoorthy@avagotech.com,
	sreekanth.reddy@avagotech.com, abhijit.mahajan@avagotech.com,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, bpoirier@suse.de
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201407300222.s6U2MElj035655@www262.sakura.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 30, 2014 at 11:22:14AM +0900, Tetsuo Handa wrote:
> Luis R. Rodriguez wrote:
> > Tetsuo is it possible / desirable to allow tasks to not kill unless the
> > reason is OOM ? Its unclear if this was discussed before, sorry if it was,
> > have just been a bit busy today to review the archive / discussions on this.
> 
> Are we aware that the 10 seconds timeout after SIGKILL is not the duration
> between the beginning of module loading and the end of kthread_create() but
> the duration to wait for kthreadd to create a new kernel thread?
> 
> If the kthreadd is unable to create a new kernel thread within 10 seconds,
> something very bad is happening. For example, memory allocation deadlock
> sequence shown below might be happening.
> 
>  (1) process1 holds a mutex using mutex_lock().
>  (2) process1 calls kthread_create() and enters into killable wait state
>      at wait_for_completion_killable().
>  (3) kthreadd calls kernel_thread() and enters into oom-killable busy loop
>      due to out of memory at alloc_pages_nodemask().
>  (4) process2 is chosen by the OOM killer, but process2 is unable to
>      terminate because process2 is waiting in unkillable state at
>      mutex_lock() which was held by process1 at (1).
>  (5) kthreadd continues busy loop because process2 does not release memory
>      and the OOM killer does not kill more processes.
>  (6) process1 continues waiting in oom-killable state because process1 is
>      not chosen by the OOM killer.
> 
> See? The system will remain unresponding unless somebody releases memory
> that is enough for kthreadd to complete.

I see but we're talking about large systems with gobs of memory so I'm pretty
sure memory should not be the issue here.

> We cannot teach process1 that
> process1 needs to give up waiting for kthreadd and call mutex_unlock()
> in order to allow process2 to terminate. Also, we cannot teach the OOM
> killer that process1 needs to be oom-killed after process2 is oom-killed.
> 
> Making the 10 seconds timeout after SIGKILL longer is safe.
> Changing it to no-timeout-unless-oom-killed is unsafe.

To be clear we have *not* merged the 10 second workaround:

https://launchpadlibrarian.net/169714201/kthread-Do-not-leave-kthread_create-immediately.patch

and come to think of it the work aroaund is aligned with what I was thinking
*without *waiting for 10 seconds, but my question was whether or not it was
reasonable to have the process request to go through this excemption.
So we would not do this all the time, but only for processes that would
request this, in this case modprobe.

  Luis
