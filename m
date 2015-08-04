From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH V2 net-next 3/6] test_bpf: test LD_ABS and LD_IND instructions on fragmented skbs.
Date: Tue,  4 Aug 2015 15:19:09 +0200
Message-ID: <1438694352-17469-4-git-send-email-nschichan@freebox.fr>
References: <1438694352-17469-1-git-send-email-nschichan@freebox.fr>
Cc: Nicolas Schichan <nschichan@freebox.fr>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438694352-17469-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These new tests exercise various load sizes and offsets crossing the
head/fragment boundary.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>

---
 lib/test_bpf.c | 142 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 142 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index e261751..f18b7b8 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4493,6 +4493,148 @@ static struct bpf_test tests[] = {
 		{ { 1, 0xbef } },
 		.fill_helper = bpf_fill_ld_abs_vlan_push_pop,
 	},
+	/*
+	 * LD_IND / LD_ABS on fragmented SKBs
+	 */
+	{
+		"LD_IND byte frag",
+		.u.insns = {
+			BPF_STMT(BPF_LDX | BPF_IMM, 0x40),
+			BPF_STMT(BPF_LD | BPF_IND | BPF_B, 0x0),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ },
+		{ {0x40, 0x42} },
+		.frag_data = {
+			0x42, 0x00, 0x00, 0x00,
+			0x43, 0x44, 0x00, 0x00,
+			0x21, 0x07, 0x19, 0x83,
+		},
+	},
+	{
+		"LD_IND halfword frag",
+		.u.insns = {
+			BPF_STMT(BPF_LDX | BPF_IMM, 0x40),
+			BPF_STMT(BPF_LD | BPF_IND | BPF_H, 0x4),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ },
+		{ {0x40, 0x4344} },
+		.frag_data = {
+			0x42, 0x00, 0x00, 0x00,
+			0x43, 0x44, 0x00, 0x00,
+			0x21, 0x07, 0x19, 0x83,
+		},
+	},
+	{
+		"LD_IND word frag",
+		.u.insns = {
+			BPF_STMT(BPF_LDX | BPF_IMM, 0x40),
+			BPF_STMT(BPF_LD | BPF_IND | BPF_W, 0x8),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ },
+		{ {0x40, 0x21071983} },
+		.frag_data = {
+			0x42, 0x00, 0x00, 0x00,
+			0x43, 0x44, 0x00, 0x00,
+			0x21, 0x07, 0x19, 0x83,
+		},
+	},
+	{
+		"LD_IND halfword mixed head/frag",
+		.u.insns = {
+			BPF_STMT(BPF_LDX | BPF_IMM, 0x40),
+			BPF_STMT(BPF_LD | BPF_IND | BPF_H, -0x1),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ [0x3e] = 0x25, [0x3f] = 0x05, },
+		{ {0x40, 0x0519} },
+		.frag_data = { 0x19, 0x82 },
+	},
+	{
+		"LD_IND word mixed head/frag",
+		.u.insns = {
+			BPF_STMT(BPF_LDX | BPF_IMM, 0x40),
+			BPF_STMT(BPF_LD | BPF_IND | BPF_W, -0x2),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ [0x3e] = 0x25, [0x3f] = 0x05, },
+		{ {0x40, 0x25051982} },
+		.frag_data = { 0x19, 0x82 },
+	},
+	{
+		"LD_ABS byte frag",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_ABS | BPF_B, 0x40),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ },
+		{ {0x40, 0x42} },
+		.frag_data = {
+			0x42, 0x00, 0x00, 0x00,
+			0x43, 0x44, 0x00, 0x00,
+			0x21, 0x07, 0x19, 0x83,
+		},
+	},
+	{
+		"LD_ABS halfword frag",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_ABS | BPF_H, 0x44),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ },
+		{ {0x40, 0x4344} },
+		.frag_data = {
+			0x42, 0x00, 0x00, 0x00,
+			0x43, 0x44, 0x00, 0x00,
+			0x21, 0x07, 0x19, 0x83,
+		},
+	},
+	{
+		"LD_ABS word frag",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_ABS | BPF_W, 0x48),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ },
+		{ {0x40, 0x21071983} },
+		.frag_data = {
+			0x42, 0x00, 0x00, 0x00,
+			0x43, 0x44, 0x00, 0x00,
+			0x21, 0x07, 0x19, 0x83,
+		},
+	},
+	{
+		"LD_ABS halfword mixed head/frag",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_ABS | BPF_H, 0x3f),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ [0x3e] = 0x25, [0x3f] = 0x05, },
+		{ {0x40, 0x0519} },
+		.frag_data = { 0x19, 0x82 },
+	},
+	{
+		"LD_ABS word mixed head/frag",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_ABS | BPF_W, 0x3e),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_SKB_FRAG,
+		{ [0x3e] = 0x25, [0x3f] = 0x05, },
+		{ {0x40, 0x25051982} },
+		.frag_data = { 0x19, 0x82 },
+	},
 };
 
 static struct net_device dev;
-- 
1.9.1
