From: =?UTF-8?B?SsO2cmc=?= Thalheim <joerg@higgsboson.tk>
Subject: [PATCH] bridge: add ageing_time, stp_state, priority over netlink
Date: Wed, 18 Mar 2015 10:06:58 +0100
Message-ID: <20150318100658.24facc36@turingmachine>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 boundary="Sig_/u4eB.k8hA4J/cEbLpzwyrbN"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.higgsboson.tk ([148.251.132.243]:59696 "EHLO
	mail.higgsboson.tk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755718AbbCRJNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:13:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/u4eB.k8hA4J/cEbLpzwyrbN
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Signed-off-by: J=C3=B6rg Thalheim <joerg@higgsboson.tk>
---
 include/uapi/linux/if_link.h |  3 +++
 net/bridge/br_netlink.c      | 32 +++++++++++++++++++++++++++++++-
 2 files changed, 34 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index dfd0bb2..ca5d838 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -224,6 +224,9 @@ enum {
 	IFLA_BR_FORWARD_DELAY,
 	IFLA_BR_HELLO_TIME,
 	IFLA_BR_MAX_AGE,
+	IFLA_BR_AGEING_TIME,
+	IFLA_BR_STP_STATE,
+	IFLA_BR_PRIORITY,
 	__IFLA_BR_MAX,
 };
=20
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 3de0eef..13ffb66 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -728,6 +728,9 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + =
1] =3D {
 	[IFLA_BR_FORWARD_DELAY]	=3D { .type =3D NLA_U32 },
 	[IFLA_BR_HELLO_TIME]	=3D { .type =3D NLA_U32 },
 	[IFLA_BR_MAX_AGE]	=3D { .type =3D NLA_U32 },
+	[IFLA_BR_AGEING_TIME] =3D { .type =3D NLA_U32 },
+	[IFLA_BR_STP_STATE] =3D { .type =3D NLA_U32 },
+	[IFLA_BR_PRIORITY] =3D { .type =3D NLA_U16 },
 };
=20
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -757,6 +760,24 @@ static int br_changelink(struct net_device *brdev, str=
uct nlattr *tb[],
 			return err;
 	}
=20
+	if (data[IFLA_BR_AGEING_TIME]) {
+		u32 ageing_time =3D nla_get_u32(data[IFLA_BR_AGEING_TIME]);
+
+		br->ageing_time =3D clock_t_to_jiffies(ageing_time);
+	}
+
+	if (data[IFLA_BR_STP_STATE]) {
+		u32 stp_enabled =3D nla_get_u32(data[IFLA_BR_STP_STATE]);
+
+		br_stp_set_enabled(br, stp_enabled);
+	}
+
+	if (data[IFLA_BR_PRIORITY]) {
+		u32 priority =3D nla_get_u16(data[IFLA_BR_PRIORITY]);
+
+		br_stp_set_bridge_priority(br, priority);
+	}
+
 	return 0;
 }
=20
@@ -765,6 +786,9 @@ static size_t br_get_size(const struct net_device *brde=
v)
 	return nla_total_size(sizeof(u32)) +	/* IFLA_BR_FORWARD_DELAY  */
 	       nla_total_size(sizeof(u32)) +	/* IFLA_BR_HELLO_TIME */
 	       nla_total_size(sizeof(u32)) +	/* IFLA_BR_MAX_AGE */
+	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_AGEING_TIME */
+	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_STP_STATE */
+	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_PRIORITY */
 	       0;
 }
=20
@@ -774,10 +798,16 @@ static int br_fill_info(struct sk_buff *skb, const st=
ruct net_device *brdev)
 	u32 forward_delay =3D jiffies_to_clock_t(br->forward_delay);
 	u32 hello_time =3D jiffies_to_clock_t(br->hello_time);
 	u32 age_time =3D jiffies_to_clock_t(br->max_age);
+	u32 ageing_time =3D jiffies_to_clock_t(br->ageing_time);
+	u32 stp_enabled =3D br->stp_enabled;
+	u16 priority =3D (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1];
=20
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
 	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
-	    nla_put_u32(skb, IFLA_BR_MAX_AGE, age_time))
+	    nla_put_u32(skb, IFLA_BR_MAX_AGE, age_time) ||
+	    nla_put_u32(skb, IFLA_BR_AGEING_TIME, ageing_time) ||
+	    nla_put_u32(skb, IFLA_BR_STP_STATE, stp_enabled) ||
+	    nla_put_u16(skb, IFLA_BR_PRIORITY, priority))
 		return -EMSGSIZE;
=20
 	return 0;
--=20
2.3.3


--Sig_/u4eB.k8hA4J/cEbLpzwyrbN
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQF8BAEBCgBmBQJVCUAyXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQ0QUJBMDczODJBRDU3RTZCOUFBNEU4OERD
QTQxMDZCOEQ3Q0M3OUZBAAoJEMpBBrjXzHn6q30H/3CxzFUzmvHFqujptXx2w/UG
tlu7JhbpmcItg9/MmJWzmxGqFgtTAOD988oCMBZG4Gd+p6eZtRCHLzsS6VfF4iLM
mzmLtm/Sq1ScyhOUnCydTVPFEmhM4XwyMhlEMxo1cOiaG41FNbPSrZcukfnSjJoz
cLU9SU/T8nN/pYT5p4Qig+QKTgcz2eL+8Sz1WPSn2vDTMhuDvucnu1zHsW39d1U4
5dV/PIwu4u7NUmkP/B3kvggmrbxAPDS1HyJkNgrtiC4AepOCnwpvrclFk1DiuFVL
Zf5MqBp9mvUHh7HjnmBYlju7498G2oEdLn2kPGnSEdzOMdeiBA8gmQWttdWCyRg=
=RDKC
-----END PGP SIGNATURE-----

--Sig_/u4eB.k8hA4J/cEbLpzwyrbN--
