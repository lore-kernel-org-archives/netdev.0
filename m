From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v7 01/10] selftest: Enhance kselftest_harness.h with a step mechanism
Date: Mon, 21 Aug 2017 02:09:24 +0200
Message-ID: <20170821000933.13024-2-mic@digikod.net>
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
Return-path: <kernel-hardening-return-9523-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170821000933.13024-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This step mechanism may be useful to return an information about the
error without being able to write to TH_LOG_STREAM.

Set _metadata->no_print to true to print this counter.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Shuah Khan <shuah@kernel.org>
Cc: Will Drewry <wad@chromium.org>
Link: https://lkml.kernel.org/r/CAGXu5j+D-FP8Kt9unNOqKrQJP4DYTpmgkJxWykZyrYiVPz3Y3Q@mail.gmail.com
---

This patch is intended to the kselftest tree:
https://lkml.kernel.org/r/20170806232337.4191-1-mic@digikod.net

Changes since v6:
* add the step counter in assert/expect macros and use _metadata to
  enable the counter (suggested by Kees Cook)
---
 tools/testing/selftests/kselftest_harness.h   | 31 ++++++++++++++++++++++-----
 tools/testing/selftests/seccomp/seccomp_bpf.c |  2 +-
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/tools/testing/selftests/kselftest_harness.h b/tools/testing/selftests/kselftest_harness.h
index c56f72e07cd7..850ff6946027 100644
--- a/tools/testing/selftests/kselftest_harness.h
+++ b/tools/testing/selftests/kselftest_harness.h
@@ -51,6 +51,9 @@
 #define __KSELFTEST_HARNESS_H
 
 #define _GNU_SOURCE
+#include <asm/types.h>
+#include <errno.h>
+#include <stdbool.h>
 #include <stdint.h>
 #include <stdio.h>
 #include <stdlib.h>
@@ -555,12 +558,18 @@
  * return while still providing an optional block to the API consumer.
  */
 #define OPTIONAL_HANDLER(_assert) \
-	for (; _metadata->trigger;  _metadata->trigger = __bail(_assert))
+	for (; _metadata->trigger; _metadata->trigger = \
+			__bail(_assert, _metadata->no_print, _metadata->step))
+
+#define __INC_STEP(_metadata) \
+	if (_metadata->passed && _metadata->step < 255) \
+		_metadata->step++;
 
 #define __EXPECT(_expected, _seen, _t, _assert) do { \
 	/* Avoid multiple evaluation of the cases */ \
 	__typeof__(_expected) __exp = (_expected); \
 	__typeof__(_seen) __seen = (_seen); \
+	__INC_STEP(_metadata); \
 	if (!(__exp _t __seen)) { \
 		unsigned long long __exp_print = (uintptr_t)__exp; \
 		unsigned long long __seen_print = (uintptr_t)__seen; \
@@ -576,6 +585,7 @@
 #define __EXPECT_STR(_expected, _seen, _t, _assert) do { \
 	const char *__exp = (_expected); \
 	const char *__seen = (_seen); \
+	__INC_STEP(_metadata); \
 	if (!(strcmp(__exp, __seen) _t 0))  { \
 		__TH_LOG("Expected '%s' %s '%s'.", __exp, #_t, __seen); \
 		_metadata->passed = 0; \
@@ -590,6 +600,8 @@ struct __test_metadata {
 	int termsig;
 	int passed;
 	int trigger; /* extra handler after the evaluation */
+	__u8 step;
+	bool no_print; /* manual trigger when TH_LOG_STREAM is not available */
 	struct __test_metadata *prev, *next;
 };
 
@@ -634,10 +646,13 @@ static inline void __register_test(struct __test_metadata *t)
 	}
 }
 
-static inline int __bail(int for_realz)
+static inline int __bail(int for_realz, bool no_print, __u8 step)
 {
-	if (for_realz)
+	if (for_realz) {
+		if (no_print)
+			_exit(step);
 		abort();
+	}
 	return 0;
 }
 
@@ -655,18 +670,24 @@ void __run_test(struct __test_metadata *t)
 		t->passed = 0;
 	} else if (child_pid == 0) {
 		t->fn(t);
-		_exit(t->passed);
+		/* return the step that failed or 0 */
+		_exit(t->passed ? 0 : t->step);
 	} else {
 		/* TODO(wad) add timeout support. */
 		waitpid(child_pid, &status, 0);
 		if (WIFEXITED(status)) {
-			t->passed = t->termsig == -1 ? WEXITSTATUS(status) : 0;
+			t->passed = t->termsig == -1 ? !WEXITSTATUS(status) : 0;
 			if (t->termsig != -1) {
 				fprintf(TH_LOG_STREAM,
 					"%s: Test exited normally "
 					"instead of by signal (code: %d)\n",
 					t->name,
 					WEXITSTATUS(status));
+			} else if (!t->passed) {
+				fprintf(TH_LOG_STREAM,
+					"%s: Test failed at step #%d\n",
+					t->name,
+					WEXITSTATUS(status));
 			}
 		} else if (WIFSIGNALED(status)) {
 			t->passed = 0;
diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 73f5ea6778ce..4d6f92a9df6b 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -107,7 +107,7 @@ TEST(mode_strict_support)
 	ASSERT_EQ(0, ret) {
 		TH_LOG("Kernel does not support CONFIG_SECCOMP");
 	}
-	syscall(__NR_exit, 1);
+	syscall(__NR_exit, 0);
 }
 
 TEST_SIGNAL(mode_strict_cannot_call_prctl, SIGKILL)
-- 
2.14.1
