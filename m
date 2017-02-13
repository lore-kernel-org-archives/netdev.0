From: Alexei Starovoitov <ast@fb.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 13 Feb 2017 15:31:56 -0800
Message-ID: <58A241EC.8050400@fb.com>
References: <20170214091250.57d054b2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "Peter Zijlstra" <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        "Arnaldo Carvalho de Melo" <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>, <joe@ovn.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170214091250.57d054b2@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/13/17 2:12 PM, Stephen Rothwell wrote:
> Hi all,
>
> After merging the net tree, today's linux-next build (powerpc64le perf)
> failed like this:
>
> Warning: tools/include/uapi/linux/bpf.h differs from kernel
> bpf.c: In function 'bpf_prog_attach':
> bpf.c:180:6: error: 'union bpf_attr' has no member named 'attach_flags'; did you mean 'map_flags'?
>    attr.attach_flags  = flags;
>        ^
>
> Caused by commit
>
>    7f677633379b ("bpf: introduce BPF_F_ALLOW_OVERRIDE flag")
>
> Unfortunately, the perf header files are kept separate from the kernel
> header files proper and are not automatically copied over :-(
>
> I have applied the following build fix patch for today.

Yes. Thanks for the fix. It's more than a merge conflict.
I should have added it in the first place. Now we have both
perf and samples/bpf depend on tools/lib/bpf and I simply
forgot about this dependency, since building perf
is not my typical workflow.

Joe,
can you think of a way to make tools/lib/bpf to
use tools/include only?
Right now we just pull tools/lib/bpf/bpf.o in samples/bpf/Makefile
and that's a hack that caused this issue.
samples/bpf/ needs to depend on libbpf.a properly.

For the patch:
Acked-by: Alexei Starovoitov <ast@kernel.org>

Dave,
can you apply it to 'net' tree,
since the patch properly made it into patchwork ?
or I can resubmit it.
Thanks!

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 14 Feb 2017 08:22:20 +1100
> Subject: [PATCH] bpf: kernel header files need to be copied into the tools directory
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>   tools/include/uapi/linux/bpf.h | 7 +++++++
>   1 file changed, 7 insertions(+)
>
> diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
> index 0eb0e87dbe9f..d2b0ac799d03 100644
> --- a/tools/include/uapi/linux/bpf.h
> +++ b/tools/include/uapi/linux/bpf.h
> @@ -116,6 +116,12 @@ enum bpf_attach_type {
>
>   #define MAX_BPF_ATTACH_TYPE __MAX_BPF_ATTACH_TYPE
>
> +/* If BPF_F_ALLOW_OVERRIDE flag is used in BPF_PROG_ATTACH command
> + * to the given target_fd cgroup the descendent cgroup will be able to
> + * override effective bpf program that was inherited from this cgroup
> + */
> +#define BPF_F_ALLOW_OVERRIDE	(1U << 0)
> +
>   #define BPF_PSEUDO_MAP_FD	1
>
>   /* flags for BPF_MAP_UPDATE_ELEM command */
> @@ -171,6 +177,7 @@ union bpf_attr {
>   		__u32		target_fd;	/* container object to attach to */
>   		__u32		attach_bpf_fd;	/* eBPF program to attach */
>   		__u32		attach_type;
> +		__u32		attach_flags;
>   	};
>   } __attribute__((aligned(8)));
>
>
