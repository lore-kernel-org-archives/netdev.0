From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCH net] bridge: fix igmpv3 / mldv2 report parsing
Date: Fri, 11 Sep 2015 18:39:48 +0200
Message-ID: <1441989588-26312-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org,
	Tobias Powalowski <tobias.powalowski@googlemail.com>,
	linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

With the newly introduced helper functions the skb pulling is hidden in
the checksumming function - and undone before returning to the caller.

The IGMPv3 and MLDv2 report parsing functions in the bridge still
assumed that the skb is pointing to the beginning of the IGMP/MLD
message while it is now kept at the beginning of the IPv4/6 header,
breaking the message parsing and creating packet loss.

Fixing this by taking the offset between IP and IGMP/MLD header into
account, too.

Fixes: 9afd85c9e455 ("net: Export IGMP/MLD message validation code")
Reported-by: Tobias Powalowski <tobias.powalowski@googlemail.com>
Tested-by: Tobias Powalowski <tobias.powalowski@googlemail.com>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
---
 net/bridge/br_multicast.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 66efdc2..480b3de 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1006,7 +1006,7 @@ static int br_ip4_multicast_igmp3_report(struct net=
_bridge *br,
=20
 	ih =3D igmpv3_report_hdr(skb);
 	num =3D ntohs(ih->ngrec);
-	len =3D sizeof(*ih);
+	len =3D skb_transport_offset(skb) + sizeof(*ih);
=20
 	for (i =3D 0; i < num; i++) {
 		len +=3D sizeof(*grec);
@@ -1067,7 +1067,7 @@ static int br_ip6_multicast_mld2_report(struct net_=
bridge *br,
=20
 	icmp6h =3D icmp6_hdr(skb);
 	num =3D ntohs(icmp6h->icmp6_dataun.un_data16[1]);
-	len =3D sizeof(*icmp6h);
+	len =3D skb_transport_offset(skb) + sizeof(*icmp6h);
=20
 	for (i =3D 0; i < num; i++) {
 		__be16 *nsrcs, _nsrcs;
--=20
1.7.10.4
