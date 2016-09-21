From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Tue, 20 Sep 2016 17:01:39 -0700
Message-ID: <57E1CDE3.5030404@fb.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>, <tariqt@mellanox.com>,
        <bblanco@plumgrid.com>, <alexei.starovoitov@gmail.com>,
        <eric.dumazet@gmail.com>, <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49142 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753989AbcIUAB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 20:01:59 -0400
In-Reply-To: <1474408824-418864-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/16 3:00 PM, Tom Herbert wrote:
> +static inline int __xdp_hook_run(struct list_head *list_head,
> +				 struct xdp_buff *xdp)
> +{
> +	struct xdp_hook_ops *elem;
> +	int ret = XDP_PASS;
> +
> +	list_for_each_entry(elem, list_head, list) {
> +		ret = elem->hook(elem->priv, xdp);
> +		if (ret != XDP_PASS)
> +			break;
> +	}
> +
> +	return ret;
> +}
> +
> +/* Run the XDP hooks for a napi device. Called from a driver's receive
> + * routine
> + */
> +static inline int xdp_hook_run(struct napi_struct *napi, struct xdp_buff *xdp)
> +{
> +	struct net_device *dev = napi->dev;
> +	int ret = XDP_PASS;
> +
> +	if (static_branch_unlikely(&xdp_hooks_needed)) {
> +		/* Run hooks in napi first */
> +		ret = __xdp_hook_run(&napi->xdp_hook_list, xdp);
> +		if (ret != XDP_PASS)
> +			return ret;
> +
> +		/* Now run device hooks */
> +		ret = __xdp_hook_run(&dev->xdp_hook_list, xdp);
> +		if (ret != XDP_PASS)
> +			return ret;
> +	}
> +
> +	return ret;
> +}

it's an interesting idea to move prog pointer into napi struct,
but certainly not at such huge cost.
Right now it's 1 load + 1 cmp + 1 indirect jump per packet
to invoke the program, with above approach it becomes
6 loads + 3 cmp (just to get through run_needed_check() check)
+ 6 loads + 3 cmp + 2 indirect jumps.
(I may be little bit off +- few loads)
That is a non-starter.
When we were optimizing receive path of tc clast ingress hook
we saw 1Mpps saved for every load+cmp+indirect jump removed.

We're working on inlining of bpf_map_lookup to save one
indirect call per lookup, we cannot just waste them here.

We need to save cycles instead, especially when it doesn't
really solve your goals. It seems the goals are:

 >- Allows alternative users of the XDP hooks other than the original
 >    BPF

this should be achieved by their own hooks while reusing
return codes XDP_TX, XDP_PASS to keep driver side the same.
I'm not against other packet processing engines, but not
at the cost of lower performance.

 >  - Allows a means to pipeline XDP programs together

this can be done already via bpf_tail_call. No changes needed.

 >  - Reduces the amount of code and complexity needed in drivers to
 >    manage XDP

hmm:
534 insertions(+), 144 deletions(-)
looks like increase in complexity instead.

 >  - Provides a more structured environment that is extensible to new
 >    features while being mostly transparent to the drivers

don't see that in these patches either.
Things like packet size change (that we're working on) still
has to be implemented for every driver.
Existing XDP_TX, XDP_DROP have to be implemented per driver as well.

Also introduction of xdp.h breaks existing UAPI.
That's not acceptable either.
