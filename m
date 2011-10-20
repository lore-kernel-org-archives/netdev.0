From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 9/9] make net/core/scm.c uid comparisons user namespace
 aware
Date: Thu, 20 Oct 2011 12:58:01 +0000
Message-ID: <20111020125801.GA1315@hallyn.com>
References: <1318974898-21431-1-git-send-email-serge@hallyn.com>
 <1318974898-21431-10-git-send-email-serge@hallyn.com>
 <m1sjmpytpf.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	oleg@redhat.com, richard@nod.at, mikevs@xs4all.net,
	segoon@openwall.com, gregkh@suse.de, dhowells@redhat.com,
	eparis@redhat.com, "Serge E. Hallyn" <serge.hallyn@canonical.com>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1sjmpytpf.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Serge Hallyn <serge@hallyn.com> writes:
> 
> > From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
> >
> > Currently uids are compared without regard for the user namespace.
> > Fix that to prevent tasks in a different user namespace from
> > wrongly matching on SCM_CREDENTIALS.
> >
> > In the past, either your uids had to match, or you had to have
> > CAP_SETXID.  In a namespaced world, you must either (both be in the
> > same user namespace and have your uids match), or you must have
> > CAP_SETXID targeted at the other user namespace.  The latter can
> > happen for instance if uid 500 created a new user namespace and
> > now interacts with uid 0 in it.
> 
> Serge this approach is wrong.

Thanks for looking, Eric.

> Because we pass the cred and the pid through the socket socket itself
> is just a conduit and should be ignored in this context.

Ok, that makes sense, but

> The only interesting test should be are you allowed to impersonate other
> users in your current userk namespace.

Why in your current user namespace?  Shouldn't it be in the
target user ns?  I understand it could be wrong to tie the
user ns owning the socket to the target userns (though I still
kind of like it), but just because I have CAP_SETUID in my
own user_ns doesn't mean I should be able to pose as another
uid in your user_ns.

(Now I also see that cred_to_ucred() translates to the current
user_ns, so that should have been a hint to me before about
your intent, but I'm not convinced I agree with your intent).

And you do the same with the pid.  Why is that a valid assumption?

(I've got that feeling that I'll feel like a dunce once you explain :)

> So it should be possible to simplify the entire patch to just:
>  static __inline__ int scm_check_creds(struct ucred *creds)
>  {
>  	const struct cred *cred = current_cred();
> +	struct user_namespace *ns = cred->user_ns;
> 
> -	if ((creds->pid == task_tgid_vnr(current) || capable(CAP_SYS_ADMIN)) &&
> -	    ((creds->uid == cred->uid   || creds->uid == cred->euid ||
> -	      creds->uid == cred->suid) || capable(CAP_SETUID)) &&
> -	    ((creds->gid == cred->gid   || creds->gid == cred->egid ||
> -	      creds->gid == cred->sgid) || capable(CAP_SETGID))) {
> +	if ((creds->pid == task_tgid_vnr(current) || ns_capable(ns, CAP_SYS_ADMIN)) &&
> +	    ((creds->uid == cred->uid   || creds->uid == cred->euid ||
> +	      creds->uid == cred->suid) || ns_capable(ns, CAP_SETUID)) &&
> +	    ((creds->gid == cred->gid   || creds->gid == cred->egid ||
> +	      creds->gid == cred->sgid) || ns_capable(ns, CAP_SETGID))) {
>   	       return 0;
>   	}
>   	return -EPERM;
>   }
