From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] net: bridge: start hello timer only if device is up
Date: Thu,  1 Jun 2017 18:07:55 +0300
Message-ID: <1496329675-11254-1-git-send-email-nikolay@cumulusnetworks.com>
References: <06ef2ff1-f29d-a163-3226-7bd43c7a407c@cumulusnetworks.com>
Cc: davem@davemloft.net, roopa@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Xin Long <lucien.xin@gmail.com>, Ivan Vecera <cera@cera.cz>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35489 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751091AbdFAPI0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 11:08:26 -0400
Received: by mail-wm0-f41.google.com with SMTP id b84so162424864wmh.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 08:08:26 -0700 (PDT)
In-Reply-To: <06ef2ff1-f29d-a163-3226-7bd43c7a407c@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the transition of NO_STP -> KERNEL_STP was fixed by always calling
mod_timer in br_stp_start, it introduced a new regression which causes
the timer to be armed even when the bridge is down, and since we stop
the timers in its ndo_stop() function, they never get disabled if the
device is destroyed before it's upped.

To reproduce:
$ while :; do ip l add br0 type bridge hello_time 100; brctl stp br0 on;
ip l del br0; done;

CC: Xin Long <lucien.xin@gmail.com>
CC: Ivan Vecera <cera@cera.cz>
CC: Sebastian Ott <sebott@linux.vnet.ibm.com>
Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Fixes: 6d18c732b95c ("bridge: start hello_timer when enabling KERNEL_STP in br_stp_start")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Sebastian it'd be great if you can test the patch as well.

 net/bridge/br_stp_if.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 4efd5d54498a..89110319ef0f 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -173,7 +173,8 @@ static void br_stp_start(struct net_bridge *br)
 		br_debug(br, "using kernel STP\n");
 
 		/* To start timers on any ports left in blocking */
-		mod_timer(&br->hello_timer, jiffies + br->hello_time);
+		if (br->dev->flags & IFF_UP)
+			mod_timer(&br->hello_timer, jiffies + br->hello_time);
 		br_port_state_selection(br);
 	}
 
-- 
2.1.4
