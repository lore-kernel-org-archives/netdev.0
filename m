From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH] net: sh_eth: fix skb_over_panic happen
Date: Tue, 07 Feb 2012 15:54:32 +0900
Message-ID: <4F30CAA8.5050207@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:52591 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965Ab2BGGyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 01:54:36 -0500
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor3.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZ0002VJGIYSJ00@relmlor3.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 Feb 2012 15:54:34 +0900 (JST)
Received: from relmlac2.idc.renesas.com ([10.200.69.22])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0LZ0000CYGIYF820@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 Feb 2012 15:54:34 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When this GETHER controller received a large frame (about 1800 bytes
or more), skb_over_panic() happened. This is because the previous
driver set the RFLR to 0x1000 (4096 bytes) and the skb allocate size
is smaller than 4096 bytes. So, the controller accepted such a frame.

The controller can discard a large frame by the RFLR setting.
So, the patch modifies the value of RFLR to mtu + ETH_HLEN +
ETH_FCS_LEN.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 drivers/net/ethernet/renesas/sh_eth.h |    3 ---
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 813d41c..9e899b0 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -817,7 +817,7 @@ static int sh_eth_dev_init(struct net_device *ndev)
 		sh_eth_write(ndev, 0, TRIMD);

 	/* Recv frame limit set register */
-	sh_eth_write(ndev, RFLR_VALUE, RFLR);
+	sh_eth_write(ndev, ndev->mtu + ETH_HLEN + ETH_FCS_LEN, RFLR);

 	sh_eth_write(ndev, sh_eth_read(ndev, EESR), EESR);
 	sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 47877b1..cdbd844 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -575,9 +575,6 @@ enum RPADIR_BIT {
 	RPADIR_PADR = 0x0003f,
 };

-/* RFLR */
-#define RFLR_VALUE 0x1000
-
 /* FDR */
 #define DEFAULT_FDR_INIT	0x00000707

-- 
1.7.1
