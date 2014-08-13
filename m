From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 1/3] init / kthread: add module_long_probe_init() and
 module_long_probe_exit()
Date: Wed, 13 Aug 2014 09:03:55 +0800
Message-ID: <20140813010355.GA27894@kroah.com>
References: <1407882507-325-1-git-send-email-mcgrof@do-not-panic.com>
 <1407882507-325-2-git-send-email-mcgrof@do-not-panic.com>
 <201408122259.s7CMx6Bm042549@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "\"\\\"Luis R. Rodriguez\\\"\"" <mcgrof@do-not-panic.com>,
	tiwai@suse.de, linux-kernel@vger.kernel.org,
	"\"\\\"Luis R. Rodriguez\\\"\"" <mcgrof@suse.com>,
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
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:39175 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbaHMBEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 21:04:32 -0400
Content-Disposition: inline
In-Reply-To: <201408122259.s7CMx6Bm042549@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2014 at 07:59:06AM +0900, Tetsuo Handa wrote:
> Luis R. Rodriguez wrote:
> > Tetsuo bisected and found that commit 786235ee \"kthread: make
> > kthread_create() killable\" modified kthread_create() to bail as
> > soon as SIGKILL is received.
> 
> I just wrote commit 786235ee. It is not Tetsuo who bisected it.
> 
> > @@ -128,4 +129,38 @@ bool queue_kthread_work(struct kthread_worker *worker,
> > void flush_kthread_work(struct kthread_work *work);
> > void flush_kthread_worker(struct kthread_worker *worker);
> > 
> > +#ifndef MODULE
> > +
> > +#define module_long_probe_init(x)      __initcall(x);
> > +#define module_long_probe_exit(x)      __exitcall(x);
> > +
> > +#else
> > +/* To be used by modules which can take over 30 seconds at probe */
> > +#define module_long_probe_init(initfn)                    \\
> > +     static struct task_struct *__init_thread;          \\
> > +     static int _long_probe_##initfn(void *arg)          \\
> > +     {                                   \\
> > +          return initfn();                    \\
> > +     }                                   \\
> > +     static inline __init int __long_probe_##initfn(void)     \\
> > +     {                                   \\
> > +          __init_thread = kthread_run(_long_probe_##initfn,\\
> > +                             NULL,          \\
> > +                             #initfn);          \\
> > +          if (IS_ERR(__init_thread))               \\
> > +               return PTR_ERR(__init_thread);          \\
> > +          return 0;                         \\
> > +     }                                   \\
> > +     module_init(__long_probe_##initfn);
> > +/* To be used by modules that require module_long_probe_init() */
> > +#define module_long_probe_exit(exitfn)                    \\
> > +     static inline void __long_probe_##exitfn(void)          \\
> > +     {                                   \\
> > +          exitfn();                         \\
> 
> exitfn() must not be called if initfn() failed or has not
> completed yet. You need a bool variable for indicating that
> we are ready to call exitfn().
> 
> Also, subsequent userspace operations may fail if
> we return to userspace before initfn() completes
> (e.g. device nodes are not created yet).

I doubt that this will be a problem, as device nodes are usually created
_after_ module_init() returns.

But the cleanup issues are real on error paths.  Given that these
drivers will need "work" anyway, I don't think it's really a big deal.

thanks,

greg k-h
