From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Sat, 17 Mar 2012 21:14:55 +1100
Message-ID: <7a1c4974e8fbc3b82ead0bfb18224d5b.squirrel@webmail.greenhost.nl>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
    <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
    <1331658828.4449.16.camel@edumazet-glaptop>
    <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
    <1331704535.2456.37.camel@edumazet-laptop>
    <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
    <1331712357.2456.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1331712357.2456.58.camel@edumazet-laptop>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, March 14, 2012 19:05, Eric Dumazet wrote:
> Le mercredi 14 mars 2012 =C3=A0 08:59 +0100, Indan Zupancic a =C3=A9c=
rit :
>
>> The only remaining question is, is it worth the extra code to releas=
e
>> up to 32kB of unused memory? It seems a waste to not free it, but if
>> people think it's not worth it then let's just leave it around.
>
> Quite frankly its not an issue, given JIT BPF is not yet default
> enabled.

And what if assuming JIT BPF would be default enabled?

> I am not sure all bugs were found and fixed. I would warn users befor=
e
> considering using it in production.
>
> If you have time, I would appreciate if you could double check and fi=
nd
> last bugs in it.

I'll do my best.

The current JIT doesn't handle negative offsets: The stuff that's handl=
ed
by __load_pointer(). Easiest solution would be to make it non-static an=
d
call it instead of doing bpf_error. I guess __load_pointer was added la=
ter
and the JIT code didn't get updated.

But gcc refuses to inline load_pointer, instead it inlines __load_point=
er
and does the important checks first. Considering the current assembly c=
ode
does a call too, it could as well call load_pointer() directly. That wo=
uld
save a lot of assembly code, handle all negative cases too and be prett=
y
much the same speed. The only question is if this slow down some other
archs than x86. What do you think?

The EMIT_COND_JMP(f_op, f_offset); should be in an else case, otherwise
it's superfluous. It's a harmless bug though. I haven't spotted anythin=
g
else yet.

You can get rid of all the "if (is_imm8(offsetof(struct sk_buff, len)))=
"
code by making sure everything is near: Somewhere at the start, just
add 127 to %rdi and a BUILD_BUG_ON(sizeof(struct sk_buff) > 255).

I'll write some more patches tomorrow.

Greetings,

Indan

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7c1b765..7e0f575 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -581,8 +581,9 @@ cond_branch:			f_offset =3D addrs[i + filter[i].jf]=
 - addrs[i];
 					if (filter[i].jf)
 						EMIT_JMP(f_offset);
 					break;
+				} else {
+					EMIT_COND_JMP(f_op, f_offset);
 				}
-				EMIT_COND_JMP(f_op, f_offset);
 				break;
 			default:
 				/* hmm, too complex filter, give up with jit compiler */



