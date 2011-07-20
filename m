From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Tue, 19 Jul 2011 21:59:41 -0400
Message-ID: <20110720015941.GA2692@neilslaptop.think-freely.org>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311105738.3113.11.camel@edumazet-laptop>
 <20110719202922.GA2352@minipsycho>
 <1311108107.3113.22.camel@edumazet-laptop>
 <20110720001904.GA1992@neilslaptop.think-freely.org>
 <1311122593.3113.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43013 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab1GTB7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 21:59:55 -0400
Content-Disposition: inline
In-Reply-To: <1311122593.3113.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 02:43:12AM +0200, Eric Dumazet wrote:
> Le mardi 19 juillet 2011 =E0 20:19 -0400, Neil Horman a =E9crit :
> > >=20
> > You are correct Eric, this can cause a significant performance regr=
ession, but I
> > think that beats causing a panic or other unexpected behavior.  I r=
ead your
> > previous threads with others regarding fixing this with vlans, but =
I don't think
> > its fair to just say 'its fast, but it might cause oopses'.=20
> >=20
> > And its not sufficient to simply forbid soft drivers to make use of=
 pktgen, its
> > not just a soft driver problem, its systemic.  Any driver which ass=
umes that it
> > has exclusive access to an skb submitted for transmit is at risk fr=
om pktgen in
> > its current implementation.  That of course as a subset includes al=
l the soft
> > drivers, but others are also suceptible.  As examples (some of whic=
h I noted in
> > the origional post) virtio_net uses the skb->cb to hold vnet header=
 information
> > which will be corrupted on sucessive sends.  bnx2x linearizes skbs =
under certain
> > circumstances, which means pktgen, if it marshals a fragmented fram=
e will not
> > send a fragmented frame after the first iteration.  The PPP and Sli=
p drivers
> > skb_push the skb to prepend a header to the frame on send, meaning =
sucessive
> > uses, up until they get an skb_under_panic will get iteratively mor=
e malformed
> > frames on the wire as ppp headers get stacked on top of one another=
=2E  These are
> > ust a few of the examples I've found.
> >=20
> > The long and the short of it in my mind, is that we have a fundamen=
tal
> > disconnect between driver asumptions and pktgen.  If its ok to subm=
it shared
> > skbs to drivers, then we need to augment drivers that modify skbs o=
n transmit to
> > clone the skb (likey not an efficient solution), or if its not ok t=
o do so, we
> > need to change pktgen to not behave that way.
> >=20
>=20
> Its a known problem, please check mail archives. Nobody felt a fix wa=
s
> needed.
>=20
As I said in my origional note, I said I read the archives, I didn't ag=
ree with
the conclusion that a fix was unnecessecary.  I'm sorry if you don't ca=
re for
dissenting opinions.

> > > Note : a sysadmin has other ways to make a machine panic or reboo=
t or
> > > halt...
> > Yes, predictable ways, that the sysadmin can see coming based on wh=
at they're
> > doing (i.e. no one should be shocked if they dd /dev/random to /dev=
/kmem and get
> > a hang or panic, or if they issue a sysrq-c, etc).  This case is di=
fferent.  A
> > sysadmin reasonably expects pktgen to send the frames they configur=
e on the
> > interface they specify.  While its arguably reasonable to forsee th=
at it may not
> > work with soft interfaces, pktgen just won't work with some hardwar=
e drivers (as
> > per the examples above).  And it won't always be an oops, it may be=
 occasional
> > random behvaior in the output data, and its highly dependent not ju=
st on the use
> > of pktgen, but rather the specific command(s) issued.
> >=20
> >=20
> > I'm sensitive to the performance impact, but I would much rather se=
e a lower
> > performing pktgen that doesn't randomly crash, and bring the perfor=
mance back up
> > in a safe, reliable way.  To that end, I've been starting to think =
about
> > pre-allocating a ring buffer of skbs with a skb->users count biased=
 up to
> > prevent driver freeing.  That way we could detect 'unused skb's' by=
 a user count
> > that was at the bias level.  Thoughts?
> >=20
>=20
> I dont know. I use pktgen maybe once per week and never got a single
> crash like this. We probably are very few pktgen users in the world, =
and
> we use it exactly to avoid calling skb_clone() or other expensive per
> xmit setup.
Please re-read my origional post.  Lots of drivers work just fine, some=
 don't.
Some just behave differently.  Its the random results thats broken and =
I feel
needs fixing.  I get that performance is an issue, and I'm open to othe=
r
solutions, I'm not open to just saying 'its fine, mostly'.

>=20
> Just remove pktgen from RedHat kernels, if you dont trust sysadmins.
> # CONFIG_PKTGEN is not set
>=20
You're twisting my words.  At what point in time did I say I
don't trust sysadmins?  I want to give them a tool that works reliably =
without
them having to comb through their nic drivers xmit patch to ensure that=
 pktgen
works without crashing or causing other odd behavior.  I don't think th=
ats too
much to ask.
=20
> Alternatively, add a check to problematic drivers to _not_ mess skb i=
f
> skb_shared(skb) is true : eventually use skb_share_check()
>=20
The former isn't feasible, as many skb modifications are neccesitated b=
y the
nature of the hardware.  The latter is possible, but far less scalable =
than just
modifying pktgen.

=46WIW, I like Ben's solution, adding a flag to drivers noting that the=
y can't
handle multi-skb.  Then we can dynamically enforce a clone in pktgen wh=
en needed
(or buffer up additional skbs)
