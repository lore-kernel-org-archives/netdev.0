From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 1/3] init / kthread: add module_long_probe_init()
	and module_long_probe_exit()
Date: Mon, 18 Aug 2014 17:19:54 +0200
Message-ID: <20140818151954.GA20284@redhat.com>
References: <20140816025007.GB3347@wotan.suse.de> <s5h1tsfwqi2.wl-tiwai@suse.de> <20140817122527.GA30546@redhat.com> <20140817124803.GA31996@redhat.com> <20140817125505.GA32429@redhat.com> <20140817174624.GE3347@wotan.suse.de> <20140817182138.GA4411@redhat.com> <s5hfvguw570.wl-tiwai@suse.de> <20140818122217.GA12707@redhat.com> <s5ha97253yo.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@suse.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
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
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <s5ha97253yo.wl-tiwai@suse.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/18, Takashi Iwai wrote:
>
> At Mon, 18 Aug 2014 14:22:17 +0200,
> Oleg Nesterov wrote:
> >
> > On 08/18, Takashi Iwai wrote:
> > >
> > > #define module_long_probe_init(initfn)				\
> > > 	static int _long_probe_##initfn(void *arg)		\
> > > 	{							\
> > > 		module_put_and_exit(initfn());			\
> > > 		return 0;					\
> > > 	}							\
> > > 	static int __init __long_probe_##initfn(void)		\
> > > 	{							\
> > > 		struct task_struct *__init_thread =		\
> > > 			kthread_create(_long_probe_##initfn,	\
> > > 				       NULL, #initfn);		\
> > > 		if (IS_ERR(__init_thread))			\
> > > 			return PTR_ERR(__init_thread);		\
> > > 		__module_get(THIS_MODULE);			\
> > > 		wake_up_process(__init_thread);			\
> > > 		return 0;					\
> > > 	}							\
> > > 	module_init(__long_probe_##initfn)
> > >
> > > ... and module_exit() remains identical as the normal version.
> >
> > Aaaah. This is not true, module_exit() should not call exitfn() if initfn()
> > fails... So _long_probe_##initfn() needs to save the error code which should
> > be checked by module_exit().
>
> Oh, right.  So we need a reference in the module exit path in anyway,

We only need to save the error code,

	static int _long_probe_retval;

	static int _long_probe_##initfn(void *arg)
	{
		_long_probe_retval = initfn();
		module_put_and_exit(0); /* noreturn */
	}

	static void __long_probe_##exitfn(void)
	{
		if (!_long_probe_retval)
			exitfn();
	}

> and Luis' version might be shorter in the end.

I dont't think that "shorter" does matter in this case. The real difference
is sys_delete_module() behaviour if it is called before initfn() completes.

And, again, I do not really know which version is better.

Oleg.

