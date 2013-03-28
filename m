From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 01/11] batman-adv: Fix endianness errors for
	network coding
Date: Thu, 28 Mar 2013 08:50:21 +0100
Message-ID: <1364457031-3194-2-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin-SHBFXCSm21MJGwgDXS7ZQA@public.gmane.org>,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1364457031-3194-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Martin Hundeb=C3=B8ll <martin-SHBFXCSm21MJGwgDXS7ZQA@public.gmane.org>

Add a htonl() in network_coding.c when reading the sequence number
from received ogm_packet, to avoid wrong byte ordering when comparing
with a host value. This bug was introduced in
3ed7ada3f0bbcd058567bc0a8f9729a73eba7db6 ("batman-adv: network coding -
detect coding nodes and remove these after timeout").

Change the type of coded_packet->coded_len from uint16 to __be16 to
avoid wrong assumptions about endianness in later uses. Introduced in
c3289f3650d34b60296000a629c99f2488f7c3dd ("batman-adv: network coding -
code and transmit packets if possible").

Reported-by: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Martin Hundeb=C3=B8ll <martin-SHBFXCSm21MJGwgDXS7ZQA@public.gmane.org>
Signed-off-by: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/network-coding.c | 2 +-
 net/batman-adv/packet.h         | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-cod=
ing.c
index 5728079..086c107 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -654,7 +654,7 @@ static bool batadv_can_nc_with_orig(struct batadv_pri=
v *bat_priv,
 				    struct batadv_orig_node *orig_node,
 				    struct batadv_ogm_packet *ogm_packet)
 {
-	if (orig_node->last_real_seqno !=3D ogm_packet->seqno)
+	if (orig_node->last_real_seqno !=3D ntohl(ogm_packet->seqno))
 		return false;
 	if (orig_node->last_ttl !=3D ogm_packet->header.ttl + 1)
 		return false;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index a079958..a51ccfc 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -308,7 +308,7 @@ struct batadv_coded_packet {
 	uint8_t  second_source[ETH_ALEN];
 	uint8_t  second_orig_dest[ETH_ALEN];
 	__be32   second_crc;
-	uint16_t coded_len;
+	__be16   coded_len;
 };
=20
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
--=20
1.8.1.5
