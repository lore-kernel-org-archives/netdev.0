From: Werner Almesberger <wa@almesberger.net>
Subject: snd_cwnd drawn and quartered
Date: Tue, 24 Dec 2002 22:50:40 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021224225040.A22201@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chengjin@cs.caltech.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

how about a little bug for Christmas ? :-)

There seems to be a bug in how fast recovery halves cwnd:
Linux TCP decrements snd_cwnd for every second incoming ACK
until we leave fast recovery.

Using the NewReno procedure, recovery ends between the time of
the inital loss plus RTT (no further losses), or about one RTT
later (if we lose the packet just sent before we detected the
initial loss).

So, in the worst case (i.e. the drawn-out recovery), cwnd gets
decremented for every second incoming ACK during two RTTs. In
the first RTT, we get the equivalent of the old cwnd of ACKs,
while in the second RTT, we've slowed down, and get only half
as many ACKs. So we end up with cwnd being a quarter of its
initial value.

Now, one could argue that this actually kind of makes sense
(i.e. no discontinuity for loss near the end of recovery),
but the code quite clearly tries to avoid this case:

net/ipv4/tcp_input.c:tcp_cwnd_down:

	if (decr && tp->snd_cwnd > tp->snd_ssthresh/2)
		tp->snd_cwnd -= decr;

Unfortunately, snd_ssthresh has already been halved at this
point, so the test actually does nothing. So I'd suggest to
change this to

	if (decr && tp->snd_cwnd > tp->snd_ssthresh)

This was found by Cheng Jin and me in his simulator based
on 2.4.18, but the code still seems to be the same in 2.5.53.

BTW, ironically, at least gcc 3.1 generates slightly worse
code if I change the second line to

		tp->snd_cwnd--;

It may still be desirable to change this for clarity,
though.

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
