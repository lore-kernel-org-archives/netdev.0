From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] x86 bpf_jit: support MOD operation
Date: Mon, 10 Sep 2012 22:48:33 +0200
Message-ID: <1347310113.13103.8.camel@edumazet-glaptop>
References: <20120907074910.2df46817@arrowsmith>
	 <20120908030311.GM17289@tassilo.jf.intel.com>
	 <1347091415.1234.317.camel@edumazet-glaptop>
	 <20120910.154537.639794042526369471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ak@linux.intel.com, gbakos@alpinista.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63565 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152Ab2IJUsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 16:48:39 -0400
Received: by eekc1 with SMTP id c1so1503729eek.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 13:48:37 -0700 (PDT)
In-Reply-To: <20120910.154537.639794042526369471.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit b6069a9570 (filter: add MOD operation) added generic
support for modulus operation in BPF.

This patch brings JIT support for x86_64

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Andi Kleen <ak@linux.intel.com>
Cc: George Bakos <gbakos@alpinista.org>
---
 arch/x86/net/bpf_jit_comp.c |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 33643a8..106c578 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -280,6 +280,31 @@ void bpf_jit_compile(struct sk_filter *fp)
 				}
 				EMIT4(0x31, 0xd2, 0xf7, 0xf3); /* xor %edx,%edx; div %ebx */
 				break;
+			case BPF_S_ALU_MOD_X: /* A %= X; */
+				seen |= SEEN_XREG;
+				EMIT2(0x85, 0xdb);	/* test %ebx,%ebx */
+				if (pc_ret0 > 0) {
+					/* addrs[pc_ret0 - 1] is start address of target
+					 * (addrs[i] - 6) is the address following this jmp
+					 * ("xor %edx,%edx; div %ebx;mov %edx,%eax" being 6 bytes long)
+					 */
+					EMIT_COND_JMP(X86_JE, addrs[pc_ret0 - 1] -
+								(addrs[i] - 6));
+				} else {
+					EMIT_COND_JMP(X86_JNE, 2 + 5);
+					CLEAR_A();
+					EMIT1_off32(0xe9, cleanup_addr - (addrs[i] - 6)); /* jmp .+off32 */
+				}
+				EMIT2(0x31, 0xd2);	/* xor %edx,%edx */
+				EMIT2(0xf7, 0xf3);	/* div %ebx */
+				EMIT2(0x89, 0xd0);	/* mov %edx,%eax */
+				break;
+			case BPF_S_ALU_MOD_K: /* A %= K; */
+				EMIT2(0x31, 0xd2);	/* xor %edx,%edx */
+				EMIT1(0xb9);EMIT(K, 4);	/* mov imm32,%ecx */
+				EMIT2(0xf7, 0xf1);	/* div %ecx */
+				EMIT2(0x89, 0xd0);	/* mov %edx,%eax */
+				break;
 			case BPF_S_ALU_DIV_K: /* A = reciprocal_divide(A, K); */
 				EMIT3(0x48, 0x69, 0xc0); /* imul imm32,%rax,%rax */
 				EMIT(K, 4);
