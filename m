From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Tue, 9 Aug 2011 07:54:54 -0700
Message-ID: <20110809075454.5331dcac@nehalam.ftrdhcpuser.net>
References: <20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
	<CA+mtBx_bdCGvR+xBMq9px0vOV6a6kFn0wYyJH26+CdSPLtvgfw@mail.gmail.com>
	<20110808111917.4b2669de@nehalam.ftrdhcpuser.net>
	<20110809.004123.2080217558650594315.davem@davemloft.net>
	<1312877173.2371.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50840 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722Ab1HIOyp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 10:54:45 -0400
In-Reply-To: <1312877173.2371.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 09 Aug 2011 10:06:13 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 09 ao=FBt 2011 =E0 00:41 -0700, David Miller a =E9crit :
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Mon, 8 Aug 2011 11:19:17 -0700
> >=20
> > > On Mon, 8 Aug 2011 11:01:57 -0700
> > > Tom Herbert <therbert@google.com> wrote:
> > >=20
> > >> > Since transmit completion means calling dev_kfree_skb() why no=
t account
> > >> > there? You could add some info to netdev if necessary to get c=
ompile
> > >> > the statistics.
> > >> >
> > >> The algorithm depends on knowing the total number of packets com=
peted
> > >> in a single execution of transmit completion (epic based).  We o=
nly
> > >> want to recalculate the limits once per completion, which happen=
s when
> > >> the completion function is called.
> > >=20
> > > So just add some stats to netdev and count the number of dev_kfre=
e_skb
> > > calls and do your work at napi complete.
> >=20
> > No, I think what Tom's doing here is reasonable.
> >=20
> > First off, drivers have never been required to do specific things i=
f
> > they return success for ->ndo_start_xmit().  They can kfree_skb(skb=
)
> > and return NET_TX_SUCCESS, and that's fine.
> >=20
> > This mean we can't use ->ndo_start_xmit() return values to drive th=
e
> > BQL engine.
> >=20
> > So we simply have a way for the driver to say when it really does
> > queue up a packet, and that might be useful for other things.
> >=20
> > Second, you absolutely do not want to run the BQL engine on every
> > single dev_kfree_skb() call.  You want to batch it, and that's what
> > Tom's new interface does, and that is therefore quite reasonable
> > too.
> >=20
> > In fact, I think the best part about this revision of the BQL patch=
es
> > is the device driver interface. :-)
> >=20
>=20
> I agree, it permits a smooth transition to selected drivers, even som=
e
> non NAPI ones ;)
>=20
> In some stress situations, NAPI never completes, so it would also mea=
n
> adding a dql call in this case...

Ok. then we need to fix all NAPI drivers at once, and get more
drivers converted over to NAPI. It is really annoying how there
is just too much variation among network drivers.

