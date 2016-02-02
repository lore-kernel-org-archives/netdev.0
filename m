From: Kamal Mostafa <kamal@canonical.com>
Subject: =?UTF-8?q?=5B3=2E13=2Ey-ckt=20stable=5D=20Patch=20=22=3D=3FUTF-8=3Fq=3Fveth=3A=3D20don=3DE2=3D80=3D99t=3D20modify=3D20ip=3D5Fsummed=3B=3D20doing=3F=3D=20=3D=3FUTF-8=3Fq=3F=3D20so=3D20treats=3D20packets=3D20with=3D20bad=3D20checksums=3D20as=3D20good=2E=3F=3D=22=20has=20been=20added=20to=20the=203=2E13=2Ey-ckt=20tree?=
Date: Tue,  2 Feb 2016 09:36:17 -0800
Message-ID: <1454434577-12403-1-git-send-email-kamal@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Cong Wang <cwang@twopensource.com>,
	"David S. Miller" <davem@davemloft.net>,
	Kamal Mostafa <kamal@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a note to let you know that I have just added a patch titled

    =3D?UTF-8?q?veth:=3D20don=3DE2=3D80=3D99t=3D20modify=3D20ip=3D5Fsum=
med;=3D20doing?=3D =3D?UTF-8?q?=3D20so=3D20treats=3D20packets=3D20with=3D=
20bad=3D20checksums=3D20as=3D20good.?=3D

to the linux-3.13.y-queue branch of the 3.13.y-ckt extended stable tree=
=20
which can be found at:

    http://kernel.ubuntu.com/git/ubuntu/linux.git/log/?h=3Dlinux-3.13.y=
-queue

This patch is scheduled to be released in version 3.13.11-ckt34.

If you, or anyone else, feels it should not be added to this tree, plea=
se=20
reply to this email.

=46or more information about the 3.13.y-ckt tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Kamal

---8<------------------------------------------------------------

=46rom 707eea8be46c3bd8ef61cea1d105dbecdb937e8b Mon Sep 17 00:00:00 200=
1
=46rom: Vijay Pandurangan <vijayp@vijayp.ca>
Date: Fri, 18 Dec 2015 14:34:59 -0500
Subject: =3D?UTF-8?q?veth:=3D20don=3DE2=3D80=3D99t=3D20modify=3D20ip=3D=
5Fsummed;=3D20doing?=3D
 =3D?UTF-8?q?=3D20so=3D20treats=3D20packets=3D20with=3D20bad=3D20checks=
ums=3D20as=3D20good.?=3D
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

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
index 5b37437..887e698 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -116,12 +116,6 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, =
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

 	if (likely(dev_forward_skb(rcv, skb) =3D=3D NET_RX_SUCCESS)) {
 		struct pcpu_vstats *stats =3D this_cpu_ptr(dev->vstats);
