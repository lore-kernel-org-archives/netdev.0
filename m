From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Tue, 20 Dec 2016 19:36:16 +0100
Message-ID: <9e378fb1-23ff-a239-d915-3d9aa26a999e@zonque.org>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <20161220031802.GA77838@ast-mbp.thefacebook.com>
 <CALCETrXymvAo-9zhQe=amToz_fs9XGniK2KLZv5Fxc66qcUx6A@mail.gmail.com>
 <bdc18fe4-f90d-49f0-d0a6-a28f87335df2@zonque.org>
 <CALCETrXyp2ddf4HRsEoN=qEwTBaezOUX2XWj6nxPcbc4t13svw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrXyp2ddf4HRsEoN=qEwTBaezOUX2XWj6nxPcbc4t13svw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 12/20/2016 06:23 PM, Andy Lutomirski wrote:
> On Tue, Dec 20, 2016 at 2:21 AM, Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org> wrote:

> To clarify, since this thread has gotten excessively long and twisted,
> I think it's important that, for hooks attached to a cgroup, you be
> able to tell in a generic way whether something is plugged into the
> hook.  The natural way to see a cgroup's configuration is to read from
> cgroupfs, so I think that reading from cgroupfs should show you that a
> BPF program is attached and also give enough information that, once
> bpf programs become dumpable, you can dump the program (using the
> bpf() syscall or whatever).

[...]

> There isn't a big semantic difference between
> 'open("/cgroup/NAME/some.control.file", O_WRONLY); ioctl(...,
> CGROUP_ATTACH_BPF, ...)' and 'open("/cgroup/NAME/some.control.file",
> O_WRONLY); bpf(BPF_PROG_ATTACH, ...);'.  There is, however, a semantic
> difference when you do open("/cgroup/NAME", O_RDONLY | O_DIRECTORY)
> because the permission check is much weaker.

Okay, if you have such a control file, you can of course do something
like that. When we discussed things back then with Tejun however, we
concluded that a controller that is not completely controllable through
control knobs that can be written and read via cat is meaningless.
That's why this has become a 'hidden' cgroup feature.

With your proposed API, you'd first go to the bpf(2) syscall in order to
get a prog fd, and then come back to some sort of cgroup API to put the
fd in there. That's quite a mix and match, which is why we considered
the API cleaner in its current form, as everything that is related to
bpf is encapsulated behind a single syscall.

> My preference would be to do an ioctl on a new
> /cgroup/NAME/network_hooks.inet_ingress file.  Reading that file tells
> you whether something is attached and hopefully also gives enough
> information (a hash of the BPF program, perhaps) to dump the actual
> program using future bpf() interfaces.  write() and ioctl() can be
> used to configure it as appropriate.

So am I reading this right? You're proposing to add ioctl() hooks to
kernfs/cgroupfs? That would open more possibilities of course, but I'm
not sure where that rabbit hole leads us eventually.

> Another option that I like less would be to have a
> /cgroup/NAME/cgroup.bpf that lists all the active hooks along with
> their contents.  You would do an ioctl() on that to program a hook and
> you could read it to see what's there.

Yes, read() could, in theory, give you similar information than ioctl(),
but in human-readable form.

> FWIW, everywhere I say ioctl(), the bpf() syscall would be okay, too.
> It doesn't make a semantic difference, except that I dislike
> BPF_PROG_DETACH because that particular command isn't BPF-specific at
> all.

Well, I think it is; it pops the bpf program from a target and drops the
reference on it. It's not much code, but it's certainly bpf-specific.

>>> So if I set up a cgroup that's monitored and call it /cgroup/a and
>>> enable delegation and if the program running there wants to do its own
>>> monitoring in /cgroup/a/b (via delegation), then you really want the
>>> outer monitor to silently drop events coming from /cgroup/a/b?
>>
>> That's a fair point, and we've discussed it as well. The issue is, as
>> Alexei already pointed out, that we do not want to traverse the tree up
>> to the root for nested cgroups due to the runtime costs in the
>> networking fast-path. After all, we're running the bpf program for each
>> packet in flight. Hence, we opted for the approach to only look at the
>> leaf node for now, with the ability to open it up further in the future
>> using flags during attach etc.
> 
> Careful here!  You don't look only at the leaf node for now.  You do a
> fancy traversal and choose the nearest node that has a hook set up.

But we do the 'complex' operation at attach time or when a cgroup is
created, both of which are slow-path operations. In the fast-path, we
only look at the leaf, which may or may not have an effective program
installed. And that's of course much cheaper then doing the traversing
for each packet.

> mkdir /cgroup/foo
> BPF_PROG_ATTACH(some program to foo)
> mkdir /cgroup/foo/bar
> chown -R some_user /cgroup/foo/bar
> 
> If the kernel only looked at the leaf, then the program that did the
> above would not expect that the program would constrain
> /cgroup/foo/bar's activity.  But, as it stands, the program *would*
> expect /cgroup/foo/bar to be constrained, except that, whenever the
> capable() check changes to ns_capable() (which will happen eventually
> one way or another), then the bad guy can create /cgroup/foo/bar/baz,
> install a new no-op hook there, and break the security assumption.
> 
> IOW, I think that totally non-recursive hooks are okay from a security
> perspective, albeit rather strange, but the current design is not okay
> from a security perspective.

We locked down the ability to override any of these programs with
CAP_NET_ADMIN, which is also what it takes to flush iptables, right?
What's the difference?

> So here's a fleshed-out possible version that's a bit of a compromise
> after sleeping on this.  There's plenty of room to tweak this.
> 
> Each cgroup gets a new file cgroup.hooks.  Reading it shows a list of
> active hooks.  (A hook can be a string like "network.inet_ingress".)
> 
> You can write a command like "-network.inet_ingress off" to it to
> disable network.inet_ingress.  You can write a command like
> "+network.inet_ingress" to it to enable the network.inet_ingress hook.
> 
> When a hook (e.g. network.inet_ingress) is enabled, a new file appears
> in the cgroup called "hooks.network.inet_ingress").  You can read it
> to get an indication of what is currently installed in that slot.  You
> can write "none" to it to cause nothing to be installed in that slot.
> (This replaces BPF_PROG_DETACH.).  You can open it for write and use
> bpf() or perhaps ioctl() to attach a bpf program.  Maybe you can also
> use bpf() to dump the bpf program, but, regardless, if a bpf program
> is there, read() will return some string that contains "bpf" and maybe
> some other useful information.

I can see where you're going, but I don't know yet if if I like this
approach better, given that you would still need a binary interface at
least at attach time, and that such an interface would use a resource
returned from bpf(2). The ability to read from control files in order to
see what's going on is nice though.

I'd like to have Tejun's and Alexei's opinion on this - as I said, I had
something like that (albeit much simpler) in one of my very early
drafts, but we consented to do the hookup the other way around, for
stated reasons.


Thanks,
Daniel
