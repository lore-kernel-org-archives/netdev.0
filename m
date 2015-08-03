From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH 4/6] test_bpf: add module parameters to filter the tests to run.
Date: Mon,  3 Aug 2015 16:02:06 +0200
Message-ID: <1438610528-14245-5-git-send-email-nschichan@freebox.fr>
References: <1438610528-14245-1-git-send-email-nschichan@freebox.fr>
Cc: Nicolas Schichan <nschichan@freebox.fr>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:53771 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753583AbbHCOCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Aug 2015 10:02:37 -0400
In-Reply-To: <1438610528-14245-1-git-send-email-nschichan@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When developping on the interpreter or a particular JIT, it can be
insteresting to restrict the test list to a specific test or a
particular range of tests.

This patch adds the following module parameters to the test_bpf module:

* test_name=<string>: only the specified named test will be run.

* test_id=<number>: only the test with the specified id will be run
  (see the output of test_pbf without parameters to get the test id).

* test_range=<number>,<number>: only the tests with IDs in the
  specified id range are run (see the output of test_pbf without
  parameters to get the test ids).

Any invalid range, test id or test name will result in -EINVAL being
returned and no tests being run.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 lib/test_bpf.c | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 73 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index f5606fb..abd0507 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4870,10 +4870,72 @@ static int run_one(const struct bpf_prog *fp, struct bpf_test *test)
 	return err_cnt;
 }
 
+static char test_name[64];
+module_param_string(test_name, test_name, sizeof(test_name), 0);
+
+static int test_id = -1;
+module_param(test_id, int, 0);
+
+static int test_range[2] = { -1, -1 };
+module_param_array(test_range, int, NULL, 0);
+
+static __init int find_test_index(const char *test_name)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(tests); i++) {
+		if (!strcmp(tests[i].descr, test_name))
+			return i;
+	}
+	return -1;
+}
+
 static __init int prepare_bpf_tests(void)
 {
 	int i;
 
+	if (test_id >= 0) {
+		/*
+		 * if a test_id was specified, use test_range to
+		 * conver only that test.
+		 */
+		if (test_id >= ARRAY_SIZE(tests)) {
+			pr_err("test_bpf: invalid test_id specified.\n");
+			return -EINVAL;
+		}
+
+		test_range[0] = test_id;
+		test_range[1] = test_id;
+	} else if (test_range[0] >= 0) {
+		/*
+		 * check that the supplied test_range is valid.
+		 */
+		if (test_range[0] >= ARRAY_SIZE(tests) ||
+		    test_range[1] >= ARRAY_SIZE(tests)) {
+			pr_err("test_bpf: test_range is out of bound.\n");
+			return -EINVAL;
+		}
+
+		if (test_range[1] < test_range[0]) {
+			pr_err("test_bpf: test_range is ending before it starts.\n");
+			return -EINVAL;
+		}
+	} else if (*test_name) {
+		/*
+		 * if a test_name was specified, find it and setup
+		 * test_range to cover only that test.
+		 */
+		int idx = find_test_index(test_name);
+
+		if (idx < 0) {
+			pr_err("test_bpf: no test named '%s' found.\n",
+			       test_name);
+			return -EINVAL;
+		}
+		test_range[0] = idx;
+		test_range[1] = idx;
+	}
+
 	for (i = 0; i < ARRAY_SIZE(tests); i++) {
 		if (tests[i].fill_helper &&
 		    tests[i].fill_helper(&tests[i]) < 0)
@@ -4893,6 +4955,14 @@ static __init void destroy_bpf_tests(void)
 	}
 }
 
+static bool exclude_test(int test_id)
+{
+	if (test_range[0] >= 0 &&
+	    (test_id < test_range[0] || test_id > test_range[1]))
+		return true;
+	return false;
+}
+
 static __init int test_bpf(void)
 {
 	int i, err_cnt = 0, pass_cnt = 0;
@@ -4902,6 +4972,9 @@ static __init int test_bpf(void)
 		struct bpf_prog *fp;
 		int err;
 
+		if (exclude_test(i))
+			continue;
+
 		pr_info("#%d %s ", i, tests[i].descr);
 
 		fp = generate_filter(i, &err);
-- 
1.9.1
