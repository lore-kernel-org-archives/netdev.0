From: Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Subject: [PATCH 4/6] kbuild: add a new kselftest_install make target to install selftests
Date: Fri,  9 Jan 2015 20:06:13 +1100
Message-ID: <1420794375-31881-4-git-send-email-mpe@ellerman.id.au>
References: <1420794375-31881-1-git-send-email-mpe@ellerman.id.au>
Cc: mmarek-AlSwsSmVLrQ@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tim.bird-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org,
	josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420794375-31881-1-git-send-email-mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a new make target to install kernel selftests. This new target will
build and install selftests.

The default is just $(objtree)/selftests. This is preferable to
something based on $(INSTALL_MOD_PATH) (which defaults to /), as it
allows a normal user to install the tests. This is similar to the
default behaviour of make headers_install.

Therefore the most basic usage is:

$ make kselftests_install
$ ./selftests/all.sh

To install elsewhere use:

$ make kselftests_install INSTALL_SELFTESTS_PATH=/some/where
$ /some/where/all.sh

Signed-off-by: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Signed-off-by: Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>
---
 Makefile                         | 13 ++++++++++++-
 tools/testing/selftests/Makefile |  1 +
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/Makefile b/Makefile
index eb4eca56843a..c186a928d8be 100644
--- a/Makefile
+++ b/Makefile
@@ -1072,12 +1072,20 @@ headers_check: headers_install
 	$(Q)$(MAKE) $(hdr-inst)=arch/$(hdr-arch)/include/uapi/asm $(hdr-dst) HDRCHECK=1
 
 # ---------------------------------------------------------------------------
-# Kernel selftest
+# Kernel selftest targets
+
+# Default base path for kselftest install
+INSTALL_SELFTESTS_PATH = $(abspath $(objtree)/selftests)
 
 PHONY += kselftest
 kselftest:
 	$(Q)$(MAKE) -C tools/testing/selftests run_tests
 
+# Kernel selftest install
+PHONY += kselftest_install
+kselftest_install:
+	$(Q)$(MAKE) -C tools/testing/selftests INSTALL_PATH=$(INSTALL_SELFTESTS_PATH) install
+
 # ---------------------------------------------------------------------------
 # Modules
 
@@ -1286,6 +1294,9 @@ help:
 	@echo  '                    Build, install, and boot kernel before'
 	@echo  '                    running kselftest on it'
 	@echo  ''
+	@echo  '  kselftest_install - Install selftests to INSTALL_SELFTESTS_PATH'
+	@echo  '                      default: $(INSTALL_SELFTESTS_PATH)'
+	@echo  ''
 	@echo  'Kernel packaging:'
 	@$(MAKE) $(build)=$(package-dir) help
 	@echo  ''
diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 4f2849b5ff77..a2345f4512bb 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -62,6 +62,7 @@ ifdef INSTALL_PATH
 
 	@# Ask all targets to emit their test scripts
 	echo "#!/bin/bash\n\n" > $(ALL_SCRIPT)
+	echo "cd \$$(dirname \$$0)" >> $(ALL_SCRIPT)
 	echo "ROOT=\$$PWD\n" >> $(ALL_SCRIPT)
 
 	for TARGET in $(TARGETS); do \
-- 
2.1.0
