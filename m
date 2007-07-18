From: Patrick McHardy <kaber@trash.net>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 01:34:08 +0200
Message-ID: <469EA370.8000103@trash.net>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com> <469E9AC8.3090603@trash.net> <469EA0D1.6020406@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50880 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964942AbXGRXeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 19:34:46 -0400
In-Reply-To: <469EA0D1.6020406@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>> Put another way, once you enable VLAN header stripping, you
>> won't see the headers for *any* VLAN, not only for those you're
>> actually running locally. This is also a problem for devices
>> like macvlan, where it would be desirable to make use of
>> hardware VLAN accerlation. I was thinking about storing the
>> information somewhere in the packets meta-data on both RX and
>> TX paths, that would also allow tcpdump to properly display
>> packets.
>>   
> 
> MAC-VLAN could gather this information based on it's parent
> device (ie, if parent-dev has VID 7, then add VID 7 to the meta
> data.  There would be no need for any driver changes I think.


Its actually more a problem on the RX path. VLAN acceleration
works (at least with some drivers) by enabling HW header striping
and using the VLAN ID for an immediate lookup in the VLAN devices
configured on that device. So if the VLAN is not configured on the
real device but something like macvlan, it will get the packet
without a header and without any indication that this was a VLAN
packet. This is also what causes the tcpdump problem.

On the TX path, it could simply use the CB, but this is actually
also wrong (for both macvlan and real devices) since qdiscs have
ownership of the skb in between, and at least netem *does* modify
the CB, breaking VLAN.

> Other than TCP-dump, or some other raw protocol that wants to see
> the VLAN header in user-space, I can't think of what use this would
> be, however.  And, if you just disable VLAN accel in the NIC (see below),
> that would make this mac-vlan hackery not needed at all?


Optimizations for macvlan are not too important, I agree. But for
tcpdump I consider it a bug.

>> I have planned to look into this when I find some time.
>> Your suggestion of disabling VLAN acceleration in promiscous
>> mode sounds like a reasonable solution until then ..
>>   
> 
> I think a better method would be to allow disabling VLAN HW accel for a
> NIC with
> ethtool.  Then, the packets will be received by the software stack with
> the vlan
> header intact.  Something sniffing on the physical dev will
> automatically get the
> VLAN header.


That would also be fine. But considering that the TX path is
problematic too, a clean solution for all of this would be
to store the VLAN id in the skb. And we do have some holes
to plug currently :)

