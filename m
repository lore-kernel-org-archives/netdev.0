From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [net-next,v2,7/9] net: use core MTU range checking in misc drivers
Date: Sat, 22 Oct 2016 09:17:18 +0200
Message-ID: <1589681.UIpgezyxdl@sven-edge>
References: <20161020175524.6184-8-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2432560.DpE8Nn2PIp"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>,
        Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Cliff Whickman <cpw-sJ/iWh9BUns@public.gmane.org>,
        Robin Holt <robinmholt-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jes Sorensen <jes-dtAfj9ClZIwnoBwkMbRkTB2eb7JE58TQ@public.gmane.org>,
        Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
        Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>,
        Antonio Quartulli <a@unstable.cc>,
        Sathya Prakash <sathya.prakash-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Chaitra P B <chaitra.basappa-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Suganath Prabu Subramani
        <suganath-prabu.subramani-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        MPT-FusionLinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Arvid Brodin <arvid.brodin-SVm98a2vdck@public.gmane.org>,
        Remi Denis-Courmont <courmisch-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Jarod Wilson <jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161020175524.6184-8-jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart2432560.DpE8Nn2PIp
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Donnerstag, 20. Oktober 2016 13:55:22 CEST Jarod Wilson wrote:
[...]
> batman-adv:
> - set max_mtu
> - remove batadv_interface_change_mtu
> - initialization is a little async, not 100% certain that max_mtu is set
>   in the optimal place, don't have hardware to test with

batman-adv is creating a virtual interface - so there are no
hardware requirements (ok, ethernet compatible hardware - even
when only virtual/emulated).

[...]
> diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
> index 49e16b6..112679d 100644
> --- a/net/batman-adv/soft-interface.c
> +++ b/net/batman-adv/soft-interface.c
> @@ -158,17 +158,6 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
>  	return 0;
>  }
>  
> -static int batadv_interface_change_mtu(struct net_device *dev, int new_mtu)
> -{
> -	/* check ranges */
> -	if ((new_mtu < 68) || (new_mtu > batadv_hardif_min_mtu(dev)))
> -		return -EINVAL;
> -
> -	dev->mtu = new_mtu;
> -
> -	return 0;
> -}
> -
>  /**
>   * batadv_interface_set_rx_mode - set the rx mode of a device
>   * @dev: registered network device to modify
> @@ -920,7 +909,6 @@ static const struct net_device_ops batadv_netdev_ops = {
>  	.ndo_vlan_rx_add_vid = batadv_interface_add_vid,
>  	.ndo_vlan_rx_kill_vid = batadv_interface_kill_vid,
>  	.ndo_set_mac_address = batadv_interface_set_mac_addr,
> -	.ndo_change_mtu = batadv_interface_change_mtu,
>  	.ndo_set_rx_mode = batadv_interface_set_rx_mode,
>  	.ndo_start_xmit = batadv_interface_tx,
>  	.ndo_validate_addr = eth_validate_addr,
> @@ -987,6 +975,7 @@ struct net_device *batadv_softif_create(struct net *net, const char *name)
>  	dev_net_set(soft_iface, net);
>  
>  	soft_iface->rtnl_link_ops = &batadv_link_ops;
> +	soft_iface->max_mtu = batadv_hardif_min_mtu(soft_iface);
>  
>  	ret = register_netdevice(soft_iface);
>  	if (ret < 0) {

This looks bogus to me. You are now setting max_mtu during initialization of
the virtual interface. But at this time no slave interfaces were added to the
master batman-adv interface. So the batadv_hardif_min_mtu will not return the
correct value here. Especially if you don't have fragmentation enabled.

So this change looks like a bug to me

Kind regards,
	Sven
--nextPart2432560.DpE8Nn2PIp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYCxJ+AAoJEF2HCgfBJntGtL8QAJLHOpTGiLhThIc/wONyxcjq
hLuSfiHJZFQZAZY1093MNgFAtw7v2P9gHiZ21OLLwDDCHIotPGtpopEEZaAW7niD
zyJPJLyVqJD/aP5hW5rZJJF0ZRNBdEd0yWEQValipVOkZwDrVIyvT/903kU3b1wF
aqwT/hLczmZGAGfdtCUM0gugJznWOF3TvvJ9cB/pKuCBNfQc6Pv/kaYGcNwp8L11
i+RSB9J1xv+BKBQtS020xczwzleyEt6KIeVFoHwdK23w/N5ISBt9SUgq/ZYh1Vl+
ZuOeMrHZjqwxvrDjqObyk2wt8uXRcXRrZj82nRtXZNsUf9xUxlDNBPdkYl3vDBS0
dHJDRLCfR7vt35uvPJPsnyxN+UxaQEqrtw/ehff4XLnGC6GRNip0+qHGV58hq2l3
+Cdg91RBaBY7xeNObBou5dGCe5guxjJEd3appNl//sxnL4joGX8OCWpAkPcAL/gs
zPNXgL0WB043mEIxDekKbC9dM5JYpwjD5vHS1wVR4WdW4oN2CF1V23KXxj6ip4fg
BtGnHn0NgmgAez06i6bjcRIsZcJJZFxzykqbWOYM8kW1+PgFfkica4VD7WPW5hxC
fURSk6sjRLNd5b32wBlZFgG6Pc0hExREGgnYo/Vh+1bI7cw2paZ1ryqqL0ueYuSL
5NwFF+L6gSS5IMq+OkbR
=k26u
-----END PGP SIGNATURE-----

--nextPart2432560.DpE8Nn2PIp--

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
