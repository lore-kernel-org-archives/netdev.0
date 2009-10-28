From: Mark Huth <mhuth@mvista.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Wed, 28 Oct 2009 09:55:09 -0700
Message-ID: <4AE8776D.4020609@mvista.com>
References: <1256683583.3153.389.camel@linux-1lbu> <4AE780CB.8070401@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Chen <schen@mvista.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu47.mvista.com ([206.112.117.47]:51630 "HELO
	gateway-1237.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1752724AbZJ1RTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 13:19:52 -0400
In-Reply-To: <4AE780CB.8070401@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> Steve Chen wrote:
>> Multicast packet reassembly can fail
>>
>> When multicast connections with multiple fragments are received by the 
>> same
>> node from more than one Ethernet ports, race condition between fragments
>> from each Ethernet port can cause fragment reassembly to fail leading to
>> packet drop.  This is because packets from each Ethernet port appears 
>> identical
>> to the the code that reassembles the Ethernet packet.
>>
>> The solution is evaluate the Ethernet interface number in addition to 
>> all other
>> parameters so that every packet can be uniquely identified.  The existing
>> iif field in struct ipq is now used to generate the hash key, and iif 
>> is also
>> used for comparison in case of hash collision.
>>
>> Please note that q->saddr ^ (q->iif << 5) is now being passed into
>> ipqhashfn to generate the hash key.  This is borrowed from the routing
>> code.
>>
>> Signed-off-by: Steve Chen <schen@mvista.com>
>> Signed-off-by: Mark Huth <mhuth@mvista.com>
> 
> It has been hours since my last good Emily Litella moment so I'll ask - 
> isn't the combination of source and dest addr, protocol, IP ID and 
> fragment offset supposed to take care of this?  How does the ingress 
> interface have anything to do with it?
> 
> rick jones
The problem we've seen arises only when there are multiple interfaces 
each receiving the same multicast packets.  In that case there are 
multiple packets with the same key.  Steve was able to track down a 
packet loss due to re-assembly failure under certain arrival order 
conditions.

The proposed fix eliminated the packet loss in this case.  There might 
be a different problem in the re-assembly code that we have masked by 
separating the packets into streams from each interface.  Now that you 
mention it, the re-assembly code should be robust in the face of some 
duplicated and mis-ordered packets.  We can look more closely at that code.

Mark Huth

