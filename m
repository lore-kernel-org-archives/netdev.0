From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] mlx4_en: Fix read buffer overflow in mlx4_en_complete_rx_desc()
Date: Sun, 09 Aug 2009 11:54:21 +0200
Message-ID: <4A7E9CCD.7000307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	yevgenyp@mellanox.co.il, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:56950 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbZHIJui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2009 05:50:38 -0400
Received: by ewy10 with SMTP id 10so2431700ewy.37
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2009 02:50:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the length is less or equal to frag_prefix_size in the first iteration
we write skb_frags_rx[-1] and read from priv->frag_info[-1]

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 91bdfdf..3ac0404 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -506,8 +506,9 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 				 PCI_DMA_FROMDEVICE);
 	}
 	/* Adjust size of last fragment to match actual length */
-	skb_frags_rx[nr - 1].size = length -
-		priv->frag_info[nr - 1].frag_prefix_size;
+	if (nr > 0)
+		skb_frags_rx[nr - 1].size = length -
+			priv->frag_info[nr - 1].frag_prefix_size;
 	return nr;
 
 fail:
