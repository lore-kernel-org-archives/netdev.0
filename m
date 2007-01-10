From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: Fw: Intermittent SCTP multihoming breakage
Date: Wed, 10 Jan 2007 12:10:12 -0800
Message-ID: <1168459812.8248.24.camel@w-sridhar2.beaverton.ibm.com>
References: <20070103154634.b40d9cde.akpm@osdl.org>
	 <1167872389.8646.25.camel@w-sridhar2.beaverton.ibm.com>
	 <Pine.CYG.4.58.0701040913300.3128@shill1-mobl.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:33137 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965066AbXAJUKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 15:10:21 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0AKAlwQ008199
	for <netdev@vger.kernel.org>; Wed, 10 Jan 2007 15:10:47 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l0AKADI1269904
	for <netdev@vger.kernel.org>; Wed, 10 Jan 2007 15:10:13 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0AKADdf008538
	for <netdev@vger.kernel.org>; Wed, 10 Jan 2007 15:10:13 -0500
To: Steve Hill <steve.hill@dialogic.com>
In-Reply-To: <Pine.CYG.4.58.0701040913300.3128@shill1-mobl.eicon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-10 at 11:55 +0000, Steve Hill wrote:
> On Wed, 3 Jan 2007, Sridhar Samudrala wrote:
> 
> Sorry for the delay in replying.
> 
> > No. lksctp-developers mailing list is still the best place for SCTP related
> > discussions. You can subscribe and look in the archives at
> >   http://lists.sourceforge.net/lists/listinfo/lksctp-developers
> 
> Hmm, I had a look there and it seemed reasonably inactive and overrun by
> spam.. (And I've been unable to subscribe).

It is not very active all the time, but you can see bursts of activity. 
All the SCTP patches and issues get discussed there before being 
submitted to netdev.
I didn't realize that so much spam is getting on this list. I don't see
any of it as my mailer's spam filters seem to be pretty effective. I will
see if there is a way to set up spam filters on sourceforge lists.

I haven't heard of any issues with subscription. Could you try again and
let me know offline if you still have issues.

> 
> > How are the 2 machines connected? Are they connected directly or
> > via a router?
> 
> They are currently connected together directly through crossover cables.
> 
> > Do you see both the addresses when you do cat /proc/net/sctp/assocs
> > after the association is established on both the peers?
> 
> Yes, the contents of /proc/net/sctp/assocs looks correct.
> 
> > How are you dropping traffic? You could try simulating failover by
> > bringing down the interface or physically removing the link.
> 
> I have been using iptables to drop SCTP packets on both the INPUT and
> OUTPUT chains.  However, I get the same results if I just unplug the
> network cable (using iptables is easier for my testing since I don't have
> to crawl around behind the test systems :)
> 
> > > 1. Sometimes, just after failing over to the second path I see an ABORT.
> > This seems to indicate that somehow the app has terminated.
> 
> The abort _appears_ to be caused by a retransmit timer expiring, causing
> the SCTP stack to tear down the association.  However, I haven't done much
> investigation of this problem yet - I've been focussing on the second
> problem since it seems to happen more frequently.
> 
> > > 2. More frequently, the association stays up indefinately, with heartbeat
> > > requests and acks on the second path, but no data chunks are sent even
> > > though the transmit queue on the transmitting end appears to be full and
> > > the socket is blocking writes.
> > This is strange. Can you collect tcpdump traces on sender and receiver when
> > this happens?
> 
> I've taken dumps of the data on the wire for both paths:
>   http://www.nexusuk.org/~steve/sctp/path1.pcap
>   http://www.nexusuk.org/~steve/sctp/path2.pcap
> 
> I can't see anything odd in the network traffic - it just stops as if it
> has no more data to send.  However, the socket appears to still be
> blocking so the application cannot give it any new data.
> 
> This seems to be a problem with the abandonment functionality:
> 1. Transmit chunk 1.  The transmitted list now contains chunk 1.
> 2. Chunk 1 and it's retransmissions get lost on the network.
> 3. Abandon chunk 1.  The transmitted list is now empty.
> 4. Transmit chunk 2.  the transmitted list now contains chunk 2
> 5. Receive a gap-ack for chunk 2, indicating that chunk 1 is missing.
> At this point, the T3 timer is disabled at the bottom of
> sctp_check_transmitted() since all the chunks in the transmitted queue are
> gap-acked.  The whole connection now stalls, waiting for the SACK for
> chunk 1 that will never arrive.
> 
> It should be noted that this is not unordered data and I'm not clear on
> how abandoned chunks are supposed to be handled - I hadn't intentionally
> enabled the abandonment functionality, the timetolive was set on the
> transmitted chunks by accident.

So looks like there may be an issue with PR-SCTP(partial reliability)
support and packet loss. I will take a look into this.

Do you still see this problem even if you don't set timetolive?
If you don't need chunks to be expired, you can disable pr-sctp using 
echo 0 > /proc/sys/net/sctp/prsctp-enable

Thanks
Sridhar


