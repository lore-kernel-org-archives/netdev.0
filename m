From: Tom Parkin <tparkin@katalix.com>
Subject: Re: [PATCH net] l2tp: fix race condition in l2tp_tunnel_delete
Date: Fri, 15 Sep 2017 10:42:59 +0100
Message-ID: <20170915094259.GA3209@jackdaw>
References: <f07e7ba88b9b4651900a888796e3f8816d06a8a8.1505396134.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Cc: netdev@vger.kernel.org, Guillaume Nault <g.nault@alphalink.fr>,
        Xin Long <lucien.xin@gmail.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.katalix.com ([82.103.140.233]:50509 "EHLO mail.katalix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750879AbdIOJti (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 05:49:38 -0400
Content-Disposition: inline
In-Reply-To: <f07e7ba88b9b4651900a888796e3f8816d06a8a8.1505396134.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 15, 2017 at 11:08:07AM +0200, Sabrina Dubroca wrote:
> The tunnel is currently removed from the list during destruction. This
> can lead to a double-free of the struct sock if we try to delete the tunn=
el
> twice fast enough.
>=20
> The first delete operation does a lookup (l2tp_tunnel_get), finds the
> tunnel, calls l2tp_tunnel_delete, which queues it for deletion by
> l2tp_tunnel_del_work.
>
> The second delete operation also finds the tunnel and calls
> l2tp_tunnel_delete. If the workqueue has already fired and started
> running l2tp_tunnel_del_work, then l2tp_tunnel_delete will queue the
> same tunnel a second time, and try to free the socket again.
>=20
> Add a dead flag and remove tunnel from its list earlier. Then we can
> remove the check of queue_work's result that was meant to prevent that
> race but doesn't.

How do we avoid leaving stale information on the tunnel list for
use-cases which don't delete tunnels using netlink?  For example the
L2TPv2 ppp/socket API depends on sk_destruct to clean up the kernel
context on socket destruction.  Similarly, userspace may just close
the tunnel socket without first making netlink calls to delete the
tunnel.

By moving the tunnel list removal from l2tp_tunnel_destruct to
l2tp_tunnel_delete I can't see how codepaths which don't involve
l2tp_tunnel_delete don't end up with a corrupted tunnel list.

Tom
--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZu6CjAAoJEJSMBmUKuovQgSMIAKhny7R9FEuB8wkeixYlaTPh
qFcnP9RPQVhZbR/l2w/20fXEM/RAxM/p9Jg8vxndXG9gHk4uk+5q93fGxqYE6fd+
i6p4xIL/rly9rV6V9fAlokYunhYziO54ueXLnDZH7p/EDnIy+MBSjZG6gHaH7QDA
k1XNCnA5lBbBqUcyQ7O1hHZ7Ktm0sOEIJeNJ7QQFQ6IKxekwy5bzxs9HDZ/wF3UT
qONoog4FxAYQ32zjvFtuEgKl16K8IlUULC5eZFqyyCO6wgC/sHdlmEhFb6XULA3P
R/cFxcIWg8D8J5D5HtdI+T2C0lqtWRbpNBGHxpk/cowHZHr+bUxzVOzXTskpxr4=
=fAra
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--
