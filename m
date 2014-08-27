From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next v4 01/13] net: dsa: reduce number of protocol
 hooks
Date: Wed, 27 Aug 2014 08:25:45 -0700
Message-ID: <53FDF879.1000504@intel.com>
References: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com> <1409028581-17399-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com, jhs@mojatatu.com,
	alexander.duyck@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65403 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934716AbaH0PZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 11:25:47 -0400
In-Reply-To: <1409028581-17399-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2014 09:49 PM, Florian Fainelli wrote:
> DSA is currently registering one packet_type function per EtherType it
> needs to intercept in the receive path of a DSA-enabled Ethernet device.
> Right now we have three of them: trailer, DSA and eDSA, and there might
> be more in the future, this will not scale to the addition of new
> protocols.
> 
> This patch proceeds with adding a new layer of abstraction and two new
> functions:
> 
> dsa_switch_rcv() which will dispatch into the tag-protocol specific
> receive function implemented by net/dsa/tag_*.c
> 
> dsa_slave_xmit() which will dispatch into the tag-protocol specific
> transmit function implemented by net/dsa/tag_*.c
> 
> When we do create the per-port slave network devices, we iterate over
> the switch protocol to assign the DSA-specific receive and transmit
> operations.
> 
> This allows us to greatly simplify the check in eth_type_trans() and
> always override the skb->protocol with ETH_P_DSA for Ethernet switches
> tagged protocol, while also reducing the number repetitive slave
> netdevice_ops assignments.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v4:
> - introduce a level of indirection and dsa_device_ops to limit the
>   number of packet_type functions to just one and do the dispatching
>   in the core dsa code.
> 
> New patch in v3
> 

Just a thought, you might want to consider using a protocol value other
than ETH_P_DSA.  Maybe we should add a new value named ETH_P_XDSA for
this approach since what we are doing is a multiplexed DSA protocol now.

This would allow for much easier back-porting of this if needed and also
prevents us from possibly triggering any issues if there are any
user-space APIs that might be trying to capture packets based on the
protocol value.

Thanks,

Alex
