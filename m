From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: linkwatch: allow vlans to get carrier
 changes faster
Date: Wed, 31 Aug 2011 11:31:58 +0200
Message-ID: <1314783118.2801.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110826060257.5304.62723.stgit@ltc219.sdl.hitachi.co.jp>
	 <20110825230859.11b2b132@nehalam.ftrdhcpuser.net>
	 <20110826064553.GA5874@gondor.apana.org.au>  <4E5A40A9.2000404@hitachi.com>
	 <1314540589.3036.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yrl.pp-manager.tt@hitachi.com
To: HAYASAKA Mitsuo <mitsuo.hayasaka.hu@hitachi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314540589.3036.12.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a time-lag of IFF_RUNNING flag consistency between vlan and
real devices when the real devices are in problem such as link or cable
broken.

This leads to a degradation of Availability such as a delay of failover
in HA systems using vlan since the detection of the problem at real
device is delayed.

We can avoid the linkwatch delay (~1 sec) for devices linked to another
ones, since delay is already done for the realdev.

Based on a previous patch from Mitsuo Hayasaka

Reported-by: Mitsuo Hayasaka <mitsuo.hayasaka.hu@hitachi.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: Tom Herbert <therbert@google.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jesse Gross <jesse@nicira.com>
---
 net/core/link_watch.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index 357bd4e..c3519c6 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -78,8 +78,13 @@ static void rfc2863_policy(struct net_device *dev)
=20
 static bool linkwatch_urgent_event(struct net_device *dev)
 {
-	return netif_running(dev) && netif_carrier_ok(dev) &&
-		qdisc_tx_changing(dev);
+	if (!netif_running(dev))
+		return false;
+
+	if (dev->ifindex !=3D dev->iflink)
+		return true;
+
+	return netif_carrier_ok(dev) &&	qdisc_tx_changing(dev);
 }
=20
=20
