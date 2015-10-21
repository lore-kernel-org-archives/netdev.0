From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Wed, 21 Oct 2015 15:44:37 -0700
Message-ID: <56281555.3030504@plumgrid.com>
References: <1445280385.602530.414418777.63627F89@webmail.messagingengine.com>
 <562545AA.2080207@plumgrid.com>
 <1445284997.621186.414538017.6E35B341@webmail.messagingengine.com>
 <56255714.2070800@plumgrid.com> <56256BF9.1090500@iogearbox.net>
 <56258B11.9080505@plumgrid.com> <5625FF71.8020304@iogearbox.net>
 <56267FAF.60206@plumgrid.com> <87io61fjx3.fsf@x220.int.ebiederm.org>
 <5627AC79.5000704@iogearbox.net> <20151021183447.GC23554@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Thomas Graf <tgraf@suug.ch>, Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151021183447.GC23554@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/15 11:34 AM, Thomas Graf wrote:
>> So far, during this discussion, it was proposed to modify the file system
>> >to a single-mount one and to stick this under/sys/kernel/bpf/. This
>> >will not have "real" namespace support either, but it was proposed to
>> >have a following structure:
>> >
>> >   /sys/kernel/bpf/username/<optional_dirs_mkdir_by_user>/progX
> This would probably work as you would typically map the ebpf map
> using -v like this to give a stable path:
>
>          docker run -v /sys/kernel/bpf/foo/maps/progX:/map proX

yep
tracefs works inside docker the same way.
May be we should let users pick names similar to this fs patch to make
the above easier to use.
Also from bpf syscall point of the user shouldn't see
/sys/kernel/bpf/user/ prefix. Only 'optional_dirs_mkdir_by_user/name'
when doing pin/new_fd.
May be prog type should be a fixed part of the path as well.

>> >Together with device cgroups for containers, it would allow scenarios where
>> >you can have:
>> >
>> >   * eBPF (map/prog) device pass-through so a map/prog could even be shared out
>> >     from the initial namespace into individual ones/all (one could possibly
>> >     extend such maps as read-only for these consumers).
>> >   * eBPF device creation for unprivileged users with permissions being set
>> >     accordingly (as in fs case).
>> >   * Since cgroup controller can also do wildcards on major/minors, we could
>> >     make that further fine-grained.
>> >   * eBPF device creation can also be enforced by the cgroup controller to be
>> >     entirely disallowed for a specific container.

none of the above is practical. It can be demoed in a canned
environment, but it's a complete mismatch of apis. cgroup/dev is a
static config, whereas bpf-cdev is dynamic (with minors out of idr for
all users) When you have to hack drivers/base/core.c to get there it
should have been a warning sign that something is wrong with
this cdev approach.

> I've read the discussion passively and my take away is that, frankly,
> I think the differences are somewhat minor. Both architectures can
> scale to what we need. Both will do the job. I'm slightly worried about
> exposing uAPI as a FS, I think that didn't work too well for sysfs. It's
> pretty much a define the format once and never touch it again kind of
> deal.

It's even worse in cdev style since it piggy backs on sysfs.
