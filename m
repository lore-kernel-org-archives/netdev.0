From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 22:00:16 -0700
Message-ID: <4ADE9560.5050500@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com> <4ADE2A24.6080300@gmail.com> <4ADE2C00.8030900@candelatech.com> <4ADE3253.10302@gmail.com> <4ADE44FC.4030406@candelatech.com> <4ADE7A63.4090404@candelatech.com> <4ADE7C0D.5070208@gmail.com> <4ADE873F.3030903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50789 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbZJUFAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 01:00:19 -0400
In-Reply-To: <4ADE873F.3030903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> pktgen should not use "clone XXX" pkts if macvlan is used (or any other driver
> that ultimatly calls dev_queue_xmit() and queue packet), since skb queue anchor
> is shared and would be overwritten.
>   
> After some thoughts, I believe user is in error :)
I tried to explain in my original post:  The problem arises when
when the hard-start-xmit fails with NETDEV_TX_BUSY.  Part of the
hard-start-xmit logic for virtual devices can call dev_queue_xmit, which 
can ultimately
change the queue mapping and yet may still return NETDEV_TX_BUSY.

pktgen would try to resend this skb next loop, and this is where it would
blow up.

I have a patched macvlan logic and a patched dev queue xmit logic that 
allows
me to return NETDEV_TX_BUSY when underlying device fails to transmit.

It may be that my hacked macvlan is the only virtual device that could ever
return NETDEV_TX_BUSY, and if that is the case, I don't think the bug
could ever be hit in official kernel code.  My opinion is that the 
current pktgen code makes
too many assumptions, so unless there is a performance penalty, I still
think it should be cleaned up.  But, I may be too paranoid.
> 1) Only way to use "clone XXXX" pkts is when using real device.
>   
Agreed, and I was not cloning pkts on the mac-vlan interface.
> 2) Also, using macvlan in pktgen is sub-optimal, since you can already put any
> MAC addresses in pktgen pkts, you dont need to go through macvlan layer.
>   
It's sub-optimal for massive pkt pushing, but still useful for sending 
multiple distinct flows
across a single physical wire.
> 3) If ixgbe overwrites skb->queue_mapping to current cpu, you should setup pktgen
>  queue_map_min and queue_map_max to match you cpu number, or use QUEUE_MAP_CPU pktgen flag
> Or else, pktgen wont get  the appropriate txq (and lock) before calling driver start_xmit()
>   
The hard-start-xmit path doesn't call the driver's queue-mapping logic, 
so you
only get that fun when transmitting through mac-vlans (or .1q vlans, 
etc).  There appears to be
no watchdog for virtual devices, and the dev_queue_xmit path updates the 
proper txq, so, as long as you
aren't using that +1 variant of the skb set queue map logic in pktgen, I 
think you will be fine.  The
current code is fine in this manner, but your patch broke it w/out the 
second patch to remove the +1
logic.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


