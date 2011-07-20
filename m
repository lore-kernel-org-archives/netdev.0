From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Wed, 20 Jul 2011 02:43:12 +0200
Message-ID: <1311122593.3113.46.camel@edumazet-laptop>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	 <1311105738.3113.11.camel@edumazet-laptop>
	 <20110719202922.GA2352@minipsycho>
	 <1311108107.3113.22.camel@edumazet-laptop>
	 <20110720001904.GA1992@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43912 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab1GTAnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 20:43:18 -0400
Received: by wwe5 with SMTP id 5so4687142wwe.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 17:43:17 -0700 (PDT)
In-Reply-To: <20110720001904.GA1992@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 20:19 -0400, Neil Horman a =C3=A9crit :
> >=20
> You are correct Eric, this can cause a significant performance regres=
sion, but I
> think that beats causing a panic or other unexpected behavior.  I rea=
d your
> previous threads with others regarding fixing this with vlans, but I =
don't think
> its fair to just say 'its fast, but it might cause oopses'.=20
>=20
> And its not sufficient to simply forbid soft drivers to make use of p=
ktgen, its
> not just a soft driver problem, its systemic.  Any driver which assum=
es that it
> has exclusive access to an skb submitted for transmit is at risk from=
 pktgen in
> its current implementation.  That of course as a subset includes all =
the soft
> drivers, but others are also suceptible.  As examples (some of which =
I noted in
> the origional post) virtio_net uses the skb->cb to hold vnet header i=
nformation
> which will be corrupted on sucessive sends.  bnx2x linearizes skbs un=
der certain
> circumstances, which means pktgen, if it marshals a fragmented frame =
will not
> send a fragmented frame after the first iteration.  The PPP and Slip =
drivers
> skb_push the skb to prepend a header to the frame on send, meaning su=
cessive
> uses, up until they get an skb_under_panic will get iteratively more =
malformed
> frames on the wire as ppp headers get stacked on top of one another. =
 These are
> ust a few of the examples I've found.
>=20
> The long and the short of it in my mind, is that we have a fundamenta=
l
> disconnect between driver asumptions and pktgen.  If its ok to submit=
 shared
> skbs to drivers, then we need to augment drivers that modify skbs on =
transmit to
> clone the skb (likey not an efficient solution), or if its not ok to =
do so, we
> need to change pktgen to not behave that way.
>=20

Its a known problem, please check mail archives. Nobody felt a fix was
needed.

> > Note : a sysadmin has other ways to make a machine panic or reboot =
or
> > halt...
> Yes, predictable ways, that the sysadmin can see coming based on what=
 they're
> doing (i.e. no one should be shocked if they dd /dev/random to /dev/k=
mem and get
> a hang or panic, or if they issue a sysrq-c, etc).  This case is diff=
erent.  A
> sysadmin reasonably expects pktgen to send the frames they configure =
on the
> interface they specify.  While its arguably reasonable to forsee that=
 it may not
> work with soft interfaces, pktgen just won't work with some hardware =
drivers (as
> per the examples above).  And it won't always be an oops, it may be o=
ccasional
> random behvaior in the output data, and its highly dependent not just=
 on the use
> of pktgen, but rather the specific command(s) issued.
>=20
>=20
> I'm sensitive to the performance impact, but I would much rather see =
a lower
> performing pktgen that doesn't randomly crash, and bring the performa=
nce back up
> in a safe, reliable way.  To that end, I've been starting to think ab=
out
> pre-allocating a ring buffer of skbs with a skb->users count biased u=
p to
> prevent driver freeing.  That way we could detect 'unused skb's' by a=
 user count
> that was at the bias level.  Thoughts?
>=20

I dont know. I use pktgen maybe once per week and never got a single
crash like this. We probably are very few pktgen users in the world, an=
d
we use it exactly to avoid calling skb_clone() or other expensive per
xmit setup.

Just remove pktgen from RedHat kernels, if you dont trust sysadmins.
# CONFIG_PKTGEN is not set

Alternatively, add a check to problematic drivers to _not_ mess skb if
skb_shared(skb) is true : eventually use skb_share_check()



