From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path MTU discovery broken
Date: Mon, 7 Oct 2013 05:09:10 +0200
Message-ID: <20131007030910.GG9295@order.stressinduktion.org>
References: <20130927201420.GB12043@sesse.net> <20130928203318.GC23654@order.stressinduktion.org> <20131006120612.GA27852@sesse.net> <20131007015252.GE9295@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44695 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754738Ab3JGDJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 23:09:11 -0400
Content-Disposition: inline
In-Reply-To: <20131007015252.GE9295@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 03:52:52AM +0200, Hannes Frederic Sowa wrote:
> On Sun, Oct 06, 2013 at 02:06:12PM +0200, Steinar H. Gunderson wrote:
> > On Sat, Sep 28, 2013 at 10:33:18PM +0200, Hannes Frederic Sowa wrot=
e:
> > >> So the =E2=80=9Cpacket too big=E2=80=9D packets really look like=
 they're being ignored.
> > >> However, they _do_ reach the kernel somehow, since Icmp6InPktToo=
Bigs
> > >> seems to increase.
> > >>=20
> > >> Could this be related somehow to the packets coming from 2001:67=
c:29f4::31,
> > >> while the default route is to a link-local address? (An RPF issu=
e?) This used
> > >> to work (although it was often flaky for me) in 3.10 and before.=
 I can't
> > >> easily bisect, though, as I don't boot this machine too often.
> > > This looks like a bug and should definitely get fixed. There shou=
ld be
> > > no RPF issue. May I have a look at your /proc/net/ipv6_route?
> >=20
> > It started again, so now I could capture what you asked for:
> >=20
> > pannekake:~> cat /proc/net/ipv6_route=20
> > 2001067c00a400037c4d9ae8ab73230f 80 0000000000000000000000000000000=
0 00 fe80000000000000023048fffe555743 00000000 00000001 00000137 010000=
23     eth0
>=20
> This one does look like the most probable route which could have the =
problem.
> It has a RTF_MODIFIED flag indicating it received a pmtu update.
>=20
> Did you take the snapshot while the tcp connection was hanging? We no=
rmally
> take 2 references to the rt6_info while the tcp connection is running=
, this
> oddly only has one (but got used a lot). But doing a judgement on the
> reference count is imprecise.
>=20
> If you write that this got worse in recent kernels I suspect commit
>=20
> commit ca4c3fc24e293719fe7410c4e63da9b6bc633b83
> Author: fan.du <fan.du@windriver.com>
> Date:   Tue Jul 30 08:33:53 2013 +0800
>=20
>     net: split rt_genid for ipv4 and ipv6
>=20

Hm, this actually went in in 3.12, so a bit too late for things to star=
t
failing in 3.11.

> The commit itself is fine, we may have a problem in our dst check log=
ic
> or do not bump rt6_genid at some point? If this is the case I might h=
ave
> an idea how to reproduce the problem.

Seems fine.

Could you try to check (with e.g. nstat) if any of the following counte=
rs
change if the icmp messages hit the host?

TcpExtOutOfWindowIcmps
Icmp6InErrors
TcpExtTCPMinTTLDrop
TcpExtListenDrops

Thanks,

  Hannes
