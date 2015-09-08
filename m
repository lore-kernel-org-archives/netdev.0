From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] bpf: fix out of bounds access in verifier log
Date: Tue,  8 Sep 2015 13:40:01 -0700
Message-ID: <1441744801-15537-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Yonghong Song <yhs@plumgrid.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35197 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbbIHUkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 16:40:07 -0400
Received: by pacfv12 with SMTP id fv12so136688388pac.2
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 13:40:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when the verifier log is enabled the print_bpf_insn() is doing
bpf_alu_string[BPF_OP(insn->code) >> 4]
and
bpf_jmp_string[BPF_OP(insn->code) >> 4]
where BPF_OP is a 4-bit instruction opcode.
Malformed insns can cause out of bounds access.
Fix it by sizing arrays appropriately.

The bug was found by clang address sanitizer with libfuzzer.

Reported-by: Yonghong Song <yhs@plumgrid.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
fyi sanitizer error looks like:
...
 27 invalid dst register in STX OK
 28 invalid dst register in ST OK
 29 invalid src register in LDX OK
 30 invalid dst register in LDX OK
 31 junk insn OK
 32 junk insn2 OK
=================================================================
==52730==ERROR: AddressSanitizer: global-buffer-overflow on address 0x000000500c58
READ of size 8 at 0x000000500c58 thread T0
    #0 0x4e480b in print_bpf_insn verifier.c:332:5
    #1 0x4e1bcb in do_check verifier.c:1657:4
...
0x000000500c58 is located 8 bytes to the right of global variable 'bpf_alu_string'
defined in 'verifier.c:286:26' (0x500be0) of size 112
---
 kernel/bpf/verifier.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index ed12e385fb75..b074b23000d6 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -283,7 +283,7 @@ static const char *const bpf_class_string[] = {
 	[BPF_ALU64] = "alu64",
 };
 
-static const char *const bpf_alu_string[] = {
+static const char *const bpf_alu_string[16] = {
 	[BPF_ADD >> 4]  = "+=",
 	[BPF_SUB >> 4]  = "-=",
 	[BPF_MUL >> 4]  = "*=",
@@ -307,7 +307,7 @@ static const char *const bpf_ldst_string[] = {
 	[BPF_DW >> 3] = "u64",
 };
 
-static const char *const bpf_jmp_string[] = {
+static const char *const bpf_jmp_string[16] = {
 	[BPF_JA >> 4]   = "jmp",
 	[BPF_JEQ >> 4]  = "==",
 	[BPF_JGT >> 4]  = ">",
-- 
1.7.9.5
