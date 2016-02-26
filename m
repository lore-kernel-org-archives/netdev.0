From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RFC 3/3] net: convert tc_u32 to use the intermediate
 representation
Date: Fri, 26 Feb 2016 15:24:02 +0100
Message-ID: <20160226142402.GB2523@salvia>
References: <1456421844-5901-1-git-send-email-pablo@netfilter.org>
 <1456421844-5901-4-git-send-email-pablo@netfilter.org>
 <56CF6612.6040900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	horms@verge.net.au
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54539 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853AbcBZOYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 09:24:14 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 43E95ED06C
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 15:24:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 32165DA8F9
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 15:24:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 93C7BDA8F9
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 15:24:07 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <56CF6612.6040900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2016 at 12:37:38PM -0800, John Fastabend wrote:
> On 16-02-25 09:37 AM, Pablo Neira Ayuso wrote:
> > This patch moves the u32 parser from the ixgbe that John has made to the
> > core u32. This parser has been adapted to build the intermediate
> > representation.
> > 
> > To store the parsing information, this patch introduces a parse table
> > object, one per device, so we don't need to store the parsing states in
> > the adapter, which is the major dependency with previous patches.
> > 
> > Since u32 allows rules connected via links, the u32 parser tracks this
> > links and then generates the intermediate representation that is passed
> > to the ixgbe driver.
> 
> It also supports hash tables and loops.

Then, it is a matter of extending the tc-u32 parser and the IR to
support whatever you need.

> > New drivers will only have to implement the jit translation code based
> > on the intermediate representation. With some extra work, I think it
> > should be possible to generalize the existing tc specific ndo action so
> > it can be used by other frontends.
> > 
> > I tried to stick to John's original u32 frontend parser as much as
> > possible, adapting it to build the intermediate representation.
> > 
> > After this change, we don't expose the tc action structure layout and
> > other similar frontend details to the backend anymore to the backend
> > anymore. I think this is good since changes in the frontend should not
> > need to be propagated to the 1..n drivers supporting u32 offloads. In
> > that sense, this helps to keep the frontend software representation
> > separated from low-level backend driver details.
> > 
> > After this patch, it should be possible to put the tc_cls_u32_knode
> > structure into diet since we only need the handle (as unique id) and the
> > ast tree.
> > 
> 
> On ixgbe this is true but going forward I can support hash functions
> so you need the divisor, prio, and handle minimally. I'm not sure how
> to do hash tables for example in this IR yet. Might be there I'm still
> trying to grok the IR details.

We just need a description with the list elements that you want to
place in the hashtable.

The matching can be expressed in ast by adding a list of elements that
are part of the hashtable:

                 relational
                    / \
                   /   \
                  /     \
           payload      list of elements
  (offset, base, len)       |
                            \
                             --> e1 --> e2 --> ... --> en

> > I couldn't send any more incremental changes to update previous work
> > since the u32 parser and the internal representation were put together,
> > that why this patch is slightly large.
> > 
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> > ---
> >  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |   4 -
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  | 216 ++++++++--------
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 112 --------
> >  include/net/pkt_cls.h                          |   3 +
> >  net/sched/cls_u32.c                            | 344 +++++++++++++++++++++++++
> 
> Feels like a lot of code to me when the original direct u32 to hw
> was reasonably small and the flower implementation is small as well.

This is your tc-u32 parser plus simple boiler plate code to build the
IR that will be common to everyone. Without this, other drivers will
have to track u32 links and so on.

Other than that, we'll end up with 1..N different u32 parsers in the
backend.

> [...]
> 
> >  
> > +static int ixgbe_tcp_jit(struct net_ir_jit_ctx *ctx,
> > +			 const struct net_ir_expr *expr,
> > +			 void *data)
> > +{
> > +	struct ixgbe_filter *f = (struct ixgbe_filter *)data;
> > +	struct net_ir_expr *right = expr->relational.right;
> > +	struct net_ir_expr *payload;
> > +	u32 mask = 0xffffffff;
> > +
> > +	if (expr->relational.left->type == NET_IR_EXPR_BINOP) {
> > +		payload = expr->relational.left->binop.left;
> > +		mask = expr->relational.left->binop.right->value.data;
> > +	} else {
> > +		payload = expr->relational.left;
> > +	}
> > +
> > +	switch (payload->payload.offset) {
> 
> I don't like this because it hardcodes the offset pieces into the
> driver. The reason I used a model.h header file with its structures
> in ixgbe is the next step is to expose the parser so the model can be
> updated. So that when the hardware parser changes the data structure
> can be changed via firmware call. The style of coding here wont work
> for that so we still need the model.h file and for loop.

Model update via firmware?

I think it's been already several conference rounds insisting on the
fact that we don't want infrastructure that allows to insert binary
blobs/sdks.

I don't think this is the way to go.

> [...]
> 
> >  static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
> >  				  __be16 protocol,
> >  				  struct tc_cls_u32_offload *cls)
> >  {
> >  	u32 loc = cls->knode.handle & 0xfffff;
> >  	struct ixgbe_hw *hw = &adapter->hw;
> > -	struct ixgbe_mat_field *field_ptr;
> >  	struct ixgbe_filter f;
> > -#ifdef CONFIG_NET_CLS_ACT
> > -	const struct tc_action *a;
> > -#endif
> > -	int i, err = 0;
> > +	int err = 0;
> >  	u32 handle;
> >  
> >  	memset(&f.mask, 0, sizeof(union ixgbe_atr_input));
> >  	handle = cls->knode.handle;
> >  
> > -	/* At the moment cls_u32 jumps to transport layer and skips past
> > -	 * L2 headers. The canonical method to match L2 frames is to use
> > -	 * negative values. However this is error prone at best but really
> > -	 * just broken because there is no way to "know" what sort of hdr
> > -	 * is in front of the transport layer. Fix cls_u32 to support L2
> > -	 * headers when needed.
> > -	 */
> > -	if (protocol != htons(ETH_P_IP))
> 
> This was hardcoded originally just to find the inital offset going
> forward I want to patch u32 to start at the link layer to avoid
> this.

Then, you extend the tc-u32 parser, but from the frontend core
infrastructure code, so everyone we'll benefit for this incremental
update.

> [...]
> 
> > -		if (!found_entry)
> > -			goto err_out;
> > -	}
> > +	if (net_ir_jit(&cls->knode.ast, &ixgbe_desc, &f) < 0)
> > +		return -EINVAL;
> >  
> 
> OK but this takes a cls_u32 offload engine that was running on a handful
> of LOC + a header file description that in the future will be read out
> of firmware and replaces it with an entire infrastructure. I'm not
> convinced the added complexity is worth it.

It's all about consolidating infrastructure.

> [...]
> 
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
> > +++ /dev/null
> > @@ -1,112 +0,0 @@
> > -/*******************************************************************************
> > - *
> > - * Intel 10 Gigabit PCI Express Linux drive
> > - * Copyright(c) 2016 Intel Corporation.
> > - *
> > - * This program is free software; you can redistribute it and/or modify it
> > - * under the terms and conditions of the GNU General Public License,
> > - * version 2, as published by the Free Software Foundation.
> > - *
> > - * This program is distributed in the hope it will be useful, but WITHOUT
> > - * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> > - * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> > - * more details.
> > - *
> > - * You should have received a copy of the GNU General Public License along
> > - * with this program.  If not, see <http://www.gnu.org/licenses/>.
> > - *
> > - * The full GNU General Public License is included in this distribution in
> > - * the file called "COPYING".
> > - *
> > - * Contact Information:
> > - * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
> > - * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
> > - *
> > - ******************************************************************************/
> > -
> > -#ifndef _IXGBE_MODEL_H_
> > -#define _IXGBE_MODEL_H_
> > -
> > -#include "ixgbe.h"
> > -#include "ixgbe_type.h"
> > -
> > -struct ixgbe_mat_field {
> > -	unsigned int off;
> > -	unsigned int mask;
> > -	int (*val)(struct ixgbe_fdir_filter *input,
> > -		   union ixgbe_atr_input *mask,
> > -		   u32 val, u32 m);
> > -	unsigned int type;
> > -};
> 
> As noted above the intent is to make the parser programmable so
> something like this model needs to exist for firmware to populate.

Oh, again references to update via firmware.

[...]
> My preference is to hold this work until we get a few more driver
> implementation for multiple things and see if that can scale easily
> as I suspect it might without having to over-engineer it.

I don't agree, that's simply preventing by now other frontends and
drivers to get offload support.
