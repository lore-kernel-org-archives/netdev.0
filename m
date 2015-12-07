From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 14/26] sfp: display SFP module information
Date: Mon, 07 Dec 2015 17:38:23 +0000
Message-ID: <E1a5zjz-00075t-5x@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60293 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303AbbLGRi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:38:26 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/sfp.c | 245 ++++++++++++++++++++++++++++++++++++++++++=
+++++++-
 1 file changed, 244 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/sfp.c b/drivers/net/phy/sfp.c
index 70a375403e55..678298844203 100644
--- a/drivers/net/phy/sfp.c
+++ b/drivers/net/phy/sfp.c
@@ -248,6 +248,180 @@ static unsigned int sfp_check(void *buf, size_t l=
en)
 	return check;
 }
=20
+static const char *sfp_link_len(char *buf, size_t size, unsigned int l=
ength,
+	unsigned int multiplier)
+{
+	if (length =3D=3D 0)
+		return "unsupported/unspecified";
+
+	if (length =3D=3D 255) {
+		*buf++ =3D '>';
+		size -=3D 1;
+		length -=3D 1;
+	}
+
+	length *=3D multiplier;
+
+	if (length >=3D 1000)
+		snprintf(buf, size, "%u.%0*ukm",
+			length / 1000,
+			multiplier > 100 ? 1 :
+			multiplier > 10 ? 2 : 3,
+			length % 1000);
+	else
+		snprintf(buf, size, "%um", length);
+
+	return buf;
+}
+
+struct bitfield {
+	unsigned int mask;
+	unsigned int val;
+	const char *str;
+};
+
+static const struct bitfield sfp_options[] =3D {
+	{
+		.mask =3D SFP_OPTIONS_HIGH_POWER_LEVEL,
+		.val =3D SFP_OPTIONS_HIGH_POWER_LEVEL,
+		.str =3D "hpl",
+	}, {
+		.mask =3D SFP_OPTIONS_PAGING_A2,
+		.val =3D SFP_OPTIONS_PAGING_A2,
+		.str =3D "paginga2",
+	}, {
+		.mask =3D SFP_OPTIONS_RETIMER,
+		.val =3D SFP_OPTIONS_RETIMER,
+		.str =3D "retimer",
+	}, {
+		.mask =3D SFP_OPTIONS_COOLED_XCVR,
+		.val =3D SFP_OPTIONS_COOLED_XCVR,
+		.str =3D "cooled",
+	}, {
+		.mask =3D SFP_OPTIONS_POWER_DECL,
+		.val =3D SFP_OPTIONS_POWER_DECL,
+		.str =3D "powerdecl",
+	}, {
+		.mask =3D SFP_OPTIONS_RX_LINEAR_OUT,
+		.val =3D SFP_OPTIONS_RX_LINEAR_OUT,
+		.str =3D "rxlinear",
+	}, {
+		.mask =3D SFP_OPTIONS_RX_DECISION_THRESH,
+		.val =3D SFP_OPTIONS_RX_DECISION_THRESH,
+		.str =3D "rxthresh",
+	}, {
+		.mask =3D SFP_OPTIONS_TUNABLE_TX,
+		.val =3D SFP_OPTIONS_TUNABLE_TX,
+		.str =3D "tunabletx",
+	}, {
+		.mask =3D SFP_OPTIONS_RATE_SELECT,
+		.val =3D SFP_OPTIONS_RATE_SELECT,
+		.str =3D "ratesel",
+	}, {
+		.mask =3D SFP_OPTIONS_TX_DISABLE,
+		.val =3D SFP_OPTIONS_TX_DISABLE,
+		.str =3D "txdisable",
+	}, {
+		.mask =3D SFP_OPTIONS_TX_FAULT,
+		.val =3D SFP_OPTIONS_TX_FAULT,
+		.str =3D "txfault",
+	}, {
+		.mask =3D SFP_OPTIONS_LOS_INVERTED,
+		.val =3D SFP_OPTIONS_LOS_INVERTED,
+		.str =3D "los-",
+	}, {
+		.mask =3D SFP_OPTIONS_LOS_NORMAL,
+		.val =3D SFP_OPTIONS_LOS_NORMAL,
+		.str =3D "los+",
+	}, { }
+};
+
+static const struct bitfield diagmon[] =3D {
+	{
+		.mask =3D SFP_DIAGMON_DDM,
+		.val =3D SFP_DIAGMON_DDM,
+		.str =3D "ddm",
+	}, {
+		.mask =3D SFP_DIAGMON_INT_CAL,
+		.val =3D SFP_DIAGMON_INT_CAL,
+		.str =3D "intcal",
+	}, {
+		.mask =3D SFP_DIAGMON_EXT_CAL,
+		.val =3D SFP_DIAGMON_EXT_CAL,
+		.str =3D "extcal",
+	}, {
+		.mask =3D SFP_DIAGMON_RXPWR_AVG,
+		.val =3D SFP_DIAGMON_RXPWR_AVG,
+		.str =3D "rxpwravg",
+	}, { }
+};
+
+static const char *sfp_bitfield(char *out, size_t outsz, const struct =
bitfield *bits, unsigned int val)
+{
+	char *p =3D out;
+	int n;
+
+	*p =3D '\0';
+	while (bits->mask) {
+		if ((val & bits->mask) =3D=3D bits->val) {
+			n =3D snprintf(p, outsz, "%s%s",
+				     out !=3D p ? ", " : "",
+				     bits->str);
+			if (n =3D=3D outsz)
+				break;
+			p +=3D n;
+			outsz -=3D n;
+		}
+		bits++;
+	}
+
+	return out;
+}
+
+static const char *sfp_connector(unsigned int connector)
+{
+	switch (connector) {
+	case SFP_CONNECTOR_UNSPEC:
+		return "unknown/unspecified";
+	case SFP_CONNECTOR_FIBERJACK:
+		return "Fiberjack";
+	case SFP_CONNECTOR_LC:
+		return "LC";
+	case SFP_CONNECTOR_MT_RJ:
+		return "MT-RJ";
+	case SFP_CONNECTOR_MU:
+		return "MU";
+	case SFP_CONNECTOR_SG:
+		return "SG";
+	case SFP_CONNECTOR_OPTICAL_PIGTAIL:
+		return "Optical pigtail";
+	case SFP_CONNECTOR_HSSDC_II:
+		return "HSSDC II";
+	case SFP_CONNECTOR_COPPER_PIGTAIL:
+		return "Copper pigtail";
+	default:
+		return "unknown";
+	}
+}
+
+static const char *sfp_encoding(unsigned int encoding)
+{
+	switch (encoding) {
+	case SFP_ENCODING_UNSPEC:
+		return "unspecified";
+	case SFP_ENCODING_8B10B:
+		return "8b10b";
+	case SFP_ENCODING_4B5B:
+		return "4b5b";
+	case SFP_ENCODING_NRZ:
+		return "NRZ";
+	case SFP_ENCODING_MANCHESTER:
+		return "MANCHESTER";
+	default:
+		return "unknown";
+	}
+}
+
 /* Helpers */
 static void sfp_module_tx_disable(struct sfp *sfp)
 {
@@ -414,6 +588,7 @@ static int sfp_sm_mod_probe(struct sfp *sfp)
 	char sn[17];
 	char date[9];
 	char rev[5];
+	char options[80];
 	u8 check;
 	int err;
=20
@@ -450,10 +625,78 @@ static int sfp_sm_mod_probe(struct sfp *sfp)
 	rev[4] =3D '\0';
 	memcpy(sn, sfp->id.ext.vendor_sn, 16);
 	sn[16] =3D '\0';
-	memcpy(date, sfp->id.ext.datecode, 8);
+	date[0] =3D sfp->id.ext.datecode[4];
+	date[1] =3D sfp->id.ext.datecode[5];
+	date[2] =3D '-';
+	date[3] =3D sfp->id.ext.datecode[2];
+	date[4] =3D sfp->id.ext.datecode[3];
+	date[5] =3D '-';
+	date[6] =3D sfp->id.ext.datecode[0];
+	date[7] =3D sfp->id.ext.datecode[1];
 	date[8] =3D '\0';
=20
 	dev_info(sfp->dev, "module %s %s rev %s sn %s dc %s\n", vendor, part,=
 rev, sn, date);
+	dev_info(sfp->dev, "  %s connector, encoding %s, nominal bitrate %u.%=
uGbps +%u%% -%u%%\n",
+		 sfp_connector(sfp->id.base.connector),
+		 sfp_encoding(sfp->id.base.encoding),
+		 sfp->id.base.br_nominal / 10,
+		 sfp->id.base.br_nominal % 10,
+		 sfp->id.ext.br_max, sfp->id.ext.br_min);
+	dev_info(sfp->dev, "  1000BaseSX%c 1000BaseLX%c 1000BaseCX%c 1000Base=
T%c 100BaseTLX%c 1000BaseFX%c BaseBX10%c BasePX%c\n",
+		 sfp->id.base.e1000_base_sx ? '+' : '-',
+		 sfp->id.base.e1000_base_lx ? '+' : '-',
+		 sfp->id.base.e1000_base_cx ? '+' : '-',
+		 sfp->id.base.e1000_base_t ? '+' : '-',
+		 sfp->id.base.e100_base_lx ? '+' : '-',
+		 sfp->id.base.e100_base_fx ? '+' : '-',
+		 sfp->id.base.e_base_bx10 ? '+' : '-',
+		 sfp->id.base.e_base_px ? '+' : '-');
+
+	if (!sfp->id.base.sfp_ct_passive && !sfp->id.base.sfp_ct_active &&
+	    !sfp->id.base.e1000_base_t) {
+		char len_9um[16], len_om[16];
+
+		dev_info(sfp->dev, "  Wavelength %unm, fiber lengths:\n",
+			 be16_to_cpup(&sfp->id.base.optical_wavelength));
+
+		if (sfp->id.base.link_len[0] =3D=3D 255)
+			strcpy(len_9um, ">254km");
+		else if (sfp->id.base.link_len[1] && sfp->id.base.link_len[1] !=3D 2=
55)
+			sprintf(len_9um, "%um",
+				sfp->id.base.link_len[1] * 100);
+		else if (sfp->id.base.link_len[0])
+			sprintf(len_9um, "%ukm", sfp->id.base.link_len[0]);
+		else if (sfp->id.base.link_len[1] =3D=3D 255)
+			strcpy(len_9um, ">25.4km");
+		else
+			strcpy(len_9um, "unsupported");
+
+		dev_info(sfp->dev, "    9=C2=B5m SM    : %s\n", len_9um);
+		dev_info(sfp->dev, " 62.5=C2=B5m MM OM1: %s\n",
+			 sfp_link_len(len_om, sizeof(len_om),
+				      sfp->id.base.link_len[3], 10));
+		dev_info(sfp->dev, "   50=C2=B5m MM OM2: %s\n",
+			 sfp_link_len(len_om, sizeof(len_om),
+				      sfp->id.base.link_len[2], 10));
+		dev_info(sfp->dev, "   50=C2=B5m MM OM3: %s\n",
+			 sfp_link_len(len_om, sizeof(len_om),
+				      sfp->id.base.link_len[5], 10));
+		dev_info(sfp->dev, "   50=C2=B5m MM OM4: %s\n",
+			 sfp_link_len(len_om, sizeof(len_om),
+				      sfp->id.base.link_len[4], 10));
+	} else {
+		char len[16];
+		dev_info(sfp->dev, "  Copper length: %s\n",
+			 sfp_link_len(len, sizeof(len),
+				      sfp->id.base.link_len[4], 1));
+	}
+
+	dev_info(sfp->dev, "  Options: %s\n",
+		 sfp_bitfield(options, sizeof(options), sfp_options,
+			      be16_to_cpu(sfp->id.ext.options)));
+	dev_info(sfp->dev, "  Diagnostics: %s\n",
+		 sfp_bitfield(options, sizeof(options), diagmon,
+			      sfp->id.ext.diagmon));
=20
 	/* We only support SFP modules, not the legacy GBIC modules. */
 	if (sfp->id.base.phys_id !=3D SFP_PHYS_ID_SFP ||
--=20
2.1.0
