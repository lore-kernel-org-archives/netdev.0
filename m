From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Add eventmask support to CT
 action.
Date: Thu, 20 Apr 2017 08:26:47 -0700
Message-ID: <1492702007.17866.4.camel@gmail.com>
References: <1492653311-99269-1-git-send-email-jarno@ovn.org>
         <1492653311-99269-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f196.google.com ([209.85.213.196]:35015 "EHLO
        mail-yb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970528AbdDTP0v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:26:51 -0400
Received: by mail-yb0-f196.google.com with SMTP id 19so4321747ybl.2
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 08:26:51 -0700 (PDT)
In-Reply-To: <1492653311-99269-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-19 at 18:55 -0700, Jarno Rajahalme wrote:
> Add a new optional conntrack action attribute OVS_CT_ATTR_EVENTMASK,
> which can be used in conjunction with the commit flag
> (OVS_CT_ATTR_COMMIT) to set the mask of bits specifying which
> conntrack events (IPCT_*) should be delivered via the Netfilter
> netlink multicast groups.  Default behavior depends on the system
> configuration, but typically a lot of events are delivered.  This can be
> very chatty for the NFNLGRP_CONNTRACK_UPDATE group, even if only some
> types of events are of interest.
> 
> Netfilter core init_conntrack() adds the event cache extension, so we
> only need to set the ctmask value.  However, if the system is
> configured without support for events, the setting will be skipped due
> to extension not being found.
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Looks good to me but I'll let Joe ack it since I'm not that familiar
with the code yet.  Nevertheless...

Reviewed-by: Greg Rose <gvrose@8192@gmail.com>

> ---
>  include/uapi/linux/openvswitch.h | 12 ++++++++++++
>  net/openvswitch/conntrack.c      | 27 +++++++++++++++++++++++++++
>  2 files changed, 39 insertions(+)
> 
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index 66d1c3c..38ae95d 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -693,6 +693,17 @@ struct ovs_action_hash {
>   * nothing if the connection is already committed will check that the current
>   * packet is in conntrack entry's original direction.  If directionality does
>   * not match, will delete the existing conntrack entry and commit a new one.
> + * @OVS_CT_ATTR_EVENTMASK: Mask of bits indicating which conntrack event types
> + * (enum ip_conntrack_events IPCT_*) should be reported.  For any bit set to
> + * zero, the corresponding event type is not generated.  Default behavior
> + * depends on system configuration, but typically all event types are
> + * generated, hence listening on UPDATE events may get a lot of events.
> + * Explicitly passing this attribute allows limiting the updates received to
> + * the events of interest.  The bit 1 << IPCT_NEW, 1 << IPCT_RELATED, and
> + * 1 << IPCT_DESTROY must be set to ones for those events to be received on
> + * NFNLGRP_CONNTRACK_NEW and NFNLGRP_CONNTRACK_DESTROY groups, respectively.
> + * Remaining bits control the changes for which an event is delivered on the
> + * NFNLGRP_CONNTRACK_UPDATE group.
>   */
>  enum ovs_ct_attr {
>  	OVS_CT_ATTR_UNSPEC,
> @@ -704,6 +715,7 @@ enum ovs_ct_attr {
>  				   related connections. */
>  	OVS_CT_ATTR_NAT,        /* Nested OVS_NAT_ATTR_* */
>  	OVS_CT_ATTR_FORCE_COMMIT,  /* No argument */
> +	OVS_CT_ATTR_EVENTMASK,  /* u32 mask of IPCT_* events. */
>  	__OVS_CT_ATTR_MAX
>  };
>  
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 58de4c2..4f7c3b5 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -66,7 +66,9 @@ struct ovs_conntrack_info {
>  	u8 commit : 1;
>  	u8 nat : 3;                 /* enum ovs_ct_nat */
>  	u8 force : 1;
> +	u8 have_eventmask : 1;
>  	u16 family;
> +	u32 eventmask;              /* Mask of 1 << IPCT_*. */
>  	struct md_mark mark;
>  	struct md_labels labels;
>  #ifdef CONFIG_NF_NAT_NEEDED
> @@ -1007,6 +1009,20 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
>  	if (!ct)
>  		return 0;
>  
> +	/* Set the conntrack event mask if given.  NEW and DELETE events have
> +	 * their own groups, but the NFNLGRP_CONNTRACK_UPDATE group listener
> +	 * typically would receive many kinds of updates.  Setting the event
> +	 * mask allows those events to be filtered.  The set event mask will
> +	 * remain in effect for the lifetime of the connection unless changed
> +	 * by a further CT action with both the commit flag and the eventmask
> +	 * option. */
> +	if (info->have_eventmask) {
> +		struct nf_conntrack_ecache *cache = nf_ct_ecache_find(ct);
> +
> +		if (cache)
> +			cache->ctmask = info->eventmask;
> +	}
> +
>  	/* Apply changes before confirming the connection so that the initial
>  	 * conntrack NEW netlink event carries the values given in the CT
>  	 * action.
> @@ -1238,6 +1254,8 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
>  	/* NAT length is checked when parsing the nested attributes. */
>  	[OVS_CT_ATTR_NAT]	= { .minlen = 0, .maxlen = INT_MAX },
>  #endif
> +	[OVS_CT_ATTR_EVENTMASK]	= { .minlen = sizeof(u32),
> +				    .maxlen = sizeof(u32) },
>  };
>  
>  static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
> @@ -1316,6 +1334,11 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
>  			break;
>  		}
>  #endif
> +		case OVS_CT_ATTR_EVENTMASK:
> +			info->have_eventmask = true;
> +			info->eventmask = nla_get_u32(a);
> +			break;
> +
>  		default:
>  			OVS_NLERR(log, "Unknown conntrack attr (%d)",
>  				  type);
> @@ -1515,6 +1538,10 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
>  				   ct_info->helper->name))
>  			return -EMSGSIZE;
>  	}
> +	if (ct_info->have_eventmask &&
> +	    nla_put_u32(skb, OVS_CT_ATTR_EVENTMASK, ct_info->eventmask))
> +		return -EMSGSIZE;
> +
>  #ifdef CONFIG_NF_NAT_NEEDED
>  	if (ct_info->nat && !ovs_ct_nat_to_attr(ct_info, skb))
>  		return -EMSGSIZE;
