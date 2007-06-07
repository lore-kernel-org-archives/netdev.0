From: noboru.obata.ar@hitachi.com
Subject: Re: [RFC] Failover-friendly TCP retransmission
Date: Thu, 07 Jun 2007 13:27:04 +0900 (JST)
Message-ID: <20070607.132704.01367720.noboru.obata.ar@hitachi.com>
References: <p738xazbwha.fsf@bingen.suse.de>
    <20070605.220536.73364034.noboru.obata.ar@hitachi.com>
    <20070605192345.GA28301@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:55935 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbXFGE1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 00:27:38 -0400
Received: from mlsv18.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id 3BDEC37AD4
	for <netdev@vger.kernel.org>; Thu,  7 Jun 2007 13:27:37 +0900 (JST)
In-Reply-To: <20070605192345.GA28301@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andi,

I thank you for your comments.

Andi Kleen <andi@firstfloor.org> writes:
> > Your suggestion, to utilize NET_XMIT_* code returned from an
> > underlying layer, is done in tcp_transmit_skb.
> > 
> > But my problem is that tcp_transmit_skb is not called during a
> > certain period of time.  So I'm suggesting to cap RTO value so
> > that tcp_transmit_skb gets called more frequently.
> 
> The transmit code controls the transmission timeout. Or at least
> it could change it if it really wanted.
> 
> What I wanted to say is: if the loss still happens under control
> of the sending end device and TCP knows this then it could change
> the retransmit timer to fire earlier or even just wait for an 
> event from the device that tells it to retransmit early.

I examined your suggestion to introduce some interface so that
TCP can know, or be notified, to retransmit early.

Then there are two options; pull from TCP or notify to TCP.

The first option, pulling from TCP, must be done at the
expiration of retransmission timer because there is no other
context to do this.  But if RTO is already large, this can
easily miss events or status of underlying layer, such as
symptom of failure, failover, etc.  So I give up pulling from
TCP.

The second option, notifying to TCP, seems a bit promising.
Upon such a notification, TCP may look into a timer structure to
find retransmission events, update their timers so that they
expire earlier, and possibly reset their RTO values.  Perhaps
this should be done for all TCP packets because TCP doesn't know
which packet will be sent to the device of interest at that time.

But I don't quite see if this better solves my problem.  Such
upcalls would be more complicated than capping RTO, and thus may
be error-prone and harder to maintain.  Problems might be
solvable, but I'd prefer a simpler solution.


> The problem with capping RTO is that when there is a loss
> in the network for some other reasons (and there is no reason
> bonding can't be used when talking to the internet) you
> might be too aggressive or not aggressive enough anymore
> to get the data through.

I think capping RTO is robust and better than upcalls.  The
effects of capping RTO, as follows, are small enough.

* It just makes retransmission more frequent.  Since there is
  already a fast retransmission in TCP, retransmitting earlier
  itself does not break TCP.  (I'm going to examine every
  occurrence of TCP_RTO_MAX, though.)

* In the worst case, it does not increase the total number of
  retransmission packets, which is bounded by tcp_retries2.

  Thus the final retransmission timeout comes earlier with same
  tcp_retries2.  If this is a case, one will have to raise
  tcp_retries2.

* The average case, in a certain period of time (say 60[s]), it
  may slightly increase the number of retransmission packets.

  Starting from RTO = 0.2[s], the numbers of retransmission
  packets in first 60[s] are, 8 with TCP_RTO_MAX = 120[s], and
  15 with TCP_RTO_MAX = 5[s].

  I think that increasing several packets per minute per socket
  are acceptable.

Therefore the side effects of capping RTO, even talking to the
Internet, seems to be small enough.

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
