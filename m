From: serge@hallyn.com
Subject: Re: [PATCH 0/2] Fix /proc/net in presence of net namespaces
Date: Thu, 28 Feb 2008 21:17:37 -0600
Message-ID: <20080229031737.GA3047@vino.hallyn.com>
References: <47C6D743.1050802@openvz.org> <m1y794514k.fsf@ebiederm.dsl.xmission.com> <20080228211720.GA1232@vino.hallyn.com> <m1k5ko4sfi.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: serge@hallyn.com, Pavel Emelyanov <xemul@openvz.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756241AbYB2DUk@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1k5ko4sfi.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> serge@hallyn.com writes:
> 
> > Quoting Eric W. Biederman (ebiederm@xmission.com):
> >> Pavel Emelyanov <xemul@openvz.org> writes:
> >> 
> >> > Current /proc/net is done with so called "shadows", but current
> >> > implementation is broken and has little chances to get fixed.
> >> >
> >> > The problem is that dentries subtree of /proc/net directory has
> >> > fancy revalidation rules to make processes living in different
> >> > net namespaces see different entries in /proc/net subtree, but
> >> > currently, tasks see in the /proc/net subdir the contents of any
> >> > other namespace, depending on who opened the file first.
> >> >
> >> > The proposed fix is to turn /proc/net into a symlink, which behaves
> >> > similar to /proc/self link - it points to .netns/<id> directory 
> >> > where the <id> is the id of net namespace, current task lives in.
> >> >
> >> > # ls -l /proc/net
> >> > lrwxrwxrwx  1 root root 8 Feb 28 18:38 /proc/net -> .netns/0
> >> >
> >> > The /proc/.netns dir contains subtrees for all the namespaces in 
> >> > the system:
> >> >
> >> > # ls -l /proc/.netns/
> >> > total 0
> >> > dr-xr-xr-x  5 root root 0 Feb 28 18:39 0
> >> > dr-xr-xr-x  3 root root 0 Feb 28 18:39 1
> >> >
> >> > To provide some security each /proc/.netns/<id> directory allows
> >> > access to tasks that live in the owning namespace only (with the
> >> > exception, that init_net tasks can see everything).
> >> 
> >> 
> >> Nack.  Yet another global set of ids that require us to implement another
> >> namespace looks like the wrong way to go.
> >
> > Sentiment granted, but I'm not sure it can be an issue.  It *could* be
> > in issue if we moved to a more flexible access control here here any
> > netns could access the .netns/N directories for all it's child
> > namespaces.
> 
> However at least for visibility and inspection we want that.
> We want to inspect what is happening to other processes.  If we didn't
> care then all of the pid namespaces could just be disjoint.

But the way Pavel has it coded, only tasks in the init namespace can
view /proc/.net/* for any other net namespaces.

If you object to that (I'm undecided - though on a gut level I do prefer
a simpler approach using bind mounts and not forcing any cross-ns access
control this way) then the ids become relevant, but the way Pavel has
it, it's just not.

> Providing interfaces where people can inspect what is going on through
> the filesystem is very natural, and a lot easier to support long term
> then adding a whole new set of interfaces for debuggers and the like.
> 
> > But it can't, and /proc/net is set by the kernel.  So the <id> can't be
> > an issue for any checkpoint/restart except htat of the whole system, and
> > of course on whole-system resume we have no <id> collision worries.
> >
> > So userspace can't do anything with <id>, so there is no reason to worry
> > about it becoming another namespace?
> 
> I was thinking we might be able to hide the existence of
> /proc/.netns/NNN/  however we can read the current working directory.
> So even if we only allow explicit access through /proc/net and all
> others paths don't work we have something that is visible.
> 
> So we really need something that we are not afraid to air in public.
> That we are not afraid to use and have it's use expanded upon.
> 
> > Right?
> 
> Think of user space processes inspecting /proc etc.

Well a task in one pid namespace cannot view the /proc for another pid
namespace, right?

> Having directory
> names change out form under you for no apparent reason is pretty nasty.

Yes, but they won't just 'change out' from under you, you ask for it...
But here like I said I do prefer an approach where /proc/net is bind
mounted by the user.  But I have no good reason to back it up...

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

Which pid will be used?  This .netns directory still is systemwide so
these pids  must (a) be globally unique and (b) be available (by your
requirements :)  upon a container restart so that the restarted process
can re-use the same pid...

I don't see the advantage to using a pid.

> - Have readdir and lookup filter the directory entries by the pid
>   namespace of the proc mount.

Yuck, I far prefer to have userspace mount --bind /proc/.net/whatever
to /proc/net rather than have the readdir and lookup do magic filtering.

> It looks like we have to tweak things just a bit so that free_pid
> would not be called until the pid namespace goes away.  Something
> similar to how we do the hash chains.

When you say pid are you talking about a pid_nr or a struct pid?  In any
case, I still don't see what makes it available for reuse on a
restart...

And if not available for reuse on a restart, then we may as well use a
simple global unique id as Pavel uses.

> If we make namespaces show up anywhere besides under
> "/proc/<pid>/task/<tid>/" we have to do something like this, and pids
> are largely designed for this kind of use.

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
> just need a non-global id for our directory entries so we don't paint
> ourselves into a corner.

But I don't see how this is going to work.  If you're using a pid_nr
inside a pid namespace, then you're not guaranteeing that the pid_nr
will be unique, so you may not be able to create th e/proc/.netns/X
directory.  If you're using the global pid, then you're not guaranteeing
that it will be available upon a container restart.

> And honestly pid visibility is a very natural choice for which network
> namespaces you can see.  You can see the namespace of any process you
> can see.  Which especially means your children.  It is an arbitrary
> rule, it is a simple rule to explain, and it works recursively unlike

But apparently not simple enough for a simpleton like me to understand,
sorry :(

> any init_net is special rule.
> 
> Eric
