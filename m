From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH net] selftests/bpf: fix broken build, take 2
Date: Sun, 19 Mar 2017 00:42:23 -0700
Message-ID: <1489909343-3734-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33333 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdCSHmc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 03:42:32 -0400
Received: by mail-pf0-f196.google.com with SMTP id p189so7813985pfp.0
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 00:42:32 -0700 (PDT)
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

Tested on Ubuntu 16.04.2.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 tools/testing/selftests/bpf/Makefile | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 67531f4..a61efd9 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,22 +1,21 @@
 LIBDIR := ../../../lib
 BPFOBJ := $(LIBDIR)/bpf/bpf.o
 
-CFLAGS += -Wall -O2 -lcap -I../../../include/uapi -I$(LIBDIR) $(BPFOBJ)
+CFLAGS += -Wall -O2 -I../../../include/uapi -I$(LIBDIR)
+LDLIBS += -lcap
 
 TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map
 
 TEST_PROGS := test_kmod.sh
 
-all: $(TEST_GEN_PROGS)
+include ../lib.mk
+
+$(TEST_GEN_PROGS): $(BPFOBJ)
 
-.PHONY: all clean force
+.PHONY: force
 
 # force a rebuild of BPFOBJ when its dependencies are updated
 force:
 
 $(BPFOBJ): force
 	$(MAKE) -C $(dir $(BPFOBJ))
-
-$(test_objs): $(BPFOBJ)
-
-include ../lib.mk
-- 
2.7.4
