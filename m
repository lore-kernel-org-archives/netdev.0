From: Werner Almesberger <wa@almesberger.net>
Subject: Re: snd_cwnd drawn and quartered
Date: Tue, 14 Jan 2003 01:01:57 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030114010157.M1516@almesberger.net>
References: <20030102030858.E1363@almesberger.net> <200301140012.DAA09790@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200301140012.DAA09790@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Tue, Jan 14, 2003 at 03:12:37AM +0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Of course. But draining happens when you received more ACKs than
> you sent packets. When such pathalogy happens we just have to do something,
> at least to understand when it happens under normal conditions.

Yes, that's a separate problem. There are (at least :-) two problems
we're looking at:

 - cwnd getting too small, probably due to "natural causes", and
   not recovering properly
 - cwnd getting reduced too much by the ssthresh/2 test

Cheng's been talking about the first one, I'm on the latter. Note
that in my case, no retransmissions are lost. There are only some
additional losses in the initial cwnd (actually, just one loss
would be sufficient), which then extend the recovery period.

I went through draft-ratehalving and compared it with what our TCP
is doing. It seems that the test is actually about 50% right :-)

Below is my analysis of the situation. How do you like the idea of
adding another variable ? :-)

Here we go:

To analyze whether changing tcp_input.c:tcp_cwnd_down from
	if (decr && tp->snd_cwnd > tp->snd_ssthresh/2)
to
	if (decr && tp->snd_cwnd > tp->snd_ssthresh)
yields valid TCP behaviour, I'm comparing the algorithm
specification in draft-ratehalving [1] with the implementation of
Linux TCP. The goal is to show whether Linux TCP still performs
according to draft-ratehalving after the change.

[1] http://www.psc.edu/networking/ftp/papers/draft-ratehalving.txt


draft-ratehalving generally aims to set cwnd (they call it rhcwnd)
to (prior_cwnd-loss)/2 (section 5.14), where "loss" are the packets
that have been lost from the RTT sent before we entered recovery,
and "prior_cwnd" is the cwnd at the time when we began recovery.
This is also explained in section 3.1 of RFC2581.

For simplicity, let's assume there is no reordering, no ACK loss,
and no jumps in delay.

Without NewReno, there are two cases: if the loss is indicated by
an "exact" means (ECN, SACK), it reduces cwnd by half the distance
by which fack is advanced, plus half the size of any "holes" found
via SACK (5.6). At the end of recovery, cwnd should therefore reach
(prior_cwnd-loss)/2, as specified above.

Still without NewReno, if loss is indicated by a duplicate ACK
without SACK, cwnd is reduced by half a segment for each duplicate
ACK received (4.7). This way, cwnd will shrink to
(prior_cwnd+loss)/2. (No typo - it's "+").

With NewReno, the algorithms are the same, but cwnd stops
decrementing at cwnd <= prior_cwnd/2 (5.12).

Once we get out of recovery, cwnd gets set to
(prior_cwnd-num_retrans)/2, where num_retrans is the number of
retransmissions in the "repair interval" (4.13). This is effectively
the number of retransmissions we needed to fix the initial loss.

I'm not entirely sure how this changes if we lose a retransmission.
RFC2581 requires cwnd to be halved twice in this case (4.3).

At the end (4.14), draft-ratehalving forces the new cwnd below
prior_cwnd/2 (in case we didn't decrement enough, e.g. in the second
"old" Reno case). It also sets ssthresh to the new cwnd, but makes
sure it (ssthresh) does not drop below prior_cwnd/4 to ensure "that
the TCP connection is not unduly harmed by extreme network conditions"
(5.14, probably meaning reordering).


When entering congestion (tcp_input.c:tcp_fastretrans_alert), Linux
TCP sets ssthresh to roughly half cwnd (tcp.h:tcp_recalc_ssthresh).
Note that this differs from the requirement of setting ssthresh to
half the amount of data in flight.

During recovery, cwnd reduction is done by tcp_input.c:tcp_cwnd_down
as follows: snd_cwnd is decremented for every second (duplicate) ACK,
which corresponds to sections 4.7 and 4.12 of draft-ratehalving,
except that snd_cwnd reduction stops at snd_ssthresh/2 (corresponding
roughly to prior_cwnd/4) instead of prior_cwnd/2.

Additionally, cwnd may be further reduced if there are less than
cwnd packets in flight. (This deserves further analysis.)

The equivalent to the first part of 4.14 happens in tcp_complete_cwr:
cwnd is set to the minimum of cwnd and ssthresh, where the latter is
(roughly) prior_cwnd/2.


Raising the cut-off point for cwnd reduction to ssthresh would still
yield the cwnd decrease described in section 4.7, and the cut-off
would occur at the point described in section 4.12. Furthermore, at
the end of recovery, snd_cwnd is set up prior_cwnd/2, which is
consistent with section 5.14.

So far, so good. Unfortunately, there are are two exceptions: a loss
outside the cwnd in which the initial loss occurred (i.e. loss of
data above high_seq) or the loss of a retransmission is required to
cause another halving of cwnd. A loss above high_seq is detected and
handled as separate loss after the current loss episode has ended,
and there does not need to concern us here.

However, loss of a retransmission is handled implicitly, as follows:
it extends the recovery interval to at least 2*RTT. This causes
the current implementation of tcp_cwnd_down to decrement snd_cwnd to
ssthresh/2, yielding the correct result.

The most correct solution seems therefore to introduce yet another
TCP state variable cwnd_bound that limits how far tcp_cwnd_down can
decrement snd_cwnd. Initially, tcp_input.c:tcp_clear_retrans and
tcp_input.c:tcp_fastretrans_alert would set cwnd_bound to the
reduced snd_ssthresh, limiting snd_cwnd reductions to prior_cwnd/2.
If tcp_input.c:tcp_sacktag_write_queue detects loss of a
retransmission, it sets cwnd_bound to ssthresh/2, allowing reduction
down to prior_cwnd/4.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
