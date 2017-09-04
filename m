From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Mon, 4 Sep 2017 16:00:05 +0800
Message-ID: <20170904080005.GA70767@cran64.bj.intel.com>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
 <20170831124516.0c5db686@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "e@erig.me" <e@erig.me>, "blp@ovn.org" <blp@ovn.org>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56928 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753329AbdIDIPE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 4 Sep 2017 04:15:04 -0400
Content-Disposition: inline
In-Reply-To: <20170831124516.0c5db686@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 06:45:16PM +0800, Jiri Benc wrote:
> > +				       mask->context[i]);
> > +		}
> > +		memcpy(flow_key->nsh.context, nsh->md1.context,
> > +		       sizeof(nsh->md1.context));
> 
> Do you follow the discussion that Hannes Sowa started on the ovs list
> regarding matching on the context fields? It would be better to hold on this
> until there's a conclusion reached.
>

I think we have had similiar discussion about this, the issue is we have
no way to handle both MD type 1 and MD type 2 by using a common flow key struct.

So we have to do so, there is miniflow to handle such issue in
userspace, but kernel data path didn't provide such mechanism. I think
every newly-added key will result in the same space-wasting issue for
kernel data path, isn't it?

> > +		err = nsh_key_from_nlattr(&attr.nla, &nsh);
> > +		if (err)
> > +			break;
> > +		err = nsh_key_from_nlattr(&mask.nla, &nsh_mask);
> > +		if (err)
> > +			break;
> 
> This is a lot of copying to just be able to use nla_for_each_nested. While
> I'm not a fan of how ovs uses the attributes to store both value and mask,
> it's not completely irrational. However, I don't think that the intent was
> to store a copy of the whole nested group. It's quite obvious that it does
> not fit the pattern from the gymnastics you need to do.
> 
> Instead, store the mask in each of the nested attributes individually. There
> will be no need for the copying above and the code will get cleaner and
> faster. It's not that the nsh_key_from_nlattr function needs to be able to
> work separately for the key and mask. Nothing else than the line above uses
> this function. Just move the logic inside.
> 
> Actually, it seems it can be moved directly to set_nsh.

OVS_ATTR_KEY_NSH is the first case to use nested attributes for set
action, so no reference code for this, set action has two use cases, one
has mask but the other hasn't, so it will be easier an nested attribute is
handled as a whole, in user space, nsh_key_from_nlattr is used in
several places. If we change it per your proposal, there will be a lot
of rework, we have to provide two functions to handle this, one is for
the case with mask, the other is for the case without mask.

> 
> > +		err = set_nsh(skb, flow_key, &nsh, &nsh_mask);
> > +		break;
> > +	}
> > +
> >  	case OVS_KEY_ATTR_IPV4:
> >  		err = set_ipv4(skb, flow_key, nla_data(a),
> >  			       get_mask(a, struct ovs_key_ipv4 *));
> > @@ -1210,6 +1336,21 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> >  		case OVS_ACTION_ATTR_POP_ETH:
> >  			err = pop_eth(skb, key);
> >  			break;
> > +
> > +		case OVS_ACTION_ATTR_PUSH_NSH: {
> > +			u8 buffer[NSH_HDR_MAX_LEN];
> > +			struct nshhdr *nsh_hdr = (struct nshhdr *)buffer;
> > +			const struct nshhdr *nsh_src = nsh_hdr;
> > +
> > +			nsh_hdr_from_nlattr(nla_data(a), nsh_hdr,
> > +					    NSH_HDR_MAX_LEN);
> 
> This is costly. This is called for every packet in the fast path. We should
> precompute and store the header instead.

How can we do so? I see batch process code in user space implementation,
but kernel data path didn't such infrastructure, how can we know next
push_nsh uses the same nsh header as previous one?

> > +	case NSH_M_TYPE2:
> > +		/* Don't support MD type 2 metedata parsing yet */
> > +		if (length < NSH_BASE_HDR_LEN)
> > +			return -EINVAL;
> 
> Shouldn't we reject the packet, then? Pretending that something was parsed
> correctly while in fact it was not, does not look correct.

For MD type 2, we don't implement metadata parsing, but it can still
work. I'm not sure what you mean here, how do we reject a packet here?

> 
> These checks should be done only once when the action is configured, not for
> each packet.

I don't know how to implement a batch processing in kernel data path, it
seems there isn't such code for reference.
