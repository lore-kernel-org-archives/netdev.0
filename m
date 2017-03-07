From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v2] {net,IB}/{rxe,usnic}: Utilize generic mac to eui32
 function
Date: Tue, 7 Mar 2017 16:27:11 +0200
Message-ID: <20170307142711.GS14379@mtr-leonro.local>
References: <1488826446-4173-1-git-send-email-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="fjEAjMKpll6GDq3U"
Cc: benve@cisco.com, dgoodell@cisco.com, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com, monis@mellanox.com,
        davem@davemloft.net, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:35474 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932531AbdCGPFd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 10:05:33 -0500
Content-Disposition: inline
In-Reply-To: <1488826446-4173-1-git-send-email-yuval.shaia@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--fjEAjMKpll6GDq3U
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 06, 2017 at 08:54:06PM +0200, Yuval Shaia wrote:
> This logic seems to be duplicated in (at least) three separate files.
> Move it to one place so code can be re-use.
>
> Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
> ---
> v0 -> v1:
> 	* Add missing #include
> 	* Rename to genaddrconf_ifid_eui48
> v1 -> v2:
> 	* Reset eui[0] to default if dev_id is used
> ---
>  drivers/infiniband/hw/usnic/usnic_common_util.h | 11 +++--------
>  drivers/infiniband/sw/rxe/rxe_net.c             | 11 ++---------
>  include/net/addrconf.h                          | 19 +++++++++++++------
>  3 files changed, 18 insertions(+), 23 deletions(-)
>
> diff --git a/drivers/infiniband/hw/usnic/usnic_common_util.h b/drivers/infiniband/hw/usnic/usnic_common_util.h
> index b54986d..09871da 100644
> --- a/drivers/infiniband/hw/usnic/usnic_common_util.h
> +++ b/drivers/infiniband/hw/usnic/usnic_common_util.h
> @@ -34,6 +34,8 @@
>  #ifndef USNIC_CMN_UTIL_H
>  #define USNIC_CMN_UTIL_H
>
> +#include <net/addrconf.h>
> +
>  static inline void
>  usnic_mac_to_gid(const char *const mac, char *raw_gid)
>  {
> @@ -57,14 +59,7 @@ usnic_mac_ip_to_gid(const char *const mac, const __be32 inaddr, char *raw_gid)
>  	raw_gid[1] = 0x80;
>  	memset(&raw_gid[2], 0, 2);
>  	memcpy(&raw_gid[4], &inaddr, 4);
> -	raw_gid[8] = mac[0]^2;
> -	raw_gid[9] = mac[1];
> -	raw_gid[10] = mac[2];
> -	raw_gid[11] = 0xff;
> -	raw_gid[12] = 0xfe;
> -	raw_gid[13] = mac[3];
> -	raw_gid[14] = mac[4];
> -	raw_gid[15] = mac[5];
> +	genaddrconf_ifid_eui48(&raw_gid[8], mac);
>  }
>
>  static inline void
> diff --git a/drivers/infiniband/sw/rxe/rxe_net.c b/drivers/infiniband/sw/rxe/rxe_net.c
> index d8610960..90285c8 100644
> --- a/drivers/infiniband/sw/rxe/rxe_net.c
> +++ b/drivers/infiniband/sw/rxe/rxe_net.c
> @@ -38,6 +38,7 @@
>  #include <linux/if_vlan.h>
>  #include <net/udp_tunnel.h>
>  #include <net/sch_generic.h>
> +#include <net/addrconf.h>
>  #include <linux/netfilter.h>
>  #include <rdma/ib_addr.h>
>
> @@ -86,18 +87,10 @@ struct rxe_recv_sockets recv_sockets;
>
>  static __be64 rxe_mac_to_eui64(struct net_device *ndev)
>  {
> -	unsigned char *mac_addr = ndev->dev_addr;
>  	__be64 eui64;
>  	unsigned char *dst = (unsigned char *)&eui64;
>
> -	dst[0] = mac_addr[0] ^ 2;
> -	dst[1] = mac_addr[1];
> -	dst[2] = mac_addr[2];
> -	dst[3] = 0xff;
> -	dst[4] = 0xfe;
> -	dst[5] = mac_addr[3];
> -	dst[6] = mac_addr[4];
> -	dst[7] = mac_addr[5];
> +	genaddrconf_ifid_eui48(dst, ndev->dev_addr);
>
>  	return eui64;
>  }
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index 17c6fd8..cdfa73f 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -103,12 +103,21 @@ int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
>  				 u32 addr_flags, bool sllao, bool tokenized,
>  				 __u32 valid_lft, u32 prefered_lft);
>
> +static inline void genaddrconf_ifid_eui48(u8 *eui, const char *const addr)
> +{
> +	memcpy(eui, addr, 3);
> +	eui[0] ^= 2;
> +	eui[3] = 0xFF;
> +	eui[4] = 0xFE;
> +	memcpy(eui + 5, addr + 3, 3);
> +}
> +
>  static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
>  {
>  	if (dev->addr_len != ETH_ALEN)
>  		return -1;
> -	memcpy(eui, dev->dev_addr, 3);
> -	memcpy(eui + 5, dev->dev_addr + 3, 3);
> +
> +	genaddrconf_ifid_eui48(eui, dev->dev_addr);
>
>  	/*
>  	 * The zSeries OSA network cards can be shared among various
> @@ -124,13 +133,11 @@ static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
>  	 * scope according to RFC2373.
>  	 */
>  	if (dev->dev_id) {
> +		eui[0] = dev->dev_addr[0];
>  		eui[3] = (dev->dev_id >> 8) & 0xFF;
>  		eui[4] = dev->dev_id & 0xFF;
> -	} else {
> -		eui[3] = 0xFF;
> -		eui[4] = 0xFE;
> -		eui[0] ^= 2;
>  	}
> +
>  	return 0;
>  }

Technically, the code is correct now, but it doesn't look right
to set the value and restore it right after that.

Thanks

>
> --
> 2.7.4
>

--fjEAjMKpll6GDq3U
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAli+wz8ACgkQ5GN7iDZy
WKfFrg//TkGqt+3KWjlXupQzNyVLtWvU5P/xDvE7M/60LnSwsMy3rRjX9/RA9Dsb
xtgH8uHhicYhBDl6M7ZkGxjUMeHj03WLa6BSn93RMga7tF0wvviCPr9cfWHP+nCd
nCMAizzum2GsNMAGb6n9fOeMS2DIxcjgDXQDsaRFOsdsyE01JFXVfM9EQPJadAt6
UG64JIQ4obIDz0StUC2KaIJ96fhwPDE04dk6eFrgfcTHVXZDX/Y9mGzbUNaoIQ8Z
0vFhZx7/FjBYTfGMuN7TweFKtt/PFJuidJM0toaQlL4YNrlsLqKhS9bRi9IIPvwt
ZS8NWKq5O1gGk8pkxBK/ExX1JBCo4AMky1XzIyw39xicFaG7jKEOO2dOldB5lMTg
zVBMUUSkBmx7nJqkBXrYI0n8GwpoGg4mzAalTkVJg9tZqPBUx4TAr5Omqthw+xO3
VvHxvTwPtn1jpnc/rr8Jgq9m9eutneqrDogTXHvDGRpR6PPiONOOu1XgbbiJ/sNx
4ZWyK60nISF3X+9Nw55PckDqrVAYnMxbK5swxKV8EbJwgR8DqJx52qPIKyt9BPMD
HsDwWoAptFxknn4DThLOi6gh6Uy0a6eFLwBKQJQfqwEG1htKmCWRHr9mDYNaIuLI
Asb3GRtZ9f+p3cDTHrLOgS5JnaeexJ2jXVeS89mkkPwGD1+JBpk=
=Z8r5
-----END PGP SIGNATURE-----

--fjEAjMKpll6GDq3U--
