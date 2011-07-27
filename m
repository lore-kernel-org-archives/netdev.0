From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 02/14] allow root in container to copy namespaces
Date: Wed, 27 Jul 2011 16:14:30 -0700
Message-ID: <m1hb67fh9l.fsf@fess.ebiederm.org>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
	<1311706717-7398-3-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, dhowells@redhat.com
To: Serge Hallyn <serge@hallyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53940 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435Ab1G0XOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 19:14:36 -0400
In-Reply-To: <1311706717-7398-3-git-send-email-serge@hallyn.com> (Serge
	Hallyn's message of "Tue, 26 Jul 2011 18:58:25 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Serge Hallyn <serge@hallyn.com> writes:

> From: Serge E. Hallyn <serge.hallyn@canonical.com>
>
> Othewise nested containers with user namespaces won't be possible.
>
> It's true that user namespaces are not yet fully isolated, but for
> that same reason there are far worse things that root in a child
> user ns can do.  Spawning a child user ns is not in itself bad.
>
> This patch also allows setns for root in a container:
> @Eric Biederman: are there gotchas in allowing setns from child
> userns?

Yes.  We need to ensure that the target namespaces are namespaces
that have been created in from user_namespace or from a child of this
user_namespace.

Aka we need to ensure that we have CAP_SYS_ADMIN for the new namespace.

Eric

> Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  kernel/fork.c    |    4 ++--
>  kernel/nsproxy.c |    6 +++---
>  2 files changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 17bf7c8..22d0cf0 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1473,8 +1473,8 @@ long do_fork(unsigned long clone_flags,
>  		/* hopefully this check will go away when userns support is
>  		 * complete
>  		 */
> -		if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SETUID) ||
> -				!capable(CAP_SETGID))
> +		if (!nsown_capable(CAP_SYS_ADMIN) || !nsown_capable(CAP_SETUID) ||
> +				!nsown_capable(CAP_SETGID))
>  			return -EPERM;
>  	}
>  
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 9aeab4b..f50542d 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -134,7 +134,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
>  				CLONE_NEWPID | CLONE_NEWNET)))
>  		return 0;
>  
> -	if (!capable(CAP_SYS_ADMIN)) {
> +	if (!nsown_capable(CAP_SYS_ADMIN)) {
>  		err = -EPERM;
>  		goto out;
>  	}
> @@ -191,7 +191,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
>  			       CLONE_NEWNET)))
>  		return 0;
>  
> -	if (!capable(CAP_SYS_ADMIN))
> +	if (!nsown_capable(CAP_SYS_ADMIN))
>  		return -EPERM;
>  
>  	*new_nsp = create_new_namespaces(unshare_flags, current,
> @@ -241,7 +241,7 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
>  	struct file *file;
>  	int err;
>  
> -	if (!capable(CAP_SYS_ADMIN))
> +	if (!nsown_capable(CAP_SYS_ADMIN))
>  		return -EPERM;
>  
>  	file = proc_ns_fget(fd);
