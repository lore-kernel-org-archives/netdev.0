From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Tue, 20 Dec 2016 09:23:14 -0800
Message-ID: <CALCETrXyp2ddf4HRsEoN=qEwTBaezOUX2XWj6nxPcbc4t13svw@mail.gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com> <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <20161220031802.GA77838@ast-mbp.thefacebook.com> <CALCETrXymvAo-9zhQe=amToz_fs9XGniK2KLZv5Fxc66qcUx6A@mail.gmail.com>
 <bdc18fe4-f90d-49f0-d0a6-a28f87335df2@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:33639 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756238AbcLTRYd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 12:24:33 -0500
Received: by mail-ua0-f169.google.com with SMTP id b56so23042036uaa.0
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 09:23:36 -0800 (PST)
In-Reply-To: <bdc18fe4-f90d-49f0-d0a6-a28f87335df2@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2016 at 2:21 AM, Daniel Mack <daniel@zonque.org> wrote:
> Hi,
>
> On 12/20/2016 04:50 AM, Andy Lutomirski wrote:
>> You mean BPF_CGROUP_RUN_PROG_INET_SOCK(sk)?  There is nothing bpf
>> specfic about the hook except that the name of this macro has "BPF" in
>> it.  There is nothing whatsoever that's bpf-specific about the context
>> -- sk is not bpf-specific at all.
>>
>> The only thing bpf-specific about it is that it currently only invokes
>> bpf programs.  That could easily change.
>
> I'm not sure if I follow. The code as it currently stands only supports
> attaching bpf programs to cgroups which have been created using
> BPF_PROG_LOAD. If cgroups would support other program types in the
> future, then they would need to be stored in different data types
> anyway, and the bpf syscall multiplexer would be the wrong entry point
> to access them anyway.

To clarify, since this thread has gotten excessively long and twisted,
I think it's important that, for hooks attached to a cgroup, you be
able to tell in a generic way whether something is plugged into the
hook.  The natural way to see a cgroup's configuration is to read from
cgroupfs, so I think that reading from cgroupfs should show you that a
BPF program is attached and also give enough information that, once
bpf programs become dumpable, you can dump the program (using the
bpf() syscall or whatever).

Obviously the interface to *attach* a BPF program to a hook will need
to be at least a little bit BPF-specific.  But there's nothing
particularly BPF-specific about detaching, and if a control file were
to exist, writing "detach" or "none" to it seems natural.

>
> Whether we add bpf-specific code to the cgroup file parsers or
> cgroup-specific code to the bpf layer does not make much of a semantic
> difference, does it? As a matter of fact, my very first implementation
> of this patch set implemented a cgroup controller that would allow
> writing strings like "ing
>
> b) make it possible to extend the functionality in the future by adding
> flags to the command struct etc.
>
> And I hoped we achieved that after discussing it for so long.
>
>> How about slowing down a wee bit and trying to come up with cgroup
>> hook semantics that work for all of these use cases?
>
> I'm all for discussing things, but I don't this was done in a rush.
>
> I do agree though that adding functionality to cgroups that is not
> limited to resource control is a delicate thing to do, which is why I
> cc'ed cgroups@ in my patches. I should have also added linux-api@ I
> guess, sorry I missed that.
>ress 5" to its control file, where 5 is the fd
> number that came out of BPF_PROG_LOAD. The main reason we decided to
> ditch that was that echoing fd numbers into a text file seemed way worse
> than going through a proper syscall layer with it, and ioctls are
> unavailable on pseudo-fs.

There isn't a big semantic difference between
'open("/cgroup/NAME/some.control.file", O_WRONLY); ioctl(...,
CGROUP_ATTACH_BPF, ...)' and 'open("/cgroup/NAME/some.control.file",
O_WRONLY); bpf(BPF_PROG_ATTACH, ...);'.  There is, however, a semantic
difference when you do open("/cgroup/NAME", O_RDONLY | O_DIRECTORY)
because the permission check is much weaker.

The reason I suggest ioctl() and not write() is that write() MUST NOT
make its behavior depend on the caller's credentials, file table, etc.
Imagine what would happen if you did 'sudo -u eviltext
>/cgroup/NAME/control.file'.  (This particular mistake has been
repeated many times in the kernel, in drivers, networking, namespaces,
core code, etc, and it's resulted in a big pile of privilege
escalation bugs.)  So write("bpf:<actual BPF instructions>") is safe
(but unusably awkward, I think), whereas write("bpf:fd 5") is unsafe.

>
> The idea was rather to allow attaching bpf programs to other things than
> just cgroups as well, which is why we called the member of 'union
> bpf_attr' 'target_fd', and a cgroup is just one type a target here.

I would make that a separate operation.  If someone adds the ability
to attach an ebpf program to, say, seccomp (I'm quite sure this will
happen eventually), it should be attached using seccomp(), not bpf(),
for example).  The people writing seccomp filters will thank you for
making the syscall in question reflect what object (the cgroup, for
example) is being modified.

>
>>> i'm assuming 'baadf00d' is bpf program fd expressed a text string?
>>> and kernel needs to parse above? will you allow capital and lower
>>> case for 'bpf:' ? and mixed case too? spaces and tabs allowed or not?
>>> can program fd expressed as decimal or hex or both?
>>> how do you return the error? as a text string for user space
>>> to parse?
>>
>> No.  The kernel does not parse it because you cannot write this to the
>> file.  You set a bpf filter with ioctl and pass an fd.
>
> An ioctl on what file, exactly?

There are at least two plausible models.

My preference would be to do an ioctl on a new
/cgroup/NAME/network_hooks.inet_ingress file.  Reading that file tells
you whether something is attached and hopefully also gives enough
information (a hash of the BPF program, perhaps) to dump the actual
program using future bpf() interfaces.  write() and ioctl() can be
used to configure it as appropriate.

Another option that I like less would be to have a
/cgroup/NAME/cgroup.bpf that lists all the active hooks along with
their contents.  You would do an ioctl() on that to program a hook and
you could read it to see what's there.

FWIW, everywhere I say ioctl(), the bpf() syscall would be okay, too.
It doesn't make a semantic difference, except that I dislike
BPF_PROG_DETACH because that particular command isn't BPF-specific at
all.

>
>> If you *read*
>> the file, you get the same bpf program hash that fdinfo on the bpf
>> object would show -- this is for debugging and (eventually) CRIU.
>
> We need a debugging facility at some point, I agree to that. As the code
> currently stands, that would rather need to go into the bpf(2) syscall
> though, as setting a program through bpf(2) and reading it through
> cgroupfs is really nasty.

But knowing that you have to call bpf() to tell whether bpf hooks are
installed in a cgroup is nasty.  Everything else uses ls and cat --
why should BPF be special here?

>> So if I set up a cgroup that's monitored and call it /cgroup/a and
>> enable delegation and if the program running there wants to do its own
>> monitoring in /cgroup/a/b (via delegation), then you really want the
>> outer monitor to silently drop events coming from /cgroup/a/b?
>
> That's a fair point, and we've discussed it as well. The issue is, as
> Alexei already pointed out, that we do not want to traverse the tree up
> to the root for nested cgroups due to the runtime costs in the
> networking fast-path. After all, we're running the bpf program for each
> packet in flight. Hence, we opted for the approach to only look at the
> leaf node for now, with the ability to open it up further in the future
> using flags during attach etc.

Careful here!  You don't look only at the leaf node for now.  You do a
fancy traversal and choose the nearest node that has a hook set up.
This gives you almost all the complexity of evaluating all of the
installed hooks with none of the benefit.  It also is, IMO, much more
dangerous than only looking at the leaf node.  Consider:

mkdir /cgroup/foo
BPF_PROG_ATTACH(some program to foo)
mkdir /cgroup/foo/bar
chown -R some_user /cgroup/foo/bar

If the kernel only looked at the leaf, then the program that did the
above would not expect that the program would constrain
/cgroup/foo/bar's activity.  But, as it stands, the program *would*
expect /cgroup/foo/bar to be constrained, except that, whenever the
capable() check changes to ns_capable() (which will happen eventually
one way or another), then the bad guy can create /cgroup/foo/bar/baz,
install a new no-op hook there, and break the security assumption.

IOW, I think that totally non-recursive hooks are okay from a security
perspective, albeit rather strange, but the current design is not okay
from a security perspective.

>
>> The current approach to bpf hooks will bite you down the road.  David
>> Ahern is already proposing using it for something that is not tracing
>> at all, and someone will want that in a container, and there will be a
>> problem.
>
> Hmm, I thought we've sorted out the concerns about that by making sure
> that we
>
> a) lock-down the API sufficiently so it doesn't cause any security
> issues in its current form, and

This argument is why iptables + userns has become a security mess, for
example.  Designing an API assuming that the bad guys will never be
permitted to use it causes quite a bit of pain when, a few years
later, bad guys are permitted to use it.

>> I think my proposal is quite close to workable.
>
> So let's talk about how to proceed. I've seen different bits of your
> proposal in different mails, and I think a summary of it would help the
> discussion.

So here's a fleshed-out possible version that's a bit of a compromise
after sleeping on this.  There's plenty of room to tweak this.

Each cgroup gets a new file cgroup.hooks.  Reading it shows a list of
active hooks.  (A hook can be a string like "network.inet_ingress".)

You can write a command like "-network.inet_ingress off" to it to
disable network.inet_ingress.  You can write a command like
"+network.inet_ingress" to it to enable the network.inet_ingress hook.

When a hook (e.g. network.inet_ingress) is enabled, a new file appears
in the cgroup called "hooks.network.inet_ingress").  You can read it
to get an indication of what is currently installed in that slot.  You
can write "none" to it to cause nothing to be installed in that slot.
(This replaces BPF_PROG_DETACH.).  You can open it for write and use
bpf() or perhaps ioctl() to attach a bpf program.  Maybe you can also
use bpf() to dump the bpf program, but, regardless, if a bpf program
is there, read() will return some string that contains "bpf" and maybe
some other useful information.

If a SELinux policy wants to lock down the netowrk.inet_ingress hook,
it uses existing mechanisms to label the hooks.network.inet_ingress
file when it appears and to restrict opening it for write.

I think this is all quite straightforward to implement and will result
in clean code.  I could probably make some decent progress toward it
over the next couple days.

--Andy
