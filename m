From: "Serge E. Hallyn" <serge.hallyn@canonical.com>
Subject: Re: [PATCH 01/15] add Documentation/namespaces/user_namespace.txt
 (v3)
Date: Tue, 27 Sep 2011 08:21:57 -0500
Message-ID: <20110927132157.GB3111@sergelap>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
 <1314993400-6910-4-git-send-email-serge@hallyn.com>
 <20110926191737.GA4562@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serge@hallyn.com>, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, dhowells@redhat.com,
	ebiederm@xmission.com, rdunlap@xenotime.net,
	kernel-hardening@lists.openwall.com
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110926191737.GA4562@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Vasiliy Kulikov (segoon@openwall.com):
> (cc'ed kernel-hardening)
> 
> 
> Hi Serge,
> 
> I didn't deeply studied the patches yet (sorry!), but I have some
> long-term question about the technique in general.  I couldn't find
> answers to the questions in the documentation.

Great - thanks for your time, Vasiliy.

There is documentation at https://wiki.ubuntu.com/UserNamespace,
and I was adding a Documentation/namespaces/user_namespace.txt file
(which hasn't gone in yet) which you can see here:
https://lkml.org/lkml/2011/7/26/351

But those don't answer your questions sufficiently.

> First, the patches by design expose much kernel code to unprivileged
> userspace processes.  This code doesn't expect malformed data (e.g. VFS,
> specific filesystems, block layer, char drivers, sysadmin part of LSMs,
> etc. etc.).  By relaxing permission rules you greatly increase attack
> surface of the kernel from unprivileged users.  Are you (or somebody
> else) planning to audit this code?

I had wanted to (but didn't) propose a discussion at ksummit about how
best to approach the filesystem code.  That's not even just for user
namespaces - patches have been floated in the past to make mount an
unprivileged operation depending on the FS and the user's permission
over the device and target.  So I don't know if a combination of auditing
and fuzzing is the way to go, or what, and wanted to get input from
some people who are more knowledgeable on that topic than me.

You're right about other kernel code as well.

I'll certainly join in this effort, but don't want to go blindly
charging in without some advice/guidance about the best way to do
this and, if others are interested, coordinate it.

We can start by looking through all code which is currently under
ns_capable(), and analyzing that.  But what tools do we have
available to perform the analysis?

Do you think a kernel summit discussion (i suppose given the late
timing, a beer bof) would be beneficial?  (I wouldn't be there)

> Also, will it be possible to somehow restrict what specific kernel
> facilities are accessible from users (IOW, what root emulation
> limitations are in action)?  It is userful from both points of sysadmin,
> who might not want to allow users to do such things, and from the
> security POV in sense of attack surface reduction.

You're probably thinking along different lines, but this is why I've
been wanting seccomp2 to get pushed through.  So that we can deny a
container the syscalls we know it won't need, especially newer ones,
to reduce the attack surface available to it.

> The patches explicitly enable some features for users on white list
> basis.  It's possible to do it for simple cases, but what are you going
> to do with multiplexing functions where there is a permission check
> before the actual multiplexing?  FS, networking drivers, etc.  Are you
> going to do the same thing as net_namespace does? - For each multiplexed
> entity create bool ->ns_aware which is false by default for all
> "untrusted"/not prepared protocols and is true for audited/prepared
> protocols.  Or probably you have something else in mind?

Ah, I typed the bottom paragraph before realizing what you were actually
asking.  The filesystems are a good example.  In the unprivileged mounts
patchsets, for instance, a flag was added to each filesystem indicating
if it was safe for unprivileged mounting (turned off for all real block
filesystems :).  For targeted capabilities, my goal would be simply to
make sure that each non-netns-aware entity do a (untargeted) capable()
check.  Without pointing to a specific example it's hard to say what I
will do.  It depends on how the code was previously laid out, and what
the maintainer of that subsystem prefers.

The way we're approaching it right now is that by default everything
stays 'capable(X)', so that a non-init user namespace doesn't get the
privileges.  While some of my patchsets this summer didn't follow this,
Eric reminded me that we should first clamp down on the user namespaces
as much as possible, and relax permissions in child namespaces later.
So the small (1-2 patch sized) sets I've been sending the last few
weeks are just trying to fix existing inadequate userid or capability
checks.

-serge
