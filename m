From: David Daney <david.daney@cavium.com>
Subject: [PATCH] tools: bpf_jit_disasm: Add option to dump JIT image to a file.
Date: Tue, 11 Apr 2017 14:30:52 -0700
Message-ID: <20170411213052.7337-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0072.outbound.protection.outlook.com ([104.47.36.72]:9152
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753522AbdDKVbA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 17:31:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When debugging the JIT on an embedded platform or cross build
environment, libbfd may not be available, making it impossible to run
bpf_jit_disasm natively.

Add an option to emit a binary image of the JIT code to a file.  This
file can then be disassembled off line.  Typical usage in this case
might be (pasting mips64 dmesg output to cat command):

   $ cat > jit.raw
   $ bpf_jit_disasm -f jit.raw -O jit.bin
   $ mips64-linux-gnu-objdump -D -b binary -m mips:isa64r2 -EB jit.bin

Signed-off-by: David Daney <david.daney@cavium.com>
---
 tools/net/bpf_jit_disasm.c | 40 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 36 insertions(+), 4 deletions(-)

diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
index 544b05a..ad572e6 100644
--- a/tools/net/bpf_jit_disasm.c
+++ b/tools/net/bpf_jit_disasm.c
@@ -229,6 +229,7 @@ static void usage(void)
 {
 	printf("Usage: bpf_jit_disasm [...]\n");
 	printf("       -o          Also display related opcodes (default: off).\n");
+	printf("       -O <file>   Write binary image of code to file, don't disassemble to stdout.\n");
 	printf("       -f <file>   Read last image dump from file or stdin (default: klog).\n");
 	printf("       -h          Display this help.\n");
 }
@@ -238,12 +239,19 @@ int main(int argc, char **argv)
 	unsigned int len, klen, opt, opcodes = 0;
 	static uint8_t image[32768];
 	char *kbuff, *file = NULL;
+	char *ofile = NULL;
+	int ofd;
+	ssize_t nr;
+	uint8_t *pos;
 
-	while ((opt = getopt(argc, argv, "of:")) != -1) {
+	while ((opt = getopt(argc, argv, "of:O:")) != -1) {
 		switch (opt) {
 		case 'o':
 			opcodes = 1;
 			break;
+		case 'O':
+			ofile = optarg;
+			break;
 		case 'f':
 			file = optarg;
 			break;
@@ -263,11 +271,35 @@ int main(int argc, char **argv)
 	}
 
 	len = get_last_jit_image(kbuff, klen, image, sizeof(image));
-	if (len > 0)
-		get_asm_insns(image, len, opcodes);
-	else
+	if (len <= 0) {
 		fprintf(stderr, "No JIT image found!\n");
+		goto done;
+	}
+	if (!ofile) {
+		get_asm_insns(image, len, opcodes);
+		goto done;
+	}
+
+	ofd = open(ofile, O_WRONLY | O_CREAT | O_TRUNC, DEFFILEMODE);
+	if (ofd < 0) {
+		fprintf(stderr, "Could not open file %s for writing: ", ofile);
+		perror(NULL);
+		goto done;
+	}
+	pos = image;
+	do {
+		nr = write(ofd, pos, len);
+		if (nr < 0) {
+			fprintf(stderr, "Could not write data to %s: ", ofile);
+			perror(NULL);
+			goto done;
+		}
+		len -= nr;
+		pos += nr;
+	} while (len);
+	close(ofd);
 
+done:
 	put_log_buff(kbuff);
 	return 0;
 }
-- 
2.9.3
