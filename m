From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v4 net-next 06/13] selftests/bpf: rewrite
	test_align
Date: Thu, 3 Aug 2017 17:13:21 +0100
Message-ID: <ce12d8ea-127d-ca20-1665-732c3475e6c6@solarflare.com>
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

Expectations have changed, as has the format of the logged state.
To make the tests easier to read, add a line-matching framework so that
 each match need only quote the register it cares about.  (Multiple
 matches may refer to the same line, but matches must be listed in
 order of increasing line.)

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 tools/testing/selftests/bpf/test_align.c | 225 ++++++++++++++++++-------------
 1 file changed, 132 insertions(+), 93 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
index 2979369..62232e4d 100644
--- a/tools/testing/selftests/bpf/test_align.c
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -27,6 +27,11 @@
 #define MAX_INSNS	512
 #define MAX_MATCHES	16
 
+struct bpf_reg_match {
+	unsigned int line;
+	const char *match;
+};
+
 struct bpf_align_test {
 	const char *descr;
 	struct bpf_insn	insns[MAX_INSNS];
@@ -36,10 +41,14 @@ struct bpf_align_test {
 		REJECT
 	} result;
 	enum bpf_prog_type prog_type;
-	const char *matches[MAX_MATCHES];
+	/* Matches must be in order of increasing line */
+	struct bpf_reg_match matches[MAX_MATCHES];
 };
 
 static struct bpf_align_test tests[] = {
+	/* Four tests of known constants.  These aren't staggeringly
+	 * interesting since we track exact values now.
+	 */
 	{
 		.descr = "mov",
 		.insns = {
@@ -53,11 +62,13 @@ static struct bpf_align_test tests[] = {
 		},
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.matches = {
-			"1: R1=ctx R3=imm2,min_value=2,max_value=2,min_align=2 R10=fp",
-			"2: R1=ctx R3=imm4,min_value=4,max_value=4,min_align=4 R10=fp",
-			"3: R1=ctx R3=imm8,min_value=8,max_value=8,min_align=8 R10=fp",
-			"4: R1=ctx R3=imm16,min_value=16,max_value=16,min_align=16 R10=fp",
-			"5: R1=ctx R3=imm32,min_value=32,max_value=32,min_align=32 R10=fp",
+			{1, "R1=ctx(id=0,off=0,imm=0)"},
+			{1, "R10=fp0"},
+			{1, "R3=inv2"},
+			{2, "R3=inv4"},
+			{3, "R3=inv8"},
+			{4, "R3=inv16"},
+			{5, "R3=inv32"},
 		},
 	},
 	{
@@ -79,17 +90,19 @@ static struct bpf_align_test tests[] = {
 		},
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.matches = {
-			"1: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R10=fp",
-			"2: R1=ctx R3=imm2,min_value=2,max_value=2,min_align=2 R10=fp",
-			"3: R1=ctx R3=imm4,min_value=4,max_value=4,min_align=4 R10=fp",
-			"4: R1=ctx R3=imm8,min_value=8,max_value=8,min_align=8 R10=fp",
-			"5: R1=ctx R3=imm16,min_value=16,max_value=16,min_align=16 R10=fp",
-			"6: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R10=fp",
-			"7: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm32,min_value=32,max_value=32,min_align=32 R10=fp",
-			"8: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm16,min_value=16,max_value=16,min_align=16 R10=fp",
-			"9: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm8,min_value=8,max_value=8,min_align=8 R10=fp",
-			"10: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm4,min_value=4,max_value=4,min_align=4 R10=fp",
-			"11: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm2,min_value=2,max_value=2,min_align=2 R10=fp",
+			{1, "R1=ctx(id=0,off=0,imm=0)"},
+			{1, "R10=fp0"},
+			{1, "R3=inv1"},
+			{2, "R3=inv2"},
+			{3, "R3=inv4"},
+			{4, "R3=inv8"},
+			{5, "R3=inv16"},
+			{6, "R3=inv1"},
+			{7, "R4=inv32"},
+			{8, "R4=inv16"},
+			{9, "R4=inv8"},
+			{10, "R4=inv4"},
+			{11, "R4=inv2"},
 		},
 	},
 	{
@@ -106,12 +119,14 @@ static struct bpf_align_test tests[] = {
 		},
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.matches = {
-			"1: R1=ctx R3=imm4,min_value=4,max_value=4,min_align=4 R10=fp",
-			"2: R1=ctx R3=imm8,min_value=8,max_value=8,min_align=4 R10=fp",
-			"3: R1=ctx R3=imm10,min_value=10,max_value=10,min_align=2 R10=fp",
-			"4: R1=ctx R3=imm10,min_value=10,max_value=10,min_align=2 R4=imm8,min_value=8,max_value=8,min_align=8 R10=fp",
-			"5: R1=ctx R3=imm10,min_value=10,max_value=10,min_align=2 R4=imm12,min_value=12,max_value=12,min_align=4 R10=fp",
-			"6: R1=ctx R3=imm10,min_value=10,max_value=10,min_align=2 R4=imm14,min_value=14,max_value=14,min_align=2 R10=fp",
+			{1, "R1=ctx(id=0,off=0,imm=0)"},
+			{1, "R10=fp0"},
+			{1, "R3=inv4"},
+			{2, "R3=inv8"},
+			{3, "R3=inv10"},
+			{4, "R4=inv8"},
+			{5, "R4=inv12"},
+			{6, "R4=inv14"},
 		},
 	},
 	{
@@ -126,13 +141,16 @@ static struct bpf_align_test tests[] = {
 		},
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.matches = {
-			"1: R1=ctx R3=imm7,min_value=7,max_value=7,min_align=1 R10=fp",
-			"2: R1=ctx R3=imm7,min_value=7,max_value=7,min_align=1 R10=fp",
-			"3: R1=ctx R3=imm14,min_value=14,max_value=14,min_align=2 R10=fp",
-			"4: R1=ctx R3=imm56,min_value=56,max_value=56,min_align=4 R10=fp",
+			{1, "R1=ctx(id=0,off=0,imm=0)"},
+			{1, "R10=fp0"},
+			{1, "R3=inv7"},
+			{2, "R3=inv7"},
+			{3, "R3=inv14"},
+			{4, "R3=inv56"},
 		},
 	},
 
+	/* Tests using unknown values */
 #define PREP_PKT_POINTERS \
 	BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, \
 		    offsetof(struct __sk_buff, data)), \
@@ -166,17 +184,19 @@ static struct bpf_align_test tests[] = {
 		},
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.matches = {
-			"7: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R10=fp",
-			"8: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv55,min_align=2 R10=fp",
-			"9: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv54,min_align=4 R10=fp",
-			"10: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv53,min_align=8 R10=fp",
-			"11: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv52,min_align=16 R10=fp",
-			"18: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv56 R10=fp",
-			"19: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv51,min_align=32 R10=fp",
-			"20: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv52,min_align=16 R10=fp",
-			"21: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv53,min_align=8 R10=fp",
-			"22: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv54,min_align=4 R10=fp",
-			"23: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv55,min_align=2 R10=fp",
+			{7, "R0=pkt(id=0,off=8,r=8,imm=0)"},
+			{7, "R3=inv(id=0,umax_value=255,var_off=(0x0; 0xff))"},
+			{8, "R3=inv(id=0,umax_value=510,var_off=(0x0; 0x1fe))"},
+			{9, "R3=inv(id=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			{10, "R3=inv(id=0,umax_value=2040,var_off=(0x0; 0x7f8))"},
+			{11, "R3=inv(id=0,umax_value=4080,var_off=(0x0; 0xff0))"},
+			{18, "R3=pkt_end(id=0,off=0,imm=0)"},
+			{18, "R4=inv(id=0,umax_value=255,var_off=(0x0; 0xff))"},
+			{19, "R4=inv(id=0,umax_value=8160,var_off=(0x0; 0x1fe0))"},
+			{20, "R4=inv(id=0,umax_value=4080,var_off=(0x0; 0xff0))"},
+			{21, "R4=inv(id=0,umax_value=2040,var_off=(0x0; 0x7f8))"},
+			{22, "R4=inv(id=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			{23, "R4=inv(id=0,umax_value=510,var_off=(0x0; 0x1fe))"},
 		},
 	},
 	{
@@ -197,16 +217,16 @@ static struct bpf_align_test tests[] = {
 		},
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.matches = {
-			"7: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R10=fp",
-			"8: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv56 R10=fp",
-			"9: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv55,min_align=1 R10=fp",
-			"10: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv56 R10=fp",
-			"11: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv54,min_align=2 R10=fp",
-			"12: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv56 R10=fp",
-			"13: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv53,min_align=4 R10=fp",
-			"14: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv56 R10=fp",
-			"15: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv52,min_align=8 R10=fp",
-			"16: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv50,min_align=8 R10=fp"
+			{7, "R3=inv(id=0,umax_value=255,var_off=(0x0; 0xff))"},
+			{8, "R4=inv(id=0,umax_value=255,var_off=(0x0; 0xff))"},
+			{9, "R4=inv(id=0,umax_value=255,var_off=(0x0; 0xff))"},
+			{10, "R4=inv(id=0,umax_value=255,var_off=(0x0; 0xff))"},
+			{11, "R4=inv(id=0,umax_value=510,var_off=(0x0; 0x1fe))"},
+			{12, "R4=inv(id=0,umax_value=255,var_off=(0x0; 0xff))"},
+			{13, "R4=inv(id=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			{14, "R4=inv(id=0,umax_value=255,var_off=(0x0; 0xff))"},
+			{15, "R4=inv(id=0,umax_value=2040,var_off=(0x0; 0x7f8))"},
+			{16, "R4=inv(id=0,umax_value=4080,var_off=(0x0; 0xff0))"},
 		},
 	},
 	{
@@ -237,12 +257,14 @@ static struct bpf_align_test tests[] = {
 		},
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 		.matches = {
-			"4: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R5=pkt(id=0,off=0,r=0) R10=fp",
-			"5: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R5=pkt(id=0,off=14,r=0) R10=fp",
-			"6: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R4=pkt(id=0,off=14,r=0) R5=pkt(id=0,off=14,r=0) R10=fp",
-			"10: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv56 R5=pkt(id=0,off=14,r=18) R10=fp",
-			"14: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv48 R5=pkt(id=0,off=14,r=18) R10=fp",
-			"15: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv48 R5=pkt(id=0,off=14,r=18) R10=fp",
+			{4, "R5=pkt(id=0,off=0,r=0,imm=0)"},
+			{5, "R5=pkt(id=0,off=14,r=0,imm=0)"},
+			{6, "R4=pkt(id=0,off=14,r=0,imm=0)"},
+			{10, "R2=pkt(id=0,off=0,r=18,imm=0)"},
+			{10, "R5=pkt(id=0,off=14,r=18,imm=0)"},
+			{10, "R4=inv(id=0,umax_value=255,var_off=(0x0; 0xff))"},
+			{14, "R4=inv(id=0,umax_value=65535,var_off=(0x0; 0xffff))"},
+			{15, "R4=inv(id=0,umax_value=65535,var_off=(0x0; 0xffff))"},
 		},
 	},
 	{
@@ -297,62 +319,59 @@ static struct bpf_align_test tests[] = {
 			/* Calculated offset in R6 has unknown value, but known
 			 * alignment of 4.
 			 */
-			"8: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R6=inv54,min_align=4 R10=fp",
-
-			/* Offset is added to packet pointer R5, resulting in known
-			 * auxiliary alignment and offset.
+			{8, "R2=pkt(id=0,off=0,r=8,imm=0)"},
+			{8, "R6=inv(id=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			/* Offset is added to packet pointer R5, resulting in
+			 * known fixed offset, and variable offset from R6.
 			 */
-			"11: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R5=pkt(id=1,off=0,r=0),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
-
+			{11, "R5=pkt(id=1,off=14,r=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
 			/* At the time the word size load is performed from R5,
 			 * it's total offset is NET_IP_ALIGN + reg->off (0) +
 			 * reg->aux_off (14) which is 16.  Then the variable
 			 * offset is considered using reg->aux_off_align which
 			 * is 4 and meets the load's requirements.
 			 */
-			"15: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=pkt(id=1,off=4,r=4),aux_off=14,aux_off_align=4 R5=pkt(id=1,off=0,r=4),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
-
-
+			{15, "R4=pkt(id=1,off=18,r=18,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			{15, "R5=pkt(id=1,off=14,r=18,umax_value=1020,var_off=(0x0; 0x3fc))"},
 			/* Variable offset is added to R5 packet pointer,
 			 * resulting in auxiliary alignment of 4.
 			 */
-			"18: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off=14,aux_off_align=4 R5=pkt(id=2,off=0,r=0),aux_off_align=4 R6=inv54,min_align=4 R10=fp",
-
+			{18, "R5=pkt(id=2,off=0,r=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
 			/* Constant offset is added to R5, resulting in
 			 * reg->off of 14.
 			 */
-			"19: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off=14,aux_off_align=4 R5=pkt(id=2,off=14,r=0),aux_off_align=4 R6=inv54,min_align=4 R10=fp",
-
+			{19, "R5=pkt(id=2,off=14,r=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
 			/* At the time the word size load is performed from R5,
-			 * it's total offset is NET_IP_ALIGN + reg->off (14) which
-			 * is 16.  Then the variable offset is considered using
-			 * reg->aux_off_align which is 4 and meets the load's
-			 * requirements.
+			 * its total fixed offset is NET_IP_ALIGN + reg->off
+			 * (14) which is 16.  Then the variable offset is 4-byte
+			 * aligned, so the total offset is 4-byte aligned and
+			 * meets the load's requirements.
 			 */
-			"23: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=pkt(id=2,off=18,r=18),aux_off_align=4 R5=pkt(id=2,off=14,r=18),aux_off_align=4 R6=inv54,min_align=4 R10=fp",
-
+			{23, "R4=pkt(id=2,off=18,r=18,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			{23, "R5=pkt(id=2,off=14,r=18,umax_value=1020,var_off=(0x0; 0x3fc))"},
 			/* Constant offset is added to R5 packet pointer,
 			 * resulting in reg->off value of 14.
 			 */
-			"26: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off_align=4 R5=pkt(id=0,off=14,r=8) R6=inv54,min_align=4 R10=fp",
-			/* Variable offset is added to R5, resulting in an
-			 * auxiliary offset of 14, and an auxiliary alignment of 4.
+			{26, "R5=pkt(id=0,off=14,r=8"},
+			/* Variable offset is added to R5, resulting in a
+			 * variable offset of (4n).
 			 */
-			"27: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off_align=4 R5=pkt(id=3,off=0,r=0),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
-			/* Constant is added to R5 again, setting reg->off to 4. */
-			"28: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off_align=4 R5=pkt(id=3,off=4,r=0),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
-			/* And once more we add a variable, which causes an accumulation
-			 * of reg->off into reg->aux_off_align, with resulting value of
-			 * 18.  The auxiliary alignment stays at 4.
+			{27, "R5=pkt(id=3,off=14,r=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			/* Constant is added to R5 again, setting reg->off to 18. */
+			{28, "R5=pkt(id=3,off=18,r=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			/* And once more we add a variable; resulting var_off
+			 * is still (4n), fixed offset is not changed.
+			 * Also, we create a new reg->id.
 			 */
-			"29: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off_align=4 R5=pkt(id=4,off=0,r=0),aux_off=18,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+			{29, "R5=pkt(id=4,off=18,r=0,umax_value=2040,var_off=(0x0; 0x7fc))"},
 			/* At the time the word size load is performed from R5,
-			 * it's total offset is NET_IP_ALIGN + reg->off (0) +
-			 * reg->aux_off (18) which is 20.  Then the variable offset
-			 * is considered using reg->aux_off_align which is 4 and meets
-			 * the load's requirements.
+			 * its total fixed offset is NET_IP_ALIGN + reg->off (18)
+			 * which is 20.  Then the variable offset is (4n), so
+			 * the total offset is 4-byte aligned and meets the
+			 * load's requirements.
 			 */
-			"33: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=pkt(id=4,off=4,r=4),aux_off=18,aux_off_align=4 R5=pkt(id=4,off=0,r=4),aux_off=18,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+			{33, "R4=pkt(id=4,off=22,r=22,umax_value=2040,var_off=(0x0; 0x7fc))"},
+			{33, "R5=pkt(id=4,off=18,r=22,umax_value=2040,var_off=(0x0; 0x7fc))"},
 		},
 	},
 };
@@ -373,6 +392,9 @@ static int do_test_single(struct bpf_align_test *test)
 {
 	struct bpf_insn *prog = test->insns;
 	int prog_type = test->prog_type;
+	char bpf_vlog_copy[32768];
+	const char *line_ptr;
+	int cur_line = -1;
 	int prog_len, i;
 	int fd_prog;
 	int ret;
@@ -387,14 +409,31 @@ static int do_test_single(struct bpf_align_test *test)
 		ret = 1;
 	} else {
 		ret = 0;
+		/* We make a local copy so that we can strtok() it */
+		strncpy(bpf_vlog_copy, bpf_vlog, sizeof(bpf_vlog_copy));
+		line_ptr = strtok(bpf_vlog_copy, "\n");
 		for (i = 0; i < MAX_MATCHES; i++) {
-			const char *t, *m = test->matches[i];
+			struct bpf_reg_match m = test->matches[i];
 
-			if (!m)
+			if (!m.match)
 				break;
-			t = strstr(bpf_vlog, m);
-			if (!t) {
-				printf("Failed to find match: %s\n", m);
+			while (line_ptr) {
+				cur_line = -1;
+				sscanf(line_ptr, "%u: ", &cur_line);
+				if (cur_line == m.line)
+					break;
+				line_ptr = strtok(NULL, "\n");
+			}
+			if (!line_ptr) {
+				printf("Failed to find line %u for match: %s\n",
+				       m.line, m.match);
+				ret = 1;
+				printf("%s", bpf_vlog);
+				break;
+			}
+			if (!strstr(line_ptr, m.match)) {
+				printf("Failed to find match %u: %s\n",
+				       m.line, m.match);
 				ret = 1;
 				printf("%s", bpf_vlog);
 				break;
