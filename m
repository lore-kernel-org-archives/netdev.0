From: 'Christoph Paasch' <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net] tcp: Fix integer-overflows in TCP vegas
Date: Wed, 23 Jul 2014 13:18:02 +0200
Message-ID: <20140723111802.GB6387@cpaasch-mac>
References: <1406065017-22102-1-git-send-email-christoph.paasch@uclouvain.be>
 <063D6719AE5E284EB5DD2968C1650D6D1727BEDC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Doug Leith <doug.leith@nuim.ie>,
	Neal Cardwell <ncardwell@google.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:57333 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754841AbaGWL11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 07:27:27 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1727BEDC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/07/14 - 08:38:30, David Laight wrote:
> From: Of Christoph Paasch
> > In vegas we do a multiplication of the cwnd and the rtt. This
> > may overflow and thus their result is stored in a u64. However, we first
> > need to cast the cwnd so that actually 64-bit arithmetic is done.
> > 
> > Cc: Doug Leith <doug.leith@nuim.ie>
> > Fixes: 8d3a564da34e (tcp: tcp_vegas cong avoid fix)
> > Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> > ---
> >  net/ipv4/tcp_vegas.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
> > index 9a5e05f27f4f..6a4bdea2a0fb 100644
> > --- a/net/ipv4/tcp_vegas.c
> > +++ b/net/ipv4/tcp_vegas.c
> > @@ -218,7 +218,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
> >  			 * This is:
> >  			 *     (actual rate in segments) * baseRTT
> >  			 */
> > -			target_cwnd = tp->snd_cwnd * vegas->baseRTT / rtt;
> > +			target_cwnd = (u64)tp->snd_cwnd * vegas->baseRTT / rtt;
> 
> Won't that add a reference to the 64bit divide function?

Yes, you are right. Sorry... (that's what happens if one only tests on a
64-bit system... :S )

> If snd_cwnd is small then maybe:
> 	target_cwnd = (256u * vegas->baseRTT) / rtt * tp->snd_cwnd / 256u;
> If large I think low bits are always zero so:
> 	target_cwnd = (256u * vegas->baseRTT) / rtt * (tp->snd_cwnd / 256u);
> Possibly with a different power of 2...

I realize that baseRTT is always smaller or equal to rtt.

Thus, target_cwnd will always be <= snd_cwnd. So, I think target_cwnd does not
need to be a u64.


I think that it would be safer to do do_div(). That way no matter what the
difference between baseRTT and rtt, we always set the correct value. Otherwise
we might set target_cwnd to 0, while with a do_div it would not.

But a do_div might be more costly than your solution.


What do you (or others) think?


Cheers,
Christoph
