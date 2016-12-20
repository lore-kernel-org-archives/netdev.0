From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Tue, 20 Dec 2016 10:49:25 -0800
Message-ID: <CALCETrVhjiRMSkvmMDgq_O7niWHiRcvjq-my8nYS9_s8JDye1g@mail.gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com> <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <20161220031802.GA77838@ast-mbp.thefacebook.com> <CALCETrXymvAo-9zhQe=amToz_fs9XGniK2KLZv5Fxc66qcUx6A@mail.gmail.com>
 <bdc18fe4-f90d-49f0-d0a6-a28f87335df2@zonque.org> <CALCETrXyp2ddf4HRsEoN=qEwTBaezOUX2XWj6nxPcbc4t13svw@mail.gmail.com>
 <9e378fb1-23ff-a239-d915-3d9aa26a999e@zonque.org>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9e378fb1-23ff-a239-d915-3d9aa26a999e@zonque.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 10:36 AM, Daniel Mack <daniel@zonque.org> wrote:
> Hi,
>
> On 12/20/2016 06:23 PM, Andy Lutomirski wrote:
>> On Tue, Dec 20, 2016 at 2:21 AM, Daniel Mack <daniel@zonque.org> wrote:
>
>> To clarify, since this thread has gotten excessively long and twisted,
>> I think it's important that, for hooks attached to a cgroup, you be
>> able to tell in a generic way whether something is plugged into the
>> hook.  The natural way to see a cgroup's configuration is to read from
>> cgroupfs, so I think that reading from cgroupfs should show you that a
>> BPF program is attached and also give enough information that, once
>> bpf programs become dumpable, you can dump the program (using the
>> bpf() syscall or whatever).
>
> [...]
>
>> There isn't a big semantic difference between
>> 'open("/cgroup/NAME/some.control.file", O_WRONLY); ioctl(...,
>> CGROUP_ATTACH_BPF, ...)' and 'open("/cgroup/NAME/some.control.file",
>> O_WRONLY); bpf(BPF_PROG_ATTACH, ...);'.  There is, however, a semantic
>> difference when you do open("/cgroup/NAME", O_RDONLY | O_DIRECTORY)
>> because the permission check is much weaker.
>
> Okay, if you have such a control file, you can of course do something
> like that. When we discussed things back then with Tejun however, we
> concluded that a controller that is not completely controllable through
> control knobs that can be written and read via cat is meaningless.
> That's why this has become a 'hidden' cgroup feature.
>
> With your proposed API, you'd first go to the bpf(2) syscall in order to
> get a prog fd, and then come back to some sort of cgroup API to put the
> fd in there. That's quite a mix and match, which is why we considered
> the API cleaner in its current form, as everything that is related to
> bpf is encapsulated behind a single syscall.

You already have to do bpf() to get a prog fd, then open() to get a
cgroup fd, then bpf() or ioctl() to attach, so this isn't much
different, and its exactly the same number of syscalls.

>
>> My preference would be to do an ioctl on a new
>> /cgroup/NAME/network_hooks.inet_ingress file.  Reading that file tells
>> you whether something is attached and hopefully also gives enough
>> information (a hash of the BPF program, perhaps) to dump the actual
>> program using future bpf() interfaces.  write() and ioctl() can be
>> used to configure it as appropriate.
>
> So am I reading this right? You're proposing to add ioctl() hooks to
> kernfs/cgroupfs? That would open more possibilities of course, but I'm
> not sure where that rabbit hole leads us eventually.

Indeed.  I already have a test patch to add ioctl() to kernfs.  Adding
it to cgroupfs shouldn't be much more complicated.

>
>> Another option that I like less would be to have a
>> /cgroup/NAME/cgroup.bpf that lists all the active hooks along with
>> their contents.  You would do an ioctl() on that to program a hook and
>> you could read it to see what's there.
>
> Yes, read() could, in theory, give you similar information than ioctl(),
> but in human-readable form.
>
>> FWIW, everywhere I say ioctl(), the bpf() syscall would be okay, too.
>> It doesn't make a semantic difference, except that I dislike
>> BPF_PROG_DETACH because that particular command isn't BPF-specific at
>> all.
>
> Well, I think it is; it pops the bpf program from a target and drops the
> reference on it. It's not much code, but it's certainly bpf-specific.

I mean the interface isn't bpf-specific.  If there was something that
wasn't bpf attached to the target, you'd still want an API to detach
it.

>
>>>> So if I set up a cgroup that's monitored and call it /cgroup/a and
>>>> enable delegation and if the program running there wants to do its own
>>>> monitoring in /cgroup/a/b (via delegation), then you really want the
>>>> outer monitor to silently drop events coming from /cgroup/a/b?
>>>
>>> That's a fair point, and we've discussed it as well. The issue is, as
>>> Alexei already pointed out, that we do not want to traverse the tree up
>>> to the root for nested cgroups due to the runtime costs in the
>>> networking fast-path. After all, we're running the bpf program for each
>>> packet in flight. Hence, we opted for the approach to only look at the
>>> leaf node for now, with the ability to open it up further in the future
>>> using flags during attach etc.
>>
>> Careful here!  You don't look only at the leaf node for now.  You do a
>> fancy traversal and choose the nearest node that has a hook set up.
>
> But we do the 'complex' operation at attach time or when a cgroup is
> created, both of which are slow-path operations. In the fast-path, we
> only look at the leaf, which may or may not have an effective program
> installed. And that's of course much cheaper then doing the traversing
> for each packet.

You would never traverse the full hierarchy for each packet.  You'd
have a linked list of programs that are attached, kind of like how
there's an "effective" array right now.  I sent out pseudocode earlier
in the thread.

>
>> mkdir /cgroup/foo
>> BPF_PROG_ATTACH(some program to foo)
>> mkdir /cgroup/foo/bar
>> chown -R some_user /cgroup/foo/bar
>>
>> If the kernel only looked at the leaf, then the program that did the
>> above would not expect that the program would constrain
>> /cgroup/foo/bar's activity.  But, as it stands, the program *would*
>> expect /cgroup/foo/bar to be constrained, except that, whenever the
>> capable() check changes to ns_capable() (which will happen eventually
>> one way or another), then the bad guy can create /cgroup/foo/bar/baz,
>> install a new no-op hook there, and break the security assumption.
>>
>> IOW, I think that totally non-recursive hooks are okay from a security
>> perspective, albeit rather strange, but the current design is not okay
>> from a security perspective.
>
> We locked down the ability to override any of these programs with
> CAP_NET_ADMIN, which is also what it takes to flush iptables, right?
> What's the difference?

For iptables, it's ns_capable() now, and there have been a number of
holes in it.  For cgroup, it's going to turn in to ns_capable() sooner
or later, and it would be nice to be ready for it.

--Andy
