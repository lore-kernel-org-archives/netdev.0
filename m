From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 1/5] dp83640: Include hash in timestamp/packet matching
Date: Fri, 30 Oct 2015 13:14:00 +0100
Message-ID: <1446207244-2206-2-git-send-email-stefan.sorensen@spectralink.com>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0136.outbound.protection.outlook.com ([157.56.111.136]:46595
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1031021AbbJ3MOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 08:14:30 -0400
In-Reply-To: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only using the message type and sequence id for matching timestamps wit=
h
packets is error prone, particularly if packets can be reordered. Fix b=
y
extending the check to include the hash of bytes 20-29 (source id in PT=
Pv2)
that is provided with the timestamps.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 185b03c..9534478 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -20,6 +20,7 @@
=20
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
=20
+#include <linux/crc32.h>
 #include <linux/ethtool.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
@@ -789,7 +790,7 @@ static int decode_evnt(struct dp83640_private *dp83=
640,
=20
 static int match(struct sk_buff *skb, unsigned int type, struct rxts *=
rxts)
 {
-	u16 *seqid;
+	u16 *seqid, hash;
 	unsigned int offset =3D 0;
 	u8 *msgtype, *data =3D skb_mac_header(skb);
=20
@@ -819,11 +820,18 @@ static int match(struct sk_buff *skb, unsigned in=
t type, struct rxts *rxts)
 		msgtype =3D data + offset + OFF_PTP_CONTROL;
 	else
 		msgtype =3D data + offset;
+	if (rxts->msgtype !=3D (*msgtype & 0xf))
+		return 0;
=20
 	seqid =3D (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
+	if (rxts->seqid !=3D ntohs(*seqid))
+		return 0;
+
+	hash =3D ether_crc(10, data + offset + 20) >> 20;
+	if (rxts->hash !=3D hash)
+		return 0;
=20
-	return rxts->msgtype =3D=3D (*msgtype & 0xf) &&
-		rxts->seqid   =3D=3D ntohs(*seqid);
+	return 1;
 }
=20
 static void decode_rxts(struct dp83640_private *dp83640,
--=20
2.5.0
