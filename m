From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups
Date: Fri, 26 Aug 2016 07:20:35 -0700
Message-ID: <CALCETrVFSbrW9VzdNirtwCXZ3-Ce1DnXoQcPgEQgbyy0=W0rEQ@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net> <CALCETrVqfTaY4gfwNdwynBqWwYh6xsGHaqdoA3uc_jHogbkA-A@mail.gmail.com>
 <57BF043D.4000300@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Arnd Bergmann <arnd@arndb.de>, Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
	David Drysdale <drysdale@google.com>, "David S . Miller" <davem@davemloft.net>,
	Elena Reshetova <elena.reshetova@intel.com>, James Morris <james.l.morris@oracle.com>,
	Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
	Sargun Dhillon <sargun@sargun.me>, "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux API <linux-api@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <kernel-hardening-return-4471-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <57BF043D.4000300@digikod.net>
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 7:44 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
>
> On 25/08/2016 13:09, Andy Lutomirski wrote:
>> On Thu, Aug 25, 2016 at 3:32 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.n=
et> wrote:
>>> Add an eBPF function bpf_landlock_cmp_cgroup_beneath(opt, map, map_op)
>>> to compare the current process cgroup with a cgroup handle, The handle
>>> can match the current cgroup if it is the same or a child. This allows
>>> to make conditional rules according to the current cgroup.
>>>
>>> A cgroup handle is a map entry created from a file descriptor referring
>>> a cgroup directory (e.g. by opening /sys/fs/cgroup/X). In this case, th=
e
>>> map entry is of type BPF_MAP_HANDLE_TYPE_LANDLOCK_CGROUP_FD and the
>>> inferred array map is of type BPF_MAP_ARRAY_TYPE_LANDLOCK_CGROUP.
>>
>> Can you elaborate on why this is useful?  I.e. why not just supply
>> different policies to different subtrees.
>
> The main use case I see is to load the security policies at the start of
> a user session for all processes but not enforce them right away. The
> user can then keep a shell for Landlock administration tasks and lock
> the other processes with a dedicated cgroup on the fly. This allows the
> user to make unremovable Landlock security policies but only activate
> them when needed for specific processes.

This seems like a bit of a dubious use case to me.  The landlock
mechanism should be flexible enough to do this kind of thing even
without cgroups, and "spawn a process, wait a while, and then confine
it by fiddling with cgroups" seems a lot dicier than just loading the
right policy in the first place, especially since eBPF policies can be
stateful.

>
>>
>> Also, how does this interact with the current cgroup v1 vs v2 mess?
>> As far as I can tell, no one can even really agree on what "what
>> cgroup am I in" means right now.
>
> I tested with cgroup-v2 but indeed, it seems a bit different with
> cgroup-v1 :)
> Does anyone know how to handle both cases?
>
>>
>>>
>>> An unprivileged process can create and manipulate cgroups thanks to
>>> cgroup delegation.
>>
>> What is cgroup delegation?
>
> This is simply the action of changing the owner of cgroup sysfs files to
> allow an unprivileged user to handle them (cf. Documentation/cgroup-v2.tx=
t)

As far as I can tell, Tejun and systemd both actively discourage doing
this.  Maybe I misunderstand.  But in any event, the admin giving you
a cgroup hierarchy you can use for this means that the admin has to
cooperate with your policy, and it further requires (with cgroup v2 or
similar, which is most likely the future) that your lockdown policy be
compatible with your resource control policy.

I would suggest dropping this lockdown feature until a use case
emerges that really can't be addressed adequately without it.

--Andy
