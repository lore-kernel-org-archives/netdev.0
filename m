From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: prevent sign extension in dev_get_stats()
Date: Tue, 27 Jun 2017 07:02:20 -0700
Message-ID: <1498572140.736.115.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170609142947.16969-1-dheidler@suse.de>
         <20170609151621.11e610a2@xeon-e3>
         <1497054551.736.99.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170610.161335.734544822657172006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dheidler@suse.de, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33702 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751490AbdF0OCX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 10:02:23 -0400
Received: by mail-pf0-f195.google.com with SMTP id e199so4905859pfh.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 07:02:22 -0700 (PDT)
In-Reply-To: <20170610.161335.734544822657172006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Similar to the fix provided by Dominik Heidler in commit
9b3dc0a17d73 ("l2tp: cast l2tp traffic counter to unsigned")
we need to take care of 32bit kernels in dev_get_stats().

When using atomic_long_read(), we add a 'long' to u64 and
might misinterpret high order bit, unless we cast to unsigned.

Fixes: caf586e5f23ce ("net: add a core netdev->rx_dropped counter")
Fixes: 015f0688f57ca ("net: net: add a core netdev->tx_dropped counter")
Fixes: 6e7333d315a76 ("net: add rx_nohandler stat counter")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jarod Wilson <jarod@redhat.com>
---
Note: I will provide similar other fixes in networking tree.

 net/core/dev.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7243421c9783..91bb55070533 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7783,9 +7783,9 @@ struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 	} else {
 		netdev_stats_to_stats64(storage, &dev->stats);
 	}
-	storage->rx_dropped += atomic_long_read(&dev->rx_dropped);
-	storage->tx_dropped += atomic_long_read(&dev->tx_dropped);
-	storage->rx_nohandler += atomic_long_read(&dev->rx_nohandler);
+	storage->rx_dropped += (unsigned long)atomic_long_read(&dev->rx_dropped);
+	storage->tx_dropped += (unsigned long)atomic_long_read(&dev->tx_dropped);
+	storage->rx_nohandler += (unsigned long)atomic_long_read(&dev->rx_nohandler);
 	return storage;
 }
 EXPORT_SYMBOL(dev_get_stats);
