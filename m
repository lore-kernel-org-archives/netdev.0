From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3.2 085/115] veth: =?UTF-8?B?ZG9u4oCZdCBtb2RpZnkgaXBf?=
 =?UTF-8?B?c3VtbWVkOyBkb2luZyBzbyB0cmVhdHMgcGFja2V0cyB3aXRoIGJhZCBjaGVja3M=?=
 =?UTF-8?B?dW1zIGFzIGdvb2Qu?=
Date: Sat, 30 Apr 2016 14:29:40 -0700
Message-ID: <572523C4.4080307@candelatech.com>
References: <lsq.1461711744.699003961@decadent.org.uk> <5720E1F0.9010203@candelatech.com> <1461780469.5102.0.camel@decadent.org.uk> <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com> <572155F4.10405@candelatech.com> <20160428102953.GA7656@bistromath.localdomain> <1462041181.17662.3.camel@decadent.org.uk> <57250A17.5090804@candelatech.com> <CALx6S36cqecPH+Zd8pGVdFHRi7bmWgAwm2UgFVprt5JOuO47UA@mail.gmail.com> <57251CB3.1040504@candelatech.com> <CAKUBDd-_5RouHduHvjOqgOpyAArEBd80BEy4KBDPLRQoTtWb2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:55775 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbcD3V3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 17:29:44 -0400
In-Reply-To: <CAKUBDd-_5RouHduHvjOqgOpyAArEBd80BEy4KBDPLRQoTtWb2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/30/2016 02:13 PM, Vijay Pandurangan wrote:
> On Sat, Apr 30, 2016 at 4:59 PM, Ben Greear <greearb@candelatech.com> wrote:
>>
>>
>> On 04/30/2016 12:54 PM, Tom Herbert wrote:
>>>
>>> We've put considerable effort into cleaning up the checksum interface
>>> to make it as unambiguous as possible, please be very careful to
>>> follow it. Broken checksum processing is really hard to detect and
>>> debug.
>>>
>>> CHECKSUM_UNNECESSARY means that some number of _specific_ checksums
>>> (indicated by csum_level) have been verified to be correct in a
>>> packet. Blindly promoting CHECKSUM_NONE to CHECKSUM_UNNECESSARY is
>>> never right. If CHECKSUM_UNNECESSARY is set in such a manner but the
>>> checksum it would refer to has not been verified and is incorrect this
>>> is a major bug.
>>
>>
>> Suppose I know that the packet received on a packet-socket has
>> already been verified by a NIC that supports hardware checksumming.
>>
>> Then, I want to transmit it on a veth interface using a second
>> packet socket.  I do not want veth to recalculate the checksum on
>> transmit, nor to validate it on the peer veth on receive, because I do
>> not want to waste the CPU cycles.  I am assuming that my app is not
>> accidentally corrupting frames, so the checksum can never be bad.
>>
>> How should the checksumming be configured for the packets going into
>> the packet-socket from user-space?
>
>
> It seems like that only the receiver should decide whether or not to
> checksum packets on the veth, not the sender.
>
> How about:
>
> We could add a receiving socket option for "don't checksum packets
> received from a veth when the other side has marked them as
> elide-checksum-suggested" (similar to UDP_NOCHECKSUM), and a sending
> socket option for "mark all data sent via this socket to a veth as
> elide-checksum-suggested".
>
> So the process would be:
>
> Writer:
> 1. open read socket
> 2. open write socket, with option elide-checksum-for-veth-suggested
> 3. write data
>
> Reader:
> 1. open read socket with "follow-elide-checksum-suggestions-on-veth"
> 2. read data
>
> The kernel / module would then need to persist the flag on all packets
> that traverse a veth, and drop these data when they leave the veth
> module.

I'm not sure this works completely.  In my app, the packet flow might be:

eth0 <-> raw-socket <-> user-space-bridge <-> raw-socket <-> vethA <-> vethB <-> [kernel router/bridge logic ...] <-> eth1

There may be no sockets on the vethB port.  And reader/writer is not
a good way to look at it since I am implementing a bi-directional bridge in
user-space and each packet-socket is for both rx and tx.

>> Also, I might want to send raw frames that do have
>> broken checksums (lets assume a real NIC, not veth), and I want them
>> to hit the wire with those bad checksums.
>>
>>
>> How do I configure the checksumming in this case?
>
>
> Correct me if I'm wrong but I think this is already possible now. You
> can have packets with incorrect checksum hitting the wire as is. What
> you cannot do is instruct the receiving end to ignore the checksum
> from the sending end when using a physical device (and something I
> think we should mimic on the sending device).

Yes, it does work currently (or, last I checked)...I just want to make sure it keeps working.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
