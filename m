From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 1/4] bpf: xdp: Allow head adjustment in XDP prog
Date: Fri, 2 Dec 2016 19:43:07 -0800
Message-ID: <20161203034307.GB70461@kafai-mba.local>
References: <1480721013-1047541-1-git-send-email-kafai@fb.com>
 <1480721013-1047541-2-git-send-email-kafai@fb.com>
 <5842102D.4000903@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41478 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751731AbcLCDnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 22:43:32 -0500
Content-Disposition: inline
In-Reply-To: <5842102D.4000903@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 03, 2016 at 01:22:05AM +0100, Daniel Borkmann wrote:
> On 12/03/2016 12:23 AM, Martin KaFai Lau wrote:
> >This patch allows XDP prog to extend/remove the packet
> >data at the head (like adding or removing header).  It is
> >done by adding a new XDP helper bpf_xdp_adjust_head().
> >
> >It also renames bpf_helper_changes_skb_data() to
> >bpf_helper_changes_pkt_data() to better reflect
> >that XDP prog does not work on skb.
> >
> >Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> [...]
> >diff --git a/net/core/filter.c b/net/core/filter.c
> >index 56b43587d200..6902e2f73e38 100644
> >--- a/net/core/filter.c
> >+++ b/net/core/filter.c
> >@@ -2234,7 +2234,34 @@ static const struct bpf_func_proto bpf_skb_change_head_proto = {
> >  	.arg3_type	= ARG_ANYTHING,
> >  };
> >
> >-bool bpf_helper_changes_skb_data(void *func)
> >+BPF_CALL_2(bpf_xdp_adjust_head, struct xdp_buff *, xdp, int, offset)
> >+{
> >+	/* Both mlx4 and mlx5 driver align each packet to PAGE_SIZE when
> >+	 * XDP prog is set.
> >+	 * If the above is not true for the other drivers to support
> >+	 * bpf_xdp_adjust_head, struct xdp_buff can be extended.
> >+	 */
> >+	void *head = (void *)((unsigned long)xdp->data & PAGE_MASK);
> >+	void *new_data = xdp->data + offset;
> >+
> >+	if (new_data < head || new_data >= xdp->data_end)
> >+		/* The packet length must be >=1 */
>
> Patch looks generally good to me. Should the min pkt len here be
> limited to ETH_HLEN instead of 1?
Make sense.  Will make the change.

>
> >+		return -EINVAL;
> >+
> >+	xdp->data = new_data;
> >+
> >+	return 0;
> >+}
> >+
> >+static const struct bpf_func_proto bpf_xdp_adjust_head_proto = {
> >+	.func		= bpf_xdp_adjust_head,
> >+	.gpl_only	= false,
> >+	.ret_type	= RET_INTEGER,
> >+	.arg1_type	= ARG_PTR_TO_CTX,
> >+	.arg2_type	= ARG_ANYTHING,
> >+};
> >+
> >+bool bpf_helper_changes_pkt_data(void *func)
> >  {
> >  	if (func == bpf_skb_vlan_push ||
> >  	    func == bpf_skb_vlan_pop ||
> [...]
