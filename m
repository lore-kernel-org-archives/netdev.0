From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net] tun: remove bogus hardware vlan acceleration flags from vlan_features
Date: Tue, 18 Feb 2014 21:20:09 +0900
Message-ID: <1392726009-8083-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1392726009-8083-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	netdev@vger.kernel.org,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:59355 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbaBRMUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 07:20:48 -0500
In-Reply-To: <1392726009-8083-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>

Even though only the outer vlan tag can be HW accelerated in the transmission
path, in the TUN/TAP driver vlan_features mirrors hw_features, which happens
to have the NETIF_F_HW_VLAN_?TAG_TX flags set. Because of this, during packet
tranmisssion through a stacked vlan device dev_hard_start_xmit, (incorrectly)
assuming that the vlan device supports hardware vlan acceleration, does not
add the vlan header to the skb payload and the inner vlan tags are lost
(vlan_tci contains the outer vlan tag when userspace reads the packet from
the tap device).

Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---

diff -urNp linux-3.13.3-orig/drivers/net/tun.c linux-3.13.3/drivers/net/tun.c
--- linux-3.13.3-orig/drivers/net/tun.c	2014-01-20 11:40:07.000000000 +0900
+++ linux-3.13.3/drivers/net/tun.c	2014-02-18 16:23:04.461078629 +0900
@@ -1651,7 +1651,9 @@ static int tun_set_iff(struct net *net,
 				   TUN_USER_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
 				   NETIF_F_HW_VLAN_STAG_TX;
 		dev->features = dev->hw_features;
-		dev->vlan_features = dev->features;
+		dev->vlan_features = dev->features &
+				     ~(NETIF_F_HW_VLAN_CTAG_TX |
+				       NETIF_F_HW_VLAN_STAG_TX);
 
 		INIT_LIST_HEAD(&tun->disabled);
 		err = tun_attach(tun, file, false);
