From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Fri, 29 Feb 2008 10:58:19 +0300
Message-ID: <47C7BB1B.9060906@openvz.org>
References: <47C6D743.1050802@openvz.org>	<m1y794514k.fsf@ebiederm.dsl.xmission.com>	<20080228211720.GA1232@vino.hallyn.com> <m1k5ko4sfi.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: serge@hallyn.com, Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52274 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbYB2H7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 02:59:47 -0500
In-Reply-To: <m1k5ko4sfi.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I was thinking we might be able to hide the existence of
> /proc/.netns/NNN/  however we can read the current working directory.
> So even if we only allow explicit access through /proc/net and all
> others paths don't work we have something that is visible.

I have a patch that overrides the ->readdir method for /proc/.netns,
so that you can no longer read the directory contents, but you still
can guess one by guessing and opening files in it. Overriding the 
->lookup to screw one up looks like "shadowing" technics.

OTOH - consider you have the ids of existing net namespaces, but cannot 
read the contents on any but yours. So what? This information is useless
for you. So I dropped this part of a patch.

> So we really need something that we are not afraid to air in public.
> That we are not afraid to use and have it's use expanded upon.
> 
>> Right?
> 
> Think of user space processes inspecting /proc etc.  Having directory
> names change out form under you for no apparent reason is pretty nasty.

Have you ever bothered about /proc/<pid> change?

> Plus we have the consequence that a user space visible id is likely to
> get used for reporting in user space programs.  Reporting that will go
> haywire on a migration event.
>
> And if the id is used in reporting people are likely to want to use the
> id for control (so this may be the edge of a slippery slope).
> 
> Things like inode numbers that are a secondary effect are enough of a problem
> when looking at how things interact.  A directly visible user space visible
> id is a problem.
> 
> All we need to do if we use a pid as an id is:
> - Have one directory .netns with all of the net directories listed by pid.

We have one now.

> - Have readdir and lookup filter the directory entries by the pid
>   namespace of the proc mount.

So, how are you going to filter the lookup? The problem I see - you have
a process that opened the /proc/.netns/X directory (he onws that namespace)
and the other one trying to do the same. The VFS layer finds the hashed
dentry corresponding to this /proc/.netns/X. The only way you can prevent
VFS from giving one to the second task is to override .d_revalidate method 
and drop that dentry....

But we've already tried to walk this way with no luck.

> It looks like we have to tweak things just a bit so that free_pid
> would not be called until the pid namespace goes away.  Something
> similar to how we do the hash chains.

This is not about pid namespace, this is about net namespace and
tuning pids management to facilitate networking needs is not the right
thing to do.

> If we make namespaces show up anywhere besides under
> "/proc/<pid>/task/<tid>/" we have to do something like this, and pids
> are largely designed for this kind of use.

Proc consists of two parts - the <pid>-s one with generated-on-the-fly
entries and the static one that is represented by proc_dir_entry tree.
Do you propose to mix those two?

> It looks like the way /proc is currently structured we don't need a
> reverse map from pid to net namespace.  But I would not have a problem
> with that.
> 
> Our limitations are:
> - We need an inviolate dentry tree of the VFS dcache goes nuts.
> - We need an id that is in a namespace, or else we get pushed
>   into the yet another namespace problem.
> - We want to aim for minimal dentry duplication, to keep resource
>   consumption under control.  Which makes /proc/<pid>/task/<tid>/net
>   an unfortunate choice.
> 
> So I think /proc/.netns/ or simply /proc/netns/ is a good choice. We

Thanks.

> just need a non-global id for our directory entries so we don't paint
> ourselves into a corner.

What namespace do you mean by "non-global"?

> And honestly pid visibility is a very natural choice for which network
> namespaces you can see.  You can see the namespace of any process you
> can see.  Which especially means your children.  It is an arbitrary
> rule, it is a simple rule to explain, and it works recursively unlike
> any init_net is special rule.
> 
> Eric
> 

