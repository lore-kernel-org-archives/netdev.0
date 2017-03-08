From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v3] {net,IB}/{rxe,usnic}: Utilize generic mac to eui32
 function
Date: Wed, 8 Mar 2017 09:40:41 +0200
Message-ID: <20170308074041.GW14379@mtr-leonro.local>
References: <1488915118-23331-1-git-send-email-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="562f9N4fbIs+fPrJ"
Cc: benve@cisco.com, dgoodell@cisco.com, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com, monis@mellanox.com,
        davem@davemloft.net, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:44124 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750707AbdCHHn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Mar 2017 02:43:26 -0500
Content-Disposition: inline
In-Reply-To: <1488915118-23331-1-git-send-email-yuval.shaia@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--562f9N4fbIs+fPrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 07, 2017 at 09:31:58PM +0200, Yuval Shaia wrote:
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
> v2 -> v3:
> 	* Add helper function to avoid re-setting eui[0] to default if
> 	  dev_id is used
> ---
>  drivers/infiniband/hw/usnic/usnic_common_util.h | 11 +++--------
>  drivers/infiniband/sw/rxe/rxe_net.c             | 11 ++---------
>  include/net/addrconf.h                          | 25 +++++++++++++++++++------
>  3 files changed, 24 insertions(+), 23 deletions(-)

Not promising statistics :)

>
> diff --git a/drivers/infiniband/hw/usnic/usnic_common_util.h b/drivers/infiniband/hw/usnic/usnic_common_util.h
> index b54986d..d91b035 100644
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
> +	addrconf_addr_eui48(&raw_gid[8], mac);
>  }
>
>  static inline void
> diff --git a/drivers/infiniband/sw/rxe/rxe_net.c b/drivers/infiniband/sw/rxe/rxe_net.c
> index d8610960..ab8ea23 100644
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

It is worth to drop this wrapper completely. The rxe_mac_to_eui64 is
called twice in the same file.

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
> +	addrconf_addr_eui48(dst, ndev->dev_addr);
>
>  	return eui64;
>  }
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index 17c6fd8..28274ed 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -103,12 +103,25 @@ int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
>  				 u32 addr_flags, bool sllao, bool tokenized,
>  				 __u32 valid_lft, u32 prefered_lft);
>
> +static inline void addrconf_addr_eui48_xor(u8 *eui, const char *const addr, bool xor)
> +{
> +	memcpy(eui, addr, 3);
> +	if (xor)
> +		eui[0] ^= 2;
> +	eui[3] = 0xFF;
> +	eui[4] = 0xFE;
> +	memcpy(eui + 5, addr + 3, 3);
> +}
> +
> +static inline void addrconf_addr_eui48(u8 *eui, const char *const addr)
> +{
> +	addrconf_addr_eui48_xor(eui, addr, true);

Just put your "eui[0] ^= 2" here and remove redundant "if (xor)".
> +}
> +
>  static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
>  {
>  	if (dev->addr_len != ETH_ALEN)
>  		return -1;
> -	memcpy(eui, dev->dev_addr, 3);
> -	memcpy(eui + 5, dev->dev_addr + 3, 3);
>
>  	/*
>  	 * The zSeries OSA network cards can be shared among various
> @@ -123,14 +136,14 @@ static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
>  	 * case.  Hence the resulting interface identifier has local
>  	 * scope according to RFC2373.
>  	 */
> +
> +	addrconf_addr_eui48_xor(eui, dev->dev_addr, !dev->dev_id);
> +
>  	if (dev->dev_id) {
>  		eui[3] = (dev->dev_id >> 8) & 0xFF;
>  		eui[4] = dev->dev_id & 0xFF;
> -	} else {
> -		eui[3] = 0xFF;
> -		eui[4] = 0xFE;
> -		eui[0] ^= 2;

Leave this line.
Thanks

>  	}
> +
>  	return 0;
>  }
>
> --
> 2.7.4
>

--562f9N4fbIs+fPrJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAli/tXgACgkQ5GN7iDZy
WKcATg//XBs/9RdP7P/GvQsmsnne651UI4vROPpkw+YQI0xlm5O5VYH5z/N8s7+2
e/qOzMtuT4QMtqMYlMku/BgcWNclsebqaWsfZZZjEDStd50ZEmDF03shM/tMlDrN
5O8a9PxKT2TWmmE45262JIhDt/FrScJmDWH9TgYve8qH8BgYDq7CvRBdp5mctJnQ
hdKcS5m3GU5jTU4iSaXk4aUCCTyR6d1pz3fuywSRJCHbE8u6XpSChSA1tLi/iBMZ
7U+0zvwXQo0KYbp1PVvr8GyST49+H+xLSVyXje5I8c88WE6ksiwCqlgox800sXpF
bO35iR2/eP6UP5IscE+5vzJrO0kFaZw/DKZesZoFCa86QoGhihO6VaSBtnUi5Yu3
xlfv7waa6c8bQuoR+GlWIKundsfFoa41Ts647NwO9uGxC0iniWv3o7dXbAv/pDcQ
G7jG/dVLeyk9dGNP/hwafRNlmdd85BawJmsvl9nhrdsojswCZuL5PnIhRGeQltP7
iq7fTvjpjUKXyE+/p6e0Q5BWWmCR4pXpfDvDL/siBSFasngJeHrFYfnmjKJADi7m
woe8lcYSwDowLD7hblOHPVb1m7fCO9h1H9T4aLwv+L0JUc10u5NbeLD8YH5erfUN
7x8pIo7b3LblfMWhTNTtO+81ithlCE255RF5BvwbeBR2Rvw999o=
=ukIE
-----END PGP SIGNATURE-----

--562f9N4fbIs+fPrJ--
