From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast messages
Date: Wed, 15 Apr 2009 17:06:47 -0400
Message-ID: <49E64C67.90201@hp.com>
References: <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141447310.30596@qirst.com> <20090414204445.GB17196@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141740280.3973@qirst.com> <20090415110714.GA21448@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904150841550.10217@qirst.com> <20090415142208.GB21448@hmsreliant.think-freely.org> <49E5F1FF.1000801@hp.com> <20090415155702.GC21448@hmsreliant.think-freely.org> <49E6063B.3040107@hp.com> <20090415163812.GD21448@hmsreliant.think-freely.org> <49E6172D.8080201@hp.com> <alpine.DEB.1.10.0904151516380.18317@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:35490 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbZDOVGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 17:06:50 -0400
In-Reply-To: <alpine.DEB.1.10.0904151516380.18317@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> On Wed, 15 Apr 2009, Vlad Yasevich wrote:
> 
>> Looking at BSD, which was the root of the original brokeness, they have it fixed.
>> The code will skip sockets that are not members of a particular group.  So, we
>> are trying really hard to stay bug-for-bug compatible with old implementations.
> 
> Ahh interesting. David: Could you say something on this?

Just digging around some more, it appears that OpenSolaris also filters out
non-joined groups at the socket:

http://src.opensolaris.org/source/xref/onnv/onnv-gate/usr/src/uts/common/inet/ip/ip_multi.c#ilg_lookup_ill_withsrc

In that code, connp is essentially a socket and ilg is the membership list.
That function function called from conn_wantpacket(), which is in turn called
for every socket that matches the packet.

> 
>> What's worse is that if you have a socket that doesn't care about any mulicast
>> destinations (never did an ADD_MEMBERSHIP), it will still get multicast traffic if
>> it bound to that port.
>>
>> We need to take into account the socket's multicast group list.
> 
> Right. The fix is pretty simple too since the infrastructure has been
> there since the IGMPv3 updates.
> 

Right. since IGMPv3 introduced the concept of filtering.  It even states this
in RFC 3376:

     Filtering of packets based upon a socket's multicast reception
     state is a new feature of this service interface.  The previous
     service interface [RFC1112] described no filtering based upon
     multicast join state; rather, a join on a socket simply caused the
     host to join a group on the given interface, and packets destined
     for that group could be delivered to all sockets whether they had
     joined or not.


-vlad
