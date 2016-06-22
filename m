From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH -next 3/4] cgroup: bpf: Add bpf_skb_in_cgroup_proto
Date: Tue, 21 Jun 2016 18:15:13 -0700
Message-ID: <20160622011511.GA97149@ast-mbp.thefacebook.com>
References: <1466555002-1316296-1-git-send-email-kafai@fb.com>
 <1466555002-1316296-4-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tejun Heo <tj@kernel.org>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466555002-1316296-4-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2016 at 05:23:21PM -0700, Martin KaFai Lau wrote:
> Adds a bpf helper, bpf_skb_in_cgroup, to decide if a skb->sk
> belongs to a descendant of a cgroup2.  It is similar to the
> feature added in netfilter:
> commit c38c4597e4bf ("netfilter: implement xt_cgroup cgroup2 path match")
> 
> The user is expected to populate a BPF_MAP_TYPE_CGROUP_ARRAY
> which will be used by the bpf_skb_in_cgroup.
> 
> Modifications to the bpf verifier is to ensure BPF_MAP_TYPE_CGROUP_ARRAY
> and bpf_skb_in_cgroup() are always used together.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  include/uapi/linux/bpf.h |  1 +
>  kernel/bpf/verifier.c    |  8 ++++++++
>  net/core/filter.c        | 36 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 45 insertions(+)
> 
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index ef4e386..a91714bd 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -314,6 +314,7 @@ enum bpf_func_id {
>  	 */
>  	BPF_FUNC_skb_get_tunnel_opt,
>  	BPF_FUNC_skb_set_tunnel_opt,
> +	BPF_FUNC_skb_in_cgroup,
...
> +static u64 bpf_skb_in_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
...
> +	if (unlikely(!cgrp))
> +		return -ENOENT;
> +
> +	return cgroup_is_descendant(sock_cgroup_ptr(&sk->sk_cgrp_data), cgrp);

if you'd need to respin the patch for other reasons please add kdoc
to bpf.h for this new helper similar to other helpers.
To say that 0 or 1 return values is indication of cg2 descendant relation
and < 0 in case of error.

Acked-by: Alexei Starovoitov <ast@kernel.org>
