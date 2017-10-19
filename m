From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 19 Oct 2017 14:05:30 +0100
Message-ID: <20171019130530.ipxwriotybk3ofbd@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="fnkulj3de4kcda5w"
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from heliosphere.sirena.org.uk ([172.104.155.198]:52996 "EHLO
        heliosphere.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752099AbdJSNFy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 09:05:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fnkulj3de4kcda5w
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  tools/testing/selftests/bpf/test_verifier.c

between commit:

  28e33f9d78eef ("bpf: disallow arithmetic operations on context pointer")

=66rom the net tree and commit:

  22c8852624fc9 ("bpf: improve selftests and add tests for meta pointer")

=66rom the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

diff --cc tools/testing/selftests/bpf/test_verifier.c
index 3c7d3a45a3c5,cc91d0159f43..000000000000
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@@ -6645,20 -6645,325 +6645,339 @@@ static struct bpf_test tests[] =3D=20
  		.errstr =3D "BPF_END uses reserved fields",
  		.result =3D REJECT,
  	},
 +	{
 +		"arithmetic ops make PTR_TO_CTX unusable",
 +		.insns =3D {
 +			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1,
 +				      offsetof(struct __sk_buff, data) -
 +				      offsetof(struct __sk_buff, mark)),
 +			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
 +				    offsetof(struct __sk_buff, mark)),
 +			BPF_EXIT_INSN(),
 +		},
 +		.errstr =3D "dereference of modified ctx ptr R1 off=3D68+8, ctx+const i=
s allowed, ctx+const+const is not",
 +		.result =3D REJECT,
 +		.prog_type =3D BPF_PROG_TYPE_SCHED_CLS,
 +	},
+ 	{
+ 		"meta access, test1",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D ACCEPT,
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test2",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_SUB, BPF_REG_0, 8),
+ 			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_0, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D REJECT,
+ 		.errstr =3D "invalid access to packet, off=3D-8",
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test3",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_end)),
+ 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D REJECT,
+ 		.errstr =3D "invalid access to packet",
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test4",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_end)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_4),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D REJECT,
+ 		.errstr =3D "invalid access to packet",
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test5",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_3),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_4, 3),
+ 			BPF_MOV64_IMM(BPF_REG_2, -8),
+ 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+ 				     BPF_FUNC_xdp_adjust_meta),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_3, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D REJECT,
+ 		.errstr =3D "R3 !read_ok",
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test6",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_3),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+ 			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_0, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D REJECT,
+ 		.errstr =3D "invalid access to packet",
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test7",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_3),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+ 			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D ACCEPT,
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test8",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0xFFFF),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D ACCEPT,
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test9",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 0xFFFF),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 1),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D REJECT,
+ 		.errstr =3D "invalid access to packet",
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test10",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_end)),
+ 			BPF_MOV64_IMM(BPF_REG_5, 42),
+ 			BPF_MOV64_IMM(BPF_REG_6, 24),
+ 			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_5, -8),
+ 			BPF_STX_XADD(BPF_DW, BPF_REG_10, BPF_REG_6, -8),
+ 			BPF_LDX_MEM(BPF_DW, BPF_REG_5, BPF_REG_10, -8),
+ 			BPF_JMP_IMM(BPF_JGT, BPF_REG_5, 100, 6),
+ 			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_5),
+ 			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
+ 			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 8),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_6, BPF_REG_5, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_2, BPF_REG_2, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D REJECT,
+ 		.errstr =3D "invalid access to packet",
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test11",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_MOV64_IMM(BPF_REG_5, 42),
+ 			BPF_MOV64_IMM(BPF_REG_6, 24),
+ 			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_5, -8),
+ 			BPF_STX_XADD(BPF_DW, BPF_REG_10, BPF_REG_6, -8),
+ 			BPF_LDX_MEM(BPF_DW, BPF_REG_5, BPF_REG_10, -8),
+ 			BPF_JMP_IMM(BPF_JGT, BPF_REG_5, 100, 6),
+ 			BPF_ALU64_REG(BPF_ADD, BPF_REG_2, BPF_REG_5),
+ 			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+ 			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 8),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_6, BPF_REG_3, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_5, BPF_REG_5, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D ACCEPT,
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"meta access, test12",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_meta)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data)),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+ 				    offsetof(struct xdp_md, data_end)),
+ 			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 16),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_4, 5),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_3, 0),
+ 			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 16),
+ 			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_3, 1),
+ 			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+ 			BPF_MOV64_IMM(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D ACCEPT,
+ 		.prog_type =3D BPF_PROG_TYPE_XDP,
+ 	},
+ 	{
+ 		"bpf_exit with invalid return code. test1",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.errstr =3D "R0 has value (0x0; 0xffffffff)",
+ 		.result =3D REJECT,
+ 		.prog_type =3D BPF_PROG_TYPE_CGROUP_SOCK,
+ 	},
+ 	{
+ 		"bpf_exit with invalid return code. test2",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+ 			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 1),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D ACCEPT,
+ 		.prog_type =3D BPF_PROG_TYPE_CGROUP_SOCK,
+ 	},
+ 	{
+ 		"bpf_exit with invalid return code. test3",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+ 			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 3),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.errstr =3D "R0 has value (0x0; 0x3)",
+ 		.result =3D REJECT,
+ 		.prog_type =3D BPF_PROG_TYPE_CGROUP_SOCK,
+ 	},
+ 	{
+ 		"bpf_exit with invalid return code. test4",
+ 		.insns =3D {
+ 			BPF_MOV64_IMM(BPF_REG_0, 1),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.result =3D ACCEPT,
+ 		.prog_type =3D BPF_PROG_TYPE_CGROUP_SOCK,
+ 	},
+ 	{
+ 		"bpf_exit with invalid return code. test5",
+ 		.insns =3D {
+ 			BPF_MOV64_IMM(BPF_REG_0, 2),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.errstr =3D "R0 has value (0x2; 0x0)",
+ 		.result =3D REJECT,
+ 		.prog_type =3D BPF_PROG_TYPE_CGROUP_SOCK,
+ 	},
+ 	{
+ 		"bpf_exit with invalid return code. test6",
+ 		.insns =3D {
+ 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.errstr =3D "R0 is not a known value (ctx)",
+ 		.result =3D REJECT,
+ 		.prog_type =3D BPF_PROG_TYPE_CGROUP_SOCK,
+ 	},
+ 	{
+ 		"bpf_exit with invalid return code. test7",
+ 		.insns =3D {
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+ 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 4),
+ 			BPF_ALU64_REG(BPF_MUL, BPF_REG_0, BPF_REG_2),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.errstr =3D "R0 has unknown scalar value",
+ 		.result =3D REJECT,
+ 		.prog_type =3D BPF_PROG_TYPE_CGROUP_SOCK,
+ 	},
  };
 =20
  static int probe_filter_length(const struct bpf_insn *fp)

--fnkulj3de4kcda5w
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlnooxoACgkQJNaLcl1U
h9BwDQf/S4sDok9QxdzhqGQfb0Kuv1p+5gTBDRNWSUSmI1Fy9z98C2IaivQjpUWS
fT6AJLcN3go4onhy/1cj82jnayvl6ZDWJeb5I2ROySFtaBSOse3rQfIhGR7DBsfJ
Pn7eeguKdPknpnNPWe/JbADXatWZxlOPQMDpJqSVNknwDi3qpeMJNWD+oDu3SSte
Z90kwrNMua7N5/ATdVbDZZy5DVtZ3Gael+W18CNYkYkXcomRCtGbSETsayUcDO1q
stu1btvxSzBTfvR/rOsbGXmSMx6fgwhWR2x06+IXT5HD2BdANGj0eO1oT2Bacqma
zoz8uqt4f6vh1and9WL5/N6L3uy6MQ==
=MYE/
-----END PGP SIGNATURE-----

--fnkulj3de4kcda5w--
