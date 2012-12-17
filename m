From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tuntap: reset network header before calling
 skb_get_rxhash()
Date: Mon, 17 Dec 2012 06:39:20 -0800
Message-ID: <1355755160.10504.25.camel@edumazet-glaptop>
References: <20121217005616.GA23029@shutemov.name>
	 <20121216.172214.687979484434537200.davem@davemloft.net>
	 <20121217014631.GA23101@shutemov.name>
	 <1355719589.10504.13.camel@edumazet-glaptop>
	 <20121217081121.GA24173@shutemov.name>
	 <CAD6jFUTXP-XgwFeyN11bfGcbiit=aUOoP7sSm64WK+4s6tg2TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, maxk@qti.qualcomm.com,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Daniel Borkmann <danborkmann@iogearbox.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56330 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928Ab2LQOjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 09:39:24 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so4051092pbc.19
        for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 06:39:24 -0800 (PST)
In-Reply-To: <CAD6jFUTXP-XgwFeyN11bfGcbiit=aUOoP7sSm64WK+4s6tg2TQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 499744209b2c (tuntap: dont use skb after netif_rx_ni(skb))
introduced another bug.

skb_get_rxhash() needs to access the network header, and it was
set for us in netif_rx_ni().

We need to reset network header or else skb_flow_dissect() behavior
is out of control.

Reported-and-tested-by: Kirill A. Shutemov <kirill@shutemov.name>
Tested-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/tun.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 255a9f5..173acf5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1199,6 +1199,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
 	}
 
+	skb_reset_network_header(skb);
 	rxhash = skb_get_rxhash(skb);
 	netif_rx_ni(skb);
 
