From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 21:57:18 +0400
Message-ID: <20070501175718.GA11542@2ka.mipt.ru>
References: <20070501151354.GB1751@kvack.org> <20070501162050.GB21896@2ka.mipt.ru> <20070501164935.GC1751@kvack.org> <20070501174126.GA7577@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55968 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755181AbXEAR50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 13:57:26 -0400
Content-Disposition: inline
In-Reply-To: <20070501174126.GA7577@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 09:41:28PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Tue, May 01, 2007 at 12:49:35PM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> > On Tue, May 01, 2007 at 08:20:50PM +0400, Evgeniy Polyakov wrote:
> > > > http://www.kvack.org/~bcrl/ack-storm.log .  As near as I can tell, a 
> > > > similar effect can occur between two Linux boxes if the right packets get 
> > > > reordered/dropped during connection teardown.
> > > 
> > > Could you archive 24Mb file or cut more precise bits out of it?
> > 
> > The interesting bits are the first 10 lines.
> > 
> > > According to your patch, several packets with fin bit might be sent,
> > > including one with data. If another host does not receive fin
> > > retransmit, then that logic is broken, and it can not be fixed by
> > > duplicating fins, I would even say, that remote box should drop second
> > > packet with fin, while it can carry data, which will break higher
> > > connection logic.
> > 
> > The FIN hasn't been ack'd by the other side, though and yet Linux is no 
> > longer transmitting packets with it sent.  Read the beginning of the trace.
> 
> Hmm, 2.2 machine in your test seems to behave incorrectly:
> 
> 22>11: 2624175182:2624175182(0) ack 1562038077 ack
> 22>11: 2624175182:2624175182(0) ack 1562038077 fin
> 
> 11>22: 1562038077:1562038077(0) ack 2624175183 fin
> 11>22: 1562038077:1562038077(0) ack 2624175183 fin // retransmit after
> 0.3 seconds, since there was no ack, it was either dropped, or first fin
> was dropped in the wire
> In former case 22 is in closing, in latter case - fin-wait1
> 
> 22>11: 2624175182:2624175182(0) ack 1562038077 ack //what is this ack
> for? It should have sequence number +1, since fin was sent.
> 11>22: 1562038078:1562038078(0) ack 2624175183 ack
> 11 answers that this ack is bogus and it wants 2624175183
> 
> 22>11: 2624175182:2624175182(0) ack 1562038077 ack
> 11>22: 1562038078:1562038078(0) ack 2624175183 ack
> 
> and so on...
> 
> I think if you will storm any system with acks lower than expected
> unacknowledged number, result will be the same - ack, that it was bogus
> message, if sending system sends wrong ack again, it will again receive
> that it was bogus...

Wrong syn number of course.
I described not exactly correct case - likely broken side does not know 
that its messages were lost (or specially crafts such packets), so it 
retransmit the same bogus packet with wrong syn, which already was acked.

As far as I can see, this is it:

/* step 1: check sequence number */
if (!tcp_sequence(tp, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq)) {
	if (!th->rst)
		tcp_send_dupack(sk, skb);
	goto discard;
}

-- 
	Evgeniy Polyakov
