From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Tue, 20 Oct 2015 10:53:51 -0700
Message-ID: <56267FAF.60206@plumgrid.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <56213A61.40509@iogearbox.net> <87d1welkp8.fsf@x220.int.ebiederm.org>
 <56214FAC.5060704@plumgrid.com> <87y4f2io9l.fsf@x220.int.ebiederm.org>
 <5621649A.80403@plumgrid.com> <87mvviidku.fsf@x220.int.ebiederm.org>
 <5621B5BC.8020204@plumgrid.com> <56223F00.5030203@iogearbox.net>
 <562301F9.1030702@plumgrid.com> <5623B4B4.2010703@iogearbox.net>
 <5623CD8D.7000500@iogearbox.net> <56240814.8020105@plumgrid.com>
 <1445240171.3728424.413797809.230D716F@webmail.messagingengine.com>
 <5624BD0C.3070404@iogearbox.net> <5624FCDF.3090601@iogearbox.net>
 <562518B8.2070401@plumgrid.com> <56252A43.3000706@iogearbox.net>
 <56253335.9000206@plumgrid.com>
 <1445280385.602530.414418777.63627F89@webmail.messagingengine.com>
 <562545AA.2080207@plumgrid.com>
 <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>
 <56255714.2070800@plumgrid.com> <56256BF9.1090500@iogearbox.net>
 <56258B11.9080505@plumgrid.com> <5625FF71.8020304@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5625FF71.8020304@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/15 1:46 AM, Daniel Borkmann wrote:
>> as we discussed in this thread and earlier during plumbers I think
>> it would be good to expose key/values somehow in this fs.
>> 'how' is a big question.
>
> Yes, it is a big question, and probably best left to the domain-specific
> application itself, which can already dump the map nowadays via bpf(2)
> syscall. You can add bindings to various languages to make it available
> elsewhere as well.
>
> Or, you have a user space 'bpf' tool that can connect to any map that is
> being exposed with whatever model, and have modular pretty printers in
> user space somewhere located as shared objects, they could get auto-loaded
> in the background. Maps could get an annotation attached as an attribute
> during creation that is being exposed somewhere, so it can be mapped to
> a pretty printer shared object. This would better be solved in user space
> entirely, in my opinion, why should the kernel add complexity for this
> when this is so much user-space application specific anyway?
>
> As we all agreed, looking into key/values via shell is a rare event and
> not needed most of the times. It comes with it's own problems (f.e. think
> of dumping a possible rhashtable map with key/values as files). But even
> iff we'd want to stick this into files by all means, fusefs can do this
> specific job entirely in user space _plus_ fetching these shared objects
> for pretty printers etc, all we need for this is to add this annotation/
> mapping attribute somewhere to bpf_maps and that's all it takes.
>
> This question is no doubt independant of the fd pinning mechanism, but as
> I said, I don't think sticking this into the kernel is a good idea. Why
> would that be the kernel's job?

agree with all of the concerns above. I said it would be good for
kernel to expose key/values and I still think it would be a useful
feature. Regardless whether kernel does it or not in the future,
the point was 'IF we want kernel to do it then bpf FS is the right way'.

> In the other email, you are mentioning fdinfo. fdinfo can be done for any
> map/prog already today by just adding the right .show_fdinfo() callback to
> bpf_map_fops and bpf_prog_fops, so we let the anon-inodes that we already
> use today to do this job for free and such debugging info can be inspected
> through procfs already. This is common practice, f.e. look at timerfd,
> signalfd and others.

I know. That's exactly what I proposed, but again the point was
that fdinfo of regular FDs should match in style to pinned FDs,
'cat /sys/kernel/bpf/.../map5' should be similar to
'cat /proc/.../fdinfo/5'
and 'cat /sys/kernel/bpf...' you can only cleanly do with bpffs.

>> But regardless which path we take, sysfs is too rigid.
>> For the sake of argument say we do every key as a new file in bpffs.
>> It's not very scalable, but comparing to sysfs it's better
>> (resource wise).
>
> I doubt this is scaleable at all, no matter if its sysfs or a own custom
> fs. How should that work. You have a map with possibly thousands or
> millions
> of entries. Are these files to be generated on the fly like in procfs as
> soon as you enter that directory? Or as a one-time snapshot (but then
> the user mights want to create various snapshots)? There might be new
> map elements as building blocks in the future such as pipes, ring buffers
> etc. How are they being dumped as files?

you're arguing that keys as files are not scalable. sure.
See what I said above "it's not very scalable"
The point is that fs approach is more flexible comparing to cdev.

>> not everything in unix is a model that should be followed.
>> af_unix with name[0]!=0 is a bad api that wasn't thought through.
>> Thankfully Linux improved it with abstract names that don't use
>> special files.
>> bpf maps obviously is not an IPC (either pinned or not).
>
> So, if this pinning facility is unprivileged and available for *all*
> applications, then applications can in-fact use eBPF maps (w/o any
> other aides such as Unix domain sockets to transfer fds) among themselves
> to exchange state via bpf(2) syscall. It doesn't need a corresponding
> program.

Obviously I know that, but it doesn't make it an IPC.
Just because two processes can talk to each other via normal tcpip it
doesn't make tcpip an IPC mechanism.
The point is "just because two processes can communicate with each
other via X (bpf maps) we are not going to optimize (or make
architectural decisions in X) just for this use case". It's a job of
generic IPC and we have enough of them already.

> Okay, sure, but then having a mount_single() and separating users and
> namespaces is still not being resolved, as you've noticed.

yes and that's what I proposed to do:
Tweaking this FS patch to do mount_single() and define directory
structure is the best way forward.

> So, if you distribute the names through the kernel and dictate a strict
> hierarchy, then we'll end up with a similar model that cdevs resolve.

yes. exactly.
but comparing to cdev, it will be:
- cheaper for kernel to keep (memory wise)
- faster to pin FDs
- do normal 'rm' to destroy
- possible to extend to unprivileged users
- possible to add fdinfo (same output for pinned and normal fd)
- possible to expose key/value

I'm puzzled how you can keep arguing in favor of cdev when it's
obviously deficient comparing to fs and fs has no disadvantages.
Looks like we can only resolve it over beer.
How about we setup a public hangout ? Today or tomorrow?
