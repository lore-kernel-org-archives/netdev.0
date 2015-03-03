From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bridge: fix bridge netlink RCU usage
Date: Tue, 03 Mar 2015 05:40:38 -0800
Message-ID: <1425390038.5130.171.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425389374-12568-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:40498 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756102AbbCCNkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 08:40:40 -0500
Received: by iebtr6 with SMTP id tr6so57894518ieb.7
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 05:40:40 -0800 (PST)
In-Reply-To: <1425389374-12568-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-03 at 14:29 +0100, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> When the STP timer fires, it can call br_ifinfo_notify(),
> which in turn ends up in the new br_get_link_af_size().
> This function is annotated to be using RTNL locking, which
> clearly isn't the case here, and thus lockdep warns:
> 
>   ===============================
>   [ INFO: suspicious RCU usage. ]
>   3.19.0+ #569 Not tainted
>   -------------------------------
>   net/bridge/br_private.h:204 suspicious rcu_dereference_protected() usage!
> 
> Fix this by doing RCU locking here.
> 
> Fixes: b7853d73e39b ("bridge: add vlan info to bridge setlink and dellink notification messages")
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  net/bridge/br_netlink.c | 11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 17e0177467f5..c63ac0d13add 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -26,12 +26,15 @@ static size_t br_get_link_af_size(const struct net_device *dev)
>  {
>  	struct net_port_vlans *pv;
>  
> -	if (br_port_exists(dev))
> -		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
> -	else if (dev->priv_flags & IFF_EBRIDGE)
> +	if (br_port_exists(dev)) {
> +		rcu_read_lock();
> +		pv = nbp_get_vlan_info(br_port_get_rcu(dev));
> +		rcu_read_unlock();

right after this rcu_read_unlock(), you no longer are allowed to deref
pv


> +	} else if (dev->priv_flags & IFF_EBRIDGE) {
>  		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
> -	else
> +	} else {
>  		return 0;
> +	}
>  
>  	if (!pv)
>  		return 0;
