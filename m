From: Werner Almesberger <wa@almesberger.net>
Subject: Re: snd_cwnd drawn and quartered
Date: Tue, 14 Jan 2003 02:25:09 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030114022509.P1516@almesberger.net>
References: <20030114010157.M1516@almesberger.net> <200301140502.IAA10733@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200301140502.IAA10733@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Tue, Jan 14, 2003 at 08:02:23AM +0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Losses in the same window must not result in multiplicative collapse
> of cwnd or extension of recovery period. If they do, we are really buggy.

Oh, according to NewReno, extending the recovery period is just fine.
You just need to stop counting ... And what we have is definitely
NewReno-ish, with recovery ending at high_seq.

> Which is funny and unexpected, I read the paper only after the implementation
> has been mostly finished (based on old Hoe's papers) and just added
> some colorful details, sort of this one. :-)

That explains why things are so similar but still not quite the
same :-))

> It is required to stop all the smartness and to enter RTO timeout,

Okay, that makes also the ssthresh/2 fix easier, because it eliminates
the one case where the current behaviour is actually right.

> I did not get this. This limit is boundary check which you referred to
> several sentences above. Not falling under prior_cwnd/2 does not need
> a special check, we do not receive more than prior_cnwd ACKs while single
> recovery period in any case.

Yes yes, we do ... that's what NewReno is all about. Let's say you
lose the 0th and the 99th segment (with cwnd = 100). You'll detect
the first loss at t = 100, and enter recovery. You leave recovery
once snd_nxt (stored in high_seq) at that time has been ack'ed. So
this is 100. At time t=199, we find out about the loss of the 99th
segment, and retransmit. This gets ack'ed at time t=299. So it's
only then when we leave recovery.

draft-ratehalving distinguishes the adjustement interval and the
repair interval. The latter lasts until we've fixed all losses,
while the former should indeed not exceed one RTT. It's this
limitation that's missing in Linux.

> Huh. We can just shot this silly heuritsics, if it hurts. :-)

If you enter RTO upon loss of retransmission, we can, yes.
(And we don't even need a new variable ;-)

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
