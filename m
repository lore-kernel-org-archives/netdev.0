From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Fw: Intermittent SCTP multihoming breakage
Date: Wed, 10 Jan 2007 15:49:21 -0500
Message-ID: <45A55151.2060401@hp.com>
References: <20070103154634.b40d9cde.akpm@osdl.org> <1167872389.8646.25.camel@w-sridhar2.beaverton.ibm.com> <Pine.CYG.4.58.0701040913300.3128@shill1-mobl.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:57273 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965092AbXAJVDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 16:03:33 -0500
To: Steve Hill <steve.hill@dialogic.com>
In-Reply-To: <Pine.CYG.4.58.0701040913300.3128@shill1-mobl.eicon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Hill wrote:
> On Wed, 3 Jan 2007, Sridhar Samudrala wrote:
> 
> Sorry for the delay in replying.
> 
>> No. lksctp-developers mailing list is still the best place for SCTP related
>> discussions. You can subscribe and look in the archives at
>>   http://lists.sourceforge.net/lists/listinfo/lksctp-developers
> 
> Hmm, I had a look there and it seemed reasonably inactive and overrun by
> spam.. (And I've been unable to subscribe).
> 
>> How are the 2 machines connected? Are they connected directly or
>> via a router?
> 
> They are currently connected together directly through crossover cables.
> 
>> Do you see both the addresses when you do cat /proc/net/sctp/assocs
>> after the association is established on both the peers?
> 
> Yes, the contents of /proc/net/sctp/assocs looks correct.
> 
>> How are you dropping traffic? You could try simulating failover by
>> bringing down the interface or physically removing the link.
> 
> I have been using iptables to drop SCTP packets on both the INPUT and
> OUTPUT chains.  However, I get the same results if I just unplug the
> network cable (using iptables is easier for my testing since I don't have
> to crawl around behind the test systems :)
> 
>>> 1. Sometimes, just after failing over to the second path I see an ABORT.
>> This seems to indicate that somehow the app has terminated.
> 
> The abort _appears_ to be caused by a retransmit timer expiring, causing
> the SCTP stack to tear down the association.  However, I haven't done much
> investigation of this problem yet - I've been focussing on the second
> problem since it seems to happen more frequently.
> 
>>> 2. More frequently, the association stays up indefinately, with heartbeat
>>> requests and acks on the second path, but no data chunks are sent even
>>> though the transmit queue on the transmitting end appears to be full and
>>> the socket is blocking writes.
>> This is strange. Can you collect tcpdump traces on sender and receiver when
>> this happens?
> 
> I've taken dumps of the data on the wire for both paths:
>   http://www.nexusuk.org/~steve/sctp/path1.pcap
>   http://www.nexusuk.org/~steve/sctp/path2.pcap

Taking a look at these it does appear to complete stall...  There are some
rather interesting retransmission that don't look quite right...

> 
> I can't see anything odd in the network traffic - it just stops as if it
> has no more data to send.  However, the socket appears to still be
> blocking so the application cannot give it any new data.
> 
> This seems to be a problem with the abandonment functionality:
> 1. Transmit chunk 1.  The transmitted list now contains chunk 1.
> 2. Chunk 1 and it's retransmissions get lost on the network.
> 3. Abandon chunk 1.  The transmitted list is now empty.

This causes a FORWARD TSN chunk to be sent to the peer telling him
to advance CTSN to that of chunk 1.

> 4. Transmit chunk 2.  the transmitted list now contains chunk 2
> 5. Receive a gap-ack for chunk 2, indicating that chunk 1 is missing.

Yes, but at this point, we will regenerate the FORWARD TSN since chunk1
is still on the abandoned list.

> At this point, the T3 timer is disabled at the bottom of
> sctp_check_transmitted() since all the chunks in the transmitted queue are
> gap-acked.  The whole connection now stalls, waiting for the SACK for
> chunk 1 that will never arrive.
> 

I'll look some more at this...

-vlad
> It should be noted that this is not unordered data and I'm not clear on
> how abandoned chunks are supposed to be handled - I hadn't intentionally
> enabled the abandonment functionality, the timetolive was set on the
> transmitted chunks by accident.
> 

