From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] /proc/net/tcp, overhead removed
Date: Mon, 28 Sep 2009 16:24:17 -0700
Message-ID: <20090928162417.59640672@nehalam>
References: <1254000675-8327-1-git-send-email-iler.ml@gmail.com>
	<4ABF360E.7080301@gmail.com>
	<f36b08ee0909281510y282d621etb4264ecd92cbe8f0@mail.gmail.com>
	<4AC13697.4090707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yakov Lerner <iler.ml@gmail.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49339 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753499AbZI1XYT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 19:24:19 -0400
In-Reply-To: <4AC13697.4090707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Sep 2009 00:20:07 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Yakov Lerner a =C3=A9crit :
> > On Sun, Sep 27, 2009 at 12:53, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >> Yakov Lerner a =C3=A9crit :
> >>> /proc/net/tcp does 20,000 sockets in 60-80 milliseconds, with thi=
s patch.
> >>>
> >>> The overhead was in tcp_seq_start(). See analysis (3) below.
> >>> The patch is against Linus git tree (1). The patch is small.
> >>>
> >>> ------------  -----------   ------------------------------------
> >>> Before patch  After patch   20,000 sockets (10,000 tw + 10,000 es=
tab)(2)
> >>> ------------  -----------   ------------------------------------
> >>> 6 sec          0.06 sec     dd bs=3D1k if=3D/proc/net/tcp >/dev/n=
ull
> >>> 1.5 sec        0.06 sec     dd bs=3D4k if=3D/proc/net/tcp >/dev/n=
ull
> >>>
> >>> 1.9 sec        0.16 sec     netstat -4ant >/dev/null
> >>> ------------  -----------   ------------------------------------
> >>>
> >>> This is ~ x25 improvement.
> >>> The new time is not dependent on read blockize.
> >>> Speed of netstat, naturally, improves, too; both -4 and -6.
> >>> /proc/net/tcp6 does 20,000 sockets in 100 millisec.
> >>>
> >>> (1) against git://git.kernel.org/pub/scm/linux/kernel/git/torvald=
s/linux-2.6.git
> >>>
> >>> (2) Used 'manysock' utility to stress system with large number of=
 sockets:
> >>>   "manysock 10000 10000"    - 10,000 tw + 10,000 estab ip4 socket=
s.
> >>>   "manysock -6 10000 10000" - 10,000 tw + 10,000 estab ip6 socket=
s.
> >>> Found at http://ilerner.3b1.org/manysock/manysock.c
> >>>
> >>> (3) Algorithmic analysis.
> >>>     Old algorithm.
> >>>
> >>> During 'cat </proc/net/tcp', tcp_seq_start() is called O(numsocke=
ts) times (4).
> >>> On average, every call to tcp_seq_start() scans half the whole ha=
shtable. Ouch.
> >>> This is O(numsockets * hashsize). 95-99% of 'cat </proc/net/tcp' =
is spent in
> >>> tcp_seq_start()->tcp_get_idx. This overhead is eliminated by new =
algorithm,
> >>> which is O(numsockets + hashsize).
> >>>
> >>>     New algorithm.
> >>>
> >>> New algorithms is O(numsockets + hashsize). We jump to the right
> >>> hash bucket in tcp_seq_start(), without scanning half the hash.
> >>> To jump right to the hash bucket corresponding to *pos in tcp_seq=
_start(),
> >>> we reuse three pieces of state (st->num, st->bucket, st->sbucket)
> >>> as follows:
> >>>  - we check that requested pos >=3D last seen pos (st->num), the =
typical case.
> >>>  - if so, we jump to bucket st->bucket
> >>>  - to arrive to the right item after beginning of st->bucket, we
> >>> keep in st->sbucket the position corresponding to the beginning o=
f
> >>> bucket.
> >>>
> >>> (4) Explanation of O( numsockets * hashsize) of old algorithm.
> >>>
> >>> tcp_seq_start() is called once for every ~7 lines of netstat outp=
ut
> >>> if readsize is 1kb, or once for every ~28 lines if readsize >=3D =
4kb.
> >>> Since record length of /proc/net/tcp records is 150 bytes, formul=
a for
> >>> number of calls to tcp_seq_start() is
> >>>             (numsockets * 150 / min(4096,readsize)).
> >>> Netstat uses 4kb readsize (newer versions), or 1kb (older version=
s).
> >>> Note that speed of old algorithm does not improve above 4kb block=
size.
> >>>
> >>> Speed of the new algorithm does not depend on blocksize.
> >>>
> >>> Speed of the new algorithm does not perceptibly depend on hashsiz=
e (which
> >>> depends on ramsize). Speed of old algorithm drops with bigger has=
hsize.
> >>>
> >>> (5) Reporting order.
> >>>
> >>> Reporting order is exactly same as before if hash does not change=
 underfoot.
> >>> When hash elements come and go during report, reporting order wil=
l be
> >>> same as that of tcpdiag.
> >>>
> >>> Signed-off-by: Yakov Lerner <iler.ml@gmail.com>

Does the netlink interface used by ss command have the problem?

--=20
