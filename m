From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] filter: add minimal BPF JIT image disassembler
Date: Wed, 20 Mar 2013 23:11:47 +0100
Message-ID: <1363817507-7499-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23109 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586Ab3CTWLu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 18:11:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a minimal stand-alone user space helper, that allows for debugging or
verification of emitted BPF JIT images. This is in particular useful for
emitted opcode debugging, since minor bugs in the JIT compiler can be fatal.
The disassembler is architecture generic and uses libopcodes and libbfd.

How to get to the disassembly, example:

  1) `echo 2 > /proc/sys/net/core/bpf_jit_enable`
  2) Load a BPF filter (e.g. `tcpdump -p -n -s 0 -i eth1 host 192.168.20.0/24`)
  3) Run e.g. `bpf_jit_disasm -o` to disassemble the most recent JIT code output

`bpf_jit_disasm -o` will display the related opcodes to a particular instruction
as well. Example for x86_64:

$ ./bpf_jit_disasm
94 bytes emitted from JIT compiler (pass:3, flen:9)
ffffffffa0356000 + <x>:
   0:	push   %rbp
   1:	mov    %rsp,%rbp
   4:	sub    $0x60,%rsp
   8:	mov    %rbx,-0x8(%rbp)
   c:	mov    0x68(%rdi),%r9d
  10:	sub    0x6c(%rdi),%r9d
  14:	mov    0xe0(%rdi),%r8
  1b:	mov    $0xc,%esi
  20:	callq  0xffffffffe0d01b71
  25:	cmp    $0x86dd,%eax
  2a:	jne    0x000000000000003d
  2c:	mov    $0x14,%esi
  31:	callq  0xffffffffe0d01b8d
  36:	cmp    $0x6,%eax
[...]
  5c:	leaveq
  5d:	retq

$ ./bpf_jit_disasm -o
94 bytes emitted from JIT compiler (pass:3, flen:9)
ffffffffa0356000 + <x>:
   0:	push   %rbp
	55
   1:	mov    %rsp,%rbp
	48 89 e5
   4:	sub    $0x60,%rsp
	48 83 ec 60
   8:	mov    %rbx,-0x8(%rbp)
	48 89 5d f8
   c:	mov    0x68(%rdi),%r9d
	44 8b 4f 68
  10:	sub    0x6c(%rdi),%r9d
	44 2b 4f 6c
[...]
  5c:	leaveq
	c9
  5d:	retq
	c3

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 I have added a 'net' target for current and future misc tools. I decided not
 to add an extra man-page, since it's just a very small helper, with an option
 -o, that is accessible through -h, nothing more. Let me know if that's okay
 for you, thanks.

 v1 -> v2: change location of file from scripts/ to tools/net/
 v2 -> v3: add a Makefile and 'net' target under tools

 tools/Makefile             |  11 +--
 tools/net/Makefile         |  15 ++++
 tools/net/bpf_jit_disasm.c | 199 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 220 insertions(+), 5 deletions(-)
 create mode 100644 tools/net/Makefile
 create mode 100644 tools/net/bpf_jit_disasm.c

diff --git a/tools/Makefile b/tools/Makefile
index fa36565..c73c635 100644
--- a/tools/Makefile
+++ b/tools/Makefile
@@ -12,6 +12,7 @@ help:
 	@echo '  turbostat  - Intel CPU idle stats and freq reporting tool'
 	@echo '  usb        - USB testing tools'
 	@echo '  virtio     - vhost test module'
+	@echo '  net        - misc networking tools'
 	@echo '  vm         - misc vm tools'
 	@echo '  x86_energy_perf_policy - Intel energy policy tool'
 	@echo ''
@@ -34,7 +35,7 @@ help:
 cpupower: FORCE
 	$(call descend,power/$@)
 
-cgroup firewire lguest perf usb virtio vm: FORCE
+cgroup firewire lguest perf usb virtio vm net: FORCE
 	$(call descend,$@)
 
 selftests: FORCE
@@ -46,7 +47,7 @@ turbostat x86_energy_perf_policy: FORCE
 cpupower_install:
 	$(call descend,power/$(@:_install=),install)
 
-cgroup_install firewire_install lguest_install perf_install usb_install virtio_install vm_install:
+cgroup_install firewire_install lguest_install perf_install usb_install virtio_install vm_install net_install:
 	$(call descend,$(@:_install=),install)
 
 selftests_install:
@@ -57,12 +58,12 @@ turbostat_install x86_energy_perf_policy_install:
 
 install: cgroup_install cpupower_install firewire_install lguest_install \
 		perf_install selftests_install turbostat_install usb_install \
-		virtio_install vm_install x86_energy_perf_policy_install
+		virtio_install vm_install net_install x86_energy_perf_policy_install
 
 cpupower_clean:
 	$(call descend,power/cpupower,clean)
 
-cgroup_clean firewire_clean lguest_clean perf_clean usb_clean virtio_clean vm_clean:
+cgroup_clean firewire_clean lguest_clean perf_clean usb_clean virtio_clean vm_clean net_clean:
 	$(call descend,$(@:_clean=),clean)
 
 selftests_clean:
@@ -73,6 +74,6 @@ turbostat_clean x86_energy_perf_policy_clean:
 
 clean: cgroup_clean cpupower_clean firewire_clean lguest_clean perf_clean \
 		selftests_clean turbostat_clean usb_clean virtio_clean \
-		vm_clean x86_energy_perf_policy_clean
+		vm_clean net_clean x86_energy_perf_policy_clean
 
 .PHONY: FORCE
diff --git a/tools/net/Makefile b/tools/net/Makefile
new file mode 100644
index 0000000..b4444d5
--- /dev/null
+++ b/tools/net/Makefile
@@ -0,0 +1,15 @@
+prefix = /usr
+
+CC = gcc
+
+all : bpf_jit_disasm
+
+bpf_jit_disasm : CFLAGS = -Wall -O2
+bpf_jit_disasm : LDLIBS = -lopcodes -lbfd -ldl
+bpf_jit_disasm : bpf_jit_disasm.o
+
+clean :
+	rm -rf *.o bpf_jit_disasm
+
+install :
+	install bpf_jit_disasm $(prefix)/bin/bpf_jit_disasm
diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
new file mode 100644
index 0000000..cfe0cdc
--- /dev/null
+++ b/tools/net/bpf_jit_disasm.c
@@ -0,0 +1,199 @@
+/*
+ * Minimal BPF JIT image disassembler
+ *
+ * Disassembles BPF JIT compiler emitted opcodes back to asm insn's for
+ * debugging or verification purposes.
+ *
+ * To get the disassembly of the JIT code, do the following:
+ *
+ *  1) `echo 2 > /proc/sys/net/core/bpf_jit_enable`
+ *  2) Load a BPF filter (e.g. `tcpdump -p -n -s 0 -i eth1 host 192.168.20.0/24`)
+ *  3) Run e.g. `bpf_jit_disasm -o` to read out the last JIT code
+ *
+ * Copyright 2013 Daniel Borkmann <borkmann@redhat.com>
+ * Licensed under the GNU General Public License, version 2.0 (GPLv2)
+ */
+
+#include <stdint.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <assert.h>
+#include <unistd.h>
+#include <string.h>
+#include <bfd.h>
+#include <dis-asm.h>
+#include <sys/klog.h>
+#include <sys/types.h>
+#include <regex.h>
+
+static void get_exec_path(char *tpath, size_t size)
+{
+	char *path;
+	ssize_t len;
+
+	snprintf(tpath, size, "/proc/%d/exe", (int) getpid());
+	tpath[size - 1] = 0;
+
+	path = strdup(tpath);
+	assert(path);
+
+	len = readlink(path, tpath, size);
+	tpath[len] = 0;
+
+	free(path);
+}
+
+static void get_asm_insns(uint8_t *image, size_t len, unsigned long base,
+			  int opcodes)
+{
+	int count, i, pc = 0;
+	char tpath[256];
+	struct disassemble_info info;
+	disassembler_ftype disassemble;
+	bfd *bfdf;
+
+	memset(tpath, 0, sizeof(tpath));
+	get_exec_path(tpath, sizeof(tpath));
+
+	bfdf = bfd_openr(tpath, NULL);
+	assert(bfdf);
+	assert(bfd_check_format(bfdf, bfd_object));
+
+	init_disassemble_info(&info, stdout, (fprintf_ftype) fprintf);
+	info.arch = bfd_get_arch(bfdf);
+	info.mach = bfd_get_mach(bfdf);
+	info.buffer = image;
+	info.buffer_length = len;
+
+	disassemble_init_for_target(&info);
+
+	disassemble = disassembler(bfdf);
+	assert(disassemble);
+
+	do {
+		printf("%4x:\t", pc);
+
+		count = disassemble(pc, &info);
+
+		if (opcodes) {
+			printf("\n\t");
+			for (i = 0; i < count; ++i)
+				printf("%02x ", (uint8_t) image[pc + i]);
+		}
+		printf("\n");
+
+		pc += count;
+	} while(count > 0 && pc < len);
+
+	bfd_close(bfdf);
+}
+
+static char *get_klog_buff(int *klen)
+{
+	int ret, len = klogctl(10, NULL, 0);
+	char *buff = malloc(len);
+
+	assert(buff && klen);
+	ret = klogctl(3, buff, len);
+	assert(ret >= 0);
+	*klen = ret;
+
+	return buff;
+}
+
+static void put_klog_buff(char *buff)
+{
+	free(buff);
+}
+
+static int get_last_jit_image(char *haystack, size_t hlen,
+			      uint8_t *image, size_t ilen,
+			      unsigned long *base)
+{
+	char *ptr, *pptr, *tmp;
+	off_t off = 0;
+	int ret, flen, proglen, pass, ulen = 0;
+	regmatch_t pmatch[1];
+	regex_t regex;
+
+	if (hlen == 0)
+		return 0;
+
+	ret = regcomp(&regex, "flen=[[:alnum:]]+ proglen=[[:digit:]]+ "
+		      "pass=[[:digit:]]+ image=[[:xdigit:]]+", REG_EXTENDED);
+	assert(ret == 0);
+
+	ptr = haystack;
+	while (1) {
+		ret = regexec(&regex, ptr, 1, pmatch, 0);
+		if (ret == 0) {
+			ptr += pmatch[0].rm_eo;
+			off += pmatch[0].rm_eo;
+			assert(off < hlen);
+		} else
+			break;
+	}
+
+	ptr = haystack + off - (pmatch[0].rm_eo - pmatch[0].rm_so);
+	ret = sscanf(ptr, "flen=%d proglen=%d pass=%d image=%lx",
+		     &flen, &proglen, &pass, base);
+	if (ret != 4)
+		return 0;
+
+	tmp = ptr = haystack + off;
+	while ((ptr = strtok(tmp, "\n")) != NULL && ulen < ilen) {
+		tmp = NULL;
+		if (!strstr(ptr, "JIT code"))
+			continue;
+		pptr = ptr;
+		while ((ptr = strstr(pptr, ":")))
+			pptr = ptr + 1;
+		ptr = pptr;
+		do {
+			image[ulen++] = (uint8_t) strtoul(pptr, &pptr, 16);
+			if (ptr == pptr || ulen >= ilen) {
+				ulen--;
+				break;
+			}
+			ptr = pptr;
+		} while (1);
+	}
+
+	assert(ulen == proglen);
+	printf("%d bytes emitted from JIT compiler (pass:%d, flen:%d)\n",
+	       proglen, pass, flen);
+	printf("%lx + <x>:\n", *base);
+
+	regfree(&regex);
+	return ulen;
+}
+
+int main(int argc, char **argv)
+{
+	int len, klen, opcodes = 0;
+	char *kbuff;
+	unsigned long base;
+	uint8_t image[4096];
+
+	if (argc > 1) {
+		if (!strncmp("-o", argv[argc - 1], 2)) {
+			opcodes = 1;
+		} else {
+			printf("usage: bpf_jit_disasm [-o: show opcodes]\n");
+			exit(0);
+		}
+	}
+
+	bfd_init();
+	memset(image, 0, sizeof(image));
+
+	kbuff = get_klog_buff(&klen);
+
+	len = get_last_jit_image(kbuff, klen, image, sizeof(image), &base);
+	if (len > 0 && base > 0)
+		get_asm_insns(image, len, base, opcodes);
+
+	put_klog_buff(kbuff);
+
+	return 0;
+}
-- 
1.7.11.7
