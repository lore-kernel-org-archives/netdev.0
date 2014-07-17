From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH net v3 1/2] bonding: enhance L2 hash helper with packet type
Date: Thu, 17 Jul 2014 14:16:25 +0800
Message-ID: <1405577786-28811-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jianhua Xie <jianhua.xie@freescale.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Pan Jiafei <Jiafei.Pan@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0212.outbound.protection.outlook.com ([207.46.163.212]:59764
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751276AbaGQGUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 02:20:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <jianhua.xie@freescale.com>

Current L2 hash helper calculates destination eth addr and
source ether addr as L2 hash factors.  This patch is adding
packet type ID field into L2 hash factors.  While one of
BOND_XMIT_POLICY_LAYER2 or BOND_XMIT_POLICY_{LAYER|ENCAP}23
is applied, for the 2nd level hash, enhanced hash method can
help to distribute different types of packets like IPv4/IPv6
packets to different slave devices.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: David S. Miller <davem@davemloft.net>
CC: Pan Jiafei <Jiafei.Pan@freescale.com>

Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
---

v3-changes:
 Create another patch for updating bonding.txt.

v2-changes:
 Use the appropriate interface skb_header_pointer()
 to check skb headlen, fragmented packet or not is
 not distinguished any more.

 drivers/net/bonding/bond_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3a451b6..bcff90c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2999,11 +2999,11 @@ static struct notifier_block bond_netdev_notifier = {
 /* L2 hash helper */
 static inline u32 bond_eth_hash(struct sk_buff *skb)
 {
-	struct ethhdr *data = (struct ethhdr *)skb->data;
-
-	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
-		return data->h_dest[5] ^ data->h_source[5];
+	struct ethhdr *ep, hdr_tmp;
 
+	ep = skb_header_pointer(skb, 0, sizeof(hdr_tmp), &hdr_tmp);
+	if (ep)
+		return ep->h_dest[5] ^ ep->h_source[5] ^ ep->h_proto;
 	return 0;
 }
 
-- 
1.8.5
