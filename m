From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 1/2] bpf: remove struct bpf_prog_type_list
Date: Wed, 5 Apr 2017 13:57:18 -0400
Message-ID: <20170405175716.GA31738@ast-mbp>
References: <20170404172711.4088-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36629 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755351AbdDER7c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 13:59:32 -0400
Received: by mail-io0-f194.google.com with SMTP id 68so2079884ioh.3
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 10:59:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170404172711.4088-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 04, 2017 at 07:27:10PM +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> There's no need to have struct bpf_prog_type_list since
> it just contains a list_head, the type, and the ops
> pointer. Since the types are densely packed and not
> actually dynamically registered, it's much easier and
> smaller to have an array of type->ops pointer.
> 
> This doesn't really change the image size much, but in
> the running image it saves a few hundred bytes because
> the structs are removed and traded against __init code.
> 
> While at it, also mark bpf_register_prog_type() __init
> since it's only called from code already marked so.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
> So I'm not sure about this - I looked at this code since
> I wanted to see if we could even register prog_types from
> modules, but that seems to be impossible right now ...
> ---
>  include/linux/bpf.h      | 12 +++------
>  include/uapi/linux/bpf.h |  2 ++
>  kernel/bpf/syscall.c     | 26 ++++++++++----------
>  kernel/trace/bpf_trace.c | 21 +++-------------
>  net/core/filter.c        | 63 +++++++-----------------------------------------
>  5 files changed, 31 insertions(+), 93 deletions(-)
> 
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 909fc033173a..891a76aaccaa 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -169,12 +169,6 @@ struct bpf_verifier_ops {
>  				  struct bpf_prog *prog);
>  };
>  
> -struct bpf_prog_type_list {
> -	struct list_head list_node;
> -	const struct bpf_verifier_ops *ops;
> -	enum bpf_prog_type type;
> -};
> -
>  struct bpf_prog_aux {
>  	atomic_t refcnt;
>  	u32 used_map_cnt;
> @@ -234,7 +228,8 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
>  #ifdef CONFIG_BPF_SYSCALL
>  DECLARE_PER_CPU(int, bpf_prog_active);
>  
> -void bpf_register_prog_type(struct bpf_prog_type_list *tl);
> +void bpf_register_prog_type(enum bpf_prog_type type,
> +			    const struct bpf_verifier_ops *ops);
>  void bpf_register_map_type(struct bpf_map_type_list *tl);
>  
>  struct bpf_prog *bpf_prog_get(u32 ufd);
> @@ -295,7 +290,8 @@ static inline void bpf_long_memcpy(void *dst, const void *src, u32 size)
>  /* verify correctness of eBPF program */
>  int bpf_check(struct bpf_prog **fp, union bpf_attr *attr);
>  #else
> -static inline void bpf_register_prog_type(struct bpf_prog_type_list *tl)
> +static inline void bpf_register_prog_type(enum bpf_prog_type type,
> +					  const struct bpf_verifier_ops *ops)
>  {
>  }
>  
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 0539a0ceef38..cc68f5bbf458 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -112,6 +112,8 @@ enum bpf_prog_type {
>  	BPF_PROG_TYPE_LWT_IN,
>  	BPF_PROG_TYPE_LWT_OUT,
>  	BPF_PROG_TYPE_LWT_XMIT,
> +
> +	NUM_BPF_PROG_TYPES,

I don't think it's right to add something to uapi because
kernel implemetation changed. If we decide to go back to
link list this will be unused. One can argue that this can
be used for other purpose, but I'd like to separate such
discussions.
I think defining it internally as an array
and adding runtime check to bpf_register_prog_type() that
prog type id is less than the size of the array will be
clean enough. Even better if we can statically init
the array and drop bpf_register_prog_type() completely
then compiler will figure out the size of the array
at compile time and runtime check in find() will be sizeof(array).

>  static int find_prog_type(enum bpf_prog_type type, struct bpf_prog *prog)
>  {
> -	struct bpf_prog_type_list *tl;
> -
> -	list_for_each_entry(tl, &bpf_prog_types, list_node) {
> -		if (tl->type == type) {
> -			prog->aux->ops = tl->ops;
> -			prog->type = type;
> -			return 0;
> -		}
> -	}
> +	if (type >= NUM_BPF_PROG_TYPES || !bpf_prog_types[type])
> +		return -EINVAL;
>  
> -	return -EINVAL;
> +	prog->aux->ops = bpf_prog_types[type];
> +	prog->type = type;

this is nice improvement.
please add a check for null too, since when folks
backport stuff there will be holes in this array.
Backports typically do
enum bpf_prog_type {
  PROG_A,
  PROG_B
  PROG_X = 10;
};

>  static int __init register_sk_filter_ops(void)
>  {
> -	bpf_register_prog_type(&sk_filter_type);
> -	bpf_register_prog_type(&sched_cls_type);
> -	bpf_register_prog_type(&sched_act_type);
> -	bpf_register_prog_type(&xdp_type);
> -	bpf_register_prog_type(&cg_skb_type);
> -	bpf_register_prog_type(&cg_sock_type);
> -	bpf_register_prog_type(&lwt_in_type);
> -	bpf_register_prog_type(&lwt_out_type);
> -	bpf_register_prog_type(&lwt_xmit_type);
> +	bpf_register_prog_type(BPF_PROG_TYPE_SOCKET_FILTER, &sk_filter_ops);
> +	bpf_register_prog_type(BPF_PROG_TYPE_SCHED_CLS, &tc_cls_act_ops);
> +	bpf_register_prog_type(BPF_PROG_TYPE_SCHED_ACT, &tc_cls_act_ops);
> +	bpf_register_prog_type(BPF_PROG_TYPE_XDP, &xdp_ops);
> +	bpf_register_prog_type(BPF_PROG_TYPE_CGROUP_SKB, &cg_skb_ops);
> +	bpf_register_prog_type(BPF_PROG_TYPE_CGROUP_SOCK, &cg_sock_ops);
> +	bpf_register_prog_type(BPF_PROG_TYPE_LWT_IN, &lwt_inout_ops);
> +	bpf_register_prog_type(BPF_PROG_TYPE_LWT_OUT, &lwt_inout_ops);
> +	bpf_register_prog_type(BPF_PROG_TYPE_LWT_XMIT, &lwt_xmit_ops);

I think we should be able to statically init the array as well and
avoid these calls too and we won't need to add anything to uapi.
