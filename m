From: P@draigBrady.com
Subject: [PATCH] Re: [E1000-devel] e1000 jumbo problems
Date: Thu, 01 Jul 2004 20:51:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40E46B32.1080605@draigBrady.com>
References: <40D883C2.7010106@draigBrady.com> <40D9BF6B.4050807@draigBrady.com> <41b516cb040623114825a9c555@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000106050202080508060107"
Cc: e1000-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Leech <chris.leech@gmail.com>
In-Reply-To: <41b516cb040623114825a9c555@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000106050202080508060107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by corvil.com id i61JpEOC095576

This patch is not for applying, just for discussion.
comments below...

Chris Leech wrote:
>>>Another related issue, is that the driver uses 4KiB buffers
>>>for MTUs in the 1500 -> 2000 range which seems a bit silly.
>>>Any particular reason for that?
>=20
>=20
> It is wasteful, but does anyone actually use an MTU in the range of
> 1501 - 2030?  It seems silly to me to go with a non-standard frame
> size, but not go up to something that might give you a performance
> benefit (9k).
> =20
>=20
>>I changed the driver to use 2KiB buffers for frames in the
>>1518 -> 2048 range (BSEX=3D0, LPE=3D1). This breaks however
>>as packets are not dropped that are larger than the max specified?
>>Instead they're scribbled into memory causing a lockup after a while.
>=20
>=20
> That sounds right, if you actually got the RCTL register set
> correctly.  In e1000_setup_rctl the adapter->rx_buffer_len is used to
> set that register, and it's currently written to only set LPE if the
> buffer size is bigger than 2k (thus, why 4k buffers are used even when
> the MTU is in the 1501 - 2030 range).  To use 2k buffers for slightly
> large frames, you'd want some new flag in the adapter for LPE (or
> check netdev->mtu I guess) and do something like: rctl |=3D
> E1000_RCTL_SZ_2048 | E1000_RCTL_LPE
>=20
> e1000 devices don't have a programmable MTU for receive filtering,
> they drop anything larger than 1518 unless LPE (long packet enable) is
> set.  If LPE is set they accept anything that fits in the FIFO and has
> a valid FCS.

More accurately e1000s accept anything (even greater than a FIFO).
When a large packet is written into multiple FIFOs, only the
last rx descriptor has the EOP (end of packet) flag set.
The driver doesn't handle this at all currently and will
drop the initial buffers (because they don't have the EOP set) which
is fine, but it will accept the last buffer (part of the packet).

I've attached a patch that fixes this. Also the patch drops packets
that fit within a buffer but are larger than MTU. So in summary
the patch will stop packets > MTU being accepted by the driver.

Note also this patch changes to using 2KiB buffers (from 4KiB)
for MTUs between 1500 and 2030, and also it enables large frame
reception (LFE) always, but ingore these as they're just for
debugging.

The patch makes my system completely stable now for MTUs <=3D 2500,
However I can still get the system to freeze repeatedly by sending
packets larger than this.

cheers,
P=E1draig.

--------------000106050202080508060107
Content-Type: application/x-texinfo;
 name="e1000-smallMTU.diff"
Content-Disposition: inline;
 filename="e1000-smallMTU.diff"
Content-Transfer-Encoding: 7bit

diff -Naru e1000-5.2.52-k3/src/e1000.h e1000-pb/src/e1000.h
--- e1000-5.2.52-k3/src/e1000.h	2004-05-17 23:59:53.000000000 +0100
+++ e1000-pb/src/e1000.h	2004-06-28 14:45:04.000000000 +0100
@@ -177,6 +177,8 @@
 	unsigned int next_to_use;
 	/* next descriptor to check for DD status bit */
 	unsigned int next_to_clean;
+	/* whether next buffer is partial packet */
+	unsigned int multi_buf_pkt;
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 };
diff -Naru e1000-5.2.52-k3/src/e1000_hw.h e1000-pb/src/e1000_hw.h
--- e1000-5.2.52-k3/src/e1000_hw.h	2004-05-17 23:59:53.000000000 +0100
+++ e1000-pb/src/e1000_hw.h	2004-06-29 14:30:45.000000000 +0100
@@ -922,6 +922,7 @@
     uint64_t sec;
     uint64_t cexterr;
     uint64_t rlec;
+    uint64_t multibuf;
     uint64_t xonrxc;
     uint64_t xontxc;
     uint64_t xoffrxc;
diff -Naru e1000-5.2.52-k3/src/e1000_main.c e1000-pb/src/e1000_main.c
--- e1000-5.2.52-k3/src/e1000_main.c	2004-05-17 23:59:53.000000000 +0100
+++ e1000-pb/src/e1000_main.c	2004-07-01 19:24:41.000000000 +0100
@@ -817,6 +817,8 @@
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
 
+	txdr->multi_buf_pkt = 0;
+
 	return 0;
 }
 
@@ -935,6 +937,8 @@
 	rxdr->next_to_clean = 0;
 	rxdr->next_to_use = 0;
 
+	rxdr->multi_buf_pkt = 0;
+
 	return 0;
 }
 
@@ -962,11 +966,12 @@
 		rctl &= ~E1000_RCTL_SBP;
 
 	rctl &= ~(E1000_RCTL_SZ_4096);
+	rctl |= E1000_RCTL_LPE;
 	switch (adapter->rx_buffer_len) {
 	case E1000_RXBUFFER_2048:
 	default:
 		rctl |= E1000_RCTL_SZ_2048;
-		rctl &= ~(E1000_RCTL_BSEX | E1000_RCTL_LPE);
+		rctl &= ~(E1000_RCTL_BSEX);
 		break;
 	case E1000_RXBUFFER_4096:
 		rctl |= E1000_RCTL_SZ_4096 | E1000_RCTL_BSEX | E1000_RCTL_LPE;
@@ -1101,6 +1106,8 @@
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 
+	tx_ring->multi_buf_pkt = 0;
+
 	E1000_WRITE_REG(&adapter->hw, TDH, 0);
 	E1000_WRITE_REG(&adapter->hw, TDT, 0);
 }
@@ -1169,6 +1176,8 @@
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 
+	rx_ring->multi_buf_pkt = 0;
+
 	E1000_WRITE_REG(&adapter->hw, RDH, 0);
 	E1000_WRITE_REG(&adapter->hw, RDT, 0);
 }
@@ -1904,14 +1913,16 @@
 		DPRINTK(PROBE, ERR, "Invalid MTU setting\n");
 		return -EINVAL;
 	}
+	if(max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
+		if(adapter->hw.mac_type < e1000_82543) {
+			DPRINTK(PROBE, ERR, "Jumbo Frames not supported on 82542\n");
+			return -EINVAL;
+		}
+	}
 
-	if(max_frame <= MAXIMUM_ETHERNET_FRAME_SIZE) {
+	if(max_frame <= E1000_RXBUFFER_2048) {
 		adapter->rx_buffer_len = E1000_RXBUFFER_2048;
 
-	} else if(adapter->hw.mac_type < e1000_82543) {
-		DPRINTK(PROBE, ERR, "Jumbo Frames not supported on 82542\n");
-		return -EINVAL;
-
 	} else if(max_frame <= E1000_RXBUFFER_4096) {
 		adapter->rx_buffer_len = E1000_RXBUFFER_4096;
 
@@ -1961,7 +1972,7 @@
 	adapter->stats.gorch += E1000_READ_REG(hw, GORCH);
 	adapter->stats.bprc += E1000_READ_REG(hw, BPRC);
 	adapter->stats.mprc += E1000_READ_REG(hw, MPRC);
-	adapter->stats.roc += E1000_READ_REG(hw, ROC);
+	adapter->stats.roc += E1000_READ_REG(hw, ROC); adapter->stats.roc += adapter->stats.multibuf;
 	adapter->stats.prc64 += E1000_READ_REG(hw, PRC64);
 	adapter->stats.prc127 += E1000_READ_REG(hw, PRC127);
 	adapter->stats.prc255 += E1000_READ_REG(hw, PRC255);
@@ -1979,7 +1990,7 @@
 	adapter->stats.latecol += E1000_READ_REG(hw, LATECOL);
 	adapter->stats.dc += E1000_READ_REG(hw, DC);
 	adapter->stats.sec += E1000_READ_REG(hw, SEC);
-	adapter->stats.rlec += E1000_READ_REG(hw, RLEC);
+	adapter->stats.rlec += E1000_READ_REG(hw, RLEC); adapter->stats.rlec += adapter->stats.multibuf;
 	adapter->stats.xonrxc += E1000_READ_REG(hw, XONRXC);
 	adapter->stats.xontxc += E1000_READ_REG(hw, XONTXC);
 	adapter->stats.xoffrxc += E1000_READ_REG(hw, XOFFRXC);
@@ -2069,6 +2080,8 @@
 			adapter->phy_stats.receive_errors += phy_tmp;
 	}
 
+	adapter->stats.multibuf=0;
+
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 
@@ -2190,6 +2203,7 @@
 	if(work_done < work_to_do || !netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
+		return 0;
 	}
 
 	return (work_done >= work_to_do);
@@ -2312,7 +2326,18 @@
 		skb = buffer_info->skb;
 		length = le16_to_cpu(rx_desc->length);
 
-		if(!(rx_desc->status & E1000_RXD_STAT_EOP)) {
+		if((!(rx_desc->status & E1000_RXD_STAT_EOP)) || rx_ring->multi_buf_pkt) {
+
+			if(!(rx_desc->status & E1000_RXD_STAT_EOP)) {
+				rx_ring->multi_buf_pkt=1; /* Next buffer also to be dropped */
+			} else {
+				spin_lock_irqsave(&adapter->stats_lock, flags);
+				adapter->stats.multibuf++; /* counted as "frame too large" error */
+				/* TODO: decrement byte and packet counts */
+				spin_unlock_irqrestore(&adapter->stats_lock, flags);
+
+				rx_ring->multi_buf_pkt=0;
+			}
 
 			/* All receives must fit into a single buffer */
 
@@ -2358,6 +2383,27 @@
 			}
 		}
 
+		if(length > adapter->hw.max_frame_size +
+		   (rx_desc->status & E1000_RXD_STAT_VP ? VLAN_TAG_SIZE : 0)) {
+
+			spin_lock_irqsave(&adapter->stats_lock, flags);
+			adapter->stats.multibuf++; /* counted as "frame too large" error */
+			/* TODO: decrement byte and packet counts */
+			spin_unlock_irqrestore(&adapter->stats_lock, flags);
+
+			E1000_DBG("%s: Packet length %d too big\n",
+				netdev->name, length);
+
+			dev_kfree_skb_irq(skb);
+			rx_desc->status = 0;
+			buffer_info->skb = NULL;
+
+			if(++i == rx_ring->count) i = 0;
+
+			rx_desc = E1000_RX_DESC(*rx_ring, i);
+			continue;
+		}
+
 		/* Good Receive */
 		skb_put(skb, length - ETHERNET_FCS_SIZE);
 

--------------000106050202080508060107--
