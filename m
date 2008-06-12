From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] Do not activate promiscuous mode on wlan interfaces for
 bridging.
Date: Thu, 12 Jun 2008 11:13:58 -0700
Message-ID: <20080612111358.30980552@extreme>
References: <4850672a.1abd600a.56e0.ffffa374@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j@w1.fi, johannes@sipsolutions.net,
	bridge@linux-foundation.org, linux-wireless@vger.kernel.org
To: luisca@cozybit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42063 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752042AbYFLSOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 14:14:50 -0400
In-Reply-To: <4850672a.1abd600a.56e0.ffffa374@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jun 2008 16:18:20 -0700
luisca@cozybit.com wrote:

> I have come across a 802.11 device that stops acknowledging frames addressed to
> it when in promiscuous mode. The device can act as an AP with hostapd. However,
> when the interface is attached to a bridge the lack of acknowledgments makes the
> device non-functional as an AP.
> 
> It seems that it is not really necessary to activate promiscuous mode when
> attaching a wlan interface to a bridge, and it causes unnecessary processing
> overhead to any wlan device.
> 
> Case 1: Ethernet to ethernet
> ----------------------------
> 
> A <----> BRIDGE <----> B
> 
> The bridge needs to set promiscuous mode on both interfaces.
> 
> Case 2: Ethernet to 802.11 through AP
> -------------------------------------
> 
> A <----> BRIDGE/AP -))  ((- B
> 
> The ethernet interface needs to be in promiscuous mode so that frames from A to
> B are received by the bridge and then forwarded.
> 
> However, the wlan interface does _not_ need to be a promiscuous mode. A 802.11
> frame from B to A will have:
> 
> ToDS
> RA = BSSID = MAC_AP
> TA = SA = MAC_B
> DA = MAC_A
> 
> Frames are naturally addressed to the AP, so the wlan interface does not need to
> be in promiscuous mode. Activating promiscuous mode would actually force the
> device to deal with many frames it does not really have to deal with.
> 
> Case 3: Ethernet to 802.11 through IBSS / Managed STAs
> ------------------------------------------------------
> 
> A <----> BRIDGE/IBSS_STA_B -))  ((- IBSS_STA_C
> 
> or
> 
> A <----> BRIDGE/STA -))  ((- AP
> 
> In this case the frames on the wireless segment will not be naturally addressed
> to the bridge, so activating promiscuous mode on the wireless interface would be
> necessary for the bridge to work. However there are three problems here:
> 
> First as Jouni Malinen states [1], this would not comply with 802.11 standard,
> which does not allow to use as SA a MAC address other than our own. If we do it
> anyway, we will have to look for 802.11 ACKs to the MAC address we bridge to
> control frame retransmissions. I do not think any device does this.
> 
> Second, such a bridge would be responsible for sending 802.11 ACKs for any
> 802.11 frame addressed to a MAC in the ethernet segment it bridges to. As acking
> is usually implemented at MAC level I do not think any device supports this.
> 
> Third, on the managed STA case, the STA would have to fake an association with
> the AP for A (and every other node in the ethernet segment it bridges to).  While
> doable, it adds unnecessary ugly complexity.
> 
> Even with these problems the bridging might "work", but every frame on the wlan
> segment from/to the bridged ethernet will have to be retransmitted the maximum
> number of times since acks would not work properly.
> 
> Given this three cases, the best would be to consider case 3 to be not
> supported (it is indeed not supported, AFAIK), and apply the patch below.
> 
> Please let me know what you think of this patch and whether it could interfere
> with any functionality.
> 
> Nomenclature
> RA = receiver address
> TA = transmitter address
> SA = source address
> BSSID = basic service set identifier
> <----> = Ethernet link
> -)) ((- = 802.11 link
> 
> [1]: http://marc.info/?l=linux-wireless&m=117881727809631&w=2
> 
> Signed-off-by: Luis Carlos Cobo <luisca@cozybit.com>
> ---
>  net/bridge/br_if.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index c2397f5..155bd90 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -135,7 +135,8 @@ static void del_nbp(struct net_bridge_port *p)
>  
>  	sysfs_remove_link(br->ifobj, dev->name);
>  
> -	dev_set_promiscuity(dev, -1);
> +	if (!dev->ieee80211_ptr)
> +		dev_set_promiscuity(dev, -1);
>  
>  	spin_lock_bh(&br->lock);
>  	br_stp_disable_port(p);
> @@ -389,7 +390,15 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  		goto err2;
>  
>  	rcu_assign_pointer(dev->br_port, p);
> -	dev_set_promiscuity(dev, 1);
> +	/*
> +	 * 802.11 interfaces working as Access Points do not need to be set to
> +	 * promiscuous mode for bridging, as every frame is addressed to them.
> +	 *
> +	 * Bridging of 802.11 interfaces which are not in AP mode is not
> +	 * supported.
> +	 */
> +	if (!dev->ieee80211_ptr)
> +		dev_set_promiscuity(dev, 1);
>  
>  	list_add_rcu(&p->list, &br->port_list);
>  

NACK too much of a one off hack. If the device can't do promiscuous or bridging
properly, it should solve the problem there. Otherwise you will have to fix all
other uses of promiscuous as well.
