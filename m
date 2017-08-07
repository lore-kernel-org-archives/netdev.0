From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 08/12] selftests/bpf: don't try to access past
 MAX_PACKET_OFF in test_verifier
Date: Mon, 7 Aug 2017 15:29:11 +0100
Message-ID: <900cc572-f770-b386-2345-721a9c5c8563@solarflare.com>
References: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A number of selftests fell foul of the changed MAX_PACKET_OFF handling.
For instance, "direct packet access: test2" was potentially reading four
 bytes from pkt + 0xffff, which could take it past the verifier's limit,
 causing the program to be rejected (checks against pkt_end didn't give
 us any reg->range).
Increase the shifts by one so that R2 is now mask 0x7fff instead of
 mask 0xffff.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 tools/testing/selftests/bpf/test_verifier.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 0691494..876b878 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -2330,8 +2330,8 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, data)),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_4),
 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_1),
-			BPF_ALU64_IMM(BPF_LSH, BPF_REG_2, 48),
-			BPF_ALU64_IMM(BPF_RSH, BPF_REG_2, 48),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_2, 49),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_2, 49),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_2),
 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_3),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 8),
@@ -2710,11 +2710,11 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_0, 0xffffffff),
 			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
 			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
-			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 0xffff),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 0x7fff),
 			BPF_MOV64_REG(BPF_REG_4, BPF_REG_0),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_2),
 			BPF_MOV64_REG(BPF_REG_5, BPF_REG_4),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0xffff - 1),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0x7fff - 1),
 			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
 			BPF_STX_MEM(BPF_DW, BPF_REG_5, BPF_REG_4, 0),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -2736,10 +2736,10 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_4, 0xffffffff),
 			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_4, -8),
 			BPF_LDX_MEM(BPF_DW, BPF_REG_4, BPF_REG_10, -8),
-			BPF_ALU64_IMM(BPF_AND, BPF_REG_4, 0xffff),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_4, 0x7fff),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_2),
 			BPF_MOV64_REG(BPF_REG_5, BPF_REG_4),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0xffff - 1),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0x7fff - 1),
 			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
 			BPF_STX_MEM(BPF_DW, BPF_REG_5, BPF_REG_4, 0),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -2765,7 +2765,7 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_4, 0xffffffff),
 			BPF_STX_XADD(BPF_DW, BPF_REG_10, BPF_REG_4, -8),
 			BPF_LDX_MEM(BPF_DW, BPF_REG_4, BPF_REG_10, -8),
-			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 48),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 49),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_2),
 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_4),
 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 2),
@@ -2820,7 +2820,7 @@ static struct bpf_test tests[] = {
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_4),
 			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
 			BPF_MOV64_REG(BPF_REG_5, BPF_REG_0),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 0xffff - 1),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 0x7fff - 1),
 			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
 			BPF_STX_MEM(BPF_DW, BPF_REG_5, BPF_REG_0, 0),
 			BPF_MOV64_IMM(BPF_REG_0, 0),
