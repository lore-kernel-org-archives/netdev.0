From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v5 06/10] seccomp,landlock: Handle Landlock events per
 process hierarchy
Date: Wed, 1 Mar 2017 14:20:44 -0800
Message-ID: <CALCETrWpXnFs3=tWjJSi6-E=XgbZVnq1p-Ty3BtPvXZawriHMw@mail.gmail.com>
References: <20170222012632.4196-1-mic@digikod.net> <20170222012632.4196-7-mic@digikod.net>
 <CALCETrWExjKHccdj-cYxPtis1NtXTPEYfReNLh065J1hHKvFiA@mail.gmail.com> <e6c917cb-d4a6-4147-9d6e-9c9fc906621d@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>,
	Daniel Borkmann <daniel@iogearbox.net>, David Drysdale <drysdale@google.com>,
	"David S . Miller" <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>,
	James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
	Jonathan Corbet <corbet@lwn.net>, Matthew Garrett <mjg59@srcf.ucam.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>, Kees Cook <keescook@chromium.org>,
	Paul Moore <paul@paul-moore.com>, Sargun Dhillon <sargun@sargun.me>,
	"Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>, Tejun Heo <tj@kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Will Drewry <wad@chromium.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <kernel-hardening-return-6879-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <e6c917cb-d4a6-4147-9d6e-9c9fc906621d@digikod.net>
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 2:14 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net> =
wrote:
>
> On 28/02/2017 21:01, Andy Lutomirski wrote:
>> On Tue, Feb 21, 2017 at 5:26 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.n=
et> wrote:
>>> The seccomp(2) syscall can be use to apply a Landlock rule to the
>>> current process. As with a seccomp filter, the Landlock rule is enforce=
d
>>> for all its future children. An inherited rule tree can be updated
>>> (append-only) by the owner of inherited Landlock nodes (e.g. a parent
>>> process that create a new rule)
>>
>> Can you clarify exaclty what this type of update does?  Is it
>> something that should be supported by normal seccomp rules as well?
>
> There is two main structures involved here: struct landlock_node and
> struct landlock_rule, both defined in include/linux/landlock.h [02/10].
>
> Let's take an example with seccomp filter and then Landlock:
> * seccomp filter: Process P1 creates and applies a seccomp filter F1 to
> itself. Then it forks and creates a child P2, which inherits P1's
> filters, hence F1. Now, if P1 add a new seccomp filter F2 to itself, P2
> *won't get it*. The P2's filter list will still only contains F1 but not
> F2. If P2 sets up and applies a new filter F3 to itself, its filter list
> will contains F1 and F3.
> * Landlock: Process P1 creates and applies a Landlock rule R1 to itself.
> Underneath the kernel creates a new node N1 dedicated to P1, which
> contains all its rules. Then P1 forks and creates a child P2, which
> inherits P1's rules, hence R1. Underneath P2 inherited N1. Now, if P1
> add a new Landlock rule R2 to itself, P2 *will get it* as well (because
> R2 is part of N1). If P2 creates and applies a new rule R3 to itself,
> its rules will contains R1, R2 and R3. Underneath the kernel created a
> new node N2 for P2, which only contains R3 but inherits/links to N1.
>
> This design makes it possible for a process to add more constraints to
> its children on the fly. I think it is a good feature to have and a
> safer default inheritance mechanism, but it could be guarded by an
> option flag if we want both mechanism to be available. The same design
> could be used by seccomp filter too.
>

Then let's do it right.

Currently each task has an array of seccomp filter layers.  When a
task forks, the child inherits the layers.  All the layers are
presently immutable.  With Landlock, a layer can logically be a
syscall fitler layer or a Landlock layer.  This fits in to the
existing model just fine.

If we want to have an interface to allow modification of an existing
layer, let's make it so that, when a layer is added, you have to
specify a flag to make the layer modifiable (by current, presumably,
although I can imagine other policies down the road).  Then have a
separate API that modifies a layer.

IOW, I think your patch is bad for three reasons, all fixable:

1. The default is wrong.  A layer should be immutable to avoid an easy
attack in which you try to sandbox *yourself* and then you just modify
the layer to weaken it.

2. The API that adds a layer should be different from the API that
modifies a layer.

3. The whole modification mechanism should be a separate patch to be
reviewed on its own merits.

> The current inheritance mechanism doesn't enable to only add a rule to
> the current process. The rule will be inherited by its children
> (starting from the children created after the first applied rule). An
> option flag NEW_RULE_HIERARCHY (or maybe another seccomp operation)
> could enable to create a new node for the current process, and then
> makes it not inherited by the previous children.

I like my proposal above much better.  "Add a layer" and "change a
layer" should be different operations.

--Andy
