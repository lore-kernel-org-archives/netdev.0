From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: fix harmonize_features() vs NETIF_F_HIGHDMA
Date: Wed, 18 Jan 2017 12:12:17 -0800
Message-ID: <1484770337.13165.120.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170117074820.5106-1-ashiduka@jp.fujitsu.com>
         <AM4PR0401MB2260E5BE096D7B86EDF4F04FFF7C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
         <337A096076BEF646A1F21E1AD855580E3AC8F71A@g01jpexmbkw23>
         <1484713283.13165.89.camel@edumazet-glaptop3.roam.corp.google.com>
         <1484714132.13165.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAOrHB_A-oJid6RTeQB_xy0GDKsJjvEDwdTepMXN336qSi5h8AA@mail.gmail.com>
         <1484769077.13165.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Ashizuka, Yuusuke" <ashiduka@jp.fujitsu.com>,
        Andy Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Pravin B Shelar <pshelar@nicira.com>
To: Pravin Shelar <pshelar@ovn.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35361 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752749AbdARUTp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 15:19:45 -0500
Received: by mail-pg0-f66.google.com with SMTP id 204so2167303pge.2
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 12:19:45 -0800 (PST)
In-Reply-To: <1484769077.13165.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Ashizuka reported a highmem oddity and sent a patch for freescale
fec driver.

But the problem root cause is that core networking stack
must ensure no skb with highmem fragment is ever sent through
a device that does not assert NETIF_F_HIGHDMA in its features.

We need to call illegal_highdma() from harmonize_features()
regardless of CSUM checks.

Fixes: ec5f06156423 ("net: Kill link between CSUM and SG features.")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Pravin Shelar <pshelar@ovn.org>
Reported-by: "Ashizuka, Yuusuke" <ashiduka@jp.fujitsu.com>
---
 net/core/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 07b307b0b414730688b64fdb2295b0fa1b721e51..7f218e095361520d11c243d650e053321ea7274f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2795,9 +2795,9 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 	if (skb->ip_summed != CHECKSUM_NONE &&
 	    !can_checksum_protocol(features, type)) {
 		features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
-	} else if (illegal_highdma(skb->dev, skb)) {
-		features &= ~NETIF_F_SG;
 	}
+	if (illegal_highdma(skb->dev, skb))
+		features &= ~NETIF_F_SG;
 
 	return features;
 }
