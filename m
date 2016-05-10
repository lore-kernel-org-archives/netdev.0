From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net] openvswitch: Fix cached ct with helper.
Date: Tue, 10 May 2016 16:55:33 -0700
Message-ID: <67865008-7CDC-469D-8EAA-C097C19F7408@ovn.org>
References: <1462905631-12209-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35157 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbcEJXzh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 19:55:37 -0400
Received: by mail-pf0-f195.google.com with SMTP id r187so2734665pfr.2
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 16:55:37 -0700 (PDT)
In-Reply-To: <1462905631-12209-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This would result in inconsistent helper assignment if a first CT action assigns a helper and a further CT action tries to assign a different helper; Typically the second helper assignment would be ignored, but if the unconfirmed conntrack entry is lost due to an upcall the second helper assignment would be successful.  This is best resolved by allowing helper assignment by a committing CT action only by testing the 'info->commit' flag in addition to the conditions you have there already. It may also be helpful to fail helper assignment without the commit flag in parse_ct().

  Jarno

> On May 10, 2016, at 11:40 AM, Joe Stringer <joe@ovn.org> wrote:
> 
> When using conntrack helpers from OVS, a common configuration is to
> perform a lookup without specifying a helper, then go through a
> firewalling policy, only to decide to attach a helper afterwards.
> 
> In this case, the initial lookup will cause a ct entry to be attached to
> the skb, then the later commit with helper should attach the helper and
> confirm the connection. However, the helper attachment has been missing.
> If the user has enabled automatic helper attachment, then this issue
> will be masked as it will be applied in init_conntrack(). It is also
> masked if the action is executed from ovs_packet_cmd_execute() as that
> will construct a fresh skb.
> 
> This patch fixes the issue by making an explicit call to try to assign
> the helper if there is a discrepancy between the action's helper and the
> current skb->nfct.
> 
> Fixes: cae3a2627520 ("openvswitch: Allow attaching helpers to ct action")
> Signed-off-by: Joe Stringer <joe@ovn.org>
> ---
> net/openvswitch/conntrack.c | 12 ++++++++++++
> 1 file changed, 12 insertions(+)
> 
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index b5fea1101faa..89f61a1720eb 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -776,6 +776,18 @@ static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
> 			return -EINVAL;
> 		}
> 
> +		/* Userspace may decide to perform a ct lookup without a helper
> +		 * specified followed by a (recirculate and) commit with one.
> +		 * Therefore, for unconfirmed connections we need to attach the
> +		 * helper here.
> +		 */
> +		if (!nf_ct_is_confirmed(ct) && info->helper && !nfct_help(ct)) {
> +			int err = __nf_ct_try_assign_helper(ct, info->ct,
> +							    GFP_ATOMIC);
> +			if (err)
> +				return err;
> +		}
> +
> 		/* Call the helper only if:
> 		 * - nf_conntrack_in() was executed above ("!cached") for a
> 		 *   confirmed connection, or
> -- 
> 2.1.4
> 
