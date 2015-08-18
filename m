From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] vrf: vrf_master_ifindex_rcu is not always called
 with rcu read lock
Date: Tue, 18 Aug 2015 13:45:20 -0600
Message-ID: <55D38B50.1030004@cumulusnetworks.com>
References: <1439914666-7561-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35316 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbbHRTpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:45:22 -0400
Received: by iodt126 with SMTP id t126so202919803iod.2
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 12:45:21 -0700 (PDT)
In-Reply-To: <1439914666-7561-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/15 10:17 AM, Nikolay Aleksandrov wrote:
> diff --git a/include/net/vrf.h b/include/net/vrf.h
> index 40e3793c7a05..22dfe2195092 100644
> --- a/include/net/vrf.h
> +++ b/include/net/vrf.h
> @@ -35,7 +35,6 @@ struct net_vrf {
>
>
>   #if IS_ENABLED(CONFIG_NET_VRF)
> -/* called with rcu_read_lock() */
>   static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
>   {
>   	struct net_vrf_dev *vrf_ptr;
> @@ -44,12 +43,14 @@ static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
>   	if (!dev)
>   		return 0;
>
> -	if (netif_is_vrf(dev))
> +	if (netif_is_vrf(dev)) {
>   		ifindex = dev->ifindex;
> -	else {
> +	} else {
> +		rcu_read_lock();
>   		vrf_ptr = rcu_dereference(dev->vrf_ptr);
>   		if (vrf_ptr)
>   			ifindex = vrf_ptr->ifindex;
> +		rcu_read_unlock();
>   	}
>
>   	return ifindex;
>

The intent of the _rcu in the name is to mean it is called with 
rcu_read_lock held which is the case for __fib_validate_source and 
ip_route_input_slow. It looks like the icmp callers (icmp_reply and 
icmp_route_lookup) are the exceptions. For those create a

static inline int vrf_master_ifindex(const struct net_device *dev)
{

}

that does the rcu lock/unlock and calls vrf_master_ifindex_rcu in between.
