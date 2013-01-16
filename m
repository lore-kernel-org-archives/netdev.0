From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 802.1q HW filter spammage in 3.7.2+ kernels.
Date: Tue, 15 Jan 2013 22:01:48 -0800
Message-ID: <1358316108.19956.82.camel@edumazet-glaptop>
References: <50F60404.3090605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:55934 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064Ab3APGBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 01:01:51 -0500
Received: by mail-pb0-f49.google.com with SMTP id un15so526475pbc.36
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 22:01:50 -0800 (PST)
In-Reply-To: <50F60404.3090605@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Tue, 2013-01-15 at 17:36 -0800, Ben Greear wrote:
> My kernel logs are full of this (I have 2000 macvlans).

Are you using 2000 macvlans on the same device ? Interesting...

I am wondering how multicast/broadcast messages don't generate a huge
load and packet drops, since we clone packets for every macvlan, and
queue then to netif_rx()

I guess you dont use IPv6 on these macvlans ?


While reviewing the code, I found this small bug.

[PATCH] macvlan: fix macvlan_get_size()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/macvlan.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 1047e58..f4f2790 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -828,7 +828,12 @@ static int macvlan_changelink(struct net_device *dev,
 
 static size_t macvlan_get_size(const struct net_device *dev)
 {
-	return nla_total_size(4);
+	return
+		/* IFLA_MACVLAN_MODE, */
+		nla_total_size(4) +
+		/* IFLA_MACVLAN_FLAGS */
+		nla_total_size(2) +
+		0;
 }
 
 static int macvlan_fill_info(struct sk_buff *skb,
