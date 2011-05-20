From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] macvlan: fix panic if lowerdev in a bond
Date: Fri, 20 May 2011 18:44:49 +0200
Message-ID: <1305909889.3173.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39217 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935169Ab1ETQow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 12:44:52 -0400
Received: by wwa36 with SMTP id 36so4215387wwa.1
        for <netdev@vger.kernel.org>; Fri, 20 May 2011 09:44:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a35e2c1b6d905 (macvlan: use rx_handler_data pointer to store
macvlan_port pointer V2) added a bug in macvlan_port_create()

Steps to reproduce the bug:

# ifenslave bond0 eth0 eth1

# ip link add link eth0 up name eth0#1 type macvlan
->error EBUSY

# ip link add link eth0 up name eth0#1 type macvlan
->panic


Fix: Dont set IFF_MACVLAN_PORT in error case.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Jiri Pirko <jpirko@redhat.com>
---
This is a stable candidate (2.6.36+)

 drivers/net/macvlan.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d7c0bc62..1e12a27 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -584,8 +584,8 @@ static int macvlan_port_create(struct net_device *dev)
 	err = netdev_rx_handler_register(dev, macvlan_handle_frame, port);
 	if (err)
 		kfree(port);
-
-	dev->priv_flags |= IFF_MACVLAN_PORT;
+	else
+		dev->priv_flags |= IFF_MACVLAN_PORT;
 	return err;
 }
 


