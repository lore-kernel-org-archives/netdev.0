From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 1/2] macvlan: Only deliver one copy of the frame to
 the macvlan interface
Date: Fri, 13 Oct 2017 13:40:24 -0700
Message-ID: <20171013204024.16950.38333.stgit@localhost.localdomain>
References: <20171013203726.16950.32584.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:44807 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751851AbdJMUk0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 16:40:26 -0400
Received: by mail-pf0-f196.google.com with SMTP id x7so11281699pfa.1
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 13:40:26 -0700 (PDT)
In-Reply-To: <20171013203726.16950.32584.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch intoduces a slight adjustment for macvlan to address the fact
that in source mode I was seeing two copies of any packet addressed to the
macvlan interface being delivered where there should have been only one.

The issue appears to be that one copy was delivered based on the source MAC
address and then the second copy was being delivered based on the
destination MAC address. To fix it I am just treating a unicast address
match as though it is not a match since source based macvlan isn't supposed
to be matching based on the destination MAC anyway.

Fixes: 79cf79abce71 ("macvlan: add source mode")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/macvlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d2aea961e0f4..fb1c9e095d0c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -480,7 +480,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 					      struct macvlan_dev, list);
 	else
 		vlan = macvlan_hash_lookup(port, eth->h_dest);
-	if (vlan == NULL)
+	if (!vlan || vlan->mode == MACVLAN_MODE_SOURCE)
 		return RX_HANDLER_PASS;
 
 	dev = vlan->dev;
