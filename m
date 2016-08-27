From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Sat, 27 Aug 2016 16:06:38 +0200
Message-ID: <57C19E6E.6040908@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="AVxQRIMeh71XXdwGkEpqNMl03tow7b3d9"
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann
 <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        "David S . Miller" <davem@davemloft.net>,
        Kees Cook <keescook@chromium.org>, Sargun Dhillon <sargun@sargun.me>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-4483-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160826230539.GA26683@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--AVxQRIMeh71XXdwGkEpqNMl03tow7b3d9
Content-Type: multipart/mixed; boundary="T4O3NOIS7AeCL7l8sqMUmudTjxd5i4cGv"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann
 <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 "David S . Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>,
 Sargun Dhillon <sargun@sargun.me>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
Message-ID: <57C19E6E.6040908@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
In-Reply-To: <20160826230539.GA26683@ast-mbp.thefacebook.com>

--T4O3NOIS7AeCL7l8sqMUmudTjxd5i4cGv
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 27/08/2016 01:05, Alexei Starovoitov wrote:
> On Fri, Aug 26, 2016 at 05:10:40PM +0200, Micka=EBl Sala=FCn wrote:
>>
>>>
>>> - I don't think such 'for' loop can scale. The solution needs to work=

>>> with thousands of containers and thousands of cgroups.
>>> In the patch 06/10 the proposal is to use 'current' as holder of
>>> the programs:
>>> +   for (prog =3D current->seccomp.landlock_prog;
>>> +                   prog; prog =3D prog->prev) {
>>> +           if (prog->filter =3D=3D landlock_ret->filter) {
>>> +                   cur_ret =3D BPF_PROG_RUN(prog->prog, (void *)&ctx=
);
>>> +                   break;
>>> +           }
>>> +   }
>>> imo that's the root of scalability issue.
>>> I think to be able to scale the bpf programs have to be attached to
>>> cgroups instead of tasks.
>>> That would be very different api. seccomp doesn't need to be touched.=

>>> But that is the only way I see to be able to scale.
>>
>> Landlock is inspired from seccomp which also use a BPF program per
>> thread. For seccomp, each BPF programs are executed for each syscall.
>> For Landlock, some BPF programs are executed for some LSM hooks. I don=
't
>> see why it is a scale issue for Landlock comparing to seccomp. I also
>> don't see why storing the BPF program list pointer in the cgroup struc=
t
>> instead of the task struct change a lot here. The BPF programs executi=
on
>> will be the same anyway (for each LSM hook). Kees should probably have=
 a
>> better opinion on this.
>=20
> seccomp has its own issues and copying them doesn't make this lsm any b=
etter.
> Like seccomp bpf programs are all gigantic switch statement that looks
> for interesting syscall numbers. All syscalls of a task are paying
> non-trivial seccomp penalty due to such design. If bpf was attached per=

> syscall it would have been much cheaper. Of course doing it this way
> for seccomp is not easy, but for lsm such facility is already there.
> Blank call of a single bpf prog for all lsm hooks is unnecessary
> overhead that can and should be avoided.

It's probably a misunderstanding. Contrary to seccomp which run all the
thread's BPF programs for any syscall, Landlock only run eBPF programs
for the triggered LSM hooks, if their type match. Indeed, thanks to the
multiple eBPF program types and contrary to seccomp, Landlock only run
an eBPF program when needed. Landlock will have almost no performance
overhead if the syscalls do not trigger the watched LSM hooks for the
current process.


>=20
>>> May be another way of thinking about it is 'lsm cgroup controller'
>>> that Sargun is proposing.
>>> The lsm hooks will provide stable execution points and the programs
>>> will be called like:
>>> prog =3D task_css_set(current)->dfl_cgrp->bpf.prog_effective[lsm_hook=
_id];
>>> BPF_PROG_RUN(prog, ctx);
>>> The delegation functionality and 'prog_effective' logic that
>>> Daniel Mack is proposing will be fully reused here.
>>> External container management software will be able to apply bpf
>>> programs to control tasks under cgroup and such
>>> bpf_landlock_cmp_cgroup_beneath() helper won't be necessary.
>>> The user will be able to register different programs for different ls=
m hooks.
>>> If I understand the patch 6/10 correctly, there is one (or a list) pr=
og for
>>> all lsm hooks per task which is not flexible enough.
>>
>> For each LSM hook triggered by a thread, all of its Landlock eBPF
>> programs (dedicated for this kind of hook) will be evaluated (if
>> needed). This is the same behavior as seccomp (list of BPF programs
>> attached to a process hierarchy) except the BPF programs are not
>> evaluated for syscall but for LSM hooks. There is no way to make it mo=
re
>> fine-grained :)
>=20
> There is a way to attach different bpf program per cgroup
> and per lsm hook. Such approach drastically reduces overhead
> of sandboxed application.

As said above, Landlock will not run an eBPF programs when not strictly
needed. Attaching to a cgroup will have the same performance impact as
attaching to a process hierarchy.


--T4O3NOIS7AeCL7l8sqMUmudTjxd5i4cGv--

--AVxQRIMeh71XXdwGkEpqNMl03tow7b3d9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXwZ5vAAoJECLe/t9zvWqVLTIH/37D/wWb+itj90028SDPlWzL
3eCNbSt1oDKIQjO6AxNTqe5+ZoIrILkxT7c22v+Ov5hdlx7AoorjXWTBrdUvZ4bX
QnaH7Nyit40DoiG30Ay6Y02vN6mLpHp3eQ6zHk60ys8oRsaS9YFv4YbuvMZeUHhX
Wlz4vREk2zAij4vjaagVjmRZK8dfYxJ2IlrRDqhpTE04a2AlkIbuon6PhxLh6BnR
Jev/Bx9wWKU6AOo+uzOvxu8keOh+BlQadKt7/nFIiytsJGivY4/2Q0gkTm+2l9jy
IKXM0uGy4gSE5VW3203QTw2Ad3AqPqVm07BLweUyhQMtA6jBf1HgRGlu4sYB6jU=
=5+Ct
-----END PGP SIGNATURE-----

--AVxQRIMeh71XXdwGkEpqNMl03tow7b3d9--
