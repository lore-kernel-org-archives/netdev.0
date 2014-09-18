From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv6 net-next 1/3] sunvnet: upgrade to VIO protocol version
 1.6
Date: Thu, 18 Sep 2014 15:58:21 -0400
Message-ID: <541B395D.1000809@oracle.com>
References: <541A2316.5010603@oracle.com> <2AB76E42-C12D-47C5-8476-0D0C611691A5@oracle.com> <541AD838.50700@oracle.com> <9BA1705F-0C89-471A-9872-688A3FA3165C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48271 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756218AbaIRT60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 15:58:26 -0400
In-Reply-To: <9BA1705F-0C89-471A-9872-688A3FA3165C@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/18/2014 02:49 PM, Raghuram Kothakota wrote:

> 
> I am probably not as knowledgeable of sunvnet as you may be, but I would assume
> the code is capable of handling the a vport removal and should have sufficient method
> cleanup as well. 

There is nothing in the code that I saw that checks if pending descriptors are marked as
VIO_DESC_DONE before freeing the buffer space when the device is shutdown. From that, I
assume a shutdown during active transmits could result in a fault or the remote looking
at garbage. Adding a wait for that condition could be "forever" if the remote disappears
while processing receives, so it'd need a timeout, too, and it all needs to switch gracefully
to the new buffer set.

I didn't want to put MTU changes in the list of things to trigger that, as I believe they
also would, nor to complicate the MTU-relevant pieces I have with something that I think
ultimately should use fewer, larger buffers.

> In the virtualization world, we want resources to be efficiently used and memory is
> still very important resource. My concern is mostly because this memory usage of
> 32+MB is on a per LDC basis. LDoms today supports a max of 128 domains, but
> from my experience seen actual deployments of the order of 50 domains. This is
> going up as the platforms getting more and more powerful.  If there are really
> that many peers,  then the amount of memory consumed by one vnet instance
> is 50 * 32+MB = 1.6GB+.  It's fine if this memory is really used, but it seems like this
> will be useful only when the peer is another linux guest with this version of vnet and
> also the MTU is configured to use 64K.  The memory is being wasted for all other
> peers that either don't support 64K MTU or not configured to use it and also 
> the switch port as obviously it doesn't support 64K MTU today.

Since the current code allows only 1500-byte MTUs, this patch set is useful for any
value larger than that-- on Solaris, up to 16000, and on Linux, as high as 64K.
I think dynamic buffer allocation should not be tied to these other items, but it
should be done. This isn't the end of sunvnet development, but the beginning. However,
if 64K is too large, what value is not? Any number we pick is arbitrary and with large
numbers of LDOMs may be "too many." Of course, the smaller it is, the smaller the
benefit, too.

I would prefer to reduce VNET_MAXPACKET to some lower value, or make it a module
parameter, than to link this patchset to dynamic allocation of buffers. But the
16000 value Solaris supports would correspond to ~400MB in your example above --
still a large number for a single virtual interface.

>> b) I think most people will want to use large MTUs for performance; enough so
>> 	that perhaps the bring-up MTU should be 64K too
> 
> 
> From my experience in SPARC world, most customers pushed us back for any
> proposal to use Jumbo Frames. The customers who configured Jumbo frames,
> mostly used 9K for performance of NFS etc.

Customers have never been able to use jumbo frames on Linux LDOMs before, and I
expect an 8X improvement in throughput might affect their judgement on it. Moreso,
if those large buffers and throughput improvements can be done with GSO/TSO by
default with no MTU adjustments on the devices.

> When we implemented TSO support, we evaluated the cost of the buffers vs
> performance. We were able to limit TSO support to 8K(actually bit less) and still
> achieve high performance, for example we are able to drive line rate on a 10G
> and guest-to-guest of the order of 45+Gbps. So, my suggestion would be to
> increase the parallelism of the code more than depending on large MTU.

That's nice for Solaris. I see:

dlsl1 880 # ip link set mtu 8192 dev eth1
dlsl1 881 # netperf -H 10.0.0.2
TCP STREAM TEST to 10.0.0.2 : interval
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    3176.10
dlsl1 882 # ip link set mtu 65535 dev eth1
dlsl1 883 # netperf -H 10.0.0.2
TCP STREAM TEST to 10.0.0.2 : interval
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.00    7651.42

So, on Linux, throughput is more than doubled by supporting all the way to
64K-- something I expect to translate to TSO as well. Beyond that, it ought
to be whatever the admin wants-- not some arbitrary limit set in advance.
Since it is a virtual device, there is no physical constraint, as in Ethernet
signaling, to force it to 1500, or 9K. The only limit ought to be the IPv4
max packet size of 64K IP data + framing (and arguably not even that, if it's
using primarily or exclusively IPv6).

						+-DLS
