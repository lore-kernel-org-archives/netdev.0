From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net] bpf: fix byte order test in test_verifier
Date: Fri, 4 Aug 2017 15:26:59 -0700
Message-ID: <21522bb6-1b9d-8f4b-ff29-352959ae57f1@fb.com>
References: <2914429672dfe6d0420a81dff36853326a7f604d.1501877778.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33250 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752707AbdHDW1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 18:27:37 -0400
In-Reply-To: <2914429672dfe6d0420a81dff36853326a7f604d.1501877778.git.daniel@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 8/4/17 1:24 PM, Daniel Borkmann wrote:
> We really must check with #if __BYTE_ORDER == XYZ instead of
> just presence of #ifdef __LITTLE_ENDIAN. I noticed that when
> actually running this on big endian machine, the latter test
> resolves to true for user space, same for #ifdef __BIG_ENDIAN.
> 
> E.g., looking at endian.h from libc, both are also defined
> there, so we really must test this against __BYTE_ORDER instead
> for proper insns selection. For the kernel, such checks are
> fine though e.g. see 13da9e200fe4 ("Revert "endian: #define
> __BYTE_ORDER"") and 415586c9e6d3 ("UAPI: fix endianness conditionals
> in M32R's asm/stat.h") for some more context, but not for
> user space. Lets also make sure to properly include endian.h.
> After that, suite passes for me:
> 
> ./test_verifier: ELF 64-bit MSB executable, [...]
> 
> Linux foo 4.13.0-rc3+ #4 SMP Fri Aug 4 06:59:30 EDT 2017 s390x s390x s390x GNU/Linux
> 
> Before fix: Summary: 505 PASSED, 11 FAILED
> After  fix: Summary: 516 PASSED,  0 FAILED
> 
> Fixes: 18f3d6be6be1 ("selftests/bpf: Add test cases to test narrower ctx field loads")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>   tools/testing/selftests/bpf/test_verifier.c | 19 ++++++++++---------
>   1 file changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
> index addea82..d3ed732 100644
> --- a/tools/testing/selftests/bpf/test_verifier.c
> +++ b/tools/testing/selftests/bpf/test_verifier.c
> @@ -8,6 +8,7 @@
>    * License as published by the Free Software Foundation.
>    */
>   
> +#include <endian.h>
>   #include <asm/types.h>
>   #include <linux/types.h>
>   #include <stdint.h>
> @@ -1098,7 +1099,7 @@ struct test_val {
>   		"check skb->hash byte load permitted",
>   		.insns = {
>   			BPF_MOV64_IMM(BPF_REG_0, 0),
> -#ifdef __LITTLE_ENDIAN
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
>   			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
>   				    offsetof(struct __sk_buff, hash)),
>   #else
> @@ -1135,7 +1136,7 @@ struct test_val {
>   		"check skb->hash byte load not permitted 3",
>   		.insns = {
>   			BPF_MOV64_IMM(BPF_REG_0, 0),
> -#ifdef __LITTLE_ENDIAN
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
>   			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
>   				    offsetof(struct __sk_buff, hash) + 3),
>   #else
> @@ -1244,7 +1245,7 @@ struct test_val {
>   		"check skb->hash half load permitted",
>   		.insns = {
>   			BPF_MOV64_IMM(BPF_REG_0, 0),
> -#ifdef __LITTLE_ENDIAN
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
>   			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
>   				    offsetof(struct __sk_buff, hash)),
>   #else
> @@ -1259,7 +1260,7 @@ struct test_val {
>   		"check skb->hash half load not permitted",
>   		.insns = {
>   			BPF_MOV64_IMM(BPF_REG_0, 0),
> -#ifdef __LITTLE_ENDIAN
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
>   			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
>   				    offsetof(struct __sk_buff, hash) + 2),
>   #else
> @@ -5422,7 +5423,7 @@ struct test_val {
>   		"check bpf_perf_event_data->sample_period byte load permitted",
>   		.insns = {
>   			BPF_MOV64_IMM(BPF_REG_0, 0),
> -#ifdef __LITTLE_ENDIAN
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
>   			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
>   				    offsetof(struct bpf_perf_event_data, sample_period)),
>   #else
> @@ -5438,7 +5439,7 @@ struct test_val {
>   		"check bpf_perf_event_data->sample_period half load permitted",
>   		.insns = {
>   			BPF_MOV64_IMM(BPF_REG_0, 0),
> -#ifdef __LITTLE_ENDIAN
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
>   			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
>   				    offsetof(struct bpf_perf_event_data, sample_period)),
>   #else
> @@ -5454,7 +5455,7 @@ struct test_val {
>   		"check bpf_perf_event_data->sample_period word load permitted",
>   		.insns = {
>   			BPF_MOV64_IMM(BPF_REG_0, 0),
> -#ifdef __LITTLE_ENDIAN
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
>   			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
>   				    offsetof(struct bpf_perf_event_data, sample_period)),
>   #else
> @@ -5481,7 +5482,7 @@ struct test_val {
>   		"check skb->data half load not permitted",
>   		.insns = {
>   			BPF_MOV64_IMM(BPF_REG_0, 0),
> -#ifdef __LITTLE_ENDIAN
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
>   			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
>   				    offsetof(struct __sk_buff, data)),
>   #else
> @@ -5497,7 +5498,7 @@ struct test_val {
>   		"check skb->tc_classid half load not permitted for lwt prog",
>   		.insns = {
>   			BPF_MOV64_IMM(BPF_REG_0, 0),
> -#ifdef __LITTLE_ENDIAN
> +#if __BYTE_ORDER == __LITTLE_ENDIAN
>   			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
>   				    offsetof(struct __sk_buff, tc_classid)),
>   #else
> 

The change looks good to me.
Acked-by: Yonghong <yhs@fb.com>
