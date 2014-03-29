From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Proper suspend/resume flow
Date: Sat, 29 Mar 2014 16:37:26 +0000
Message-ID: <1396111046.2898.88.camel@deadeye.wl.decadent.org.uk>
References: <20140326115828.GZ7528@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Vf9qYLMeA3FZl8lOnb8t"
Cc: netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60721 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751805AbaC2Qhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 12:37:38 -0400
In-Reply-To: <20140326115828.GZ7528@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Vf9qYLMeA3FZl8lOnb8t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-26 at 11:58 +0000, Russell King - ARM Linux wrote:
> I've been looking at the Freescale FEC driver recently, and I've noticed
> that it's suspend path looks like this:
>=20
>         if (netif_running(ndev)) {
>                 netif_device_detach(ndev);
>                 fec_stop(ndev);
>         }
>=20
> I believe this to be unsafe, because if the device is active, then we may
> have packets in the transmit ring.  It may be possible for the ring to be
> cleaned between netif_device_detach() and fec_stop(), resulting in a call
> to netif_wake_queue(), which doesn't seem to take account of whether the
> device has been detached.
>
> I wondered if this was just limited to the freescale driver, and I found
> a similar pattern in e1000e - __e1000e_shutdown() calls netif_device_deta=
ch()
> as the very first thing, before doing anything else.  This seems to be a
> common pattern.  8139cp.c does this, the second call seems to be rather
> redundant:
>=20
>         netif_device_detach (dev);
>         netif_stop_queue (dev);
>=20
> Tulip on the other hand shuts the hardware down and cleans the transmit
> ring first before calling netif_device_detach(), thus ensuring that there
> won't be any transmit completions before this call.  It doesn't stop the
> queue before this, so presumably in a SMP environment, it is possible for
> packets to get queued after the transmit ring has been cleaned.
>=20
> So, what is the correct approach to suspending a net device?  When should
> netif_device_detach() be called?
[...]

My advice here is based on Solarflare's extensive stress-testing of the
sfc driver control path and the race conditions it uncovered.  It did
not cover suspend/resume, but it does cover MTU and ring size changes
which involve the same sort of stop/start while the device is still
marked as running.

- Given the way the watchdog works, I think netif_device_detach() must
be called first if you are going to stop TX queues in a control
operation other than ndo_stop (commits e4abce853849, 29c69a488264).

- The driver must check netif_device_present() before calling
netif_wake_queue().  Perhaps netif_wake_queue() itself should check
that, if many drivers need to do it.

- Calls to netif_device_detach() may need to be synchronised with the TX
scheduler (commits c2f3b8e3a44b, 35205b211c8d).  To support this, the
function efx_device_detach_sync() maybe should be turned into a general
netif_device_detach_sync() (and then possibly needs to disable IRQs).

Ben.

--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949

--=-Vf9qYLMeA3FZl8lOnb8t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzb2xue/yOyVhhEJAQrO6BAAvTDwAJKJYkEBmobBsEFn8pL1dM8saCgb
+QoJbYPKnG6ryl/zGMeeUF+D+3toNkLmMsP3SFqHeVtmTtXR0jkL/jlduFAamADD
MW3tbHSngm+u2xwYgGf7blJ38PXmNbYbzwkWvNrGZTD4wh+LIDLsXfvh+jO+2HaR
4d7wSBvjTL8QtblTVo2FiETy3Q/NZEtL50sI+ChRkJ7O2PaMf/5T5QpO6vt7KQJ1
YuLlitslNEHNMCNbVn1lDSp/gU2+fSd8lIq5Vz2gvR0ppCJSzaNVzansZ35X5IA1
Ll961RIJMSED5tTKrLDlAfG0r4+/o/Q88mFFaLq5uL1kWYG9Wp1IoanzRJUeXy1Z
miNk6NrdgA7g5Qyuy4zfh//Fq4Dn2tdxHFfNMijaDjm2EbiH5fCPcd/Dl7jKBell
PJRfGGLVswOvae1tquNKXKJ62OKfPv4jNE571sqJVHgaBPCsgHYb2DgLBFdvrclA
oG4M570eJfBXNrVs8ZuyJKyy/H+XttKXi3XnXUiH7siNvqYIv2d85lLslVIIa/om
ySlOegCUufS4uj0l/QaHJ3VkFGbEmdAOIGc1pDzWWr74zQ+ke+H2MfgF0bz96zUW
GFUs/bIhdQrUr0BkbORda2Y95HuCyM2Ai+Xo7JWV01vTJinKdZxdEBXZ/GJKpbTB
Ua1nw1jjxpM=
=kG2D
-----END PGP SIGNATURE-----

--=-Vf9qYLMeA3FZl8lOnb8t--
