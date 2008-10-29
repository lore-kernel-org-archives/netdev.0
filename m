From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: linux bridge and MTU
Date: Wed, 29 Oct 2008 23:31:56 +0300
Message-ID: <4908C83C.8040907@msgid.tls.msk.ru>
References: <49086423.9050104@msgid.tls.msk.ru> <20081029082610.307520cd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.33.150]:22959 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753609AbYJ2Ub7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 16:31:59 -0400
In-Reply-To: <20081029082610.307520cd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 29 Oct 2008 16:24:51 +0300
> Michael Tokarev <mjt@tls.msk.ru> wrote:
> 
>> There's an interesting interaction between different
>> MTU (max transmission unit) values on interfaces
>> which are bridged together.  I'm trying to understand
>> how it works.
[exchanging larger packets between different interfaces
  on the same bridge]

> The bridge is a pure level 2 switch. It tries to conform to the 802.1d standard
> and therefore is agnostic of higher level protocols. To quote spec

Yes it is.  But in linux, bridge is not just that, it's ALSO
a (virtual) network interface, with its own IP address(es),
netmask(s) and so on.  *And* with the MTU value.
> 
> ---------------------
> 
> 6.3.8 Maximum Service Data Unit Size
> The Maximum Service Data Unit Size that can be supported by an IEEE 802 LAN varies with the MAC
> method and its associated parameters (speed, electrical characteristics, etc.). It may be constrained by the
> owner of the LAN. The Maximum Service Data Unit Size supported by a Bridge between two LANs is the
> smaller of that supported by the LANs. No attempt is made by a Bridge to relay a frame to a LAN that does
> not support the size of Service Data Unit conveyed by that frame.

Yes that's what I observed, -- the MTU of the bridge *interface*
is set to the minimum MTU of all interfaces "connected to" this
bridge.  That part works as expected.

However, my question was somewhat different.  The host "external"
to a bridge is able to send larger packets (provided it's individual
interface has sufficient MTU). But the host that provides home for
that bridge can not, and can't even reply to larger packets.  Or,
rather, it does not TRYING to do so, so to say, knowing in advance
that the MTU is smaller than that.

What I'd expect from the bridge code is something like: to set
MTU of the bridge device to the LARGEST mtu of all the interfaces,
but tell the networking stack to fragment packet ONLY when such
packet will go to the smaller-MTU interface.  Since bridge in
linux is NOT a pure level2 thing, it is much more smarter than
that, and at least knows about MTU and routing.

Ok, let's see how it works in case of one of the "external" hosts,
connected to larger-MTU interface, sends a large packet to another
host connected to the same bridge but on smaller-mtu port
(hosts B and C in the above example):

   B <=== MTU=3000 ===> A (bridge) <=== MTU=1500 ====> C

B sends a large packet to C.  According to the MTU of its
local network segment, it sends out a 3000-byte packet.
And immediately receives an ICMP from A telling "fragmentation
needed".  So it corrects the MTU and goes on with smaller packets.

When B sends out a packet destined to A, or even to another
host connected to the same bridge and also with larger MTU,
the packet goes just fine.

I.e., 2 hosts on a "larger-MTU-part" of the bridge can send
and receive larger packets.  This is true ONLY when the
sending side is NOT the host running the bridge.  When
the sending host is A, it can't send larger packets.  Which
is somewhat strange, as it knows, unlike all the others,
the whole thing, and has much more chances to "work right".

> You might be able to do something with netfilter.

The whole thing has nothing to do with netfilter.  If I didn't
misunderstand what you meant.

Thanks!

/mjt
