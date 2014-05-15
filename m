From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 1/2] tools: bpf_jit_disasm: ignore image address for disasm
Date: Thu, 15 May 2014 15:56:38 -0700
Message-ID: <1400194599-5247-2-git-send-email-ast@plumgrid.com>
References: <1400194599-5247-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:46011 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754293AbaEOW4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 18:56:52 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so1667099pad.30
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 15:56:52 -0700 (PDT)
In-Reply-To: <1400194599-5247-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

seccomp filters use kernel JIT image addresses, so bpf_jit_enable=2 prints
[ 20.146438] flen=3 proglen=82 pass=0 image=0000000000000000
[ 20.146442] JIT code: 00000000: 55 48 89 e5 48 81 ec 28 02 00 00 ...

ignore image address, so that seccomp filters can be disassembled

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 tools/net/bpf_jit_disasm.c |   18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
index cfe0cdcda3de..d9730c3319b9 100644
--- a/tools/net/bpf_jit_disasm.c
+++ b/tools/net/bpf_jit_disasm.c
@@ -43,8 +43,7 @@ static void get_exec_path(char *tpath, size_t size)
 	free(path);
 }
 
-static void get_asm_insns(uint8_t *image, size_t len, unsigned long base,
-			  int opcodes)
+static void get_asm_insns(uint8_t *image, size_t len, int opcodes)
 {
 	int count, i, pc = 0;
 	char tpath[256];
@@ -107,13 +106,13 @@ static void put_klog_buff(char *buff)
 }
 
 static int get_last_jit_image(char *haystack, size_t hlen,
-			      uint8_t *image, size_t ilen,
-			      unsigned long *base)
+			      uint8_t *image, size_t ilen)
 {
 	char *ptr, *pptr, *tmp;
 	off_t off = 0;
 	int ret, flen, proglen, pass, ulen = 0;
 	regmatch_t pmatch[1];
+	unsigned long base;
 	regex_t regex;
 
 	if (hlen == 0)
@@ -136,7 +135,7 @@ static int get_last_jit_image(char *haystack, size_t hlen,
 
 	ptr = haystack + off - (pmatch[0].rm_eo - pmatch[0].rm_so);
 	ret = sscanf(ptr, "flen=%d proglen=%d pass=%d image=%lx",
-		     &flen, &proglen, &pass, base);
+		     &flen, &proglen, &pass, &base);
 	if (ret != 4)
 		return 0;
 
@@ -162,7 +161,7 @@ static int get_last_jit_image(char *haystack, size_t hlen,
 	assert(ulen == proglen);
 	printf("%d bytes emitted from JIT compiler (pass:%d, flen:%d)\n",
 	       proglen, pass, flen);
-	printf("%lx + <x>:\n", *base);
+	printf("%lx + <x>:\n", base);
 
 	regfree(&regex);
 	return ulen;
@@ -172,7 +171,6 @@ int main(int argc, char **argv)
 {
 	int len, klen, opcodes = 0;
 	char *kbuff;
-	unsigned long base;
 	uint8_t image[4096];
 
 	if (argc > 1) {
@@ -189,9 +187,9 @@ int main(int argc, char **argv)
 
 	kbuff = get_klog_buff(&klen);
 
-	len = get_last_jit_image(kbuff, klen, image, sizeof(image), &base);
-	if (len > 0 && base > 0)
-		get_asm_insns(image, len, base, opcodes);
+	len = get_last_jit_image(kbuff, klen, image, sizeof(image));
+	if (len > 0)
+		get_asm_insns(image, len, opcodes);
 
 	put_klog_buff(kbuff);
 
-- 
1.7.9.5
