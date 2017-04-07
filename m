From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2 1/2] bpf: remove struct bpf_prog_type_list
Date: Fri, 07 Apr 2017 21:03:15 +0200
Message-ID: <1491591795.5800.3.camel@sipsolutions.net>
References: <20170407190008.32632-1-johannes@sipsolutions.net>
         (sfid-20170407_210037_465123_47EA385C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51638 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752848AbdDGTDS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 15:03:18 -0400
In-Reply-To: <20170407190008.32632-1-johannes@sipsolutions.net> (sfid-20170407_210037_465123_47EA385C)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So two things about this, and they apply to the other patch as well:

> +extern const struct bpf_verifier_ops sk_filter_prog_ops;
> +extern const struct bpf_verifier_ops tc_cls_act_prog_ops;
> +extern const struct bpf_verifier_ops xdp_prog_ops;
> +extern const struct bpf_verifier_ops cg_skb_prog_ops;
> +extern const struct bpf_verifier_ops cg_sock_prog_ops;
> +extern const struct bpf_verifier_ops lwt_inout_prog_ops;
> +extern const struct bpf_verifier_ops lwt_xmit_prog_ops;
> +extern const struct bpf_verifier_ops kprobe_prog_ops;
> +extern const struct bpf_verifier_ops tracepoint_prog_ops;
> +extern const struct bpf_verifier_ops perf_event_prog_ops;

I'm not super happy with having to list it here - and maybe I should
add ifdefs here as well.

+static const struct bpf_verifier_ops * const bpf_prog_types[] = {
> +#ifdef CONFIG_NET
> +	[BPF_PROG_TYPE_SOCKET_FILTER] = &sk_filter_prog_ops,
> +	[BPF_PROG_TYPE_SCHED_CLS] = &tc_cls_act_prog_ops,
> +	[BPF_PROG_TYPE_SCHED_ACT] = &tc_cls_act_prog_ops,
> +	[BPF_PROG_TYPE_XDP] = &xdp_prog_ops,
> +	[BPF_PROG_TYPE_CGROUP_SKB] = &cg_skb_prog_ops,
> +	[BPF_PROG_TYPE_CGROUP_SOCK] = &cg_sock_prog_ops,
> +	[BPF_PROG_TYPE_LWT_IN] = &lwt_inout_prog_ops,
> +	[BPF_PROG_TYPE_LWT_OUT] = &lwt_inout_prog_ops,
> +	[BPF_PROG_TYPE_LWT_XMIT] = &lwt_xmit_prog_ops,
> +#endif
> +#ifdef CONFIG_BPF_EVENTS
> +	[BPF_PROG_TYPE_KPROBE] = &kprobe_prog_ops,
> +	[BPF_PROG_TYPE_TRACEPOINT] = &tracepoint_prog_ops,
> +	[BPF_PROG_TYPE_PERF_EVENT] = &perf_event_prog_ops,
> +#endif

And here I list it again.

Something I considered was to add the prog_type to the ops struct, and
use the linker (putting this into a special section) to assemble an
array. But that
 * makes the lwt_inout_prog_ops that are shared not work without
   duplicating
 * requires more complicated search code

This seems optimal for the resulting binary, but it's a bunch more
typing.

johannes
