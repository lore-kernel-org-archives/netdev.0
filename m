From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH v2 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Fri, 8 Apr 2016 12:36:14 +0200
Message-ID: <20160408123614.2a15a346@redhat.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41245 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757244AbcDHKgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 06:36:23 -0400
In-Reply-To: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Apr 2016 21:48:46 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> Add a new bpf prog type that is intended to run in early stages of the
> packet rx path. Only minimal packet metadata will be available, hence a
> new context type, struct bpf_phys_dev_md, is exposed to userspace. So
> far only expose the readable packet length, and only in read mode.
> 
> The PHYS_DEV name is chosen to represent that the program is meant only
> for physical adapters, rather than all netdevs.
> 
> While the user visible struct is new, the underlying context must be
> implemented as a minimal skb in order for the packet load_* instructions
> to work. The skb filled in by the driver must have skb->len, skb->head,
> and skb->data set, and skb->data_len == 0.
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>  include/uapi/linux/bpf.h | 14 ++++++++++
>  kernel/bpf/verifier.c    |  1 +
>  net/core/filter.c        | 68 ++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 83 insertions(+)
> 
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 70eda5a..3018d83 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -93,6 +93,7 @@ enum bpf_prog_type {
>  	BPF_PROG_TYPE_SCHED_CLS,
>  	BPF_PROG_TYPE_SCHED_ACT,
>  	BPF_PROG_TYPE_TRACEPOINT,
> +	BPF_PROG_TYPE_PHYS_DEV,
>  };
>  
>  #define BPF_PSEUDO_MAP_FD	1
> @@ -368,6 +369,19 @@ struct __sk_buff {
>  	__u32 tc_classid;
>  };
>  
> +/* user return codes for PHYS_DEV prog type */
> +enum bpf_phys_dev_action {
> +	BPF_PHYS_DEV_DROP,
> +	BPF_PHYS_DEV_OK,
> +};

I can imagine these extra return codes:

 BPF_PHYS_DEV_MODIFIED,   /* Packet page/payload modified */
 BPF_PHYS_DEV_STOLEN,     /* E.g. forward use-case */
 BPF_PHYS_DEV_SHARED,     /* Queue for async processing, e.g. tcpdump use-case */

The "STOLEN" and "SHARED" use-cases require some refcnt manipulations,
which we can look at when we get that far...

For the "MODIFIED" case, people caring about checksumming, might want
to voice their concern if we want additional info or return codes,
indicating if software need to recalc CSUM (or e.g. if only IP-pseudo
hdr was modified).


> +/* user accessible metadata for PHYS_DEV packet hook
> + * new fields must be added to the end of this structure
> + */
> +struct bpf_phys_dev_md {
> +	__u32 len;
> +};

This is userspace visible.  I can easily imagine this structure will get
extended.  How does a userspace eBPF program know that the struct got
extended? (bet you got some scheme, normally I would add a "version" as
first elem).

BTW, how and where is this "struct bpf_phys_dev_md" allocated?


>  struct bpf_tunnel_key {
>  	__u32 tunnel_id;
>  	union {
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 58792fe..877542d 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1344,6 +1344,7 @@ static bool may_access_skb(enum bpf_prog_type type)
>  	case BPF_PROG_TYPE_SOCKET_FILTER:
>  	case BPF_PROG_TYPE_SCHED_CLS:
>  	case BPF_PROG_TYPE_SCHED_ACT:
> +	case BPF_PROG_TYPE_PHYS_DEV:
>  		return true;
>  	default:
>  		return false;
> diff --git a/net/core/filter.c b/net/core/filter.c
> index e8486ba..4f73fb9 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2021,6 +2021,12 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
>  	}
>  }
>  
> +static const struct bpf_func_proto *
> +phys_dev_func_proto(enum bpf_func_id func_id)
> +{
> +	return sk_filter_func_proto(func_id);
> +}
> +
>  static bool __is_valid_access(int off, int size, enum bpf_access_type type)
>  {
>  	/* check bounds */
> @@ -2076,6 +2082,36 @@ static bool tc_cls_act_is_valid_access(int off, int size,
>  	return __is_valid_access(off, size, type);
>  }
>  
> +static bool __is_valid_phys_dev_access(int off, int size,
> +				       enum bpf_access_type type)
> +{
> +	if (off < 0 || off >= sizeof(struct bpf_phys_dev_md))
> +		return false;
> +
> +	if (off % size != 0)
> +		return false;
> +
> +	if (size != 4)
> +		return false;
> +
> +	return true;
> +}
> +
> +static bool phys_dev_is_valid_access(int off, int size,
> +				     enum bpf_access_type type)
> +{
> +	if (type == BPF_WRITE)
> +		return false;
> +
> +	switch (off) {
> +	case offsetof(struct bpf_phys_dev_md, len):
> +		break;
> +	default:
> +		return false;
> +	}
> +	return __is_valid_phys_dev_access(off, size, type);
> +}
> +
>  static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
>  				      int src_reg, int ctx_off,
>  				      struct bpf_insn *insn_buf,
> @@ -2213,6 +2249,26 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
>  	return insn - insn_buf;
>  }
>  
> +static u32 bpf_phys_dev_convert_ctx_access(enum bpf_access_type type,
> +					   int dst_reg, int src_reg,
> +					   int ctx_off,
> +					   struct bpf_insn *insn_buf,
> +					   struct bpf_prog *prog)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +
> +	switch (ctx_off) {
> +	case offsetof(struct bpf_phys_dev_md, len):
> +		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
> +
> +		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
> +				      offsetof(struct sk_buff, len));
> +		break;
> +	}
> +
> +	return insn - insn_buf;
> +}
> +
>  static const struct bpf_verifier_ops sk_filter_ops = {
>  	.get_func_proto = sk_filter_func_proto,
>  	.is_valid_access = sk_filter_is_valid_access,
> @@ -2225,6 +2281,12 @@ static const struct bpf_verifier_ops tc_cls_act_ops = {
>  	.convert_ctx_access = bpf_net_convert_ctx_access,
>  };
>  
> +static const struct bpf_verifier_ops phys_dev_ops = {
> +	.get_func_proto = phys_dev_func_proto,
> +	.is_valid_access = phys_dev_is_valid_access,
> +	.convert_ctx_access = bpf_phys_dev_convert_ctx_access,
> +};
> +
>  static struct bpf_prog_type_list sk_filter_type __read_mostly = {
>  	.ops = &sk_filter_ops,
>  	.type = BPF_PROG_TYPE_SOCKET_FILTER,
> @@ -2240,11 +2302,17 @@ static struct bpf_prog_type_list sched_act_type __read_mostly = {
>  	.type = BPF_PROG_TYPE_SCHED_ACT,
>  };
>  
> +static struct bpf_prog_type_list phys_dev_type __read_mostly = {
> +	.ops = &phys_dev_ops,
> +	.type = BPF_PROG_TYPE_PHYS_DEV,
> +};
> +
>  static int __init register_sk_filter_ops(void)
>  {
>  	bpf_register_prog_type(&sk_filter_type);
>  	bpf_register_prog_type(&sched_cls_type);
>  	bpf_register_prog_type(&sched_act_type);
> +	bpf_register_prog_type(&phys_dev_type);
>  
>  	return 0;
>  }



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
