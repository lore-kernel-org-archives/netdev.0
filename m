From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Sat, 27 Aug 2016 23:14:39 +0200
Message-ID: <57C202BF.7000207@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net>
 <20160827180642.GA38754@ast-mbp.thefacebook.com>
 <57C1EB72.2050703@digikod.net>
 <20160827204307.GA43714@ast-mbp.thefacebook.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="V7TMmF11NTpDPG5VxpMnw4uPoRnRfS53v"
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
Return-path: <kernel-hardening-return-4496-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160827204307.GA43714@ast-mbp.thefacebook.com>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--V7TMmF11NTpDPG5VxpMnw4uPoRnRfS53v
Content-Type: multipart/mixed; boundary="dv4UxEeKWJ08QunjdccXKD1xeBSmPVldI"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann
 <daniel@iogearbox.net>, Daniel Mack <daniel@zonque.org>,
 "David S . Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>,
 Sargun Dhillon <sargun@sargun.me>, kernel-hardening@lists.openwall.com,
 linux-api@vger.kernel.org, linux-security-module@vger.kernel.org,
 netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
Message-ID: <57C202BF.7000207@digikod.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net>
 <20160827180642.GA38754@ast-mbp.thefacebook.com>
 <57C1EB72.2050703@digikod.net>
 <20160827204307.GA43714@ast-mbp.thefacebook.com>
In-Reply-To: <20160827204307.GA43714@ast-mbp.thefacebook.com>

--dv4UxEeKWJ08QunjdccXKD1xeBSmPVldI
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 27/08/2016 22:43, Alexei Starovoitov wrote:
> On Sat, Aug 27, 2016 at 09:35:14PM +0200, Micka=EBl Sala=FCn wrote:
>> On 27/08/2016 20:06, Alexei Starovoitov wrote:
>>> On Sat, Aug 27, 2016 at 04:06:38PM +0200, Micka=EBl Sala=FCn wrote:
>>>> As said above, Landlock will not run an eBPF programs when not stric=
tly
>>>> needed. Attaching to a cgroup will have the same performance impact =
as
>>>> attaching to a process hierarchy.
>>>
>>> Having a prog per cgroup per lsm_hook is the only scalable way I
>>> could come up with. If you see another way, please propose.
>>> current->seccomp.landlock_prog is not the answer.
>>
>> Hum, I don't see the difference from a performance point of view betwe=
en
>> a cgroup-based or a process hierarchy-based system.
>>
>> Maybe a better option should be to use an array of pointers with N
>> entries, one for each supported hook, instead of a unique pointer list=
?
>=20
> yes, clearly array dereference is faster than link list walk.
> Now the question is where to keep this prog_array[num_lsm_hooks] ?
> Since we cannot keep it inside task_struct, we have to allocate it.
> Every time the task is creted then. What to do on the fork? That
> will require changes all over. Then the obvious optimization would be
> to share this allocated array of prog pointers across multiple tasks...=

> and little by little this new facility will look like cgroup.
> Hence the suggestion to put this array into cgroup from the start.

I see your point :)

>=20
>> Anyway, being able to attach an LSM hook program to a cgroup thanks to=

>> the new BPF_PROG_ATTACH seems a good idea (while keeping the possibili=
ty
>> to use a process hierarchy). The downside will be to handle an LSM hoo=
k
>> program which is not triggered by a seccomp-filter, but this should be=

>> needed anyway to handle interruptions.
>=20
> what do you mean 'not triggered by seccomp' ?
> You're not suggesting that this lsm has to enable seccomp to be functio=
nal?
> imo that's non starter due to overhead.

Yes, for now, it is triggered by a new seccomp filter return value
RET_LANDLOCK, which can take a 16-bit value called cookie. This must not
be needed but could be useful to bind a seccomp filter security policy
with a Landlock one. Waiting for Kees's point of view=85


--dv4UxEeKWJ08QunjdccXKD1xeBSmPVldI--

--V7TMmF11NTpDPG5VxpMnw4uPoRnRfS53v
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXwgK/AAoJECLe/t9zvWqVDpoIAKAMk65weL3PS13K3b1whxv1
noZAY5oC/t+ytsDoo6hAeGIsnYG06B6vcbBP0pufjqqPzg3y77cfAFdc62fUMdE/
iRmP6aRSIFRYIR6n/OlAZcoYx3jBFVQlBcSH0IH+dUJDtSgL4i3fUj5WHuPpBqWR
EqlEh63XQXe3Fiavj04y/w/rJlyn9fthIN6bMtNd5MgogZ3OVsMde0gLjPypd9qd
zlaw6VfzdinoD5OzrGp971pHtlByVmYqrH2MjIh3ZWkq0o9zL+FI5Wmva7codKhp
PjwOkjqVdFRZKIgsjg9qjaZnjcEsGHH1r7Myyqg/c2I/s38Nn2ALQY3n6/CKzD0=
=8gjJ
-----END PGP SIGNATURE-----

--V7TMmF11NTpDPG5VxpMnw4uPoRnRfS53v--
