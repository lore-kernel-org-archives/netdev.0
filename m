From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH v3] bridge: fix bridge netlink RCU usage
Date: Tue, 03 Mar 2015 06:31:29 -0800
Message-ID: <54F5C5C1.9000306@cumulusnetworks.com>
References: <1425390556-17844-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:37383 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756146AbbCCObe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 09:31:34 -0500
Received: by paceu11 with SMTP id eu11so10563380pac.4
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 06:31:31 -0800 (PST)
In-Reply-To: <1425390556-17844-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/3/15, 5:49 AM, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
>
> When the STP timer fires, it can call br_ifinfo_notify(),
> which in turn ends up in the new br_get_link_af_size().
> This function is annotated to be using RTNL locking, which
> clearly isn't the case here, and thus lockdep warns:
>
>    ===============================
>    [ INFO: suspicious RCU usage. ]
>    3.19.0+ #569 Not tainted
>    -------------------------------
>    net/bridge/br_private.h:204 suspicious rcu_dereference_protected() usage!
>
> Fix this by doing RCU locking here.
>
> Fixes: b7853d73e39b ("bridge: add vlan info to bridge setlink and dellink notification messages")
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>   net/bridge/br_netlink.c | 15 ++++++++-------
>   1 file changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 17e0177467f5..72d8efa9b1eb 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -25,19 +25,20 @@
>   static size_t br_get_link_af_size(const struct net_device *dev)
>   {
>   	struct net_port_vlans *pv;
> +	unsigned int num_vlans;
>   
> +	rcu_read_lock();
>   	if (br_port_exists(dev))
> -		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
> +		pv = nbp_get_vlan_info(br_port_get_rcu(dev));
>   	else if (dev->priv_flags & IFF_EBRIDGE)
> -		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
> +		pv = br_get_vlan_info(netdev_priv(dev));
>   	else
> -		return 0;
> -
> -	if (!pv)
> -		return 0;
> +		pv = NULL;
> +	num_vlans = pv ? pv->num_vlans : 0;
> +	rcu_read_unlock();
>   
>   	/* Each VLAN is returned in bridge_vlan_info along with flags */
> -	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
> +	return num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
>   }
>   
>   static inline size_t br_port_info_size(void)
Thanks!

I used an existing function and did not realize I was newly adding the 
stp notify case to the mix.
Will make sure I run with lockdep on next time.

My subsequent patch  in net-next related to this code, changes things a 
bit (fed0a159c8c5e453d79d6a73897c576efea0a8a5 bridge: fix link 
notification skb size calculation to include vlan ranges).
It reverts the use of this function which makes sure this is always 
called under rtnl.
But, I did add another version of this function in net-next which has 
the same problem.
Assuming that patch in net-next is on its way to net soon, am wondering 
if fixing it in net-next is the right course.

I can apply your patch there and re-submit. Or if you prefer to 
re-submit your patch on net-next that's great too.

please let me know.

Thanks,
Roopa
