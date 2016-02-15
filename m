From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 1/3] pasemi_mac: Replace LRO with GRO
Date: Mon, 15 Feb 2016 21:25:11 +0000
Message-ID: <20160215212511.GC5231@decadent.org.uk>
References: <20160215212351.GB5231@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="da4uJneut+ArUgXk"
Cc: Olof Johansson <olof@lixom.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36449 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751104AbcBOVZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 16:25:13 -0500
Content-Disposition: inline
In-Reply-To: <20160215212351.GB5231@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--da4uJneut+ArUgXk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

GRO is simpler to use than the old inet_lro library, and is compatible
with forwarding and bridging configurations.

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/pasemi/Kconfig              |  5 +--
 drivers/net/ethernet/pasemi/pasemi_mac.c         | 50 +-------------------=
----
 drivers/net/ethernet/pasemi/pasemi_mac.h         |  4 --
 drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c |  1 -
 4 files changed, 3 insertions(+), 57 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/Kconfig b/drivers/net/ethernet/pas=
emi/Kconfig
index db19c6f49859..7c92e8306c19 100644
--- a/drivers/net/ethernet/pasemi/Kconfig
+++ b/drivers/net/ethernet/pasemi/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_PASEMI
 	bool "PA Semi devices"
 	default y
-	depends on PPC_PASEMI && PCI && INET
+	depends on PPC_PASEMI && PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
=20
@@ -18,9 +18,8 @@ if NET_VENDOR_PASEMI
=20
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
-	depends on PPC_PASEMI && PCI && INET
+	depends on PPC_PASEMI && PCI
 	select PHYLIB
-	select INET_LRO
 	---help---
 	  This driver supports the on-chip 1/10Gbit Ethernet controller on
 	  PA Semi's PWRficient line of chips.
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/etherne=
t/pasemi/pasemi_mac.c
index 57a6e6cd74fc..af54df52aa6b 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -30,9 +30,7 @@
 #include <linux/skbuff.h>
=20
 #include <linux/ip.h>
-#include <linux/tcp.h>
 #include <net/checksum.h>
-#include <linux/inet_lro.h>
 #include <linux/prefetch.h>
=20
 #include <asm/irq.h>
@@ -52,12 +50,9 @@
  *
  * - Multicast support
  * - Large MTU support
- * - SW LRO
  * - Multiqueue RX/TX
  */
=20
-#define LRO_MAX_AGGR 64
-
 #define PE_MIN_MTU	64
 #define PE_MAX_MTU	9000
 #define PE_DEF_MTU	ETH_DATA_LEN
@@ -257,37 +252,6 @@ static int pasemi_mac_set_mac_addr(struct net_device *=
dev, void *p)
 	return 0;
 }
=20
-static int get_skb_hdr(struct sk_buff *skb, void **iphdr,
-		       void **tcph, u64 *hdr_flags, void *data)
-{
-	u64 macrx =3D (u64) data;
-	unsigned int ip_len;
-	struct iphdr *iph;
-
-	/* IPv4 header checksum failed */
-	if ((macrx & XCT_MACRX_HTY_M) !=3D XCT_MACRX_HTY_IPV4_OK)
-		return -1;
-
-	/* non tcp packet */
-	skb_reset_network_header(skb);
-	iph =3D ip_hdr(skb);
-	if (iph->protocol !=3D IPPROTO_TCP)
-		return -1;
-
-	ip_len =3D ip_hdrlen(skb);
-	skb_set_transport_header(skb, ip_len);
-	*tcph =3D tcp_hdr(skb);
-
-	/* check if ip header and tcp header are complete */
-	if (ntohs(iph->tot_len) < ip_len + tcp_hdrlen(skb))
-		return -1;
-
-	*hdr_flags =3D LRO_IPV4 | LRO_TCP;
-	*iphdr =3D iph;
-
-	return 0;
-}
-
 static int pasemi_mac_unmap_tx_skb(struct pasemi_mac *mac,
 				    const int nfrags,
 				    struct sk_buff *skb,
@@ -817,7 +781,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac_rxring=
 *rx,
 		skb_put(skb, len-4);
=20
 		skb->protocol =3D eth_type_trans(skb, mac->netdev);
-		lro_receive_skb(&mac->lro_mgr, skb, (void *)macrx);
+		napi_gro_receive(&mac->napi, skb);
=20
 next:
 		RX_DESC(rx, n) =3D 0;
@@ -839,8 +803,6 @@ next:
=20
 	rx_ring(mac)->next_to_clean =3D n;
=20
-	lro_flush_all(&mac->lro_mgr);
-
 	/* Increase is in number of 16-byte entries, and since each descriptor
 	 * with an 8BRES takes up 3x8 bytes (padded to 4x8), increase with
 	 * count*2.
@@ -1754,16 +1716,6 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct =
pci_device_id *ent)
 	dev->features =3D NETIF_F_IP_CSUM | NETIF_F_LLTX | NETIF_F_SG |
 			NETIF_F_HIGHDMA | NETIF_F_GSO;
=20
-	mac->lro_mgr.max_aggr =3D LRO_MAX_AGGR;
-	mac->lro_mgr.max_desc =3D MAX_LRO_DESCRIPTORS;
-	mac->lro_mgr.lro_arr =3D mac->lro_desc;
-	mac->lro_mgr.get_skb_header =3D get_skb_hdr;
-	mac->lro_mgr.features =3D LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
-	mac->lro_mgr.dev =3D mac->netdev;
-	mac->lro_mgr.ip_summed =3D CHECKSUM_UNNECESSARY;
-	mac->lro_mgr.ip_summed_aggr =3D CHECKSUM_UNNECESSARY;
-
-
 	mac->dma_pdev =3D pci_get_device(PCI_VENDOR_ID_PASEMI, 0xa007, NULL);
 	if (!mac->dma_pdev) {
 		dev_err(&mac->pdev->dev, "Can't find DMA Controller\n");
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.h b/drivers/net/etherne=
t/pasemi/pasemi_mac.h
index a5807703ab96..161c99a98403 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.h
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.h
@@ -31,7 +31,6 @@
 #define CS_RING_SIZE (TX_RING_SIZE*2)
=20
=20
-#define MAX_LRO_DESCRIPTORS 8
 #define MAX_CS	2
=20
 struct pasemi_mac_txring {
@@ -84,10 +83,7 @@ struct pasemi_mac {
=20
 	u8		mac_addr[ETH_ALEN];
=20
-	struct net_lro_mgr	lro_mgr;
-	struct net_lro_desc	lro_desc[MAX_LRO_DESCRIPTORS];
 	struct timer_list	rxtimer;
-	unsigned int		lro_max_aggr;
=20
 	struct pasemi_mac_txring *tx;
 	struct pasemi_mac_rxring *rx;
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c b/drivers/net=
/ethernet/pasemi/pasemi_mac_ethtool.c
index 25fae568261f..f046bfc18e7d 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
@@ -20,7 +20,6 @@
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
 #include <linux/pci.h>
-#include <linux/inet_lro.h>
=20
 #include <asm/pasemi_dma.h>
 #include "pasemi_mac.h"


--da4uJneut+ArUgXk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVsJCN+e/yOyVhhEJAQrWQQ//UlXdqsySYIVF0z+MK0kCHLtv/ItcJtLf
w9HooASGCv6qx7tPG8W8JUzzW0I2tif7wdNrw9Ilw7a3k0jF7JqMROZjmKMqDK0L
36Csd5B1DMO92VFtsTCgtzVD5JTuzuLhr2kenPBKMOc1cEsWrsmKUcleP6BW5tqY
05gFTF9BzAae6dDbjaUtrNMdiLTp33mT3wWM1ldp4N3szFSj3R86ojAsYxNqbQ/M
uck30H4ZxUw1XhTBx7VPWdjjLIoJaMhox6N2dhQVjdDFh47AbO4nyWHtz5j1DpSL
NblAn/8iW2PiA9CrZ8lXz+hQyv2V//mMxcTcHaZA5aQrNavGl4aUwSYtHsk//F/b
9qE47+u8yfHjWb/HKq9vmH4fiXyNzl70Qg/xzj9TyW+MGP7x+32qoLSAILkPokUa
jzWpbdyUgwNhK0u0hN+JfmrwYrHfTrWOAyFJ3S75HhuxV4aQe6FP0jZ1auG+LnH0
3v5gm4Ds+JsGc7x6OXzBD9qXOAZ/fNctvkIc/deL9/onXbxyRxsMt8LSF54oS2TW
nIvXJgCFctJJ1HJGmyY+wE3vYifVDaPlhaocHcc94Y1cwyhTC1zGEAsEBYCcJNQE
cDJFav8/SKyiaFD9fdN6U4uQNEElf1fVuNOWCDBpHWPh4CilRXfbO+KwAme2+6E/
Niatwm7i2OI=
=YR3N
-----END PGP SIGNATURE-----

--da4uJneut+ArUgXk--
