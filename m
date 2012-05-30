From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/2] Faster/parallel SYN handling to mitigate SYN
 floods
Date: Wed, 30 May 2012 10:44:57 +0200
Message-ID: <1338367497.7747.72.camel@localhost>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <4FC3A465.4030203@uclouvain.be> <1338322661.7747.17.camel@localhost>
	 <4FC53353.2050801@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Andi Kleen <andi@firstfloor.org>
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932264Ab2E3IpQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2012 04:45:16 -0400
In-Reply-To: <4FC53353.2050801@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-29 at 22:36 +0200, Christoph Paasch wrote:
[...cut...]

> >> Concerning (2):
> >>
> >> Imagine, a SYN coming in, when the reqsk-queue is not yet full. A
> >> request-sock will be added to the reqsk-queue. Then, a retransmission of
> >> this SYN comes in and the queue got full by the time. This time
> >> tcp_v4_syn_conn_limit will do syn-cookies and thus generate a different
> >> seq-number for the SYN/ACK.
> > 
> > I have addressed your issue, by checking the reqsk_queue in
> > tcp_v4_syn_conn_limit() before allocating a new req via
> > inet_reqsk_alloc().
> > If I find an existing reqsk, I choose to drop it, so the SYN cookie
> > SYN-ACK takes precedence, as the path/handling of the last ACK doesn't
> > find this reqsk. This is done under the lock.
> 
> Then the receiver will receive two SYN/ACK's for the same SYN with
> different sequence-numbers. As the "SYN cookie SYN-ACK" will arrive
> second, it will be discarded and seq-numbers from the first one will be
> taken on the client-side.

I thought that the retransmitted SYN packet, were caused by the SYN-ACK
didn't reach the client?

> Then, the connection will never establish, as both sides "agreed" on
> different sequence numbers.
> 
> I would say, you have to handle the retransmitted SYN as in
> tcp_v4_hnd_req by calling tcp_check_req.

Choosing that code path, should be easy by simply returning 0 (no_limit)
from my function tcp_v4_syn_conn_limit(), to indicate that the normal
slow code path should be chosen.

I guess this will not pose a big attack angle, as the entries in
reqsk_queue will be fairly small.
