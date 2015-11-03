From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v2 net-next 1/5] dp83640: Include hash in timestamp/packet matching
Date: Tue, 3 Nov 2015 09:34:04 +0100
Message-ID: <1446539648-8355-2-git-send-email-stefan.sorensen@spectralink.com>
References: <1446539648-8355-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0124.outbound.protection.outlook.com ([65.55.169.124]:15049
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751565AbbKCIho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 03:37:44 -0500
In-Reply-To: <1446539648-8355-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only using the message type and sequence id for matching timestamps
with packets is error prone, as multiple clients may very well be
sending packets with the same messagetype and timestamp at the same
time. Fix by extending the check to include the hash of bytes 20-29
(source id in PTPv2) that is provided with the timestamps.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 185b03c..cae3b3b 100644
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
@@ -787,9 +788,12 @@ static int decode_evnt(struct dp83640_private *dp8=
3640,
 	return parsed;
 }
=20
+#define DP83640_PACKET_HASH_OFFSET	20
+#define DP83640_PACKET_HASH_LEN		10
+
 static int match(struct sk_buff *skb, unsigned int type, struct rxts *=
rxts)
 {
-	u16 *seqid;
+	u16 *seqid, hash;
 	unsigned int offset =3D 0;
 	u8 *msgtype, *data =3D skb_mac_header(skb);
=20
@@ -819,11 +823,19 @@ static int match(struct sk_buff *skb, unsigned in=
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
+	hash =3D ether_crc(DP83640_PACKET_HASH_LEN,
+			 data + offset + DP83640_PACKET_HASH_OFFSET) >> 20;
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
