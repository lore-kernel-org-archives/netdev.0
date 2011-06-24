From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: Reducing rwnd by sizeof(struct sk_buff) for each
 CHUNK is too aggressive
Date: Fri, 24 Jun 2011 11:21:11 -0400
Message-ID: <4E04AB67.1040407@hp.com>
References: <20110624101535.GB9222@canuck.infradead.org> <4E0495C3.30102@hp.com> <20110624144251.GC9222@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:24627 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210Ab1FXP1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 11:27:49 -0400
In-Reply-To: <20110624144251.GC9222@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2011 10:42 AM, Thomas Graf wrote:
> On Fri, Jun 24, 2011 at 09:48:51AM -0400, Vladislav Yasevich wrote:
>> I believe there was work in progress to change how window is computed.  The issue with
>> your current patch is that it is possible to consume all of the receive buffer space while
>> still having an open receive window.  We've seen it in real life which is why the above band-aid
>> was applied.
> 

First, let me state that I mis-understood what the patch is attempting to do.
Looking again, I understand this a little better, but still have reservations.

> I don't understand this. The rwnd _announced_ is sk_rcvbuf/2 so we are
> reserving half of sk_rcvbuf for structures like sk_buff. This means we
> can use _all_ of rwnd for data. If the peer announces a a_rwnd of 1500
> in the last SACK I expect that peer to be able to handle 1500 bytes of
> data.
> 
> Regardless of that, why would we reserve a sk_buff for each chunk? We only
> allocate an skb per packet which can have many chunks attached.
> 
> To me, this looks like a fix for broken sctp peers.

Well, the rwnd announced is what the peer stated it is.  All we can do is
try to estimate what it will be when this packet is received.
We, instead of trying to underestimate the window size, try to over-estimate it.
Almost every implementation has some kind of overhead and we don't know how
that overhead will impact the window.  As such we try to temporarily account for this
overhead.

If we treat the window as strictly available data, then we may end up sending a lot more traffic
then the window can take thus causing us to enter 0 window probe and potential retransmission
issues that will trigger congestion control.  
We'd like to avoid that so we put some overhead into our computations.  It may not be ideal
since we do this on a per-chunk basis.  It could probably be done on per-packet basis instead.
This way, we'll essentially over-estimate but under-subscribe our current view of the peers
window.  So in one shot, we are not going to over-fill it and will get an updated view next
time the SACK arrives.

> 
>> The correct patch should really something similar to TCP, where receive window is computed as
>> a percentage of the available receive buffer space at every adjustment.  This should also take into
>> account SWS on the sender side.
> 
> Can you elaborate this a little more? You want our view of the peer's receive
> window to be computed as a percentage of the available receive buffer on our
> side?
> 

As I said, I miss-understood what you were trying to do. Sorry for going off in another direction.

Thanks
-vlad

