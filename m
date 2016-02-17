From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH nf-next v7 4/7] openvswitch: Find existing conntrack entry
 after upcall.
Date: Wed, 17 Feb 2016 15:50:32 -0800
Message-ID: <CAPWQB7E7bKQVKxhLwA5_VJnon+U3j+1nZOiNWcqQ=CjEG=jn5w@mail.gmail.com>
References: <1454722865-59558-1-git-send-email-jarno@ovn.org> <1454722865-59558-5-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:44933 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965013AbcBQXu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 18:50:56 -0500
In-Reply-To: <1454722865-59558-5-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 February 2016 at 17:41, Jarno Rajahalme <jarno@ovn.org> wrote:
<snip>
>  /* Determine whether skb->nfct is equal to the result of conntrack lookup. */
> -static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
> -                           const struct ovs_conntrack_info *info)
> +static bool skb_nfct_cached(struct net *net,
> +                           const struct sw_flow_key *key,
> +                           const struct ovs_conntrack_info *info,
> +                           struct sk_buff *skb)
>  {
>         enum ip_conntrack_info ctinfo;
>         struct nf_conn *ct;
>
>         ct = nf_ct_get(skb, &ctinfo);
> +       /* If no ct, check if we have evidence that an existing conntrack entry
> +        * might be found for this skb.  This happens when we lose a skb->nfct
> +        * due to an upcall.  If the connection was not confirmed, it is not
> +        * cached and needs to be run through conntrack again. */
> +       if (!ct && key->ct.state & OVS_CS_F_TRACKED
> +           && !(key->ct.state & OVS_CS_F_INVALID)
> +           && key->ct.zone == info->zone.id)
> +               ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
> +                                         &ctinfo);
>         if (!ct)
>                 return false;

Logically I think that this makes more sense residing within
__ovs_ct_lookup() and actually populating skb->{nfct,nfctinfo} prior
to making this call to skb_nfct_cached() which answers the question
"Is skb->nfct the same as if I did a lookup?". Maybe a better name for
this function is something like ovs_ct_cmp() as it compares the skb's
nfct against the OVS structures.

The call to nf_ct_get() could move out into __ovs_ct_lookup(), then
just pass the 'ct' into here. I see that a later patch already adds
another call to nf_ct_get() into __ovs_ct_lookup(), which should only
be necessary in the case where it is not already cached.
