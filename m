From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next PATCH v2 3/3] net: sched: cls_u32 add bit to specify
 software only rules
Date: Thu, 25 Feb 2016 23:02:54 -0800
Message-ID: <56CFF89E.8070602@intel.com>
References: <20160225231540.9820.7688.stgit@john-Precision-Tower-5810> <20160225232045.9820.6694.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	daniel@iogearbox.net, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4141 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbcBZHDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 02:03:17 -0500
In-Reply-To: <20160225232045.9820.6694.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/25/2016 3:20 PM, John Fastabend wrote:
> In the initial implementation the only way to stop a rule from being
> inserted into the hardware table was via the device feature flag.
> However this doesn't work well when working on an end host system
> where packets are expect to hit both the hardware and software
> datapaths.
>
> For example we can imagine a rule that will match an IP address and
> increment a field. If we install this rule in both hardware and
> software we may increment the field twice. To date we have only
> added support for the drop action so we have been able to ignore
> these cases. But as we extend the action support we will hit this
> example plus more such cases. Arguably these are not even corner
> cases in many working systems these cases will be common.
>
> To avoid forcing the driver to always abort (i.e. the above example)
> this patch adds a flag to add a rule in software only. A careful
> user can use this flag to build software and hardware datapaths
> that work together. One example we have found particularly useful
> is to use hardware resources to set the skb->mark on the skb when
> the match may be expensive to run in software but a mark lookup
> in a hash table is cheap. The idea here is hardware can do in one
> lookup what the u32 classifier may need to traverse multiple lists
> and hash tables to compute. The flag is only passed down on inserts
> on deletion to avoid stale references in hardware we always try

I think this is supposed to be a new sentence starting with 'On deletion'
> to remove a rule if it exists.
>
> The flags field is part of the classifier specific options. Although
> it is tempting to lift this into the generic structure doing this
> proves difficult do to how the tc netlink attributes are implemented
> along with how the dump/change routines are called. There is also
> precedence for putting seemingly generic pieces in the specific
> classifier options such as TCA_U32_POLICE, TCA_U32_ACT, etc. So
> although not ideal I've left FLAGS in the u32 options as well as it
> simplifies the code greatly and user space has already learned how
> to manage these bits ala 'tc' tool.
>
> Another thing if trying to update a rule we require the flags to
> be unchanged. This is to force user space, software u32 and
> the hardware u32 to keep in sync. Thanks to Simon Horman for
> catching this case.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>   include/net/pkt_cls.h        |   13 +++++++++++--
>   include/uapi/linux/pkt_cls.h |    1 +
>   net/sched/cls_u32.c          |   37 +++++++++++++++++++++++++++----------
>   3 files changed, 39 insertions(+), 12 deletions(-)
<snip>
>
> @@ -482,7 +485,9 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
>   	}
>   }
>   
> -static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
> +static void u32_replace_hw_knode(struct tcf_proto *tp,
> +				 struct tc_u_knode *n,
> +				 u32 flags)
>   {
>   	struct net_device *dev = tp->q->dev_queue->dev;
>   	struct tc_cls_u32_offload u32_offload = {0};
> @@ -491,7 +496,7 @@ static void u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n)
>   	offload.type = TC_SETUP_CLSU32;
>   	offload.cls_u32 = &u32_offload;
>   
> -	if (tc_should_offload(dev)) {
> +	if (tc_should_offload(dev, flags)) {
>   		offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
>   		offload.cls_u32->knode.handle = n->handle;
>   		offload.cls_u32->knode.fshift = n->fshift;
> @@ -679,6 +684,7 @@ static const struct nla_policy u32_policy[TCA_U32_MAX + 1] = {
>   	[TCA_U32_SEL]		= { .len = sizeof(struct tc_u32_sel) },
>   	[TCA_U32_INDEV]		= { .type = NLA_STRING, .len = IFNAMSIZ },
>   	[TCA_U32_MARK]		= { .len = sizeof(struct tc_u32_mark) },
> +	[TCA_U32_FLAGS]		= { .len = NLA_U32 },
should be  .type = NLA_U32

> <snip>
