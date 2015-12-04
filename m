From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: read MAC address registers only once
Date: Sat, 05 Dec 2015 00:58:57 +0300
Message-ID: <2035649.FBvo9Og81d@wasted.cogentembedded.com>
References: <10429393.qU4CxZ5nlj@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <10429393.qU4CxZ5nlj@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code reading the MAHR/MALR registers in read_mac_address() is terribly
ineffective -- it reads MAHR 4 times and MALR 2 times, while it's enough to
read each register only once.  Use the local variables to achieve that,
somewhat beautifying the code while at it...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -989,12 +989,15 @@ static void read_mac_address(struct net_
 	if (mac[0] || mac[1] || mac[2] || mac[3] || mac[4] || mac[5]) {
 		memcpy(ndev->dev_addr, mac, ETH_ALEN);
 	} else {
-		ndev->dev_addr[0] = (sh_eth_read(ndev, MAHR) >> 24);
-		ndev->dev_addr[1] = (sh_eth_read(ndev, MAHR) >> 16) & 0xFF;
-		ndev->dev_addr[2] = (sh_eth_read(ndev, MAHR) >> 8) & 0xFF;
-		ndev->dev_addr[3] = (sh_eth_read(ndev, MAHR) & 0xFF);
-		ndev->dev_addr[4] = (sh_eth_read(ndev, MALR) >> 8) & 0xFF;
-		ndev->dev_addr[5] = (sh_eth_read(ndev, MALR) & 0xFF);
+		u32 mahr = sh_eth_read(ndev, MAHR);
+		u32 malr = sh_eth_read(ndev, MALR);
+
+		ndev->dev_addr[0] = (mahr >> 24) & 0xFF;
+		ndev->dev_addr[1] = (mahr >> 16) & 0xFF;
+		ndev->dev_addr[2] = (mahr >>  8) & 0xFF;
+		ndev->dev_addr[3] = (mahr >>  0) & 0xFF;
+		ndev->dev_addr[4] = (malr >>  8) & 0xFF;
+		ndev->dev_addr[5] = (malr >>  0) & 0xFF;
 	}
 }
 

