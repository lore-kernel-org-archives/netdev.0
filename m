From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: DQL and TCQ_F_CAN_BYPASS destroy performance under
 virtualizaiton (Was: "Re: net_sched strange in 4.11")
Date: Tue, 9 May 2017 11:11:09 -0400
Message-ID: <20170509151109.GH16825@stefanha-x1.localdomain>
References: <66c5c2d3-65df-8506-6934-5628e709e229@cambridgegreys.com>
 <27ae4e1c-7c6c-14c2-f3a4-9d0b1265d034@cambridgegreys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="h3LYUU6HlUDSAOzy"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>, jasowang@redhat.com
To: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22578 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751304AbdEIPLN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 11:11:13 -0400
Content-Disposition: inline
In-Reply-To: <27ae4e1c-7c6c-14c2-f3a4-9d0b1265d034@cambridgegreys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--h3LYUU6HlUDSAOzy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 09, 2017 at 08:46:46AM +0100, Anton Ivanov wrote:
> I have figured it out. Two issues.
>=20
> 1) skb->xmit_more is hardly ever set under virtualization because the qdi=
sc
> is usually bypassed because of TCQ_F_CAN_BYPASS. Once TCQ_F_CAN_BYPASS is
> set a virtual NIC driver is not likely see skb->xmit_more (this answers my
> "how does this work at all" question).
>=20
> 2) If that flag is turned off (I patched sched_generic to turn it off in
> pfifo_fast while testing), DQL keeps xmit_more from being set. If the dri=
ver
> is not DQL enabled xmit_more is never ever set. If the driver is DQL enab=
led
> the queue is adjusted to ensure xmit_more stops happening within 10-15 xm=
it
> cycles.
>=20
> That is plain *wrong* for virtual NICs - virtio, emulated NICs, etc. Ther=
e,
> the BIG cost is telling the hypervisor that it needs to "kick" the packet=
s.
> The cost of putting them into the vNIC buffers is negligible. You want
> xmit_more to happen - it makes between 50% and 300% (depending on vNIC
> design) difference. If there is no xmit_more the vNIC will immediately
> "kick" the hypervisor and try to signal that  the packet needs to move
> straight away (as for example in virtio_net).
>=20
> In addition to that, the perceived line rate is proportional to this cost,
> so I am not sure that the current dql math holds. In fact, I think it does
> not - it is trying to adjust something which influences the perceived line
> rate.
>=20
> So - how do we turn BOTH bypass and DQL adjustment while under
> virtualization and set them to be "always qdisc" + "always xmit_more
> allowed"
>=20
> A.
>=20
> P.S. Cc-ing virtio maintainer

CCing Michael Tsirkin and Jason Wang, who are the core virtio and
virtio-net maintainers.  (I maintain the vsock driver - it's unrelated
to this discussion.)

>=20
> A.
>=20
>=20
> On 08/05/17 08:15, Anton Ivanov wrote:
> > Hi all,
> >=20
> > I was revising some of my old work for UML to prepare it for submission
> > and I noticed that skb->xmit_more does not seem to be set any more.
> >=20
> > I traced the issue as far as net/sched/sched_generic.c
> >=20
> > try_bulk_dequeue_skb() is never invoked (the drivers I am working on are
> > dql enabled so that is not the problem).
> >=20
> > More interestingly, if I put a breakpoint and debug output into
> > dequeue_skb() around line 147 - right before the bulk: tag that skb
> > there is always NULL. ???
> >=20
> > Similarly, debug in pfifo_fast_dequeue shows only NULLs being dequeued.
> > Again - ???
> >=20
> > First and foremost, I apologize for the silly question, but how can this
> > work at all? I see the skbs showing up at the driver level, why are
> > NULLs being returned at qdisc dequeue and where do the skbs at the
> > driver level come from?
> >=20
> > Second, where should I look to fix it?
> >=20
> > A.
> >=20
>=20
>=20
> --=20
> Anton R. Ivanov
>=20
> Cambridge Greys Limited, England company No 10273661
> http://www.cambridgegreys.com/
>=20

--h3LYUU6HlUDSAOzy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZEdwNAAoJEJykq7OBq3PIWkwIALNpT6+ZeHogI5FZniXXtzAz
Aicw+GY4fbqqYdm8l965IiSr6UJDj46cDvUHewsBWpfpS9PfvcpkBobg8KkHiEfw
WgxupnR1soeqVokGXbSUd84ZQGVsRVeLLzlMbZF3h2oaqDmZomjGl5JRwWfGGszF
pbtfeJvrA/pOjPydZqKWp9hYTwS4SKy+JIQ9+enXhQrAVMI0K4erJ2w+y/9sf+Wv
U3ZBMFGneOQgi4gSh5GuhMnzmQdWQrnEgYR8IiYn5XS8gz9RY5VQ/vhRc6xWYNcK
qKO3rJW/Sgck71+FUJHOAzpUXXil5BG5KlT2a5lZY2unzzIn/WkiKf+ZH0eBer0=
=W3zy
-----END PGP SIGNATURE-----

--h3LYUU6HlUDSAOzy--
