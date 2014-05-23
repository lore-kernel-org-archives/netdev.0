From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/5] net: filter: improve test case framework
Date: Fri, 23 May 2014 18:44:00 +0200
Message-ID: <1400863441-3711-5-git-send-email-dborkman@redhat.com>
References: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752839AbaEWQoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 12:44:14 -0400
In-Reply-To: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simplifies and refactors the test case code a
bit and also adds a summary of all test that passed or
failed in the kernel log, so that it's easier to spot if
something has failed.

Future work could further extend the test framework to also
support different input 'stimuli' i.e. related structures
to seccomp.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 lib/test_bpf.c | 388 ++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 233 insertions(+), 155 deletions(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index e03991e..da34e33 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -22,12 +22,14 @@
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
 
+/* General test specific settings */
 #define MAX_SUBTESTS	3
+#define MAX_TESTRUNS	10000
 #define MAX_DATA	128
 #define MAX_INSNS	512
 #define MAX_K		0xffffFFFF
 
-/* define few constants used to init test 'skb' */
+/* Few constants used to init test 'skb' */
 #define SKB_TYPE	3
 #define SKB_MARK	0x1234aaaa
 #define SKB_HASH	0x1234aaab
@@ -36,18 +38,29 @@
 #define SKB_DEV_IFINDEX	577
 #define SKB_DEV_TYPE	588
 
-/* redefine REGs to make tests less verbose */
-#define R0 BPF_REG_0
-#define R1 BPF_REG_1
-#define R2 BPF_REG_2
-#define R3 BPF_REG_3
-#define R4 BPF_REG_4
-#define R5 BPF_REG_5
-#define R6 BPF_REG_6
-#define R7 BPF_REG_7
-#define R8 BPF_REG_8
-#define R9 BPF_REG_9
-#define R10 BPF_REG_10
+/* Redefine REGs to make tests less verbose */
+#define R0		BPF_REG_0
+#define R1		BPF_REG_1
+#define R2		BPF_REG_2
+#define R3		BPF_REG_3
+#define R4		BPF_REG_4
+#define R5		BPF_REG_5
+#define R6		BPF_REG_6
+#define R7		BPF_REG_7
+#define R8		BPF_REG_8
+#define R9		BPF_REG_9
+#define R10		BPF_REG_10
+
+/* Flags that can be passed to test cases */
+#define FLAG_NO_DATA		BIT(0)
+#define FLAG_EXPECTED_FAIL	BIT(1)
+
+enum {
+	CLASSIC  = BIT(6),	/* Old BPF instructions only. */
+	INTERNAL = BIT(7),	/* Extended instruction set.  */
+};
+
+#define TEST_TYPE_MASK		(CLASSIC | INTERNAL)
 
 struct bpf_test {
 	const char *descr;
@@ -55,12 +68,7 @@ struct bpf_test {
 		struct sock_filter insns[MAX_INSNS];
 		struct sock_filter_int insns_int[MAX_INSNS];
 	} u;
-	enum {
-		NO_DATA,
-		EXPECTED_FAIL,
-		SKB,
-		SKB_INT
-	} data_type;
+	__u8 aux;
 	__u8 data[MAX_DATA];
 	struct {
 		int data_size;
@@ -84,7 +92,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_LD | BPF_B | BPF_IND, 1),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ 10, 20, 30, 40, 50 },
 		{ { 2, 10 }, { 3, 20 }, { 4, 30 } },
 	},
@@ -96,7 +104,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0) /* A == len * 2 */
 		},
-		SKB,
+		CLASSIC,
 		{ 10, 20, 30, 40, 50 },
 		{ { 1, 2 }, { 3, 6 }, { 4, 8 } },
 	},
@@ -111,7 +119,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_ALU | BPF_MUL | BPF_K, 3),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		0,
+		CLASSIC | FLAG_NO_DATA,
 		{ },
 		{ { 0, 0xfffffffd } }
 	},
@@ -129,7 +137,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		0,
+		CLASSIC | FLAG_NO_DATA,
 		{ },
 		{ { 0, 0x40000001 } }
 	},
@@ -145,7 +153,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		0,
+		CLASSIC | FLAG_NO_DATA,
 		{ },
 		{ { 0, 0x800000ff }, { 1, 0x800000ff } },
 	},
@@ -156,7 +164,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_LD | BPF_H | BPF_IND, MAX_K),
 			BPF_STMT(BPF_RET | BPF_K, 1)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, 0 }, { 10, 0 }, { 60, 0 } },
 	},
@@ -166,7 +174,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS, 1000),
 			BPF_STMT(BPF_RET | BPF_K, 1)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, 0 }, { 10, 0 }, { 60, 0 } },
 	},
@@ -179,7 +187,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ 1, 2, 3 },
 		{ { 1, 0 }, { 2, 3 } },
 	},
@@ -193,7 +201,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_LD | BPF_B | BPF_IND, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ 1, 2, 3, 0xff },
 		{ { 1, 1 }, { 3, 3 }, { 4, 0xff } },
 	},
@@ -206,7 +214,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3 },
 		{ { 15, 0 }, { 16, 3 } },
 	},
@@ -220,7 +228,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_LD | BPF_B | BPF_IND, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3 },
 		{ { 14, 0 }, { 15, 1 }, { 17, 3 } },
 	},
@@ -241,7 +249,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_RET | BPF_K, 1),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, 3 }, { 10, 3 } },
 	},
@@ -252,7 +260,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_MARK),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, SKB_MARK}, { 10, SKB_MARK} },
 	},
@@ -263,7 +271,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_RXHASH),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, SKB_HASH}, { 10, SKB_HASH} },
 	},
@@ -274,7 +282,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_QUEUE),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, SKB_QUEUE_MAP }, { 10, SKB_QUEUE_MAP } },
 	},
@@ -293,7 +301,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_MISC | BPF_TXA, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ 10, 20, 30 },
 		{ { 10, ETH_P_IP }, { 100, ETH_P_IP } },
 	},
@@ -304,7 +312,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_VLAN_TAG),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{
 			{ 1, SKB_VLAN_TCI & ~VLAN_TAG_PRESENT },
@@ -318,7 +326,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_VLAN_TAG_PRESENT),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{
 			{ 1, !!(SKB_VLAN_TCI & VLAN_TAG_PRESENT) },
@@ -332,7 +340,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_IFINDEX),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, SKB_DEV_IFINDEX }, { 10, SKB_DEV_IFINDEX } },
 	},
@@ -343,7 +351,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_HATYPE),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, SKB_DEV_TYPE }, { 10, SKB_DEV_TYPE } },
 	},
@@ -358,7 +366,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_ALU | BPF_SUB | BPF_X, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, 0 }, { 10, 0 } },
 	},
@@ -372,7 +380,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_NLATTR),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ 0xff, 4, 0, 2, 0, 4, 0, 3, 0 },
 		{ { 4, 0 }, { 20, 5 } },
 	},
@@ -406,7 +414,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_NLATTR_NEST),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ 0xff, 12, 0, 1, 0, 4, 0, 2, 0, 4, 0, 3, 0 },
 		{ { 4, 0 }, { 20, 9 } },
 	},
@@ -425,7 +433,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_PAY_OFFSET),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		/* 00:00:00:00:00:00 > 00:00:00:00:00:00, ethtype IPv4 (0x0800),
 		 * length 98: 127.0.0.1 > 127.0.0.1: ICMP echo request,
 		 * id 9737, seq 1, length 64
@@ -446,7 +454,7 @@ static struct bpf_test tests[] = {
 				 SKF_AD_OFF + SKF_AD_ALU_XOR_X),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 4, 10 ^ 300 }, { 20, 10 ^ 300 } },
 	},
@@ -468,7 +476,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_ALU | BPF_XOR | BPF_X, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
+		CLASSIC,
 		{ },
 		{ { 1, 0x80000001 }, { 2, 0x80000002 }, { 60, 0x80000000 ^ 60 } }
 	},
@@ -481,7 +489,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_RET | BPF_K, 1),
 			BPF_STMT(BPF_RET | BPF_K, MAX_K)
 		},
-		SKB,
+		CLASSIC,
 		{ 3, 3, 3, 3, 3 },
 		{ { 1, 0 }, { 3, 1 }, { 4, MAX_K } },
 	},
@@ -494,7 +502,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_RET | BPF_K, 1),
 			BPF_STMT(BPF_RET | BPF_K, MAX_K)
 		},
-		SKB,
+		CLASSIC,
 		{ 4, 4, 4, 3, 3 },
 		{ { 2, 0 }, { 3, 1 }, { 4, MAX_K } },
 	},
@@ -513,7 +521,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_RET | BPF_K, 40),
 			BPF_STMT(BPF_RET | BPF_K, MAX_K)
 		},
-		SKB,
+		CLASSIC,
 		{ 1, 2, 3, 4, 5 },
 		{ { 1, 20 }, { 3, 40 }, { 5, MAX_K } },
 	},
@@ -545,7 +553,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_RET | BPF_K, 30),
 			BPF_STMT(BPF_RET | BPF_K, MAX_K)
 		},
-		SKB,
+		CLASSIC,
 		{ 0, 0xAA, 0x55, 1 },
 		{ { 4, 10 }, { 5, 20 }, { 6, MAX_K } },
 	},
@@ -577,7 +585,7 @@ static struct bpf_test tests[] = {
 			{ 0x06,  0,  0, 0x0000ffff },
 			{ 0x06,  0,  0, 0x00000000 },
 		},
-		SKB,
+		CLASSIC,
 		/* 3c:07:54:43:e5:76 > 10:bf:48:d6:43:d6, ethertype IPv4(0x0800)
 		 * length 114: 10.1.1.149.49700 > 10.1.2.10.22: Flags [P.],
 		 * seq 1305692979:1305693027, ack 3650467037, win 65535,
@@ -635,7 +643,7 @@ static struct bpf_test tests[] = {
 			{ 0x06,  0,  0, 0x0000ffff },
 			{ 0x06,  0,  0, 0x00000000 },
 		},
-		SKB,
+		CLASSIC,
 		{ 0x10, 0xbf, 0x48, 0xd6, 0x43, 0xd6,
 		  0x3c, 0x07, 0x54, 0x43, 0xe5, 0x76,
 		  0x08, 0x00,
@@ -654,8 +662,8 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_MISC | BPF_TXA, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
-		SKB,
-		{},
+		CLASSIC,
+		{ },
 		{ {1, 0}, {2, 0} },
 	},
 	{
@@ -670,7 +678,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_REG(BPF_MOV, R0, R1),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, 0xfffffffd } }
 	},
@@ -686,7 +694,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_IMM(BPF_MOV, R0, 1),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, 1 } }
 	},
@@ -703,7 +711,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU32_IMM(BPF_MOV, R0, 1),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, 1 } }
 	},
@@ -720,7 +728,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU32_IMM(BPF_MOV, R0, 1),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, 1 } }
 	},
@@ -882,7 +890,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_REG(BPF_MOV, R0, R9),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, 2957380 } }
 	},
@@ -1028,7 +1036,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU32_REG(BPF_MOV, R0, R9),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, 2957380 } }
 	},
@@ -1161,7 +1169,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_REG(BPF_SUB, R0, R9),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, 11 } }
 	},
@@ -1227,7 +1235,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_IMM(BPF_MOV, R0, 1),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, 1 } }
 	},
@@ -1289,7 +1297,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_REG(BPF_MOV, R0, R2),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, 0x35d97ef2 } }
 	},
@@ -1309,7 +1317,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_IMM(BPF_MOV, R0, -1),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ },
 		{ { 0, -1 } }
 	},
@@ -1326,7 +1334,7 @@ static struct bpf_test tests[] = {
 			BPF_LD_IND(BPF_B, R8, -70),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ 10, 20, 30, 40, 50 },
 		{ { 4, 0 }, { 5, 10 } }
 	},
@@ -1339,7 +1347,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU32_REG(BPF_DIV, R0, R7),
 			BPF_EXIT_INSN(),
 		},
-		SKB_INT,
+		INTERNAL,
 		{ 10, 20, 30, 40, 50 },
 		{ { 3, 0 }, { 4, 0 } }
 	},
@@ -1348,7 +1356,7 @@ static struct bpf_test tests[] = {
 		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 1),
 		},
-		EXPECTED_FAIL,
+		CLASSIC | FLAG_NO_DATA | FLAG_EXPECTED_FAIL,
 		{ },
 		{ }
 	},
@@ -1358,7 +1366,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_ALU | BPF_DIV | BPF_K, 0),
 			BPF_STMT(BPF_RET | BPF_K, 0)
 		},
-		EXPECTED_FAIL,
+		CLASSIC | FLAG_NO_DATA | FLAG_EXPECTED_FAIL,
 		{ },
 		{ }
 	},
@@ -1369,7 +1377,7 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_LDX | BPF_W | BPF_ABS, 0),
 			BPF_STMT(BPF_RET | BPF_K, 0)
 		},
-		EXPECTED_FAIL,
+		CLASSIC | FLAG_EXPECTED_FAIL,
 		{ },
 		{ }
 	},
@@ -1379,26 +1387,15 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_STX, 16),
 			BPF_STMT(BPF_RET | BPF_K, 0)
 		},
-		EXPECTED_FAIL,
+		CLASSIC | FLAG_NO_DATA | FLAG_EXPECTED_FAIL,
 		{ },
 		{ }
 	},
 };
 
-static int get_length(struct sock_filter *fp)
-{
-	int len = 0;
-
-	while (fp->code != 0 || fp->k != 0) {
-		fp++;
-		len++;
-	}
-
-	return len;
-}
+static struct net_device dev;
 
-struct net_device dev;
-struct sk_buff *populate_skb(char *buf, int size)
+static struct sk_buff *populate_skb(char *buf, int size)
 {
 	struct sk_buff *skb;
 
@@ -1410,6 +1407,8 @@ struct sk_buff *populate_skb(char *buf, int size)
 		return NULL;
 
 	memcpy(__skb_put(skb, size), buf, size);
+
+	/* Initialize a fake skb with test pattern. */
 	skb_reset_mac_header(skb);
 	skb->protocol = htons(ETH_P_IP);
 	skb->pkt_type = SKB_TYPE;
@@ -1425,43 +1424,149 @@ struct sk_buff *populate_skb(char *buf, int size)
 	return skb;
 }
 
-static int run_one(struct sk_filter *fp, struct bpf_test *t)
+static void *generate_test_data(struct bpf_test *test, int sub)
 {
-	u64 start, finish, res, cnt = 100000;
-	int err_cnt = 0, err, i, j;
-	u32 ret = 0;
-	void *data;
+	if (test->aux & FLAG_NO_DATA)
+		return NULL;
 
-	for (i = 0; i < MAX_SUBTESTS; i++) {
-		if (t->test[i].data_size == 0 &&
-		    t->test[i].result == 0)
-			break;
-		if (t->data_type == SKB ||
-		    t->data_type == SKB_INT) {
-			data = populate_skb(t->data, t->test[i].data_size);
-			if (!data)
-				return -ENOMEM;
-		} else {
-			data = NULL;
+	/* Test case expects an skb, so populate one. Various
+	 * subtests generate skbs of different sizes based on
+	 * the same data.
+	 */
+	return populate_skb(test->data, test->test[sub].data_size);
+}
+
+static void release_test_data(const struct bpf_test *test, void *data)
+{
+	if (test->aux & FLAG_NO_DATA)
+		return;
+
+	kfree_skb(data);
+}
+
+static int probe_filter_length(struct sock_filter *fp)
+{
+	int len = 0;
+
+	while (fp->code != 0 || fp->k != 0) {
+		fp++;
+		len++;
+	}
+
+	return len;
+}
+
+static struct sk_filter *generate_filter(int which, int *err)
+{
+	struct sk_filter *fp;
+	struct sock_fprog_kern fprog;
+	unsigned int flen = probe_filter_length(tests[which].u.insns);
+	__u8 test_type = tests[which].aux & TEST_TYPE_MASK;
+
+	switch (test_type) {
+	case CLASSIC:
+		fprog.filter = tests[which].u.insns;
+		fprog.len = flen;
+
+		*err = sk_unattached_filter_create(&fp, &fprog);
+		if (tests[which].aux & FLAG_EXPECTED_FAIL) {
+			if (*err == -EINVAL) {
+				pr_cont("PASS\n");
+				/* Verifier rejected filter as expected. */
+				*err = 0;
+				return NULL;
+			} else {
+				pr_cont("UNEXPECTED_PASS\n");
+				/* Verifier didn't reject the test that's
+				 * bad enough, just return!
+				 */
+				*err = -EINVAL;
+				return NULL;
+			}
+		}
+		/* We don't expect to fail. */
+		if (*err) {
+			pr_cont("FAIL to attach err=%d len=%d\n",
+				*err, fprog.len);
+			return NULL;
+		}
+		break;
+
+	case INTERNAL:
+		fp = kzalloc(sk_filter_size(flen), GFP_KERNEL);
+		if (fp == NULL) {
+			pr_cont("UNEXPECTED_FAIL no memory left\n");
+			*err = -ENOMEM;
+			return NULL;
 		}
 
-		start = ktime_to_us(ktime_get());
-		for (j = 0; j < cnt; j++)
-			ret = SK_RUN_FILTER(fp, data);
-		finish = ktime_to_us(ktime_get());
+		fp->len = flen;
+		memcpy(fp->insnsi, tests[which].u.insns_int,
+		       fp->len * sizeof(struct sock_filter_int));
 
-		res = (finish - start) * 1000;
-		do_div(res, cnt);
+		sk_filter_select_runtime(fp);
+		break;
+	}
 
-		err = ret != t->test[i].result;
-		if (!err)
-			pr_cont("%lld ", res);
+	*err = 0;
+	return fp;
+}
 
-		if (t->data_type == SKB || t->data_type == SKB_INT)
-			kfree_skb(data);
+static void release_filter(struct sk_filter *fp, int which)
+{
+	__u8 test_type = tests[which].aux & TEST_TYPE_MASK;
 
-		if (err) {
-			pr_cont("ret %d != %d ", ret, t->test[i].result);
+	switch (test_type) {
+	case CLASSIC:
+		sk_unattached_filter_destroy(fp);
+		break;
+	case INTERNAL:
+		sk_filter_free(fp);
+		break;
+	}
+}
+
+static int __run_one(const struct sk_filter *fp, const void *data,
+		     int runs, u64 *duration)
+{
+	u64 start, finish;
+	int ret, i;
+
+	start = ktime_to_us(ktime_get());
+
+	for (i = 0; i < runs; i++)
+		ret = SK_RUN_FILTER(fp, data);
+
+	finish = ktime_to_us(ktime_get());
+
+	*duration = (finish - start) * 1000ULL;
+	do_div(*duration, runs);
+
+	return ret;
+}
+
+static int run_one(const struct sk_filter *fp, struct bpf_test *test)
+{
+	int err_cnt = 0, i, runs = MAX_TESTRUNS;
+
+	for (i = 0; i < MAX_SUBTESTS; i++) {
+		void *data;
+		u64 duration;
+		u32 ret;
+
+		if (test->test[i].data_size == 0 &&
+		    test->test[i].result == 0)
+			break;
+
+		data = generate_test_data(test, i);
+		ret = __run_one(fp, data, runs, &duration);
+		release_test_data(test, data);
+
+		if (ret == test->test[i].result) {
+			pr_cont("%lld ", duration);
+		} else {
+			pr_cont("ret %d != %d ", ret,
+				test->test[i].result);
 			err_cnt++;
 		}
 	}
@@ -1471,65 +1576,37 @@ static int run_one(struct sk_filter *fp, struct bpf_test *t)
 
 static __init int test_bpf(void)
 {
-	struct sk_filter *fp, *fp_ext = NULL;
-	struct sock_fprog_kern fprog;
-	int err, i, err_cnt = 0;
+	int i, err_cnt = 0, pass_cnt = 0;
 
 	for (i = 0; i < ARRAY_SIZE(tests); i++) {
-		pr_info("#%d %s ", i, tests[i].descr);
+		struct sk_filter *fp;
+		int err;
 
-		fprog.filter = tests[i].u.insns;
-		fprog.len = get_length(fprog.filter);
+		pr_info("#%d %s ", i, tests[i].descr);
 
-		if (tests[i].data_type == SKB_INT) {
-			fp_ext = kzalloc(4096, GFP_KERNEL);
-			if (!fp_ext)
-				return -ENOMEM;
-			fp = fp_ext;
-			memcpy(fp_ext->insns, tests[i].u.insns_int,
-			       fprog.len * 8);
-			fp->len = fprog.len;
-			sk_filter_select_runtime(fp);
-		} else {
-			err = sk_unattached_filter_create(&fp, &fprog);
-			if (tests[i].data_type == EXPECTED_FAIL) {
-				if (err == -EINVAL) {
-					pr_cont("PASS\n");
-					continue;
-				} else {
-					pr_cont("UNEXPECTED_PASS\n");
-					/* verifier didn't reject the test
-					 * that's bad enough, just return
-					 */
-					return -EINVAL;
-				}
-			}
-			if (err) {
-				pr_cont("FAIL to attach err=%d len=%d\n",
-					err, fprog.len);
-				return err;
+		fp = generate_filter(i, &err);
+		if (fp == NULL) {
+			if (err == 0) {
+				pass_cnt++;
+				continue;
 			}
-		}
 
+			return err;
+		}
 		err = run_one(fp, &tests[i]);
-
-		if (tests[i].data_type != SKB_INT)
-			sk_unattached_filter_destroy(fp);
-		else
-			sk_filter_free(fp);
+		release_filter(fp, i);
 
 		if (err) {
-			pr_cont("FAIL %d\n", err);
+			pr_cont("FAIL (%d times)\n", err);
 			err_cnt++;
 		} else {
 			pr_cont("PASS\n");
+			pass_cnt++;
 		}
 	}
 
-	if (err_cnt)
-		return -EINVAL;
-	else
-		return 0;
+	pr_info("Summary: %d PASSED, %d FAILED\n", pass_cnt, err_cnt);
+	return err_cnt ? -EINVAL : 0;
 }
 
 static int __init test_bpf_init(void)
@@ -1543,4 +1620,5 @@ static void __exit test_bpf_exit(void)
 
 module_init(test_bpf_init);
 module_exit(test_bpf_exit);
+
 MODULE_LICENSE("GPL");
-- 
1.7.11.7
