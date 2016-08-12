From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for gre tunneled skbs
Date: Fri, 12 Aug 2016 13:11:50 +0200
Message-ID: <dfa12e1b-54dc-4e20-8819-cb2400a693d1@stressinduktion.org>
References: <1470726261-16371-1-git-send-email-wenxu@ucloud.cn>
 <20160810.173511.968926810628735179.davem@davemloft.net>
 <20160811224132.7a17f0c3@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: wenxu@ucloud.cn, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	wenx05124561@163.com
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35629 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751356AbcHLLLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 07:11:54 -0400
In-Reply-To: <20160811224132.7a17f0c3@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.08.2016 21:41, Shmulik Ladkani wrote:
> On Wed, 10 Aug 2016 17:35:11 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
>>> commit b8247f095edd ("net: ip_finish_output_gso: If skb_gso_network_seglen
>>> exceeds MTU, allow segmentation for local udp tunneled skbs")
>>>
>>> Given:
>>>      - tap0 and ovs-gre
>>>      - ovs-gre stacked on eth0, eth0 having the small mtu
>>>
>>> After encapsulation these skbs have skb_gso_network_seglen that exceed
>>> eth0's ip_skb_dst_mtu. So the finnal each segment would be larger than
>>> eth0 mtu. These packets maybe dropped.
>>>
>>> It has the same problem if tap0 bridge with ipgre or gretap device. So
>>> the IPSKB_FRAG_SEGS flags should also be set in gre tunneled skbs.
>>>
>>> Signed-off-by: wenxu <wenxu@ucloud.cn>  
>>
>> I am rather certain that this test is intentionally restricted to
>> UDP tunnel endpoints, because GRE and other tunnel types are PMTU safe.
>>
>> Hannes and Shmulik?
> 
> It was restricted to UDP tun encaps per Hannes' suggestion, in order to
> scope the change, as Hannes hinted gre and ipip are pmtu-safe, see [1].
> 
> Glancing at ip_tunnel_xmit() --> tnl_update_pmtu(), they do seem to
> handle PMTU, but - if I understand correctly - only in the !skb_is_gso
> case.
> (since 68c3316311 "v4 GRE: Add TCP segmentation offload for GRE")
> 
> This is probably due the same hidden assumption that 'gso_size' will be
> suitable for the egress mtu even after encapsulation, which does not
> hold true in some usecases as described in [2].
> 
> Therefore it might be that b8247f095edd needs to be augmented for
> non-udp tunnels as well.
> 
> Hannes?

I really would not like to see this expanded to gre and other protocols.
All switches drop packets where the packets are exceeding the MTU,
bridges and also openvswitch should behave the same.

Unfortunately we already had this loophole in the kernel that vxlan udp
output path could fragment the packet again, even in case of switches.
But this stopped working for GSO packets, which violates another rule in
the kernel, GSO should always be transparent and user space should never
have to care if a packet is GSO or not.

Because we couldn't a) roll back the change that we fragment packets in
UDP output paths and b) should not violate GSO transparency rule, I
strongly believed it would be better too only change the kernel in a way
that it transparently works with GSO, too. If we argue that a VTEP is
its own UDP endpoint which is set up after the bridge, I still can sleep
well. :)

My understanding was that GRE failed consistently, GSO as well as
non-GSO packets are dropped, which would be the correct behavior for me.
I don't want to change this. A good argument against this would be if we
violate the GSO transparency rule again. But when I looked into the code
I couldn't see that.

Bye,
Hannes
