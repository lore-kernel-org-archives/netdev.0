From: Vijay Pandurangan <vijayp@vijayp.ca>
Subject: [PATCH] veth: don't modify ip-summed; doing so treats packets with
 bad checksums as good.
Date: Fri, 18 Dec 2015 10:54:23 -0700
Message-ID: <CAKoqxG=R566bG2sQzWabAaaoUZjUJfoVP7k7dcYK4QuEcH0jrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ej@evanjones.ca
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 drivers/net/veth.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0ef4a5a..ba21d07 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -117,12 +117,6 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb,
struct net_device *dev)
  kfree_skb(skb);
  goto drop;
  }
- /* don't change ip_summed =3D=3D CHECKSUM_PARTIAL, as that
- * will cause bad checksum on forwarded packets
- */
- if (skb->ip_summed =3D=3D CHECKSUM_NONE &&
-    rcv->features & NETIF_F_RXCSUM)
- skb->ip_summed =3D CHECKSUM_UNNECESSARY;

  if (likely(dev_forward_skb(rcv, skb) =3D=3D NET_RX_SUCCESS)) {
  struct pcpu_vstats *stats =3D this_cpu_ptr(dev->vstats);
--=20
2.5.0
