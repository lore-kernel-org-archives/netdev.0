From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Tue, 20 Oct 2015 00:17:29 +0200
Message-ID: <56256BF9.1090500@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net> <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com> <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net> <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com> <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com> <87mvviidku.fsf@x220.int.ebiederm.org> <5621B5BC.8020204@plumgrid.com> <56223F00.5030203@iogearbox.net> <562301F9.1030702@plumgrid.com> <5623B4B4.2010703@iogearbox.net> <5623CD8D.7000500@iogearbox.net> <56240814.8020105@plumgrid.com> <1445240171.3728424.413797809.230D716F@webmail.messagingengine.com> <5624BD0C.3070404@iogearbox.net> <5624FCDF.3090601@iogearbox.net> <562518B8.2070401@plumgrid.com> <56252A43.3000706@iogearbox.net> <56253335.9000206@plumgrid.com> <1445280
 385.602530.414418777.63627F89@webmail.messagingengine.com> <562545AA.2080207@plumgrid.com> <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com> <56255714.2070800@plumgrid.com>
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
In-Reply-To: <56255714.2070800@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2015 10:48 PM, Alexei Starovoitov wrote:
> On 10/19/15 1:03 PM, Hannes Frederic Sowa wrote:
>>
>> I doubt it will stay a lightweight feature as it should not be in the
>> responsibility of user space to provide those debug facilities.
>
> It feels we're talking past each other.
> I want to solve 'persistent map' problem.
> debugging of maps/progs, hierarchy, etc are all nice to have,
> but different issues.

Ok, so you are saying that this file system will have *only* regular
files that are to be considered nodes for eBPF maps and progs. Nothing
else will ever be added to it? Yet, eBPF map and prog nodes are *not*
*regular files* to me, this seems odd.

As soon as you are starting to add additional folders that contain
files dumping additional meta data, etc, you basically end up on a
bit of similar concept to sysfs, no?

> In case of persistent maps I imagine unprivileged process would want
> to use it eventually as well, so this requirement already kills cdev
> approach for me, since I don't think we ever let unprivileged apps
> create cdev with syscall.

Hmm, I see. So far the discussion was only about having this for privileged
users (also in this fs patch). F.e. privileged system daemons could setup
and distribute progs/maps to consumers, etc (f.e. seccomp and tc case).

When we start lifting this, eBPF maps by its own will become a real kernel
IPC facility for unprivileged Linux applications (independently whether
they are connected to an actual eBPF program). Those kernel IPC facilities
that are anchored in the file system like named pipes and Unix domain sockets
are indicated as such as special files, no?

>> The bpf syscall is still used to create the pseudo nodes. If they should
>> be persistent they just get registered in the sysfs class hierarchy.
>
> nope. they should not. sysfs is debugging/tunning facility.
> There is absolutely no need for bpf to plug into sysfs.
>
>>> Doing 'resource stats' via sysfs requires bpf to add to sysfs, which
>>> is not this cdev approach.
>>
>> This is not yet part of the patch, but I think this would be added.
>> Daniel?
>
> please don't. I'm strongly against adding unnecessary bloat.
>
>> I don't think there are broad differences. But in case a namespaces uses
>> huge number of maps with tons of data, the admin in the initial
>> namespace might want to debug that without searching all mountpoints and
>> find dependencies between processes etc. IMHO sysfs approach can be
>> better extended here.
>
> sure, then we can force all bpffs to have the same hierarchy and mounted
> in /sys/kernel/bpf location. That would be the same.

That would imply to have a mount_single() file system (like f.e. tracefs and
securityfs), right?

So you'd loose having various mounts in different namespaces. And if you
allow various mount points, how would that /facilitate/ to an admin to
identify all eBPF objects/resources currently present in the system?

Or to an application developer finding possible mount points for his own
application so that bpf(2) syscall to create these nodes succeeds? Would
you make mounting also unprivileged? What if various distros have these
mount points at different locations? What should unprivileged applications
do to know that they can use these locations for themselves?

Also, since they are only regular files, one can only try and find these
objects based on their naming schemes, which seems to get a bit odd in case
this file system also carries (perhaps future?) other regular files that
are not eBPF map and program-special.

> It feels you're pushing for cdev only because of that potential
> debugging need. Did you actually face that need? I didn't and
> don't like to add 'nice to have' feature until real need comes.

I think this discussion arose, because the question of how flexible we are
in future to extend this facility. Nothing more.

I still don't consider the cdev approach as a hack. Despite a bit "old
school" as you say, the semantics seem to be better defined, imho. It
integrates better into existing facilities.

Cheers,
Daniel
