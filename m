From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH RFC 3/3] net: convert tc_u32 to use the intermediate representation
Date: Thu, 25 Feb 2016 12:37:38 -0800
Message-ID: <56CF6612.6040900@gmail.com>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org> <1456421844-5901-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, horms@verge.net.au
To: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35830 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbcBYUhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 15:37:51 -0500
Received: by mail-pa0-f44.google.com with SMTP id ho8so38941458pac.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 12:37:51 -0800 (PST)
In-Reply-To: <1456421844-5901-4-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 09:37 AM, Pablo Neira Ayuso wrote:
> This patch moves the u32 parser from the ixgbe that John has made to the
> core u32. This parser has been adapted to build the intermediate
> representation.
> 
> To store the parsing information, this patch introduces a parse table
> object, one per device, so we don't need to store the parsing states in
> the adapter, which is the major dependency with previous patches.
> 
> Since u32 allows rules connected via links, the u32 parser tracks this
> links and then generates the intermediate representation that is passed
> to the ixgbe driver.

It also supports hash tables and loops.

> 
> New drivers will only have to implement the jit translation code based
> on the intermediate representation. With some extra work, I think it
> should be possible to generalize the existing tc specific ndo action so
> it can be used by other frontends.
> 
> I tried to stick to John's original u32 frontend parser as much as
> possible, adapting it to build the intermediate representation.
> 
> After this change, we don't expose the tc action structure layout and
> other similar frontend details to the backend anymore to the backend
> anymore. I think this is good since changes in the frontend should not
> need to be propagated to the 1..n drivers supporting u32 offloads. In
> that sense, this helps to keep the frontend software representation
> separated from low-level backend driver details.
> 
> After this patch, it should be possible to put the tc_cls_u32_knode
> structure into diet since we only need the handle (as unique id) and the
> ast tree.
> 

On ixgbe this is true but going forward I can support hash functions
so you need the divisor, prio, and handle minimally. I'm not sure how
to do hash tables for example in this IR yet. Might be there I'm still
trying to grok the IR details.

> I couldn't send any more incremental changes to update previous work
> since the u32 parser and the internal representation were put together,
> that why this patch is slightly large.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |   4 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 216 ++++++++--------
>  drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 112 --------
>  include/net/pkt_cls.h                          |   3 +
>  net/sched/cls_u32.c                            | 344 +++++++++++++++++++++++++

Feels like a lot of code to me when the original direct u32 to hw
was reasonably small and the flower implementation is small as well.

[...]

>  
> +static int ixgbe_tcp_jit(struct net_ir_jit_ctx *ctx,
> +			 const struct net_ir_expr *expr,
> +			 void *data)
> +{
> +	struct ixgbe_filter *f = (struct ixgbe_filter *)data;
> +	struct net_ir_expr *right = expr->relational.right;
> +	struct net_ir_expr *payload;
> +	u32 mask = 0xffffffff;
> +
> +	if (expr->relational.left->type == NET_IR_EXPR_BINOP) {
> +		payload = expr->relational.left->binop.left;
> +		mask = expr->relational.left->binop.right->value.data;
> +	} else {
> +		payload = expr->relational.left;
> +	}
> +
> +	switch (payload->payload.offset) {

I don't like this because it hardcodes the offset pieces into the
driver. The reason I used a model.h header file with its structures
in ixgbe is the next step is to expose the parser so the model can be
updated. So that when the hardware parser changes the data structure
can be changed via firmware call. The style of coding here wont work
for that so we still need the model.h file and for loop.

> +	case offsetof(struct tcphdr, source):
> +		f->input->filter.formatted.src_port = right->value.data & 0xffff;
> +		f->mask.formatted.src_port = mask & 0xffff;
> +		break;
> +	case offsetof(struct tcphdr, dest):
> +		f->input->filter.formatted.dst_port = right->value.data & 0xffff;
> +		f->mask.formatted.dst_port = mask & 0xffff;
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +	return 0;
> +}
> +
> +static struct net_ir_proto_desc ixgbe_tcp_desc = {
> +	.base		= NET_IR_PAYLOAD_TRANSPORT_HDR,
> +	.protonum	= IPPROTO_TCP,

hmm I'm having trouble tracking down how this is used but the point of
a lot of ongoing work is to not be dependent on any specific protocol
values. The IPPROTO_TCP here looks suspicious why do we need this? It
seems to imply I would need to define a IPPROTO_FOO if I wanted to add
a new protocol.

> +	.jit		= ixgbe_tcp_jit,
> +};
> +
> +static int ixgbe_ipv4_jit(struct net_ir_jit_ctx *ctx,
> +			  const struct net_ir_expr *expr,
> +			  void *data)
> +{
> +	struct ixgbe_filter *f = (struct ixgbe_filter *)data;
> +	struct net_ir_expr *right = expr->relational.right;
> +	struct net_ir_expr *payload;
> +	u32 mask = 0xffffffff;
> +
> +	if (expr->relational.left->type == NET_IR_EXPR_BINOP) {
> +		payload = expr->relational.left->binop.left;
> +		mask = expr->relational.left->binop.right->value.data;
> +	} else {
> +		payload = expr->relational.left;
> +	}
> +
> +	switch (payload->payload.offset) {

same comment here it depends on iphdr, saddr, etc. This is fundamentally
broken in my opinion. I shouldn't be using 'struct' and specific keys to
find address. I want this to be agnostic of protocol so when my users
wants to add protocol foo I can do it without recompiling the
driver/kernel.

> +	case offsetof(struct iphdr, saddr):
> +		f->input->filter.formatted.src_ip[0] = right->value.data;
> +		f->mask.formatted.src_ip[0] = mask;
> +		break;
> +	case offsetof(struct iphdr, daddr):
> +		f->input->filter.formatted.dst_ip[0] = right->value.data;
> +		f->mask.formatted.dst_ip[0] = mask;
> +		break;
> +	case offsetof(struct iphdr, protocol):
> +		net_ir_jit_update_pctx(ctx, NET_IR_PAYLOAD_TRANSPORT_HDR,
> +				       right->value.data);
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +	return 0;
> +}
> +
> +static struct net_ir_proto_desc ixgbe_ipv4_desc = {
> +	.base		= NET_IR_PAYLOAD_NETWORK_HDR,
> +	.jit		= ixgbe_ipv4_jit,
> +	.protocols	= {
> +		&ixgbe_tcp_desc,
> +		NULL
> +	},
> +};
> +

[...]

>  static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
>  				  __be16 protocol,
>  				  struct tc_cls_u32_offload *cls)
>  {
>  	u32 loc = cls->knode.handle & 0xfffff;
>  	struct ixgbe_hw *hw = &adapter->hw;
> -	struct ixgbe_mat_field *field_ptr;
>  	struct ixgbe_filter f;
> -#ifdef CONFIG_NET_CLS_ACT
> -	const struct tc_action *a;
> -#endif
> -	int i, err = 0;
> +	int err = 0;
>  	u32 handle;
>  
>  	memset(&f.mask, 0, sizeof(union ixgbe_atr_input));
>  	handle = cls->knode.handle;
>  
> -	/* At the moment cls_u32 jumps to transport layer and skips past
> -	 * L2 headers. The canonical method to match L2 frames is to use
> -	 * negative values. However this is error prone at best but really
> -	 * just broken because there is no way to "know" what sort of hdr
> -	 * is in front of the transport layer. Fix cls_u32 to support L2
> -	 * headers when needed.
> -	 */
> -	if (protocol != htons(ETH_P_IP))

This was hardcoded originally just to find the inital offset going
forward I want to patch u32 to start at the link layer to avoid this.

[...]

> -		if (!found_entry)
> -			goto err_out;
> -	}
> +	if (net_ir_jit(&cls->knode.ast, &ixgbe_desc, &f) < 0)
> +		return -EINVAL;
>  

OK but this takes a cls_u32 offload engine that was running on a handful
of LOC + a header file description that in the future will be read out
of firmware and replaces it with an entire infrastructure. I'm not
convinced the added complexity is worth it.

[...]

> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
> +++ /dev/null
> @@ -1,112 +0,0 @@
> -/*******************************************************************************
> - *
> - * Intel 10 Gigabit PCI Express Linux drive
> - * Copyright(c) 2016 Intel Corporation.
> - *
> - * This program is free software; you can redistribute it and/or modify it
> - * under the terms and conditions of the GNU General Public License,
> - * version 2, as published by the Free Software Foundation.
> - *
> - * This program is distributed in the hope it will be useful, but WITHOUT
> - * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> - * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> - * more details.
> - *
> - * You should have received a copy of the GNU General Public License along
> - * with this program.  If not, see <http://www.gnu.org/licenses/>.
> - *
> - * The full GNU General Public License is included in this distribution in
> - * the file called "COPYING".
> - *
> - * Contact Information:
> - * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
> - * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
> - *
> - ******************************************************************************/
> -
> -#ifndef _IXGBE_MODEL_H_
> -#define _IXGBE_MODEL_H_
> -
> -#include "ixgbe.h"
> -#include "ixgbe_type.h"
> -
> -struct ixgbe_mat_field {
> -	unsigned int off;
> -	unsigned int mask;
> -	int (*val)(struct ixgbe_fdir_filter *input,
> -		   union ixgbe_atr_input *mask,
> -		   u32 val, u32 m);
> -	unsigned int type;
> -};

As noted above the intent is to make the parser programmable so
something like this model needs to exist for firmware to populate.

[...]

> -#endif /* _IXGBE_MODEL_H_ */
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index 2121df5..c276ba2 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -358,6 +358,8 @@ tcf_match_indev(struct sk_buff *skb, int ifindex)
>  }
>  #endif /* CONFIG_NET_CLS_IND */
>  
> +#include <net/ir.h>
> +
>  struct tc_cls_u32_knode {
>  	struct tcf_exts *exts;
>  	struct tc_u32_sel *sel;
> @@ -366,6 +368,7 @@ struct tc_cls_u32_knode {
>  	u32 mask;
>  	u32 link_handle;
>  	u8 fshift;
> +	struct net_ir_ast ast;
>  };
>  
>  struct tc_cls_u32_hnode {
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index d54bc94..b79b4675 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -44,6 +44,8 @@
>  #include <net/act_api.h>
>  #include <net/pkt_cls.h>
>  #include <linux/netdevice.h>
> +#include <net/tc_act/tc_gact.h>
> +#include <net/ir.h>
>  
>  struct tc_u_knode {
>  	struct tc_u_knode __rcu	*next;
> @@ -442,11 +444,208 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
>  	}
>  }
>  
> +static struct net_ir_stmt *
> +u32_payload_stmt_alloc(enum net_ir_payload_bases base, u32 offset, u32 value,
> +		       u32 mask)
> +{
> +	struct net_ir_expr *expr, *payload, *binop;
> +	struct net_ir_stmt *stmt;
> +
> +	expr = net_ir_expr_alloc(NET_IR_EXPR_RELATIONAL);
> +	if (!expr)
> +		return NULL;
> +
> +	expr->op = NET_IR_OP_EQ;
> +
> +	payload = net_ir_expr_alloc(NET_IR_EXPR_PAYLOAD);

A lot of memory allocation and what not done in the add/del path of the
rule set seems like its going to cause a performance impact. Yes I know
this is already slow slow slow but this adds one more thing to fix when
we get around to optimizing the updates.

Otherwise it seems to be a fairly faithful lifting of my ixgbe parser
into the IR.

[...]

>  	offload.type = TC_SETUP_CLSU32;
>  	offload.cls_u32 = &u32_offload;
> @@ -457,6 +656,19 @@ static void u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
>  		offload.cls_u32->hnode.handle = h->handle;
>  		offload.cls_u32->hnode.prio = h->prio;
>  
> +		/* No support hash tables at the moment so abort when given
> +		 * hash tables.
> +		 */

Cool so you cuaght this but how does the AST support hash tables? Some
of my above comments are around this.

> +		if (h->divisor > 0)
> +			return;
> +
> +		p = u32_parser_tables_get(tp);
> +		if (!p)
> +			return;
> +
> +		set_bit(TC_U32_USERHTID(offload.cls_u32->hnode.handle),
> +			&p->tables);
> +
>  		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
>  					      tp->protocol, &offload);
>  	}
> @@ -467,6 +679,7 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
>  	struct net_device *dev = tp->q->dev_queue->dev;
>  	struct tc_cls_u32_offload u32_offload = {0};
>  	struct tc_to_netdev offload;
> +	struct u32_parser_table *p;
>  
>  	offload.type = TC_SETUP_CLSU32;
>  	offload.cls_u32 = &u32_offload;
> @@ -477,11 +690,135 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
>  		offload.cls_u32->hnode.handle = h->handle;
>  		offload.cls_u32->hnode.prio = h->prio;
>  
> +		p = u32_parser_tables_get(tp);
> +		if (!p)
> +			return;
> +
> +		clear_bit(TC_U32_USERHTID(offload.cls_u32->hnode.handle),
> +			  &p->tables);
> +
>  		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
>  					      tp->protocol, &offload);
>  	}
>  }
>  

So I'm sorry but after reviewing this for a few hours this morning I'm
not convinced the complexity is worth the payoff. It seems to make the
code a bit heavy and the in-driver code path isn't actually any smaller.

Sure I get flower for free but with a bunch of overhead so I don't like
that and flower implementation is also simple in driver. Also bpf wont
fit in this model so I still need an ebpf parser.

So really this just unifies nft and u32 at the cost of another layer
of abstraction which I don't think provides much value. It seems like
I could get to the same place with a few helper functions for driver
writers to use without the overhead/code complexity of a bunch of new
pointers, allocated objects, needless translations and IR code that
now needs to be maintained and reviewed and supported.

My preference is to hold this work until we get a few more driver
implementation for multiple things and see if that can scale easily
as I suspect it might without having to over-engineer it.

Thanks,
.John
