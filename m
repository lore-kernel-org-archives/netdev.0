From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v5 09/10] bpf,landlock: Add tests for Landlock
Date: Wed, 22 Feb 2017 02:26:31 +0100
Message-ID: <20170222012632.4196-10-mic@digikod.net>
References: <20170222012632.4196-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.or
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-6810-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170222012632.4196-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Test basic context access and filesystem event with multiple cases.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: Shuah Khan <shuah@kernel.org>
Cc: Will Drewry <wad@chromium.org>
---
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/bpf/test_verifier.c        |  54 +++-
 tools/testing/selftests/landlock/.gitignore        |   2 +
 tools/testing/selftests/landlock/Makefile          |  47 +++
 tools/testing/selftests/landlock/rules/Makefile    |  52 +++
 tools/testing/selftests/landlock/rules/README.rst  |   1 +
 .../testing/selftests/landlock/rules/bpf_helpers.h |   1 +
 tools/testing/selftests/landlock/rules/fs1.c       |  31 ++
 tools/testing/selftests/landlock/rules/fs2.c       |  31 ++
 tools/testing/selftests/landlock/test_fs.c         | 347 +++++++++++++++++++++
 10 files changed, 566 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/landlock/.gitignore
 create mode 100644 tools/testing/selftests/landlock/Makefile
 create mode 100644 tools/testing/selftests/landlock/rules/Makefile
 create mode 120000 tools/testing/selftests/landlock/rules/README.rst
 create mode 120000 tools/testing/selftests/landlock/rules/bpf_helpers.h
 create mode 100644 tools/testing/selftests/landlock/rules/fs1.c
 create mode 100644 tools/testing/selftests/landlock/rules/fs2.c
 create mode 100644 tools/testing/selftests/landlock/test_fs.c

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 831022b12848..a8dadcfa4c01 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -10,6 +10,7 @@ TARGETS += futex
 TARGETS += gpio
 TARGETS += ipc
 TARGETS += kcmp
+TARGETS += landlock
 TARGETS += lib
 TARGETS += membarrier
 TARGETS += memfd
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 15eeb79104fe..ee1d439e48e4 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -4451,7 +4451,59 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 		.result_unpriv = REJECT,
-	}
+	},
+	{
+		"landlock/fs: always accept",
+		.insns = {
+			BPF_MOV32_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_LANDLOCK,
+		.prog_subtype = {
+			.landlock_rule = {
+				.version = 1,
+				.event = LANDLOCK_SUBTYPE_EVENT_FS,
+			}
+		},
+	},
+	{
+		"landlock/fs: read context",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_6,
+				offsetof(struct landlock_context, status)),
+			/* test operations on raw values */
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_6,
+				offsetof(struct landlock_context, arch)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_6,
+				offsetof(struct landlock_context, syscall_nr)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_6,
+				offsetof(struct landlock_context, syscall_cmd)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_6,
+				offsetof(struct landlock_context, event)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_6,
+				offsetof(struct landlock_context, arg1)),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_6,
+				offsetof(struct landlock_context, arg2)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 1),
+			BPF_MOV32_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_LANDLOCK,
+		.prog_subtype = {
+			.landlock_rule = {
+				.version = 1,
+				.event = LANDLOCK_SUBTYPE_EVENT_FS,
+			}
+		},
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
diff --git a/tools/testing/selftests/landlock/.gitignore b/tools/testing/selftests/landlock/.gitignore
new file mode 100644
index 000000000000..e5ade9fc5633
--- /dev/null
+++ b/tools/testing/selftests/landlock/.gitignore
@@ -0,0 +1,2 @@
+/test_fs
+/tmp_*
diff --git a/tools/testing/selftests/landlock/Makefile b/tools/testing/selftests/landlock/Makefile
new file mode 100644
index 000000000000..9a52c82d64fa
--- /dev/null
+++ b/tools/testing/selftests/landlock/Makefile
@@ -0,0 +1,47 @@
+LIBDIR := ../../../lib
+BPFOBJ := $(LIBDIR)/bpf/bpf.o
+LOADOBJ := ../../../../samples/bpf/bpf_load.o
+
+CFLAGS += -Wl,-no-as-needed -Wall -O2 -I../../../include/uapi -I$(LIBDIR)
+LDFLAGS += -lelf
+
+test_src = $(wildcard test_*.c)
+rule_src = $(wildcard rules/*.c)
+
+test_objs := $(test_src:.c=)
+rule_objs := $(rule_src:.c=.o)
+
+TEST_PROGS := $(test_objs)
+
+.PHONY: all clean clean_tmp force
+
+all: $(test_objs) $(rule_objs)
+
+# force a rebuild of BPFOBJ when its dependencies are updated
+force:
+
+$(BPFOBJ): force
+	$(MAKE) -C $(dir $(BPFOBJ))
+
+$(LOADOBJ):
+	$(MAKE) -C $(dir $(LOADOBJ))
+
+# minimize builds
+rules/modules.order: $(rule_src)
+	$(MAKE) -C rules
+	@touch $@
+
+$(rule_objs): rules/modules.order
+	@
+
+$(test_objs): $(BPFOBJ) $(LOADOBJ)
+
+include ../lib.mk
+
+clean_tmp:
+	$(RM) -r tmp_*
+
+clean: clean_tmp
+	$(MAKE) -C rules clean
+	$(RM) $(test_objs)
+
diff --git a/tools/testing/selftests/landlock/rules/Makefile b/tools/testing/selftests/landlock/rules/Makefile
new file mode 100644
index 000000000000..bf33b67a9fc2
--- /dev/null
+++ b/tools/testing/selftests/landlock/rules/Makefile
@@ -0,0 +1,52 @@
+# kbuild trick to avoid linker error. Can be omitted if a module is built.
+obj- := dummy.o
+
+# Tell kbuild to always build the programs
+always := fs1.o
+always += fs2.o
+
+EXTRA_CFLAGS = -Wall -Wextra
+
+# Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
+#  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
+LLC ?= llc
+CLANG ?= clang
+
+# Verify LLVM compiler tools are available and bpf target is supported by llc
+.PHONY: all clean verify_cmds verify_target_bpf $(CLANG) $(LLC)
+
+# Trick to allow make to be run from this directory
+all:
+	$(MAKE) -C ../../../../../ $(CURDIR)/
+
+clean:
+	$(MAKE) -C ../../../../../ M=$(CURDIR) clean
+
+verify_cmds: $(CLANG) $(LLC)
+	@for TOOL in $^ ; do \
+		if ! (which -- "$${TOOL}" > /dev/null 2>&1); then \
+			echo "*** ERROR: Cannot find LLVM tool $${TOOL}" ;\
+			exit 1; \
+		else true; fi; \
+	done
+
+verify_target_bpf: verify_cmds
+	@if ! (${LLC} -march=bpf -mattr=help > /dev/null 2>&1); then \
+		echo "*** ERROR: LLVM (${LLC}) does not support 'bpf' target" ;\
+		echo "   NOTICE: LLVM version >= 3.7.1 required" ;\
+		exit 2; \
+	else true; fi
+
+%_kern.c: verify_target_bpf
+
+# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
+# But, there is no easy way to fix it, so just exclude it since it is
+# useless for BPF samples.
+$(obj)/%.o: $(src)/%.c
+	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
+		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
+		-Wno-compare-distinct-pointer-types \
+		-Wno-gnu-variable-sized-type-not-at-end \
+		-Wno-tautological-compare \
+		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
+
diff --git a/tools/testing/selftests/landlock/rules/README.rst b/tools/testing/selftests/landlock/rules/README.rst
new file mode 120000
index 000000000000..605f48aa6f72
--- /dev/null
+++ b/tools/testing/selftests/landlock/rules/README.rst
@@ -0,0 +1 @@
+../../../../../samples/bpf/README.rst
\ No newline at end of file
diff --git a/tools/testing/selftests/landlock/rules/bpf_helpers.h b/tools/testing/selftests/landlock/rules/bpf_helpers.h
new file mode 120000
index 000000000000..0aa1a521b39a
--- /dev/null
+++ b/tools/testing/selftests/landlock/rules/bpf_helpers.h
@@ -0,0 +1 @@
+../../../../../samples/bpf/bpf_helpers.h
\ No newline at end of file
diff --git a/tools/testing/selftests/landlock/rules/fs1.c b/tools/testing/selftests/landlock/rules/fs1.c
new file mode 100644
index 000000000000..fb3cab7a3116
--- /dev/null
+++ b/tools/testing/selftests/landlock/rules/fs1.c
@@ -0,0 +1,31 @@
+/*
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ * Landlock test - Read-only filesystem
+ */
+
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+SEC("landlock1")
+static int landlock_fs_prog1(struct landlock_context *ctx)
+{
+	if (!(ctx->arg2 & LANDLOCK_ACTION_FS_WRITE))
+		return 0;
+	return 1;
+}
+
+SEC("subtype")
+static union bpf_prog_subtype _subtype = {
+	.landlock_rule = {
+		.version = 1,
+		.event = LANDLOCK_SUBTYPE_EVENT_FS,
+	}
+};
+
+SEC("license")
+static char _license[] = "GPL";
diff --git a/tools/testing/selftests/landlock/rules/fs2.c b/tools/testing/selftests/landlock/rules/fs2.c
new file mode 100644
index 000000000000..d5cb6b9e8c26
--- /dev/null
+++ b/tools/testing/selftests/landlock/rules/fs2.c
@@ -0,0 +1,31 @@
+/*
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ * Landlock test - No-open filesystem
+ */
+
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+SEC("landlock1")
+static int landlock_fs_prog1(struct landlock_context *ctx)
+{
+	if (!(ctx->arg2 & LANDLOCK_ACTION_FS_GET))
+		return 0;
+	return 1;
+}
+
+SEC("subtype")
+static union bpf_prog_subtype _subtype = {
+	.landlock_rule = {
+		.version = 1,
+		.event = LANDLOCK_SUBTYPE_EVENT_FS,
+	}
+};
+
+SEC("license")
+static char _license[] = "GPL";
diff --git a/tools/testing/selftests/landlock/test_fs.c b/tools/testing/selftests/landlock/test_fs.c
new file mode 100644
index 000000000000..3dcc0294324c
--- /dev/null
+++ b/tools/testing/selftests/landlock/test_fs.c
@@ -0,0 +1,347 @@
+/*
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ *
+ * Tests code for Landlock
+ */
+
+#define _GNU_SOURCE
+#include <errno.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
+#include <linux/seccomp.h>
+#include <stddef.h>
+#include <string.h>
+#include <sys/prctl.h>
+#include <sys/syscall.h>
+
+#include <fcntl.h> /* open() */
+#include <sys/mount.h>
+#include <sys/stat.h> /* mkdir() */
+#include <sys/mman.h> /* mmap() */
+
+#include "../seccomp/test_harness.h"
+#include "../../../../samples/bpf/bpf_load.h"
+
+#define TMP_PREFIX "tmp_"
+
+#ifndef SECCOMP_ADD_LANDLOCK_RULE
+#define SECCOMP_ADD_LANDLOCK_RULE	2
+#endif
+
+#ifndef seccomp
+static int seccomp(unsigned int op, unsigned int flags, void *args)
+{
+	errno = 0;
+	return syscall(__NR_seccomp, op, flags, args);
+}
+#endif
+
+static unsigned int __step_count = 0;
+
+#define ASSERT_STEP(cond) \
+	{ \
+		step--; \
+		if (!(cond)) \
+			_exit(step); \
+	}
+
+TEST(seccomp_landlock)
+{
+	int ret;
+
+	ret = prctl(PR_SET_NO_NEW_PRIVS, 1, NULL, 0, 0);
+	ASSERT_EQ(0, ret) {
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS");
+	}
+	ret = seccomp(SECCOMP_ADD_LANDLOCK_RULE, 0, NULL);
+	EXPECT_EQ(-1, ret);
+	EXPECT_EQ(EFAULT, errno) {
+		TH_LOG("Kernel does not support CONFIG_SECURITY_LANDLOCK");
+	}
+}
+
+struct layout1 {
+	int file_ro;
+	int file_rw;
+	int file_wo;
+};
+
+static void setup_layout1(struct __test_metadata *_metadata,
+		struct layout1 *l1)
+{
+	int fd;
+	char buf[] = "fs1";
+
+	l1->file_ro = -1;
+	l1->file_rw = -1;
+	l1->file_wo = -1;
+
+	fd = open(TMP_PREFIX "file_created",
+			O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC,
+			S_IRUSR | S_IWUSR);
+	ASSERT_GE(fd, 0);
+	ASSERT_EQ(sizeof(buf), write(fd, buf, sizeof(buf)));
+	ASSERT_EQ(0, close(fd));
+
+	fd = mkdir(TMP_PREFIX "dir_created", S_IRUSR | S_IWUSR);
+	ASSERT_GE(fd, 0);
+	ASSERT_EQ(0, close(fd));
+
+	l1->file_ro = open(TMP_PREFIX "file_ro",
+			O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC,
+			S_IRUSR | S_IWUSR);
+	ASSERT_LE(0, l1->file_ro);
+	ASSERT_EQ(sizeof(buf), write(l1->file_ro, buf, sizeof(buf)));
+	ASSERT_EQ(0, close(l1->file_ro));
+	l1->file_ro = open(TMP_PREFIX "file_ro",
+			O_RDONLY | O_CLOEXEC,
+			S_IRUSR | S_IWUSR);
+	ASSERT_LE(0, l1->file_ro);
+
+	l1->file_rw = open(TMP_PREFIX "file_rw",
+			O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC,
+			S_IRUSR | S_IWUSR);
+	ASSERT_LE(0, l1->file_rw);
+	ASSERT_EQ(sizeof(buf), write(l1->file_rw, buf, sizeof(buf)));
+	ASSERT_EQ(0, lseek(l1->file_rw, 0, SEEK_SET));
+
+	l1->file_wo = open(TMP_PREFIX "file_wo",
+			O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC,
+			S_IRUSR | S_IWUSR);
+	ASSERT_LE(0, l1->file_wo);
+	ASSERT_EQ(sizeof(buf), write(l1->file_wo, buf, sizeof(buf)));
+	ASSERT_EQ(0, lseek(l1->file_wo, 0, SEEK_SET));
+}
+
+static void cleanup_layout1(void)
+{
+	unlink(TMP_PREFIX "file_created");
+	unlink(TMP_PREFIX "file_ro");
+	unlink(TMP_PREFIX "file_rw");
+	unlink(TMP_PREFIX "file_wo");
+	unlink(TMP_PREFIX "should_not_exist");
+	rmdir(TMP_PREFIX "dir_created");
+}
+
+FIXTURE(rule_fs1) {
+	struct layout1 l1;
+	int prog;
+};
+
+FIXTURE_SETUP(rule_fs1)
+{
+	cleanup_layout1();
+	setup_layout1(_metadata, &self->l1);
+
+	ASSERT_EQ(0, load_bpf_file("rules/fs1.o")) {
+		TH_LOG("%s", bpf_log_buf);
+	}
+	self->prog = prog_fd[0];
+	ASSERT_EQ(0, prctl(PR_SET_NO_NEW_PRIVS, 1, NULL, 0, 0)) {
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS");
+	}
+}
+
+FIXTURE_TEARDOWN(rule_fs1)
+{
+	EXPECT_EQ(0, close(self->prog));
+	/* cleanup_layout1() would be denied here */
+}
+
+TEST_F(rule_fs1, load_prog) {}
+
+TEST_F(rule_fs1, read_only_file)
+{
+	int fd;
+	int step = 0;
+	char buf_write[] = "should not be written";
+	char buf_read[2];
+
+	ASSERT_EQ(-1, write(self->l1.file_ro, buf_write, sizeof(buf_write)));
+	ASSERT_EQ(EBADF, errno);
+
+	ASSERT_EQ(-1, read(self->l1.file_wo, buf_read, sizeof(buf_read)));
+	ASSERT_EQ(EBADF, errno);
+
+	ASSERT_EQ(0, seccomp(SECCOMP_ADD_LANDLOCK_RULE, 0, &self->prog)) {
+		TH_LOG("Failed to apply rule fs1: %s", strerror(errno));
+	}
+
+	fd = open(".",
+			O_TMPFILE | O_EXCL | O_RDWR | O_CLOEXEC,
+			S_IRUSR | S_IWUSR);
+	ASSERT_STEP(fd == -1);
+	ASSERT_STEP(errno != EOPNOTSUPP)
+	ASSERT_STEP(errno == EPERM);
+
+	fd = open(TMP_PREFIX "file_created",
+			O_RDONLY | O_CLOEXEC);
+	ASSERT_STEP(fd >= 0);
+	ASSERT_STEP(!close(fd));
+
+	fd = open(TMP_PREFIX "file_created",
+			O_RDWR | O_CLOEXEC);
+	ASSERT_STEP(fd == -1);
+	ASSERT_STEP(errno == EPERM);
+
+	fd = open(TMP_PREFIX "file_created",
+			O_WRONLY | O_CLOEXEC);
+	ASSERT_STEP(fd == -1);
+	ASSERT_STEP(errno == EPERM);
+
+	fd = open(TMP_PREFIX "should_not_exist",
+			O_CREAT | O_EXCL | O_CLOEXEC,
+			S_IRUSR | S_IWUSR);
+	ASSERT_STEP(fd == -1);
+	ASSERT_STEP(errno == EPERM);
+
+	ASSERT_STEP(-1 ==
+			write(self->l1.file_ro, buf_write, sizeof(buf_write)));
+	ASSERT_STEP(errno == EBADF);
+	ASSERT_STEP(sizeof(buf_read) ==
+			read(self->l1.file_ro, buf_read, sizeof(buf_read)));
+
+	ASSERT_STEP(-1 ==
+			write(self->l1.file_rw, buf_write, sizeof(buf_write)));
+	ASSERT_STEP(errno == EPERM);
+	ASSERT_STEP(sizeof(buf_read) ==
+			read(self->l1.file_rw, buf_read, sizeof(buf_read)));
+
+	ASSERT_STEP(-1 == write(self->l1.file_wo, buf_write, sizeof(buf_write)));
+	ASSERT_STEP(errno == EPERM);
+	ASSERT_STEP(-1 == read(self->l1.file_wo, buf_read, sizeof(buf_read)));
+	ASSERT_STEP(errno == EBADF);
+
+	ASSERT_STEP(-1 == unlink(TMP_PREFIX "file_created"));
+	ASSERT_STEP(errno == EPERM);
+	ASSERT_STEP(-1 == rmdir(TMP_PREFIX "dir_created"));
+	ASSERT_STEP(errno == EPERM);
+
+	ASSERT_STEP(0 == close(self->l1.file_ro));
+	ASSERT_STEP(0 == close(self->l1.file_rw));
+	ASSERT_STEP(0 == close(self->l1.file_wo));
+}
+
+TEST_F(rule_fs1, read_only_mount)
+{
+	int step = 0;
+
+	ASSERT_EQ(0, mount(".", TMP_PREFIX "dir_created",
+				NULL, MS_BIND, NULL));
+	ASSERT_EQ(0, umount2(TMP_PREFIX "dir_created", MNT_FORCE));
+
+	ASSERT_EQ(0, seccomp(SECCOMP_ADD_LANDLOCK_RULE, 0, &self->prog)) {
+		TH_LOG("Failed to apply rule fs1: %s", strerror(errno));
+	}
+
+	ASSERT_STEP(-1 == mount(".", TMP_PREFIX "dir_created",
+				NULL, MS_BIND, NULL));
+	ASSERT_STEP(errno == EPERM);
+	ASSERT_STEP(-1 == umount("/"));
+	ASSERT_STEP(errno == EPERM);
+}
+
+TEST_F(rule_fs1, read_only_mem)
+{
+	int step = 0;
+	void *addr;
+
+	addr = mmap(NULL, 1, PROT_READ | PROT_WRITE,
+			MAP_SHARED, self->l1.file_rw, 0);
+	ASSERT_NE(NULL, addr);
+	ASSERT_EQ(0, munmap(addr, 1));
+
+	ASSERT_EQ(0, seccomp(SECCOMP_ADD_LANDLOCK_RULE, 0, &self->prog)) {
+		TH_LOG("Failed to apply rule fs1: %s", strerror(errno));
+	}
+
+	addr = mmap(NULL, 1, PROT_READ, MAP_SHARED,
+			self->l1.file_rw, 0);
+	ASSERT_STEP(addr != NULL);
+	ASSERT_STEP(-1 == mprotect(addr, 1, PROT_WRITE));
+	ASSERT_STEP(errno == EPERM);
+	ASSERT_STEP(0 == munmap(addr, 1));
+
+	addr = mmap(NULL, 1, PROT_READ | PROT_WRITE, MAP_SHARED,
+			self->l1.file_rw, 0);
+	ASSERT_STEP(addr != NULL);
+	ASSERT_STEP(errno == EPERM);
+
+	addr = mmap(NULL, 1, PROT_READ | PROT_WRITE, MAP_PRIVATE,
+			self->l1.file_rw, 0);
+	ASSERT_STEP(addr != NULL);
+	ASSERT_STEP(0 == munmap(addr, 1));
+}
+
+FIXTURE(rule_fs2) {
+	struct layout1 l1;
+	int prog;
+};
+
+FIXTURE_SETUP(rule_fs2)
+{
+	cleanup_layout1();
+	setup_layout1(_metadata, &self->l1);
+
+	ASSERT_EQ(0, load_bpf_file("rules/fs2.o")) {
+		TH_LOG("%s", bpf_log_buf);
+	}
+	self->prog = prog_fd[0];
+	ASSERT_EQ(0, prctl(PR_SET_NO_NEW_PRIVS, 1, NULL, 0, 0)) {
+		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS");
+	}
+}
+
+FIXTURE_TEARDOWN(rule_fs2)
+{
+	EXPECT_EQ(0, close(self->prog));
+	cleanup_layout1();
+}
+
+static void landlocked_deny_open(struct __test_metadata *_metadata,
+		struct layout1 *l1)
+{
+	int fd;
+	void *addr;
+
+	fd = open(".", O_DIRECTORY | O_CLOEXEC);
+	ASSERT_EQ(-1, fd);
+	ASSERT_EQ(EPERM, errno);
+
+	addr = mmap(NULL, 1, PROT_READ | PROT_WRITE,
+			MAP_SHARED, l1->file_rw, 0);
+	ASSERT_NE(NULL, addr);
+	ASSERT_EQ(0, munmap(addr, 1));
+}
+
+TEST_F(rule_fs2, deny_open_for_hierarchy) {
+	int fd;
+	int status;
+	pid_t child;
+
+	fd = open(".", O_DIRECTORY | O_CLOEXEC);
+	ASSERT_LE(0, fd);
+	ASSERT_EQ(0, close(fd));
+
+	ASSERT_EQ(0, seccomp(SECCOMP_ADD_LANDLOCK_RULE, 0, &self->prog)) {
+		TH_LOG("Failed to apply rule fs2: %s", strerror(errno));
+	}
+
+	landlocked_deny_open(_metadata, &self->l1);
+
+	child = fork();
+	ASSERT_LE(0, child);
+	if (!child) {
+		landlocked_deny_open(_metadata, &self->l1);
+		_exit(1);
+	}
+	ASSERT_EQ(child, waitpid(child, &status, 0));
+	ASSERT_TRUE(WIFEXITED(status));
+	_exit(WEXITSTATUS(status));
+}
+
+TEST_HARNESS_MAIN
-- 
2.11.0
