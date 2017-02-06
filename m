From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v2 3/3] bpf: Always test unprivileged programs
Date: Mon,  6 Feb 2017 21:52:25 +0100
Message-ID: <20170206205225.32233-3-mic@digikod.net>
References: <20170206205225.32233-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206205225.32233-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If selftests are run as root, then execute the unprivileged checks as
well. This switch from 240 to 364 tests.

The test numbers are suffixed with "/u" when executed as unprivileged or
with "/p" when executed as privileged.

The geteuid() check is replaced with a capability check.

Handling capabilities requires the libcap dependency.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Shuah Khan <shuah@kernel.org>
---
 tools/testing/selftests/bpf/Makefile        |  2 +-
 tools/testing/selftests/bpf/test_verifier.c | 68 ++++++++++++++++++++++++++---
 2 files changed, 64 insertions(+), 6 deletions(-)

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index c470c7301636..f3d65ad53494 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,4 +1,4 @@
-CFLAGS += -Wall -O2 -I../../../include/uapi
+CFLAGS += -Wall -O2 -lcap -I../../../include/uapi
 
 test_objs = test_verifier test_tag test_maps test_lru_map test_lpm_map
 
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 0d0912c7f03c..6a82e7db2c20 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -16,6 +16,7 @@
 #include <stdbool.h>
 #include <sched.h>
 
+#include <sys/capability.h>
 #include <sys/resource.h>
 
 #include <linux/unistd.h>
@@ -4496,6 +4497,55 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 	goto close_fds;
 }
 
+static bool is_admin(void)
+{
+	cap_t caps;
+	cap_flag_value_t sysadmin = CAP_CLEAR;
+	const cap_value_t cap_val = CAP_SYS_ADMIN;
+
+	if (!CAP_IS_SUPPORTED(CAP_SETFCAP)) {
+		perror("cap_get_flag");
+		return false;
+	}
+	caps = cap_get_proc();
+	if (!caps) {
+		perror("cap_get_proc");
+		return false;
+	}
+	if (cap_get_flag(caps, cap_val, CAP_EFFECTIVE, &sysadmin))
+		perror("cap_get_flag");
+	if (cap_free(caps))
+		perror("cap_free");
+	return (sysadmin == CAP_SET);
+}
+
+static int set_admin(bool admin)
+{
+	cap_t caps;
+	const cap_value_t cap_val = CAP_SYS_ADMIN;
+	int ret = -1;
+
+	caps = cap_get_proc();
+	if (!caps) {
+		perror("cap_get_proc");
+		return -1;
+	}
+	if (cap_set_flag(caps, CAP_EFFECTIVE, 1, &cap_val,
+				admin ? CAP_SET : CAP_CLEAR)) {
+		perror("cap_set_flag");
+		goto out;
+	}
+	if (cap_set_proc(caps)) {
+		perror("cap_set_proc");
+		goto out;
+	}
+	ret = 0;
+out:
+	if (cap_free(caps))
+		perror("cap_free");
+	return ret;
+}
+
 static int do_test(bool unpriv, unsigned int from, unsigned int to)
 {
 	int i, passes = 0, errors = 0;
@@ -4506,11 +4556,19 @@ static int do_test(bool unpriv, unsigned int from, unsigned int to)
 		/* Program types that are not supported by non-root we
 		 * skip right away.
 		 */
-		if (unpriv && test->prog_type)
-			continue;
+		if (!test->prog_type) {
+			if (!unpriv)
+				set_admin(false);
+			printf("#%d/u %s ", i, test->descr);
+			do_test_single(test, true, &passes, &errors);
+			if (!unpriv)
+				set_admin(true);
+		}
 
-		printf("#%d %s ", i, test->descr);
-		do_test_single(test, unpriv, &passes, &errors);
+		if (!unpriv) {
+			printf("#%d/p %s ", i, test->descr);
+			do_test_single(test, false, &passes, &errors);
+		}
 	}
 
 	printf("Summary: %d PASSED, %d FAILED\n", passes, errors);
@@ -4522,7 +4580,7 @@ int main(int argc, char **argv)
 	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
 	struct rlimit rlim = { 1 << 20, 1 << 20 };
 	unsigned int from = 0, to = ARRAY_SIZE(tests);
-	bool unpriv = geteuid() != 0;
+	bool unpriv = !is_admin();
 
 	if (argc == 3) {
 		unsigned int l = atoi(argv[argc - 2]);
-- 
2.11.0
