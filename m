From: Steve Hill <steve.hill@dialogic.com>
Subject: Re: Fw: Intermittent SCTP multihoming breakage
Date: Wed, 10 Jan 2007 11:55:58 +0000
Message-ID: <Pine.CYG.4.58.0701040913300.3128@shill1-mobl.eicon.com>
References: <20070103154634.b40d9cde.akpm@osdl.org>
 <1167872389.8646.25.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eiconmtl.eicon.com ([192.219.17.124]:50815 "EHLO
	EICONMTL.eicon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932725AbXAJMJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 07:09:24 -0500
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1167872389.8646.25.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 Jan 2007, Sridhar Samudrala wrote:

Sorry for the delay in replying.

> No. lksctp-developers mailing list is still the best place for SCTP related
> discussions. You can subscribe and look in the archives at
>   http://lists.sourceforge.net/lists/listinfo/lksctp-developers

Hmm, I had a look there and it seemed reasonably inactive and overrun by
spam.. (And I've been unable to subscribe).

> How are the 2 machines connected? Are they connected directly or
> via a router?

They are currently connected together directly through crossover cables.

> Do you see both the addresses when you do cat /proc/net/sctp/assocs
> after the association is established on both the peers?

Yes, the contents of /proc/net/sctp/assocs looks correct.

> How are you dropping traffic? You could try simulating failover by
> bringing down the interface or physically removing the link.

I have been using iptables to drop SCTP packets on both the INPUT and
OUTPUT chains.  However, I get the same results if I just unplug the
network cable (using iptables is easier for my testing since I don't have
to crawl around behind the test systems :)

> > 1. Sometimes, just after failing over to the second path I see an ABORT.
> This seems to indicate that somehow the app has terminated.

The abort _appears_ to be caused by a retransmit timer expiring, causing
the SCTP stack to tear down the association.  However, I haven't done much
investigation of this problem yet - I've been focussing on the second
problem since it seems to happen more frequently.

> > 2. More frequently, the association stays up indefinately, with heartbeat
> > requests and acks on the second path, but no data chunks are sent even
> > though the transmit queue on the transmitting end appears to be full and
> > the socket is blocking writes.
> This is strange. Can you collect tcpdump traces on sender and receiver when
> this happens?

I've taken dumps of the data on the wire for both paths:
  http://www.nexusuk.org/~steve/sctp/path1.pcap
  http://www.nexusuk.org/~steve/sctp/path2.pcap

I can't see anything odd in the network traffic - it just stops as if it
has no more data to send.  However, the socket appears to still be
blocking so the application cannot give it any new data.

This seems to be a problem with the abandonment functionality:
1. Transmit chunk 1.  The transmitted list now contains chunk 1.
2. Chunk 1 and it's retransmissions get lost on the network.
3. Abandon chunk 1.  The transmitted list is now empty.
4. Transmit chunk 2.  the transmitted list now contains chunk 2
5. Receive a gap-ack for chunk 2, indicating that chunk 1 is missing.
At this point, the T3 timer is disabled at the bottom of
sctp_check_transmitted() since all the chunks in the transmitted queue are
gap-acked.  The whole connection now stalls, waiting for the SACK for
chunk 1 that will never arrive.

It should be noted that this is not unordered data and I'm not clear on
how abandoned chunks are supposed to be handled - I hadn't intentionally
enabled the abandonment functionality, the timetolive was set on the
transmitted chunks by accident.

-- 
 - Steve Hill
   Software Engineer
   Dialogic
   Fordingbridge, Hampshire, UK
   +44-1425-651392
   steve.hill@dialogic.com
