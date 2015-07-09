From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next] rocker: forward packets to CPU when a port in promiscuous mode
Date: Thu,  9 Jul 2015 13:25:31 +0900
Message-ID: <1436415931-16469-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:32818 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbbGIE1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 00:27:38 -0400
Received: by pdbqm3 with SMTP id qm3so14090327pdb.0
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 21:27:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows the CPU to see all packets seen by a port when the
netdev associated with the port is in promiscuous mode.

This change was previously posted as part of a larger patch and in turn
patchset which also aimed to allow rocker interfaces to receive packets
when not bridged. That problem has subsequently been addressed in a
different way by Scott Feldman.

When this change was previously posted Scott indicated that he had some
reservations about sending all packets from a switch to the CPU. The
purpose of posting this patch is to start discussion of weather this
approach is appropriate and if not how else we might move forwards.

In my opinion if host doesn't want all packets its shouldn't put a port
in promiscuous mode. But perhaps that is an overly na=C3=AFve view to t=
ake.

My main motivation for this change at this time is to allow rocker to
work with Open vSwitch and it appears that this change is sufficient to
reach that goal. Another approach might be to teach
rocker_port_master_changed() about Open vSwitch.

In the longer term I believe Open vSwitch should be able to program
flows into rocker 'hardware' and thus not all packets would reach the C=
PU.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.c | 33 ++++++++++++++++++++++++++++=
+----
 1 file changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/etherne=
t/rocker/rocker.c
index 2d8578cade03..9e812b85b421 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -199,6 +199,7 @@ struct rocker;
 enum {
 	ROCKER_CTRL_LINK_LOCAL_MCAST,
 	ROCKER_CTRL_LOCAL_ARP,
+	ROCKER_CTRL_PROMISC,
 	ROCKER_CTRL_IPV4_MCAST,
 	ROCKER_CTRL_IPV6_MCAST,
 	ROCKER_CTRL_DFLT_BRIDGING,
@@ -3222,6 +3223,12 @@ static struct rocker_ctrl {
 		.eth_type =3D htons(ETH_P_ARP),
 		.acl =3D true,
 	},
+	[ROCKER_CTRL_PROMISC] =3D {
+		/* pass all pkts up to CPU */
+		.eth_dst =3D zero_mac,
+		.eth_dst_mask =3D zero_mac,
+		.acl =3D true,
+	},
 	[ROCKER_CTRL_IPV4_MCAST] =3D {
 		/* pass IPv4 mcast pkts up to CPU, RFC 1112 */
 		.eth_dst =3D ipv4_mcast,
@@ -3755,13 +3762,19 @@ static int rocker_port_stp_update(struct rocker=
_port *rocker_port,
 		break;
 	case BR_STATE_LEARNING:
 	case BR_STATE_FORWARDING:
-		want[ROCKER_CTRL_LINK_LOCAL_MCAST] =3D true;
+		if (!(rocker_port->dev->flags & IFF_PROMISC))
+			want[ROCKER_CTRL_LINK_LOCAL_MCAST] =3D true;
 		want[ROCKER_CTRL_IPV4_MCAST] =3D true;
 		want[ROCKER_CTRL_IPV6_MCAST] =3D true;
-		if (rocker_port_is_bridged(rocker_port))
+		if (rocker_port_is_bridged(rocker_port)) {
 			want[ROCKER_CTRL_DFLT_BRIDGING] =3D true;
-		else
-			want[ROCKER_CTRL_LOCAL_ARP] =3D true;
+		} else {
+			if (rocker_port->dev->flags & IFF_PROMISC) {
+				want[ROCKER_CTRL_PROMISC] =3D true;
+			} else {
+				want[ROCKER_CTRL_LOCAL_ARP] =3D true;
+			}
+		}
 		break;
 	}
=20
@@ -4152,6 +4165,17 @@ static int rocker_port_set_mac_address(struct ne=
t_device *dev, void *p)
 	return 0;
 }
=20
+static void rocker_port_change_rx_flags(struct net_device *dev, int ch=
ange)
+{
+	struct rocker_port *rocker_port =3D netdev_priv(dev);
+
+	if (change & IFF_PROMISC && rocker_port->dev->flags & IFF_UP)
+		if (!rocker_port_fwd_disable(rocker_port,
+					     SWITCHDEV_TRANS_NONE, 0))
+			rocker_port_fwd_enable(rocker_port,
+					       SWITCHDEV_TRANS_NONE, 0);
+}
+
 static int rocker_port_get_phys_port_name(struct net_device *dev,
 					  char *buf, size_t len)
 {
@@ -4171,6 +4195,7 @@ static const struct net_device_ops rocker_port_ne=
tdev_ops =3D {
 	.ndo_open			=3D rocker_port_open,
 	.ndo_stop			=3D rocker_port_stop,
 	.ndo_start_xmit			=3D rocker_port_xmit,
+	.ndo_change_rx_flags		=3D rocker_port_change_rx_flags,
 	.ndo_set_mac_address		=3D rocker_port_set_mac_address,
 	.ndo_bridge_getlink		=3D switchdev_port_bridge_getlink,
 	.ndo_bridge_setlink		=3D switchdev_port_bridge_setlink,
--=20
2.1.4
