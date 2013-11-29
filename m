From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net 3/3] net/hsr: Support iproute print_opt ('ip -details
 ...')
Date: Fri, 29 Nov 2013 23:38:16 +0100
Message-ID: <52991758.4030109@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>,
	=?UTF-8?B?RWzDrWFzIE1vbGluYSBNdcOxb3o=?= <elias.molina@ehu.es>,
	Arvid Brodin <arvid.brodin@alten.se>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam2.webland.se ([91.207.112.92]:58452 "EHLO spam2.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953Ab3K2Wp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Nov 2013 17:45:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements the rtnl_link_ops fill_info routine for HSR.

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 include/uapi/linux/if_link.h |  4 +++-
 net/hsr/hsr_netlink.c        | 28 ++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.=
h
index b78566f..6db4601 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -488,7 +488,9 @@ enum {
 	IFLA_HSR_UNSPEC,
 	IFLA_HSR_SLAVE1,
 	IFLA_HSR_SLAVE2,
-	IFLA_HSR_MULTICAST_SPEC,
+	IFLA_HSR_MULTICAST_SPEC,	/* Last byte of supervision addr */
+	IFLA_HSR_SUPERVISION_ADDR,	/* Supervision frame multicast addr */
+	IFLA_HSR_SEQ_NR,
 	__IFLA_HSR_MAX,
 };
=20
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 5325af8..01a5261 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -23,6 +23,8 @@ static const struct nla_policy hsr_policy[IFLA_HSR_MA=
X + 1] =3D {
 	[IFLA_HSR_SLAVE1]		=3D { .type =3D NLA_U32 },
 	[IFLA_HSR_SLAVE2]		=3D { .type =3D NLA_U32 },
 	[IFLA_HSR_MULTICAST_SPEC]	=3D { .type =3D NLA_U8 },
+	[IFLA_HSR_SUPERVISION_ADDR]	=3D { .type =3D NLA_BINARY, .len =3D ETH_=
ALEN },
+	[IFLA_HSR_SEQ_NR]		=3D { .type =3D NLA_U16 },
 };
=20
=20
@@ -59,6 +61,31 @@ static int hsr_newlink(struct net *src_net, struct n=
et_device *dev,
 	return hsr_dev_finalize(dev, link, multicast_spec);
 }
=20
+static int hsr_fill_info(struct sk_buff *skb, const struct net_device =
*dev)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv =3D netdev_priv(dev);
+
+	if (hsr_priv->slave[0])
+		if (nla_put_u32(skb, IFLA_HSR_SLAVE1, hsr_priv->slave[0]->ifindex))
+			goto nla_put_failure;
+
+	if (hsr_priv->slave[1])
+		if (nla_put_u32(skb, IFLA_HSR_SLAVE2, hsr_priv->slave[1]->ifindex))
+			goto nla_put_failure;
+
+	if (nla_put(skb, IFLA_HSR_SUPERVISION_ADDR, ETH_ALEN,
+		    hsr_priv->sup_multicast_addr) ||
+	    nla_put_u16(skb, IFLA_HSR_SEQ_NR, hsr_priv->sequence_nr))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 static struct rtnl_link_ops hsr_link_ops __read_mostly =3D {
 	.kind		=3D "hsr",
 	.maxtype	=3D IFLA_HSR_MAX,
@@ -66,6 +93,7 @@ static struct rtnl_link_ops hsr_link_ops __read_mostl=
y =3D {
 	.priv_size	=3D sizeof(struct hsr_priv),
 	.setup		=3D hsr_dev_setup,
 	.newlink	=3D hsr_newlink,
+	.fill_info	=3D hsr_fill_info,
 };
=20
=20
--=20
1.8.1.5


--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
