From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/9] net: dsa: Allow configuration of CPU & DSA
 port speeds/duplex
Date: Sun, 23 Aug 2015 11:38:56 -0700
Message-ID: <55DA1340.9080604@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36684 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbbHWSi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:38:58 -0400
Received: by obkg7 with SMTP id g7so96107364obk.3
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:38:58 -0700 (PDT)
In-Reply-To: <1440323220-20438-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 02:46, Andrew Lunn a =C3=A9crit :
> By default, DSA and CPU ports are configured to the maximum speed the
> switch supports. However there can be use cases where the peer device=
s
> port is slower. Allow a fixed-link property to be used with the DSA
> and CPU port in the device tree, and use this information to configur=
e
> the port.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  net/dsa/dsa.c | 37 +++++++++++++++++++++++++++++++++++++
>  1 file changed, 37 insertions(+)
>=20
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 053eb2b8e682..afff17341b73 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -176,6 +176,35 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
>  #endif /* CONFIG_NET_DSA_HWMON */
> =20
>  /* basic switch operations *****************************************=
*********/
> +static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_devic=
e *master)
> +{
> +	struct dsa_chip_data *cd =3D ds->pd;
> +	struct device_node *port_dn;
> +	struct phy_device *phydev;
> +	int ret, port;
> +
> +	for (port =3D 0; port < DSA_MAX_PORTS; port++) {
> +		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
> +			continue;
> +
> +		port_dn =3D cd->port_dn[port];
> +		if (of_phy_is_fixed_link(port_dn)) {
> +			ret =3D of_phy_register_fixed_link(port_dn);
> +			if (ret) {
> +				netdev_err(master,
> +					   "failed to register fixed PHY\n");
> +				return ret;
> +			}
> +			phydev =3D of_phy_find_device(port_dn);
> +			genphy_config_init(phydev);
> +			genphy_read_status(phydev);
> +			if (ds->drv->adjust_link)
> +				ds->drv->adjust_link(ds, port, phydev);

This kind of hack here because what you really need is just the link
parameters, but you cannot obtain such information without first
configuring the PHY up to a certain point in genphy_config_init(), and
then have genphy_read_status() copy these values in your phydev structu=
re.

Maybe we should really consider something like this after all:

https://lkml.org/lkml/2015/8/5/490

Or maybe, we should really introduce this "cpu" network device after al=
l
with a dropping xmit function, such that we get ethtool counters to wor=
k
on it, and we can also attach it to a PHY device to configure link
parameters?
--=20
=46lorian
