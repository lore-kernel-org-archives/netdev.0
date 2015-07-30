From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()
Date: Thu, 30 Jul 2015 16:32:25 -0500
Message-ID: <20150730213225.GA11294@sbohrermbp13-local.rgmadvisors.com>
References: <CA++eYdtOendgSVix0aibj_Ykd=7td4ac3z9Zz1c_p67Xy3bWYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sbohrer@rgmadvisors.com, netdev <netdev@vger.kernel.org>,
	Yurij.Plotnikov@oktetlabs.ru, David Miller <davem@davemloft.net>,
	=?iso-8859-1?Q?St=E5le?= Kristoffersen <stalk@bridgetech.tv>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36243 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbbG3Vcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 17:32:31 -0400
Received: by oibn4 with SMTP id n4so28887509oib.3
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 14:32:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA++eYdtOendgSVix0aibj_Ykd=7td4ac3z9Zz1c_p67Xy3bWYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2015 at 10:26:08PM +0200, Kenneth Klette Jonassen wrote=
:
> Commit 6e54030 breaks the IP_MULTICAST_ALL socket option. There is
> already a check in ip_mc_sf_allow() that should do the filtering you
> claim to fix. Was it considered?
>
> Commit message:
> 421b3885bf6d56391297844f43fb7154a6396e12 "udp: ipv4: Add udp early
> demux" introduced a regression that allowed sockets bound to INADDR_A=
NY
> to receive packets from multicast groups that the socket had not join=
ed...
>=20
> man ip(7):
> IP_MULTICAST_ALL (since Linux 2.6.31)
> This option can be used to modify the delivery policy of
> multicast messages to sockets bound to the wildcard INADDR_ANY
> address.  The argument is a boolean integer (defaults to 1).
> If set to 1, the socket will receive messages from all the
> groups that have been joined globally on the whole system.
> Otherwise, it will deliver messages only from the groups that
> have been explicitly joined=E2=80=A6

Do you have an application or test case that is now broken after this
commit?  Or is this just a theoretical breakage based off of my commit
message?  If you have a simple example test case can you share it?
Also if this breaks your application but you don't have a test case
can you describe the breakage?  Is IP_MULTICAST_ALL 0 or 1?  Are you
not receiving packets or receiving packets you don't expect to
receive?

I admittedly haven't tried to create a test case yet, but looking over
the code I'm not sure how this could have broken IP_MULTICAST_ALL.
Commit 6e54030 added a call to ip_check_mc_rcu() which as far as I can
tell checks to see that a received multicast packet was a mc address
joined on that interface.  Without this check it is possible to
receive multicast packets for an address that hasn't been joined on
that machine at all.  Which was the bug I was fixing.

The ip_mc_sf_allow() check comes next, and is still there.  It should
continue to provide the behavior you quoted from the man page.  It
isn't/wasn't sufficient to use IP_MULTICAST_ALL as a fix for the
original bug because as I mentioned above you could receive packets
that nothing on the machine had joined.

--
Shawn
