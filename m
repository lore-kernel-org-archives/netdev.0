From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 5/5] samples/bpf: like LLC also verify and allow
 redefining CLANG command
Date: Tue, 26 Apr 2016 18:27:32 +0200
Message-ID: <20160426162732.22962.73140.stgit@firesoul>
References: <20160426162650.22962.20516.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, bblanco@plumgrid.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	naveen.n.rao@linux.vnet.ibm.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53675 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149AbcDZQ1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 12:27:34 -0400
In-Reply-To: <20160426162650.22962.20516.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users are likely to manually compile both LLVM 'llc' and 'clang'
tools.  Thus, also allow redefining CLANG and verify command exist.

Makefile implementation wise, the target that verify the command have
been generalized.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/Makefile   |   23 +++++++++++++----------
 samples/bpf/README.rst |    6 +++---
 2 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index dd63521832d8..c02ea9d2a248 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -81,9 +81,10 @@ HOSTLOADLIBES_spintest += -lelf
 HOSTLOADLIBES_map_perf_test += -lelf -lrt
 HOSTLOADLIBES_test_overhead += -lelf -lrt
 
-# Allows pointing LLC to a LLVM backend with bpf support, redefine on cmdline:
-#  make samples/bpf/ LLC=~/git/llvm/build/bin/llc
+# Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
+#  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
 LLC ?= llc
+CLANG ?= clang
 
 # Trick to allow make to be run from this directory
 all:
@@ -94,15 +95,17 @@ clean:
 	@rm -f *~
 
 # Verify LLVM compiler is available and bpf target is supported
-.PHONY: verify_cmd_llc verify_target_bpf
+.PHONY: verify_cmd_llc verify_target_bpf $(CLANG) $(LLC)
 
-verify_cmd_llc:
-	@if ! (which "${LLC}" > /dev/null 2>&1); then \
-		echo "*** ERROR: Cannot find LLVM tool 'llc' (${LLC})" ;\
-		exit 1; \
-	else true; fi
+verify_cmds: $(CLANG) $(LLC)
+	@for TOOL in $^ ; do \
+		if ! (which "$${TOOL}" > /dev/null 2>&1); then \
+			echo "*** ERROR: Cannot find LLVM tool $${TOOL}" ;\
+			exit 1; \
+		else true; fi; \
+	done
 
-verify_target_bpf: verify_cmd_llc
+verify_target_bpf: verify_cmds
 	@if ! (${LLC} -march=bpf -mattr=help > /dev/null 2>&1); then \
 		echo "*** ERROR: LLVM (${LLC}) does not support 'bpf' target" ;\
 		echo "   NOTICE: LLVM version >= 3.7.1 required" ;\
@@ -115,6 +118,6 @@ $(src)/*.c: verify_target_bpf
 # But, there is no easy way to fix it, so just exclude it since it is
 # useless for BPF samples.
 $(obj)/%.o: $(src)/%.c
-	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
+	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
 		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
 		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
index 1ec4b08a7b40..74897dbe6458 100644
--- a/samples/bpf/README.rst
+++ b/samples/bpf/README.rst
@@ -73,8 +73,8 @@ Quick sniplet for manually compiling LLVM and clang
  $ cmake .. -DLLVM_TARGETS_TO_BUILD="BPF;X86"
  $ make -j $(getconf _NPROCESSORS_ONLN)
 
-It is also possible to point make to the newly compile 'llc' command
-via redefining LLC on the make command line::
+It is also possible to point make to the newly compile 'llc' or
+'clang' command via redefining LLC or CLANG on the make command line::
 
- make samples/bpf/ LLC=~/git/llvm/build/bin/llc
+ make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
 
