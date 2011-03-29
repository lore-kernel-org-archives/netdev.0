From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] net: gre: provide multicast mappings for ipv4 and ipv6
Date: Tue, 29 Mar 2011 11:40:53 +0300
Message-ID: <1301388053-6083-1-git-send-email-timo.teras@iki.fi>
References: <4D8F6313.60408@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Doug Kehn <rdkehn@yahoo.com>,
	=?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:59172 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab1C2IlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 04:41:07 -0400
Received: by ewy4 with SMTP id 4so1419954ewy.19
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2011 01:41:05 -0700 (PDT)
In-Reply-To: <4D8F6313.60408@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My commit 6d55cb91a0020ac0 (gre: fix hard header destination
address checking) broke multicast.

The reason is that ip_gre used to get ipgre_header() calls with
zero destination if we have NOARP or multicast destination. Instead
the actual target was decided at ipgre_tunnel_xmit() time based on
per-protocol dissection.

Instead of allowing the "abuse" of ->header() calls with invalid
destination, this creates multicast mappings for ip_gre. This also
fixes "ip neigh show nud noarp" to display the proper multicast
mappings used by the gre device.

Reported-by: Doug Kehn <rdkehn@yahoo.com>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
Compile tested only. Doug tested IPv4 side with the earlier patch.

The IPv6 side needs a review. I'm not sure if mapped IPv4 multicast
addresses are intrepreted as multicast addresses by ndisc code or
if we could map real IPv6 multicast addresses to IPv4 multicast
addresses.

 include/net/if_inet6.h |   16 ++++++++++++++++
 include/net/ip.h       |    8 ++++++++
 net/ipv4/arp.c         |    3 +++
 net/ipv6/ndisc.c       |    2 ++
 4 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 04977ee..fccc218 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -286,5 +286,21 @@ static inline void ipv6_ib_mc_map(const struct in6=
_addr *addr,
 	buf[9]  =3D broadcast[9];
 	memcpy(buf + 10, addr->s6_addr + 6, 10);
 }
+
+static inline int ipv6_ipgre_mc_map(const struct in6_addr *addr,
+				    const unsigned char *broadcast, char *buf)
+{
+	if ((broadcast[0] | broadcast[1] | broadcast[2] | broadcast[3]) !=3D =
0) {
+		memcpy(buf, broadcast, 4);
+	} else {
+		/* v4mapped? */
+		if ((addr->s6_addr32[0] | addr->s6_addr32[1] |
+		     (addr->s6_addr32[2] ^ htonl(0x0000ffff))) !=3D 0)
+			return -EINVAL;
+		memcpy(buf, &addr->s6_addr32[3], 4);
+	}
+	return 0;
+}
+
 #endif
 #endif
diff --git a/include/net/ip.h b/include/net/ip.h
index a4f6311..7c41658 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -339,6 +339,14 @@ static inline void ip_ib_mc_map(__be32 naddr, cons=
t unsigned char *broadcast, ch
 	buf[16] =3D addr & 0x0f;
 }
=20
+static inline void ip_ipgre_mc_map(__be32 naddr, const unsigned char *=
broadcast, char *buf)
+{
+	if ((broadcast[0] | broadcast[1] | broadcast[2] | broadcast[3]) !=3D =
0)
+		memcpy(buf, broadcast, 4);
+	else
+		memcpy(buf, &naddr, sizeof(naddr));
+}
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #include <linux/ipv6.h>
 #endif
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 090d273..1b74d3b 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -215,6 +215,9 @@ int arp_mc_map(__be32 addr, u8 *haddr, struct net_d=
evice *dev, int dir)
 	case ARPHRD_INFINIBAND:
 		ip_ib_mc_map(addr, dev->broadcast, haddr);
 		return 0;
+	case ARPHRD_IPGRE:
+		ip_ipgre_mc_map(addr, dev->broadcast, haddr);
+		return 0;
 	default:
 		if (dir) {
 			memcpy(haddr, dev->broadcast, dev->addr_len);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0e49c9d..92f952d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -341,6 +341,8 @@ int ndisc_mc_map(struct in6_addr *addr, char *buf, =
struct net_device *dev, int d
 	case ARPHRD_INFINIBAND:
 		ipv6_ib_mc_map(addr, dev->broadcast, buf);
 		return 0;
+	case ARPHRD_IPGRE:
+		return ipv6_ipgre_mc_map(addr, dev->broadcast, buf);
 	default:
 		if (dir) {
 			memcpy(buf, dev->broadcast, dev->addr_len);
--=20
1.7.1

