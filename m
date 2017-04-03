From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 3 Apr 2017 12:07:48 +1000
Message-ID: <20170403120748.2d11f2b0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        Martin KaFai Lau <kafai@fb.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got conflicts in:

  tools/testing/selftests/bpf/Makefile
  tools/testing/selftests/bpf/test_verifier.c

between commit:

  02ea80b1850e ("bpf: add various verifier test cases for self-tests")

from the net tree and commits:

  6882804c916b ("selftests/bpf: add a test for overlapping packet range checks")
  fb30d4b71214 ("bpf: Add tests for map-in-map")

from the net-next tree.

I fixed it up (see below - though there are probably more fixups needed)
and can carry the fix as necessary. This is now fixed as far as
linux-next is concerned, but any non trivial conflicts should be
mentioned to your upstream maintainer when your tree is submitted for
merging.  You may also want to consider cooperating with the maintainer
of the conflicting tree to minimise any particularly complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc tools/testing/selftests/bpf/Makefile
index 9af09e8099c0,32fb7a294f0f..000000000000
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@@ -1,17 -1,12 +1,19 @@@
  LIBDIR := ../../../lib
  BPFDIR := $(LIBDIR)/bpf
 +APIDIR := ../../../include/uapi
 +GENDIR := ../../../../include/generated
 +GENHDR := $(GENDIR)/autoconf.h
  
 -CFLAGS += -Wall -O2 -I../../../include/uapi -I$(LIBDIR) -I../../../include
 +ifneq ($(wildcard $(GENHDR)),)
 +  GENFLAGS := -DHAVE_GENHDR
 +endif
 +
- CFLAGS += -Wall -O2 -I$(APIDIR) -I$(LIBDIR) -I$(GENDIR) $(GENFLAGS)
- LDLIBS += -lcap
++CFLAGS += -Wall -O2 -I$(APIDIR) -I$(LIBDIR) -I$(GENDIR) -I../../../include $(GENFLAGS)
+ LDLIBS += -lcap -lelf
  
- TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map
+ TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs
+ 
+ TEST_GEN_FILES = test_pkt_access.o test_xdp.o test_l4lb.o
  
  TEST_PROGS := test_kmod.sh
  
diff --cc tools/testing/selftests/bpf/test_verifier.c
index c848e90b6421,f4f43c98cf7f..000000000000
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@@ -46,9 -38,8 +46,10 @@@
  
  #define MAX_INSNS	512
  #define MAX_FIXUPS	8
+ #define MAX_NR_MAPS	4
  
 +#define F_NEEDS_EFFICIENT_UNALIGNED_ACCESS	(1 << 0)
 +
  struct bpf_test {
  	const char *descr;
  	struct bpf_insn	insns[MAX_INSNS];
@@@ -4719,8 -4454,76 +4721,77 @@@ static struct bpf_test tests[] = 
  		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
  		.result = REJECT,
  		.result_unpriv = REJECT,
 +		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
- 	}
+ 	},
+ 	{
+ 		"map in map access",
+ 		.insns = {
+ 			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+ 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+ 			BPF_LD_MAP_FD(BPF_REG_1, 0),
+ 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+ 				     BPF_FUNC_map_lookup_elem),
+ 			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+ 			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+ 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+ 			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+ 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+ 				     BPF_FUNC_map_lookup_elem),
+ 			BPF_MOV64_REG(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.fixup_map_in_map = { 3 },
+ 		.result = ACCEPT,
+ 	},
+ 	{
+ 		"invalid inner map pointer",
+ 		.insns = {
+ 			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+ 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+ 			BPF_LD_MAP_FD(BPF_REG_1, 0),
+ 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+ 				     BPF_FUNC_map_lookup_elem),
+ 			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+ 			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+ 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+ 			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
+ 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+ 				     BPF_FUNC_map_lookup_elem),
+ 			BPF_MOV64_REG(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.fixup_map_in_map = { 3 },
+ 		.errstr = "R1 type=inv expected=map_ptr",
+ 		.errstr_unpriv = "R1 pointer arithmetic prohibited",
+ 		.result = REJECT,
+ 	},
+ 	{
+ 		"forgot null checking on the inner map pointer",
+ 		.insns = {
+ 			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+ 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+ 			BPF_LD_MAP_FD(BPF_REG_1, 0),
+ 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+ 				     BPF_FUNC_map_lookup_elem),
+ 			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+ 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+ 			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+ 			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+ 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+ 				     BPF_FUNC_map_lookup_elem),
+ 			BPF_MOV64_REG(BPF_REG_0, 0),
+ 			BPF_EXIT_INSN(),
+ 		},
+ 		.fixup_map_in_map = { 3 },
+ 		.errstr = "R1 type=map_value_or_null expected=map_ptr",
+ 		.result = REJECT,
+ 	},
  };
  
  static int probe_filter_length(const struct bpf_insn *fp)
@@@ -4802,10 -4635,15 +4904,14 @@@ static void do_test_single(struct bpf_t
  	struct bpf_insn *prog = test->insns;
  	int prog_len = probe_filter_length(prog);
  	int prog_type = test->prog_type;
- 	int fd_f1 = -1, fd_f2 = -1, fd_f3 = -1;
+ 	int map_fds[MAX_NR_MAPS];
 -	int fd_prog, expected_ret;
  	const char *expected_err;
+ 	int i;
+ 
+ 	for (i = 0; i < MAX_NR_MAPS; i++)
+ 		map_fds[i] = -1;
  
- 	do_test_fixup(test, prog, &fd_f1, &fd_f2, &fd_f3);
+ 	do_test_fixup(test, prog, map_fds);
  
  	fd_prog = bpf_load_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
  				   prog, prog_len, "GPL", 0, bpf_vlog,
@@@ -4844,13 -4671,11 +4950,12 @@@
  	}
  
  	(*passes)++;
 -	printf("OK\n");
 +	printf("OK%s\n", reject_from_alignment ?
 +	       " (NOTE: reject due to unknown alignment)" : "");
  close_fds:
  	close(fd_prog);
- 	close(fd_f1);
- 	close(fd_f2);
- 	close(fd_f3);
+ 	for (i = 0; i < MAX_NR_MAPS; i++)
+ 		close(map_fds[i]);
  	sched_yield();
  	return;
  fail_log:
