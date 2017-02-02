From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf: test for AND edge cases
Date: Thu, 2 Feb 2017 10:07:28 -0800
Message-ID: <58937560.7060401@fb.com>
References: <1486054838-5072-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Josef Bacik <jbacik@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>, <jannh@google.com>, <daniel@iogearbox.net>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35165 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752247AbdBBSH7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 13:07:59 -0500
In-Reply-To: <1486054838-5072-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/17 9:00 AM, Josef Bacik wrote:
> These two tests are based on the work done for f23cc643f9ba.  The first test is
> just a basic one to make sure we don't allow AND'ing negative values, even if it
> would result in a valid index for the array.  The second is a cleaned up version
> of the original testcase provided by Jann Horn that resulted in the commit.
>
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Thanks for the tests! Much appreciated.

> diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
> index 853d7e4..44404f1 100644
> --- a/tools/testing/selftests/bpf/test_verifier.c
> +++ b/tools/testing/selftests/bpf/test_verifier.c
> @@ -2905,6 +2905,61 @@ static struct bpf_test tests[] = {
>   		.result = REJECT,
>   		.errstr = "invalid bpf_context access",
>   	},
> +	{
> +		"invalid and of negative number",
> +		.insns = {
> +			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
> +			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
> +			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
> +			BPF_LD_MAP_FD(BPF_REG_1, 0),
> +			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
> +				     BPF_FUNC_map_lookup_elem),
> +			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
> +			BPF_MOV64_IMM(BPF_REG_1, 6),
> +			BPF_ALU64_IMM(BPF_AND, BPF_REG_1, -4),
> +			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
> +			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
> +			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
> +				   offsetof(struct test_val, foo)),
> +			BPF_EXIT_INSN(),
> +		},
> +		.fixup_map2 = { 3 },
> +		.errstr_unpriv = "R0 pointer arithmetic prohibited",
> +		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",

the errstr doesn't have to compare the whole string. In case we find
typos or adjust the hint message, we'd need to change the test as well,
but I see it's being used as-is in other tests already, so we'll
fix all of them at once when time comes.

Acked-by: Alexei Starovoitov <ast@kernel.org>
