From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 4/4] macvlan: play well with ipvlan device
Date: Sat,  6 Dec 2014 15:53:46 -0800
Message-ID: <1417910026-13371-1-git-send-email-maheshb@google.com>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:53642 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbaLFXxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 18:53:49 -0500
Received: by mail-ob0-f202.google.com with SMTP id va2so295686obc.5
        for <netdev@vger.kernel.org>; Sat, 06 Dec 2014 15:53:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If device is already used as an ipvlan port then refuse to
use it as a macvlan port at early stage of port creation.

	thost1:~# ip link add link eth0 ipvl0 type ipvlan
	thost1:~# echo $?
	0
	thost1:~# ip link add link eth0 mvl0 type macvlan
	RTNETLINK answers: Device or resource busy
	thost1:~# echo $?
	2
	thost1:~#

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/macvlan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9538674587aa..84b4008210c7 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1056,6 +1056,9 @@ static int macvlan_port_create(struct net_device *dev)
 	if (dev->type != ARPHRD_ETHER || dev->flags & IFF_LOOPBACK)
 		return -EINVAL;
 
+	if (netif_is_ipvlan_port(dev))
+		return -EBUSY;
+
 	port = kzalloc(sizeof(*port), GFP_KERNEL);
 	if (port == NULL)
 		return -ENOMEM;
-- 
2.2.0.rc0.207.ga3a616c
