From: Phil Dibowitz <phil@ipom.com>
Subject: [PATCH] Interface Stat Clearing Framework, skge support, ethtool
 support
Date: Sat, 29 Apr 2006 20:16:54 -0700
Message-ID: <44542C26.4070409@ipom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig37A6B6D4ABE86EFA64A4F7A6"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ipom.com ([209.40.128.125]:16524 "EHLO
	uberhacker.sage-inc.com") by vger.kernel.org with ESMTP
	id S1750887AbWD3DRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 23:17:04 -0400
Received: from [10.1.1.2] (cpe-24-24-245-191.socal.res.rr.com [24.24.245.191])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by uberhacker.sage-inc.com (Postfix) with ESMTP id B5D011BBC5
	for <netdev@vger.kernel.org>; Sat, 29 Apr 2006 22:17:12 -0500 (CDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig37A6B6D4ABE86EFA64A4F7A6
Content-Type: multipart/mixed;
 boundary="------------000607080903090506060700"

This is a multi-part message in MIME format.
--------------000607080903090506060700
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hey folks,

A few months back I posted an in-progress patch for adding a clear_stats
framework similar to the get_stats framework and implimenting support
for it in the skge driver (the one NIC I have access to), as well as
adding the ethtool support for it.

While a few people said they didn't see the need for it, other people
did see the need for it, and I know it's a common request on many
sysadmin mailing lists I'm on.

Since no one seemed to have any technical issue with the patch, I've
cleaned up the patch, tested it, and fixed a few minor issues.

Unless someone has an objection, I'd think this would be useful to a lot
of people.

There are two patches attached:

interface_stats_clear.patch - the kernel patch against 2.6.17-rc3-git2
ethtool3-clearstats.patch - the ethtool patch to add the -z flag to
		support it.

If the kernel patch gets accepted I'll send a more complete ethtool
patch with documentation updates, etc.

Thanks.
--=20
Phil Dibowitz                             phil@ipom.com
Freeware and Technical Pages              Insanity Palace of Metallica
http://www.phildev.net/                   http://www.ipom.com/

"Be who you are and say what you feel, because those who mind don't
matter and those who matter don't mind."
 - Dr. Suess



--------------000607080903090506060700
Content-Type: text/x-patch;
 name="interface_stats_clear.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="interface_stats_clear.patch"



This patch adds support for clearing interface statistics using the ethto=
ol interface adding a new 0x23 command. It adds a clear_stats function po=
inter to the net_device struct, and then impliments local functions in th=
e driver much the say get_stats works. The ethtool funtion pointer points=
 to the same functions. The driver-local functions are currently only imp=
limented in the skge driver.

Signed-off-by: Phil Dibowitz <phil@ipom.com>

---


diff -puN include/linux/netdevice.h~interface_stats_clear include/linux/n=
etdevice.h
--- linux-2.6.17-rc3-git2/include/linux/netdevice.h~interface_stats_clear=
	2006-04-29 19:44:41.000000000 -0700
+++ linux-2.6.17-rc3-git2-phil/include/linux/netdevice.h	2006-04-29 19:44=
:41.000000000 -0700
@@ -319,6 +319,7 @@ struct net_device
=20
=20
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
+	void (*clear_stats)(struct net_device *dev);
 	struct iw_statistics*	(*get_wireless_stats)(struct net_device *dev);
=20
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
diff -puN drivers/net/skge.c~interface_stats_clear drivers/net/skge.c
--- linux-2.6.17-rc3-git2/drivers/net/skge.c~interface_stats_clear	2006-0=
4-29 19:44:41.000000000 -0700
+++ linux-2.6.17-rc3-git2-phil/drivers/net/skge.c	2006-04-29 19:44:41.000=
000000 -0700
@@ -44,7 +44,7 @@
 #include "skge.h"
=20
 #define DRV_NAME		"skge"
-#define DRV_VERSION		"1.5"
+#define DRV_VERSION		"1.6"
 #define PFX			DRV_NAME " "
=20
 #define DEFAULT_TX_RING_SIZE	128
@@ -97,6 +97,8 @@ static int xm_phy_write(struct skge_hw *
 static int gm_phy_write(struct skge_hw *hw, int port, u16 reg, u16 val);=

 static void genesis_get_stats(struct skge_port *skge, u64 *data);
 static void yukon_get_stats(struct skge_port *skge, u64 *data);
+static void genesis_clear_stats(struct skge_port *skge);
+static void yukon_clear_stats(struct skge_port *skge);
 static void yukon_init(struct skge_hw *hw, int port);
 static void genesis_mac_init(struct skge_hw *hw, int port);
 static void genesis_link_up(struct skge_port *skge);
@@ -366,6 +368,15 @@ static struct net_device_stats *skge_get
 	return &skge->net_stats;
 }
=20
+static void skge_clear_stats(struct net_device *dev)
+{
+	struct skge_port *skge =3D netdev_priv(dev);
+	if (skge->hw->chip_id =3D=3D CHIP_ID_GENESIS)
+		genesis_clear_stats(skge);
+	else
+		yukon_clear_stats(skge);
+}
+
 static void skge_get_strings(struct net_device *dev, u32 stringset, u8 *=
data)
 {
 	int i;
@@ -722,6 +733,7 @@ static struct ethtool_ops skge_ethtool_o
 	.phys_id	=3D skge_phys_id,
 	.get_stats_count =3D skge_get_stats_count,
 	.get_ethtool_stats =3D skge_get_ethtool_stats,
+	.clear_ethtool_stats =3D skge_clear_stats,
 	.get_perm_addr	=3D ethtool_op_get_perm_addr,
 };
=20
@@ -1383,6 +1395,20 @@ static void genesis_get_stats(struct skg
 		data[i] =3D xm_read32(hw, port, skge_stats[i].xmac_offset);
 }
=20
+static void genesis_clear_stats(struct skge_port *skge)
+{
+	struct skge_hw *hw =3D skge->hw;
+	int port =3D skge->port;
+
+	/*
+	 * This is based on reading other parts of the driver
+	 * and is not yet tested.
+	 */
+
+	xm_write16(hw, port, XM_STAT_CMD, 0 | XM_SC_CLR_RXC
+			| XM_SC_CLR_TXC);
+}
+
 static void genesis_mac_intr(struct skge_hw *hw, int port)
 {
 	struct skge_port *skge =3D netdev_priv(hw->dev[port]);
@@ -1871,6 +1897,21 @@ static void yukon_get_stats(struct skge_
 					  skge_stats[i].gma_offset);
 }
=20
+static void yukon_clear_stats(struct skge_port *skge)
+{
+	struct skge_hw *hw =3D skge->hw;
+	int port =3D skge->port;
+	u16 reg;
+	int i;
+
+	reg =3D gma_read16(hw, port, GM_PHY_ADDR);
+	/* this read is important, or we sometimes get no effect */
+	gma_write16(hw, port, GM_PHY_ADDR, reg | GM_PAR_MIB_CLR);
+	for (i =3D 0; i < GM_MIB_CNT_SIZE; i++)
+		gma_read16(hw, port, GM_MIB_CNT_BASE + 8*i);
+	gma_write16(hw, port, GM_PHY_ADDR, reg);
+}
+
 static void yukon_mac_intr(struct skge_hw *hw, int port)
 {
 	struct net_device *dev =3D hw->dev[port];
@@ -3183,6 +3224,7 @@ static struct net_device *skge_devinit(s
 	dev->do_ioctl =3D skge_ioctl;
 	dev->hard_start_xmit =3D skge_xmit_frame;
 	dev->get_stats =3D skge_get_stats;
+	dev->clear_stats =3D skge_clear_stats;
 	if (hw->chip_id =3D=3D CHIP_ID_GENESIS)
 		dev->set_multicast_list =3D genesis_set_multicast;
 	else
diff -puN include/linux/ethtool.h~interface_stats_clear include/linux/eth=
tool.h
--- linux-2.6.17-rc3-git2/include/linux/ethtool.h~interface_stats_clear	2=
006-04-29 19:44:41.000000000 -0700
+++ linux-2.6.17-rc3-git2-phil/include/linux/ethtool.h	2006-04-29 19:44:4=
1.000000000 -0700
@@ -365,6 +365,7 @@ struct ethtool_ops {
 	int	(*phys_id)(struct net_device *, u32);
 	int	(*get_stats_count)(struct net_device *);
 	void	(*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, =
u64 *);
+	void    (*clear_ethtool_stats)(struct net_device *);
 	int	(*get_perm_addr)(struct net_device *, struct ethtool_perm_addr *, u=
8 *);
 	int	(*begin)(struct net_device *);
 	void	(*complete)(struct net_device *);
@@ -408,6 +409,7 @@ struct ethtool_ops {
 #define ETHTOOL_GPERMADDR	0x00000020 /* Get permanent hardware address *=
/
 #define ETHTOOL_GUFO		0x00000021 /* Get UFO enable (ethtool_value) */
 #define ETHTOOL_SUFO		0x00000022 /* Set UFO enable (ethtool_value) */
+#define ETHTOOL_CSTATS		0x00000023 /* Clear NIC-specific statistics */
=20
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff -puN net/core/ethtool.c~interface_stats_clear net/core/ethtool.c
--- linux-2.6.17-rc3-git2/net/core/ethtool.c~interface_stats_clear	2006-0=
4-29 19:44:41.000000000 -0700
+++ linux-2.6.17-rc3-git2-phil/net/core/ethtool.c	2006-04-29 19:44:41.000=
000000 -0700
@@ -741,6 +741,17 @@ static int ethtool_get_stats(struct net_
 	return ret;
 }
=20
+static int ethtool_clear_stats(struct net_device *dev, void __user *user=
addr)
+{
+	struct ethtool_ops *ops =3D dev->ethtool_ops;
+	if (!ops->clear_ethtool_stats)
+		return -EOPNOTSUPP;
+
+	ops->clear_ethtool_stats(dev);
+
+	return 0;
+}
+
 static int ethtool_get_perm_addr(struct net_device *dev, void __user *us=
eraddr)
 {
 	struct ethtool_perm_addr epaddr;
@@ -906,6 +917,9 @@ int dev_ethtool(struct ifreq *ifr)
 	case ETHTOOL_SUFO:
 		rc =3D ethtool_set_ufo(dev, useraddr);
 		break;
+	case ETHTOOL_CSTATS:
+		rc =3D ethtool_clear_stats(dev, useraddr);
+		break;
 	default:
 		rc =3D  -EOPNOTSUPP;
 	}
_

--------------000607080903090506060700
Content-Type: text/x-patch;
 name="ethtool3-clearstats.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="ethtool3-clearstats.patch"

--- ethtool-3/ethtool.c.b4phil	2006-04-29 19:01:18.000000000 -0700
+++ ethtool-3/ethtool.c	2006-04-29 19:01:36.000000000 -0700
@@ -66,6 +66,7 @@
 static int do_goffload(int fd, struct ifreq *ifr);
 static int do_soffload(int fd, struct ifreq *ifr);
 static int do_gstats(int fd, struct ifreq *ifr);
+static int do_cstats(int fd, struct ifreq *ifr);
 static int send_ioctl(int fd, struct ifreq *ifr);
 static int check_for_pre24_kernel();
=20
@@ -242,6 +243,7 @@
 	MODE_GOFFLOAD,
 	MODE_SOFFLOAD,
 	MODE_GSTATS,
+	MODE_CSTATS,
 } mode =3D MODE_GSET;
=20
 static int goffload_changed =3D 0;
@@ -470,6 +472,8 @@
 				mode =3D MODE_TEST;
 			else if (!strcmp(argp[i], "-S"))
 				mode =3D MODE_GSTATS;
+			else if (!strcmp(argp[i], "-z"))
+				mode =3D MODE_CSTATS;
 			else if (!strcmp(argp[i], "-h"))
 				show_usage(0);
 			else
@@ -492,6 +496,7 @@
 			    (mode =3D=3D MODE_GOFFLOAD) ||
 			    (mode =3D=3D MODE_SOFFLOAD) ||
 			    (mode =3D=3D MODE_GSTATS) ||
+			    (mode =3D=3D MODE_CSTATS) ||
 			    (mode =3D=3D MODE_PHYS_ID)) {
 				devname =3D argp[i];
 				break;
@@ -1266,6 +1271,8 @@
 		return do_soffload(fd, &ifr);
 	} else if (mode =3D=3D MODE_GSTATS) {
 		return do_gstats(fd, &ifr);
+	} else if (mode =3D=3D MODE_CSTATS) {
+		return do_cstats(fd, &ifr);
 	}
=20
 	return 69;
@@ -2010,6 +2017,79 @@
 	return 0;
 }
=20
+static int do_cstats(int fd, struct ifreq *ifr)
+{
+	struct ethtool_drvinfo drvinfo;
+	struct ethtool_gstrings *strings;
+	struct ethtool_stats *stats;
+	unsigned int n_stats, sz_str, sz_stats, i;
+	int err;
+
+	drvinfo.cmd =3D ETHTOOL_GDRVINFO;
+	ifr->ifr_data =3D (caddr_t)&drvinfo;
+	err =3D send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot get driver information");
+		return 71;
+	}
+
+	n_stats =3D drvinfo.n_stats;
+	if (n_stats < 1) {
+		fprintf(stderr, "no stats available\n");
+		return 94;
+	}
+
+	sz_str =3D n_stats * ETH_GSTRING_LEN;
+	sz_stats =3D n_stats * sizeof(u64);
+
+	strings =3D calloc(1, sz_str + sizeof(struct ethtool_gstrings));
+	stats =3D calloc(1, sz_stats + sizeof(struct ethtool_stats));
+	if (!strings || !stats) {
+		fprintf(stderr, "no memory available\n");
+		return 95;
+	}
+
+	strings->cmd =3D ETHTOOL_GSTRINGS;
+	strings->string_set =3D ETH_SS_STATS;
+	strings->len =3D n_stats;
+	ifr->ifr_data =3D (caddr_t) strings;
+	err =3D send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot get stats strings information");
+		free(strings);
+		free(stats);
+		return 96;
+	}
+
+	stats->cmd =3D ETHTOOL_CSTATS;
+	stats->n_stats =3D n_stats;
+	ifr->ifr_data =3D (caddr_t) stats;
+	err =3D send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Cannot get stats information");
+		free(strings);
+		free(stats);
+		return 97;
+	}
+
+	/* todo - pretty-print the strings per-driver */
+	/*
+	fprintf(stdout, "NIC statistics:\n");
+	for (i =3D 0; i < n_stats; i++) {
+		char s[ETH_GSTRING_LEN];
+
+		strncpy(s, &strings->data[i * ETH_GSTRING_LEN],
+			ETH_GSTRING_LEN);
+		fprintf(stdout, "     %s: %llu\n",
+			s, stats->data[i]);
+	}
+	*/
+	free(strings);
+	free(stats);
+
+	return 0;
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	int err;
--- ethtool-3/ethtool-copy.h.b4phil	2006-04-29 19:01:26.000000000 -0700
+++ ethtool-3/ethtool-copy.h	2006-04-29 19:01:36.000000000 -0700
@@ -283,6 +283,7 @@
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
+#define ETHTOOL_CSTATS		0x00000023 /* get NIC-specific statistics */
=20
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET

--------------000607080903090506060700--

--------------enig37A6B6D4ABE86EFA64A4F7A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFEVCwrN5XoxaHnMrsRAmIHAJ4ixV7zIeGcwyZeG4RW1KnQXAUVcACfTPj3
H8wd5wMM1S5gG7QeFqP71o8=
=VoYo
-----END PGP SIGNATURE-----

--------------enig37A6B6D4ABE86EFA64A4F7A6--
