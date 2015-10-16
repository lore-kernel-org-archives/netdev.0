From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: hix5hd2_gmac: avoid integer overload warning
Date: Fri, 16 Oct 2015 12:00:51 +0200
Message-ID: <4752736.dePgPCNd9q@wuerfel>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, joe@perches.com, liguozhu@hisilicon.com,
	Yisen.Zhuang@huawei.com, netdev@vger.kernel.org,
	linuxarm@huawei.com, salil.mehta@huawei.com,
	kenneth-lee-2012@foxmail.com, xuwei5@hisilicon.com,
	lisheng011@huawei.com, linux-kernel@vger.kernel.org,
	lipeng321@huawei.com
To: huangdaode <huangdaode@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:62554 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbbJPKBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 06:01:07 -0400
In-Reply-To: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BITS_RX_EN is an 'unsigned long' constant, so the ones complement of that
has bits set that do not fit into a 32-bit variable on 64-bit architectures,
which causes a harmless gcc warning:

drivers/net/ethernet/hisilicon/hix5hd2_gmac.c: In function 'hix5hd2_port_disable':
drivers/net/ethernet/hisilicon/hix5hd2_gmac.c:374:2: warning: large integer implicitly truncated to unsigned type [-Woverflow]
  writel_relaxed(~(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);

This adds a cast to (u32) to tell gcc that the code is indeed fine.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
index a5e077eac99a..e51892d518ff 100644
--- a/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hix5hd2_gmac.c
@@ -371,7 +371,7 @@ static void hix5hd2_port_enable(struct hix5hd2_priv *priv)
 
 static void hix5hd2_port_disable(struct hix5hd2_priv *priv)
 {
-	writel_relaxed(~(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);
+	writel_relaxed(~(u32)(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);
 	writel_relaxed(0, priv->base + DESC_WR_RD_ENA);
 }
 
