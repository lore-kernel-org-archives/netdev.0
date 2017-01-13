From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next] ipvlan: fix dev_id creation corner case.
Date: Fri, 13 Jan 2017 15:48:30 -0800
Message-ID: <20170113234830.16054-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>,
        David Miller <davem@davemloft.org>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34359 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751261AbdAMXsi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 18:48:38 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so10240337pfb.1
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 15:48:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

In the last patch da36e13cf65 ("ipvlan: improvise dev_id generation
logic in IPvlan") I missed some part of Dave's suggestion and because
of that the dev_id creation could fail in a corner case scenario. This
would happen when more or less 64k devices have been already created and
several have been deleted. If the devices that are still sticking around
are the last n bits from the bitmap. So in this scenario even if lower
bits are available, the dev_id search is so narrow that it always fails.

Fixes: da36e13cf65 ("ipvlan: improvise dev_id generation logic in IPvlan")
CC: David Miller <davem@davemloft.org>
CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 92b221a03350..b5c390f0f2b3 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -550,6 +550,9 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	err = ida_simple_get(&port->ida, port->dev_id_start, 0xFFFE,
 			     GFP_KERNEL);
 	if (err < 0)
+		err = ida_simple_get(&port->ida, 0x1, port->dev_id_start,
+				     GFP_KERNEL);
+	if (err < 0)
 		goto destroy_ipvlan_port;
 	dev->dev_id = err;
 	/* Increment id-base to the next slot for the future assignment */
-- 
2.11.0.483.g087da7b7c-goog
