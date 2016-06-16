From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bridge: netfilter: spanning tree: Add
 masked_ether_addr_equal and neatening
Date: Wed, 15 Jun 2016 23:04:04 -0700
Message-ID: <1466057044.19647.42.camel@perches.com>
References: <f39576f17e9f5dee35258917917f2d740e820a77.1466024030.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <f39576f17e9f5dee35258917917f2d740e820a77.1466024030.git.joe@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-06-15 at 13:58 -0700, Joe Perches wrote:
> There is code duplication of a masked ethernet address comparison her=
e
> so make it a separate function instead.
>=20
> Miscellanea:
>=20
> o Neaten alignment of FWINV macro uses to make it clearer for the rea=
der
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>=20
> This masked_ether_addr_equal function could go into etherdevice.h,
> but I don't see another use like it in kernel code.=A0=A0Is there one=
?

Turns out there are at least a few more uses in bridge/netfilter

=A0net/bridge/netfilter/ebt_arp.c
=A0net/bridge/netfilter/ebtables.c

Maybe this?
---
=46rom 770261c682a745b8de663a5756a66cd00bb5b79b Mon Sep 17 00:00:00 200=
1
Message-Id: <770261c682a745b8de663a5756a66cd00bb5b79b.1466056695.git.jo=
e@perches.com>
=46rom: Joe Perches <joe@perches.com>
Date: Wed, 15 Jun 2016 13:45:54 -0700
Subject: [PATCH] etherdevice.h & bridge: netfilter: Add and use
=A0ether_addr_equal_masked

There are code duplications of a masked ethernet address comparison her=
e
so make it a separate function instead.

Miscellanea:

o Neaten alignment of FWINV macro uses to make it clearer for the reade=
r

Signed-off-by: Joe Perches <joe@perches.com>
---
=A0include/linux/etherdevice.h=A0=A0=A0=A0=A0| 22 ++++++++++++++++++
=A0net/bridge/netfilter/ebt_arp.c=A0=A0| 17 +++++---------
=A0net/bridge/netfilter/ebt_stp.c=A0=A0| 49 ++++++++++++++++++---------=
--------------
=A0net/bridge/netfilter/ebtables.c | 17 +++++---------
=A04 files changed, 56 insertions(+), 49 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 37ff4a6..942a24c 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -374,6 +374,28 @@ static inline bool ether_addr_equal_unaligned(cons=
t u8 *addr1, const u8 *addr2)
=A0}
=A0
=A0/**
+ * ether_addr_equal_masked - Compare two Ethernet addresses with a mas=
k
+ * @addr1: Pointer to a six-byte array containing the 1st Ethernet add=
ress
+ * @addr2: Pointer to a six-byte array containing the 2nd Ethernet add=
ress
+ * @mask: Pointer to a six-byte array containing the Ethernet address =
bitmask
+ *
+ * Compare two Ethernet addresses with a mask, returns true if for eve=
ry bit
+ * set in the bitmask the equivalent bits in the ethernet addresses ar=
e equal.
+ */
+static inline bool ether_addr_equal_masked(const u8 *addr1, const u8 *=
addr2,
+					=A0=A0=A0const u8 *mask)
+{
+	int i;
+
+	for (i =3D 0; i < ETH_ALEN; i++) {
+		if ((addr1[i] ^ addr2[i]) & mask[i])
+			return false;
+	}
+
+	return true;
+}
+
+/**
=A0 * is_etherdev_addr - Tell if given Ethernet address belongs to the =
device.
=A0 * @dev: Pointer to a device structure
=A0 * @addr: Pointer to a six-byte array containing the Ethernet addres=
s
diff --git a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_=
arp.c
index cd457b8..cca0a89 100644
--- a/net/bridge/netfilter/ebt_arp.c
+++ b/net/bridge/netfilter/ebt_arp.c
@@ -65,7 +65,6 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_actio=
n_param *par)
=A0	if (info->bitmask & (EBT_ARP_SRC_MAC | EBT_ARP_DST_MAC)) {
=A0		const unsigned char *mp;
=A0		unsigned char _mac[ETH_ALEN];
-		uint8_t verdict, i;
=A0
=A0		if (ah->ar_hln !=3D ETH_ALEN || ah->ar_hrd !=3D htons(ARPHRD_ETHER=
))
=A0			return false;
@@ -74,11 +73,9 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_acti=
on_param *par)
=A0						sizeof(_mac), &_mac);
=A0			if (mp =3D=3D NULL)
=A0				return false;
-			verdict =3D 0;
-			for (i =3D 0; i < 6; i++)
-				verdict |=3D (mp[i] ^ info->smaddr[i]) &
-				=A0=A0=A0=A0=A0=A0=A0info->smmsk[i];
-			if (FWINV(verdict !=3D 0, EBT_ARP_SRC_MAC))
+			if (FWINV(!ether_addr_equal_masked(mp, info->smaddr,
+							=A0=A0=A0info->smmsk),
+				=A0=A0EBT_ARP_SRC_MAC))
=A0				return false;
=A0		}
=A0
@@ -88,11 +85,9 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_acti=
on_param *par)
=A0						sizeof(_mac), &_mac);
=A0			if (mp =3D=3D NULL)
=A0				return false;
-			verdict =3D 0;
-			for (i =3D 0; i < 6; i++)
-				verdict |=3D (mp[i] ^ info->dmaddr[i]) &
-					info->dmmsk[i];
-			if (FWINV(verdict !=3D 0, EBT_ARP_DST_MAC))
+			if (FWINV(!ether_addr_equal_masked(mp, info->dmaddr,
+							=A0=A0=A0info->dmmsk),
+				=A0=A0EBT_ARP_DST_MAC))
=A0				return false;
=A0		}
=A0	}
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_=
stp.c
index e77f90b..45f73d5 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -46,7 +46,6 @@ static bool ebt_filter_config(const struct ebt_stp_in=
fo *info,
=A0	const struct ebt_stp_config_info *c;
=A0	u16 v16;
=A0	u32 v32;
-	int verdict, i;
=A0
=A0	c =3D &info->config;
=A0	if ((info->bitmask & EBT_STP_FLAGS) &&
@@ -54,66 +53,62 @@ static bool ebt_filter_config(const struct ebt_stp_=
info *info,
=A0		return false;
=A0	if (info->bitmask & EBT_STP_ROOTPRIO) {
=A0		v16 =3D NR16(stpc->root);
-		if (FWINV(v16 < c->root_priol ||
-		=A0=A0=A0=A0v16 > c->root_priou, EBT_STP_ROOTPRIO))
+		if (FWINV(v16 < c->root_priol || v16 > c->root_priou,
+			=A0=A0EBT_STP_ROOTPRIO))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_ROOTADDR) {
-		verdict =3D 0;
-		for (i =3D 0; i < 6; i++)
-			verdict |=3D (stpc->root[2+i] ^ c->root_addr[i]) &
-				=A0=A0=A0c->root_addrmsk[i];
-		if (FWINV(verdict !=3D 0, EBT_STP_ROOTADDR))
+		if (FWINV(!ether_addr_equal_masked(&stpc->root[2], c->root_addr,
+						=A0=A0=A0c->root_addrmsk),
+			=A0=A0EBT_STP_ROOTADDR))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_ROOTCOST) {
=A0		v32 =3D NR32(stpc->root_cost);
-		if (FWINV(v32 < c->root_costl ||
-		=A0=A0=A0=A0v32 > c->root_costu, EBT_STP_ROOTCOST))
+		if (FWINV(v32 < c->root_costl || v32 > c->root_costu,
+			=A0=A0EBT_STP_ROOTCOST))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_SENDERPRIO) {
=A0		v16 =3D NR16(stpc->sender);
-		if (FWINV(v16 < c->sender_priol ||
-		=A0=A0=A0=A0v16 > c->sender_priou, EBT_STP_SENDERPRIO))
+		if (FWINV(v16 < c->sender_priol || v16 > c->sender_priou,
+			=A0=A0EBT_STP_SENDERPRIO))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_SENDERADDR) {
-		verdict =3D 0;
-		for (i =3D 0; i < 6; i++)
-			verdict |=3D (stpc->sender[2+i] ^ c->sender_addr[i]) &
-				=A0=A0=A0c->sender_addrmsk[i];
-		if (FWINV(verdict !=3D 0, EBT_STP_SENDERADDR))
+		if (FWINV(!ether_addr_equal_masked(&stpc->sender[2],
+						=A0=A0=A0c->sender_addr,
+						=A0=A0=A0c->sender_addrmsk),
+			=A0=A0EBT_STP_SENDERADDR))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_PORT) {
=A0		v16 =3D NR16(stpc->port);
-		if (FWINV(v16 < c->portl ||
-		=A0=A0=A0=A0v16 > c->portu, EBT_STP_PORT))
+		if (FWINV(v16 < c->portl || v16 > c->portu, EBT_STP_PORT))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_MSGAGE) {
=A0		v16 =3D NR16(stpc->msg_age);
-		if (FWINV(v16 < c->msg_agel ||
-		=A0=A0=A0=A0v16 > c->msg_ageu, EBT_STP_MSGAGE))
+		if (FWINV(v16 < c->msg_agel || v16 > c->msg_ageu,
+			=A0=A0EBT_STP_MSGAGE))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_MAXAGE) {
=A0		v16 =3D NR16(stpc->max_age);
-		if (FWINV(v16 < c->max_agel ||
-		=A0=A0=A0=A0v16 > c->max_ageu, EBT_STP_MAXAGE))
+		if (FWINV(v16 < c->max_agel || v16 > c->max_ageu,
+			=A0=A0EBT_STP_MAXAGE))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_HELLOTIME) {
=A0		v16 =3D NR16(stpc->hello_time);
-		if (FWINV(v16 < c->hello_timel ||
-		=A0=A0=A0=A0v16 > c->hello_timeu, EBT_STP_HELLOTIME))
+		if (FWINV(v16 < c->hello_timel || v16 > c->hello_timeu,
+			=A0=A0EBT_STP_HELLOTIME))
=A0			return false;
=A0	}
=A0	if (info->bitmask & EBT_STP_FWDD) {
=A0		v16 =3D NR16(stpc->forward_delay);
-		if (FWINV(v16 < c->forward_delayl ||
-		=A0=A0=A0=A0v16 > c->forward_delayu, EBT_STP_FWDD))
+		if (FWINV(v16 < c->forward_delayl || v16 > c->forward_delayu,
+			=A0=A0EBT_STP_FWDD))
=A0			return false;
=A0	}
=A0	return true;
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebt=
ables.c
index 5a61f35..5721a25 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -130,7 +130,6 @@ ebt_basic_match(const struct ebt_entry *e, const st=
ruct sk_buff *skb,
=A0	const struct ethhdr *h =3D eth_hdr(skb);
=A0	const struct net_bridge_port *p;
=A0	__be16 ethproto;
-	int verdict, i;
=A0
=A0	if (skb_vlan_tag_present(skb))
=A0		ethproto =3D htons(ETH_P_8021Q);
@@ -157,19 +156,15 @@ ebt_basic_match(const struct ebt_entry *e, const =
struct sk_buff *skb,
=A0		return 1;
=A0
=A0	if (e->bitmask & EBT_SOURCEMAC) {
-		verdict =3D 0;
-		for (i =3D 0; i < 6; i++)
-			verdict |=3D (h->h_source[i] ^ e->sourcemac[i]) &
-			=A0=A0=A0e->sourcemsk[i];
-		if (FWINV2(verdict !=3D 0, EBT_ISOURCE))
+		if (FWINV2(!ether_addr_equal_masked(h->h_source,
+						=A0=A0=A0=A0e->sourcemac, e->sourcemsk),
+			=A0=A0=A0EBT_ISOURCE))
=A0			return 1;
=A0	}
=A0	if (e->bitmask & EBT_DESTMAC) {
-		verdict =3D 0;
-		for (i =3D 0; i < 6; i++)
-			verdict |=3D (h->h_dest[i] ^ e->destmac[i]) &
-			=A0=A0=A0e->destmsk[i];
-		if (FWINV2(verdict !=3D 0, EBT_IDEST))
+		if (FWINV2(!ether_addr_equal_masked(h->h_dest,
+						=A0=A0=A0=A0e->destmac, e->destmsk),
+			=A0=A0=A0EBT_IDEST))
=A0			return 1;
=A0	}
=A0	return 0;
--=A0
2.8.0.rc4.16.g56331f8

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
