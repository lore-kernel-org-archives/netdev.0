From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Tue, 20 Oct 2015 12:07:51 +0200
Message-ID: <1445335671.822349.415077537.0691ED4C@webmail.messagingengine.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net>
 <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com>
 <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com>
 <87mvviidku.fsf@x220.int.ebiederm.org> <5621B5BC.8020204@plumgrid.com>
 <56223F00.5030203@iogearbox.net> <562301F9.1030702@plumgrid.com>
 <5623B4B4.2010703@iogearbox.net> <5623CD8D.7000500@iogearbox.net>
 <56240814.8020105@plumgrid.com>
 <1445240171.3728424.413797809.230D716F@webmail.messagingengine.com>
 <5624BD0C.3070404@iogearbox.net> <5624FCDF.3090601@iogearbox.net>
 <562518B8.2070401@plumgrid.com> <56252A43.3000706@iogearbox.net>
 <56253335.9000206@plumgrid.com>
 <1445280385.602530.414418777.63627F89@webmail.messagingengine.com>
 <562545AA.2080207@plumgrid.com>
 <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>
 <56255714.2070800@plumgrid.com>
 <1445295769.660392.414696249.0B413DF1@webmail.messagingengine.com>
 <56259438.3080308@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56259438.3080308@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Alexei,

On Tue, Oct 20, 2015, at 03:09, Alexei Starovoitov wrote:
> On 10/19/15 4:02 PM, Hannes Frederic Sowa wrote:
> > I bet commercial software will make use of this ebpf framework, too. And
> > the kernel always helped me and gave me a way to see what is going on,
> > debug which part of my operating system universe interacts with which
> > other part. Merely dropping file descriptors with data attached to them
> > in an filesystem seems not to fulfill my need at all. I would love to
> > see where resources are referenced and why, like I am nowadays.
> 
> agree. common fs with hierarchy will give this visibility in
> one place.
> 
> >> >It feels you're pushing for cdev only because of that potential
> >> >debugging need. Did you actually face that need? I didn't and
> >> >don't like to add 'nice to have' feature until real need comes.
> > Given that we want to monitor the load of a hashmap for graphing
> > purposes. Or liberate some hashmaps from its restriction on number of
> > keys and make upper bounds configurable by admins who know the
> > dimensions of their systems and not some software deep down buried in
> > the bpf syscall where I might not have access to source code. In tc
> > force e.g. hashmaps to do garbage collection because we cannot be sure
> > that under DoS attacks user space clean up gets scheduled early enough
> > if ebpf adds flows to hashtables. I do see need to expand and implement
> > some kind of policy in the future.
> 
> disagree here. admin should not interfere with map parameters.
> What you proposing above sounds very very dangerous.
> Admins to configure GC of maps? What do you think the programs will do
> with such sophisticated maps? What kind of networking app you have
> in mind? Anyway that's a bit off-topic. I'm very curious though.

<off-topic>
Just a pretty obvious idea is accurate sampling of flows.
</off-topic>

> >> >single task in seccomp can have a chain of bpf progs, so hierarchy
> >> >is already there.
> > And it would be great to inspect them.
> 
> again let's not mix criu and lsof-like requirements with 'pin fd'.
> For visibility of normal maps we can add fdinfo and lsof
> can pick it up without any fs or any cdevs.

fdinfo tells me where my position in a file is and which locks the file
have? Nothing like that is supposed to work on bpf file descriptors,
because they are kind of special. A new hierarchy has to be installed
alongside fdinfo/.

> > I am fine with creating maps only by bpf syscall. But to hide
> > configuration details or at least not be really able to query them
> > easily seems odd to me. If we go with the ebpffs how could those
> > attributes be added?
> 
> I'm not advocating to hide details. Most of the time maps will not be
> pinned, so fdinfo seems the easiest way to show things like key_size,
> value_size, max_entries, type.

This is an argument in favor of the "fdinfo-like" approach.

So far, if someone wants to delve into the details of a map my approach
would be to take the file descriptor and make it persistence. I have to
think about that some more.

> Even if we decide to do it some other way, it's not related to 'pin fd'
> discussion, since debugging/visibility is nice to have for all bpf 
> objects. Note that walking of key/value without pretty-printers
> provided by the app is meaningless for admin, so only things
> like 'how much memory this map is using' are useful.

Yes, absolutely and I am absolutely against pretty printing key values
in kernel domain.

> May be we should try to draft the hierarchy of this common fs.
> How about:
> /sys/kernel/bpf/username/optional_dirs_mkdir_by_user/progX
> and 'cat' of it will print the same as fdinfo for normal maps,
> so admin can see what maps were pinned by user and its cost.

So cat-ing them will produce text output with some details about the
map? This is what I wanted to avoid. The concept with symlinks and small
files seems much cleaner and nicer to me. Also you cannot add writable
attributes to this filesystem or you overload stuff heavily?

> Inside 'fdinfo' output we can provide pointers to which progs
> are using which maps as
> # cat /sys/kernel/bpf/.../mapX
> key_size: 4
> used_by: /proc/xxx/fd/5
> # cat /sys/kernel/bpf/.../progY
> type: socket
> using: /proc/xxx/fd/6
> using: /sys/kernel/bpf/.../mapZ
> and similar for cat /proc/xxx/fdinfo/6
> but showing hierarchy as directories is non starter, since
> it's no a tree.

It is not a tree but a graph, sure, that's why sysfs allows to break the
cyclic dependencies and create symlinks (see holders/ directories). ;)

And if you implement the same set of features IMHO you basically
re-implement sysfs. In the beginning we just expose the basic maps and
there won't be any features in sysfs, but it will be cheap to have
read/write flags on maps etc. etc. (I don't know what people will come
up with, yet.). In my opinion those are clearly attributes of a map and
should be defined and managed alongside with their holders.

> All of these would be nice, but doesn't have to be implemented
> along with 'pin fd' feature.

The pinfd feature will provide the future infrastructure alongside to
make this usable, so I think it is worth spending time to think about
it.

Thanks,
Hannes
