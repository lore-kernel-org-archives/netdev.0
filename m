From: Werner Almesberger <wa@almesberger.net>
Subject: Re: snd_cwnd drawn and quartered
Date: Tue, 14 Jan 2003 03:36:51 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030114033651.S1516@almesberger.net>
References: <20030114022509.P1516@almesberger.net> <200301140614.JAA10804@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200301140614.JAA10804@sex.inr.ac.ru>; from kuznet@ms2.inr.ac.ru on Tue, Jan 14, 2003 at 09:14:36AM +0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Sorry, it is just nonsense in newreno, it is that high_seq makes.
> Well, and this is surely not fine, losses in several consecutive
> windows must result in multiplicative reduction of cwnd.

This is precisely what NewReno does. If you lose anything within
that cwnd, recovery is extended. If you lose something after the
cwnd, you'll first finish the old recovery cycle (since snd_una
has now passed high_seq), and then enter a new one, with the
appropriate reduction of ssthresh and cwnd.

> > Yes yes, we do ... that's what NewReno is all about. Let's say you
> > lose the 0th and the 99th segment (with cwnd = 100). You'll detect
> > the first loss at t = 100, and enter recovery. You leave recovery
> > once snd_nxt (stored in high_seq) at that time has been ack'ed. So
> > this is 100. At time t=199, we find out about the loss of the 99th
> > segment, and retransmit. This gets ack'ed at time t=299. So it's
> > only then when we leave recovery.
> 
> I do not understand, what you has just said. You cant discover
> loss of 99th segment _after_ 100th was happily ACKed. :-) :-)

That would be kind of evil :-) But that's not what I meant. The
100 refers to high_seq, i.e. the segment we need to get ack'ed
for leaving recovery.

> But thit does not matter because it handles opposite case, when cwnd
> was not reduced enough for one RTT, so rh falls to hold state
> to decrease cwnd smoothly. It is just an unnecessary complication
> to my opinion. Did I get this wrong?

Hmm, I think it's like I said. The case of cwnd not getting
reduced enough is handled when exiting repair, i.e. section 4.13
and 4.14.

Note that those intervals don't have to be explicitly tracked in
any way. E.g. the adjustment interval can just be implemented by
stopping decrementing cwnd at the new ssthresh.

> Picture, Werner! What does happen on picture quarter.eps????

t=0:  we have the first loss. At this time, snd_nxt is 100, so
      we set high_seq accordingly, slash ssthresh, and enter
      recovery.
~98:  we have the last loss within our cwnd (the simulation
      just stops losing packets at this point. In real life,
      this transmission should of course be smoother.)
100:  we've recovered our initial loss, but snd_una is still
      below high_seq, because of all the other losses in that
      cwnd
~200: we recover the last loss, and snd_una finally increases
      above high_seq, so we leave recovery now.

All that is just fine, if I interpret NewReno right. The only
problem is that we should have stopped reducing cwnd after the
first RTT.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
