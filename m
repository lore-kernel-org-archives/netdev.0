From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: [PATCHv2 net] bridge: fix igmp / mld query parsing
Date: Wed,  4 May 2016 17:25:02 +0200
Message-ID: <1462375502-8381-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Simon Wunderlich <sw@simonwunderlich.de>, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
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

With the newly introduced helper functions the skb pulling is hidden
in the checksumming function - and undone before returning to the
caller.

The IGMP and MLD query parsing functions in the bridge still
assumed that the skb is pointing to the beginning of the IGMP/MLD
message while it is now kept at the beginning of the IPv4/6 header.

If there is a querier somewhere else, then this either causes
the multicast snooping to stay disabled even though it could be
enabled. Or, if we have the querier enabled too, then this can
create unnecessary IGMP / MLD query messages on the link.

Fixing this by taking the offset between IP and IGMP/MLD header into
account, too.

Fixes: 9afd85c9e455 ("net: Export IGMP/MLD message validation code")
Reported-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
---
v2: changed "int" to "unsigned int"

 net/bridge/br_multicast.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 03661d9..ea98937 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1270,6 +1270,7 @@ static int br_ip4_multicast_query(struct net_bridge=
 *br,
 	struct br_ip saddr;
 	unsigned long max_delay;
 	unsigned long now =3D jiffies;
+	unsigned int offset =3D skb_transport_offset(skb);
 	__be32 group;
 	int err =3D 0;
=20
@@ -1280,14 +1281,14 @@ static int br_ip4_multicast_query(struct net_brid=
ge *br,
=20
 	group =3D ih->group;
=20
-	if (skb->len =3D=3D sizeof(*ih)) {
+	if (skb->len =3D=3D offset + sizeof(*ih)) {
 		max_delay =3D ih->code * (HZ / IGMP_TIMER_SCALE);
=20
 		if (!max_delay) {
 			max_delay =3D 10 * HZ;
 			group =3D 0;
 		}
-	} else if (skb->len >=3D sizeof(*ih3)) {
+	} else if (skb->len >=3D offset + sizeof(*ih3)) {
 		ih3 =3D igmpv3_query_hdr(skb);
 		if (ih3->nsrcs)
 			goto out;
@@ -1348,6 +1349,7 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 	struct br_ip saddr;
 	unsigned long max_delay;
 	unsigned long now =3D jiffies;
+	unsigned int offset =3D skb_transport_offset(skb);
 	const struct in6_addr *group =3D NULL;
 	bool is_general_query;
 	int err =3D 0;
@@ -1357,8 +1359,8 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 	    (port && port->state =3D=3D BR_STATE_DISABLED))
 		goto out;
=20
-	if (skb->len =3D=3D sizeof(*mld)) {
-		if (!pskb_may_pull(skb, sizeof(*mld))) {
+	if (skb->len =3D=3D offset + sizeof(*mld)) {
+		if (!pskb_may_pull(skb, offset + sizeof(*mld))) {
 			err =3D -EINVAL;
 			goto out;
 		}
@@ -1367,7 +1369,7 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 		if (max_delay)
 			group =3D &mld->mld_mca;
 	} else {
-		if (!pskb_may_pull(skb, sizeof(*mld2q))) {
+		if (!pskb_may_pull(skb, offset + sizeof(*mld2q))) {
 			err =3D -EINVAL;
 			goto out;
 		}
--=20
1.7.10.4
