From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/5] lib: crc32: add test cases for crc32{,c}_combine routines
Date: Wed, 30 Oct 2013 11:50:50 +0100
Message-ID: <1383130252-1515-4-git-send-email-dborkman@redhat.com>
References: <1383130252-1515-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383130252-1515-1-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We already have 100 test cases for crcs itself, so split the test
buffer with a-prio known checksums, and test crc of two blocks
against crc of the whole block for the same results.

Output/result with CONFIG_CRC32_SELFTEST=y:

  [    2.687095] crc32: CRC_LE_BITS = 64, CRC_BE BITS = 64
  [    2.687097] crc32: self tests passed, processed 225944 bytes in 278177 nsec
  [    2.687383] crc32c: CRC_LE_BITS = 64
  [    2.687385] crc32c: self tests passed, processed 225944 bytes in 141708 nsec
  [    7.336771] crc32_combine: 113072 self tests passed
  [   12.050479] crc32c_combine: 113072 self tests passed
  [   17.633089] alg: No test for crc32 (crc32-pclmul)

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: linux-kernel@vger.kernel.org
---
 lib/crc32.c | 72 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 72 insertions(+)

diff --git a/lib/crc32.c b/lib/crc32.c
index 595205c..69dd124 100644
--- a/lib/crc32.c
+++ b/lib/crc32.c
@@ -1031,6 +1031,40 @@ static int __init crc32c_test(void)
 	return 0;
 }
 
+static int __init crc32c_combine_test(void)
+{
+	int i, j;
+	int errors = 0, runs = 0;
+
+	for (i = 0; i < 100; i++) {
+		u32 crc_full;
+
+		crc_full = __crc32c_le(test[i].crc, test_buf + test[i].start,
+				       test[i].length);
+		for (j = 0; j <= test[i].length; ++j) {
+			u32 crc1, crc2;
+			u32 len1 = j, len2 = test[i].length - j;
+
+			crc1 = __crc32c_le(test[i].crc, test_buf +
+					   test[i].start, len1);
+			crc2 = __crc32c_le(0, test_buf + test[i].start +
+					   len1, len2);
+
+			if (!(crc_full == __crc32c_le_combine(crc1, crc2, len2) &&
+			      crc_full == test[i].crc32c_le))
+				errors++;
+			runs++;
+		}
+	}
+
+	if (errors)
+		pr_warn("crc32c_combine: %d/%d self tests failed\n", errors, runs);
+	else
+		pr_info("crc32c_combine: %d self tests passed\n", runs);
+
+	return 0;
+}
+
 static int __init crc32_test(void)
 {
 	int i;
@@ -1090,10 +1124,48 @@ static int __init crc32_test(void)
 	return 0;
 }
 
+static int __init crc32_combine_test(void)
+{
+	int i, j;
+	int errors = 0, runs = 0;
+
+	for (i = 0; i < 100; i++) {
+		u32 crc_full;
+
+		crc_full = crc32_le(test[i].crc, test_buf + test[i].start,
+				    test[i].length);
+		for (j = 0; j <= test[i].length; ++j) {
+			u32 crc1, crc2;
+			u32 len1 = j, len2 = test[i].length - j;
+
+			crc1 = crc32_le(test[i].crc, test_buf +
+					test[i].start, len1);
+			crc2 = crc32_le(0, test_buf + test[i].start +
+					len1, len2);
+
+			if (!(crc_full == crc32_le_combine(crc1, crc2, len2) &&
+			      crc_full == test[i].crc_le))
+				errors++;
+			runs++;
+		}
+	}
+
+	if (errors)
+		pr_warn("crc32_combine: %d/%d self tests failed\n", errors, runs);
+	else
+		pr_info("crc32_combine: %d self tests passed\n", runs);
+
+	return 0;
+}
+
 static int __init crc32test_init(void)
 {
 	crc32_test();
 	crc32c_test();
+
+	crc32_combine_test();
+	crc32c_combine_test();
+
 	return 0;
 }
 
-- 
1.8.3.1
