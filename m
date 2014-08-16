From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v3 1/3] init / kthread: add module_long_probe_init()
	and module_long_probe_exit()
Date: Sat, 16 Aug 2014 04:50:07 +0200
Message-ID: <20140816025007.GB3347@wotan.suse.de>
References: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com> <1407882507-325-2-git-send-email-mcgrof@do-not-panic.com> <20140813175101.GA7156@redhat.com> <20140814231028.GQ21930@wotan.suse.de> <20140815143902.GB13222@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	gregkh@linuxfoundation.org, tiwai@suse.de,
	linux-kernel@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140815143902.GB13222@redhat.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 15, 2014 at 04:39:02PM +0200, Oleg Nesterov wrote:
> On 08/15, Luis R. Rodriguez wrote:
> >
> > On Wed, Aug 13, 2014 at 07:51:01PM +0200, Oleg Nesterov wrote:
> > > On 08/12, Luis R. Rodriguez wrote:
> > > >
> > > > +/* To be used by modules which can take over 30 seconds at probe */
> > >
> > > Probably the comment should explain that this hack should only be
> > > used if the driver is buggy and is wating for "real fix".
> > >
> > > > +#define module_long_probe_init(initfn)				\
> > > > +	static struct task_struct *__init_thread;		\
> > > > +	static int _long_probe_##initfn(void *arg)		\
> > > > +	{							\
> > > > +		return initfn();				\
> > > > +	}							\
> > > > +	static inline __init int __long_probe_##initfn(void)	\
> > > > +	{							\
> > > > +		__init_thread = kthread_run(_long_probe_##initfn,\
> > > > +					    NULL,		\
> > > > +					    #initfn);		\
> > > > +		if (IS_ERR(__init_thread))			\
> > > > +			return PTR_ERR(__init_thread);		\
> > > > +		return 0;					\
> > > > +	}							\
> > > > +	module_init(__long_probe_##initfn);
> > > > +/* To be used by modules that require module_long_probe_init() */
> > > > +#define module_long_probe_exit(exitfn)				\
> > > > +	static inline void __long_probe_##exitfn(void)		\
> > > > +	{							\
> > > > +		exitfn();					\
> > > > +		if (__init_thread)				\
> > > > +			kthread_stop(__init_thread);		\
> > > > +	}							\
> > >
> > > exitfn() should be called after kthread_stop(), and only if initfn()
> > > returns 0. So it should probably do
> > >
> > > 	int err = kthread_stop(__init_thread);
> > > 	if (!err)
> > > 		exitfn();
> >
> > Thanks! With the check for __init_thread as well as it can be
> > ERR_PTR(-ENOMEM), ERR_PTR(-EINTR), or NULL (for whatever other
> > reason).
> 
> Do you mean __long_probe_##exitfn() should also check ERR_PTR(__init_thread)?
> I don't think so. If kthread_run() above fails, module_init() should return
> the error (it does), so module_exit() won't be called.

Good point.

> > > But there is an additional complication, you can't use __init_thread
> > > without get_task_struct(),
> >
> > Can you elaborate why ? kthread_stop() uses get_task_struct(),
> 
> This is too late. This task_struct can be already freed/reused. See below.
> 
> > wake_up_process() and finally put_task_struct(), and we're the
> > only user of this thread. Also kthread_run() ensures wake_up_process()
> > gets called on startup, so not sure where the race would be provided
> > all users here and with the respective helpers on buggy drivers.
> >
> > > so  __long_probe_##initfn() can't use
> > > kthread_run(). It needs kthread_create() + get_task_struct() + wakeup.
> >
> > I fail to see why we'd need to add get_task_struct() on
> > module_long_probe_init(), can you clarify?
> 
> kthread_stop(kthread_run(callback)) is only safe if callback() can not exit
> on its own, without checking kthread_should_stop(). And btw that is why
> kthread_stop() does get_task_struct()).
> 
> If callback() can exit (if it calls do_exit() or simply returns), then nothing
> protects this task_struct, it will be freed.

OK thanks, yeah I see the issue now, and I was able to create a null
pointer dereference by simply calling schedule() quite a bit, will
roll in the required fixes, but come to think of it if there are
other uses (I haven't SmPLd grep'd for grammar uses yet) perhaps
generic helpers would be good? kthread_run_alloc() kthread_run_free().

  Luis
