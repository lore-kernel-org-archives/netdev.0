From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/5] bpf: add prog tag test case to bpf selftests
Date: Tue, 24 Jan 2017 01:06:29 +0100
Message-ID: <8723f7d203c7d1eb17098c4d31795af9fc3c7b15.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44957 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdAXAGp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:06:45 -0500
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the test case used to compare the results from fdinfo with
af_alg's output on the tag. Tests are from min to max sized
programs, with and without maps included.

  # ./test_tag
  test_tag: OK (40945 tests)

Tested on x86_64 and s390x.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/Makefile   |   4 +-
 tools/testing/selftests/bpf/test_tag.c | 202 +++++++++++++++++++++++++++++++++
 2 files changed, 204 insertions(+), 2 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_tag.c

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 064a3e5..769a6cb 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,8 +1,8 @@
 CFLAGS += -Wall -O2 -I../../../../usr/include
 
-test_objs = test_verifier test_maps test_lru_map test_lpm_map
+test_objs = test_verifier test_tag test_maps test_lru_map test_lpm_map
 
-TEST_PROGS := test_verifier test_maps test_lru_map test_lpm_map test_kmod.sh
+TEST_PROGS := $(test_objs) test_kmod.sh
 TEST_FILES := $(test_objs)
 
 all: $(test_objs)
diff --git a/tools/testing/selftests/bpf/test_tag.c b/tools/testing/selftests/bpf/test_tag.c
new file mode 100644
index 0000000..6ab4793
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_tag.c
@@ -0,0 +1,202 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <ctype.h>
+#include <time.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+#include <sched.h>
+#include <limits.h>
+#include <assert.h>
+
+#include <sys/socket.h>
+#include <sys/resource.h>
+
+#include <linux/filter.h>
+#include <linux/bpf.h>
+#include <linux/if_alg.h>
+
+#include "../../../include/linux/filter.h"
+
+#include "bpf_sys.h"
+
+static struct bpf_insn prog[BPF_MAXINSNS];
+
+static void bpf_gen_imm_prog(unsigned int insns, int fd_map)
+{
+	int i;
+
+	srand(time(NULL));
+	for (i = 0; i < insns; i++)
+		prog[i] = BPF_ALU64_IMM(BPF_MOV, i % BPF_REG_10, rand());
+	prog[i - 1] = BPF_EXIT_INSN();
+}
+
+static void bpf_gen_map_prog(unsigned int insns, int fd_map)
+{
+	int i, j = 0;
+
+	for (i = 0; i + 1 < insns; i += 2) {
+		struct bpf_insn tmp[] = {
+			BPF_LD_MAP_FD(j++ % BPF_REG_10, fd_map)
+		};
+
+		memcpy(&prog[i], tmp, sizeof(tmp));
+	}
+	if (insns % 2 == 0)
+		prog[insns - 2] = BPF_ALU64_IMM(BPF_MOV, i % BPF_REG_10, 42);
+	prog[insns - 1] = BPF_EXIT_INSN();
+}
+
+static int bpf_try_load_prog(int insns, int fd_map,
+			     void (*bpf_filler)(unsigned int insns,
+						int fd_map))
+{
+	int fd_prog;
+
+	bpf_filler(insns, fd_map);
+	fd_prog = bpf_prog_load(BPF_PROG_TYPE_SCHED_CLS, prog, insns *
+				sizeof(struct bpf_insn), "", NULL, 0);
+	assert(fd_prog > 0);
+	if (fd_map > 0)
+		bpf_filler(insns, 0);
+	return fd_prog;
+}
+
+static int __hex2bin(char ch)
+{
+	if ((ch >= '0') && (ch <= '9'))
+		return ch - '0';
+	ch = tolower(ch);
+	if ((ch >= 'a') && (ch <= 'f'))
+		return ch - 'a' + 10;
+	return -1;
+}
+
+static int hex2bin(uint8_t *dst, const char *src, size_t count)
+{
+	while (count--) {
+		int hi = __hex2bin(*src++);
+		int lo = __hex2bin(*src++);
+
+		if ((hi < 0) || (lo < 0))
+			return -1;
+		*dst++ = (hi << 4) | lo;
+	}
+	return 0;
+}
+
+static void tag_from_fdinfo(int fd_prog, uint8_t *tag, uint32_t len)
+{
+	const int prefix_len = sizeof("prog_tag:\t") - 1;
+	char buff[256];
+	int ret = -1;
+	FILE *fp;
+
+	snprintf(buff, sizeof(buff), "/proc/%d/fdinfo/%d", getpid(),
+		 fd_prog);
+	fp = fopen(buff, "r");
+	assert(fp);
+
+	while (fgets(buff, sizeof(buff), fp)) {
+		if (strncmp(buff, "prog_tag:\t", len))
+			continue;
+		ret = hex2bin(tag, buff + prefix_len, len);
+		break;
+	}
+
+	fclose(fp);
+	assert(!ret);
+}
+
+static void tag_from_alg(int insns, uint8_t *tag, uint32_t len)
+{
+	static const struct sockaddr_alg alg = {
+		.salg_family	= AF_ALG,
+		.salg_type	= "hash",
+		.salg_name	= "sha1",
+	};
+	int fd_base, fd_alg, ret;
+	ssize_t size;
+
+	fd_base = socket(AF_ALG, SOCK_SEQPACKET, 0);
+	assert(fd_base > 0);
+
+	ret = bind(fd_base, (struct sockaddr *)&alg, sizeof(alg));
+	assert(!ret);
+
+	fd_alg = accept(fd_base, NULL, 0);
+	assert(fd_alg > 0);
+
+	insns *= sizeof(struct bpf_insn);
+	size = write(fd_alg, prog, insns);
+	assert(size == insns);
+
+	size = read(fd_alg, tag, len);
+	assert(size == len);
+
+	close(fd_alg);
+	close(fd_base);
+}
+
+static void tag_dump(const char *prefix, uint8_t *tag, uint32_t len)
+{
+	int i;
+
+	printf("%s", prefix);
+	for (i = 0; i < len; i++)
+		printf("%02x", tag[i]);
+	printf("\n");
+}
+
+static void tag_exit_report(int insns, int fd_map, uint8_t *ftag,
+			    uint8_t *atag, uint32_t len)
+{
+	printf("Program tag mismatch for %d insns%s!\n", insns,
+	       fd_map < 0 ? "" : " with map");
+
+	tag_dump("  fdinfo result: ", ftag, len);
+	tag_dump("  af_alg result: ", atag, len);
+	exit(1);
+}
+
+static void do_test(uint32_t *tests, int start_insns, int fd_map,
+		    void (*bpf_filler)(unsigned int insns, int fd))
+{
+	int i, fd_prog;
+
+	for (i = start_insns; i <= BPF_MAXINSNS; i++) {
+		uint8_t ftag[8], atag[sizeof(ftag)];
+
+		fd_prog = bpf_try_load_prog(i, fd_map, bpf_filler);
+		tag_from_fdinfo(fd_prog, ftag, sizeof(ftag));
+		tag_from_alg(i, atag, sizeof(atag));
+		if (memcmp(ftag, atag, sizeof(ftag)))
+			tag_exit_report(i, fd_map, ftag, atag, sizeof(ftag));
+
+		close(fd_prog);
+		sched_yield();
+		(*tests)++;
+	}
+}
+
+int main(void)
+{
+	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
+	uint32_t tests = 0;
+	int i, fd_map;
+
+	setrlimit(RLIMIT_MEMLOCK, &rinf);
+	fd_map = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(int),
+				sizeof(int), 1, BPF_F_NO_PREALLOC);
+	assert(fd_map > 0);
+
+	for (i = 0; i < 5; i++) {
+		do_test(&tests, 2, -1,     bpf_gen_imm_prog);
+		do_test(&tests, 3, fd_map, bpf_gen_map_prog);
+	}
+
+	printf("test_tag: OK (%u tests)\n", tests);
+	close(fd_map);
+	return 0;
+}
-- 
1.9.3
