From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 2/2] geneve: lock RCU on TX path
Date: Fri, 24 Feb 2017 11:43:37 -0800
Message-ID: <20170224194337.67538-3-jakub.kicinski@netronome.com>
References: <20170224194337.67538-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Pravin Shelar <pshelar@ovn.org>, Jiri Benc <jbenc@redhat.com>,
        "John W . Linville" <linville@tuxdriver.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:35630 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751219AbdBXTug (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 14:50:36 -0500
Received: by mail-pg0-f50.google.com with SMTP id b129so15135261pgc.2
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 11:50:20 -0800 (PST)
In-Reply-To: <20170224194337.67538-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no guarantees that callers of the TX path will hold
the RCU lock.  Grab it explicitly.

Fixes: fceb9c3e3825 ("geneve: avoid using stale geneve socket.")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/geneve.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 45301cb98bc1..7074b40ebd7f 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -881,12 +881,14 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 		info = &geneve->info;
 	}
 
+	rcu_read_lock();
 #if IS_ENABLED(CONFIG_IPV6)
 	if (info->mode & IP_TUNNEL_INFO_IPV6)
 		err = geneve6_xmit_skb(skb, dev, geneve, info);
 	else
 #endif
 		err = geneve_xmit_skb(skb, dev, geneve, info);
+	rcu_read_unlock();
 
 	if (likely(!err))
 		return NETDEV_TX_OK;
-- 
2.11.0
