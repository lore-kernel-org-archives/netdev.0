From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH v4] bridge: fix bridge netlink RCU usage
Date: Tue, 03 Mar 2015 08:08:51 -0800
Message-ID: <54F5DC93.1040600@cumulusnetworks.com>
References: <1425394936-11595-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:45005 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756089AbbCCQIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 11:08:53 -0500
Received: by pdbft15 with SMTP id ft15so27149059pdb.11
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 08:08:53 -0800 (PST)
In-Reply-To: <1425394936-11595-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/3/15, 7:02 AM, Johannes Berg wrote:
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
>   net/bridge/br_netlink.c | 14 ++++++++------
>   1 file changed, 8 insertions(+), 6 deletions(-)
>
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 3de0eefe2b82..c72083968768 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -81,17 +81,19 @@ static size_t br_get_link_af_size_filtered(const struct net_device *dev,
>   	struct net_port_vlans *pv;
>   	int num_vlan_infos;
>   
> +	rcu_read_lock();
>   	if (br_port_exists(dev))
> -		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
> +		pv = nbp_get_vlan_info(br_port_get_rcu(dev));
>   	else if (dev->priv_flags & IFF_EBRIDGE)
>   		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
>   	else
> -		return 0;
> -
> -	if (!pv)
> -		return 0;
> +		pv = NULL;
> +	if (pv)
> +		num_vlan_infos = br_get_num_vlan_infos(pv, filter_mask);
> +	else
> +		num_vlan_infos = 0;
> +	rcu_read_unlock();
>   
> -	num_vlan_infos = br_get_num_vlan_infos(pv, filter_mask);
>   	if (!num_vlan_infos)
>   		return 0;
>   
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

The patch may have to be marked with prefix 'net-next' ?. (unless dave 
infers it from the thread)

Thanks again!
