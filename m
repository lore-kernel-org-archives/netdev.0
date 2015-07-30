From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf_jit_disasm: also support reading jit dump from file
Date: Thu, 30 Jul 2015 16:04:22 +0200
Message-ID: <63f20d2290807aa457cb18da45eb8fc7ff751132.1438264568.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42680 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbbG3OE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 10:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to read the dmesg BPF JIT dump also from a
file instead of the klog buffer. I found this quite useful when going
through some 'before/after patch' logs. It also fixes a regex leak
found by valgrind when no image dump was found.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/net/bpf_jit_disasm.c | 109 +++++++++++++++++++++++++++++++++++++--------
 1 file changed, 90 insertions(+), 19 deletions(-)

diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
index 618c2bc..2cd3d4c 100644
--- a/tools/net/bpf_jit_disasm.c
+++ b/tools/net/bpf_jit_disasm.c
@@ -22,9 +22,14 @@
 #include <string.h>
 #include <bfd.h>
 #include <dis-asm.h>
+#include <regex.h>
+#include <fcntl.h>
 #include <sys/klog.h>
 #include <sys/types.h>
-#include <regex.h>
+#include <sys/stat.h>
+
+#define CMD_ACTION_SIZE_BUFFER		10
+#define CMD_ACTION_READ_ALL		3
 
 static void get_exec_path(char *tpath, size_t size)
 {
@@ -87,20 +92,66 @@ static void get_asm_insns(uint8_t *image, size_t len, int opcodes)
 	bfd_close(bfdf);
 }
 
-static char *get_klog_buff(int *klen)
+static char *get_klog_buff(unsigned int *klen)
 {
-	int ret, len = klogctl(10, NULL, 0);
-	char *buff = malloc(len);
+	int ret, len;
+	char *buff;
+
+	len = klogctl(CMD_ACTION_SIZE_BUFFER, NULL, 0);
+	buff = malloc(len);
+	if (!buff)
+		return NULL;
+
+	ret = klogctl(CMD_ACTION_READ_ALL, buff, len);
+	if (ret < 0) {
+		free(buff);
+		return NULL;
+	}
 
-	assert(buff && klen);
-	ret = klogctl(3, buff, len);
-	assert(ret >= 0);
 	*klen = ret;
+	return buff;
+}
 
+static char *get_flog_buff(const char *file, unsigned int *klen)
+{
+	int fd, ret, len;
+	struct stat fi;
+	char *buff;
+
+	fd = open(file, O_RDONLY);
+	if (fd < 0)
+		return NULL;
+
+	ret = fstat(fd, &fi);
+	if (ret < 0 || !S_ISREG(fi.st_mode))
+		goto out;
+
+	len = fi.st_size + 1;
+	buff = malloc(len);
+	if (!buff)
+		goto out;
+
+	memset(buff, 0, len);
+	ret = read(fd, buff, len - 1);
+	if (ret <= 0)
+		goto out_free;
+
+	close(fd);
+	*klen = ret;
 	return buff;
+out_free:
+	free(buff);
+out:
+	close(fd);
+	return NULL;
+}
+
+static char *get_log_buff(const char *file, unsigned int *klen)
+{
+	return file ? get_flog_buff(file, klen) : get_klog_buff(klen);
 }
 
-static void put_klog_buff(char *buff)
+static void put_log_buff(char *buff)
 {
 	free(buff);
 }
@@ -138,8 +189,10 @@ static int get_last_jit_image(char *haystack, size_t hlen,
 	ptr = haystack + off - (pmatch[0].rm_eo - pmatch[0].rm_so);
 	ret = sscanf(ptr, "flen=%d proglen=%d pass=%d image=%lx",
 		     &flen, &proglen, &pass, &base);
-	if (ret != 4)
+	if (ret != 4) {
+		regfree(&regex);
 		return 0;
+	}
 
 	tmp = ptr = haystack + off;
 	while ((ptr = strtok(tmp, "\n")) != NULL && ulen < ilen) {
@@ -169,31 +222,49 @@ static int get_last_jit_image(char *haystack, size_t hlen,
 	return ulen;
 }
 
+static void usage(void)
+{
+	printf("Usage: bpf_jit_disasm [...]\n");
+	printf("       -o          Also display related opcodes (default: off).\n");
+	printf("       -f <file>   Read last image dump from file or stdin (default: klog).\n");
+	printf("       -h          Display this help.\n");
+}
+
 int main(int argc, char **argv)
 {
-	int len, klen, opcodes = 0;
-	char *kbuff;
+	unsigned int len, klen, opt, opcodes = 0;
 	static uint8_t image[32768];
+	char *kbuff, *file = NULL;
 
-	if (argc > 1) {
-		if (!strncmp("-o", argv[argc - 1], 2)) {
+	while ((opt = getopt(argc, argv, "of:")) != -1) {
+		switch (opt) {
+		case 'o':
 			opcodes = 1;
-		} else {
-			printf("usage: bpf_jit_disasm [-o: show opcodes]\n");
-			exit(0);
+			break;
+		case 'f':
+			file = optarg;
+			break;
+		default:
+			usage();
+			return -1;
 		}
 	}
 
 	bfd_init();
 	memset(image, 0, sizeof(image));
 
-	kbuff = get_klog_buff(&klen);
+	kbuff = get_log_buff(file, &klen);
+	if (!kbuff) {
+		fprintf(stderr, "Could not retrieve log buffer!\n");
+		return -1;
+	}
 
 	len = get_last_jit_image(kbuff, klen, image, sizeof(image));
 	if (len > 0)
 		get_asm_insns(image, len, opcodes);
+	else
+		fprintf(stderr, "No JIT image found!\n");
 
-	put_klog_buff(kbuff);
-
+	put_log_buff(kbuff);
 	return 0;
 }
-- 
1.9.3
