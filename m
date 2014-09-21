From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH] bridge: fix netfilter/NF_BR_LOCAL_OUT for own,
	locally generated queries
Date: Mon, 22 Sep 2014 01:32:44 +0200
Message-ID: <1411342364-4791-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>
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

Ebtables on the OUTPUT chain (NF_BR_LOCAL_OUT) would not work as expected
for both locally generated IGMP and MLD queries. The IP header specific
filter options are off by 14 Bytes for netfilter (actual output on
interfaces is fine).

NF_HOOK()=E2=80=AFexpects the skb->data to point to the IP header, not th=
e
ethernet one (while dev_queue_xmit()=E2=80=AFdoes not). Luckily there is =
an
br_dev_queue_push_xmit() helper function already - let's just use that.

Introduced by eb1d16414339a6e113d89e2cca2556005d7ce919
("bridge: Add core IGMP snooping support")

Ebtables example:

$ ebtables -I OUTPUT -p IPv6 -o eth1 --logical-out br0 \
	--log --log-level 6 --log-ip6 --log-prefix=3D"~EBT: " -j DROP

before (broken):

~EBT:  IN=3D OUT=3Deth1 MAC source =3D 02:04:64:a4:39:c2 \
	MAC dest =3D 33:33:00:00:00:01 proto =3D 0x86dd IPv6 \
	SRC=3D64a4:39c2:86dd:6000:0000:0020:0001:fe80 IPv6 \
	DST=3D0000:0000:0000:0004:64ff:fea4:39c2:ff02, \
	IPv6 priority=3D0x3, Next Header=3D2

after (working):

~EBT:  IN=3D OUT=3Deth1 MAC source =3D 02:04:64:a4:39:c2 \
	MAC dest =3D 33:33:00:00:00:01 proto =3D 0x86dd IPv6 \
	SRC=3Dfe80:0000:0000:0000:0004:64ff:fea4:39c2 IPv6 \
	DST=3Dff02:0000:0000:0000:0000:0000:0000:0001, \
	IPv6 priority=3D0x0, Next Header=3D0

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 7751c92..9d02e6c 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -813,10 +813,9 @@ static void __br_multicast_send_query(struct net_bri=
dge *br,
 		return;
=20
 	if (port) {
-		__skb_push(skb, sizeof(struct ethhdr));
 		skb->dev =3D port->dev;
 		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
-			dev_queue_xmit);
+			br_dev_queue_push_xmit);
 	} else {
 		br_multicast_select_own_querier(br, ip, skb);
 		netif_rx(skb);
--=20
1.7.10.4
