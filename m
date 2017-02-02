From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH net-next] loopback: clear pfmemalloc on outgoing skb's
Date: Thu, 2 Feb 2017 10:56:11 -0500
Message-ID: <1486050971.29885.24.camel@fb.com>
References: <1485983078-2372-1-git-send-email-jbacik@fb.com>
         <1485992285.6360.168.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>,
        "David S . Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41258 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751036AbdBBP4j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 10:56:39 -0500
In-Reply-To: <1485992285.6360.168.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-01 at 15:38 -0800, Eric Dumazet wrote:
> On Wed, 2017-02-01 at 16:04 -0500, Josef Bacik wrote:
> > 
> > I was seeing random disconnects while testing NBD over
> > loopback.  This turned
> > out to be because NBD sets pfmemalloc on it's socket, however the
> > receiving side
> > is a user space application so does not have pfmemalloc set on its
> > socket.  This
> > means that sk_filter_trim_cap will simply drop this packet, under
> > the assumption
> > that the other side will simply retransmit.  Well we do retransmit,
> > and then the
> > packet is just dropped again for the same reason.  To keep this
> > from happening
> > simply clear skb->pfmemalloc on transmit so that we don't drop the
> > packet on the
> > receive side.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> > ---
> >  drivers/net/loopback.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> > index 1e05b7c..13c9126 100644
> > --- a/drivers/net/loopback.c
> > +++ b/drivers/net/loopback.c
> > @@ -81,6 +81,13 @@ static netdev_tx_t loopback_xmit(struct sk_buff
> > *skb,
> >  	 */
> >  	skb_dst_force(skb);
> >  
> > +	/* If our transmitter was a pfmemalloc socket we need to
> > clear
> > +	 * pfmemalloc here, otherwise the receiving socket may not
> > be
> > +	 * pfmemalloc, and if this is a tcp packet then it'll get
> > dropped and
> > +	 * all traffic will halt.
> > +	 */
> > +	skb->pfmemalloc = false;
> > +
> I am not sure this is a proper fix.
> 
> Presumably if the socket was able to store packets in its write
> queue,
> fact that it sends it to loopback or an Ethernet link should not
> matter.
> 
> Only in RX path the pfmemalloc thing is really important.
> 
> So I would rather not set skb->pfmemalloc for skbs allocated for the
> write queue, and more exactly the fast clone.
> 
> This would actually speed up the stack a bit.

The problem is we set skb->pfmemalloc a bunch of different places, such
as __skb_fill_page_desc, which appears to be used in both the RX and TX
path, so we can't just kill it there.  Do we want to go through and
audit each one, provide a way for callers to indicate if we care about
pfmemalloc and solve this problem that way?  I feel like that's more
likely to bite us in the ass down the line, and somebody who doesn't
know the context is going to come along and change it and regress us to
the current situation.  The only place this is a problem is with
loopback, and my change is contained to this one weird case.  Thanks,

Josef
