From: James Yonan <james@openvpn.net>
Subject: Re: GSO/GRO and UDP performance
Date: Fri, 06 Sep 2013 13:26:46 -0600
Message-ID: <522A2C76.10203@openvpn.net>
References: <52270659.1090208@openvpn.net> <1378295631.7360.98.camel@edumazet-glaptop> <52299EDD.1030208@openvpn.net> <1378472829.31445.21.camel@edumazet-glaptop> <522A05E9.3090206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magnetar.openvpn.net ([74.52.27.18]:42129 "EHLO
	magnetar.openvpn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab3IFT04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 15:26:56 -0400
In-Reply-To: <522A05E9.3090206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2013 10:42, Rick Jones wrote:
> On 09/06/2013 06:07 AM, Eric Dumazet wrote:
>> On Fri, 2013-09-06 at 03:22 -0600, James Yonan wrote:
>>
>>> So I think that playing well with GSO/GRO is essential to get speedup in
>>> UDP apps because of this 43x multiplier.
>>>
>>
>> Thats not true. GRO cannot aggregate more than 16+1 packets.

Where does the 16+1 come from?  I'm getting my 43x from the ratio of max 
legal IP packet size (64KB) / internet MTU (1500).  Are you saying that 
GRO cannot aggregate up to 64 KB?

>> I think we cannot aggregate UDP packets, because UDP lacks sequence
>> numbers, so reorders would be a problem.

>> You really need something that is not UDP generic.

Right -- that's why I'm proposing a hook for UDP GSO/GRO providers that 
know about specific app-layer protocols and can provide segmentation and 
aggregation methods for them.  Such a provider would be implemented in a 
kernel module and would know about the specific app-layer protocol, so 
it would be able to losslessly segment and aggregate it (i.e. it could 
use a sequence number from the app-layer protocol).

> It may  not be as sexy, and it cannot get the 43x multiplier (just what
> *is* the service demand change on a netperf TCP_STREAM test these days
> between GSO/GRO on and off anyway?)

That's something I haven't really looked too closely at yet.  With 
MAX_GRO_SKBS set to only 8, how well would this really scale?

> but looking for basic path-length reductions would be goodness.

Path is fairly optimized as-is.

Direction 1: udp_encap_recv -> tunnel decapsulation -> netif_rx

Direction 2: ndo_start_xmit -> tunnel encapsulation -> ip_local_out

I've also looked into getting closer to driver TX by using 
dev_queue_xmit instead of ip_local_out.

Even though this is a virtual driver without interrupts, I'm also 
looking at NAPI as a way of getting packet flows into GRO on the RX side.

Bottom line is that I want to saturate 10 GigE with UDP packets without 
breaking a sweat.  ixgbe or other drivers in that class can handle it if 
the per-packet overhead in the network stack can be reduced enough.

James
