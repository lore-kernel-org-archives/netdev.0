From: wenxu <wenxu@ucloud.cn>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for gre tunneled skbs
Date: Fri, 12 Aug 2016 12:29:36 +0800
Message-ID: <ffd3ada7-1a3f-0bfc-8e4f-10904321fcae@ucloud.cn>
References: <1470726261-16371-1-git-send-email-wenxu@ucloud.cn>
 <20160810.173511.968926810628735179.davem@davemloft.net>
 <20160811224132.7a17f0c3@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: wenx05124561@163.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m97131.qiye.163.com ([220.181.97.131]:28648 "EHLO
	m97131.qiye.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbcHLEgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 00:36:04 -0400
In-Reply-To: <20160811224132.7a17f0c3@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
>> I am rather certain that this test is intentionally restricted to
>> UDP tunnel endpoints, because GRE and other tunnel types are PMTU safe.
>>
>> Hannes and Shmulik?
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
>
> [1] http://www.spinics.net/lists/netdev/msg386447.html
> [2] http://www.spinics.net/lists/netdev/msg385776.html
I think non-udp tunnels should also be set
And in b8247f095edd, condition skb_iif also should be removed
given:
ovs-internal-port bridge with ovs-gre

There is the same problem that packets from local.
