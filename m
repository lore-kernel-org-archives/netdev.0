From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] vxlan: Refactor vxlan_udp_encap_recv() to kill compiler warning
Date: Fri,  4 Sep 2015 12:49:32 +0200
Message-ID: <1441363772-20850-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/vxlan.c: In function =E2=80=98vxlan_udp_encap_recv=E2=80=99=
:
drivers/net/vxlan.c:1226: warning: =E2=80=98info=E2=80=99 may be used u=
ninitialized in this function

While this warning is a false positive, it can be killed easily by
getting rid of the pointer intermediary and referring directly to the
ip_tunnel_info structure.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Compile-tested only.
---
 drivers/net/vxlan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ce988fd01b3486c7..cf8b7f0473b3985a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1223,7 +1223,6 @@ drop:
 static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct metadata_dst *tun_dst =3D NULL;
-	struct ip_tunnel_info *info;
 	struct vxlan_sock *vs;
 	struct vxlanhdr *vxh;
 	u32 flags, vni;
@@ -1270,8 +1269,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, =
struct sk_buff *skb)
 		if (!tun_dst)
 			goto drop;
=20
-		info =3D &tun_dst->u.tun_info;
-		md =3D ip_tunnel_info_opts(info);
+		md =3D ip_tunnel_info_opts(&tun_dst->u.tun_info);
 	} else {
 		memset(md, 0, sizeof(*md));
 	}
@@ -1286,7 +1284,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, =
struct sk_buff *skb)
 		md->gbp =3D ntohs(gbp->policy_id);
=20
 		if (tun_dst)
-			info->key.tun_flags |=3D TUNNEL_VXLAN_OPT;
+			tun_dst->u.tun_info.key.tun_flags |=3D TUNNEL_VXLAN_OPT;
=20
 		if (gbp->dont_learn)
 			md->gbp |=3D VXLAN_GBP_DONT_LEARN;
--=20
1.9.1
