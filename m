From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v2 06/10] landlock: Add LSM hooks
Date: Tue, 30 Aug 2016 13:18:58 -0700
Message-ID: <CALCETrUK1umtXMEXXKzMAccNQCVTPA8_XNDf01B5=gAZuJwvsQ@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-7-git-send-email-mic@digikod.net> <CALCETrXRXxQ26caQW6Vh-NriDeSvnOb=yAu-F=3pvmd0Py+1Pg@mail.gmail.com>
 <57C5E83F.4000102@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
        David Drysdale <drysdale@google.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Alexei Starovoitov <ast@kernel.org>,
        James Morris <james.l.morris@oracle.com>,
        Sargun Dhillon <sargun@sargun.me>,
        Network Development <netdev@vger.kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Linux API <linux-api@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Mack <daniel@zonque.org>, Arnd Bergmann <arnd@arndb.de>,
        Will Drewry <wad@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Elena Reshetova <elena.reshetova@intel.com>,
        Da
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57C5E83F.4000102@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 30, 2016 at 1:10 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
>
> On 30/08/2016 20:56, Andy Lutomirski wrote:
>> On Aug 25, 2016 12:34 PM, "Micka=C3=ABl Sala=C3=BCn" <mic@digikod.net> w=
rote:
>>>
>>> Add LSM hooks which can be used by userland through Landlock (eBPF)
>>> programs. This programs are limited to a whitelist of functions (cf.
>>> next commit). The eBPF program context is depicted by the struct
>>> landlock_data (cf. include/uapi/linux/bpf.h):
>>> * hook: LSM hook ID (useful when using the same program for multiple LS=
M
>>>   hooks);
>>> * cookie: the 16-bit value from the seccomp filter that triggered this
>>>   Landlock program;
>>> * args[6]: array of LSM hook arguments.
>>>
>>> The LSM hook arguments can contain raw values as integers or
>>> (unleakable) pointers. The only way to use the pointers are to pass the=
m
>>> to an eBPF function according to their types (e.g. the
>>> bpf_landlock_cmp_fs_beneath_with_struct_file function can use a struct
>>> file pointer).
>>>
>>> For now, there is three hooks for file system access control:
>>> * file_open;
>>> * file_permission;
>>> * mmap_file.
>>>
>>
>> What's the purpose of exposing struct cred * to userspace?  It's
>> primarily just an optimization to save a bit of RAM, and it's a
>> dubious optimization at that.  What are you using it for?  Would it
>> make more sense to use struct task_struct * or struct pid * instead?
>>
>> Also, exposing struct cred * has a really weird side-effect: it allows
>> (maybe even encourages) checking for pointer equality between two
>> struct cred * objects.  Doing so will have erratic results.
>>
>
> The pointers exposed in the ePBF context are not directly readable by an
> unprivileged eBPF program thanks to the strong typing of the Landlock
> context and the static eBPF verification. There is no way to leak a
> kernel pointer to userspace from an unprivileged eBPF program: pointer
> arithmetic and comparison are prohibited. Pointers can only be pass as
> argument to dedicated eBPF functions.

I'm not talking about leaking the value -- I'm talking about leaking
the predicate (a =3D=3D b) for two struct cred pointers.  That predicate
shouldn't be available because it has very odd effects.

>
> For now, struct cred * is simply not used by any eBPF function and then
> not usable at all. It only exist here because I map the LSM hook
> arguments in a generic/automatic way to the eBPF context.

Maybe remove it from this patch set then?

--Andy
