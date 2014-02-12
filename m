From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 01/14] ethtool: Expand documentation of struct
 ethtool_cmd
Date: Wed, 12 Feb 2014 22:13:57 +0000
Message-ID: <1392243237.15615.5.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AEEc0Srf2F9K9aQH45CG"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52774 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753033AbaBLWOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:05 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-AEEc0Srf2F9K9aQH45CG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

struct ethtool_cmd has very limited documentation; it contains
several obscure or obsolete fields and several with non-obvious
interpretation.

Replace the inline comments (and some others below) with a full
explanation of the semantics as well as I understand them, in
kernel-doc format.  Formally deprecate some fields that seem to be of
historical use only.

Extend the comment about 32/64-bit compatibility to cover all
ethtool structures.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 124 +++++++++++++++++++++++++++++++--------=
----
 1 file changed, 90 insertions(+), 34 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 38dbafa..c4d5eb2 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -16,37 +16,97 @@
 #include <linux/types.h>
 #include <linux/if_ether.h>
=20
-/* This should work for both 32 and 64 bit userland. */
+/* All structures exposed to userland should be defined such that they
+ * have the same layout for 32-bit and 64-bit userland.
+ */
+
+/**
+ * struct ethtool_cmd - link control and status
+ * @cmd: Command number =3D %ETHTOOL_GSET or %ETHTOOL_SSET
+ * @supported: Bitmask of %SUPPORTED_* flags for the link modes,
+ *	physical connectors and other link features for which the
+ *	interface supports autonegotiation or auto-detection.
+ *	Read-only.
+ * @advertising: Bitmask of %ADVERTISED_* flags for the link modes,
+ *	physical connectors and other link features that are
+ *	advertised through autonegotiation or enabled for
+ *	auto-detection.
+ * @speed: Low bits of the speed
+ * @duplex: Duplex mode; one of %DUPLEX_*
+ * @port: Physical connector type; one of %PORT_*
+ * @phy_address: MDIO address of PHY (transceiver); 0 or 255 if not
+ *	applicable.  For clause 45 PHYs this is the PRTAD.
+ * @transceiver: Historically used to distinguish different possible
+ *	PHY types, but not in a consistent way.  Deprecated.
+ * @autoneg: Enable/disable autonegotiation and auto-detection;
+ *	either %AUTONEG_DISABLE or %AUTONEG_ENABLE
+ * @mdio_support: Bitmask of %ETH_MDIO_SUPPORTS_* flags for the MDIO
+ *	protocols supported by the interface; 0 if unknown.
+ *	Read-only.
+ * @maxtxpkt: Historically used to report TX IRQ coalescing; now
+ *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
+ * @maxrxpkt: Historically used to report RX IRQ coalescing; now
+ *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
+ * @speed_hi: High bits of the speed
+ * @eth_tp_mdix: Ethernet twisted-pair MDI(-X) status; one of
+ *	%ETH_TP_MDI_*.  If the status is unknown or not applicable, the
+ *	value will be %ETH_TP_MDI_INVALID.  Read-only.
+ * @eth_tp_mdix_ctrl: Ethernet twisted pair MDI(-X) control; one of
+ *	%ETH_TP_MDI_*.  If MDI(-X) control is not implemented, reads
+ *	yield %ETH_TP_MDI_INVALID and writes may be ignored or rejected.
+ *	When written successfully, the link should be renegotiated if
+ *	necessary.
+ * @lp_advertising: Bitmask of %ADVERTISED_* flags for the link modes
+ *	and other link features that the link partner advertised
+ *	through autonegotiation; 0 if unknown or not applicable.
+ *	Read-only.
+ *
+ * The link speed in Mbps is split between @speed and @speed_hi.  Use
+ * the ethtool_cmd_speed() and ethtool_cmd_speed_set() functions to
+ * access it.
+ *
+ * If autonegotiation is disabled, the speed and @duplex represent the
+ * fixed link mode and are writable if the driver supports multiple
+ * link modes.  If it is enabled then they are read-only; if the link
+ * is up they represent the negotiated link mode; if the link is down,
+ * the speed is 0, %SPEED_UNKNOWN or the highest enabled speed and
+ * @duplex is %DUPLEX_UNKNOWN or the best enabled duplex mode.
+ *
+ * Some hardware interfaces may have multiple PHYs and/or physical
+ * connectors fitted or do not allow the driver to detect which are
+ * fitted.  For these interfaces @port and/or @phy_address may be
+ * writable, possibly dependent on @autoneg being %AUTONEG_DISABLE.
+ * Otherwise, attempts to write different values may be ignored or
+ * rejected.
+ *
+ * Users should assume that all fields not marked read-only are
+ * writable and subject to validation by the driver.  They should use
+ * %ETHTOOL_GSET to get the current values before making specific
+ * changes and then applying them with %ETHTOOL_SSET.
+ *
+ * Drivers that implement set_settings() should validate all fields
+ * other than @cmd that are not described as read-only or deprecated,
+ * and must ignore all fields described as read-only.
+ *
+ * Deprecated fields should be ignored by both users and drivers.
+ */
 struct ethtool_cmd {
 	__u32	cmd;
-	__u32	supported;	/* Features this interface supports */
-	__u32	advertising;	/* Features this interface advertises */
-	__u16	speed;	        /* The forced speed (lower bits) in
-				 * Mbps. Please use
-				 * ethtool_cmd_speed()/_set() to
-				 * access it */
-	__u8	duplex;		/* Duplex, half or full */
-	__u8	port;		/* Which connector port */
-	__u8	phy_address;	/* MDIO PHY address (PRTAD for clause 45).
-				 * May be read-only or read-write
-				 * depending on the driver.
-				 */
-	__u8	transceiver;	/* Which transceiver to use */
-	__u8	autoneg;	/* Enable or disable autonegotiation */
-	__u8	mdio_support;	/* MDIO protocols supported.  Read-only.
-				 * Not set by all drivers.
-				 */
-	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
-	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
-	__u16	speed_hi;       /* The forced speed (upper
-				 * bits) in Mbps. Please use
-				 * ethtool_cmd_speed()/_set() to
-				 * access it */
-	__u8	eth_tp_mdix;	/* twisted pair MDI-X status */
-	__u8    eth_tp_mdix_ctrl; /* twisted pair MDI-X control, when set,
-				   * link should be renegotiated if necessary
-				   */
-	__u32	lp_advertising;	/* Features the link partner advertises */
+	__u32	supported;
+	__u32	advertising;
+	__u16	speed;
+	__u8	duplex;
+	__u8	port;
+	__u8	phy_address;
+	__u8	transceiver;
+	__u8	autoneg;
+	__u8	mdio_support;
+	__u32	maxtxpkt;
+	__u32	maxrxpkt;
+	__u16	speed_hi;
+	__u8	eth_tp_mdix;
+	__u8	eth_tp_mdix_ctrl;
+	__u32	lp_advertising;
 	__u32	reserved[2];
 };
=20
@@ -905,7 +965,6 @@ enum ethtool_sfeatures_retval_bits {
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
=20
-/* Indicates what features are supported by the interface. */
 #define SUPPORTED_10baseT_Half		(1 << 0)
 #define SUPPORTED_10baseT_Full		(1 << 1)
 #define SUPPORTED_100baseT_Half		(1 << 2)
@@ -934,7 +993,6 @@ enum ethtool_sfeatures_retval_bits {
 #define SUPPORTED_40000baseSR4_Full	(1 << 25)
 #define SUPPORTED_40000baseLR4_Full	(1 << 26)
=20
-/* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
 #define ADVERTISED_10baseT_Full		(1 << 1)
 #define ADVERTISED_100baseT_Half	(1 << 2)
@@ -999,9 +1057,7 @@ enum ethtool_sfeatures_retval_bits {
 #define XCVR_DUMMY2		0x03
 #define XCVR_DUMMY3		0x04
=20
-/* Enable or disable autonegotiation.  If this is set to enable,
- * the forced link modes above are completely ignored.
- */
+/* Enable or disable autonegotiation. */
 #define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
=20


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-AEEc0Srf2F9K9aQH45CG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyJee/yOyVhhEJAQqjwg/8D6W908tvBlO6U7+mKIHaUVEkKxr1WUoI
sKf5R53dW4l0wFI4Ho/p/WJXVZu8He4wt/SXB/7KyI5R8xOnY1hJhjAlWrNmh5Bg
NKMFBj49pXI3icB6Sl811ZhRoQW3q+jS0L99uhReWV0xzpEjI1HkxlrXB8z/nB9Z
PjqR6eZRaP1tDuwLKycBJMy7tmrjOggM5GwPJD1zqX4BG3w+QcRg+a6zPr7ovc++
/tRjobnbN1o4IbfMqLf/JyGd4T+ahyUw0MkAWTX5a+Rg2+xtjFWSdj9UefsLn05M
BNWepG6WpZ8ZagwjZH/MwbnTyQxlqK3SrRki5syR6M3Y2oabuJwW9eSZ71PrZXI6
aAH4+z6RiM+Hrj+6UDTTAxjqKSWaeMt88rZP8GymnIcOuBkRfxNn2OMDpSgQ8Ika
LNHuox/Lp5T658zK+x24E9wdN7/6r8Wknnbyb5STpM1VKQWsQ3GL/CzGTnP5wIAu
OHDqUHh24TpbHbhlO7YTY01PxgPwdFog/7hpWnV0Asl5l+dxlxQZXF5VwOqVtyLk
0t/o9ESoa3Jr1NAuFkAoWH4Uxd0HraVpFJSncmNUNOlOcWD8aRB96xtDoInW9vu6
oEqGdnNRsCHRkdTySTo7zf+qd2n5/Sj0g1tAvj5CaSLfShSv4WlugcbommE4Kvyj
Tt0ShrxIy6A=
=twSo
-----END PGP SIGNATURE-----

--=-AEEc0Srf2F9K9aQH45CG--
