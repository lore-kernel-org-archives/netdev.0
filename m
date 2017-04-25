From: Benjamin Poirier <bpoirier@suse.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return uninitialized
 stats
Date: Tue, 25 Apr 2017 10:54:33 -0700
Message-ID: <20170425175433.ykc6ilm6uo7e6my2@f1.synalogic.ca>
References: <20170421212012.25950-1-bpoirier@suse.com>
 <630A6B92B7EDEB45A87E20D3D286660171182EED@hasmsx109.ger.corp.intel.com>
 <caef8d69-9e47-bbcc-0758-e5900e1cb291@intel.com>
 <20170424191026.wpnpyhdaurfjixl7@f1.synalogic.ca>
 <309B89C4C689E141A5FF6A0C5FB2118B8C5EF4F7@ORSMSX101.amr.corp.intel.com>
 <1493111272.68612.2.camel@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="z2mi25bvoz5l6nek"
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
        "Neftin, Sasha" <sasha.neftin@intel.com>,
        David S Miller <davem@davemloft.net>,
        stephen@networkplumber.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Stefan Priebe <s.priebe@profihost.ag>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39887 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1946907AbdDYRyk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 13:54:40 -0400
Content-Disposition: inline
In-Reply-To: <1493111272.68612.2.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--z2mi25bvoz5l6nek
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2017/04/25 02:07, Jeff Kirsher wrote:
[...]
> > >=20
> > > I don't see any memset in e1000e_get_stats64(). What kernel version
> > > are
> > > you looking at?
> >=20
> > The call to memset was removed from the upstream kernel with:
> > -------------------------------------------------------------------
> > -----------------
> > commit 5944701df90d9577658e2354cc27c4ceaeca30fe
> > Author: stephen hemminger <stephen@networkplumber.org>
> > Date:=A0=A0 Fri Jan 6 19:12:53 2017 -0800
> >=20
> > =A0=A0=A0 net: remove useless memset's in drivers get_stats64
> >=20
> > =A0=A0=A0 In dev_get_stats() the statistic structure storage has already
> > been
> > =A0=A0=A0 zeroed. Therefore network drivers do not need to call memset()
> > again.
> > ...
> > < changes to other drivers snipped out >
> > ...
> > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> > b/drivers/net/ethernet/int
> > index 723025b..79651eb 100644
> > --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> > +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> > @@ -5925,7 +5925,6 @@ void e1000e_get_stats64(struct net_device
> > *netdev,
> > =A0{
> > =A0=A0=A0=A0=A0=A0=A0 struct e1000_adapter *adapter =3D netdev_priv(net=
dev);
> >=20
> > -=A0=A0=A0=A0=A0=A0 memset(stats, 0, sizeof(struct rtnl_link_stats64));
> > =A0=A0=A0=A0=A0=A0=A0 spin_lock(&adapter->stats64_lock);
> > =A0=A0=A0=A0=A0=A0=A0 e1000e_update_stats(adapter);
> > =A0=A0=A0=A0=A0=A0=A0 /* Fill out the OS statistics structure */
> > -------------------------------------------------------------------
> > -----------------
> >=20
> > This also is where the bad counters start to show up for e1000e for
> > my test systems.=A0 From this driver on I see (very) large values for
> > tx_dropped, rx_over_errors and tx_fifo_errors on driver load (even
> > before bringing the interface up.=A0 It seems the memset is not so
> > useless for this driver after all.=A0 Would simply reverting the e1000e
> > portion of this patch resolve the issue?
>=20
> Looks like Aaron beat me to the punch on pointing out that we had this
> very code in there before.  It appears that Stephen's
> assertion/assumption was incorrect about the stats structure being
> zero'd out, which is why we are seeing the issue.
>=20
> I have no issue reverting Stephen's earlier patch, or do we want to
> pursue why the stats structure is not zero'd out and resolve that
> instead.  Either way, just want to make sure we are all on the same
> page as to the right solution so that we do not end up repeating this
> in the future.

If you revert the e1000e part of 5944701df90d ("net: remove useless
memset's in drivers get_stats64", v4.11-rc1) it will fix the issue with
ethtool but memset will be done twice for code paths that call
dev_get_stats() (sysfs, rtnl, ...). Not a big deal but this is not a
problem in the approach I initially suggested. Alternatively, we could
put a memset in e1000_get_ethtool_stats().

--z2mi25bvoz5l6nek
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkvpDtefvZykbqQVOaJBbS33YWS0FAlj/jVQACgkQaJBbS33Y
WS2FCw//YYDGcojIhTLTBCwB1f3gUyotrtdaVgJj/bX8CNFy7H0VgKjJIeAGKBDs
9vFLM3pZ87JHx1fRDT7JTI/M8Ut9aa34ibzJLKoN/kELUnga/p8PUu6TdGWDXDxl
JJhIn3f4hao0F90bmj58j7fR1St2VlY13/DGCTWeI8RPzZT0gsZYW7bujGppKB0s
ozPvOVozTMBQ56ukT0HvP7fiLUbLNC5l5GVTCo1ZxRjbpYm0lgLmzWJQ+QdH6CbP
we5inZTcmvKSX2SNBnKzLasLVRQWZcnSNurKpD7sTeF5e0cRQwg+bVeJZQfGojTF
6RQ0dPZqM5UpyY8SKtrJn9FJgBgaZHKLz1qK19PLyOME7sXcE59XlfgffaBplMes
JaYvImpu8qtMGD/kV/6G8OSSZ9EX8TCDlWkJJlpAFULpD3Ht1ox6pEtgvx7uzgD5
V7au6yW6byrT2acnDjhLs/JBNFYNiuRz+u/eClfq9amSST3zlm2jB72YopmgXC51
eDdzzS5c3Yq6DmdBfqkyeqF243zOEIAr3nee5qBC7128+D5zqOgy7HZ+dhTYRxwD
TrgP7QZyKXni24fdOtJjBH2AkPTKybsuEmPN3nSg+WjG5Wo296RJBJd+PqHhx+BV
qoTwpYfLrRAi90iLrmpa26IMOwZvysdhfrm4OaJaIx1BwuoTKvw=
=+2+n
-----END PGP SIGNATURE-----

--z2mi25bvoz5l6nek--
