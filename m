From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH 01/15] add Documentation/namespaces/user_namespace.txt
 (v3)
Date: Tue, 27 Sep 2011 19:56:59 +0400
Message-ID: <20110927155659.GA22532@albatros>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
 <1314993400-6910-4-git-send-email-serge@hallyn.com>
 <20110926191737.GA4562@albatros>
 <20110927132157.GB3111@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serge@hallyn.com>, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, dhowells@redhat.com,
	ebiederm@xmission.com, rdunlap@xenotime.net,
	kernel-hardening@lists.openwall.com
To: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110927132157.GB3111@sergelap>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2011 at 08:21 -0500, Serge E. Hallyn wrote:
> > First, the patches by design expose much kernel code to unprivileged
> > userspace processes.  This code doesn't expect malformed data (e.g. VFS,
> > specific filesystems, block layer, char drivers, sysadmin part of LSMs,
> > etc. etc.).  By relaxing permission rules you greatly increase attack
> > surface of the kernel from unprivileged users.  Are you (or somebody
> > else) planning to audit this code?
> 
> I had wanted to (but didn't) propose a discussion at ksummit about how
> best to approach the filesystem code.  That's not even just for user
> namespaces - patches have been floated in the past to make mount an
> unprivileged operation depending on the FS and the user's permission
> over the device and target.

This is a dangerous operation by itself.  AFAICS, this is the reason why
e.g. FUSE doesn't pass user mount points to other users and even root.
Beginning from violating some rules like existance of single "." and
".." in each directory and ending with filename charsets with /, \000
and things like `, ", ', \ inside.


>  So I don't know if a combination of auditing
> and fuzzing is the way to go,

Maybe the combination of both.  There are no generic recommendations,
it's always limited to the subsystem, checked property, and the
auditor.


> > Also, will it be possible to somehow restrict what specific kernel
> > facilities are accessible from users (IOW, what root emulation
> > limitations are in action)?  It is userful from both points of sysadmin,
> > who might not want to allow users to do such things, and from the
> > security POV in sense of attack surface reduction.
> 
> You're probably thinking along different lines, but this is why I've
> been wanting seccomp2 to get pushed through.  So that we can deny a
> container the syscalls we know it won't need, especially newer ones,
> to reduce the attack surface available to it.

This dependency greatly complicates the things.

First, there is a big misunderstanding between Will and Ingo in what
needs seccompv2 should serve.  Will wants to reduce kernel attack
surface by limiting syscalls and syscall arguments available to a user
(a single task, btw).  Ingo wants to see a full featured filtering
engine, which needs code changes all over the kernel.  Given the needed
changes amounts, it will unlikely reduce attack surface.

You probably don't want Will's version as syscalls filtering is a very
bad abstraction in your case.  user_namespaces likely need Ingo's
version of seccomp as it will be possible to filter e.g. fs-specific
events, but even if it is implemented, it will take a looong time for
your needs IMHO.


Also, I'm afraid for _good_ user_namespace filtering the policy
definition will be too complicated (like SELinux policy definition for
non-trivial applications) if it is implemented in events filtering
terms.


> The way we're approaching it right now is that by default everything
> stays 'capable(X)', so that a non-init user namespace doesn't get the
> privileges.

Great.  I was not sure about it.


>  While some of my patchsets this summer didn't follow this,
> Eric reminded me that we should first clamp down on the user namespaces
> as much as possible, and relax permissions in child namespaces later.

I think it is the only sane way.


> So the small (1-2 patch sized) sets I've been sending the last few
> weeks are just trying to fix existing inadequate userid or capability
> checks.
> 
> -serge

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
