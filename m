From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH V2 net-next 6/6] test_bpf: add tests checking that JIT/interpreter sets A and X to 0.
Date: Tue,  4 Aug 2015 15:19:12 +0200
Message-ID: <1438694352-17469-7-git-send-email-nschichan@freebox.fr>
References: <1438694352-17469-1-git-send-email-nschichan@freebox.fr>
Cc: Nicolas Schichan <nschichan@freebox.fr>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:33917 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934180AbbHDNUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 09:20:09 -0400
In-Reply-To: <1438694352-17469-1-git-send-email-nschichan@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is mandatory for the JIT or interpreter to reset the A and X
registers to 0 before running the filter. Check that it is the case on
various ALU and JMP instructions.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>

---
 lib/test_bpf.c | 158 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 158 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index e6ef56d..d137739 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4931,6 +4931,164 @@ static struct bpf_test tests[] = {
 		},
 		{ {0x40, 0x88ee99ff } },
 	},
+	/*
+	 * verify that the interpreter or JIT correctly sets A and X
+	 * to 0.
+	 */
+	{
+		"ADD default X",
+		.u.insns = {
+			/*
+			 * A = 0x42
+			 * A = A + X
+			 * ret A
+			 */
+			BPF_STMT(BPF_LD | BPF_IMM, 0x42),
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x42 } },
+	},
+	{
+		"ADD default A",
+		.u.insns = {
+			/*
+			 * A = A + 0x42
+			 * ret A
+			 */
+			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 0x42),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x42 } },
+	},
+	{
+		"SUB default X",
+		.u.insns = {
+			/*
+			 * A = 0x66
+			 * A = A - X
+			 * ret A
+			 */
+			BPF_STMT(BPF_LD | BPF_IMM, 0x66),
+			BPF_STMT(BPF_ALU | BPF_SUB | BPF_X, 0),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x66 } },
+	},
+	{
+		"SUB default A",
+		.u.insns = {
+			/*
+			 * A = A - -0x66
+			 * ret A
+			 */
+			BPF_STMT(BPF_ALU | BPF_SUB | BPF_K, -0x66),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x66 } },
+	},
+	{
+		"MUL default X",
+		.u.insns = {
+			/*
+			 * A = 0x42
+			 * A = A * X
+			 * ret A
+			 */
+			BPF_STMT(BPF_LD | BPF_IMM, 0x42),
+			BPF_STMT(BPF_ALU | BPF_MUL | BPF_X, 0),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x0 } },
+	},
+	{
+		"MUL default A",
+		.u.insns = {
+			/*
+			 * A = A * 0x66
+			 * ret A
+			 */
+			BPF_STMT(BPF_ALU | BPF_MUL | BPF_K, 0x66),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x0 } },
+	},
+	{
+		"DIV default X",
+		.u.insns = {
+			/*
+			 * A = 0x42
+			 * A = A / X ; this halt the filter execution if X is 0
+			 * ret 0x42
+			 */
+			BPF_STMT(BPF_LD | BPF_IMM, 0x42),
+			BPF_STMT(BPF_ALU | BPF_DIV | BPF_X, 0),
+			BPF_STMT(BPF_RET | BPF_K, 0x42),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x0 } },
+	},
+	{
+		"DIV default A",
+		.u.insns = {
+			/*
+			 * A = A / 1
+			 * ret A
+			 */
+			BPF_STMT(BPF_ALU | BPF_DIV | BPF_K, 0x1),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x0 } },
+	},
+	{
+		"JMP EQ default A",
+		.u.insns = {
+			/*
+			 * cmp A, 0x0, 0, 1
+			 * ret 0x42
+			 * ret 0x66
+			 */
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0x0, 0, 1),
+			BPF_STMT(BPF_RET | BPF_K, 0x42),
+			BPF_STMT(BPF_RET | BPF_K, 0x66),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x42 } },
+	},
+	{
+		"JMP EQ default X",
+		.u.insns = {
+			/*
+			 * A = 0x0
+			 * cmp A, X, 0, 1
+			 * ret 0x42
+			 * ret 0x66
+			 */
+			BPF_STMT(BPF_LD | BPF_IMM, 0x0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_X, 0x0, 0, 1),
+			BPF_STMT(BPF_RET | BPF_K, 0x42),
+			BPF_STMT(BPF_RET | BPF_K, 0x66),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x42 } },
+	},
 };
 
 static struct net_device dev;
-- 
1.9.1
