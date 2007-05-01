From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 22:02:49 +0400
Message-ID: <20070501180249.GB11542@2ka.mipt.ru>
References: <20070501151354.GB1751@kvack.org> <20070501162050.GB21896@2ka.mipt.ru> <20070501164935.GC1751@kvack.org> <20070501174126.GA7577@2ka.mipt.ru> <20070501175718.GA11542@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41740 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755220AbXEASDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 14:03:05 -0400
Content-Disposition: inline
In-Reply-To: <20070501175718.GA11542@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 09:57:18PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > I think if you will storm any system with acks lower than expected
> > unacknowledged number, result will be the same - ack, that it was bogus
> > message, if sending system sends wrong ack again, it will again receive
> > that it was bogus...
> 
> Wrong syn number of course.
> I described not exactly correct case - likely broken side does not know 
> that its messages were lost (or specially crafts such packets), so it 
> retransmit the same bogus packet with wrong syn, which already was acked.
> 
> As far as I can see, this is it:
> 
> /* step 1: check sequence number */
> if (!tcp_sequence(tp, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq)) {
> 	if (!th->rst)
> 		tcp_send_dupack(sk, skb);
> 	goto discard;
> }

And this is part of the RFC Linux follows:

        There are four cases for the acceptability test for an incoming
        segment:

        Segment Receive  Test
        Length  Window
        ------- -------  -------------------------------------------

           0       0     SEG.SEQ = RCV.NXT

           0      >0     RCV.NXT =< SEG.SEQ < RCV.NXT+RCV.WND

          >0       0     not acceptable

          >0      >0     RCV.NXT =< SEG.SEQ < RCV.NXT+RCV.WND
                      or RCV.NXT =< SEG.SEQ+SEG.LEN-1 < RCV.NXT+RCV.WND

        If the RCV.WND is zero, no segments will be acceptable, but
        special allowance should be made to accept valid ACKs, URGs and
        RSTs.

        If an incoming segment is not acceptable, an acknowledgment
        should be sent in reply (unless the RST bit is set, if so drop
        the segment and return):

          <SEQ=SND.NXT><ACK=RCV.NXT><CTL=ACK>

        After sending the acknowledgment, drop the unacceptable segment
        and return.


-- 
	Evgeniy Polyakov
