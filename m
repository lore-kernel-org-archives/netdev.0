From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 19:27:25 +0200
Message-ID: <5621337D.8090003@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net> <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net> <1444991103.2861759.411876897.42C807BD@webmail.messagingengine.com> <5620FD52.2060103@iogearbox.net> <1445013408.2943971.412165665.3C995178@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	tgraf@suug.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445013408.2943971.412165665.3C995178@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/2015 06:36 PM, Hannes Frederic Sowa wrote:
> On Fri, Oct 16, 2015, at 15:36, Daniel Borkmann wrote:
>> On 10/16/2015 12:25 PM, Hannes Frederic Sowa wrote:
>>> On Fri, Oct 16, 2015, at 03:09, Daniel Borkmann wrote:
>>>> This eventually leads us to this patch, which implements a minimal
>>>> eBPF file system. The idea is a bit similar, but to the point that
>>>> these inodes reside at one or multiple mount points. A directory
>>>> hierarchy can be tailored to a specific application use-case from the
>>>> various subsystem users and maps/progs pinned inside it. Two new eBPF
>>>> commands (BPF_PIN_FD, BPF_NEW_FD) have been added to the syscall in
>>>> order to create one or multiple special inodes from an existing file
>>>> descriptor that points to a map/program (we call it eBPF fd pinning),
>>>> or to create a new file descriptor from an existing special inode.
>>>> BPF_PIN_FD requires CAP_SYS_ADMIN capabilities, whereas BPF_NEW_FD
>>>> can also be done unpriviledged when having appropriate permissions
>>>> to the path.
>>>
>>> In my opinion this is very un-unixiy, I have to say at least.
>>>
>>> Namespaces at some point dealt with the same problem, they nowadays use
>>> bind mounts of /proc/$$/ns/* to some place in the file hierarchy to keep
>>> the namespace alive. This at least allows someone to build up its own
>>> hierarchy with normal unix tools and not hidden inside a C-program. For
>>> filedescriptors we already have /proc/$$/fd/* but it seems that doesn't
>>> work out of the box nowadays.
>>
>> Yes, that doesn't work out of the box, but I also don't know how usable
>> that would really be. The idea is roughly rather similar to the paths
>> passed to bind(2)/connect(2) on Unix domain sockets, as mentioned. You
>> have a map/prog resource that you stick to a special inode so that you
>> can retrieve it at a later point in time from the same or different
>> processes through a new fd pointing to the resource from user side, so
>> that the bpf(2) syscall can be performed upon it.
>>
>> With Unix tools, you could still create/remove a hierarchy or unlink
>> those that have maps/progs. You are correct that tools that don't
>> implement bpf(2) currently cannot access the content behind it, since
>> bpf(2) manages access to the data itself. I did like the 2nd idea though,
>> mentioned in the commit log, but don't know how flexible we are in
>> terms of adding S_IFBPF to the UAPI.
>
> I don't think it should be a problem. You referred to POSIX Standard in
> your other mail but I can't see any reason why not to establish a new
> file mode. Anyway, FreeBSD (e.g. whiteouts) and Solaris (e.g. Doors,
> Event Ports) are just examples of new modes being added.
>
> mknod /bpf/map/1 m 1 1
>
> :)
>
> Yes, maybe I think this is a better solution architectural instead of
> constructing a new filesystem.

Yeah, also 'man 2 stat' lists a couple of others used by various systems.

The pro's of this approach would be that no new file system would be needed
and the special inode could be placed on top of any 'regular' file system
that would support special files. I do like that as well.

I'm wondering whether this would prevent us in future from opening access
to shell tools etc on that special file, but probably one could provide a
default set of file ops via init_special_inode() that could be overloaded
by the underlying fs if required.

>>> I don't know in terms of how many objects bpf should be able to handle
>>> and if such a bind-mount based solution would work, I guess not.
>>>
>>> In my opinion I still favor a user space approach. Subsystems which use
>>> ebpf in a way that no user space program needs to be running to control
>>> them would need to export the fds by itself. E.g. something like
>>> sysfs/kobject for tc? The hierarchy would then be in control of the
>>> subsystem which could also create a proper naming hierarchy or maybe
>>> even use an already given one. Do most other eBPF users really need to
>>> persist file descriptors somewhere without user space control and pick
>>> them up later?
>>
>> I was thinking about a strict predefined hierarchy dictated by the kernel
>> as well, but was then considering a more flexible approach that could be
>> tailored freely to various use cases. A predefined hierarchy would most
>> likely need to be resolved per subsystem and it's not really easy to map
>> this properly. F.e. if the kernel would try to provide unique ids (as
>> opposed to have a name or annotation member through the syscall), it
>> could end up being quite cryptic. If we let the users choose names, I'm
>> not sure if a single hierarchy level would be enough. Then, additionally
>> you have facilities like tail calls that eBPF programs could do.
>
> I don't think that most subsystems need to expose those file
> descriptors. Seccomp probably will have a supervisor process running and
> per aggregation will also have a user space process running keeping the
> fd alive. So it is all about tc/sched.
>
> And I am not sure if tc will really needs a filesystem to handle all
> this. The simplest approach is to just keep a name <-> fd mapping
> somewhere in the net/sched/ subsystem and use this for all tc users.

Solving this on a generic level eventually felt cleaner, where a subsystem
would have the choice of whether making use of this or not. tc/sched has
currently two types BPF_PROG_TYPE_SCHED_{CLS,ACT}, so a common facility
would be needed for both subsystems. It's a bit hard to see what other
subsystems would come in future, and we could end up with multiple
subsystem-specific APIs essentially doing the same thing.

At the very beginning, there was also the idea to just reference such an
object by name, but it would need to be made available somewhere (procfs?)
to get a picture and manage them from an admin pov. Having some object
exposed as a file like other ipc building blocks seems better, imho.
Whether as special file or file system, yeah, that's a different question.

[...]
> I see that tail calls makes this all very difficult to show which entity
> uses which ebpf entity in some way, as it looks like n:m relationships.

Yes, this is indeed the case.

>> In such cases, one could even craft relationships where a (strict auto
>> generated) tree representation would not be sufficient (f.e.
>> recirculation
>> up to a certain depth). The tail called programs could be changed
>> atomically during runtime, etc. The other issue related to a per
>> subsystem
>> representation is that bpf(2) is the central management interface for
>> creating/accessing maps/progs, and each subsystem then has its own little
>> interface to "install" them internally (f.e. via netlink, setsockopt(2),
>> etc). That means, with tail calls, only the 'root' programs are installed
>> there and further transactions would be needed in order to make
>> individual
>> subsystems aware, so they could potentially generate some hierarchy;
>> don't
>> know, it seems rather complex.
>
> I understand, this is really not suitable to represent in its entirety
> in sysfs or any kind of hierarchical structure right now. Either we
> limit it somewhat (Alexei will certainly intervene here) or one of your
> filesystem approaches will win.
>
> But I still wonder why people are so against user space dependencies?
>
> Another idea that I discussed with Daniel just to have it publicly
> available: a userspace helper would be called for every ebpf entity
> change so it could mirror or keep track ebpf handles in user space. You
> can think along the lines of kernel/core_pattern. This would probably
> also depend on non-anon-inode usage of ebpf fds.

Yes, it seems to me, but other than that, it would also require a user
space daemon managing all these, right? At least from the consensus at
Plumbers, running an extra daemon was considered rather impractical wrt
deployment (same with fuse).

Best,
Daniel
