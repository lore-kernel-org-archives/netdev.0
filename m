From: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Subject: [PATCH] Fix e1000e with Intel 82572EI that has no hardware
 timestamp support
Date: Wed, 6 Aug 2014 14:27:44 +0000
Message-ID: <be459158bb5c46fcaf73129858342da4@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Nick Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: de-DE
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the Intel 82527EI (driver: e1000e) there is an issue when running 
the ptpd2 program, that leads to a kernel oops.
The reason is here that in e1000_xmit_frame() a work queue will be 
scheduled that has not been initialized in this case.
The work queue "tx_hwstamp_work" will only be initialized if 
adapter->flags & FLAG_HAS_HW_TIMESTAMP set.
This check is missing in e1000_xmit_frame().

The following patch adds the missing check.

---
 drivers/net/ethernet/intel/e1000e/netdev.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-3.12.26/drivers/net/ethernet/intel/e1000e/netdev.c
===================================================================
--- linux-3.12.26.orig/drivers/net/ethernet/intel/e1000e/netdev.c	2014-08-04 10:56:56.000000000 +0200
+++ linux-3.12.26/drivers/net/ethernet/intel/e1000e/netdev.c	2014-08-06 16:22:10.000000000 +0200
@@ -5549,8 +5549,9 @@
 	count = e1000_tx_map(tx_ring, skb, first, adapter->tx_fifo_limit,
 			     nr_frags);
 	if (count) {
-		if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
-			     !adapter->tx_hwtstamp_skb)) {
+		if ((adapter->flags & FLAG_HAS_HW_TIMESTAMP) && 
+		    unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		    !adapter->tx_hwtstamp_skb)) {
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 			tx_flags |= E1000_TX_FLAGS_HWTSTAMP;
 			adapter->tx_hwtstamp_skb = skb_get(skb);

-- 
