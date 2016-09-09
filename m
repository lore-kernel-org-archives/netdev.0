From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 9/9] selftests: Update vDSO Makefile to work under selftests
Date: Fri,  9 Sep 2016 16:22:50 -0600
Message-ID: <2034b315d4f40df479ba7ada1580a22fd91a75b4.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update vDSO Makefile to work under selftests. vDSO will not be run as part
of selftests suite and will not included in install targets. They can be
built separately for now.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/vDSO/Makefile | 29 ++++++++++++++++-------------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/tools/testing/selftests/vDSO/Makefile b/tools/testing/selftests/vDSO/Makefile
index b12e987..706b68b 100644
--- a/tools/testing/selftests/vDSO/Makefile
+++ b/tools/testing/selftests/vDSO/Makefile
@@ -1,17 +1,20 @@
 ifndef CROSS_COMPILE
-# vdso_test won't build for glibc < 2.16, so disable it
-# hostprogs-y := vdso_test
-hostprogs-$(CONFIG_X86) := vdso_standalone_test_x86
-vdso_standalone_test_x86-objs := vdso_standalone_test_x86.o parse_vdso.o
-vdso_test-objs := parse_vdso.o vdso_test.o
-
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
-
-HOSTCFLAGS := -I$(objtree)/usr/include -std=gnu99
-HOSTCFLAGS_vdso_standalone_test_x86.o := -fno-asynchronous-unwind-tables -fno-stack-protector
-HOSTLOADLIBES_vdso_standalone_test_x86 := -nostdlib
+CFLAGS := -std=gnu99
+CFLAGS_vdso_standalone_test_x86 := -nostdlib -fno-asynchronous-unwind-tables -fno-stack-protector
 ifeq ($(CONFIG_X86_32),y)
-HOSTLOADLIBES_vdso_standalone_test_x86 += -lgcc_s
+LDLIBS += -lgcc_s
 endif
+
+TEST_PROGS := vdso_test vdso_standalone_test_x86
+
+all: $(TEST_PROGS)
+vdso_test: parse_vdso.c vdso_test.c
+vdso_standalone_test_x86: vdso_standalone_test_x86.c parse_vdso.c
+	$(CC) $(CFLAGS) $(CFLAGS_vdso_standalone_test_x86) \
+		vdso_standalone_test_x86.c parse_vdso.c \
+		-o vdso_standalone_test_x86
+
+include ../lib.mk
+clean:
+	rm -fr $(TEST_PROGS)
 endif
-- 
2.7.4
