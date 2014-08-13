From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 1/3] init / kthread: add module_long_probe_init()
	and module_long_probe_exit()
Date: Wed, 13 Aug 2014 19:51:01 +0200
Message-ID: <20140813175101.GA7156@redhat.com>
References: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com> <1407882507-325-2-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, tiwai@suse.de,
	linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
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
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407882507-325-2-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/12, Luis R. Rodriguez wrote:
>
> +/* To be used by modules which can take over 30 seconds at probe */

Probably the comment should explain that this hack should only be
used if the driver is buggy and is wating for "real fix".

> +#define module_long_probe_init(initfn)				\
> +	static struct task_struct *__init_thread;		\
> +	static int _long_probe_##initfn(void *arg)		\
> +	{							\
> +		return initfn();				\
> +	}							\
> +	static inline __init int __long_probe_##initfn(void)	\
> +	{							\
> +		__init_thread = kthread_run(_long_probe_##initfn,\
> +					    NULL,		\
> +					    #initfn);		\
> +		if (IS_ERR(__init_thread))			\
> +			return PTR_ERR(__init_thread);		\
> +		return 0;					\
> +	}							\
> +	module_init(__long_probe_##initfn);
> +/* To be used by modules that require module_long_probe_init() */
> +#define module_long_probe_exit(exitfn)				\
> +	static inline void __long_probe_##exitfn(void)		\
> +	{							\
> +		exitfn();					\
> +		if (__init_thread)				\
> +			kthread_stop(__init_thread);		\
> +	}							\

exitfn() should be called after kthread_stop(), and only if initfn()
returns 0. So it should probably do

	int err = kthread_stop(__init_thread);
	if (!err)
		exitfn();

But there is an additional complication, you can't use __init_thread
without get_task_struct(), so  __long_probe_##initfn() can't use
kthread_run(). It needs kthread_create() + get_task_struct() + wakeup.

Oleg.
