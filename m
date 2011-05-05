From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Thu, 5 May 2011 11:44:28 +0300
Message-ID: <20110505084428.GB17647@redhat.com>
References: <20110504181813.GA17547@redhat.com>
 <20110504223415.GA14819@gondor.apana.org.au>
 <20110504232854.GA11687@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752925Ab1EEIou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 04:44:50 -0400
Content-Disposition: inline
In-Reply-To: <20110504232854.GA11687@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2011 at 01:28:54AM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> On Thu, May 05, 2011 at 08:34:15AM +1000, Herbert Xu wrote:
> > On Wed, May 04, 2011 at 09:18:14PM +0300, Michael S. Tsirkin wrote:
> > > BTW, I just noticed that net-next spits out
> > > many of the following when I run any VMs:
> > >=20
> > > tap0: Dropping NETIF_F_SG since no checksum feature.
> > > tap0: Dropping NETIF_F_GSO since no SG feature.
> > > tap0: Features changed: 0x401b4849 -> 0x40004040
> > > device msttap0 entered promiscuous mode
> > > br0: Dropping NETIF_F_GSO since no SG feature.
> > > br0: port 1(msttap0) entering forwarding state
> > > br0: port 1(msttap0) entering forwarding state
> > > tap0: Features changed: 0x40004040 -> 0x40024849
> > > tap0: Dropping NETIF_F_SG since no checksum feature.
> > > tap0: Dropping NETIF_F_GSO since no SG feature.
> > > tap0: Features changed: 0x40024849 -> 0x40004040
> > > br0: Dropping NETIF_F_GSO since no SG feature.
> > > tap0: Dropping NETIF_F_SG since no checksum feature.
> > > tap0: Dropping NETIF_F_GSO since no SG feature.
> > > tap0: Dropping NETIF_F_SG since no checksum feature.
> > > tap0: Dropping NETIF_F_GSO since no SG feature.
> > > tap0: Dropping NETIF_F_SG since no checksum feature.
> > > tap0: Dropping NETIF_F_GSO since no SG feature.
> > > tap0: Dropping NETIF_F_SG since no checksum feature.
> > > tap0: Dropping NETIF_F_GSO since no SG feature.
> > > tap0: Features changed: 0x40004040 -> 0x401b4849
> > > tap0: Dropping NETIF_F_SG since no checksum feature.
> > > tap0: Dropping NETIF_F_GSO since no SG feature.
> > > tap0: Features changed: 0x401b4849 -> 0x40004040
> > > br0: Dropping NETIF_F_GSO since no SG feature.
> > >=20
> > > My problem is not primarily with warnings:
> > >=20
> > > will that linearize all packets and disable GSO
> > > for tap and bridge? If yes it can't be good
> > > for performance...
> > I think so.  So the question is why is checksum off?
>=20
> Whatever application is creating the tap0 device is not calling
> ioctl(TUNSETOFFLOAD) with TUN_F_CSUM set. This is userspace bug/featu=
re
> exposed by recent changes to netdev features handling.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

No, I think it's not a bug in userspace. Here is what it does:

    /* Check if our kernel supports TUNSETOFFLOAD */
    if (ioctl(fd, TUNSETOFFLOAD, 0) !=3D 0 && errno =3D=3D EINVAL) {
        return;
    }

    if (csum) {
        offload |=3D TUN_F_CSUM;
        if (tso4)
            offload |=3D TUN_F_TSO4;
        if (tso6)
            offload |=3D TUN_F_TSO6;
        if ((tso4 || tso6) && ecn)
            offload |=3D TUN_F_TSO_ECN;
        if (ufo)
            offload |=3D TUN_F_UFO;
    }

    if (ioctl(fd, TUNSETOFFLOAD, offload) !=3D 0) {
        offload &=3D ~TUN_F_UFO;
        if (ioctl(fd, TUNSETOFFLOAD, offload) !=3D 0) {
            fprintf(stderr, "TUNSETOFFLOAD ioctl() failed: %s\n",
                    strerror(errno));
        }
    }

The first call is just to check that ioctl works.
When checking for ioctl in this way, userspace clears checksum.
This will clear SG and thus GSO; later userspace enables checksum.
checksum is on but SG is by now disabled so GSO gets cleared again too.


It's also likely a problem that
userspace can trigger warnings in log for what used to be
a legal way to check for ioctl and/or disable checksum offloading,
but that is more minor.

--=20
MST
