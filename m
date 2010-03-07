From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC v2 00/10] snet: Security for NETwork syscalls
Date: Sun, 7 Mar 2010 14:45:20 +0900
Message-ID: <201003071445.FJB39029.QLSHtOFOJFOVMF@I-love.SAKURA.ne.jp>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
	<201003030156.o231udx1023055@www262.sakura.ne.jp>
	<m2vdd9p9r7.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, nhorman@tuxdriver.com, root@localdomain.pl,
	linux-security-module@vger.kernel.org
To: sam@synack.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:52942 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750702Ab0CGFpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Mar 2010 00:45:23 -0500
In-Reply-To: <m2vdd9p9r7.fsf@ssh.synack.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Samir Bellabes wrote:
> Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:
> 
> > Regarding [RFC v2 09/10] snet: introduce snet_ticket
> > +enum snet_verdict snet_ticket_check(struct snet_info *info)
> > +{
> > +       struct snet_ticket *st = NULL;
> > +       unsigned int h = 0, verdict = SNET_VERDICT_NONE;
> > +       struct list_head *l = NULL;
> > +       struct snet_task_security *tsec = NULL;
> > +
> > +       if (snet_ticket_mode == SNET_TICKET_OFF)
> > +               goto out;
> > +
> > +       tsec = (struct snet_task_security*) current_security();
> > +
> > +       h = jhash_2words(info->syscall, info->protocol, 0) % HSIZE;
> > +       l = &tsec->hash[h];
> > +
> > +       read_lock_bh(&tsec->lock);
> >
> > Credentials are allocated for copy-on-write basis.
> > Sharing "tsec" among multiple "struct task_struct" is what you intended?
> 
> No, there is no shared "tsec".
> snet_ticket_check() is called from the process context. So "tsec" is
> a pointer to the "void *security" pointer from its own "struct
> task_struct".
>
Until 2.6.28:

  "void *security" is directory attached to "struct task_struct".
  copy_process() calls security_task_alloc().

  Therefore, task1->security != task2->security is guaranteed as long as you do

    task->security = kmalloc();

  at security_task_alloc().

Since 2.6.29:

  "void *security" is attached to "struct cred", and "struct cred *" is
  attached to "struct task_struct". copy_process() calls copy_creds() and
  prepare_creds() calls security_prepare_creds(). But copy_creds() does not
  call prepare_creds() for clone(CLONE_THREAD) case.

  Therefore, task1->cred->security != task2->cred->security is not guaranteed
  even if you do

    cred->security = kmalloc();

  at security_prepare_creds().

> every task_struct have a "tsec" allocated to its "void *security"
> pointer. 

You meant to have assigned "void *security" dedicated to "struct task_struct".
But "void *security" is no longer directly attached to "struct task_struct".
I couldn't find code that checks whether "current->cred" is used by only
current thread or not. "current->cred" being used by only current thread is
a requirement for having a "tsec" allocated to every "struct task_struct".

Your code will share "tsec" among multiple threads if a process created
threads using clone(CLONE_THREAD | CLONE_SIGHAND | CLONE_VM). Each thread has
its own "struct task_struct" but they share "cred->security".
Sharing "tsec" among multiple threads is what you intended?



Regards.
