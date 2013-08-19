From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 06:24:17 -0700
Message-ID: <1376918657.4226.59.camel@edumazet-glaptop>
References: <521061B4.1030508@fatooh.org>
	 <1376839467.21329.36.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
	 <1376870425.4226.25.camel@edumazet-glaptop>
	 <1376870592.4226.27.camel@edumazet-glaptop> <5211DAA6.1070302@fatooh.org>
	 <20130819123314.GC3583@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:63238 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab3HSNYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 09:24:22 -0400
In-Reply-To: <20130819123314.GC3583@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-19 at 14:33 +0200, Christoph Paasch wrote:
> Hello,
> 
> I would say, the problem is due to a sequence-number rewriting
> middlebox, who does not correctly handle the SACK-blocks.
> 
> In remote.pcap, you see:
> Packet#10: A Dup-ACK: ACK 1005503816, SACK: 1005505184-1005505648
> The SACK actually covers Packet#9
> 
> In tun0.pcap, you have:
> Packet#9: The one that is SACK'ed: SEQ: 3514869772
> Packet#11: The Dup-ACK: ACK: 3514868404, SACK: 3570452498-3570452962
> 
> You can see that the SACK-block is not really aligned with the ACK-numbers.
> 
> Netfilter is probably dropping the Dup-ACK, because the SACK-block is
> acknowledging unseen data.
> 
> 
> There are middleboxes out there that randomize the sequence numbers, due to
> an old bug in Windows, where the initial sequence number was not
> sufficiently randomized. There are some of these middleboxes, who simply do
> not support SACK, thus modify only the sequence numbers of the TCP-header
> (https://supportforums.cisco.com/docs/DOC-12668#TCP_Sequence_Number_Randomization_and_SACK).
> 
> This results in a TCP retransmission timeout on the sender, because of
> the invalid SACK-blocks, the duplicate ACKs are not accounted. This
> completly kills the performance, as you can see in our presentation given at
> IETF87: http://tools.ietf.org/agenda/87/slides/slides-87-tcpm-11.pdf
> 
> We have a patch that accounts DUP-ACKs with invalid SACK-blocks effectively
> as duplicate acknowledgments. I can send the patches, if the
> netdev-community is interested in accepting these upstream.
> 

You mean a netfilter patch, a tcp patch, or both ?
