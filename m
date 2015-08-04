From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 14/14] batman-adv: Fix potentially broken skb network header access
Date: Tue,  4 Aug 2015 18:35:34 +0200
Message-ID: <1438706134-3492-15-git-send-email-antonio__4983.52802028439$1438706748$gmane$org@meshcoding.com>
References: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:31572 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751228AbbHDQpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 12:45:31 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@c0d3.blue>

The two commits noted below added calls to ip_hdr() and ipv6_hdr(). The=
y
need a correctly set skb network header.

Unfortunately we cannot rely on the device drivers to set it for us.
Therefore setting it in the beginning of the according ndo_start_xmit
handler.

=46ixes: 1d8ab8d3c176 ("batman-adv: Modified forwarding behaviour for m=
ulticast packets")
=46ixes: ab49886e3da7 ("batman-adv: Add IPv4 link-local/IPv6-ll-all-nod=
es multicast support")
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/soft-interface.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index a2fc843..51cda3a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -202,6 +202,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	int gw_mode;
 	enum batadv_forw_mode forw_mode;
 	struct batadv_orig_node *mcast_single_orig =3D NULL;
+	int network_offset =3D ETH_HLEN;
=20
 	if (atomic_read(&bat_priv->mesh_state) !=3D BATADV_MESH_ACTIVE)
 		goto dropped;
@@ -214,14 +215,18 @@ static int batadv_interface_tx(struct sk_buff *sk=
b,
 	case ETH_P_8021Q:
 		vhdr =3D vlan_eth_hdr(skb);
=20
-		if (vhdr->h_vlan_encapsulated_proto !=3D ethertype)
+		if (vhdr->h_vlan_encapsulated_proto !=3D ethertype) {
+			network_offset +=3D VLAN_HLEN;
 			break;
+		}
=20
 		/* fall through */
 	case ETH_P_BATMAN:
 		goto dropped;
 	}
=20
+	skb_set_network_header(skb, network_offset);
+
 	if (batadv_bla_tx(bat_priv, skb, vid))
 		goto dropped;
=20
--=20
2.5.0
