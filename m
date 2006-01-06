From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 6 Jan 2006 12:26:26 -0800
Message-ID: <20060106202626.GA5677@us.ibm.com>
References: <20060105235845.967478000@sorel.sous-sol.org> <20060106004555.GD25207@sorel.sous-sol.org> <Pine.LNX.4.64.0601051727070.3169@g5.osdl.org> <43BE43B6.3010105@cosmosbay.com> <1136554632.30498.7.camel@localhost.localdomain> <20060106164702.GA5087@us.ibm.com> <43BEA693.5010509@cosmosbay.com>
Reply-To: paulmck@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Linus Torvalds <torvalds@osdl.org>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752543AbWAFUZ6@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <43BEA693.5010509@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 06, 2006 at 06:19:15PM +0100, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
> >On Fri, Jan 06, 2006 at 01:37:12PM +0000, Alan Cox wrote:
> >>On Gwe, 2006-01-06 at 11:17 +0100, Eric Dumazet wrote:
> >>>I assume that if a CPU queued 10.000 items in its RCU queue, then =
the=20
> >>>oldest entry cannot still be in use by another CPU. This might sou=
nds as=20
> >>>a violation of RCU rules, (I'm not an RCU expert) but seems quite=20
> >>>reasonable.
> >>Fixing the real problem in the routing code would be the real fix.=20
> >>
> >>The underlying problem of RCU and memory usage could be solved more
> >>safely by making sure that the sleeping memory allocator path alway=
s
> >>waits until at least one RCU cleanup has occurred after it fails an
> >>allocation before it starts trying harder. That ought to also natur=
ally
> >>throttle memory consumers more in the situation which is the right
> >>behaviour.
> >
> >A quick look at rt_garbage_collect() leads me to believe that althou=
gh
> >the IP route cache does try to limit its use of memory, it does not
> >fully account for memory that it has released to RCU, but that RCU h=
as
> >not yet freed due to a grace period not having elapsed.
> >
> >The following appears to be possible:
> >
> >1.	rt_garbage_collect() sees that there are too many entries,
> >	and sets "goal" to the number to free up, based on a
> >	computed "equilibrium" value.
> >
> >2.	The number of entries is (correctly) decremented only when
> >	the corresponding RCU callback is invoked, which actually
> >	frees the entry.
> >
> >3.	Between the time that rt_garbage_collect() is invoked the
> >	first time and when the RCU grace period ends, rt_garbage_collect()
> >	is invoked again.  It still sees too many entries (since
> >	RCU has not yet freed the ones released by the earlier
> >	invocation in step (1) above), so frees a bunch more.
> >
> >4.	Packets routed now miss the route cache, because the correspondin=
g
> >	entries are waiting for a grace period, slowing the system down.
> >	Therefore, even more entries are freed to make room for new
> >	entries corresponding to the new packets.
> >
> >If my (likely quite naive) reading of the IP route cache code is cor=
rect,
> >it would be possible to end up in a steady state with most of the en=
tries
> >always being in RCU rather than in the route cache.
> >
> >Eric, could this be what is happening to your system?
> >
> >If it is, one straightforward fix would be to keep a count of the nu=
mber
> >of route-cache entries waiting on RCU, and for rt_garbage_collect()
> >to subtract this number of entries from its goal.  Does this make se=
nse?
> >
>=20
> Hi Paul
>=20
> Thanks for reviewing route code :)
>=20
> As I said, the problem comes from 'route flush cache', that is period=
ically=20
> done by rt_run_flush(), triggered by rt_flush_timer.
>=20
> The 10% of LOWMEM ram that was used by route-cache entries are pushed=
 into=20
> rcu queues (with call_rcu_bh()) and network continue to receive
> packets from *many* sources that want their route-cache entry.

Hello, Eric,

The rt_run_flush() function could indeed be suffering from the same
problem.  Dipankar's recent patch should help RCU grace periods proceed
more quickly, does that help?

If not, it may be worthwhile to limit the number of times that
rt_run_flush() runs per RCU grace period.

						Thanx, Paul
