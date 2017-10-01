From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 3/4] ip_gre: set tunnel hlen properly in erspan_tunnel_init
Date: Sun,  1 Oct 2017 22:00:55 +0800
Message-ID: <dcf4c8a2af505c0e29dfa4b70215560f6ad591ca.1506866059.git.lucien.xin@gmail.com>
References: <cover.1506866059.git.lucien.xin@gmail.com>
 <ef4c0ca4a1f0b6ae6eabda22fd9f55d0173fa862.1506866059.git.lucien.xin@gmail.com>
 <54a772dbf163eacd65d846054a63f8f7a87e318b.1506866059.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Dmitry Kozlov <xeb@mail.ru>,
        William Tu <u9012063@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32963 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751013AbdJAOBa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 10:01:30 -0400
Received: by mail-pg0-f67.google.com with SMTP id u136so3323643pgc.0
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 07:01:30 -0700 (PDT)
In-Reply-To: <54a772dbf163eacd65d846054a63f8f7a87e318b.1506866059.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1506866059.git.lucien.xin@gmail.com>
References: <cover.1506866059.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to __gre_tunnel_init, tunnel->hlen should be set as the
headers' length between inner packet and outer iphdr.

It would be used especially to calculate a proper mtu when updating
mtu in tnl_update_pmtu. Now without setting it, a bigger mtu value
than expected would be updated, which hurts performance a lot.

This patch is to fix it by setting tunnel->hlen with:
   tunnel->tun_hlen + tunnel->encap_hlen + sizeof(struct erspanhdr)

Fixes: 84e54fe0a5ea ("gre: introduce native tunnel support for ERSPAN")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ip_gre.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2a4ef9d..fad0bb1 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1245,7 +1245,9 @@ static int erspan_tunnel_init(struct net_device *dev)
 
 	tunnel->tun_hlen = 8;
 	tunnel->parms.iph.protocol = IPPROTO_GRE;
-	t_hlen = tunnel->hlen + sizeof(struct iphdr) + sizeof(struct erspanhdr);
+	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen +
+		       sizeof(struct erspanhdr);
+	t_hlen = tunnel->hlen + sizeof(struct iphdr);
 
 	dev->needed_headroom = LL_MAX_HEADER + t_hlen + 4;
 	dev->mtu = ETH_DATA_LEN - t_hlen - 4;
-- 
2.1.0
