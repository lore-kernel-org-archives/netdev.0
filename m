From: Werner Almesberger <werner@almesberger.net>
Subject: net-AIO and real-time TCP (blue sky research)
Date: Sun, 1 Aug 2004 23:51:02 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040801235102.K1276@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Suparna Bhattacharya <suparna@in.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Suparna,

I'm copying this to netdev, because people there may get a good
chuckle out of this outlandish idea as well :-)

At OLS we were chatting about using AIO also for networking.
While this concept didn't seem to rank particularly high on the
lunacy scale, it didn't appear overly useful either. About the
only possibly interesting new functionality, besides the
possibility to connect this with some eccentric TCP offloading
and zero-copy scheme, would be - when applied to TCP - to make
unACKed data in the out-of-order buffer available to user
space.

Now, it occurred to me that this may lead to something a lot
more exciting: a step towards making TCP real-time capable.
I'm using the term "real-time" loosely here, as in "there's a
deadline, but we're flexible".

I haven't followed what's going on at IETF in that area for a
while, and I'm sure plenty of other people must have thought
of similar schemes before, but since this seems nicer and
maybe even simpler than some, let me describe it anyway.

First of all, one of the main complaints of the real-time
networking people is that TCP stubbornly insists on
retransmitting every single segment until it is absolutely
certain that the segment has been received, even if the
real-time application has long since moved on.

Now, with net-AIO, the application could already get all the
data that has arrived after a lost segment. That's a good
start, but TCP will still try to retransmit. So the next step
would be to have a means to indicate that we've lost interest
in the outcome of a pending AIO operation, and - as a side
effect - communicate this also to TCP, so that TCP can stop
trying, and do something more useful instead.

Let's call this operation aio_forget(). For disk IO, this
may work just like aio_cancel().

Now, aio_forget() would be a great tool for making TCP
blissfully ignorant of any losses, actually making it very
TCP-unfriendly. So the next step would be to record the fact
that we've just forgotten some segments, but still need to
make the peer aware of the fact that there (may) have been
losses, and to slow down accordingly. Obviously, if we have
reason to believe that the peer already knows of a loss in
the general vicinity, no action is needed.

Reliably communicating a loss isn't trivial, but there should
be good background material in the context of ECN. Of course,
if ECN is available, we may just use that. Otherwise, we may
have to force a retransmission, to be sure that the peer has
noticed. (And, if the forgotten segment(s) should arrive while
TCP is trying to indicate a loss, it should stop doing so.)

Now, assuming we have a solution for indicating losses that is
satisfying both in terms of congestion control and in terms of
efficiency, there are still a few things that would be nice to
have, that this approach doesn't solve:

 - message boundaries and segment-message alignment. Not being
   able to use messages just because a few of their bytes
   ended up in a lost (and then aio_forgotten) segment would
   be just too bad. In some cases, it may be possible to just
   set the MSS to a suitable value. Also, recovering message
   boundaries after a loss may be tricky.

 - there's no direct provision for allowing adaptive coding.
   Of course, this is a fairly orthogonal problem.

 - as time passes, the sender may want to remove or substitute
   data it had already enqueued, e.g because there is less
   bandwidth than originally anticipated. So there may be a
   place for aio_forget() at the sender side too.

Now, why could this scheme be "nicer" than just inventing some
new protocol that is designed to do all these things ? The
main thing that "looks good" is that this mechanism could use
all of TCP, and may not even need major maintenance if some
minor aspect of TCP congestion control gets changed.

Anyway, this may be peculiar enough for someone to spin the
idea a little further. In the worst case, I might just have
provided additional evidence that, if you just search long
enough, there's a perfectly plausible problem for every
solution :-)

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina     werner@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
