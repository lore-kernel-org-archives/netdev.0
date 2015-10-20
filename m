From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Tue, 20 Oct 2015 10:46:41 +0200
Message-ID: <5625FF71.8020304@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net> <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net> <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com> <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com> <87mvviidku.fsf@x220.int.ebiederm.org> <5621B5BC.8020204@plumgrid.com> <56223F00.5030203@iogearbox.net> <562301F9.1030702@plumgrid.com> <5623B4B4.2010703@iogearbox.net> <5623CD8D.7000500@iogearbox.net> <56240814.8020105@plumgrid.com> <1445240171.3728424.413797809.230D716F@webmail.messagingengine.com> <5624BD0C.3070404@iogearbox.net> <5624FCDF.3090601@iogearbox.net> <562518B8.2070401@plumgrid.com> <56252A43.3000706@iogearbox.net> <56253335.9000206@plumgrid.com> <1445280385.602530.414418777.63627F89@webmail.messagingengine.com> <562545AA
 .2080207@plumgrid.com> <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com> <56255714.2070800@plumgrid.com> <56256BF9.1090500@iogearbox.net> <56258B11.9080505@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56258B11.9080505@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/2015 02:30 AM, Alexei Starovoitov wrote:
> On 10/19/15 3:17 PM, Daniel Borkmann wrote:
>> On 10/19/2015 10:48 PM, Alexei Starovoitov wrote:
>>> On 10/19/15 1:03 PM, Hannes Frederic Sowa wrote:
>>>>
>>>> I doubt it will stay a lightweight feature as it should not be in the
>>>> responsibility of user space to provide those debug facilities.
>>>
>>> It feels we're talking past each other.
>>> I want to solve 'persistent map' problem.
>>> debugging of maps/progs, hierarchy, etc are all nice to have,
>>> but different issues.
>>
>> Ok, so you are saying that this file system will have *only* regular
>> files that are to be considered nodes for eBPF maps and progs. Nothing
>> else will ever be added to it? Yet, eBPF map and prog nodes are *not*
>> *regular files* to me, this seems odd.
>>
>> As soon as you are starting to add additional folders that contain
>> files dumping additional meta data, etc, you basically end up on a
>> bit of similar concept to sysfs, no?
>
> as we discussed in this thread and earlier during plumbers I think
> it would be good to expose key/values somehow in this fs.
> 'how' is a big question.

Yes, it is a big question, and probably best left to the domain-specific
application itself, which can already dump the map nowadays via bpf(2)
syscall. You can add bindings to various languages to make it available
elsewhere as well.

Or, you have a user space 'bpf' tool that can connect to any map that is
being exposed with whatever model, and have modular pretty printers in
user space somewhere located as shared objects, they could get auto-loaded
in the background. Maps could get an annotation attached as an attribute
during creation that is being exposed somewhere, so it can be mapped to
a pretty printer shared object. This would better be solved in user space
entirely, in my opinion, why should the kernel add complexity for this
when this is so much user-space application specific anyway?

As we all agreed, looking into key/values via shell is a rare event and
not needed most of the times. It comes with it's own problems (f.e. think
of dumping a possible rhashtable map with key/values as files). But even
iff we'd want to stick this into files by all means, fusefs can do this
specific job entirely in user space _plus_ fetching these shared objects
for pretty printers etc, all we need for this is to add this annotation/
mapping attribute somewhere to bpf_maps and that's all it takes.

This question is no doubt independant of the fd pinning mechanism, but as
I said, I don't think sticking this into the kernel is a good idea. Why
would that be the kernel's job?

In the other email, you are mentioning fdinfo. fdinfo can be done for any
map/prog already today by just adding the right .show_fdinfo() callback to
bpf_map_fops and bpf_prog_fops, so we let the anon-inodes that we already
use today to do this job for free and such debugging info can be inspected
through procfs already. This is common practice, f.e. look at timerfd,
signalfd and others.

> But regardless which path we take, sysfs is too rigid.
> For the sake of argument say we do every key as a new file in bpffs.
> It's not very scalable, but comparing to sysfs it's better
> (resource wise).

I doubt this is scaleable at all, no matter if its sysfs or a own custom
fs. How should that work. You have a map with possibly thousands or millions
of entries. Are these files to be generated on the fly like in procfs as
soon as you enter that directory? Or as a one-time snapshot (but then
the user mights want to create various snapshots)? There might be new
map elements as building blocks in the future such as pipes, ring buffers
etc. How are they being dumped as files?

> If we decide to add bpf syscall command to expose map details we
> can provide pretty printer to it in a form of printk-like string
> or via some schema passed to syscall, so that keys(file names) can
> look properly in bpffs.
> The above and other ideas all possible in bpffs, but not possible
> in sysfs.

So, you'd need schemes for keys /and/ values. They could both be complicated
structures and even within these structures, you might need further domain
specific knowledge to dump stuff properly. Perhaps to make sense of it, a
member of that structure needs further processing, etc. That's why I think,
as mentioned above, it's better done in user space through modular shared
objects helpers. A default set of these .so files for pretty printing common
stuff could be shipped already and for more complex applications, they can
ship through distros their own .so files along with the application. And
developers can hack their own modules together locally, too.

So, neither sysfs nor bpffs would need anything here. Why force this into
the kernel? Even more so, if it's just rarely used anyway?

>>> In case of persistent maps I imagine unprivileged process would want
>>> to use it eventually as well, so this requirement already kills cdev
>>> approach for me, since I don't think we ever let unprivileged apps
>>> create cdev with syscall.
>>
>> Hmm, I see. So far the discussion was only about having this for privileged
>> users (also in this fs patch). F.e. privileged system daemons could setup
>> and distribute progs/maps to consumers, etc (f.e. seccomp and tc case).
>
> It completely makes sense to restrict it to admin today, but design
> should not prevent relaxing it in the future.
>
>> When we start lifting this, eBPF maps by its own will become a real kernel
>> IPC facility for unprivileged Linux applications (independently whether
>> they are connected to an actual eBPF program). Those kernel IPC facilities
>> that are anchored in the file system like named pipes and Unix domain
>> sockets
>> are indicated as such as special files, no?
>
> not everything in unix is a model that should be followed.
> af_unix with name[0]!=0 is a bad api that wasn't thought through.
> Thankfully Linux improved it with abstract names that don't use
> special files.
> bpf maps obviously is not an IPC (either pinned or not).

So, if this pinning facility is unprivileged and available for *all*
applications, then applications can in-fact use eBPF maps (w/o any
other aides such as Unix domain sockets to transfer fds) among themselves
to exchange state via bpf(2) syscall. It doesn't need a corresponding
program.

>>> sure, then we can force all bpffs to have the same hierarchy and mounted
>>> in /sys/kernel/bpf location. That would be the same.
>>
>> That would imply to have a mount_single() file system (like f.e. tracefs
>> and
>> securityfs), right?
>
> Probably. I'm not sure whether it should be single fs or we allow
> multiple mount points. There are pro and con for both.
>
>> So you'd loose having various mounts in different namespaces. And if you
>> allow various mount points, how would that /facilitate/ to an admin to
>> identify all eBPF objects/resources currently present in the system?
>
> if it's single mount point there are no issues, but would be nice
> to separate users and namespaces somehow.
>
>> Or to an application developer finding possible mount points for his own
>> application so that bpf(2) syscall to create these nodes succeeds? Would
>> you make mounting also unprivileged? What if various distros have these
>> mount points at different locations? What should unprivileged applications
>> do to know that they can use these locations for themselves?
>
> mounting is root only of course and having standard location answers
> all of these questions.

Okay, sure, but then having a mount_single() and separating users and
namespaces is still not being resolved, as you've noticed.

>> Also, since they are only regular files, one can only try and find these
>> objects based on their naming schemes, which seems to get a bit odd in case
>> this file system also carries (perhaps future?) other regular files that
>> are not eBPF map and program-special.
>
> not sure what you meant. If names are given by kernel, there are no
> problem finding them. If by user, we'd file attributes like the way
> you did with xattr.

So, if you distribute the names through the kernel and dictate a strict
hierarchy, then we'll end up with a similar model that cdevs resolve.

>>> It feels you're pushing for cdev only because of that potential
>>> debugging need. Did you actually face that need? I didn't and
>>> don't like to add 'nice to have' feature until real need comes.
>>
>> I think this discussion arose, because the question of how flexible we are
>> in future to extend this facility. Nothing more.
>
> Exactly and cdev style pushes us into the corner of traditional
> cdev with ioctl which I don't think is flexible enough.

So, as elaborated above in terms of pretty printers and fdinfo examples,
they can all be resolved much more elegantly. So far I still fail to see
the reason why a custom dedicated fs would be better to make the pinning
syscall work, when this can be solved with a better integration into
Linux facilities by using cdevs.

Thanks !
