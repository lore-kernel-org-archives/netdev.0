From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] bpf: BPF for lightweight tunnel
 infrastructure
Date: Tue, 29 Nov 2016 16:15:06 -0800
Message-ID: <20161130001504.GA28238@ast-mbp.thefacebook.com>
References: <cover.1480424542.git.tgraf@suug.ch>
 <7cc79a82e49996a9ebbff861af471018fdf118fb.1480424542.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        hannes@stressinduktion.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34363 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbcK3APO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:15:14 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so9049281pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 16:15:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <7cc79a82e49996a9ebbff861af471018fdf118fb.1480424542.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 02:21:22PM +0100, Thomas Graf wrote:
> Registers new BPF program types which correspond to the LWT hooks:
>   - BPF_PROG_TYPE_LWT_IN   => dst_input()
>   - BPF_PROG_TYPE_LWT_OUT  => dst_output()
>   - BPF_PROG_TYPE_LWT_XMIT => lwtunnel_xmit()
> 
> The separate program types are required to differentiate between the
> capabilities each LWT hook allows:
> 
>  * Programs attached to dst_input() or dst_output() are restricted and
>    may only read the data of an skb. This prevent modification and
>    possible invalidation of already validated packet headers on receive
>    and the construction of illegal headers while the IP headers are
>    still being assembled.
> 
>  * Programs attached to lwtunnel_xmit() are allowed to modify packet
>    content as well as prepending an L2 header via a newly introduced
>    helper bpf_skb_push(). This is safe as lwtunnel_xmit() is invoked
>    after the IP header has been assembled completely.
> 
> All BPF programs receive an skb with L3 headers attached and may return
> one of the following error codes:
> 
>  BPF_OK - Continue routing as per nexthop
>  BPF_DROP - Drop skb and return EPERM
>  BPF_REDIRECT - Redirect skb to device as per redirect() helper.
>                 (Only valid in lwtunnel_xmit() context)
> 
> The return codes are binary compatible with their TC_ACT_
> relatives to ease compatibility.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
...
> +#define LWT_BPF_MAX_HEADROOM 128

why 128?
btw I'm thinking for XDP to use 256, so metadata can be stored in there.

> +static int run_lwt_bpf(struct sk_buff *skb, struct bpf_lwt_prog *lwt,
> +		       struct dst_entry *dst, bool can_redirect)
> +{
> +	int ret;
> +
> +	/* Preempt disable is needed to protect per-cpu redirect_info between
> +	 * BPF prog and skb_do_redirect(). The call_rcu in bpf_prog_put() and
> +	 * access to maps strictly require a rcu_read_lock() for protection,
> +	 * mixing with BH RCU lock doesn't work.
> +	 */
> +	preempt_disable();
> +	rcu_read_lock();
> +	bpf_compute_data_end(skb);
> +	ret = BPF_PROG_RUN(lwt->prog, skb);
> +	rcu_read_unlock();
> +
> +	switch (ret) {
> +	case BPF_OK:
> +		break;
> +
> +	case BPF_REDIRECT:
> +		if (!can_redirect) {
> +			WARN_ONCE(1, "Illegal redirect return code in prog %s\n",
> +				  lwt->name ? : "<unknown>");
> +			ret = BPF_OK;
> +		} else {
> +			ret = skb_do_redirect(skb);

I think this assumes that program did bpf_skb_push and L2 header is present.
Would it make sense to check that mac_header < network_header here to make
sure that it actually happened? I think the cost of single 'if' isn't much.
Also skb_do_redirect() can redirect to l3 tunnels like ipip ;)
so program shouldn't be doing bpf_skb_push in such case...
May be rename bpf_skb_push to bpf_skb_push_l2 ?
since it's doing skb_reset_mac_header(skb); at the end of it?
Or it's probably better to use 'flags' argument to tell whether
bpf_skb_push() should set mac_header or not ? Then this bit:

> +		case BPF_OK:
> +			/* If the L3 header was expanded, headroom might be too
> +			 * small for L2 header now, expand as needed.
> +			 */
> +			ret = xmit_check_hhlen(skb);

will work fine as well...
which probably needs "mac_header wasn't set" check? or it's fine?

All bpf bits look great. Thanks!
