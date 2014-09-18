From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv6 net-next 1/3] sunvnet: upgrade to VIO protocol version
 1.6
Date: Thu, 18 Sep 2014 09:03:52 -0400
Message-ID: <541AD838.50700@oracle.com>
References: <541A2316.5010603@oracle.com> <2AB76E42-C12D-47C5-8476-0D0C611691A5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33521 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752969AbaIRND6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 09:03:58 -0400
In-Reply-To: <2AB76E42-C12D-47C5-8476-0D0C611691A5@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/18/2014 12:09 AM, Raghuram Kothakota wrote:

>> @@ -1048,8 +1116,8 @@ static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
>> 	void *dring;
>>
>> 	for (i = 0; i < VNET_TX_RING_SIZE; i++) {
>> -		void *buf = kzalloc(ETH_FRAME_LEN + 8, GFP_KERNEL);
>> -		int map_len = (ETH_FRAME_LEN + 7) & ~7;
>> +		void *buf = kzalloc(VNET_MAXPACKET + 8, GFP_KERNEL);
> 
> 
> This patch doesn't change the VNET_MAXPACKET to 64k, but the patch 2/3 changes
> it to 64k+. Allocating buffers of size VNET_MAXPACKET always can consume too much
> memory for every port/LDC, that would be more than 32MB.  You may want to allocate
> buffers based on the mtu that is negotiated, so that this memory used only when
> such large packets are accepted by the peer.

I originally had code to dynamically allocate them after the MTU negotiation, but
that opens up a can of worms regarding stopping and freeing an active ring. I don't
believe the shutdown code addresses this adequately, either, and I think this is
worth addressing, but separately.

I convinced myself to do it this way because:
a) memory is cheap
b) I think most people will want to use large MTUs for performance; enough so
	that perhaps the bring-up MTU should be 64K too
c) future (actually current) TSO/GSO work will want large buffers even if the MTU
	is not changed

So, if this is actually too much memory, I was more inclined to reduce the ring
size rather than either add complicating code to handle active-ring reallocation
that would typically be run once per boot, or another alternative of adding
module parameters to specify the buffer size TSO/GSO will need 64K to perform
well, regardless of the device MTU.

							+-DLS
