From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 path MTU discovery broken
Date: Mon, 7 Oct 2013 03:52:52 +0200
Message-ID: <20131007015252.GE9295@order.stressinduktion.org>
References: <20130927201420.GB12043@sesse.net> <20130928203318.GC23654@order.stressinduktion.org> <20131006120612.GA27852@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edumazet@google.com, fan.du@windriver.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44588 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953Ab3JGBwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 21:52:54 -0400
Content-Disposition: inline
In-Reply-To: <20131006120612.GA27852@sesse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 06, 2013 at 02:06:12PM +0200, Steinar H. Gunderson wrote:
> On Sat, Sep 28, 2013 at 10:33:18PM +0200, Hannes Frederic Sowa wrote:
> >> So the =E2=80=9Cpacket too big=E2=80=9D packets really look like t=
hey're being ignored.
> >> However, they _do_ reach the kernel somehow, since Icmp6InPktTooBi=
gs
> >> seems to increase.
> >>=20
> >> Could this be related somehow to the packets coming from 2001:67c:=
29f4::31,
> >> while the default route is to a link-local address? (An RPF issue?=
) This used
> >> to work (although it was often flaky for me) in 3.10 and before. I=
 can't
> >> easily bisect, though, as I don't boot this machine too often.
> > This looks like a bug and should definitely get fixed. There should=
 be
> > no RPF issue. May I have a look at your /proc/net/ipv6_route?
>=20
> It started again, so now I could capture what you asked for:
>=20
> pannekake:~> cat /proc/net/ipv6_route=20
> 2001067c00a400037c4d9ae8ab73230f 80 00000000000000000000000000000000 =
00 fe80000000000000023048fffe555743 00000000 00000001 00000137 01000023=
     eth0

This one does look like the most probable route which could have the pr=
oblem.
It has a RTF_MODIFIED flag indicating it received a pmtu update.

Did you take the snapshot while the tcp connection was hanging? We norm=
ally
take 2 references to the rt6_info while the tcp connection is running, =
this
oddly only has one (but got used a lot). But doing a judgement on the
reference count is imprecise.

If you write that this got worse in recent kernels I suspect commit

commit ca4c3fc24e293719fe7410c4e63da9b6bc633b83
Author: fan.du <fan.du@windriver.com>
Date:   Tue Jul 30 08:33:53 2013 +0800

    net: split rt_genid for ipv4 and ipv6


The commit itself is fine, we may have a problem in our dst check logic
or do not bump rt6_genid at some point? If this is the case I might hav=
e
an idea how to reproduce the problem.

Greetings,

  Hannes
