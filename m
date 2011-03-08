From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Tue, 8 Mar 2011 15:21:03 -0800
Message-ID: <20110308152103.714f5f05@nehalam>
References: <il4vur$3ka$1@dough.gmane.org>
	<20110308111011.GA27967@xanadu.blop.info>
	<4D764AAC.30302@ncsu.edu>
	<20110308.114346.48506864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rhee@ncsu.edu, lucas.nussbaum@loria.fr, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59768 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756170Ab1CHXVH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 18:21:07 -0500
In-Reply-To: <20110308.114346.48506864.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Mar 2011 11:43:46 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Injong Rhee <rhee@ncsu.edu>
> Date: Tue, 08 Mar 2011 10:26:36 -0500
>=20
> > Thanks for updating CUBIC hystart. You might want to test the
> > cases with more background traffic and verify whether this
> > threshold is too conservative.
>=20
> So let's get down to basics.
>=20
> What does Hystart do specially that allows it to avoid all of the
> problems that TCP VEGAS runs into.
>=20
> Specifically, that if you use RTTs to make congestion control
> decisions it is impossible to notice new bandwidth becomming availabl=
e
> fast enough.
>=20
> Again, it's impossible to react fast enough.  No matter what you twea=
k
> all of your various settings to, this problem will still exist.
>=20
> This is a core issue, you cannot get around it.
>=20
> This is why I feel that Hystart is fundamentally flawed and we should
> turn it off by default if not flat-out remove it.
>=20
> Distributions are turning it off by default already, therefore it's
> stupid for the upstream kernel to behave differently if that's what
> %99 of the world is going to end up experiencing.

The assumption in Hystart that spacing between ACK's is solely due to
congestion is a bad. If you read the paper, this is why FreeBSD's
estimation logic is dismissed. The Hystart problem is different
than the Vegas issue.

Algorithms that look at min RTT are ok, since the lower bound is
fixed; additional queuing and variation in network only increases RTT
it never reduces it. With a min RTT it is possible to compute the
upper bound on available bandwidth. i.e If all packets were as good as
this estimate minRTT then the available bandwidth is X. But then using
an individual RTT sample to estimate unused bandwidth is flawed. To
quote paper.

  "Thus, by checking whether =E2=88=86(N ) is larger than Dmin , we
can detect whether cwnd has reached the available capacity
of the path"=20

So what goes wrong:
  1. Dmin can be too large because this connection always sees delays
due to other traffic or hardware. i.e buffer bloat.  This would cause
the bandwidth estimate to be too low and therefore TCP would leave
slow start too early (and not get up to full bandwidth).

  2. Dmin can be smaller than the clock resolution. This would cause
either sample to be ignored, or Dmin to be zero. If Dmin is zero,
the bandwidth estimate would in theory be infinite, which would
lead to TCP not leaving slow start because of Hystart. Instead
TCP would leave slow start at first loss.

Other possible problems:
  3. ACK's could be nudged together by variations in delay.
This would cause HyStart to exit slow start prematurely. To false
think it is an ACK train.

Noise in network is not catastrophic, it just
causes TCP to exit slow-start early and have to go into normal
window growth phase. The problem is that the original non-Hystart
behavior of Cubic is unfair; the first flow dominates the link
and other flows are unable to get in. If you run tests with two
flows one will get a larger share of the bandwidth.

I think Hystart is okay in concept but there may be issues
on low RTT links as well as other corner cases that need bug
fixing.

1. Needs to use better resolution than HZ. Since HZ can be 100.
2. Hardcoding 2ms as spacing between ACK's as train is wrong
   for local networks.





