From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: bpf_jit: fix BPF_S_LDX_B_MSH compilation
Date: Sun, 18 Mar 2012 05:40:48 -0700
Message-ID: <1332074448.3722.25.camel@edumazet-laptop>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	 <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
	 <1331658828.4449.16.camel@edumazet-glaptop>
	 <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
	 <1331704535.2456.37.camel@edumazet-laptop>
	 <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
	 <1331712357.2456.58.camel@edumazet-laptop>
	 <7a1c4974e8fbc3b82ead0bfb18224d5b.squirrel@webmail.greenhost.nl>
	 <1331992184.2466.45.camel@edumazet-laptop>
	 <9a0230cb8db556cc9cf5d1f6b2439fb5.squirrel@webmail.greenhost.nl>
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
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	Matt Evans <matt@ozlabs.org>
To: Indan Zupancic <indan@nul.nu>, David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <9a0230cb8db556cc9cf5d1f6b2439fb5.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 18 mars 2012 =C3=A0 19:35 +1100, Indan Zupancic a =C3=A9cri=
t :

> And in the 00.00001% case that the filter uses a computed negative
> offset the BPF JIT fails at runtime. So to not be buggy you need at
> least a call to __load_pointer() for the negative case.

Please show me how and why a real (I mean useful one...) filter could
generate a dynamic negative value, and I'll change the code.

Negative values are there to allow access to network/mac header
components. I cant see how a BPF code could have a valid use of dynamic
indexes in these headers.

Right now we consider such code is evil and filter does "return 0"
saying so.

If I remember well, a more practical issue was mentioned by Matt Evans
and I forgot about it.

Its even _documented_ in his code.

Thanks

[PATCH] net: bpf_jit: fix BPF_S_LDX_B_MSH compilation

Matt Evans spotted that x86 bpf_jit was incorrectly handling negative
constant offsets in BPF_S_LDX_B_MSH instruction.

We need to abort JIT compilation like we do in common_load so that
filter uses the interpreter code and can call __load_pointer()

Reference: http://lists.openwall.net/netdev/2011/07/19/11

Thanks to Indan Zupancic to bring back this issue.

Reported-by: Matt Evans <matt@ozlabs.org>
Reported-by: Indan Zupancic <indan@nul.nu>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
David, libpcap doesnt generate such pattern, so feel to add this patch
to net-next. Thanks !

 arch/x86/net/bpf_jit_comp.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7c1b765..5671752 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -475,8 +475,10 @@ void bpf_jit_compile(struct sk_filter *fp)
 			case BPF_S_LD_W_ABS:
 				func =3D sk_load_word;
 common_load:			seen |=3D SEEN_DATAREF;
-				if ((int)K < 0)
+				if ((int)K < 0) {
+					/* Abort the JIT because __load_pointer() is needed. */
 					goto out;
+				}
 				t_offset =3D func - (image + addrs[i]);
 				EMIT1_off32(0xbe, K); /* mov imm32,%esi */
 				EMIT1_off32(0xe8, t_offset); /* call */
@@ -489,14 +491,8 @@ common_load:			seen |=3D SEEN_DATAREF;
 				goto common_load;
 			case BPF_S_LDX_B_MSH:
 				if ((int)K < 0) {
-					if (pc_ret0 > 0) {
-						/* addrs[pc_ret0 - 1] is the start address */
-						EMIT_JMP(addrs[pc_ret0 - 1] - addrs[i]);
-						break;
-					}
-					CLEAR_A();
-					EMIT_JMP(cleanup_addr - addrs[i]);
-					break;
+					/* Abort the JIT because __load_pointer() is needed. */
+					goto out;
 				}
 				seen |=3D SEEN_DATAREF | SEEN_XREG;
 				t_offset =3D sk_load_byte_msh - (image + addrs[i]);


