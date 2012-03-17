From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Sat, 17 Mar 2012 06:49:44 -0700
Message-ID: <1331992184.2466.45.camel@edumazet-laptop>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	 <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
	 <1331658828.4449.16.camel@edumazet-glaptop>
	 <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
	 <1331704535.2456.37.camel@edumazet-laptop>
	 <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
	 <1331712357.2456.58.camel@edumazet-laptop>
	 <7a1c4974e8fbc3b82ead0bfb18224d5b.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <7a1c4974e8fbc3b82ead0bfb18224d5b.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 17 mars 2012 =C3=A0 21:14 +1100, Indan Zupancic a =C3=A9crit =
:
> On Wed, March 14, 2012 19:05, Eric Dumazet wrote:
> > Le mercredi 14 mars 2012 =C3=A0 08:59 +0100, Indan Zupancic a =C3=A9=
crit :
> >
> >> The only remaining question is, is it worth the extra code to rele=
ase
> >> up to 32kB of unused memory? It seems a waste to not free it, but =
if
> >> people think it's not worth it then let's just leave it around.
> >
> > Quite frankly its not an issue, given JIT BPF is not yet default
> > enabled.
>=20
> And what if assuming JIT BPF would be default enabled?
>=20

OK, so here are the reasons why I chose not doing this :
---------------------------------------------------------

1) When I wrote this code, I _wanted_ keeping the original BPF around
for post morterm analysis. When we are 100% confident code is bug free,
we might remove the "BPF source code", but I am not convinced.

2) Most filters are less than 1 Kbytes, and who run thousands of BPF
network filters on a machine ? Do you have real cases ? Because in thes=
e
cases, the vmalloc() PAGE granularity might be a problem anyway.


Some filters are setup for a very short period of time...
(tcpdump for example setup a "ret 0" at the very beginning of a capture
). Doing the extra kmalloc()/copy/kfree() is a loss.

tcpdump -n -s 0 -c 1000 arp

[29211.083449] JIT code: ffffffffa0cbe000: 31 c0 c3
[29211.083481] flen=3D4 proglen=3D55 pass=3D3 image=3Dffffffffa0cc0000
[29211.083487] JIT code: ffffffffa0cc0000: 55 48 89 e5 48 83 ec 60 48 8=
9 5d f8 44 8b 4f 68
[29211.083494] JIT code: ffffffffa0cc0010: 44 2b 4f 6c 4c 8b 87 e0 00 0=
0 00 be 0c 00 00 00
[29211.083500] JIT code: ffffffffa0cc0020: e8 04 32 38 e0 3d 06 08 00 0=
0 75 07 b8 ff ff 00
[29211.083506] JIT code: ffffffffa0cc0030: 00 eb 02 31 c0 c9 c3



> The current JIT doesn't handle negative offsets: The stuff that's han=
dled
> by __load_pointer(). Easiest solution would be to make it non-static =
and
> call it instead of doing bpf_error. I guess __load_pointer was added =
later
> and the JIT code didn't get updated.

I dont think so, check git history if you want :)

>=20
> But gcc refuses to inline load_pointer, instead it inlines __load_poi=
nter
> and does the important checks first. Considering the current assembly=
 code
> does a call too, it could as well call load_pointer() directly. That =
would
> save a lot of assembly code, handle all negative cases too and be pre=
tty
> much the same speed. The only question is if this slow down some othe=
r
> archs than x86. What do you think?

You miss the point : 99.999 % of offsets are positive in filters.

Best is to not call load_pointer() and only call skb_copy_bits() if the
data is not in skb head, but in some fragment.

I dont know, I never had to use negative offsets in my own filters.
So in the BPF JIT I said : If we have a negative offset in a filter,
just disable JIT code completely for this filter (lines 478-479).

Same for fancy instructions like BPF_S_ANC_NLATTR /
BPF_S_ANC_NLATTR_NEST

Show me a real use first.

I am pragmatic : I spend time coding stuff if there is a real need.

>=20
> The EMIT_COND_JMP(f_op, f_offset); should be in an else case, otherwi=
se
> it's superfluous. It's a harmless bug though. I haven't spotted anyth=
ing
> else yet.

Its not superflous, see my comment at the end of this mail.

>=20
> You can get rid of all the "if (is_imm8(offsetof(struct sk_buff, len)=
))"
> code by making sure everything is near: Somewhere at the start, just
> add 127 to %rdi and a BUILD_BUG_ON(sizeof(struct sk_buff) > 255).
>=20

This code is optimized away by the compiler, you know that ?

Adding "add 127 to rdi" is one more instruction, adding dependencies an=
d
making out slow path code more complex (calls to skb_copy_bits() in
bpf_jit.S ...). Thats a bad idea.


> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.=
c
> index 7c1b765..7e0f575 100644
> --- a/arch/x86/net/bpf_jit_comp.c
> +++ b/arch/x86/net/bpf_jit_comp.c
> @@ -581,8 +581,9 @@ cond_branch:			f_offset =3D addrs[i + filter[i].j=
f] - addrs[i];
>  					if (filter[i].jf)
>  						EMIT_JMP(f_offset);
>  					break;
> +				} else {
> +					EMIT_COND_JMP(f_op, f_offset);
>  				}
> -				EMIT_COND_JMP(f_op, f_offset);
>  				break;
>  			default:
>  				/* hmm, too complex filter, give up with jit compiler */
>=20
>=20
>=20

I see no change in your patch in the code generation.

if (filter[i].jt =3D=3D 0), we want to EMIT_COND_JMP(f_op, f_offset);
because we know at this point that filter[i].jf !=3D 0) [ line 536 ]

if (filter[i].jt !=3D 0), the break; in line 583 prevents the
EMIT_COND_JMP(f_op, f_offset);

Thanks !


