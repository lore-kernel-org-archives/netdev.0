From: "Indan Zupancic" <indan@nul.nu>
Subject: [PATCH] net: bpf_jit: Simplify code by always using offset8 or
 offset32.
Date: Tue, 20 Mar 2012 13:24:56 +1100
Message-ID: <371a1925e68e68f873e30381e0fa60ea.squirrel@webmail.greenhost.nl>
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
    <1332075121.3722.34.camel@edumazet-laptop>
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
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1332075121.3722.34.camel@edumazet-laptop>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, March 18, 2012 23:52, Eric Dumazet wrote:
> Le dimanche 18 mars 2012 =C3=A0 19:35 +1100, Indan Zupancic a =C3=A9c=
rit :
>
>> Yes. The main difference would be that the JIT could always generate=
 imm8
>> offsets, saving 4 bytes per long offset while also simplifying the c=
ompiler
>> code. The %rdi + 127 is 4 bytes, and if the rest become slightly fas=
ter
>> because they're imm8 then it's worth the extra instruction.
>>
>
> Do you understand you try to save 3 bytes in the function prolog, but
> your single EMIT4(0x48, 0x83, 0xc7, 127); /* addq $127,%rdi */
> defeats this ?

That's not what I'm trying to do, I'm trying to simplify the code
so it's easier to verify and less cluttered. I admit the fixup in
bpf_slow_path_common makes it a bad idea over all. But if that one
extra addq would have been all that was needed then it would have
been worth it I think. Even if it makes the prologue one byte longer.

>
> Ancillary instructions are rarely used, libpcap for example doesnt ha=
ve
> support for them.
>
>> I first thought the +127 could be done in two bytes, but 4 bytes are
>> needed, so maybe it's not worth it.
> ...
>> The add 127 would be at the start, the first instruction using it wo=
uld
>> be a couple of instructions later, so I don't think the dependency i=
s a
>> problem.
>>
>> You're right about skb_copy_bits(), I did a quick search for rdi usa=
ge
>> but missed it was the first parameter too. It would need one extra
>> sub 127 or add -127 in the slow path, after the push. But it's the s=
low
>> path already, one extra instruction won't make much difference.
>
> It will, because new NIC drivers tend to provide skbs with fragments.

If it does then perhaps the fast path should be made faster by inlining
the code instead of calling a function which may not be cached.

>
> Using libpcap filter like "udp[100]" calls the skb_copy_bits() helper=
 in
> this case.
>
> There is no difference in instruction timing using offset32 or offset=
8,
> so the code you add will slow the filter anyway.

I assumed optimising for imm8 was worthwile, but if it's the same speed=
,
saving a few bytes here and there while wasting kilobytes of memory
any way doesn't make much sense.

Greetings,

Indan


[PATCH] net: bpf_jit: Simplify code by always using offset8 or offset32=
=2E

Instruction timing of offset32 or offset8 is the same, do not bother sa=
ving
a few bytes of code here and there. Only use offset8 for skb.len, skb.d=
ata_len
and skb.dev: It is very unlikely that those fields are ever moved to th=
e end
of sk_buff. The other fields are used in ancillary instructions, for th=
ose
always use offset32.

Signed-off-by: Indan Zupancic <indan@nul.nu>

 arch/x86/net/bpf_jit_comp.c |  104 +++++++++++++----------------------=
--------
 1 files changed, 31 insertions(+), 73 deletions(-)
---
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7c1b765..5ddb82b 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -102,6 +102,12 @@ do {								\
 		f_op =3D FOP;		\
 		goto cond_branch

+#define SKB_OFF8(field) ({				\
+	int _off =3D offsetof(struct sk_buff, field);	\
+	BUILD_BUG_ON(_off > 127);			\
+	_off;						\
+	})
+

 #define SEEN_DATAREF 1 /* might call external helpers */
 #define SEEN_XREG    2 /* ebx is used */
@@ -172,30 +178,13 @@ void bpf_jit_compile(struct sk_filter *fp)
 			 *  r8 =3D skb->data
 			 */
 			if (seen_or_pass0 & SEEN_DATAREF) {
-				if (offsetof(struct sk_buff, len) <=3D 127)
-					/* mov    off8(%rdi),%r9d */
-					EMIT4(0x44, 0x8b, 0x4f, offsetof(struct sk_buff, len));
-				else {
-					/* mov    off32(%rdi),%r9d */
-					EMIT3(0x44, 0x8b, 0x8f);
-					EMIT(offsetof(struct sk_buff, len), 4);
-				}
-				if (is_imm8(offsetof(struct sk_buff, data_len)))
-					/* sub    off8(%rdi),%r9d */
-					EMIT4(0x44, 0x2b, 0x4f, offsetof(struct sk_buff, data_len));
-				else {
-					EMIT3(0x44, 0x2b, 0x8f);
-					EMIT(offsetof(struct sk_buff, data_len), 4);
-				}
-
-				if (is_imm8(offsetof(struct sk_buff, data)))
-					/* mov off8(%rdi),%r8 */
-					EMIT4(0x4c, 0x8b, 0x47, offsetof(struct sk_buff, data));
-				else {
-					/* mov off32(%rdi),%r8 */
-					EMIT3(0x4c, 0x8b, 0x87);
-					EMIT(offsetof(struct sk_buff, data), 4);
-				}
+				/* mov    off8(%rdi),%r9d */
+				EMIT4(0x44, 0x8b, 0x4f, SKB_OFF8(len));
+				/* sub    off8(%rdi),%r9d */
+				EMIT4(0x44, 0x2b, 0x4f, SKB_OFF8(data_len));
+				/* mov off32(%rdi),%r8 */
+				EMIT3(0x4c, 0x8b, 0x87);
+				EMIT(offsetof(struct sk_buff, data), 4);
 			}
 		}

@@ -391,43 +380,24 @@ void bpf_jit_compile(struct sk_filter *fp)
 				break;
 			case BPF_S_LD_W_LEN: /*	A =3D skb->len; */
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) !=3D 4);
-				if (is_imm8(offsetof(struct sk_buff, len)))
-					/* mov    off8(%rdi),%eax */
-					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, len));
-				else {
-					EMIT2(0x8b, 0x87);
-					EMIT(offsetof(struct sk_buff, len), 4);
-				}
+				/* mov    off8(%rdi),%eax */
+				EMIT3(0x8b, 0x47, SKB_OFF8(len));
 				break;
 			case BPF_S_LDX_W_LEN: /* X =3D skb->len; */
 				seen |=3D SEEN_XREG;
-				if (is_imm8(offsetof(struct sk_buff, len)))
-					/* mov off8(%rdi),%ebx */
-					EMIT3(0x8b, 0x5f, offsetof(struct sk_buff, len));
-				else {
-					EMIT2(0x8b, 0x9f);
-					EMIT(offsetof(struct sk_buff, len), 4);
-				}
+				/* mov off8(%rdi),%ebx */
+				EMIT3(0x8b, 0x5f, SKB_OFF8(len));
 				break;
 			case BPF_S_ANC_PROTOCOL: /* A =3D ntohs(skb->protocol); */
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) !=3D 2);
-				if (is_imm8(offsetof(struct sk_buff, protocol))) {
-					/* movzwl off8(%rdi),%eax */
-					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, protocol));
-				} else {
-					EMIT3(0x0f, 0xb7, 0x87); /* movzwl off32(%rdi),%eax */
-					EMIT(offsetof(struct sk_buff, protocol), 4);
-				}
+				/* movzwl off32(%rdi),%eax */
+				EMIT3(0x0f, 0xb7, 0x87);
+				EMIT(offsetof(struct sk_buff, protocol), 4);
 				EMIT2(0x86, 0xc4); /* ntohs() : xchg   %al,%ah */
 				break;
 			case BPF_S_ANC_IFINDEX:
-				if (is_imm8(offsetof(struct sk_buff, dev))) {
-					/* movq off8(%rdi),%rax */
-					EMIT4(0x48, 0x8b, 0x47, offsetof(struct sk_buff, dev));
-				} else {
-					EMIT3(0x48, 0x8b, 0x87); /* movq off32(%rdi),%rax */
-					EMIT(offsetof(struct sk_buff, dev), 4);
-				}
+				/* movq off8(%rdi),%rax */
+				EMIT4(0x48, 0x8b, 0x47, SKB_OFF8(dev));
 				EMIT3(0x48, 0x85, 0xc0);	/* test %rax,%rax */
 				EMIT_COND_JMP(X86_JE, cleanup_addr - (addrs[i] - 6));
 				BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) !=3D 4);
@@ -436,33 +406,21 @@ void bpf_jit_compile(struct sk_filter *fp)
 				break;
 			case BPF_S_ANC_MARK:
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) !=3D 4);
-				if (is_imm8(offsetof(struct sk_buff, mark))) {
-					/* mov off8(%rdi),%eax */
-					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, mark));
-				} else {
-					EMIT2(0x8b, 0x87);
-					EMIT(offsetof(struct sk_buff, mark), 4);
-				}
+				/* mov off32(%rdi),%eax */
+				EMIT2(0x8b, 0x87);
+				EMIT(offsetof(struct sk_buff, mark), 4);
 				break;
 			case BPF_S_ANC_RXHASH:
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) !=3D 4);
-				if (is_imm8(offsetof(struct sk_buff, rxhash))) {
-					/* mov off8(%rdi),%eax */
-					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, rxhash));
-				} else {
-					EMIT2(0x8b, 0x87);
-					EMIT(offsetof(struct sk_buff, rxhash), 4);
-				}
+				/* mov off32(%rdi),%eax */
+				EMIT2(0x8b, 0x87);
+				EMIT(offsetof(struct sk_buff, rxhash), 4);
 				break;
 			case BPF_S_ANC_QUEUE:
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) !=3D 2);
-				if (is_imm8(offsetof(struct sk_buff, queue_mapping))) {
-					/* movzwl off8(%rdi),%eax */
-					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, queue_mapping));
-				} else {
-					EMIT3(0x0f, 0xb7, 0x87); /* movzwl off32(%rdi),%eax */
-					EMIT(offsetof(struct sk_buff, queue_mapping), 4);
-				}
+				/* movzwl off32(%rdi),%eax */
+				EMIT3(0x0f, 0xb7, 0x87);
+				EMIT(offsetof(struct sk_buff, queue_mapping), 4);
 				break;
 			case BPF_S_ANC_CPU:
 #ifdef CONFIG_SMP
