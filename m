From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: filter: use block statements in tcpdump tests
Date: Mon, 26 May 2014 20:17:35 +0200
Message-ID: <1401128255-6545-3-git-send-email-dborkman@redhat.com>
References: <1401128255-6545-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50448 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068AbaEZSRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2014 14:17:44 -0400
In-Reply-To: <1401128255-6545-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts raw opcodes for tcpdump tests into
BPF_STMT()/BPF_JUMP() combinations, which brings it into
conformity with the rest of the patches and it also makes
life easier to grasp what's going on in these particular
test cases when they ever fail. Also arrange payload from
the jump+holes test in a way as we have with other packet
payloads in the test suite.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 lib/test_bpf.c | 143 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 75 insertions(+), 68 deletions(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 6be9119..3c4a1e3 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -560,30 +560,30 @@ static struct bpf_test tests[] = {
 	{
 		"tcpdump port 22",
 		.u.insns = {
-			{ 0x28,  0,  0, 0x0000000c },
-			{ 0x15,  0,  8, 0x000086dd },
-			{ 0x30,  0,  0, 0x00000014 },
-			{ 0x15,  2,  0, 0x00000084 },
-			{ 0x15,  1,  0, 0x00000006 },
-			{ 0x15,  0, 17, 0x00000011 },
-			{ 0x28,  0,  0, 0x00000036 },
-			{ 0x15, 14,  0, 0x00000016 },
-			{ 0x28,  0,  0, 0x00000038 },
-			{ 0x15, 12, 13, 0x00000016 },
-			{ 0x15,  0, 12, 0x00000800 },
-			{ 0x30,  0,  0, 0x00000017 },
-			{ 0x15,  2,  0, 0x00000084 },
-			{ 0x15,  1,  0, 0x00000006 },
-			{ 0x15,  0,  8, 0x00000011 },
-			{ 0x28,  0,  0, 0x00000014 },
-			{ 0x45,  6,  0, 0x00001fff },
-			{ 0xb1,  0,  0, 0x0000000e },
-			{ 0x48,  0,  0, 0x0000000e },
-			{ 0x15,  2,  0, 0x00000016 },
-			{ 0x48,  0,  0, 0x00000010 },
-			{ 0x15,  0,  1, 0x00000016 },
-			{ 0x06,  0,  0, 0x0000ffff },
-			{ 0x06,  0,  0, 0x00000000 },
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 12),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x86dd, 0, 8), /* IPv6 */
+			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 20),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x84, 2, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x6, 1, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x11, 0, 17),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 54),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 22, 14, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 56),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 22, 12, 13),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x0800, 0, 12), /* IPv4 */
+			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 23),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x84, 2, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x6, 1, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x11, 0, 8),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 20),
+			BPF_JUMP(BPF_JMP | BPF_JSET | BPF_K, 0x1fff, 6, 0),
+			BPF_STMT(BPF_LDX | BPF_B | BPF_MSH, 14),
+			BPF_STMT(BPF_LD | BPF_H | BPF_IND, 14),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 22, 2, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_IND, 16),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 22, 0, 1),
+			BPF_STMT(BPF_RET | BPF_K, 0xffff),
+			BPF_STMT(BPF_RET | BPF_K, 0),
 		},
 		CLASSIC,
 		/* 3c:07:54:43:e5:76 > 10:bf:48:d6:43:d6, ethertype IPv4(0x0800)
@@ -609,39 +609,39 @@ static struct bpf_test tests[] = {
 			 * ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0) and
 			 * (len > 115 or len < 30000000000)' -d
 			 */
-			{ 0x28,  0,  0, 0x0000000c },
-			{ 0x15, 30,  0, 0x000086dd },
-			{ 0x15,  0, 29, 0x00000800 },
-			{ 0x30,  0,  0, 0x00000017 },
-			{ 0x15,  0, 27, 0x00000006 },
-			{ 0x28,  0,  0, 0x00000014 },
-			{ 0x45, 25,  0, 0x00001fff },
-			{ 0xb1,  0,  0, 0x0000000e },
-			{ 0x48,  0,  0, 0x0000000e },
-			{ 0x15,  2,  0, 0x00000016 },
-			{ 0x48,  0,  0, 0x00000010 },
-			{ 0x15,  0, 20, 0x00000016 },
-			{ 0x28,  0,  0, 0x00000010 },
-			{ 0x02,  0,  0, 0x00000001 },
-			{ 0x30,  0,  0, 0x0000000e },
-			{ 0x54,  0,  0, 0x0000000f },
-			{ 0x64,  0,  0, 0x00000002 },
-			{ 0x07,  0,  0, 0x00000005 },
-			{ 0x60,  0,  0, 0x00000001 },
-			{ 0x1c,  0,  0, 0x00000000 },
-			{ 0x02,  0,  0, 0x00000005 },
-			{ 0xb1,  0,  0, 0x0000000e },
-			{ 0x50,  0,  0, 0x0000001a },
-			{ 0x54,  0,  0, 0x000000f0 },
-			{ 0x74,  0,  0, 0x00000002 },
-			{ 0x07,  0,  0, 0x00000009 },
-			{ 0x60,  0,  0, 0x00000005 },
-			{ 0x1d,  4,  0, 0x00000000 },
-			{ 0x80,  0,  0, 0x00000000 },
-			{ 0x25,  1,  0, 0x00000073 },
-			{ 0x35,  1,  0, 0xfc23ac00 },
-			{ 0x06,  0,  0, 0x0000ffff },
-			{ 0x06,  0,  0, 0x00000000 },
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 12),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x86dd, 30, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x800, 0, 29),
+			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 23),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x6, 0, 27),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 20),
+			BPF_JUMP(BPF_JMP | BPF_JSET | BPF_K, 0x1fff, 25, 0),
+			BPF_STMT(BPF_LDX | BPF_B | BPF_MSH, 14),
+			BPF_STMT(BPF_LD | BPF_H | BPF_IND, 14),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 22, 2, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_IND, 16),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 22, 0, 20),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 16),
+			BPF_STMT(BPF_ST, 1),
+			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 14),
+			BPF_STMT(BPF_ALU | BPF_AND | BPF_K, 0xf),
+			BPF_STMT(BPF_ALU | BPF_LSH | BPF_K, 2),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0x5), /* libpcap emits K on TAX */
+			BPF_STMT(BPF_LD | BPF_MEM, 1),
+			BPF_STMT(BPF_ALU | BPF_SUB | BPF_X, 0),
+			BPF_STMT(BPF_ST, 5),
+			BPF_STMT(BPF_LDX | BPF_B | BPF_MSH, 14),
+			BPF_STMT(BPF_LD | BPF_B | BPF_IND, 26),
+			BPF_STMT(BPF_ALU | BPF_AND | BPF_K, 0xf0),
+			BPF_STMT(BPF_ALU | BPF_RSH | BPF_K, 2),
+			BPF_STMT(BPF_MISC | BPF_TAX, 0x9), /* libpcap emits K on TAX */
+			BPF_STMT(BPF_LD | BPF_MEM, 5),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_X, 0, 4, 0),
+			BPF_STMT(BPF_LD | BPF_LEN, 0),
+			BPF_JUMP(BPF_JMP | BPF_JGT | BPF_K, 0x73, 1, 0),
+			BPF_JUMP(BPF_JMP | BPF_JGE | BPF_K, 0xfc23ac00, 1, 0),
+			BPF_STMT(BPF_RET | BPF_K, 0xffff),
+			BPF_STMT(BPF_RET | BPF_K, 0),
 		},
 		CLASSIC,
 		{ 0x10, 0xbf, 0x48, 0xd6, 0x43, 0xd6,
@@ -1453,17 +1453,24 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_RET | BPF_A, 0),
 		},
 		CLASSIC,
-		{ 0x00, 0x1b, 0x21, 0x3c, 0x9d, 0xf8, 0x90, 0xe2,
-		  0xba, 0x0a, 0x56, 0xb4, 0x08, 0x00, 0x45, 0x00,
-		  0x00, 0x28, 0x00, 0x00, 0x20, 0x00, 0x40, 0x11,
-		  0x00, 0x00, 0xc0, 0xa8, 0x33, 0x01, 0xc0, 0xa8,
-		  0x33, 0x02, 0xbb, 0xb6, 0xa9, 0xfa, 0x00, 0x14,
-		  0x00, 0x00, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
-		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
-		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
-		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
-		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
-		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc },
+		{ 0x00, 0x1b, 0x21, 0x3c, 0x9d, 0xf8,
+		  0x90, 0xe2, 0xba, 0x0a, 0x56, 0xb4,
+		  0x08, 0x00,
+		  0x45, 0x00, 0x00, 0x28, 0x00, 0x00,
+		  0x20, 0x00, 0x40, 0x11, 0x00, 0x00, /* IP header */
+		  0xc0, 0xa8, 0x33, 0x01,
+		  0xc0, 0xa8, 0x33, 0x02,
+		  0xbb, 0xb6,
+		  0xa9, 0xfa,
+		  0x00, 0x14, 0x00, 0x00,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc },
 		{ { 88, 0x001b } }
 	},
 	{
-- 
1.7.11.7
