From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc1-mm4 3/4] r8169: TSO support.
Date: Fri, 10 Sep 2004 00:49:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909224947.GB10144@electric-eye.fr.zoreil.com>
References: <20040909224539.GA9629@electric-eye.fr.zoreil.com> <20040909224817.GA10144@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040909224817.GA10144@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


TSO support. Suggestion of Jeff Garzik.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-160 drivers/net/r8169.c
--- linux-2.6.9-rc1/drivers/net/r8169.c~r8169-160	2004-09-08 22:53:47.000000000 +0200
+++ linux-2.6.9-rc1-fr/drivers/net/r8169.c	2004-09-08 22:53:47.000000000 +0200
@@ -323,6 +323,9 @@ enum _DescStatusBit {
 	LastFrag	= (1 << 28), /* Final segment of a packet */
 
 	/* Tx private */
+	LargeSend	= (1 << 27), /* TCP Large Send Offload (TSO) */
+	MSSShift	= 16,        /* MSS value position */
+	MSSMask		= 0xfff,     /* MSS value + LargeSend bit: 12 bits */
 	IPCS		= (1 << 18), /* Calculate IP checksum */
 	UDPCS		= (1 << 17), /* Calculate UDP/IP checksum */
 	TCPCS		= (1 << 16), /* Calculate TCP/IP checksum */
@@ -844,6 +847,8 @@ static struct ethtool_ops rtl8169_ethtoo
 	.set_tx_csum		= ethtool_op_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
+	.get_tso		= ethtool_op_get_tso,
+	.set_tso		= ethtool_op_set_tso,
 	.get_regs		= rtl8169_get_regs,
 };
 
@@ -1745,8 +1750,14 @@ static int rtl8169_xmit_frags(struct rtl
 	return cur_frag;
 }
 
-static inline u32 rtl8169_tx_csum(struct sk_buff *skb)
+static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
 {
+	if (dev->features & NETIF_F_TSO) {
+		u32 mss = skb_shinfo(skb)->tso_size;
+
+		if (mss)
+			return LargeSend | ((mss & MSSMask) << MSSShift);
+	}
 	if (skb->ip_summed == CHECKSUM_HW) {
 		const struct iphdr *ip = skb->nh.iph;
 
@@ -1754,7 +1765,7 @@ static inline u32 rtl8169_tx_csum(struct
 			return IPCS | TCPCS;
 		else if (ip->protocol == IPPROTO_UDP)
 			return IPCS | UDPCS;
-		BUG();
+		WARN_ON(1);	/* we need a WARN() */
 	}
 	return 0;
 }
@@ -1779,7 +1790,7 @@ static int rtl8169_start_xmit(struct sk_
 	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
 		goto err_stop;
 
-	opts1 = DescOwn | rtl8169_tx_csum(skb);
+	opts1 = DescOwn | rtl8169_tso_csum(skb, dev);
 
 	frags = rtl8169_xmit_frags(tp, skb, opts1);
 	if (frags) {

_
