From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: high latency with TCP connections
Date: Thu, 31 Aug 2006 15:14:56 -0700
Message-ID: <20060831151456.12a4e080@dxpl.pdx.osdl.net>
References: <20060830100734.GA22235@isil.ipib.msu.ru>
	<20060830102727.11e11453@localhost.localdomain>
	<20060831214635.GA2680@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Vodomerov <alex@sectorb.msk.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52967 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964800AbWHaWPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 18:15:48 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060831214635.GA2680@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 1 Sep 2006 01:46:35 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Hello!
> 
> > Expecting any performance with one byte write's is silly.
> 
> I am not sure why you are so confident about status of ABC.
> I missed the discussions, when it was implemented. Apparently,
> it was noticed that ABC in its pure form does not make sense
> with snd_cwnd counted in packets and there were some reasons,
> why it still was not adapted.

I implemented it but don't think ABC is the correct thing to be doing
in all cases.

If you read the RFC3465, the problem it is trying to address is that of
small packets causing growth of congestion window beyond the capacity
of the link.

It makes a number of assumptions that may not be true for Linux:
  * ABC doesn't take into account congestion window validation RFC2861
    already prevents most of the problem of inflated growth.
  * ABC assumes that the "true" capacity of the link is limited by
    byte count not packet count.


> That's what I am sure: if congestion control causes delack syndrome,
> it is difficult to advocate this congestion control scheme.
> It must be repaired, if there is even the smallest possibility
> to do this.
> 
> 
> The first idea:
> 
> Behaviour is broken, when we have < 2*MSS in flight. In that
> case receiver falls to delack timeout and breaks ACK clock.
> 
> 	thresh = tp->mss_cache;
> 
> 	if (tp->snd_nxt - tp->snd_una <= tp->mss_cache) {
> 		thresh = 1;
> 		if (tp->send_head)
> 			thresh = tp->send_head->len;
> 		/* If send_head is empty, it disables ABC.
> 		 * If send_head is good mss sized segment, ABC is in work.
> 		 * If send_head is a small segment, it is half-way.
> 		 */
> 	}
> 
> 	if (tp->bytes_acked < thresh)
> 	       return;
> 
> Probably, do this only when TCP_NODELAY is set, but actually it does not
> matter. If it is nagled/corked, cwnd will not be used/increased in any case.

Maybe it makes better sense to add a bonus to bytes_acked on each ack to
try and make small packets get an increase sooner, and try and make the
cwnd * mss_cache estimate be more accurate. In the ideal case, during
slow start with small packets cwnd should increase at the same rate
that it would with larger packets.
