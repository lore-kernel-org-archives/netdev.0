From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Tue, 20 Oct 2015 11:43:48 +0200
Message-ID: <1445334228.816594.415045713.19D1F84C@webmail.messagingengine.com>
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
 <56255714.2070800@plumgrid.com> <56256BF9.1090500@iogearbox.net>
 <56258B11.9080505@plumgrid.com>
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
In-Reply-To: <56258B11.9080505@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Alexei,

On Tue, Oct 20, 2015, at 02:30, Alexei Starovoitov wrote:
> On 10/19/15 3:17 PM, Daniel Borkmann wrote:
> > On 10/19/2015 10:48 PM, Alexei Starovoitov wrote:
> >> On 10/19/15 1:03 PM, Hannes Frederic Sowa wrote:
> >>>
> >>> I doubt it will stay a lightweight feature as it should not be in the
> >>> responsibility of user space to provide those debug facilities.
> >>
> >> It feels we're talking past each other.
> >> I want to solve 'persistent map' problem.
> >> debugging of maps/progs, hierarchy, etc are all nice to have,
> >> but different issues.
> >
> > Ok, so you are saying that this file system will have *only* regular
> > files that are to be considered nodes for eBPF maps and progs. Nothing
> > else will ever be added to it? Yet, eBPF map and prog nodes are *not*
> > *regular files* to me, this seems odd.
> >
> > As soon as you are starting to add additional folders that contain
> > files dumping additional meta data, etc, you basically end up on a
> > bit of similar concept to sysfs, no?
> 
> as we discussed in this thread and earlier during plumbers I think
> it would be good to expose key/values somehow in this fs.
> 'how' is a big question.
> But regardless which path we take, sysfs is too rigid.
> For the sake of argument say we do every key as a new file in bpffs.
> It's not very scalable, but comparing to sysfs it's better
> (resource wise).
> If we decide to add bpf syscall command to expose map details we
> can provide pretty printer to it in a form of printk-like string
> or via some schema passed to syscall, so that keys(file names) can
> look properly in bpffs.
> The above and other ideas all possible in bpffs, but not possible
> in sysfs.

If you come up with a layout (albeit I don't understand how to enforce
it, later on this more), it is kind of an uapi. It is not possible to
just change the layout of the filesystem in every kernel version.

Take f.e. bpffs like Daniel proposed it, how would you extend it to a
key/value store like of map.

Really, my IPv6 addresses very often have '\0' inside them, I don't see
a way, if they are part of a key, how to represent them in a filename.
That is forbidden by all means.

Adding pretty printer for such a filesystem is something user space
should do. How do you want to handle that? Make printk available from
ebpf programs and ebpf programs bring their own pretty-printer for their
key and values? This really looks like a security hazard. User space is
so much easier and fuse, if you want to have a key/value representation
of your map, why not in user space?

In any way, in case a key/value filesystem is needed I certainly want to
go with Eric Biederman and have one mount point per map. Otherwise I
also can't see how this should work in terms of permissions.

> >> In case of persistent maps I imagine unprivileged process would want
> >> to use it eventually as well, so this requirement already kills cdev
> >> approach for me, since I don't think we ever let unprivileged apps
> >> create cdev with syscall.
> >
> > Hmm, I see. So far the discussion was only about having this for privileged
> > users (also in this fs patch). F.e. privileged system daemons could setup
> > and distribute progs/maps to consumers, etc (f.e. seccomp and tc case).
> 
> It completely makes sense to restrict it to admin today, but design
> should not prevent relaxing it in the future.

Even today lot's of unprivileged devices are used by users from day to
day. Soundcards, terminals etc. This is also possible with cdevs.

> > When we start lifting this, eBPF maps by its own will become a real kernel
> > IPC facility for unprivileged Linux applications (independently whether
> > they are connected to an actual eBPF program). Those kernel IPC facilities
> > that are anchored in the file system like named pipes and Unix domain
> > sockets
> > are indicated as such as special files, no?
> 
> not everything in unix is a model that should be followed.
> af_unix with name[0]!=0 is a bad api that wasn't thought through.
> Thankfully Linux improved it with abstract names that don't use
> special files.
> bpf maps obviously is not an IPC (either pinned or not).

Sure, it is, IPC between ebpf programs and some kind of user space
controlling application.

> >> sure, then we can force all bpffs to have the same hierarchy and mounted
> >> in /sys/kernel/bpf location. That would be the same.
> >
> > That would imply to have a mount_single() file system (like f.e. tracefs
> > and
> > securityfs), right?
> 
> Probably. I'm not sure whether it should be single fs or we allow
> multiple mount points. There are pro and con for both.

Multiple mount points actually seem dangerous to me. Especially if fds
get pinned into multiple of those filesystems.

> > So you'd loose having various mounts in different namespaces. And if you
> > allow various mount points, how would that /facilitate/ to an admin to
> > identify all eBPF objects/resources currently present in the system?
> 
> if it's single mount point there are no issues, but would be nice
> to separate users and namespaces somehow.
> 
> > Or to an application developer finding possible mount points for his own
> > application so that bpf(2) syscall to create these nodes succeeds? Would
> > you make mounting also unprivileged? What if various distros have these
> > mount points at different locations? What should unprivileged applications
> > do to know that they can use these locations for themselves?
> 
> mounting is root only of course and having standard location answers
> all of these questions.

Then we miss the separation of users and namespaces we were talking
about above. This also needs some way of governing user space
application, I don't believe users will conform to the "you should first
add a directory for your user then for your program"-convention. cgroups
layout kind of got first "standardized" by systemd.

> > Also, since they are only regular files, one can only try and find these
> > objects based on their naming schemes, which seems to get a bit odd in case
> > this file system also carries (perhaps future?) other regular files that
> > are not eBPF map and program-special.
> 
> not sure what you meant. If names are given by kernel, there are no
> problem finding them. If by user, we'd file attributes like the way
> you did with xattr.
> 
> >> It feels you're pushing for cdev only because of that potential
> >> debugging need. Did you actually face that need? I didn't and
> >> don't like to add 'nice to have' feature until real need comes.
> >
> > I think this discussion arose, because the question of how flexible we are
> > in future to extend this facility. Nothing more.
> 
> Exactly and cdev style pushes us into the corner of traditional
> cdev with ioctl which I don't think is flexible enough.

But we don't need ioctls! ;)

Bye,
Hannes
