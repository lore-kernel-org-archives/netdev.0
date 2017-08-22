From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH net-next 1/4] selftests/bpf: add a test for a
 pruning bug in the verifier
Date: Tue, 22 Aug 2017 14:26:09 +0100
Message-ID: <38c13459-0357-3212-51ef-b345b39fb028@solarflare.com>
References: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <f25f46bd-27cb-2182-2551-2887757c1e0f-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

From: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>

The test makes a read through a map value pointer, then considers pruning
 a branch where the register holds an adjusted map value pointer.  It
 should not prune, but currently it does.

Signed-off-by: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
[ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org: added test-name and patch description]
Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 tools/testing/selftests/bpf/test_verifier.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index c03542c..6ca1487 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -6487,6 +6487,34 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_LWT_IN,
 	},
+	{
+		"varlen_map_value_access pruning",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0, 0),
+			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
+			BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
+			BPF_MOV32_IMM(BPF_REG_1, 0),
+			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 leaks addr",
+		.errstr = "R0 unbounded memory access",
+		.result_unpriv = REJECT,
+		.result = REJECT,
+		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
+	}, 
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
