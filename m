From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc3 1/5] r8169: endianness fixes
Date: Sat, 12 Feb 2005 00:39:18 +0100
Message-ID: <20050211233918.GB8792@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, jdmason@us.ibm.com, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Endianness fixes

- rtl8169_rx_csum() forgot to convert the descriptor to cpu order,
- same thing for rtl8169_rx_vlan_skb() but this one is more tricky as
  the layout of the (u32) word in the 8169 descriptor calls for a
  second level of swap at the vlan tag level (u16). The old code only
  did the second part (in an endian-dependant way, how fun).
- rtl8169_tx_vlan_tag(): this time the (u32 descriptor level) cpu_to_le32
  is issued in rtl8169_start_xmit but the (u16 vlan tag level) cpu_to_be16
  is not right any more.

Summary: avoid even calls to cpu_to_{b/l}eXX on a given piece of data.

The change has no effect on x86. Now sparc64 talks to x86.

Pinpointed-by: Jon Mason <jdmason@us.ibm.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-350 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-350	2005-02-05 21:04:12.000000000 +0100
+++ b/drivers/net/r8169.c	2005-02-12 00:25:12.992726954 +0100
@@ -698,7 +698,7 @@ static inline u32 rtl8169_tx_vlan_tag(st
 				      struct sk_buff *skb)
 {
 	return (tp->vlgrp && vlan_tx_tag_present(skb)) ?
-		TxVlanTag | cpu_to_be16(vlan_tx_tag_get(skb)) : 0x00;
+		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
 }
 
 static void rtl8169_vlan_rx_register(struct net_device *dev,
@@ -733,12 +733,12 @@ static void rtl8169_vlan_rx_kill_vid(str
 static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 			       struct sk_buff *skb)
 {
-	u32 opts2 = desc->opts2;
+	u32 opts2 = le32_to_cpu(desc->opts2);
 	int ret;
 
 	if (tp->vlgrp && (opts2 & RxVlanTag)) {
 		rtl8169_rx_hwaccel_skb(skb, tp->vlgrp,
-				       be16_to_cpu(opts2 & 0xffff));
+				       swab16(opts2 & 0xffff));
 		ret = 0;
 	} else
 		ret = -1;
@@ -2084,7 +2084,7 @@ rtl8169_tx_interrupt(struct net_device *
 
 static inline void rtl8169_rx_csum(struct sk_buff *skb, struct RxDesc *desc)
 {
-	u32 opts1 = desc->opts1;
+	u32 opts1 = le32_to_cpu(desc->opts1);
 	u32 status = opts1 & RxProtoMask;
 
 	if (((status == RxProtoTCP) && !(opts1 & TCPFail)) ||

_
