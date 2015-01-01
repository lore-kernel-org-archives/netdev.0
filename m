From: Tim Bird <tim.bird@sonymobile.com>
Subject: WIP alternative - was Re: [PATCH v3 14/20] selftests/size: add install
 target to enable test install
Date: Wed, 31 Dec 2014 18:31:16 -0800
Message-ID: <54A4B174.2010501@sonymobile.com>
References: <cover.1419387513.git.shuahkh@osg.samsung.com> <c961f80614b02a2f3c6455518d1f6fabdaf6c7f3.1419387513.git.shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shuah Khan <shuahkh@osg.samsung.com>,
	"mmarek@suse.cz" <mmarek@suse.cz>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"tranmanphong@gmail.com" <tranmanphong@gmail.com>,
	"mpe@ellerman.id.au" <mpe@ellerman.id.au>,
	"cov@codeaurora.org" <cov@codeaurora.org>,
	"dh.herrmann@gmail.com" <dh.herrmann@gmail.com>,
	"hughd@google.com" <hughd@google.com>,
	"bobby.prani@gmail.com" <bobby.prani@gmail.com>,
	"serge.hallyn@ubuntu.com" <serge.hallyn@ubuntu.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"koct9i@gmail.com" <koct9i@gmail.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <c961f80614b02a2f3c6455518d1f6fabdaf6c7f3.1419387513.git.shuahkh@osg.samsung.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/24/2014 08:27 AM, Shuah Khan wrote:
> Add a new make target to enable installing test. This target
> installs test in the kselftest install location and add to the
> kselftest script to run the test. Install target can be run
> only from top level kernel source directory.
> 
> Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
> ---
>  tools/testing/selftests/size/Makefile | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/tools/testing/selftests/size/Makefile b/tools/testing/selftests/size/Makefile
> index 04dc25e..bb7113b 100644
> --- a/tools/testing/selftests/size/Makefile
> +++ b/tools/testing/selftests/size/Makefile
> @@ -1,12 +1,22 @@
>  CC = $(CROSS_COMPILE)gcc
>  
> +TEST_STR = ./get_size || echo get_size selftests: [FAIL]
> +
>  all: get_size
>  
>  get_size: get_size.c
>  	$(CC) -static -ffreestanding -nostartfiles -s $< -o $@
>  
> +install:
> +ifdef INSTALL_KSFT_PATH
> +	install ./get_size $(INSTALL_KSFT_PATH)
> +	@echo "$(TEST_STR)" >> $(KSELFTEST)
> +else
> +	@echo Run make kselftest_install in top level source directory
> +endif
> +
>  run_tests: all
> -	./get_size
> +	@$(TEST_STR)
>  
>  clean:
>  	$(RM) get_size
> 

The install phase is desperately needed for usage of kselftest in
cross-target situations (applicable to almost all embedded).  So this
is great stuff.

I worked a bit on isolating the install stuff to a makefile include file.
This allows simplifying some of the sub-level Makefiles a bit, and allowing
control of some of the install and run logic in less places.

This is still a work in progress, but before I got too far along, I wanted
to post it for people to provide feedback.  A couple of problems cropped
up that are worth discussing, IMHO.

1) I think it should be a requirement that each test has a single
"main" program to execute to run the tests.  If multiple tests are supported
or more flexibility is desired for additional arguments, or that sort of
thing, then that's fine, but the automated script builder should be able
to run just a single program or script to have things work.  This also
makes things more consistent.  In the case of the firmware test, I created
a single fw_both.sh script to do this, instead of having two separate
blocks in the kselftest.sh script.

2) I've added a CROSS_INSTALL variable, which can call an arbitrary program
to place files on the target system (rather than just calling 'install').
In my case, I'd use my own 'ttc cp' command, which I can extend as necessary
to put things on a remote machine.  This works for a single directory,
but things get dicier with sub-directory trees full of files (like
the ftrace test uses.)

If additional items need to be installed to the target, then maybe a setup
program should be used, rather than just copying files.

3) Some of the scripts were using /bin/bash to execute them, rather
than rely on the interpreter line in the script itself (and having
the script have executable privileges).  Is there a reason for this?
I modified a few scripts to be executable, and got rid of the
explicit execution with /bin/bash.

The following is just a start...  Let me know if this direction looks
OK, and I'll finish this up.  The main item to look at is
kselftest.include file.  Note that these patches are based on Shuah's
series - but if you want to use these ideas I can rebase them onto
mainline, and break them out per test sub-level like Shuah did.


Let me know what you think.
>From 14164fd3117c97799a050f8cf791dedc93aa5e82 Mon Sep 17 00:00:00 2001
From: Tim Bird <tim.bird@sonymobile.com>
Date: Wed, 31 Dec 2014 18:04:08 -0800
Subject: [PATCH] Switch to using an include file for common kselftest_install
 actions

---
 tools/testing/selftests/cpu-hotplug/Makefile       | 15 +++-------
 .../selftests/cpu-hotplug/cpu-on-off-test.sh       |  0
 tools/testing/selftests/efivarfs/Makefile          | 21 ++++----------
 tools/testing/selftests/efivarfs/efivarfs.sh       |  0
 tools/testing/selftests/firmware/Makefile          | 32 ++++------------------
 tools/testing/selftests/firmware/fw_both.sh        | 13 +++++++++
 tools/testing/selftests/kselftest.include          | 26 ++++++++++++++++++
 tools/testing/selftests/size/Makefile              | 19 +++----------
 9 files changed, 60 insertions(+), 69 deletions(-)
 mode change 100644 => 100755 tools/testing/selftests/cpu-hotplug/cpu-on-off-test.sh
 mode change 100644 => 100755 tools/testing/selftests/efivarfs/efivarfs.sh
 create mode 100755 tools/testing/selftests/firmware/fw_both.sh
 create mode 100644 tools/testing/selftests/kselftest.include

diff --git a/tools/testing/selftests/cpu-hotplug/Makefile b/tools/testing/selftests/cpu-hotplug/Makefile
index c9e15ee..d2e540d 100644
--- a/tools/testing/selftests/cpu-hotplug/Makefile
+++ b/tools/testing/selftests/cpu-hotplug/Makefile
@@ -1,18 +1,11 @@
-TEST_STR=/bin/bash ./cpu-on-off-test.sh || echo cpu-hotplug selftests: [FAIL]
+TEST_TITLE = cpu-hotplug
+TEST_MAIN_PROG = cpu-on-off-test.sh
 
 all:
 
-install:
-ifdef INSTALL_KSFT_PATH
-	install ./cpu-on-off-test.sh $(INSTALL_KSFT_PATH)/cpu-on-off-test.sh
-	@echo "$(TEST_STR)" >> $(KSELFTEST)
-else
-	@echo Run make kselftest_install in top level source directory
-endif
-
-run_tests:
-	@$(TEST_STR)
+include ../kselftest.include
 
+# use -a to get all tests
 run_full_test:
 	@/bin/bash ./cpu-on-off-test.sh -a || echo "cpu-hotplug selftests: [FAIL]"
 
diff --git a/tools/testing/selftests/cpu-hotplug/cpu-on-off-test.sh b/tools/testing/selftests/cpu-hotplug/cpu-on-off-test.sh
old mode 100644
new mode 100755
diff --git a/tools/testing/selftests/efivarfs/Makefile b/tools/testing/selftests/efivarfs/Makefile
index aaf404b..8d48e9c 100644
--- a/tools/testing/selftests/efivarfs/Makefile
+++ b/tools/testing/selftests/efivarfs/Makefile
@@ -1,24 +1,15 @@
-CC = $(CROSS_COMPILE)gcc
-CFLAGS = -Wall
+TEST_TITLE = efivarfs
+TEST_MAIN_PROG = efivarfs.sh
 
-test_objs = open-unlink create-read
+CFLAGS = -Wall
 
-TEST_STR = /bin/bash ./efivarfs.sh || echo efivarfs selftests: [FAIL]
+TEST_PROGS = open-unlink create-read
 
 all:
 	gcc open-unlink.c -o open-unlink
 	gcc create-read.c -o create-read
 
-install:
-ifdef INSTALL_KSFT_PATH
-	install ./efivarfs.sh $(test_objs) $(INSTALL_KSFT_PATH)
-	@echo "$(TEST_STR)" >> $(KSELFTEST)
-else
-	@echo Run make kselftest_install in top level source directory
-endif
-
-run_tests: all
-	@$(TEST_STR)
+include ../kselftest.include
 
 clean:
-	rm -f $(test_objs)
+	rm -f $(TEST_PROGS)
diff --git a/tools/testing/selftests/efivarfs/efivarfs.sh b/tools/testing/selftests/efivarfs/efivarfs.sh
old mode 100644
new mode 100755
diff --git a/tools/testing/selftests/firmware/Makefile b/tools/testing/selftests/firmware/Makefile
index 7ac1cf3..b576308 100644
--- a/tools/testing/selftests/firmware/Makefile
+++ b/tools/testing/selftests/firmware/Makefile
@@ -1,36 +1,14 @@
 # Makefile for firmware loading selftests
+TEST_MAIN_PROG = fw_both.sh
+TEST_TITLE = firmware
+TEST_FILES = ./fw_filesystem.sh ./fw_userhelper.sh
 
 # No binaries, but make sure arg-less "make" doesn't trigger "run_tests"
-
-__fw_filesystem:
-fw_filesystem  = if /bin/sh ./fw_filesystem.sh ; then
-fw_filesystem += echo fw_filesystem: ok;
-fw_filesystem += else echo fw_filesystem: [FAIL];
-fw_filesystem += fi
-
-__fw_userhelper:
-fw_userhelper  = if /bin/sh ./fw_userhelper.sh ; then
-fw_userhelper += echo fw_userhelper: ok;
-fw_userhelper += else
-fw_userhelper += echo fw_userhelper: [FAIL];
-fw_userhelper += fi
-
 all:
 
-install:
-ifdef INSTALL_KSFT_PATH
-	install ./fw_filesystem.sh ./fw_userhelper.sh $(INSTALL_KSFT_PATH)
-	@echo "$(fw_filesystem)" >> $(KSELFTEST)
-	@echo "$(fw_userhelper)" >> $(KSELFTEST)
-else
-	@echo Run make kselftest_install in top level source directory
-endif
-
-run_tests:
-	@$(fw_filesystem)
-	@$(fw_userhelper)
+include ../kselftest.include
 
 # Nothing to clean up.
 clean:
 
-.PHONY: all clean run_tests fw_filesystem fw_userhelper
+.PHONY: all clean run_tests
diff --git a/tools/testing/selftests/firmware/fw_both.sh b/tools/testing/selftests/firmware/fw_both.sh
new file mode 100755
index 0000000..fb7fa8d
--- /dev/null
+++ b/tools/testing/selftests/firmware/fw_both.sh
@@ -0,0 +1,13 @@
+#!/bin/sh
+
+if /bin/sh ./fw_filesystem.sh ; then
+	echo "fw_filesystem: ok";
+else
+	echo "fw_filesystem: [FAIL]";
+fi
+
+if /bin/sh ./fw_userhelper.sh ; then
+	echo "fw_userhelper: ok";
+else
+	echo "fw_userhelper: [FAIL]";
+fi
diff --git a/tools/testing/selftests/kselftest.include b/tools/testing/selftests/kselftest.include
new file mode 100644
index 0000000..7020a82
--- /dev/null
+++ b/tools/testing/selftests/kselftest.include
@@ -0,0 +1,26 @@
+# this make include script expects the following variables to be set:
+#  TEST_MAIN_PROG - a single program to invoke to run the test
+#  TEST_TITLE - the title of the test
+#  TEST_FILES - other files that should be copied to the testing directory
+#  INSTALL_KSFT_PATH - where to put test programs
+#  KSELFTEST - the name of the generated script (which calls the sub-tests)
+#  the 'all' target, which makes sure everything is built
+
+# this file defines the 'install' and 'run_tests' targets
+
+CC = $(CROSS_COMPILE)gcc
+INSTALL = $(CROSS_INSTALL)install
+export INSTALL
+
+TEST_STR = ./$(TEST_MAIN_PROG) || echo $(TEST_TITLE) selftests: [FAIL]
+
+install:
+ifdef INSTALL_KSFT_PATH
+	$(INSTALL) ./$(TEST_MAIN_PROG) $(TEST_FILES) $(INSTALL_KSFT_PATH)
+	@echo "$(TEST_STR)" >> $(KSELFTEST)
+else
+	@echo Run make kselftest_install in the top level source directory
+endif
+
+run_tests: all
+	@$(TEST_STR)
diff --git a/tools/testing/selftests/size/Makefile b/tools/testing/selftests/size/Makefile
index bb7113b..c88819a 100644
--- a/tools/testing/selftests/size/Makefile
+++ b/tools/testing/selftests/size/Makefile
@@ -1,22 +1,11 @@
-CC = $(CROSS_COMPILE)gcc
+TEST_MAIN_PROG = get_size
 
-TEST_STR = ./get_size || echo get_size selftests: [FAIL]
+all: $(TEST_MAIN_PROG)
 
-all: get_size
+include ../kselftest.include
 
 get_size: get_size.c
 	$(CC) -static -ffreestanding -nostartfiles -s $< -o $@
 
-install:
-ifdef INSTALL_KSFT_PATH
-	install ./get_size $(INSTALL_KSFT_PATH)
-	@echo "$(TEST_STR)" >> $(KSELFTEST)
-else
-	@echo Run make kselftest_install in top level source directory
-endif
-
-run_tests: all
-	@$(TEST_STR)
-
 clean:
-	$(RM) get_size
+	$(RM) $(TEST_MAIN_PROG)
-- 
1.8.2.2


