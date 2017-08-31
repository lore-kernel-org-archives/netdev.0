From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] x86: bpf_jit: small optimization in
 emit_bpf_tail_call()
Date: Thu, 31 Aug 2017 04:53:42 -0700
Message-ID: <1504180422.15310.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33168 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750893AbdHaLxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 07:53:45 -0400
Received: by mail-io0-f194.google.com with SMTP id f99so1167861ioi.0
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 04:53:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Saves 4 bytes replacing following instructions :

lea rax, [rsi + rdx * 8 + offsetof(...)] 
mov rax, qword ptr [rax]
cmp rax, 0

by :

mov rax, [rsi + rdx * 8 + offsetof(...)] 
test rax, rax

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/x86/net/bpf_jit_comp.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 8194696e2805852a8246bf1db2a5862d5758f76b..7af5ee584bf8546f3c1b92df9d9f513416f2089d 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -287,7 +287,7 @@ static void emit_bpf_tail_call(u8 **pprog)
 	EMIT4(0x48, 0x8B, 0x46,                   /* mov rax, qword ptr [rsi + 16] */
 	      offsetof(struct bpf_array, map.max_entries));
 	EMIT3(0x48, 0x39, 0xD0);                  /* cmp rax, rdx */
-#define OFFSET1 47 /* number of bytes to jump */
+#define OFFSET1 43 /* number of bytes to jump */
 	EMIT2(X86_JBE, OFFSET1);                  /* jbe out */
 	label1 = cnt;
 
@@ -296,21 +296,20 @@ static void emit_bpf_tail_call(u8 **pprog)
 	 */
 	EMIT2_off32(0x8B, 0x85, 36);              /* mov eax, dword ptr [rbp + 36] */
 	EMIT3(0x83, 0xF8, MAX_TAIL_CALL_CNT);     /* cmp eax, MAX_TAIL_CALL_CNT */
-#define OFFSET2 36
+#define OFFSET2 32
 	EMIT2(X86_JA, OFFSET2);                   /* ja out */
 	label2 = cnt;
 	EMIT3(0x83, 0xC0, 0x01);                  /* add eax, 1 */
 	EMIT2_off32(0x89, 0x85, 36);              /* mov dword ptr [rbp + 36], eax */
 
 	/* prog = array->ptrs[index]; */
-	EMIT4_off32(0x48, 0x8D, 0x84, 0xD6,       /* lea rax, [rsi + rdx * 8 + offsetof(...)] */
+	EMIT4_off32(0x48, 0x8B, 0x84, 0xD6,       /* mov rax, [rsi + rdx * 8 + offsetof(...)] */
 		    offsetof(struct bpf_array, ptrs));
-	EMIT3(0x48, 0x8B, 0x00);                  /* mov rax, qword ptr [rax] */
 
 	/* if (prog == NULL)
 	 *   goto out;
 	 */
-	EMIT4(0x48, 0x83, 0xF8, 0x00);            /* cmp rax, 0 */
+	EMIT3(0x48, 0x85, 0xC0);		  /* test rax,rax */
 #define OFFSET3 10
 	EMIT2(X86_JE, OFFSET3);                   /* je out */
 	label3 = cnt;
