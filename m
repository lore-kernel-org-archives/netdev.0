From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: Reducing rwnd by sizeof(struct sk_buff) for each
 CHUNK is too aggressive
Date: Wed, 29 Jun 2011 10:09:18 -0400
Message-ID: <4E0B320E.4040309@hp.com>
References: <20110624101535.GB9222@canuck.infradead.org> <4E0495C3.30102@hp.com> <20110624144251.GC9222@canuck.infradead.org> <4E04AB67.1040407@hp.com> <20110627091136.GA10085@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:17322 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab1F2OJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 10:09:24 -0400
In-Reply-To: <20110627091136.GA10085@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2011 05:11 AM, Thomas Graf wrote:
> On Fri, Jun 24, 2011 at 11:21:11AM -0400, Vladislav Yasevich wrote:
>> We, instead of trying to underestimate the window size, try to over-estimate it.
>> Almost every implementation has some kind of overhead and we don't know how
>> that overhead will impact the window.  As such we try to temporarily account for this
>> overhead.
> 
> I looked into this some more and it turns out that adding per-packet
> overhead is difficult because when we mark chunks for retransmissions
> we have to add its data size to the peer rwnd again but we have no
> idea how many packets were used for the initial transmission. Therefore
> if we add an overhead, we can only do so per chunk.
> 

Good point.

>> If we treat the window as strictly available data, then we may end up sending a lot more traffic
>> then the window can take thus causing us to enter 0 window probe and potential retransmission
>> issues that will trigger congestion control.  
>> We'd like to avoid that so we put some overhead into our computations.  It may not be ideal
>> since we do this on a per-chunk basis.  It could probably be done on per-packet basis instead.
>> This way, we'll essentially over-estimate but under-subscribe our current view of the peers
>> window.  So in one shot, we are not going to over-fill it and will get an updated view next
>> time the SACK arrives.
> 
> What kind of configuration showed this behaviour? Did you observe that
> issue with Linux peers?

Yes, this was observed with linux peers.

> If a peer announces an a_rwnd which it cannot
> handle then that is a implementation bug of the receiver and not of the
> sender.
> 
> We won't go into zero window probe mode that easily, remember it's only
> one packet allowed in flight while rwnd is 0. We always take into
> account outstanding bytes when updating rwnd with a_rwnd so our view of
> the peer's rwnd is very accurate.
> 
> In fact the RFC clearly states when and how to update the peer rwnd:
> 
>    B) Any time a DATA chunk is transmitted (or retransmitted) to a peer,
>       the endpoint subtracts the data size of the chunk from the rwnd of
>       that peer.
> 
> I would like to try and reproduce the behaviour you have observed and
> fix it without cutting our ability to produce pmtu maxed packets with
> small data chunks.
> 

This was easily reproducible with sctp_darn tool using 1 byte payload.
This was a while ago, and I dont' know if anyone has tried it recently.

-vlad
