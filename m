From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 21:20:54 -0700
Message-ID: <4DDB3226.8010404@candelatech.com>
References: <4DDAB72B.9050101@gmail.com> <4DDAC26C.2070601@candelatech.com>	<20110523140048.777fb378@nehalam>	<20110523.172047.1438754754048434316.davem@davemloft.net>	<m1y61x2htp.fsf@fess.ebiederm.org> <4DDADE52.8000008@candelatech.com> <m1boyt10n4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, nicolas.2p.debian@gmail.com,
	jpirko@redhat.com, xiaosuo@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, jesse@nicira.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43770 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127Ab1EXEVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 00:21:34 -0400
In-Reply-To: <m1boyt10n4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2011 04:02 PM, Eric W. Biederman wrote:
> Ben Greear<greearb@candelatech.com>  writes:
>
>> On 05/23/2011 03:05 PM, Eric W. Biederman wrote:
>>
>> If REORDER_HDR dissappears entirely, I think you have to default to
>> stripping the header on vlan2000.
>
> Which is what patches that started this thread are doing.
>
>>> With vlan hardware acceleration.  When I tcpdump on eth0 I don't
>>> see the vlan header.  Nor do I see the vlan header when I tcpdump
>>> on vlan2000.
>>
>> I think you should see the header on eth0 regardless of hw acceleration
>> or not.  Users should not have to know if their NIC/driver supports
>> vlan tag stripping in one mode or another.
>
> But is it acceptable to fix this in libpcap?

No, because libpcap is not the only thing that opens packet
sockets.  Our user-space network emulator bridges two ethernet
interfaces using packet-sockets.  We have to have the VLAN header
available to properly bridge a VLAN packet out the other side.
It would be possible to use some aux data, but I think that is
a very nasty hack.

Surely we and libpcap are not the only users...

Also, anything using a packet filter might need the header in place.

>>> 3) What do we do with pf_packet and vlan hardware acceleration when
>>>      dumping not the vlan interface but the interface below the vlan
>>>      interface?
>>>
>>>      Do we provide an option to keep the vlan header?  Should that option
>>>      be on by default?
>>
>> At the least we need to have the header kept when using pf_packet on
>> eth0.
>
> Start with the assumption that vlan hardware acceleration is in place
> and the hardware has stripped the vlan tag and put it in skb->tci.
> Sure there are dumb divers out there that don't do this today but
> either we need to throw out vlan hardware acceleration completely
> or emulate it in software because otherwise the test matrix is just
> too big.

It's a binary case..either tag exists in skb or it doesn't.  It might double
the test cases, but that is still a reasonable number.  We should be able
to write a test app to mostly automate testing for that matter.

I still haven't had time to do detailed testing, but I *believe* that
even smart drivers like e1000e and igb don't strip tags if you do not
have any VLANs created on the NIC.  So, sometimes you get tags on
eth0 even when using fancy NICs.

>
>> I think it's best to have it available on vlan2000, but perhaps have it
>> stripped by default for backwards compatibility.
>
> Anything that deals with raw packets pretty much breaks if you don't
> strip the vlan header from visibility on vlan2000.  Plus you loose
> any advantage there is from vlan hardware acceleration, which is
> available on must modern NICs.  So I don't think we can seriously
> consider having the vlan header for present on the vlan2000 device.

I'm fine with stripping them from the vlan2000 frame, though
hopefully one day we can optimize to only do this if there
are actual consumers of the raw packet in user-space.

> All that is interesting is what to do with eth0, and pf_packet sockets.
> And the only question that seems really interesting there is do we put
> the vlan header back on with libpcap magic or with pf_packet logic.
>
> We have to start with a the assumption that we come in with a pf_packet
> with the vlan tag only in skb->tci.

Then I think we should put it back with pf_packet logic.  Possibly with
a per-socket option to disable this and send it as only aux data if that
is more efficient.

If it turns out the NIC is not stripping VLAN tags for whatever reason,
we might be able to optimize things so that it never does the HW emulation
so that it never has to un-do it later.

If we can agree on the desired behaviour, I'll put some effort into
a test system that can test a 4-port system:

eth0 { loopback cable }  eth1 { pf-socket based software bridge } eth2 { looped-back-cable } eth3

Could iterate through a matrix of vlans in various places and test each time to make sure
eth0 and eth3 receive expected data.  I could split the sender/consumer logic into one process
and the bridge into another so that it could be done on two systems with 2 ports each.

Thanks,
Ben

>
> Eric


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
