From: Noah Meyerhans <noahm@debian.org>
Subject: Re: Bug#625914: linux-image-2.6.38-2-amd64: bridging is not
	interacting well with multicast in 2.6.38-4
Date: Tue, 10 May 2011 11:05:40 -0700
Message-ID: <20110510180540.GI6397@morgul.net>
References: <20110506201234.6297.70279.reportbug@ip6-localhost> <1304995124.4065.157.camel@localhost> <20110510043833.GG6397@morgul.net> <1305031369.4065.259.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UKsZWh/ZtaJX4ozz"
Cc: 625914@bugs.debian.org, netdev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.morgul.net ([128.31.0.48]:52560 "EHLO minas.morgul.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499Ab1EJSFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 14:05:45 -0400
Content-Disposition: inline
In-Reply-To: <1305031369.4065.259.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UKsZWh/ZtaJX4ozz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 10, 2011 at 01:42:49PM +0100, Ben Hutchings wrote:
> > > This is pretty weird.  Debian version 2.6.38-3 has a few bridging
> > > changes from stable 2.6.38.3 and 2.6.38.4, but they don't look like t=
hey
> > > would cause this.
> >=20
> > I have apparently filed the bug against the wrong version of Debian's
> > kernel.  2.6.38-3 is not affected, and works as expected.  The change
> > was introduced in -4.  That may have been clear from the report itself,
> > but the report was filed against -3.  I've fixed that in the BTS.
>=20
> I gathered that, and then made the same mistake in writing the above!
> The version with the regression, 2.6.38-4, includes the changes from
> stable 2.6.38.3 and 2.6.38.4

With a little help from git bisect, I've tracked this regression down to
the following commit to the stable-2.6.38.y tree:

commit 5f1c356a3fadc0c19922d660da723b79bcc9aad7
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Mar 18 05:27:28 2011 +0000

    bridge: Reset IPCB when entering IP stack on NF_FORWARD
   =20
    [ Upstream commit 6b1e960fdbd75dcd9bcc3ba5ff8898ff1ad30b6e ]
   =20
    Whenever we enter the IP stack proper from bridge netfilter we
    need to ensure that the skb is in a form the IP stack expects
    it to be in.
   =20
    The entry point on NF_FORWARD did not meet the requirements of
    the IP stack, therefore leading to potential crashes/panics.
   =20
    This patch fixes the problem.
   =20
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Acked-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

The diff is
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4b5b66d..49d50ea 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -741,6 +741,9 @@ static unsigned int br_nf_forward_ip(unsigned int
hook, struct sk_buff *skb,
                nf_bridge->mask |=3D BRNF_PKT_TYPE;
        }
=20
+       if (br_parse_ip_options(skb))
+               return NF_DROP;
+
        /* The physdev module checks on this */
        nf_bridge->mask |=3D BRNF_BRIDGED;
        nf_bridge->physoutdev =3D skb->dev;

If I revert this change, network connectivity functions as expected for
the VMs on this host.

I don't know enough about this change or the problem it was supposed to
solve to be able to guess about what's going wrong.

noah


--UKsZWh/ZtaJX4ozz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFNyX5zYrVLjBFATsMRAmb/AJwNHxuXZFtWlm6PdQ2VrvwU1YyGVgCfdA+/
1IX2tmqcBDRQGGhkwY6KyzE=
=ThAF
-----END PGP SIGNATURE-----

--UKsZWh/ZtaJX4ozz--
