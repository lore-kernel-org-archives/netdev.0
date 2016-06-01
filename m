From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [RFC 2/3] vsockmon: Add vsockmon device
Date: Wed, 1 Jun 2016 14:15:54 -0700
Message-ID: <20160601211554.GG15594@stefanha-x1.localdomain>
References: <20160528162907.14809-1-ggarcia@deic.uab.cat>
 <20160528162907.14809-3-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MiFvc8Vo6wRSORdP"
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49908 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbcFAVQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 17:16:00 -0400
Content-Disposition: inline
In-Reply-To: <20160528162907.14809-3-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MiFvc8Vo6wRSORdP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, May 28, 2016 at 06:29:06PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> ---
>  drivers/net/Kconfig           |   8 ++
>  drivers/net/Makefile          |   1 +
>  drivers/net/vsockmon.c        | 171 ++++++++++++++++++++++++++++++++++++=
++++++
>  include/uapi/linux/Kbuild     |   1 +
>  include/uapi/linux/vsockmon.h |  37 +++++++++
>  5 files changed, 218 insertions(+)
>  create mode 100644 drivers/net/vsockmon.c
>  create mode 100644 include/uapi/linux/vsockmon.h
>=20
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 0c5415b..42c43b6 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -330,6 +330,14 @@ config NET_VRF
>  	  This option enables the support for mapping interfaces into VRF's. The
>  	  support enables VRF devices.
> =20
> +config VSOCKMON
> +    tristate "Virtual vsock monitoring device"
> +    depends on VHOST_VSOCK
> +    ---help---
> +     This option enables a monitoring net device for vsock sockets. It is
> +     mostly intended for developers or support to debug vsock issues. If
> +     unsure, say N.
> +
>  endif # NET_CORE
> =20
>  config SUNGEM_PHY
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 7336cbd..e2188d4 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -28,6 +28,7 @@ obj-$(CONFIG_GENEVE) +=3D geneve.o
>  obj-$(CONFIG_GTP) +=3D gtp.o
>  obj-$(CONFIG_NLMON) +=3D nlmon.o
>  obj-$(CONFIG_NET_VRF) +=3D vrf.o
> +obj-$(CONFIG_VSOCKMON) +=3D vsockmon.o
> =20
>  #
>  # Networking Drivers
> diff --git a/drivers/net/vsockmon.c b/drivers/net/vsockmon.c
> new file mode 100644
> index 0000000..becddc9
> --- /dev/null
> +++ b/drivers/net/vsockmon.c
> @@ -0,0 +1,171 @@
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/if_arp.h>
> +#include <net/rtnetlink.h>
> +#include <net/sock.h>
> +#include <net/af_vsock.h>
> +#include <uapi/linux/vsockmon.h>
> +
> +/* Virtio transport max packet size plus header */
> +#define DEFAULT_MTU 1024 * 64 + sizeof(struct af_vsockmon_hdr);
> +
> +struct pcpu_lstats {
> +	u64 rx_packets;
> +	u64 rx_bytes;
> +	struct u64_stats_sync syncp;
> +};
> +
> +static int vsockmon_dev_init(struct net_device *dev)
> +{
> +	dev->lstats =3D netdev_alloc_pcpu_stats(struct pcpu_lstats);
> +	return dev->lstats =3D=3D NULL ? -ENOMEM : 0;
> +}
> +
> +static void vsockmon_dev_uninit(struct net_device *dev)
> +{
> +	free_percpu(dev->lstats);
> +}
> +
> +struct vsockmon {
> +	struct vsock_tap vt;
> +};
> +
> +static int vsockmon_open(struct net_device *dev)
> +{
> +	struct vsockmon *vsockmon =3D netdev_priv(dev);
> +
> +	vsockmon->vt.dev =3D dev;
> +	vsockmon->vt.module =3D THIS_MODULE;
> +	return vsock_add_tap(&vsockmon->vt);
> +}
> +
> +static int vsockmon_close(struct net_device *dev) {
> +	struct vsockmon *vsockmon =3D netdev_priv(dev);
> +
> +	return vsock_remove_tap(&vsockmon->vt);
> +}
> +
> +static netdev_tx_t vsockmon_xmit(struct sk_buff *skb, struct net_device =
*dev)
> +{
> +	int len =3D skb->len;
> +	struct pcpu_lstats *stats =3D this_cpu_ptr(dev->lstats);
> +
> +	u64_stats_update_begin(&stats->syncp);
> +	stats->rx_bytes +=3D len;
> +	stats->rx_packets++;
> +	u64_stats_update_end(&stats->syncp);
> +
> +	dev_kfree_skb(skb);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static struct rtnl_link_stats64 *
> +vsockmon_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *s=
tats)
> +{
> +	int i;
> +	u64 bytes =3D 0, packets =3D 0;
> +
> +	for_each_possible_cpu(i) {
> +		const struct pcpu_lstats *vstats;
> +		u64 tbytes, tpackets;
> +		unsigned int start;
> +
> +		vstats =3D per_cpu_ptr(dev->lstats, i);
> +
> +		do {
> +			start =3D u64_stats_fetch_begin_irq(&vstats->syncp);
> +			tbytes =3D vstats->rx_bytes;
> +			tpackets =3D vstats->rx_packets;
> +		} while (u64_stats_fetch_retry_irq(&vstats->syncp, start));
> +
> +		packets +=3D tpackets;
> +		bytes +=3D tbytes;
> +	}
> +
> +	stats->rx_packets =3D packets;
> +	stats->tx_packets =3D 0;
> +
> +	stats->rx_bytes =3D bytes;
> +	stats->tx_bytes =3D 0;
> +
> +	return stats;
> +}
> +
> +static int vsockmon_is_valid_mtu(int new_mtu)
> +{
> +	return new_mtu >=3D (int) sizeof(struct af_vsockmon_hdr);
> +}
> +
> +static int vsockmon_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	if (!vsockmon_is_valid_mtu(new_mtu))
> +		return -EINVAL;
> +
> +	dev->mtu =3D new_mtu;
> +	return 0;
> +}

I wonder if the mtu serves any purpose.  What happens when you change it
=66rom the default value?

> +
> +static const struct net_device_ops vsockmon_ops =3D {
> +	.ndo_init =3D vsockmon_dev_init,
> +	.ndo_uninit =3D vsockmon_dev_uninit,
> +	.ndo_open =3D vsockmon_open,
> +	.ndo_stop =3D vsockmon_close,
> +	.ndo_start_xmit =3D vsockmon_xmit,
> +	.ndo_get_stats64 =3D vsockmon_get_stats64,
> +	.ndo_change_mtu =3D vsockmon_change_mtu,
> +};
> +
> +static u32 always_on(struct net_device *dev)
> +{
> +	return 1;
> +}
> +
> +static const struct ethtool_ops vsockmon_ethtool_ops =3D {
> +	.get_link =3D always_on,
> +};
> +
> +static void vsockmon_setup(struct net_device *dev)
> +{
> +	dev->type =3D ARPHRD_VSOCKMON;
> +	dev->priv_flags |=3D IFF_NO_QUEUE;
> +
> +	dev->netdev_ops	=3D &vsockmon_ops;
> +	dev->ethtool_ops =3D &vsockmon_ethtool_ops;
> +	dev->destructor	=3D free_netdev;
> +
> +	dev->features =3D NETIF_F_SG | NETIF_F_FRAGLIST |
> +			NETIF_F_HIGHDMA | NETIF_F_LLTX;
> +
> +	dev->flags =3D IFF_NOARP;
> +
> +	dev->mtu =3D DEFAULT_MTU;
> +}
> +
> +static struct rtnl_link_ops vsockmon_link_ops __read_mostly =3D {
> +	.kind			=3D "vsockmon",
> +	.priv_size		=3D sizeof(struct vsockmon),
> +	.setup			=3D vsockmon_setup,
> +};
> +
> +static __init int vsockmon_register(void)
> +{
> +	int ret =3D rtnl_link_register(&vsockmon_link_ops);
> +	if (!ret)
> +		vsock_init_tap();
> +
> +	return ret;
> +}
> +
> +static __exit void vsockmon_unregister(void)
> +{
> +	rtnl_link_unregister(&vsockmon_link_ops);
> +}
> +
> +module_init(vsockmon_register);
> +module_exit(vsockmon_unregister);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Gerard Garcia <ggarcia@deic.uab.cat>");
> +MODULE_DESCRIPTION("Vsock monitoring device");
> +MODULE_ALIAS_RTNL_LINK("vsockmon");

there should be some mention that this is derived from nlmon.c.

> diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
> index 5f047d2..b1836cc 100644
> --- a/include/uapi/linux/Kbuild
> +++ b/include/uapi/linux/Kbuild
> @@ -454,6 +454,7 @@ header-y +=3D virtio_scsi.h
>  header-y +=3D virtio_types.h
>  header-y +=3D virtio_vsock.h
>  header-y +=3D vm_sockets.h
> +header-y +=3D vsockmon.h
>  header-y +=3D vt.h
>  header-y +=3D wait.h
>  header-y +=3D wanrouter.h
> diff --git a/include/uapi/linux/vsockmon.h b/include/uapi/linux/vsockmon.h
> new file mode 100644
> index 0000000..c73166f
> --- /dev/null
> +++ b/include/uapi/linux/vsockmon.h
> @@ -0,0 +1,37 @@
> +#ifndef _UAPI_VSOCKMON_H
> +#define _UAPI_VSOCKMON_H
> +
> +#include <linux/virtio_vsock.h>
> +
> +/* Packet structure of packets received from the vsockmon device. */
> +
> +struct af_vsockmon_g {
> +	unsigned short op; /* enum af_vsock_g_ops */
> +	unsigned int src_cid;
> +	unsigned int src_port;
> +	unsigned int dst_cid;
> +	unsigned int dst_port;
> +};
> +
> +struct af_vsockmon_hdr {
> +	unsigned short type;  /* enum af_vosck_type */
> +	struct af_vsockmon_g g_hdr;
> +	union {
> +		struct virtio_vsock_hdr virtio_hdr;
> +	} t_hdr;
> +};

How does endianness work?  virtio_hdr uses little-endian fields on the
wire.  I guess that af_vsockmon_g is always CPU-endian.

> +
> +enum af_vsockmon_type {
> +	AF_VSOCK_GENERIC =3D 1, /* No transport header */
> +	AF_VSOCK_VIRTIO =3D 2,  /* Addtional virtio transport header */
> +};
> +
> +enum af_vsockmon_g_ops {
> +	AF_VSOCK_G_OP_UNKNOWN =3D 0,
> +	AF_VSOCK_G_OP_CONNECT =3D 1,
> +	AF_VSOCK_G_OP_DISCONNECT =3D 2,
> +	AF_VSOCK_G_OP_CONTROL =3D 3,
> +	AF_VSOCK_G_OP_PAYLOAD =3D 4,
> +};
> +
> +#endif
> --=20
> 2.8.3
>=20

--MiFvc8Vo6wRSORdP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXT1CKAAoJEJykq7OBq3PIKm8IAKlSIvdDnY2k4qlPCKyDUbzN
IGox2gwb0Q4WpgiPmv6Mqw2ubXvz4HQbrkXj3gfm/OKfCYs0jYHf7Ss1v5rj8COr
eJfp/4/mpIZC/IsHnQiR4w4oGmvqxHm84h0CrFvuJ7CUe8uRyMCFvROY+4cbg09b
vwLCRLQWqo4RA2nOJHpKKPHZ7Wq9bseCfyJuXAkZIVI0Mot6ju8g8wjGcKYwx9Fh
/vNFetqaKpF3fW+/C7os1QNznhjA6y9rOyitJzsJX9dgMfeI2/lzPY+3Jv+NorFk
G1PeRzEGdB5OvNF0wx4zNDAq60mpeas3cL7X+ZITdumyM0D/FcDlvjcCjIMSCDw=
=heE8
-----END PGP SIGNATURE-----

--MiFvc8Vo6wRSORdP--
