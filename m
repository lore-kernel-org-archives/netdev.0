From: Kamal Mostafa <kamal@canonical.com>
Subject: [PATCH 3.19.y-ckt 182/210] =?UTF-8?q?veth:=20don=E2=80=99t=20modify=20ip=5Fs?= =?UTF-8?q?ummed;=20doing=20so=20treats=20packets=20with=20bad=20checksums?= =?UTF-8?q?=20as=20good.?=
Date: Thu, 28 Jan 2016 17:18:40 -0800
Message-ID: <1454030348-17736-183-git-send-email-kamal@canonical.com>
References: <1454030348-17736-1-git-send-email-kamal@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org, Vijay Pandurangan <vijayp@vijayp.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Kamal Mostafa <kamal@canonical.com>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	kernel-team@lists.ubuntu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454030348-17736-1-git-send-email-kamal@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

3.19.8-ckt14 -stable review patch.  If anyone has any objections, pleas=
e let me know.

---8<------------------------------------------------------------

=46rom: Vijay Pandurangan <vijayp@vijayp.ca>

[ Upstream commit ce8c839b74e3017996fad4e1b7ba2e2625ede82f ]

Packets that arrive from real hardware devices have ip_summed =3D=3D
CHECKSUM_UNNECESSARY if the hardware verified the checksums, or
CHECKSUM_NONE if the packet is bad or it was unable to verify it. The
current version of veth will replace CHECKSUM_NONE with
CHECKSUM_UNNECESSARY, which causes corrupt packets routed from hardware=
 to
a veth device to be delivered to the application. This caused applicati=
ons
at Twitter to receive corrupt data when network hardware was corrupting
packets.

We believe this was added as an optimization to skip computing and
verifying checksums for communication between containers. However, loca=
lly
generated packets have ip_summed =3D=3D CHECKSUM_PARTIAL, so the code a=
s
written does nothing for them. As far as we can tell, after removing th=
is
code, these packets are transmitted from one stack to another unmodifie=
d
(tcpdump shows invalid checksums on both sides, as expected), and they =
are
delivered correctly to applications. We didn=E2=80=99t test every possi=
ble network
configuration, but we tried a few common ones such as bridging containe=
rs,
using NAT between the host and a container, and routing from hardware
devices to containers. We have effectively deployed this in production =
at
Twitter (by disabling RX checksum offloading on veth devices).

This code dates back to the first version of the driver, commit
<e314dbdc1c0dc6a548ecf> ("[NET]: Virtual ethernet device driver"), so I
suspect this bug occurred mostly because the driver API has evolved
significantly since then. Commit <0b7967503dc97864f283a> ("net/veth: Fi=
x
packet checksumming") (in December 2010) fixed this for packets that ge=
t
created locally and sent to hardware devices, by not changing
CHECKSUM_PARTIAL. However, the same issue still occurs for packets comi=
ng
in from hardware devices.

Co-authored-by: Evan Jones <ej@evanjones.ca>
Signed-off-by: Evan Jones <ej@evanjones.ca>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Phil Sutter <phil@nwl.cc>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Vijay Pandurangan <vijayp@vijayp.ca>
Acked-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Kamal Mostafa <kamal@canonical.com>
---
 drivers/net/veth.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8ad5965..32ce1cd 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -117,12 +117,6 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, =
struct net_device *dev)
 		kfree_skb(skb);
 		goto drop;
 	}
-	/* don't change ip_summed =3D=3D CHECKSUM_PARTIAL, as that
-	 * will cause bad checksum on forwarded packets
-	 */
-	if (skb->ip_summed =3D=3D CHECKSUM_NONE &&
-	    rcv->features & NETIF_F_RXCSUM)
-		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
 	if (likely(dev_forward_skb(rcv, skb) =3D=3D NET_RX_SUCCESS)) {
 		struct pcpu_vstats *stats =3D this_cpu_ptr(dev->vstats);
--=20
1.9.1
