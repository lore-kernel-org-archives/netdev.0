From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v7 09/10] bpf,landlock: Add tests for Landlock
Date: Mon, 21 Aug 2017 02:09:32 +0200
Message-ID: <20170821000933.13024-10-mic@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
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
Return-path: <kernel-hardening-return-9524-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170821000933.13024-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Test basic context access, ptrace protection and filesystem event with
multiple cases.

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

Changes since v6:
* use the new kselftest_harness.h
* use const variables
* replace ASSERT_STEP with ASSERT_*
* rename BPF_PROG_TYPE_LANDLOCK to BPF_PROG_TYPE_LANDLOCK_RULE
* force sample library rebuild
* fix install target

Changes since v5:
* add subtype test
* add ptrace tests
* split and rename files
* cleanup and rebase
---
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/bpf/test_verifier.c        |  55 ++++
 tools/testing/selftests/landlock/.gitignore        |   5 +
 tools/testing/selftests/landlock/Makefile          |  48 ++++
 tools/testing/selftests/landlock/bpf/Makefile      |  55 ++++
 tools/testing/selftests/landlock/bpf/README.rst    |   1 +
 .../selftests/landlock/bpf/rule_fs_no_open.c       |  32 +++
 .../selftests/landlock/bpf/rule_fs_read_only.c     |  32 +++
 tools/testing/selftests/landlock/test.h            |  28 ++
 tools/testing/selftests/landlock/test_base.c       |  27 ++
 tools/testing/selftests/landlock/test_fs.c         | 296 +++++++++++++++++++++
 tools/testing/selftests/landlock/test_ptrace.c     | 158 +++++++++++
 12 files changed, 738 insertions(+)
 create mode 100644 tools/testing/selftests/landlock/.gitignore
 create mode 100644 tools/testing/selftests/landlock/Makefile
 create mode 100644 tools/testing/selftests/landlock/bpf/Makefile
 create mode 120000 tools/testing/selftests/landlock/bpf/README.rst
 create mode 100644 tools/testing/selftests/landlock/bpf/rule_fs_no_open.c
 create mode 100644 tools/testing/selftests/landlock/bpf/rule_fs_read_only.c
 create mode 100644 tools/testing/selftests/landlock/test.h
 create mode 100644 tools/testing/selftests/landlock/test_base.c
 create mode 100644 tools/testing/selftests/landlock/test_fs.c
 create mode 100644 tools/testing/selftests/landlock/test_ptrace.c

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 26ce4f7168be..099d19950739 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -12,6 +12,7 @@ TARGETS += gpio
 TARGETS += intel_pstate
 TARGETS += ipc
 TARGETS += kcmp
+TARGETS += landlock
 TARGETS += lib
 TARGETS += membarrier
 TARGETS += memfd
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 3146839a51bf..9fb19c975c1b 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -6499,6 +6499,61 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.has_prog_subtype = true,
 	},
+	{
+		"missing subtype",
+		.insns = {
+			BPF_MOV32_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_LANDLOCK_RULE,
+	},
+	{
+		"landlock/fs: always accept",
+		.insns = {
+			BPF_MOV32_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_LANDLOCK_RULE,
+		.has_prog_subtype = true,
+		.prog_subtype = {
+			.landlock_rule = {
+				.abi = 1,
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
+			BPF_LDX_MEM(BPF_DW, BPF_REG_7, BPF_REG_6,
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
+		.prog_type = BPF_PROG_TYPE_LANDLOCK_RULE,
+		.has_prog_subtype = true,
+		.prog_subtype = {
+			.landlock_rule = {
+				.abi = 1,
+				.event = LANDLOCK_SUBTYPE_EVENT_FS,
+			}
+		},
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
diff --git a/tools/testing/selftests/landlock/.gitignore b/tools/testing/selftests/landlock/.gitignore
new file mode 100644
index 000000000000..04d01e3646da
--- /dev/null
+++ b/tools/testing/selftests/landlock/.gitignore
@@ -0,0 +1,5 @@
+/rule_*
+/test_base
+/test_fs
+/test_ptrace
+/tmp_*
diff --git a/tools/testing/selftests/landlock/Makefile b/tools/testing/selftests/landlock/Makefile
new file mode 100644
index 000000000000..77bbadfe373c
--- /dev/null
+++ b/tools/testing/selftests/landlock/Makefile
@@ -0,0 +1,48 @@
+LIBDIR := ../../../lib
+BPFOBJ := $(LIBDIR)/bpf/bpf.o
+LOADOBJ := ../../../../samples/bpf/bpf_load.o
+
+CFLAGS += -Wl,-no-as-needed -Wall -O2 -I../../../include/uapi -I$(LIBDIR)
+LDFLAGS += -lelf
+
+test_src = $(wildcard test_*.c)
+rule_src = $(wildcard bpf/rule_*.c)
+
+test_objs := $(test_src:.c=)
+rule_objs := $(notdir $(rule_src:.c=.o))
+
+TEST_PROGS := $(test_objs)
+TEST_PROGS_EXTENDED := $(rule_objs)
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
+$(LOADOBJ): force
+	$(MAKE) -C $(dir $(LOADOBJ))
+
+# minimize builds
+bpf/modules.order: $(rule_src)
+	$(MAKE) -C bpf
+	@touch $@
+
+$(rule_objs): bpf/modules.order
+	@
+
+$(test_objs): $(BPFOBJ) $(LOADOBJ) ../kselftest_harness.h
+
+include ../lib.mk
+
+clean_tmp:
+	$(RM) -r tmp_*
+
+clean: clean_tmp
+	$(MAKE) -C bpf clean
+	$(RM) $(test_objs)
+
diff --git a/tools/testing/selftests/landlock/bpf/Makefile b/tools/testing/selftests/landlock/bpf/Makefile
new file mode 100644
index 000000000000..857ad2483289
--- /dev/null
+++ b/tools/testing/selftests/landlock/bpf/Makefile
@@ -0,0 +1,55 @@
+# copied from samples/bpf/Makefile
+#
+# kbuild trick to avoid linker error. Can be omitted if a module is built.
+obj- := dummy.o
+
+# Tell kbuild to always build the programs
+always := ../rule_fs_read_only.o
+always += ../rule_fs_no_open.o
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
+$(src)/*.c: verify_target_bpf
+
+# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
+# But, there is no easy way to fix it, so just exclude it since it is
+# useless for BPF samples.
+$(obj)/../rule_%.o: $(src)/rule_%.c
+	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) -I$(obj) \
+		-I$(srctree)/tools/testing/selftests/bpf/ \
+		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
+		-Wno-compare-distinct-pointer-types \
+		-Wno-gnu-variable-sized-type-not-at-end \
+		-Wno-address-of-packed-member -Wno-tautological-compare \
+		-Wno-unknown-warning-option \
+		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
diff --git a/tools/testing/selftests/landlock/bpf/README.rst b/tools/testing/selftests/landlock/bpf/README.rst
new file mode 120000
index 000000000000..605f48aa6f72
--- /dev/null
+++ b/tools/testing/selftests/landlock/bpf/README.rst
@@ -0,0 +1 @@
+../../../../../samples/bpf/README.rst
\ No newline at end of file
diff --git a/tools/testing/selftests/landlock/bpf/rule_fs_no_open.c b/tools/testing/selftests/landlock/bpf/rule_fs_no_open.c
new file mode 100644
index 000000000000..acde56b636a3
--- /dev/null
+++ b/tools/testing/selftests/landlock/bpf/rule_fs_no_open.c
@@ -0,0 +1,32 @@
+/*
+ * Landlock rule - no-open filesystem
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <uapi/linux/bpf.h>
+
+#include <bpf_helpers.h>
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
+static const union bpf_prog_subtype _subtype = {
+	.landlock_rule = {
+		.abi = 1,
+		.event = LANDLOCK_SUBTYPE_EVENT_FS,
+	}
+};
+
+SEC("license")
+static const char _license[] = "GPL";
diff --git a/tools/testing/selftests/landlock/bpf/rule_fs_read_only.c b/tools/testing/selftests/landlock/bpf/rule_fs_read_only.c
new file mode 100644
index 000000000000..17680f2e90b0
--- /dev/null
+++ b/tools/testing/selftests/landlock/bpf/rule_fs_read_only.c
@@ -0,0 +1,32 @@
+/*
+ * Landlock rule - read-only filesystem
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <uapi/linux/bpf.h>
+
+#include <bpf_helpers.h>
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
+static const union bpf_prog_subtype _subtype = {
+	.landlock_rule = {
+		.abi = 1,
+		.event = LANDLOCK_SUBTYPE_EVENT_FS,
+	}
+};
+
+SEC("license")
+static const char _license[] = "GPL";
diff --git a/tools/testing/selftests/landlock/test.h b/tools/testing/selftests/landlock/test.h
new file mode 100644
index 000000000000..e15392bb84d4
--- /dev/null
+++ b/tools/testing/selftests/landlock/test.h
@@ -0,0 +1,28 @@
+/*
+ * Landlock helpers
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#include <errno.h>
+#include <sys/prctl.h>
+#include <sys/syscall.h>
+
+#include "../kselftest_harness.h"
+#include "../../../../samples/bpf/bpf_load.h"
+
+#ifndef SECCOMP_PREPEND_LANDLOCK_RULE
+#define SECCOMP_PREPEND_LANDLOCK_RULE	2
+#endif
+
+#ifndef seccomp
+static int seccomp(unsigned int op, unsigned int flags, void *args)
+{
+	errno = 0;
+	return syscall(__NR_seccomp, op, flags, args);
+}
+#endif
diff --git a/tools/testing/selftests/landlock/test_base.c b/tools/testing/selftests/landlock/test_base.c
new file mode 100644
index 000000000000..dbf4f57f9690
--- /dev/null
+++ b/tools/testing/selftests/landlock/test_base.c
@@ -0,0 +1,27 @@
+/*
+ * Landlock tests - base
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#define _GNU_SOURCE
+#include <errno.h>
+
+#include "test.h"
+
+TEST(seccomp_landlock)
+{
+	int ret;
+
+	ret = seccomp(SECCOMP_PREPEND_LANDLOCK_RULE, 0, NULL);
+	EXPECT_EQ(-1, ret);
+	EXPECT_EQ(EFAULT, errno) {
+		TH_LOG("Kernel does not support CONFIG_SECURITY_LANDLOCK");
+	}
+}
+
+TEST_HARNESS_MAIN
diff --git a/tools/testing/selftests/landlock/test_fs.c b/tools/testing/selftests/landlock/test_fs.c
new file mode 100644
index 000000000000..7404734d2c58
--- /dev/null
+++ b/tools/testing/selftests/landlock/test_fs.c
@@ -0,0 +1,296 @@
+/*
+ * Landlock tests - filesystem
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
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
+#include "test.h"
+
+#define TMP_PREFIX "tmp_"
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
+	char buf[] = "fs_read_only";
+
+	l1->file_ro = -1;
+	l1->file_rw = -1;
+	l1->file_wo = -1;
+
+	fd = open(TMP_PREFIX "file_created",
+			O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC, 0600);
+	ASSERT_GE(fd, 0);
+	ASSERT_EQ(sizeof(buf), write(fd, buf, sizeof(buf)));
+	ASSERT_EQ(0, close(fd));
+
+	fd = mkdir(TMP_PREFIX "dir_created", 0600);
+	ASSERT_GE(fd, 0);
+	ASSERT_EQ(0, close(fd));
+
+	l1->file_ro = open(TMP_PREFIX "file_ro",
+			O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC, 0600);
+	ASSERT_LE(0, l1->file_ro);
+	ASSERT_EQ(sizeof(buf), write(l1->file_ro, buf, sizeof(buf)));
+	ASSERT_EQ(0, close(l1->file_ro));
+	l1->file_ro = open(TMP_PREFIX "file_ro",
+			O_RDONLY | O_CLOEXEC, 0600);
+	ASSERT_LE(0, l1->file_ro);
+
+	l1->file_rw = open(TMP_PREFIX "file_rw",
+			O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC, 0600);
+	ASSERT_LE(0, l1->file_rw);
+	ASSERT_EQ(sizeof(buf), write(l1->file_rw, buf, sizeof(buf)));
+	ASSERT_EQ(0, lseek(l1->file_rw, 0, SEEK_SET));
+
+	l1->file_wo = open(TMP_PREFIX "file_wo",
+			O_CREAT | O_EXCL | O_WRONLY | O_CLOEXEC, 0600);
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
+FIXTURE(fs_read_only) {
+	struct layout1 l1;
+	int prog;
+};
+
+FIXTURE_SETUP(fs_read_only)
+{
+	cleanup_layout1();
+	setup_layout1(_metadata, &self->l1);
+
+	ASSERT_EQ(0, load_bpf_file("rule_fs_read_only.o")) {
+		TH_LOG("%s", bpf_log_buf);
+	}
+	self->prog = prog_fd[0];
+}
+
+FIXTURE_TEARDOWN(fs_read_only)
+{
+	EXPECT_EQ(0, close(self->prog));
+	/* cleanup_layout1() would be denied here */
+}
+
+TEST_F(fs_read_only, load_prog) {}
+
+TEST_F(fs_read_only, read_only_file)
+{
+	int fd;
+	char buf_write[] = "should not be written";
+	char buf_read[2];
+
+	ASSERT_EQ(-1, write(self->l1.file_ro, buf_write, sizeof(buf_write)));
+	ASSERT_EQ(EBADF, errno);
+
+	ASSERT_EQ(-1, read(self->l1.file_wo, buf_read, sizeof(buf_read)));
+	ASSERT_EQ(EBADF, errno);
+
+	ASSERT_EQ(0, seccomp(SECCOMP_PREPEND_LANDLOCK_RULE, 0, &self->prog)) {
+		TH_LOG("Failed to apply rule fs_read_only: %s",
+				strerror(errno));
+	}
+	_metadata->no_print = true;
+
+	fd = open(".", O_TMPFILE | O_EXCL | O_RDWR | O_CLOEXEC, 0600);
+	ASSERT_EQ(fd, -1);
+	ASSERT_NE(errno, EOPNOTSUPP)
+	ASSERT_EQ(errno, EPERM);
+
+	fd = open(TMP_PREFIX "file_created",
+			O_RDONLY | O_CLOEXEC);
+	ASSERT_GE(fd, 0);
+	ASSERT_EQ(close(fd), 0);
+
+	fd = open(TMP_PREFIX "file_created",
+			O_RDWR | O_CLOEXEC);
+	ASSERT_EQ(fd, -1);
+	ASSERT_EQ(errno, EPERM);
+
+	fd = open(TMP_PREFIX "file_created",
+			O_WRONLY | O_CLOEXEC);
+	ASSERT_EQ(fd, -1);
+	ASSERT_EQ(errno, EPERM);
+
+	fd = open(TMP_PREFIX "should_not_exist",
+			O_CREAT | O_EXCL | O_CLOEXEC, 0600);
+	ASSERT_EQ(fd, -1);
+	ASSERT_EQ(errno, EPERM);
+
+	ASSERT_EQ(-1,
+			write(self->l1.file_ro, buf_write, sizeof(buf_write)));
+	ASSERT_EQ(errno, EBADF);
+	ASSERT_EQ(sizeof(buf_read),
+			read(self->l1.file_ro, buf_read, sizeof(buf_read)));
+
+	ASSERT_EQ(-1,
+			write(self->l1.file_rw, buf_write, sizeof(buf_write)));
+	ASSERT_EQ(errno, EPERM);
+	ASSERT_EQ(sizeof(buf_read),
+			read(self->l1.file_rw, buf_read, sizeof(buf_read)));
+
+	ASSERT_EQ(-1, write(self->l1.file_wo, buf_write, sizeof(buf_write)));
+	ASSERT_EQ(errno, EPERM);
+	ASSERT_EQ(-1, read(self->l1.file_wo, buf_read, sizeof(buf_read)));
+	ASSERT_EQ(errno, EBADF);
+
+	ASSERT_EQ(-1, unlink(TMP_PREFIX "file_created"));
+	ASSERT_EQ(errno, EPERM);
+	ASSERT_EQ(-1, rmdir(TMP_PREFIX "dir_created"));
+	ASSERT_EQ(errno, EPERM);
+
+	ASSERT_EQ(0, close(self->l1.file_ro));
+	ASSERT_EQ(0, close(self->l1.file_rw));
+	ASSERT_EQ(0, close(self->l1.file_wo));
+}
+
+TEST_F(fs_read_only, read_only_mount)
+{
+	ASSERT_EQ(0, mount(".", TMP_PREFIX "dir_created",
+				NULL, MS_BIND, NULL));
+	ASSERT_EQ(0, umount2(TMP_PREFIX "dir_created", MNT_FORCE));
+
+	ASSERT_EQ(0, seccomp(SECCOMP_PREPEND_LANDLOCK_RULE, 0, &self->prog)) {
+		TH_LOG("Failed to apply rule fs_read_only: %s",
+				strerror(errno));
+	}
+
+	ASSERT_EQ(-1, mount(".", TMP_PREFIX "dir_created",
+				NULL, MS_BIND, NULL));
+	ASSERT_EQ(errno, EPERM);
+	ASSERT_EQ(-1, umount("/"));
+	ASSERT_EQ(errno, EPERM);
+}
+
+TEST_F(fs_read_only, read_only_mem)
+{
+	void *addr;
+
+	addr = mmap(NULL, 1, PROT_READ | PROT_WRITE,
+			MAP_SHARED, self->l1.file_rw, 0);
+	ASSERT_NE(NULL, addr);
+	ASSERT_EQ(0, munmap(addr, 1));
+
+	ASSERT_EQ(0, seccomp(SECCOMP_PREPEND_LANDLOCK_RULE, 0, &self->prog)) {
+		TH_LOG("Failed to apply rule fs_read_only: %s",
+				strerror(errno));
+	}
+
+	addr = mmap(NULL, 1, PROT_READ, MAP_SHARED,
+			self->l1.file_rw, 0);
+	ASSERT_NE(addr, NULL);
+	ASSERT_EQ(-1, mprotect(addr, 1, PROT_WRITE));
+	ASSERT_EQ(errno, EPERM);
+	ASSERT_EQ(0, munmap(addr, 1));
+
+	addr = mmap(NULL, 1, PROT_READ | PROT_WRITE, MAP_SHARED,
+			self->l1.file_rw, 0);
+	ASSERT_NE(addr, NULL);
+	ASSERT_EQ(errno, EPERM);
+
+	addr = mmap(NULL, 1, PROT_READ | PROT_WRITE, MAP_PRIVATE,
+			self->l1.file_rw, 0);
+	ASSERT_NE(addr, NULL);
+	ASSERT_EQ(0, munmap(addr, 1));
+}
+
+FIXTURE(fs_no_open) {
+	struct layout1 l1;
+	int prog;
+};
+
+FIXTURE_SETUP(fs_no_open)
+{
+	cleanup_layout1();
+	setup_layout1(_metadata, &self->l1);
+
+	ASSERT_EQ(0, load_bpf_file("rule_fs_no_open.o")) {
+		TH_LOG("%s", bpf_log_buf);
+	}
+	self->prog = prog_fd[0];
+}
+
+FIXTURE_TEARDOWN(fs_no_open)
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
+TEST_F(fs_no_open, deny_open_for_hierarchy) {
+	int fd;
+	int status;
+	pid_t child;
+
+	fd = open(".", O_DIRECTORY | O_CLOEXEC);
+	ASSERT_LE(0, fd);
+	ASSERT_EQ(0, close(fd));
+
+	ASSERT_EQ(0, seccomp(SECCOMP_PREPEND_LANDLOCK_RULE, 0, &self->prog)) {
+		TH_LOG("Failed to apply rule fs_no_open: %s", strerror(errno));
+	}
+
+	landlocked_deny_open(_metadata, &self->l1);
+
+	child = fork();
+	ASSERT_LE(0, child);
+	if (!child) {
+		landlocked_deny_open(_metadata, &self->l1);
+		_exit(0);
+	}
+	ASSERT_EQ(child, waitpid(child, &status, 0));
+	ASSERT_TRUE(WIFEXITED(status));
+	_exit(WEXITSTATUS(status));
+}
+
+TEST_HARNESS_MAIN
diff --git a/tools/testing/selftests/landlock/test_ptrace.c b/tools/testing/selftests/landlock/test_ptrace.c
new file mode 100644
index 000000000000..8d4d243cae1f
--- /dev/null
+++ b/tools/testing/selftests/landlock/test_ptrace.c
@@ -0,0 +1,158 @@
+/*
+ * Landlock tests - ptrace
+ *
+ * Copyright © 2017 Mickaël Salaün <mic@digikod.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2, as
+ * published by the Free Software Foundation.
+ */
+
+#define _GNU_SOURCE
+#include <signal.h> /* raise */
+#include <sys/ptrace.h>
+#include <sys/types.h> /* waitpid */
+#include <sys/wait.h> /* waitpid */
+#include <unistd.h> /* fork, pipe */
+
+#include "test.h"
+
+static void apply_null_sandbox(struct __test_metadata *_metadata)
+{
+	const struct bpf_insn prog_accept[] = {
+		BPF_MOV32_IMM(BPF_REG_0, 0),
+		BPF_EXIT_INSN(),
+	};
+	const union bpf_prog_subtype subtype = {
+		.landlock_rule = {
+			.abi = 1,
+			.event = LANDLOCK_SUBTYPE_EVENT_FS,
+		}
+	};
+	int prog;
+	char log[256] = "";
+
+	prog = bpf_load_program(BPF_PROG_TYPE_LANDLOCK_RULE,
+			(const struct bpf_insn *)&prog_accept,
+			sizeof(prog_accept) / sizeof(struct bpf_insn), "GPL",
+			0, log, sizeof(log), &subtype);
+	ASSERT_NE(-1, prog) {
+		TH_LOG("Failed to load minimal rule: %s\n%s",
+				strerror(errno), log);
+	}
+	ASSERT_EQ(0, seccomp(SECCOMP_PREPEND_LANDLOCK_RULE, 0, &prog)) {
+		TH_LOG("Failed to apply minimal rule: %s", strerror(errno));
+	}
+	EXPECT_EQ(0, close(prog));
+}
+
+/* PTRACE_TRACEME and PTRACE_ATTACH without Landlock rules effect */
+static void check_ptrace(struct __test_metadata *_metadata,
+		int sandbox_both, int sandbox_parent, int sandbox_child,
+		int expect_ptrace)
+{
+	pid_t child;
+	int status;
+	int pipefd[2];
+
+	ASSERT_EQ(0, pipe(pipefd));
+	if (sandbox_both)
+		apply_null_sandbox(_metadata);
+
+	child = fork();
+	ASSERT_LE(0, child);
+	if (child == 0) {
+		char buf;
+
+		EXPECT_EQ(0, close(pipefd[1]));
+		if (sandbox_child)
+			apply_null_sandbox(_metadata);
+
+		/* test traceme */
+		ASSERT_EQ(expect_ptrace, ptrace(PTRACE_TRACEME));
+		if (expect_ptrace) {
+			ASSERT_EQ(EPERM, errno);
+		} else {
+			ASSERT_EQ(0, raise(SIGSTOP));
+		}
+
+		/* sync */
+		ASSERT_EQ(1, read(pipefd[0], &buf, 1)) {
+			TH_LOG("Failed to read() sync from parent");
+		}
+		ASSERT_EQ('.', buf);
+		_exit(_metadata->passed ? EXIT_SUCCESS : EXIT_FAILURE);
+	}
+
+	EXPECT_EQ(0, close(pipefd[0]));
+	if (sandbox_parent)
+		apply_null_sandbox(_metadata);
+
+	/* test traceme */
+	if (!expect_ptrace) {
+		ASSERT_EQ(child, waitpid(child, &status, 0));
+		ASSERT_EQ(1, WIFSTOPPED(status));
+		ASSERT_EQ(0, ptrace(PTRACE_DETACH, child, NULL, 0));
+	}
+	/* test attach */
+	ASSERT_EQ(expect_ptrace, ptrace(PTRACE_ATTACH, child, NULL, 0));
+	if (expect_ptrace) {
+		ASSERT_EQ(EPERM, errno);
+	} else {
+		ASSERT_EQ(child, waitpid(child, &status, 0));
+		ASSERT_EQ(1, WIFSTOPPED(status));
+		ASSERT_EQ(0, ptrace(PTRACE_CONT, child, NULL, 0));
+	}
+
+	/* sync */
+	ASSERT_EQ(1, write(pipefd[1], ".", 1)) {
+		TH_LOG("Failed to write() sync to child");
+	}
+	ASSERT_EQ(child, waitpid(child, &status, 0));
+	if (WIFSIGNALED(status) || WEXITSTATUS(status))
+		_metadata->passed = 0;
+}
+
+TEST(ptrace_allow_without_sandbox)
+{
+	/* no sandbox */
+	check_ptrace(_metadata, 0, 0, 0, 0);
+}
+
+TEST(ptrace_allow_with_one_sandbox)
+{
+	/* child sandbox */
+	check_ptrace(_metadata, 0, 0, 1, 0);
+}
+
+TEST(ptrace_allow_with_nested_sandbox)
+{
+	/* inherited and child sandbox */
+	check_ptrace(_metadata, 1, 0, 1, 0);
+}
+
+TEST(ptrace_deny_with_parent_sandbox)
+{
+	/* parent sandbox */
+	check_ptrace(_metadata, 0, 1, 0, -1);
+}
+
+TEST(ptrace_deny_with_nested_and_parent_sandbox)
+{
+	/* inherited and parent sandbox */
+	check_ptrace(_metadata, 1, 1, 0, -1);
+}
+
+TEST(ptrace_deny_with_forked_sandbox)
+{
+	/* inherited, parent and child sandbox */
+	check_ptrace(_metadata, 1, 1, 1, -1);
+}
+
+TEST(ptrace_deny_with_sibling_sandbox)
+{
+	/* parent and child sandbox */
+	check_ptrace(_metadata, 0, 1, 1, -1);
+}
+
+TEST_HARNESS_MAIN
-- 
2.14.1
