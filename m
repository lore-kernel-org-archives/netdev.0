From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 2/4] ipvlan: play well with macvlan device
Date: Sat,  6 Dec 2014 15:53:19 -0800
Message-ID: <1417909999-13234-1-git-send-email-maheshb@google.com>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:64642 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbaLFXxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 18:53:22 -0500
Received: by mail-ob0-f201.google.com with SMTP id nt9so299902obb.2
        for <netdev@vger.kernel.org>; Sat, 06 Dec 2014 15:53:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a device is already a macvlan port then refuse to use it as
an ipvlan port in the early stage of port creation.

	thost1:~# ip link add link eth0 mvl0 type macvlan
	thost1:~# echo $?
	0
	thost1:~# ip link add link eth0 ipvl0 type ipvlan
	RTNETLINK answers: Device or resource busy
	thost1:~# echo $?
	2
	thost1:~#

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 96b71b0d78f6..a706a547d811 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -38,6 +38,12 @@ static int ipvlan_port_create(struct net_device *dev)
 		netdev_err(dev, "Master is either lo or non-ether device\n");
 		return -EINVAL;
 	}
+
+	if (netif_is_macvlan_port(dev)) {
+		netdev_err(dev, "Master is a macvlan port.\n");
+		return -EBUSY;
+	}
+
 	port = kzalloc(sizeof(struct ipvl_port), GFP_KERNEL);
 	if (!port)
 		return -ENOMEM;
-- 
2.2.0.rc0.207.ga3a616c
