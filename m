From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v4 net-next 11/13] selftests/bpf: variable
 offset negative tests
Date: Thu, 3 Aug 2017 17:15:31 +0100
Message-ID: <f6f83ba8-dc5b-f55c-a1cb-902c6f83a64b@solarflare.com>
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

Variable ctx accesses and stack accesses aren't allowed, because we can't
 determine what type of value will be read.

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 tools/testing/selftests/bpf/test_verifier.c | 41 +++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 876b878..65aa562 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -5980,6 +5980,47 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 	},
+	{
+		"variable-offset ctx access",
+		.insns = {
+			/* Get an unknown value */
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 0),
+			/* Make it small and 4-byte aligned */
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 4),
+			/* add it to skb.  We now have either &skb->len or
+			 * &skb->pkt_type, but we don't know which
+			 */
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_2),
+			/* dereference it */
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "variable ctx access var_off=(0x0; 0x4)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_LWT_IN,
+	},
+	{
+		"variable-offset stack access",
+		.insns = {
+			/* Fill the top 8 bytes of the stack */
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			/* Get an unknown value */
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 0),
+			/* Make it small and 4-byte aligned */
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 4),
+			BPF_ALU64_IMM(BPF_SUB, BPF_REG_2, 8),
+			/* add it to fp.  We now have either fp-4 or fp-8, but
+			 * we don't know which
+			 */
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_2, BPF_REG_10),
+			/* dereference it */
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_2, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "variable stack access var_off=(0xfffffffffffffff8; 0x4)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_LWT_IN,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
