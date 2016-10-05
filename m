From: Kees Cook <keescook@chromium.org>
Subject: Re: [RFC v3 16/22] bpf/cgroup,landlock: Handle Landlock hooks per cgroup
Date: Wed, 5 Oct 2016 14:25:33 -0700
Message-ID: <CAGXu5j+F80XCPSVL0VxAAoTiYk5D1NKKC3jyAU=Z0Gi7L9S0aw@mail.gmail.com>
References: <20160914072415.26021-1-mic@digikod.net> <20160914072415.26021-17-mic@digikod.net>
 <CAGXu5jJ-Heb0nnLygYo0xHaJKSrQM5RSVRNYN2NnYddwGHtWkA@mail.gmail.com> <57F5696E.6020502@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57F5696E.6020502@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 5, 2016 at 1:58 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net> =
wrote:
>
>
> On 04/10/2016 01:43, Kees Cook wrote:
>> On Wed, Sep 14, 2016 at 12:24 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.=
net> wrote:
>>> This allows to add new eBPF programs to Landlock hooks dedicated to a
>>> cgroup thanks to the BPF_PROG_ATTACH command. Like for socket eBPF
>>> programs, the Landlock hooks attached to a cgroup are propagated to the
>>> nested cgroups. However, when a new Landlock program is attached to one
>>> of this nested cgroup, this cgroup hierarchy fork the Landlock hooks.
>>> This design is simple and match the current CONFIG_BPF_CGROUP
>>> inheritance. The difference lie in the fact that Landlock programs can
>>> only be stacked but not removed. This match the append-only seccomp
>>> behavior. Userland is free to handle Landlock hooks attached to a cgrou=
p
>>> in more complicated ways (e.g. continuous inheritance), but care should
>>> be taken to properly handle error cases (e.g. memory allocation errors)=
.
>>>
>>> Changes since v2:
>>> * new design based on BPF_PROG_ATTACH (suggested by Alexei Starovoitov)
>>>
>>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>>> Cc: Alexei Starovoitov <ast@kernel.org>
>>> Cc: Andy Lutomirski <luto@amacapital.net>
>>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>>> Cc: Daniel Mack <daniel@zonque.org>
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Cc: Kees Cook <keescook@chromium.org>
>>> Cc: Tejun Heo <tj@kernel.org>
>>> Link: https://lkml.kernel.org/r/20160826021432.GA8291@ast-mbp.thefacebo=
ok.com
>>> Link: https://lkml.kernel.org/r/20160827204307.GA43714@ast-mbp.thefaceb=
ook.com
>>> ---
>>>  include/linux/bpf-cgroup.h  |  7 +++++++
>>>  include/linux/cgroup-defs.h |  2 ++
>>>  include/linux/landlock.h    |  9 +++++++++
>>>  include/uapi/linux/bpf.h    |  1 +
>>>  kernel/bpf/cgroup.c         | 33 ++++++++++++++++++++++++++++++---
>>>  kernel/bpf/syscall.c        | 11 +++++++++++
>>>  security/landlock/lsm.c     | 40 +++++++++++++++++++++++++++++++++++++=
++-
>>>  security/landlock/manager.c | 32 ++++++++++++++++++++++++++++++++
>>>  8 files changed, 131 insertions(+), 4 deletions(-)
>>>
>>> [...]
>>> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
>>> index 7b75fa692617..1c18fe46958a 100644
>>> --- a/kernel/bpf/cgroup.c
>>> +++ b/kernel/bpf/cgroup.c
>>> @@ -15,6 +15,7 @@
>>>  #include <linux/bpf.h>
>>>  #include <linux/bpf-cgroup.h>
>>>  #include <net/sock.h>
>>> +#include <linux/landlock.h>
>>>
>>>  DEFINE_STATIC_KEY_FALSE(cgroup_bpf_enabled_key);
>>>  EXPORT_SYMBOL(cgroup_bpf_enabled_key);
>>> @@ -31,7 +32,15 @@ void cgroup_bpf_put(struct cgroup *cgrp)
>>>                 union bpf_object pinned =3D cgrp->bpf.pinned[type];
>>>
>>>                 if (pinned.prog) {
>>> -                       bpf_prog_put(pinned.prog);
>>> +                       switch (type) {
>>> +                       case BPF_CGROUP_LANDLOCK:
>>> +#ifdef CONFIG_SECURITY_LANDLOCK
>>> +                               put_landlock_hooks(pinned.hooks);
>>> +                               break;
>>> +#endif /* CONFIG_SECURITY_LANDLOCK */
>>> +                       default:
>>> +                               bpf_prog_put(pinned.prog);
>>> +                       }
>>>                         static_branch_dec(&cgroup_bpf_enabled_key);
>>>                 }
>>>         }
>>
>> I get creeped out by type-controlled unions of pointers. :P I don't
>> have a suggestion to improve this, but I don't like seeing a pointer
>> type managed separately from the pointer itself as it tends to bypass
>> a lot of both static and dynamic checking. A union is better than a
>> cast of void *, but it still worries me. :)
>
> This is not fully satisfactory for me neither but the other approach is
> to use two distinct struct fields instead of a union.
> Do you prefer if there is a "type" field in the "pinned" struct to
> select the union?

Since memory usage isn't a huge deal for this, I'd actually prefer
there just be no union at all. Have a type field, and a distinct
pointer field for each type you're expecting to use. That way there
can never be confusion between types and you could even validate that
only a single field type has been populated, etc.

-Kees

--=20
Kees Cook
Nexus Security
