From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 1/2] net: cdc_mbim: handle IPv6 Neigbor Solicitations
Date: Thu, 31 Oct 2013 15:56:10 +0100
Message-ID: <1383231371-8098-2-git-send-email-bjorn@mork.no>
References: <1383231371-8098-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@gmail.com>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34830 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738Ab3JaPCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 11:02:16 -0400
In-Reply-To: <1383231371-8098-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MBIM is a point-to-point protocol transporting raw IP packets
with no L2 headers. Only IPv4 and IPv6 are supported. ARP in
particular is not, which is quite logical given the lack of
L2 headers.

The driver still emulates an ethernet interface, dropping all
unsupported protocols, and avoiding neigbour resolving by
setting the IFF_NOARP flag.

The MBIM specification does not explicitly forbid IPv6 Neighbor
Discovery, and it seems the other OS support will respond to
Neighbor Solicitations on MBIM links. There are therefore
buggy devices out there, which despite the pointlessness, still
require Neighbor Discovery for IPv6 over MBIM.

This is incompatible with the IFF_NOARP flag which disables
both ARP and ND.  We cannot support ARP in any case, so we
have to keep that flag. This patch implements a workaround
for the buggy devices, letting the driver respond directly
to Neighbor Solicitations from the device.

This is not optimal, but will have minimal effect on any sane
device.

Cc: Greg Suarez <gsuarez@smithmicro.com>
Reported-and-tested-by: Thomas Sch=C3=A4fer <tschaefer@t-online.de>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_mbim.c |   58 ++++++++++++++++++++++++++++++++++++=
++++++++
 1 file changed, 58 insertions(+)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 25ba7ec..6533a9f 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -21,6 +21,8 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc-wdm.h>
 #include <linux/usb/cdc_ncm.h>
+#include <net/ipv6.h>
+#include <net/addrconf.h>
=20
 /* driver specific data - must match cdc_ncm usage */
 struct cdc_mbim_state {
@@ -184,6 +186,60 @@ error:
 	return NULL;
 }
=20
+/* Some devices are known to send Neigbor Solicitation messages and
+ * require Neigbor Advertisement replies.  The IPv6 core will not
+ * respond since IFF_NOARP is set, so we must handle them ourselves.
+ */
+static void do_neigh_solicit(struct usbnet *dev, u8 *buf, u16 tci)
+{
+	struct ipv6hdr *iph =3D (void *)buf;
+	struct nd_msg *msg =3D (void *)(iph + 1);
+	struct net_device *netdev;
+	struct inet6_dev *in6_dev;
+	bool is_router;
+
+	/* we'll only respond to requests from unicast addresses to
+	 * our solicited node addresses.
+	 */
+	if (!ipv6_addr_is_solict_mult(&iph->daddr) ||
+	    !(ipv6_addr_type(&iph->saddr) & IPV6_ADDR_UNICAST))
+		return;
+
+	/* need to send the NA on the VLAN dev, if any */
+	if (tci)
+		netdev =3D __vlan_find_dev_deep(dev->net, htons(ETH_P_8021Q),
+					      tci);
+	else
+		netdev =3D dev->net;
+	if (!netdev)
+		return;
+
+	in6_dev =3D in6_dev_get(netdev);
+	if (!in6_dev)
+		return;
+	is_router =3D !!in6_dev->cnf.forwarding;
+	in6_dev_put(in6_dev);
+
+	/* ipv6_stub !=3D NULL if in6_dev_get returned an inet6_dev */
+	ipv6_stub->ndisc_send_na(netdev, NULL, &iph->saddr, &msg->target,
+				 is_router /* router */,
+				 true /* solicited */,
+				 false /* override */,
+				 true /* inc_opt */);
+}
+
+static bool is_neigh_solicit(u8 *buf, size_t len)
+{
+	struct ipv6hdr *iph =3D (void *)buf;
+	struct nd_msg *msg =3D (void *)(iph + 1);
+
+	return (len >=3D sizeof(struct ipv6hdr) + sizeof(struct nd_msg) &&
+		iph->nexthdr =3D=3D IPPROTO_ICMPV6 &&
+		msg->icmph.icmp6_code =3D=3D 0 &&
+		msg->icmph.icmp6_type =3D=3D NDISC_NEIGHBOUR_SOLICITATION);
+}
+
+
 static struct sk_buff *cdc_mbim_process_dgram(struct usbnet *dev, u8 *=
buf, size_t len, u16 tci)
 {
 	__be16 proto =3D htons(ETH_P_802_3);
@@ -198,6 +254,8 @@ static struct sk_buff *cdc_mbim_process_dgram(struc=
t usbnet *dev, u8 *buf, size_
 			proto =3D htons(ETH_P_IP);
 			break;
 		case 0x60:
+			if (is_neigh_solicit(buf, len))
+				do_neigh_solicit(dev, buf, tci);
 			proto =3D htons(ETH_P_IPV6);
 			break;
 		default:
--=20
1.7.10.4
