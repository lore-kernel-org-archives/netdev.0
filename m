From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH net-next 1/2] bridge: prevent flooding IPv6 packets that do not have a listener
Date: Wed,  4 Sep 2013 02:13:38 +0200
Message-ID: <1378253619-23918-2-git-send-email-linus.luessing@web.de>
References: <1378253619-23918-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Cong Wang <amwang@redhat.com>,
	Adam Baker <linux@baker-net.org.uk>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378253619-23918-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently if there is no listener for a certain group then IPv6 packets
for that group are flooded on all ports, even though there might be no
host and router interested in it on a port.

With this commit they are only forwarded to ports with a multicast
router.

Just like commit bd4265fe36 ("bridge: Only flood unregistered groups
to routers") did for IPv4, let's do the same for IPv6 with the same
reasoning.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index bbcb435..662ba7b 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1547,8 +1547,14 @@ static int br_multicast_ipv6_rcv(struct net_brid=
ge *br,
 	 *  - MLD has always Router Alert hop-by-hop option
 	 *  - But we do not support jumbrograms.
 	 */
-	if (ip6h->version !=3D 6 ||
-	    ip6h->nexthdr !=3D IPPROTO_HOPOPTS ||
+	if (ip6h->version !=3D 6)
+		return 0;
+
+	/* Prevent flooding this packet if there is no listener present */
+	if (ipv6_is_transient_multicast(&ip6h->daddr))
+		BR_INPUT_SKB_CB(skb)->mrouters_only =3D 1;
+
+	if (ip6h->nexthdr !=3D IPPROTO_HOPOPTS ||
 	    ip6h->payload_len =3D=3D 0)
 		return 0;
=20
--=20
1.7.10.4
