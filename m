From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: reinject arps into bonding slave
 instead of master
Date: Tue, 8 Mar 2011 08:13:51 +0100
Message-ID: <20110308071350.GA2826@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-7-git-send-email-jpirko@redhat.com>
 <4D7249BA.8030401@gmail.com>
 <20110305144314.GC8573@psychotron.redhat.com>
 <4D724DB4.9020207@gmail.com>
 <4D737D00.20406@gmail.com>
 <20110306133413.GB2795@psychotron.redhat.com>
 <20110307125059.GA6053@psychotron.brq.redhat.com>
 <20110307224338.GU11864@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732Ab1CHHOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 02:14:33 -0500
Content-Disposition: inline
In-Reply-To: <20110307224338.GU11864@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 07, 2011 at 11:43:38PM CET, andy@greyhouse.net wrote:
>On Mon, Mar 07, 2011 at 01:51:00PM +0100, Jiri Pirko wrote:
>> Recent patch "bonding: move processing of recv handlers into
>> handle_frame()" caused a regression on following net scheme:
>> 
>> eth0 - bond0 - bond0.5
>> 
>> where arp monitoring is happening over vlan. This patch fixes it by
>> reinjecting the arp packet into bonding slave device so the bonding
>> rx_handler can pickup and process it.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>>  net/core/dev.c |    8 ++++----
>>  1 files changed, 4 insertions(+), 4 deletions(-)
>> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index c71bd18..3d88458 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3094,12 +3094,12 @@ void netdev_rx_handler_unregister(struct net_device *dev)
>>  }
>>  EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
>>  
>> -static void vlan_on_bond_hook(struct sk_buff *skb)
>> +static void vlan_on_bond_hook(struct sk_buff *skb, struct net_device *orig_dev)
>>  {
>>  	/*
>>  	 * Make sure ARP frames received on VLAN interfaces stacked on
>>  	 * bonding interfaces still make their way to any base bonding
>> -	 * device that may have registered for a specific ptype.
>> +	 * device by reinjecting the frame into bonding slave (orig_dev)
>>  	 */
>>  	if (skb->dev->priv_flags & IFF_802_1Q_VLAN &&
>>  	    vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING &&
>> @@ -3108,7 +3108,7 @@ static void vlan_on_bond_hook(struct sk_buff *skb)
>>  
>>  		if (!skb2)
>>  			return;
>> -		skb2->dev = vlan_dev_real_dev(skb->dev);
>> +		skb2->dev = orig_dev;
>>  		netif_rx(skb2);
>>  	}
>>  }
>> @@ -3202,7 +3202,7 @@ ncls:
>>  			goto out;
>>  	}
>>  
>> -	vlan_on_bond_hook(skb);
>> +	vlan_on_bond_hook(skb, orig_dev);
>>  
>>  	/* deliver only exact match when indicated */
>>  	null_or_dev = deliver_exact ? skb->dev : NULL;
>
>This patch doesn't work.
>
>My setup has bond0.100 -> bond0 -> eth2 and eth3.  ARP monitoring is
>enabled as is arp_valiate.
>
>The initial problem was just that just before vlan_on_bond_hook is
>called, skb->dev = bond0.100 and orig_dev = eth2.   (This is after
>running goto another_route and having been called back through
>__netif_receive_skb since vlan_hwaccel_do_receive it true.)
>
>Now vlan_on_bond_hook is called and we have 2 skbs.
>
>The original skb still have skb->dev = bond0.100 and orig_dev = eth2.
>Since bond_arp_rcv is registered for traffic only to bond0, the handler
>is not hit and the frame is dropped (or processed by another handler).
>
>The cloned skb has skb->dev = bond0 and is put back on the receive queue
>and comes back through __netif_receive_skb.  This frame will match the
>ptype entry for bond_arp_rcv, but since orig_dev = bond0 in this case,
>the code in bond_arp_rcv will not handle the frame.  
>
>If we truly want to track the original interface that received the
>frame, the following is a better option.  With the recursive nature of
>__netif_receive_skb at this point, we should really consider setting
>orig_dev from skb_iif rather than just from skb->dev.
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index 30440e7..500fdbc 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -3135,7 +3135,6 @@ static int __netif_receive_skb(struct sk_buff *skb)
> 
> 	if (!skb->skb_iif)
> 		skb->skb_iif = skb->dev->ifindex;
>-	orig_dev = skb->dev;
> 
> 	skb_reset_network_header(skb);
> 	skb_reset_transport_header(skb);
>@@ -3145,6 +3144,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
> 
> 	rcu_read_lock();
> 
>+	orig_dev = dev_get_by_index_rcu(dev_net(skb->dev),skb->skb_iif);
> another_round:
> 
> 	__this_cpu_inc(softnet_data.processed);
>

This was proposed earlier. people did not like this very much :(

I forgot to include crucial part of "goto another_round for vlan".
Following patch should work (will test it once I get to work):

Subject: [patch net-next 2.6] net: reinject arps into bonding slave instead of master

Recent patch "bonding: move processing of recv handlers into
handle_frame()" caused a regression on following net scheme:

eth0 - bond0 - bond0.5

where arp monitoring is happening over vlan. This patch fixes it by
reinjecting the arp packet into bonding slave device so the bonding
rx_handler can pickup and process it.

also instead of calling __netif_receive_skb recursively, "goto another
round" does this recursion. The point is the orig_dev variable remains
intact.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/core/dev.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c71bd18..ec330e1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3094,12 +3094,12 @@ void netdev_rx_handler_unregister(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
 
-static void vlan_on_bond_hook(struct sk_buff *skb)
+static void vlan_on_bond_hook(struct sk_buff *skb, struct net_device *orig_dev)
 {
 	/*
 	 * Make sure ARP frames received on VLAN interfaces stacked on
 	 * bonding interfaces still make their way to any base bonding
-	 * device that may have registered for a specific ptype.
+	 * device by reinjecting the frame into bonding slave (orig_dev)
 	 */
 	if (skb->dev->priv_flags & IFF_802_1Q_VLAN &&
 	    vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING &&
@@ -3108,7 +3108,7 @@ static void vlan_on_bond_hook(struct sk_buff *skb)
 
 		if (!skb2)
 			return;
-		skb2->dev = vlan_dev_real_dev(skb->dev);
+		skb2->dev = orig_dev;
 		netif_rx(skb2);
 	}
 }
@@ -3196,13 +3196,12 @@ ncls:
 			pt_prev = NULL;
 		}
 		if (vlan_hwaccel_do_receive(&skb)) {
-			ret = __netif_receive_skb(skb);
-			goto out;
+			goto another_round;
 		} else if (unlikely(!skb))
 			goto out;
 	}
 
-	vlan_on_bond_hook(skb);
+	vlan_on_bond_hook(skb, orig_dev);
 
 	/* deliver only exact match when indicated */
 	null_or_dev = deliver_exact ? skb->dev : NULL;
-- 
1.7.4

