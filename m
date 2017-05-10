From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf pointer alignment validation
Date: Tue, 9 May 2017 22:57:37 -0700
Message-ID: <20170510055735.hfkoh4w3xaka5yl5@ast-mbp>
References: <20170505.162044.2097924822206705957.davem@davemloft.net>
 <20170505.224709.1156323937148435706.davem@davemloft.net>
 <59104D35.8080108@iogearbox.net>
 <20170509.143234.1785658771452710730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33839 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750986AbdEJF5q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 01:57:46 -0400
Received: by mail-pg0-f46.google.com with SMTP id u28so11168750pgn.1
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 22:57:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170509.143234.1785658771452710730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 09, 2017 at 02:32:34PM -0400, David Miller wrote:
>  
> +static u32 calc_align(u32 imm)
> +{
> +	u32 align = 1;
> +
> +	if (!imm)
> +		return 1U << 31;
> +
> +	while (!(imm & 1)) {
> +		imm >>= 1;
> +		align <<= 1;
> +	}
> +	return align;
> +}

same question as in previous reply.
Why not to use something like:
static u32 calc_align(u32 n)
{
        if (!n)
                return 1U << 31;
        return n - ((n - 1) & n);
}

> -		if (log_level && do_print_state) {
> +		if (log_level > 1 || (log_level && do_print_state)) {
>  			verbose("\nfrom %d to %d:", prev_insn_idx, insn_idx);
>  			print_verifier_state(&env->cur_state);
>  			do_print_state = false;

this needs to be tweaked like
if (log_level > 1)
        verbose("%d:", insn_idx);
else
	verbose("\nfrom %d to %d:", prev_insn_idx, insn_idx);

otherwise it prints prev_insn_idx which is meaningful
only with processing exit and search pruning.
That's why below ...

> +		.descr = "unknown shift",
> +		.insns = {
> +			LOAD_UNKNOWN(BPF_REG_3),
> +			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
> +			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
> +			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
> +			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
> +			LOAD_UNKNOWN(BPF_REG_4),
> +			BPF_ALU64_IMM(BPF_LSH, BPF_REG_4, 5),
> +			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
> +			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
> +			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
> +			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
> +			BPF_MOV64_IMM(BPF_REG_0, 0),
> +			BPF_EXIT_INSN(),
> +		},
> +		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
> +		.matches = {
> +			"from 4 to 7: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R10=fp",
> +			"from 4 to 8: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv55,min_align=2 R10=fp",
> +			"from 4 to 9: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv54,min_align=4 R10=fp",
> +			"from 4 to 10: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv53,min_align=8 R10=fp",
> +			"from 4 to 11: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv52,min_align=16 R10=fp",
> +			"from 15 to 18: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv56 R10=fp",
> +			"from 15 to 19: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv51,min_align=32 R10=fp",
> +			"from 15 to 20: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv52,min_align=16 R10=fp",

... looks crazy here, since program is linear and 'from 4' and 'from 15' are
completely non-obvious and will change in the future for sure.
Since it just happened that search pruning heuristic kicked in at those points.
Hence doing verbose("%d:", insn_idx); is necessary to avoid noise.

> +		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
> +		.matches = {
> +			/* Calculated offset in R4 has unknown value, but known
> +			 * alignment of 4.
> +			 */
> +			"from 4 to 8: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R6=inv54,min_align=4 R10=fp",
> +
> +			/* Offset is added to packet pointer, resulting in known
> +			 * auxiliary alignment and offset.
> +			 */
> +			"from 4 to 11: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R5=pkt(id=1,off=0,r=0),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
> +
> +			/* At the time the word size load is performed from R5,
> +			 * it's total offset is NET_IP_ALIGN + reg->off (0) +
> +			 * reg->aux_off (14) which is 16.  Then the variable
> +			 * offset is considered using reg->aux_off_align which
> +			 * is 4 and meets the load's requirements.
> +			 */
> +			"from 13 to 15: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=pkt(id=1,off=4,r=4),aux_off=14,aux_off_align=4 R5=pkt(id=1,off=0,r=4),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
> +
> +
> +			/* Variable offset is added to R5 packet pointer,
> +			 * resulting in auxiliary alignment of 4.
> +			 */
> +			"from 13 to 18: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off=14,aux_off_align=4 R5=pkt(id=2,off=0,r=0),aux_off_align=4 R6=inv54,min_align=4 R10=fp",
> +
> +			/* Constant offset is added to R5, resulting in
> +			 * reg->off of 14.
> +			 */
> +			"from 13 to 19: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off=14,aux_off_align=4 R5=pkt(id=2,off=14,r=0),aux_off_align=4 R6=inv54,min_align=4 R10=fp",
> +
> +			/* At the time the word size load is performed from R5,
> +			 * it's total offset is NET_IP_ALIGN + reg->off (14) which
> +			 * is 16.  Then the variable offset is considered using
> +			 * reg->aux_off_align which is 4 and meets the load's
> +			 * requirements.
> +			 */
> +			"from 21 to 23: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=pkt(id=2,off=18,r=18),aux_off_align=4 R5=pkt(id=2,off=14,r=18),aux_off_align=4 R6=inv54,min_align=4 R10=fp",

Nice to see all these comments.
I wonder how we can make them automatic in the verifier.
Like if verifier can somehow hint the user in such human friendly way
about what is happening with the program.
Today that's the #1 problem. Most folks complaining
that verifier error messages are too hard to understand.
CTF should help. Proper data-flow analysis in the verifier should help too.

> +static int do_test_single(struct bpf_align_test *test)
> +{
> +	struct bpf_insn *prog = test->insns;
> +	int prog_type = test->prog_type;
> +	int prog_len, i;
> +	int fd_prog;
> +	int ret;
> +
> +	prog_len = probe_filter_length(prog);
> +	fd_prog = bpf_verify_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
> +				     prog, prog_len, "GPL", 0,
> +				     bpf_vlog, sizeof(bpf_vlog));
> +	if (fd_prog < 0) {
> +		printf("Failed to load program.\n");
> +		printf("%s", bpf_vlog);
> +		ret = 1;
> +	} else {
> +		ret = 0;
> +		for (i = 0; i < MAX_MATCHES; i++) {
> +			const char *t, *m = test->matches[i];
> +
> +			if (!m)
> +				break;
> +			t = strstr(bpf_vlog, m);
> +			if (!t) {
> +				printf("Failed to find match: %s\n", m);
> +				ret = 1;
> +				printf("%s", bpf_vlog);
> +				break;
> +			}
> +		}
> +		/* printf("%s", bpf_vlog); */
> +		close(fd_prog);

would it make sense to bpf_prog_test_run() it here as well?
On x86 not much value, but on sparc we can somehow look for traps?
Is there some counter of unaligned traps that we can read and report
as error to user space after prog_test_run ?
These tests we cannot really run, since they don't do any load/store.
I mean more for some future tests. Or some sort of debug warn
that there were traps while bpf prog was executed, so the user
is alarmed and reports to us, since that would be a bug in verifier
align logic?
