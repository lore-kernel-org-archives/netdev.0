From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] veth: extend features to support tunneling
Date: Fri, 25 Oct 2013 18:25:03 -0700
Message-ID: <1382750703.4032.32.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	 <1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025.181809.348808013109842304.davem@davemloft.net>
	 <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	 <1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382748742.4032.24.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:45852 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab3JZBZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 21:25:07 -0400
Received: by mail-ee0-f41.google.com with SMTP id d49so2395376eek.14
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 18:25:06 -0700 (PDT)
In-Reply-To: <1382748742.4032.24.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While investigating on a recent vxlan regression, I found veth
was using a zero features set for vxlan tunnels.

We have to segment GSO frames, copy the payload, and do the checksum.

This patch brings a ~200% performance increase

We probably have to add hw_enc_features support
on other virtual devices.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 drivers/net/veth.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index b2d0347..b24db7a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -261,6 +261,8 @@ static const struct net_device_ops veth_netdev_ops = {
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
 		       NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
+		       NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |	    \
+		       NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT | NETIF_F_UFO	|   \
 		       NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX | \
 		       NETIF_F_HW_VLAN_STAG_TX | NETIF_F_HW_VLAN_STAG_RX )
 
@@ -279,6 +281,7 @@ static void veth_setup(struct net_device *dev)
 	dev->destructor = veth_dev_free;
 
 	dev->hw_features = VETH_FEATURES;
+	dev->hw_enc_features = VETH_FEATURES;
 }
 
 /*
