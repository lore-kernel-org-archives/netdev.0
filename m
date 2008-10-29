From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: linux bridge and MTU
Date: Wed, 29 Oct 2008 08:26:10 -0700
Message-ID: <20081029082610.307520cd@extreme>
References: <49086423.9050104@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41613 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102AbYJ2P0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 11:26:48 -0400
In-Reply-To: <49086423.9050104@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Oct 2008 16:24:51 +0300
Michael Tokarev <mjt@tls.msk.ru> wrote:

> There's an interesting interaction between different
> MTU (max transmission unit) values on interfaces
> which are bridged together.  I'm trying to understand
> how it works.
> 
> Suppose there are 2 interfaces in the bridge, one is
> with standard 1500 mtu and another is, say 3500.
> 
> As far as I can see, bridge interface sets its mtu to
> be the smallest of all the components.  Which seems
> to be the right ting to do.
> 
> But now the question is - is it possible to communicate
> over the interface with larger MTU using full frames?
> 
> For example, here are a tcpdump from a single ping-pong
> "pair" between host "B" which is connected to a larger-MTU
> interface, and host "A" which is with the bridge described
> above, using 3000-byte packets:
> 
> IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1), length 3028) B > A ICMP echo request, id 35331, seq 2, length 3008
> 
> IP (tos 0x0, ttl 64, id 39747, offset 0, flags [+], proto ICMP (1), length 1500) B > A: ICMP echo reply, id 35331, seq 2, length 1480
> IP (tos 0x0, ttl 64, id 39747, offset 1480, flags [+], proto ICMP (1), length 1500) B > A: icmp
> IP (tos 0x0, ttl 64, id 39747, offset 2960, flags [none], proto ICMP (1), length 68) B > A: icmp
> 
> So, the reply comes in 3 packets according to 1500 MTU of
> the bridge interface.
> 
> When forwarding from B to some host C connected to the other
> interface with standard 1500 mtu, host A correctly sends
> "fragmentation required" ICMP back, so that part works.
> Also, host A obviously is able to receive larger frames.
> But it can't SEND larger frames, even if the underlying
> interface has proper MTU settings?
> 
> Is there a way to achieve this?
> 

The bridge is a pure level 2 switch. It tries to conform to the 802.1d standard
and therefore is agnostic of higher level protocols. To quote spec

---------------------

6.3.8 Maximum Service Data Unit Size
The Maximum Service Data Unit Size that can be supported by an IEEE 802 LAN varies with the MAC
method and its associated parameters (speed, electrical characteristics, etc.). It may be constrained by the
owner of the LAN. The Maximum Service Data Unit Size supported by a Bridge between two LANs is the
smaller of that supported by the LANs. No attempt is made by a Bridge to relay a frame to a LAN that does
not support the size of Service Data Unit conveyed by that frame.

---------------------
You might be able to do something with netfilter.
