From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 1/3] init / kthread: add module_long_probe_init() and
	module_long_probe_exit()
Date: Sun, 17 Aug 2014 14:25:27 +0200
Message-ID: <20140817122527.GA30546@redhat.com>
References: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com> <1407882507-325-2-git-send-email-mcgrof@do-not-panic.com> <20140813175101.GA7156@redhat.com> <20140814231028.GQ21930@wotan.suse.de> <20140815143902.GB13222@redhat.com> <20140816025007.GB3347@wotan.suse.de> <s5h1tsfwqi2.wl-tiwai@suse.de>
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
In-Reply-To: <s5h1tsfwqi2.wl-tiwai@suse.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17, Takashi Iwai wrote:
>
> How about just increasing/decreasing the module count for blocking the
> exit call?  For example:
>
> #define module_long_probe_init(initfn)				\
> 	static int _long_probe_##initfn(void *arg)		\
> 	{							\
> 		int ret = initfn();				\
> 		module_put(THIS_MODULE);			\

WINDOW, please see below.

> 		return ret;					\
> 	}							\
> 	static inline __init int __long_probe_##initfn(void)	\
> 	{							\
> 		struct task_struct *__init_thread;		\
> 		__module_get(THIS_MODULE);			\
> 		__init_thread = kthread_run(_long_probe_##initfn,\
> 					    NULL,		\
> 					    #initfn);		\
> 		if (IS_ERR(__init_thread)) {			\
> 			module_put(THIS_MODULE);		\
> 			return PTR_ERR(__init_thread);		\
> 		}						\
> 		return 0;					\
> 	}							\

I leave this to you and Luis, but personally I think this is very
nice idea, I like it. Because sys_delete_module() won't hang in D
state waiting for initfn().

There is a small problem. This module can be unloaded right after
module_put() above. In this case its memory can be unmapped and
the exiting thread can crash.

This is very unlikely, this thread needs to execute just a few insn
and escape from this module's memory. Given that only the buggy
modules should use this hack, perhaps we can even ignore this race.

But perhaps it makes sense to close this race anyway, and we already
have complete_and_exit() which can be used instead of "return ret"
above. Just we need the additional "static struct completion" and
module_exit() should call wait_for_completion.

Oleg.

