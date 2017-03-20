From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH v2 net] selftests/bpf: fix broken build, take 2
Date: Sun, 19 Mar 2017 23:03:14 -0700
Message-ID: <1489989794-6859-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36056 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752945AbdCTGLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 02:11:45 -0400
Received: by mail-pg0-f67.google.com with SMTP id 81so10025073pgh.3
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 23:11:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merge of 'linux-kselftest-4.11-rc1':

1. Partially removed use of 'test_objs' target, breaking force rebuild of
BPFOBJ, introduced in commit d498f8719a09 ("bpf: Rebuild bpf.o for any
dependency update").

  Update target so dependency on BPFOBJ is restored.

2. Introduced commit 2047f1d8ba28 ("selftests: Fix the .c linking rule")
which fixes order of LDLIBS.

  Commit d02d8986a768 ("bpf: Always test unprivileged programs") added
libcap dependency into CFLAGS. Use LDLIBS instead to fix linking of
test_verifier.

3. Introduced commit d83c3ba0b926 ("selftests: Fix selftests build to
just build, not run tests").

  Reordering the Makefile allows us to remove the 'all' target.

Tested both:
    selftests/bpf$ make
and
    selftests$ make TARGETS=bpf
on Ubuntu 16.04.2.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
v1:
  - Fixed build from selftests/bpf/.
v2:
  - Fixed build from selftests/ also.

 tools/testing/selftests/bpf/Makefile | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 67531f4..6a1ad58 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,22 +1,23 @@
 LIBDIR := ../../../lib
-BPFOBJ := $(LIBDIR)/bpf/bpf.o
+BPFDIR := $(LIBDIR)/bpf
 
-CFLAGS += -Wall -O2 -lcap -I../../../include/uapi -I$(LIBDIR) $(BPFOBJ)
+CFLAGS += -Wall -O2 -I../../../include/uapi -I$(LIBDIR)
+LDLIBS += -lcap
 
 TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map
 
 TEST_PROGS := test_kmod.sh
 
-all: $(TEST_GEN_PROGS)
+include ../lib.mk
+
+BPFOBJ := $(OUTPUT)/bpf.o
+
+$(TEST_GEN_PROGS): $(BPFOBJ)
 
-.PHONY: all clean force
+.PHONY: force
 
 # force a rebuild of BPFOBJ when its dependencies are updated
 force:
 
 $(BPFOBJ): force
-	$(MAKE) -C $(dir $(BPFOBJ))
-
-$(test_objs): $(BPFOBJ)
-
-include ../lib.mk
+	$(MAKE) -C $(BPFDIR) OUTPUT=$(OUTPUT)/
-- 
2.7.4
