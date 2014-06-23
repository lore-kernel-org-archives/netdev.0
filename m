From: Wilson Kok <wkok@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next] bridge: Add bridge port learn filter and
 priority
Date: Mon, 23 Jun 2014 16:03:56 -0700
Message-ID: <53A8B25C.3010407@cumulusnetworks.com>
References: <1403075767-31908-1-git-send-email-roopa@cumulusnetworks.com>	<20140618133405.515b3741@nehalam.linuxnetplumber.net>	<53A896A0.2030509@cumulusnetworks.com> <20140623141915.3310c3b8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	netdev@vger.kernel.org, scotte@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, shm@cumulusnetworks.com,
	nolan@cumulusnetworks.com, sfeldma@cumulusnetworks.com,
	jhs@mojatatu.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:55529 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaFWXEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 19:04:01 -0400
In-Reply-To: <20140623141915.3310c3b8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending the original message (in quotes) without HTML as the full 
message did not appear on the mailing list.  Please find response at the 
end of the email.

"This is not a loop situation.  The topology we're referring to is a 
multi-chassis LAG topology (a widely supported feature by networking 
vendors, e.g. Arista's MLAG and Cisco's VPC), where some hosts are 
dual-homed on a pair of switches, and some hosts are single-homed on one 
of the two switches, and there is a inter-chassis link between the 
switches.  A dual-homed host can and will source packets from either or 
both its uplinks with the same source MAC address. The packets may be 
locally forwarded on the first hop switch, and they may also cross the 
inter-chassis link from one switch to the other switch, e.g. in a 
multicast or flood situation or just unicast to a single-homed host 
connected to the other switch.  As such, the host's source MAC can be 
learned on the inter-chassis link or the host link, and can move between 
the two.  A dual-homed host may receive packets from either or both it's 
uplinks, and in some cases it may receive duplicate copies of the same 
packet.

There are three issues regarding data packet forwarding in such topology 
that need to be addressed:
   1. reduce the usage of the inter-chassis link to reduce the 
possibility of congestion and need of over-provisioning
   2. reduce the possibility of a dual-homed host receiving duplicate 
copies of the same packet
   3. prevent out of order delivery of packets to a dual-homed host when 
there are multiple paths to reach it

The proposed patch addresses #1, as soon as a dual-homed host MAC 
address is learned on a host link, the local path becomes and remains 
the preferred path to the host for unicast packets.  It also addresses 
#3, as it prevents packets destined to the dual-homed host from flipping 
between the local path and the inter-chassis path following the MAC 
address move.

To address #2 and also to reduce flooding, a simple filtering logic 
(will be submitting in a later patch) can be used such that packets 
crossing the inter-chassis link do not get forwarded to dual-homed 
hosts, the assumption being that the packet should have already been 
forwarded on the originating switch to the same host. With this 
filtering in place, the proposed patch becomes necessary to ensure that 
packets to a dual-homed host be forwarded locally on the originating 
switch and not cross the inter-chassis link, or else they will get 
dropped."


On 6/23/14, 2:19 PM, Stephen Hemminger wrote:
> On Mon, 23 Jun 2014 14:05:36 -0700
> Wilson Kok <wkok@cumulusnetworks.com> wrote:
>
>> On 6/18/14, 1:34 PM, Stephen Hemminger wrote:
>>> On Wed, 18 Jun 2014 00:16:07 -0700
>>> roopa@cumulusnetworks.com wrote:
>>>
>>>> One such topology is when there are multiple paths to a dual-homed host.
>>> That is called a loop.
>>> Loops are not allowed on bridge networks.
>>> Sorry, this is just the kind of things spanning tree and TRILL were supposed
>>> to address. Solving in local bridge is not a good idea.
>>
>> This is not a loop situation.  The topology we're referring to is a
>> multi-chassis LAG topology (a widely supported feature by networking
>> vendors, e.g. Arista's MLAG and Cisco's VPC), where some hosts are
>> dual-homed on a pair of switches, and some hosts are single-homed on one
>> of the two switches, and there is a inter-chassis link between the
>> switches.  A dual-homed host can and will source packets from either or
>> both its uplinks with the same source MAC address. The packets may be
>> locally forwarded on the first hop switch, and they may also cross the
>> inter-chassis link from one switch to the other switch, e.g. in a
>> multicast or flood situation or just unicast to a single-homed host
>> connected to the other switch.  As such, the host's source MAC can be
>> learned on the inter-chassis link or the host link, and can move between
>> the two.  A dual-homed host may receive packets from either or both it's
>> uplinks, and in some cases it may receive duplicate copies of the same
>> packet.
>>
>
> Isn't this bridging over a bond (or team) interface.
> The point is this really shouldn't be part of bridge code.
>

Yes, this is bridging over a host bond interface that terminates on two 
different switches.  Normal bridging and MAC learning operations over 
such a bond interface will give rise to the three issues listed above, 
hence the need for a solution such as the proposed additional logic in 
MAC learning in the bridge code.  I guess I'm not clear about your 
concern and wondering if you have an alternative suggestion in mind.

Thanks,
Wilson.
