From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net-next 1/2] bpf: Fix test_bpf_obj_id() when the
 bpf_jit_enable sysctl is diabled
Date: Fri, 9 Jun 2017 08:39:24 -0700
Message-ID: <83012d6c-6fc3-6b5d-f784-2706005ec091@fb.com>
References: <20170609053017.2909855-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55194 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751649AbdFIPjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 11:39:44 -0400
In-Reply-To: <20170609053017.2909855-1-kafai@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 6/8/17 10:30 PM, Martin KaFai Lau wrote:
> test_bpf_obj_id() should not expect a non zero jited_prog_len
> to be returned by bpf_obj_get_info_by_fd() when
> net.core.bpf_jit_enable is 0.
> 
> The patch checks for net.core.bpf_jit_enable and
> has different expectation on jited_prog_len.
> 
> This patch also removes the pwd.h header which I forgot
> to remove after making changes.
> 
> Fixes: 95b9afd3987f ("bpf: Test for bpf ID")
> Reported-by: Yonghong Song <yhs@fb.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> ---
>   tools/testing/selftests/bpf/test_progs.c | 19 +++++++++++++++----
>   1 file changed, 15 insertions(+), 4 deletions(-)
> 
> diff --git a/tools/testing/selftests/bpf/test_progs.c b/tools/testing/selftests/bpf/test_progs.c
> index 8189bfc7e277..fec13ab84fca 100644
> --- a/tools/testing/selftests/bpf/test_progs.c
> +++ b/tools/testing/selftests/bpf/test_progs.c
> @@ -23,7 +23,7 @@ typedef __u16 __sum16;
>   #include <sys/wait.h>
>   #include <sys/resource.h>
>   #include <sys/types.h>
> -#include <pwd.h>
> +#include <fcntl.h>
>   
>   #include <linux/bpf.h>
>   #include <linux/err.h>
> @@ -297,6 +297,7 @@ static void test_bpf_obj_id(void)
>   	const __u32 array_key = 0;
>   	const int nr_iters = 2;
>   	const char *file = "./test_obj_id.o";
> +	const char *jit_sysctl = "/proc/sys/net/core/bpf_jit_enable";
>   
>   	struct bpf_object *objs[nr_iters];
>   	int prog_fds[nr_iters], map_fds[nr_iters];
> @@ -305,9 +306,18 @@ static void test_bpf_obj_id(void)
>   	struct bpf_map_info map_infos[nr_iters + 1];
>   	char jited_insns[128], xlated_insns[128];
>   	__u32 i, next_id, info_len, nr_id_found, duration = 0;
> -	int err = 0;
> +	int sysctl_fd, jit_enabled = 0, err = 0;
>   	__u64 array_value;
>   
> +	sysctl_fd = open(jit_sysctl, 0, O_RDONLY);
> +	if (sysctl_fd != -1) {
> +		char tmpc;
> +
> +		if (read(sysctl_fd, &tmpc, sizeof(tmpc)) == 1)
> +			jit_enabled = (tmpc != '0');
> +		close(sysctl_fd);
> +	}
> +
>   	err = bpf_prog_get_fd_by_id(0);
>   	CHECK(err >= 0 || errno != ENOENT,
>   	      "get-fd-by-notexist-prog-id", "err %d errno %d\n", err, errno);
> @@ -339,13 +349,14 @@ static void test_bpf_obj_id(void)
>   		if (CHECK(err ||
>   			  prog_infos[i].type != BPF_PROG_TYPE_SOCKET_FILTER ||
>   			  info_len != sizeof(struct bpf_prog_info) ||
> -			  !prog_infos[i].jited_prog_len ||
> +			  (jit_enabled && !prog_infos[i].jited_prog_len) ||
>   			  !prog_infos[i].xlated_prog_len,
>   			  "get-prog-info(fd)",
> -			  "err %d errno %d i %d type %d(%d) info_len %u(%lu) jited_prog_len %u xlated_prog_len %u\n",
> +			  "err %d errno %d i %d type %d(%d) info_len %u(%lu) jit_enabled %d jited_prog_len %u xlated_prog_len %u\n",
>   			  err, errno, i,
>   			  prog_infos[i].type, BPF_PROG_TYPE_SOCKET_FILTER,
>   			  info_len, sizeof(struct bpf_prog_info),
> +			  jit_enabled,
>   			  prog_infos[i].jited_prog_len,
>   			  prog_infos[i].xlated_prog_len))
>   			goto done;
> 
Acked-by: Yonghong Song <yhs@fb.com>
