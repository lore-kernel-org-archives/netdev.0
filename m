From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Sat, 17 Dec 2016 20:26:41 +0100
Message-ID: <58559171.30402@digikod.net>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="CaSGuRi1BuaNNvueU4bPQaRnLaciiJiWK"
Cc: Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        John Stultz <john.stultz@linaro.org>
To: Andy Lutomirski <luto@kernel.org>, Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--CaSGuRi1BuaNNvueU4bPQaRnLaciiJiWK
Content-Type: multipart/mixed; boundary="9Ijoh97X66VOTc89JuFx5kW0wSirtCnO7";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Andy Lutomirski <luto@kernel.org>, Daniel Mack <daniel@zonque.org>,
 Alexei Starovoitov <alexei.starovoitov@gmail.com>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
 Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
 "David S. Miller" <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
 Michael Kerrisk <mtk.manpages@gmail.com>,
 Peter Zijlstra <peterz@infradead.org>
Cc: Linux API <linux-api@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Network Development <netdev@vger.kernel.org>,
 John Stultz <john.stultz@linaro.org>
Message-ID: <58559171.30402@digikod.net>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
In-Reply-To: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>

--9Ijoh97X66VOTc89JuFx5kW0wSirtCnO7
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 17/12/2016 19:18, Andy Lutomirski wrote:
> Hi all-
>=20
> I apologize for being rather late with this.  I didn't realize that
> cgroup-bpf was going to be submitted for Linux 4.10, and I didn't see
> it on the linux-api list, so I missed the discussion.
>=20
> I think that the inet ingress, egress etc filters are a neat feature,
> but I think the API has some issues that will bite us down the road
> if it becomes stable in its current form.
>=20
> Most of the problems I see are summarized in this transcript:
>=20
> # mkdir cg2
> # mount -t cgroup2 none cg2
> # mkdir cg2/nosockets
> # strace cgrp_socket_rule cg2/nosockets/ 0
> ...
> open("cg2/nosockets/", O_RDONLY|O_DIRECTORY) =3D 3
>=20
> ^^^^ You can modify a cgroup after opening it O_RDONLY?

I sent a patch to check the cgroup.procs permission before attaching a
BPF program to it [1], but it was not merged because not part of the
current security model (which may not be crystal clear). The thing is
that the current socket/BPF/cgroup feature is only available to a
process with the *global CAP_NET_ADMIN* and such a process can already
modify the network for every processes, so it doesn't make much sense to
check if it can modify the network for a subset of this processes.

[1] https://lkml.org/lkml/2016/9/19/854

However, needing a process to open a cgroup *directory* in write mode
may not make sense because the process does not modify the content of
the cgroup but only use it as a *reference* in the network stack.
Forcing an open with write mode may forbid to use this kind of
network-filtering feature in a read-only file-system but not necessarily
read-only *network configuration*.

Another point of view is that the CAP_NET_ADMIN may be an unneeded
privilege if the cgroup migration is using a no_new_privs-like feature
as I proposed with Landlock [2] (with an extra ptrace_may_access() check)=
=2E
The new capability proposition for cgroup may be interesting too.

[2] https://lkml.org/lkml/2016/9/14/82

>=20
> bpf(BPF_PROG_LOAD, {prog_type=3D0x9 /* BPF_PROG_TYPE_??? */, insn_cnt=3D=
2,
> insns=3D0x7fffe3568c10, license=3D"GPL", log_level=3D1, log_size=3D2621=
44,
> log_buf=3D0x6020c0, kern_version=3D0}, 48) =3D 4
>=20
> ^^^^ This is fine.  The bpf() syscall manipulates bpf objects.
>=20
> bpf(0x8 /* BPF_??? */, 0x7fffe3568bf0, 48) =3D 0
>=20
> ^^^^ This is not so good:
> ^^^^
> ^^^^ a) The bpf() syscall is supposed to manipulate bpf objects.  This
> ^^^^    is manipulating a cgroup.  There's no reason that a socket crea=
tion
> ^^^^    filter couldn't be written in a different language (new iptable=
s
> ^^^^    table?  Simple list of address families?), but if that happened=
,
> ^^^^    then using bpf() to install it would be entirely nonsensical.

Another point of view is to say that the BPF program (called by the
network stack) is using a reference to a set of processes thanks to a
cgroup.

> ^^^^
> ^^^^ b) This is starting to be an excessively ugly multiplexer.  Among
> ^^^^    other things, it's very unfriendly to seccomp.

FWIW, Landlock will have the capability to filter this kind of action.

>=20
> # echo $$ >cg2/nosockets/cgroup.procs
> # ping 127.0.0.1
> ping: socket: Operation not permitted
> # ls cg2/nosockets/
> cgroup.controllers  cgroup.events  cgroup.procs  cgroup.subtree_control=

> # cat cg2/nosockets/cgroup.controllers
>=20
> ^^^^ Something in cgroupfs should give an indication that this cgroup
> ^^^^ filters socket creation, but there's nothing there.  You should al=
so
> ^^^^ be able to turn the filter off from cgroupfs.

Right. Everybody was OK at LPC to add such an information but it is not
there yet.

>=20
> # mkdir cg2/nosockets/sockets
> # /home/luto/apps/linux/samples/bpf/cgrp_socket_rule cg2/nosockets/sock=
ets/ 1
>=20
> ^^^^ This succeeded, which means that, if this feature is enabled in 4.=
10,
> ^^^^ then we're stuck with its semantics.  If it returned -EINVAL inste=
ad,
> ^^^^ there would be a chance to refine it.

This is indeed unfortunate.

>=20
> # echo $$ >cg2/nosockets/sockets/cgroup.procs
> # ping 127.0.0.1
> PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
> 64 bytes from 127.0.0.1: icmp_seq=3D1 ttl=3D64 time=3D0.029 ms
> ^C
> --- 127.0.0.1 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev =3D 0.029/0.029/0.029/0.000 ms
>=20
> ^^^^ Bash was inside a cgroup that disallowed socket creation, but sock=
et
> ^^^^ creation wasn't disallowed.  This means that the obvious use of so=
cket
> ^^^^ creation filters in nestable constainers fails insecurely.
>=20
>=20
> There's also a subtle but nasty potential security problem here.
> In 4.9 and before, cgroups has only one real effect in the kernel:
> resource control. A process in a malicious cgroup could be DoSed,
> but that was about the extent of the damage that a malicious cgroup
> could do.
>=20
> In 4.10 with With CONFIG_CGROUP_BPF=3Dy, a cgroup can have bpf
> programs attached that can do things if various events occur. (Right
> now, this means socket operations, but there are plans in the works
> to do this for LSM hooks too.) These bpf programs can say yes or no,
> but they can also read out various data (including socket payloads!)
> and save them away where an attacker can find them. This sounds a
> lot like seccomp with a narrower scope but a much stronger ability to
> exfiltrate private information.
>=20
> Unfortunately, while seccomp is very, very careful to prevent
> injection of a privileged victim into a malicious sandbox, the
> CGROUP_BPF mechanism appears to have no real security model. There
> is nothing to prevent a program that's in a malicious cgroup from
> running a setuid binary, and there is nothing to prevent a program
> that has the ability to move itself or another program into a
> malicious cgroup from doing so and then, if needed for exploitation,
> exec a setuid binary.
>=20
> This isn't much of a problem yet because you currently need
> CAP_NET_ADMIN to create a malicious sandbox in the first place.  I'm
> sure that, in the near future, someone will want to make this stuff
> work in containers with delegated cgroup hierarchies, and then there
> may be a real problem here.
>=20
>=20
> I've included a few security people on this thread.  The current API
> looks abusable, and it would be nice to find all the holes before
> 4.10 comes out.
>=20
>=20
> (The cgrp_socket_rule source is attached.  You can build it by sticking=
 it
>  in samples/bpf and doing:
>=20
>  $ make headers_install
>  $ cd samples/bpf
>  $ gcc -o cgrp_socket_rule cgrp_socket_rule.c libbpf.c -I../../usr/incl=
ude
> )
>=20
> --Andy
>=20

Right. Because this feature doesn't handle namespaces (only global
CAP_NET_ADMIN), nested containers should not be allowed to use it at all.=

If we want this kind of feature to be usable by something other than a
process with a global capability, then we need an inheritance mechanism
similar to what I designed for Landlock. I think it could be added later.=


Regards,
 Micka=EBl


--9Ijoh97X66VOTc89JuFx5kW0wSirtCnO7--

--CaSGuRi1BuaNNvueU4bPQaRnLaciiJiWK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlhVkXwACgkQIt7+33O9
apXBRQgAl6MFJlYErsM2A/4xzZQ69fgtiJPIcdIrGe1Ojhvk7PjD62UAamto3CSQ
vBPwLJC3OmvQazj9c1WHRpuOazEQkt4gPO1Izg5r8PIAxQuKAM3EnEV0IpEfCcB+
FK2Po9tltJyt/epo4tnMKZX/+bW3Fc2Av2fShWXBr4rWUt2b0xW3uPU0Fy8Jji1D
fa7SB8iitiaVj+nk1FYPSfW6QgCvDsf9b6gyYzQYtMkOVuizEjJ7d1fPNEjp+XP6
Ufc/5V7EGT1CL6mMoQrujIE1LLrmCWmWwkmvYSoy9TjEnZrEOfcAN9A7QQRjzTsp
hG6KLfePijhDXgoQYovrJpQKMR0dlA==
=7a95
-----END PGP SIGNATURE-----

--CaSGuRi1BuaNNvueU4bPQaRnLaciiJiWK--
