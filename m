From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH net-next 2/2] tools lib bpf: export function to set type
Date: Mon, 15 Aug 2016 11:41:26 +0800
Message-ID: <57B139E6.8080702@huawei.com>
References: <1471090643-22403-1-git-send-email-eric@regit.org>
 <1471090643-22403-3-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>
To: Eric Leblond <eric@regit.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:62101 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbcHODml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 23:42:41 -0400
In-Reply-To: <1471090643-22403-3-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/8/13 20:17, Eric Leblond wrote:
> Current API was not allowing the user to set a type like socket
> filter. To avoid a setter function for each type, the patch simply
> exports a set function that takes the type in parameter.
>
> Signed-off-by: Eric Leblond <eric@regit.org>
> ---
>   tools/lib/bpf/libbpf.c | 15 ++++++---------
>   tools/lib/bpf/libbpf.h |  3 +++
>   2 files changed, 9 insertions(+), 9 deletions(-)
>
> diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
> index 7872ff6..ff2a8c6 100644
> --- a/tools/lib/bpf/libbpf.c
> +++ b/tools/lib/bpf/libbpf.c
> @@ -1336,26 +1336,23 @@ int bpf_program__nth_fd(struct bpf_program *prog, int n)
>   	return fd;
>   }
>   
> -static void bpf_program__set_type(struct bpf_program *prog,
> +int bpf_program__set_type(struct bpf_program *prog,
>   				  enum bpf_prog_type type)
>   {
> +	if (!prog)
> +		return -EINVAL;
>   	prog->type = type;
> +	return 0;
>   }
>   

We'd better add a sanity check here to prevent setting invalid
program type. Plase have a look at

https://lkml.org/lkml/2015/12/17/13

>   int bpf_program__set_tracepoint(struct bpf_program *prog)
>   {
> -	if (!prog)
> -		return -EINVAL;
> -	bpf_program__set_type(prog, BPF_PROG_TYPE_TRACEPOINT);
> -	return 0;
> +	return bpf_program__set_type(prog, BPF_PROG_TYPE_TRACEPOINT);
>   }
>   
>   int bpf_program__set_kprobe(struct bpf_program *prog)
>   {
> -	if (!prog)
> -		return -EINVAL;
> -	bpf_program__set_type(prog, BPF_PROG_TYPE_KPROBE);
> -	return 0;
> +	return bpf_program__set_type(prog, BPF_PROG_TYPE_KPROBE);
>   }
>   
>   static bool bpf_program__is_type(struct bpf_program *prog,
> diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
> index a6c5cde..6a84d7a 100644
> --- a/tools/lib/bpf/libbpf.h
> +++ b/tools/lib/bpf/libbpf.h
> @@ -173,6 +173,9 @@ int bpf_program__set_kprobe(struct bpf_program *prog);
>   bool bpf_program__is_tracepoint(struct bpf_program *prog);
>   bool bpf_program__is_kprobe(struct bpf_program *prog);
>   
> +int bpf_program__set_type(struct bpf_program *prog,
> +				  enum bpf_prog_type type);
> +

This makes libbpf.h depend on kernel's uapi/linux/bpf.h.
Although I did this in the above patch, I don't like this
dependency. This is the reason why I introduce

int bpf_program__set_tracepoint(struct bpf_program *prog);
int bpf_program__set_kprobe(struct bpf_program *prog);

bool bpf_program__is_tracepoint(struct bpf_program *prog);
bool bpf_program__is_kprobe(struct bpf_program *prog);

and hide bpf_program__set_type inside the .c file.

Please add type setting functions, or pass int value to
bpf_program__set_type and add sanity checking.

Thank you.
