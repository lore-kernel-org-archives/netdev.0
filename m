From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Sun, 18 Mar 2012 19:35:08 +1100
Message-ID: <9a0230cb8db556cc9cf5d1f6b2439fb5.squirrel@webmail.greenhost.nl>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
    <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
    <1331658828.4449.16.camel@edumazet-glaptop>
    <3e4fc1efb5d7dbe0dd966e3192e84645.squirrel@webmail.greenhost.nl>
    <1331704535.2456.37.camel@edumazet-laptop>
    <3f56b0860272f4ca8925c0a249a30539.squirrel@webmail.greenhost.nl>
    <1331712357.2456.58.camel@edumazet-laptop>
    <7a1c4974e8fbc3b82ead0bfb18224d5b.squirrel@webmail.greenhost.nl>
    <1331992184.2466.45.camel@edumazet-laptop>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "Will Drewry" <wad@chromium.org>,
 linux-kernel@vger.kernel.org,
 linux-arch@vger.kernel.org,
 linux-doc@vger.kernel.org,
 kernel-hardening@lists.openwall.com,
 netdev@vger.kernel.org,
 x86@kernel.org,
 arnd@arndb.de,
 davem@davemloft.net,
 hpa@zytor.com,
 mingo@redhat.com,
 oleg@redhat.com,
 peterz@infradead.org,
 rdunlap@xenotime.net,
 mcgrathr@chromium.org,
 tglx@linutronix.de,
 luto@mit.edu,
 eparis@redhat.com,
 serge.hallyn@canonical.com,
 djm@mindrot.org,
 scarybeasts@gmail.com,
 pmoore@redhat.com,
 akpm@linux-foundation.org,
 corbet@lwn.net,
 markus@chromium.org,
 coreyb@linux.vnet.ibm.com,
 keescook@chromium.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <kernel-hardening-return-1141-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1331992184.2466.45.camel@edumazet-laptop>
List-Id: netdev.vger.kernel.org

On Sun, March 18, 2012 00:49, Eric Dumazet wrote:
> Le samedi 17 mars 2012 à 21:14 +1100, Indan Zupancic a écrit :
>> On Wed, March 14, 2012 19:05, Eric Dumazet wrote:
>> > Le mercredi 14 mars 2012 à 08:59 +0100, Indan Zupancic a écrit :
>> >
>> >> The only remaining question is, is it worth the extra code to release
>> >> up to 32kB of unused memory? It seems a waste to not free it, but if
>> >> people think it's not worth it then let's just leave it around.
>> >
>> > Quite frankly its not an issue, given JIT BPF is not yet default
>> > enabled.
>>
>> And what if assuming JIT BPF would be default enabled?
>>
>
> OK, so here are the reasons why I chose not doing this :
> ---------------------------------------------------------
>
> 1) When I wrote this code, I _wanted_ keeping the original BPF around
> for post morterm analysis. When we are 100% confident code is bug free,
> we might remove the "BPF source code", but I am not convinced.
>
> 2) Most filters are less than 1 Kbytes, and who run thousands of BPF
> network filters on a machine ? Do you have real cases ? Because in these
> cases, the vmalloc() PAGE granularity might be a problem anyway.

That are good reasons.

>
> Some filters are setup for a very short period of time...
> (tcpdump for example setup a "ret 0" at the very beginning of a capture
> ). Doing the extra kmalloc()/copy/kfree() is a loss.

Doing the JITing at all is a loss then. It would be better to only JIT
a filter if it's run at least a certain number of times. This could be
done from a work queue when the filter is run often enough, and only
change bpf_func when the compilation is done, so it doesn't interfere
with incoming packets. Not sure if its worth the trouble.

>> The current JIT doesn't handle negative offsets: The stuff that's handled
>> by __load_pointer(). Easiest solution would be to make it non-static and
>> call it instead of doing bpf_error. I guess __load_pointer was added later
>> and the JIT code didn't get updated.
>
> I dont think so, check git history if you want :)

Hm, apparently not.

>
>>
>> But gcc refuses to inline load_pointer, instead it inlines __load_pointer
>> and does the important checks first. Considering the current assembly code
>> does a call too, it could as well call load_pointer() directly. That would
>> save a lot of assembly code, handle all negative cases too and be pretty
>> much the same speed. The only question is if this slow down some other
>> archs than x86. What do you think?
>
> You miss the point : 99.999 % of offsets are positive in filters.

And in the 00.00001% case that the filter uses a computed negative
offset the BPF JIT fails at runtime. So to not be buggy you need at
least a call to __load_pointer() for the negative case.

>
> Best is to not call load_pointer() and only call skb_copy_bits() if the
> data is not in skb head, but in some fragment.

Of course, but it would be nice if you didn't need to do any call at
all. Once you do, not calling load_pointer() makes less of a difference.

>
> I dont know, I never had to use negative offsets in my own filters.
> So in the BPF JIT I said : If we have a negative offset in a filter,
> just disable JIT code completely for this filter (lines 478-479).

That only works for absolute loads, not indirect ones.

Having negative indirect loads may be unlikely, but they are still
possible.

>
> Same for fancy instructions like BPF_S_ANC_NLATTR /
> BPF_S_ANC_NLATTR_NEST

Such instructions could be handled by a separate function called from
both sk_run_filter and the JIT code. That way you would be able to JIT
all BPF programs.

>
> Show me a real use first.

Those features were added for a reason, if there is no real use they
shouldn't have been added. Supporting them isn't very hard, though
requires some changes in filter.c.

>> You can get rid of all the "if (is_imm8(offsetof(struct sk_buff, len)))"
>> code by making sure everything is near: Somewhere at the start, just
>> add 127 to %rdi and a BUILD_BUG_ON(sizeof(struct sk_buff) > 255).
>>
>
> This code is optimized away by the compiler, you know that ?

Yes. The main difference would be that the JIT could always generate imm8
offsets, saving 4 bytes per long offset while also simplifying the compiler
code. The %rdi + 127 is 4 bytes, and if the rest become slightly faster
because they're imm8 then it's worth the extra instruction.

I first thought the +127 could be done in two bytes, but 4 bytes are
needed, so maybe it's not worth it.

>
> Adding "add 127 to rdi" is one more instruction, adding dependencies and
> making out slow path code more complex (calls to skb_copy_bits() in
> bpf_jit.S ...). Thats a bad idea.

The add 127 would be at the start, the first instruction using it would
be a couple of instructions later, so I don't think the dependency is a
problem.

You're right about skb_copy_bits(), I did a quick search for rdi usage
but missed it was the first parameter too. It would need one extra
sub 127 or add -127 in the slow path, after the push. But it's the slow
path already, one extra instruction won't make much difference.

> I see no change in your patch in the code generation.
>
> if (filter[i].jt == 0), we want to EMIT_COND_JMP(f_op, f_offset);
> because we know at this point that filter[i].jf != 0) [ line 536 ]
>
> if (filter[i].jt != 0), the break; in line 583 prevents the
> EMIT_COND_JMP(f_op, f_offset);

I indeed missed the break, should have double checked.

Greetings,

Indan

A patch implementing the skb + 127 trick below. It has upsides and it has
the downsides you mentioned.

 arch/x86/net/bpf_jit.S      |    1 +
 arch/x86/net/bpf_jit_comp.c |  111 ++++++++++++++-----------------------------
 2 files changed, 37 insertions(+), 75 deletions(-)
diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
index 6687022..fdfacfa 100644
--- a/arch/x86/net/bpf_jit.S
+++ b/arch/x86/net/bpf_jit.S
@@ -98,6 +98,7 @@ bpf_error:
 	push	%rdi;    /* save skb */		\
 	push	%r9;				\
 	push	SKBDATA;			\
+	subq	$127,%rdi;	/* fix skb */	\
 /* rsi already has offset */			\
 	mov	$LEN,%ecx;	/* len */	\
 	lea	-12(%rbp),%rdx;			\
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 7c1b765..d950765 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -56,6 +56,8 @@ static inline u8 *emit_code(u8 *ptr, u32 bytes, unsigned int len)
 #define CLEAR_A() EMIT2(0x31, 0xc0) /* xor %eax,%eax */
 #define CLEAR_X() EMIT2(0x31, 0xdb) /* xor %ebx,%ebx */

+#define SKB_OFF(field)	(offsetof(struct sk_buff, field) - 127)
+
 static inline bool is_imm8(int value)
 {
 	return value <= 127 && value >= -128;
@@ -106,6 +108,8 @@ do {								\
 #define SEEN_DATAREF 1 /* might call external helpers */
 #define SEEN_XREG    2 /* ebx is used */
 #define SEEN_MEM     4 /* use mem[] for temporary storage */
+#define SEEN_SKB     8 /* rdi is used */
+#define SEEN_ALL     (SEEN_DATAREF|SEEN_XREG|SEEN_MEM|SEEN_SKB)

 static inline void bpf_flush_icache(void *start, void *end)
 {
@@ -151,7 +155,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	cleanup_addr = proglen; /* epilogue address */

 	for (pass = 0; pass < 10; pass++) {
-		u8 seen_or_pass0 = (pass == 0) ? (SEEN_XREG | SEEN_DATAREF | SEEN_MEM) : seen;
+		u8 seen_or_pass0 = (pass == 0) ? (SEEN_ALL) : seen;
 		/* no prologue/epilogue for trivial filters (RET something) */
 		proglen = 0;
 		prog = temp;
@@ -159,6 +163,10 @@ void bpf_jit_compile(struct sk_filter *fp)
 		if (seen_or_pass0) {
 			EMIT4(0x55, 0x48, 0x89, 0xe5); /* push %rbp; mov %rsp,%rbp */
 			EMIT4(0x48, 0x83, 0xec, 96);	/* subq  $96,%rsp	*/
+			/* Make sure all offsets are imm8 */
+			BUILD_BUG_ON(sizeof(struct sk_buff) > 255);
+			if (seen_or_pass0 & (SEEN_SKB | SEEN_DATAREF))
+				EMIT4(0x48, 0x83, 0xc7, 127); /* addq $127,%rdi */
 			/* note : must save %rbx in case bpf_error is hit */
 			if (seen_or_pass0 & (SEEN_XREG | SEEN_DATAREF))
 				EMIT4(0x48, 0x89, 0x5d, 0xf8); /* mov %rbx, -8(%rbp) */
@@ -172,30 +180,12 @@ void bpf_jit_compile(struct sk_filter *fp)
 			 *  r8 = skb->data
 			 */
 			if (seen_or_pass0 & SEEN_DATAREF) {
-				if (offsetof(struct sk_buff, len) <= 127)
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
+				EMIT4(0x44, 0x8b, 0x4f, SKB_OFF(len));
+				/* sub    off8(%rdi),%r9d */
+				EMIT4(0x44, 0x2b, 0x4f, SKB_OFF(data_len));
+				/* mov off8(%rdi),%r8 */
+				EMIT4(0x4c, 0x8b, 0x47, SKB_OFF(data));
 			}
 		}

@@ -390,44 +380,27 @@ void bpf_jit_compile(struct sk_filter *fp)
 				EMIT3(0x89, 0x5d, 0xf0 - K*4);
 				break;
 			case BPF_S_LD_W_LEN: /*	A = skb->len; */
+				seen |= SEEN_SKB;
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
-				if (is_imm8(offsetof(struct sk_buff, len)))
-					/* mov    off8(%rdi),%eax */
-					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, len));
-				else {
-					EMIT2(0x8b, 0x87);
-					EMIT(offsetof(struct sk_buff, len), 4);
-				}
+				/* mov    off8(%rdi),%eax */
+				EMIT3(0x8b, 0x47, SKB_OFF(len));
 				break;
 			case BPF_S_LDX_W_LEN: /* X = skb->len; */
-				seen |= SEEN_XREG;
-				if (is_imm8(offsetof(struct sk_buff, len)))
-					/* mov off8(%rdi),%ebx */
-					EMIT3(0x8b, 0x5f, offsetof(struct sk_buff, len));
-				else {
-					EMIT2(0x8b, 0x9f);
-					EMIT(offsetof(struct sk_buff, len), 4);
-				}
+				seen |= SEEN_XREG | SEEN_SKB;
+				/* mov off8(%rdi),%ebx */
+				EMIT3(0x8b, 0x5f, SKB_OFF(len));
 				break;
 			case BPF_S_ANC_PROTOCOL: /* A = ntohs(skb->protocol); */
+				seen |= SEEN_SKB;
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
-				if (is_imm8(offsetof(struct sk_buff, protocol))) {
-					/* movzwl off8(%rdi),%eax */
-					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, protocol));
-				} else {
-					EMIT3(0x0f, 0xb7, 0x87); /* movzwl off32(%rdi),%eax */
-					EMIT(offsetof(struct sk_buff, protocol), 4);
-				}
+				/* movzwl off8(%rdi),%eax */
+				EMIT4(0x0f, 0xb7, 0x47, SKB_OFF(protocol));
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
+				seen |= SEEN_SKB;
+				/* movq off8(%rdi),%rax */
+				EMIT4(0x48, 0x8b, 0x47, SKB_OFF(dev));
 				EMIT3(0x48, 0x85, 0xc0);	/* test %rax,%rax */
 				EMIT_COND_JMP(X86_JE, cleanup_addr - (addrs[i] - 6));
 				BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
@@ -435,34 +408,22 @@ void bpf_jit_compile(struct sk_filter *fp)
 				EMIT(offsetof(struct net_device, ifindex), 4);
 				break;
 			case BPF_S_ANC_MARK:
+				seen |= SEEN_SKB;
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
-				if (is_imm8(offsetof(struct sk_buff, mark))) {
-					/* mov off8(%rdi),%eax */
-					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, mark));
-				} else {
-					EMIT2(0x8b, 0x87);
-					EMIT(offsetof(struct sk_buff, mark), 4);
-				}
+				/* mov off8(%rdi),%eax */
+				EMIT3(0x8b, 0x47, SKB_OFF(mark));
 				break;
 			case BPF_S_ANC_RXHASH:
+				seen |= SEEN_SKB;
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) != 4);
-				if (is_imm8(offsetof(struct sk_buff, rxhash))) {
-					/* mov off8(%rdi),%eax */
-					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, rxhash));
-				} else {
-					EMIT2(0x8b, 0x87);
-					EMIT(offsetof(struct sk_buff, rxhash), 4);
-				}
+				/* mov off8(%rdi),%eax */
+				EMIT3(0x8b, 0x47, SKB_OFF(rxhash));
 				break;
 			case BPF_S_ANC_QUEUE:
+				seen |= SEEN_SKB;
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) != 2);
-				if (is_imm8(offsetof(struct sk_buff, queue_mapping))) {
-					/* movzwl off8(%rdi),%eax */
-					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, queue_mapping));
-				} else {
-					EMIT3(0x0f, 0xb7, 0x87); /* movzwl off32(%rdi),%eax */
-					EMIT(offsetof(struct sk_buff, queue_mapping), 4);
-				}
+				/* movzwl off8(%rdi),%eax */
+				EMIT4(0x0f, 0xb7, 0x47, SKB_OFF(queue_mapping));
 				break;
 			case BPF_S_ANC_CPU:
 #ifdef CONFIG_SMP
