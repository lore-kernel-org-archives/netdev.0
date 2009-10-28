From: Steve Chen <schen@mvista.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Wed, 28 Oct 2009 12:50:03 -0500
Message-ID: <1256752203.3153.461.camel@linux-1lbu>
References: <1256683583.3153.389.camel@linux-1lbu> <4AE780CB.8070401@hp.com>
	 <4AE8776D.4020609@mvista.com>  <4AE87D03.4020708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:53480 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1755275AbZJ1RmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 13:42:15 -0400
In-Reply-To: <4AE87D03.4020708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-28 at 10:18 -0700, Rick Jones wrote:
> >> It has been hours since my last good Emily Litella moment so I'll ask 
> >> - isn't the combination of source and dest addr, protocol, IP ID and 
> >> fragment offset supposed to take care of this?  How does the ingress 
> >> interface have anything to do with it?
> >>
> >> rick jones
> > 
> > The problem we've seen arises only when there are multiple interfaces 
> > each receiving the same multicast packets.  In that case there are 
> > multiple packets with the same key.  Steve was able to track down a 
> > packet loss due to re-assembly failure under certain arrival order 
> > conditions.
> > 
> > The proposed fix eliminated the packet loss in this case.  There might 
> > be a different problem in the re-assembly code that we have masked by 
> > separating the packets into streams from each interface.  Now that you 
> > mention it, the re-assembly code should be robust in the face of some 
> > duplicated and mis-ordered packets.  We can look more closely at that code.
> 
> If I understand correctly, the idea here is to say that when multiple interfaces 
> receive fragments of copies of the same  IP datagram that both copies will 
> "survive" and flow up the stack?
> 
> I'm basing that on your description, and an email from Steve that reads:
> 
> > Actually, the patch tries to prevent packet drop for this exact
> > scenario.  Please consider the following scenarios
> > 1.  Packet comes in the fragment reassemble code in the following order
> > (eth0 frag1), (eth0 frag2), (eth1 frag1), (eth1 frag2)
> > Packet from both interfaces get reassembled and gets further processed.
> > 
> > 2. Packet can some times arrive in (perhaps other orders as well)
> > (eth0 frag1), (eth1 frag1), (eth0 frag2), (eth1 frag2)
> > Without this patch, eth0 frag 1/2 are overwritten by eth1 frag1/2, and
> > packet from eth1 is dropped in the routing code.
> 
> Doesn't that rather fly in the face of the weak-end-system model followed by Linux?
> 
> I can see where scenario one leads to two IP datagrams making it up the stack, 
> but I would have thought that was simply an "accident" of the situation that 
> cannot reasonably be prevented, not justification to cause scenario two to send 
> two datagrams up the stack.

For scenario 2, the routing code drops the 2nd packet.  As a result, no
packet make it to the application.  If someone is willing to suggest an
alternative, I can certainly rework the patch and retest.

Regards,

Steve

