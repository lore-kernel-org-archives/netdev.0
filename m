From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/18] flag parameters: paccept
Date: Thu, 8 May 2008 15:38:22 -0700
Message-ID: <20080508153822.0c4dd6e9.akpm@linux-foundation.org>
References: <200805062118.m46LI7SS004041@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davidel@xmailserver.org, mtk.manpages@gmail.com,
	torvalds@linux-foundation.org, Roland McGrath <roland@redhat.com>,
	Oleg Nesterov <oleg@tv-sign.ru>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55455 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754869AbYEHWjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 18:39:22 -0400
In-Reply-To: <200805062118.m46LI7SS004041@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008 17:18:07 -0400
Ulrich Drepper <drepper@redhat.com> wrote:

> This patch is by far the most complex in the series.  It adds a new syscall
> paccept.  This syscall differs from accept in that it adds (at the userlevel)
> two additional parameters:
> 
> - a signal mask
> - a flags value
> 
> The flags parameter can be used to set flag like SOCK_CLOEXEC.  This is
> imlpemented here as well.  Some people argued that this is a property
> which should be inherited from the file desriptor for the server but
> this is against POSIX.  Additionally, we really want the signal mask
> parameter as well (similar to pselect, ppoll, etc).  So an interface
> change in inevitable.
> 
> The flag value is the same as for socket and socketpair.  I think
> diverging here will only create confusion.  Similar to the filesystem
> interfaces where the use of the O_* constants differs, it is acceptable
> here.
> 
> The signal mask is handled as for pselect etc.  The mask is temporarily
> installed for the thread and removed before the call returns.  I modeled
> the code after pselect.  If there is a problem it's likely also in
> pselect.
> 
> For architectures which use socketcall I maintained this interface
> instead of adding a system call.  The symmetry shouldn't be broken.
> 
> The following test must be adjusted for architectures other than x86 and
> x86-64 and in case the syscall numbers changed.
>

I have a bit of a mystery going on here.
 
> ...
>
> +asmlinkage long sys_paccept(int fd, struct sockaddr __user *upeer_sockaddr,
> +			    int __user *upeer_addrlen,
> +			    const sigset_t __user *sigmask,
> +			    size_t sigsetsize, int flags)
> +{
> +	sigset_t ksigmask, sigsaved;
> +	int ret;
> +
> +	if (sigmask) {
> +		/* XXX: Don't preclude handling different sized sigset_t's.  */
> +		if (sigsetsize != sizeof(sigset_t))
> +			return -EINVAL;
> +		if (copy_from_user(&ksigmask, sigmask, sizeof(ksigmask)))
> +			return -EFAULT;
> +
> +		sigdelsetmask(&ksigmask, sigmask(SIGKILL)|sigmask(SIGSTOP));
> +		sigprocmask(SIG_SETMASK, &ksigmask, &sigsaved);
> +        }
> +
> +	ret = do_accept(fd, upeer_sockaddr, upeer_addrlen, flags);
> +
> +	if (ret < 0 && signal_pending(current)) {
> +		/*
> +		 * Don't restore the signal mask yet. Let do_signal() deliver
> +		 * the signal on the way back to userspace, before the signal
> +		 * mask is restored.
> +		 */
> +		if (sigmask) {
> +			memcpy(&current->saved_sigmask, &sigsaved,
> +			       sizeof(sigsaved));
> +			set_thread_flag(TIF_RESTORE_SIGMASK);
> +		}
> +	} else if (sigmask)
> +		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
> +
> +	return ret;
> +}

Some architectures (including x86) do not implement TIF_RESTORE_SIGMASK.

Ah, you must have prepared the patches against something prehistoric like
2.6.25.  Please prefer to prepare 2.6.x patches against the 2.6.x tree, not
the 2.6.x-1 tree?

Whatever you're trying to do here, we'll need to find a non-arch-specific
way of doing it.

