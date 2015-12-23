From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net v2] geneve: initialize needed_headroom
Date: Wed, 23 Dec 2015 16:54:27 +0100
Message-ID: <211eb876be50613e662c0f01c3de6735e23e9b97.1450885903.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>, Jesse Gross <jesse@nicira.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753468AbbLWPyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 10:54:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the needed_headroom field for the geneve device is left
to the default value.

This patch set it to space required for basic geneve encapsulation,
so that we can avoid the skb head re-allocation on xmit.

This give a 6% speedup for unsegment traffic on geneve tunnel.

v1 -> v2:
  - add ETH_HLEN for the lower device to the needed headroom

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/geneve.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index c2b79f5..58efdec 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1155,7 +1155,7 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_dev *t, *geneve = netdev_priv(dev);
 	bool tun_collect_md, tun_on_same_port;
-	int err;
+	int err, encap_len;
 
 	if (!remote)
 		return -EINVAL;
@@ -1187,6 +1187,14 @@ static int geneve_configure(struct net *net, struct net_device *dev,
 	if (t)
 		return -EBUSY;
 
+	/* make enough headroom for basic scenario */
+	encap_len = GENEVE_BASE_HLEN + ETH_HLEN;
+	if (remote->sa.sa_family == AF_INET)
+		encap_len += sizeof(struct iphdr);
+	else
+		encap_len += sizeof(struct ipv6hdr);
+	dev->needed_headroom = encap_len + ETH_HLEN;
+
 	if (metadata) {
 		if (tun_on_same_port)
 			return -EPERM;
-- 
1.8.3.1
