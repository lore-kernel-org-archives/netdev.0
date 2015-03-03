From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Fix serialization of non-masked set actions.
Date: Tue, 3 Mar 2015 11:29:51 -0800
Message-ID: <CB1EBA11-66CF-415D-A22D-12F791882289@nicira.com>
References: <1425350996-2930-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:56604 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754508AbbCCT3U convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 14:29:20 -0500
Received: by mail-pd0-f174.google.com with SMTP id v10so4242726pde.0
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 11:29:19 -0800 (PST)
In-Reply-To: <1425350996-2930-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for spotting and fixing this,

Acked-by: Jarno Rajahalme <jrajahalme@nicira.com>

> On Mar 2, 2015, at 6:49 PM, Joe Stringer <joestringer@nicira.com> wrote:
> 
> Set actions consist of a regular OVS_KEY_ATTR_* attribute nested inside
> of a OVS_ACTION_ATTR_SET action attribute. When converting masked actions
> back to regular set actions, the inner attribute length was not changed,
> ie, double the length being serialized. This patch fixes the bug.
> 
> Fixes: 83d2b9b ("net: openvswitch: Support masked set actions.")
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> This fix needs to be applied to net as well; it applies cleanly.
> ---
> net/openvswitch/flow_netlink.c |    8 +++++++-
> 1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index 216f20b..22b18c1 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -2253,14 +2253,20 @@ static int masked_set_action_to_set_action_attr(const struct nlattr *a,
> 						struct sk_buff *skb)
> {
> 	const struct nlattr *ovs_key = nla_data(a);
> +	struct nlattr *nla;
> 	size_t key_len = nla_len(ovs_key) / 2;
> 
> 	/* Revert the conversion we did from a non-masked set action to
> 	 * masked set action.
> 	 */
> -	if (nla_put(skb, OVS_ACTION_ATTR_SET, nla_len(a) - key_len, ovs_key))
> +	nla = nla_nest_start(skb, OVS_ACTION_ATTR_SET);
> +	if (!nla)
> 		return -EMSGSIZE;
> 
> +	if (nla_put(skb, nla_type(ovs_key), key_len, nla_data(ovs_key)))
> +		return -EMSGSIZE;
> +
> +	nla_nest_end(skb, nla);
> 	return 0;
> }
> 
> -- 
> 1.7.10.4
> 
