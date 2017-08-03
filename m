From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v4 net-next 09/13] selftests/bpf: don't try to
 access past MAX_PACKET_OFF in test_verifier
Date: Thu, 3 Aug 2017 17:14:58 +0100
Message-ID: <1f9712e1-bc77-e19a-7ef5-96b28c2529a1@solarflare.com>
References: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

A number of selftests fell foul of the changed MAX_PACKET_OFF handling.
For instance, "direct packet access: test2" was potentially reading four
 bytes from pkt + 0xffff, which could take it past the verifier's limit,
 causing the program to be rejected (checks against pkt_end didn't give
 us any reg->range).
Increase the shifts by one so that R2 is now mask 0x7fff instead of
 mask 0xffff.

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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
