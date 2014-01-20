From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/2] net/cxgb4: Don't retrieve stats during recovery
Date: Mon, 20 Jan 2014 03:49:11 +0000
Message-ID: <1390189751.3651.48.camel@deadeye.wl.decadent.org.uk>
References: <1390187144-15495-1-git-send-email-shangw@linux.vnet.ibm.com>
	 <1390187144-15495-2-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-kNjeN/Ljm/RIboug05rO"
Cc: netdev@vger.kernel.org, dm@chelsio.com
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:32917 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752166AbaATDtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:49:24 -0500
In-Reply-To: <1390187144-15495-2-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kNjeN/Ljm/RIboug05rO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-20 at 11:05 +0800, Gavin Shan wrote:
> We possiblly retrieve the adapter's statistics during EEH recovery
> and that should be disallowed. Otherwise, it would possibly incur
> replicate EEH error and EEH recovery is going to fail eventually.
> The patch checks if the PCI device is off-line before statistic
> retrieval.
>=20
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   11 +++++++++++
>  1 file changed, 11 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/ne=
t/ethernet/chelsio/cxgb4/cxgb4_main.c
> index c8eafbf..b0e72fb 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -4288,6 +4288,17 @@ static struct rtnl_link_stats64 *cxgb_get_stats(st=
ruct net_device *dev,
>  	struct port_info *p =3D netdev_priv(dev);
>  	struct adapter *adapter =3D p->adapter;
> =20
> +	/*
> +	 * We possibly retrieve the statistics while the PCI
> +	 * device is off-line. That would cause the recovery
> +	 * on off-lined PCI device going to fail. So it's
> +	 * reasonable to block it during the recovery period.
> +	 */
> +	if (pci_channel_offline(adapter->pdev)) {
> +		memset(ns, 0, sizeof(*ns));
> +		return ns;
> +	}

The buffer is already zero-initialised so there's no need for this
memset().

>         spin_lock(&adapter->stats_lock);
>         t4_get_port_stats(adapter, p->tx_chan, &stats);
>         spin_unlock(&adapter->stats_lock);

Is there anything to stop this running just after pci_channel_offline()
becomes true?

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-kNjeN/Ljm/RIboug05rO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUtyct+e/yOyVhhEJAQo18BAAnuoT4k1aKU+nxbdK59Yxg3gZXmqXdWZb
bn5cSo1E1+K3JEldIRYgb/Egwbuxf08t5fl++1eGO9Yu4jcceYnaLpoGRRdSxoYd
6NvCM6+7F/qOq0TN2EG9PpQfvVIpKTFUe7t80fTmhu/eoBmUKMMOkYxY/XsZgwQp
ZmXiRalZ9YB2okXIrwM0QOc+GQdlVa2DNPE80hobF27tfWfQsPNF0X2Wh7CYXcb9
6BRa8gazzIViFXEMZphIdAoj39R7mnhYaWTVKfG5k0LIrKLRMWgNJZ1Fc5gqIN9J
OljKOnOJWwkV3RiX6FAEFG4q3q4K9oTnPlccbfxKwMr0waFycTojfHzJ/EWFadU4
dpiwKBBk1PG1VJF2e1jrZYa68A2exZRORG7Bi3MfMUwwP4cFrRQo5KVjASf8RX5a
/z3l5dV3xMGVPPhRU6V2AfMJD8O7HYNKNBINvEBcNj+oiZXQ0YrQPkhL8fZ9xVlY
cMOCyz+42wXD5uv/FK4HAfBUGtPP7Y1QNbiCy5j+I0Vd0RzMv4Z7zf0jloQOcIs8
BBPxUsUKU4u68HNi/nqqfGudKsfNscV3Gk3PkrFDseD3krN9pvvltuQ1khiO3NgQ
vRNJKW0NVn12C/1tZ78J6FkxkLmT44EKpsufpaKPJ7gT8m+XGJsNdrZYrfiSo7+V
g9PHXRalvWM=
=HB7a
-----END PGP SIGNATURE-----

--=-kNjeN/Ljm/RIboug05rO--
