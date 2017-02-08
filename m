From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH v3 2/5] bpf: Simplify bpf_load_program() error handling in
 the library
Date: Wed, 8 Feb 2017 10:35:46 +0800
Message-ID: <59c4e38e-baa3-e130-3d74-14aa6b11bda5@huawei.com>
References: <20170207205609.8035-1-mic@digikod.net>
 <20170207205609.8035-3-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170207205609.8035-3-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/2/8 4:56, Mickaël Salaün wrote:
> Do not call a second time bpf(2) when a program load failed.

BPF_PROG_LOAD should success most of the time. Setting log_level to
0 by default and require log buffer when failure can make it faster
in normal case.

Thank you.

> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Wang Nan <wangnan0@huawei.com>
> ---
>   tools/lib/bpf/bpf.c | 18 ++++++------------
>   1 file changed, 6 insertions(+), 12 deletions(-)
>
> diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
> index 3ddb58a36d3c..fda3f494f1cd 100644
> --- a/tools/lib/bpf/bpf.c
> +++ b/tools/lib/bpf/bpf.c
> @@ -73,7 +73,6 @@ int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
>   		     size_t insns_cnt, char *license,
>   		     __u32 kern_version, char *log_buf, size_t log_buf_sz)
>   {
> -	int fd;
>   	union bpf_attr attr;
>   
>   	bzero(&attr, sizeof(attr));
> @@ -81,20 +80,15 @@ int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
>   	attr.insn_cnt = (__u32)insns_cnt;
>   	attr.insns = ptr_to_u64(insns);
>   	attr.license = ptr_to_u64(license);
> -	attr.log_buf = ptr_to_u64(NULL);
> -	attr.log_size = 0;
> -	attr.log_level = 0;
> +	attr.log_buf = ptr_to_u64(log_buf);
> +	attr.log_size = log_buf_sz;
>   	attr.kern_version = kern_version;
>   
> -	fd = sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
> -	if (fd >= 0 || !log_buf || !log_buf_sz)
> -		return fd;
> +	if (log_buf && log_buf_sz > 0) {
> +		attr.log_level = 1;
> +		log_buf[0] = 0;
> +	}
>   
> -	/* Try again with log */
> -	attr.log_buf = ptr_to_u64(log_buf);
> -	attr.log_size = log_buf_sz;
> -	attr.log_level = 1;
> -	log_buf[0] = 0;
>   	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
>   }
>   
