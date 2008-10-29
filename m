From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: linux bridge and MTU
Date: Thu, 30 Oct 2008 00:10:55 +0300
Message-ID: <4908D15F.8080508@msgid.tls.msk.ru>
References: <49086423.9050104@msgid.tls.msk.ru>	<20081029082610.307520cd@extreme>	<4908C83C.8040907@msgid.tls.msk.ru> <20081029134447.34c218c5@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.33.150]:21113 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754073AbYJ2VK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 17:10:59 -0400
In-Reply-To: <20081029134447.34c218c5@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 29 Oct 2008 23:31:56 +0300
> Michael Tokarev <mjt@tls.msk.ru> wrote:
[]
>> Ok, let's see how it works in case of one of the "external" hosts,
>> connected to larger-MTU interface, sends a large packet to another
>> host connected to the same bridge but on smaller-mtu port
>> (hosts B and C in the above example):
>>
>>    B <=== MTU=3000 ===> A (bridge) <=== MTU=1500 ====> C
>>
>> B sends a large packet to C.  According to the MTU of its
>> local network segment, it sends out a 3000-byte packet.
>> And immediately receives an ICMP from A telling "fragmentation
>> needed".  So it corrects the MTU and goes on with smaller packets.
> 
> A never sees IP. It just drops packet.

No.  A sees the IP just fine.  In all cases, as far as the
receiving packet is smaller than the MTU of the *interface*
it is being received from.  Not the bridge, but the interface
"connected to" the bridge.  And here was my main point being --
why A can receive large packets just fine, but can't SEND them
back (as you figured, I understand the underlying mechanic, and
see where it all comes from, but it still looks pretty...
strange, unnatural).

>> When B sends out a packet destined to A, or even to another
>> host connected to the same bridge and also with larger MTU,
>> the packet goes just fine.

^^^^^^
here

[]
>>> You might be able to do something with netfilter.
>> The whole thing has nothing to do with netfilter.  If I didn't
>> misunderstand what you meant.
> 
> The reason I mentioned netfilter is it that it provides a way to
> load special rules on a per interface/per-direction basis to alter
> behaviour. It is the tool to put non-standard behaviour in.
> One could argue that firewalling is really just one case of non-standard
> behaviour.

That'd work if bridge *interface* allowed to set MTU
manually.  I'd set the bridge MTU to the max, and used
netfilter (or even routing rules, since each routing
entry includes mtu value) to lower the MTU where appropriate.
But bridge does not allow to alter the MTU at all.

For the record: This all started when I saw how inefficient
the network is between a virtual guest system and the host,
running kvm and hw virtualization and all the optimizations
I were able to find.  I noticed the default MTU value,
and thought that increasing it seems like a good idea,
should help increasing performance due to less context
switches and the like.  After some tweaks on kvm/virtio/net
side (there was no mtu handler for virtio_net devices),
I was able to increase the MTU value, and the thing just...
flied, with performance increasing almost linearly when
increasing the MTU.  But it does not quite "want" to
work one step further.  I know there are work-arounds
for that, by using separate networks for host<=>guest
and guest<=>the_rest_of_the_world, but that seems
over-complicated.

Thanks!

/mjt
