From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] test_bpf: indicate whether bpf prog got jited in test suite
Date: Thu, 30 Apr 2015 16:17:27 +0200
Message-ID: <c031528c3effbdb3a3a566b0a8d6f48f3e4ad3be.1430403176.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Alexei Starovoitov <ast@plumgrid.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39411 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbD3ORb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 10:17:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think this is useful to verify whether a filter could be JITed or
not in case of bpf_prog_enable >= 1, which otherwise the test suite
doesn't tell besides taking a good peek at the performance numbers.

Nicolas Schichan reported a bug in the ARM JIT compiler that rejected
and waved the filter to the interpreter although it shouldn't have.
Nevertheless, the test passes as expected, but such information is
not visible.

It's i.e. useful for the remaining classic JITs, but also for
implementing remaining opcodes that are not yet present in eBPF JITs
(e.g. ARM64 waves some of them to the interpreter). This minor patch
allows to grep through dmesg to find those accordingly, but also
provides a total summary, i.e.: [<X>/53 JIT'ed]

  # echo 1 > /proc/sys/net/core/bpf_jit_enable
  # insmod lib/test_bpf.ko
  # dmesg | grep "jited:0"

dmesg example on the ARM issue with JIT rejection:

[...]
[   67.925387] test_bpf: #2 ADD_SUB_MUL_K jited:1 24 PASS
[   67.930889] test_bpf: #3 DIV_MOD_KX jited:0 794 PASS
[   67.943940] test_bpf: #4 AND_OR_LSH_K jited:1 20 20 PASS
[...]

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Nicolas Schichan <nschichan@freebox.fr>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 lib/test_bpf.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 80d78c5..f2c23ff 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1990,6 +1990,7 @@ static int run_one(const struct bpf_prog *fp, struct bpf_test *test)
 static __init int test_bpf(void)
 {
 	int i, err_cnt = 0, pass_cnt = 0;
+	int jit_cnt = 0, run_cnt = 0;
 
 	for (i = 0; i < ARRAY_SIZE(tests); i++) {
 		struct bpf_prog *fp;
@@ -2006,6 +2007,13 @@ static __init int test_bpf(void)
 
 			return err;
 		}
+
+		pr_cont("jited:%u ", fp->jited);
+
+		run_cnt++;
+		if (fp->jited)
+			jit_cnt++;
+
 		err = run_one(fp, &tests[i]);
 		release_filter(fp, i);
 
@@ -2018,7 +2026,9 @@ static __init int test_bpf(void)
 		}
 	}
 
-	pr_info("Summary: %d PASSED, %d FAILED\n", pass_cnt, err_cnt);
+	pr_info("Summary: %d PASSED, %d FAILED, [%d/%d JIT'ed]\n",
+		pass_cnt, err_cnt, jit_cnt, run_cnt);
+
 	return err_cnt ? -EINVAL : 0;
 }
 
-- 
1.9.3
