From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 02/14] allow root in container to copy namespaces
Date: Thu, 28 Jul 2011 02:13:29 +0000
Message-ID: <20110728021329.GA3774@hallyn.com>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
 <1311706717-7398-3-git-send-email-serge@hallyn.com>
 <m1hb67fh9l.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, dhowells@redhat.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 50-56-35-84.static.cloud-ips.com ([50.56.35.84]:49431 "EHLO
	mail" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751517Ab1G1CNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 22:13:30 -0400
Content-Disposition: inline
In-Reply-To: <m1hb67fh9l.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Serge Hallyn <serge@hallyn.com> writes:
> 
> > From: Serge E. Hallyn <serge.hallyn@canonical.com>
> >
> > Othewise nested containers with user namespaces won't be possible.
> >
> > It's true that user namespaces are not yet fully isolated, but for
> > that same reason there are far worse things that root in a child
> > user ns can do.  Spawning a child user ns is not in itself bad.
> >
> > This patch also allows setns for root in a container:
> > @Eric Biederman: are there gotchas in allowing setns from child
> > userns?
> 
> Yes.  We need to ensure that the target namespaces are namespaces
> that have been created in from user_namespace or from a child of this
> user_namespace.
> 
> Aka we need to ensure that we have CAP_SYS_ADMIN for the new namespace.

Thanks - so the last hunk in this patch is wrong.

> Eric
> 
> > Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
> > Cc: Eric W. Biederman <ebiederm@xmission.com>
> > ---
> >  kernel/fork.c    |    4 ++--
> >  kernel/nsproxy.c |    6 +++---
> >  2 files changed, 5 insertions(+), 5 deletions(-)
> >
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index 17bf7c8..22d0cf0 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -1473,8 +1473,8 @@ long do_fork(unsigned long clone_flags,
> >  		/* hopefully this check will go away when userns support is
> >  		 * complete
> >  		 */
> > -		if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SETUID) ||
> > -				!capable(CAP_SETGID))
> > +		if (!nsown_capable(CAP_SYS_ADMIN) || !nsown_capable(CAP_SETUID) ||
> > +				!nsown_capable(CAP_SETGID))
> >  			return -EPERM;
> >  	}
> >  
> > diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> > index 9aeab4b..f50542d 100644
> > --- a/kernel/nsproxy.c
> > +++ b/kernel/nsproxy.c
> > @@ -134,7 +134,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
> >  				CLONE_NEWPID | CLONE_NEWNET)))
> >  		return 0;
> >  
> > -	if (!capable(CAP_SYS_ADMIN)) {
> > +	if (!nsown_capable(CAP_SYS_ADMIN)) {
> >  		err = -EPERM;
> >  		goto out;
> >  	}
> > @@ -191,7 +191,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
> >  			       CLONE_NEWNET)))
> >  		return 0;
> >  
> > -	if (!capable(CAP_SYS_ADMIN))
> > +	if (!nsown_capable(CAP_SYS_ADMIN))
> >  		return -EPERM;
> >  
> >  	*new_nsp = create_new_namespaces(unshare_flags, current,
> > @@ -241,7 +241,7 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
> >  	struct file *file;
> >  	int err;
> >  
> > -	if (!capable(CAP_SYS_ADMIN))
> > +	if (!nsown_capable(CAP_SYS_ADMIN))
> >  		return -EPERM;
> >  
> >  	file = proc_ns_fget(fd);
