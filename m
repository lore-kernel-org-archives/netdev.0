From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in
 2.6.36.3
Date: Wed, 12 Jan 2011 19:14:12 +0100
Message-ID: <1294856052.3981.125.camel@edumazet-laptop>
References: <314995.84049.qm@web121708.mail.ne1.yahoo.com>
	 <1294853710.3981.108.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1101120958080.5816@JBRANDEB-DESK2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Chris Rankin <rankincj@yahoo.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52229 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab1ALSOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 13:14:17 -0500
Received: by wyb28 with SMTP id 28so853866wyb.19
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 10:14:16 -0800 (PST)
In-Reply-To: <alpine.WNT.2.00.1101120958080.5816@JBRANDEB-DESK2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 janvier 2011 =C3=A0 10:05 -0800, Brandeburg, Jesse a =C3=
=A9crit :

> First, I don't think the following comment should hold up this patch.
>=20
> As a policy question when I asked about using __GFP_NOWARN before in =
other=20
> Intel ethernet drivers the consensus seemed to be that the warning=20
> messages were useful.  All our drivers correctly handle runtime memor=
y=20
> failures, but none of them are currently using __GFP_NOWARN.
>=20
> Can I submit patches to change our other drivers to __GFP_NOWARN?  I =
think=20
> it will make for quite a few less reports of non-issues to the list. =
 All=20
> our drivers that I would be patching already have ethtool counters th=
at=20
> count failed allocations.
>=20

If an allocation failure is really handled, in the sense NIC doesnt
freeze but only lose one incoming frame, then probably yes.

I think the warning message can be useful when driver is known to let
things in a non working state ;)

As you said, this can be done later, here is a respin without this bit.

Thanks !

[PATCH v2] e100: use GFP_KERNEL allocations at device init stage

In lowmem conditions, e100 driver can fail its initialization, because
of GFP_ATOMIC abuse.

Switch to GFP_KERNEL were applicable.

Reported-by: Chris Rankin <rankincj@yahoo.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e100.c |   22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index b0aa9e6..c9a2126 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -1880,9 +1880,21 @@ static inline void e100_start_receiver(struct ni=
c *nic, struct rx *rx)
 }
=20
 #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
-static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
+
+static struct sk_buff *e100_alloc_skb(struct net_device *dev, gfp_t fl=
ags)
+{
+	struct sk_buff *skb;
+
+	skb =3D __netdev_alloc_skb(dev, RFD_BUF_LEN + NET_IP_ALIGN, flags);
+	if (NET_IP_ALIGN && skb)
+		skb_reserve(skb, NET_IP_ALIGN);
+	return skb;
+}
+
+static int e100_rx_alloc_skb(struct nic *nic, struct rx *rx, gfp_t fla=
gs)
 {
-	if (!(rx->skb =3D netdev_alloc_skb_ip_align(nic->netdev, RFD_BUF_LEN)=
))
+	rx->skb =3D e100_alloc_skb(nic->netdev, flags);
+	if (!rx->skb)
 		return -ENOMEM;
=20
 	/* Init, and map the RFD. */
@@ -2026,7 +2038,7 @@ static void e100_rx_clean(struct nic *nic, unsign=
ed int *work_done,
=20
 	/* Alloc new skbs to refill list */
 	for (rx =3D nic->rx_to_use; !rx->skb; rx =3D nic->rx_to_use =3D rx->n=
ext) {
-		if (unlikely(e100_rx_alloc_skb(nic, rx)))
+		if (unlikely(e100_rx_alloc_skb(nic, rx, GFP_ATOMIC)))
 			break; /* Better luck next time (see watchdog) */
 	}
=20
@@ -2102,13 +2114,13 @@ static int e100_rx_alloc_list(struct nic *nic)
 	nic->rx_to_use =3D nic->rx_to_clean =3D NULL;
 	nic->ru_running =3D RU_UNINITIALIZED;
=20
-	if (!(nic->rxs =3D kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
+	if (!(nic->rxs =3D kcalloc(count, sizeof(struct rx), GFP_KERNEL)))
 		return -ENOMEM;
=20
 	for (rx =3D nic->rxs, i =3D 0; i < count; rx++, i++) {
 		rx->next =3D (i + 1 < count) ? rx + 1 : nic->rxs;
 		rx->prev =3D (i =3D=3D 0) ? nic->rxs + count - 1 : rx - 1;
-		if (e100_rx_alloc_skb(nic, rx)) {
+		if (e100_rx_alloc_skb(nic, rx, GFP_KERNEL)) {
 			e100_rx_clean_list(nic);
 			return -ENOMEM;
 		}


