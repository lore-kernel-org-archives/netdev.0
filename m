From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv5 net-next 3/3] sunvnet: generate ICMP PTMUD messages
 for smaller port MTUs
Date: Wed, 17 Sep 2014 19:41:58 -0400
Message-ID: <541A1C46.90201@oracle.com>
References: <5419F3E5.4050708@oracle.com> <20140917224351.GM26828@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48429 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978AbaIQXmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 19:42:04 -0400
In-Reply-To: <20140917224351.GM26828@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/17/2014 06:43 PM, Sowmini Varadhan wrote:
> On (09/17/14 16:49), David L Stevens wrote:
>> +
>> +			rt = ip_route_output_key(dev_net(dev), &fl4);
>> +			if (!IS_ERR(rt)) {
> 
> As I've mentioned before, this layering violation makes me uneasy,
> so its benefits should be evaluated carefully.  You will typically not be
> able to find an rt for packets coming here from any application
> that does not itself use/update the FIB, e.g., uspace based packet-injectors
> (PF_PACKET-based applications, intel dpdk-based uspace stacks etc.)

I think the configurations where it doesn't work are reasonably rare, and
the default on boot is a 1500-byte MTU for everyone and none of these ICMP
errors will be triggered if that is where all hosts on the vswitch leave it.
You don't have to ever mix MTUs. The alternative in all cases where we send
an ICMP error to make it work is to instead silently drop those packets, all
packets of the same size or larger that we get after. It does nothing different
whatsoever for any configuration that works today. It only allows other configurations
to work also.

A pair of Linux LDOMs can get 8X throughput improvement by raising the MTU to 64K, but
many packets will be *silently* dropped if they go to any other destination that does
not support 64K MTU. Those destinations that don't support 64K MTU include any legacy
Linux running the pre-jumbo code and all Solaris hosts, including the current releases.

With the ICMP errors, the new linux code can interoperate properly with all of them, and
do so at much higher throughput (4-8X) with those that can support higher MTUs.

Also, I wouldn't call it a layering violation. icmp_send() is the external API for
triggering ICMP errors, and we are sending them at the point where we know the next-hop MTU.
It is exactly equivalent to an Ethernet device connected to a switch where the switch
sends useful layer-3 packets (like IGMP queries). In this case, that useful layer 3 info
is remote link MTU data; something not available in ordinary Ethernet.

Also, any PF_PACKET or other applications that bypass the routing tables can still (and
should) receive and process PMTUD packets. If you're sending raw Ethernet frames that are
IP, you should. If you mean non-routable protocols, none of those can be delivered over
any link where these ICMP errors would be sent, anyway. If you try to send an 18000-byte
non-IP packet with a 1500-byte MTU, it will be dropped today, and still dropped with this
patchset.

Large broadcast frames (your comment from another mail) will not work, just as they won't
work today. If you need to do that, you should leave the MTU of the sender below the lowest
MTU attached to the same switch, the way you would for any other Ethernet, and they'll be
fragmented and reassembled.

On the other hand, if you want your TCP and UDP traffic over IPv4 and IPv6 to be 4-8 times
faster than it is today without any other change, you can accept the deficiencies in the
otherwise not-allowed configuration and set the device MTU to 64K even when it's mixed with
other devices that can't do it. If all of them support the higher MTU, none of this code
comes into play. If some of them don't, this code allows them to interoperate; without this
code, all those packets are simply silently dropped and your network can only function at
the level of the least capable attached LDOM.

								+-DLS
