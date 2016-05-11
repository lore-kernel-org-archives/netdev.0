From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] gre: do not keep the GRE header around in collect medata mode
Date: Wed, 11 May 2016 15:53:57 +0200
Message-ID: <208ed3349bdc26bb9af1fe7e8ff64895e0e2c088.1462974784.git.jbenc@redhat.com>
Cc: Pravin Shelar <pshelar@ovn.org>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933051AbcEKNyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 09:54:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For ipgre interface in collect metadata mode, it doesn't make sense for the
interface to be of ARPHRD_IPGRE type. The outer header of received packets
is not needed, as all the information from it is present in metadata_dst. We
already don't set ipgre_header_ops for collect metadata interfaces, which is
the only consumer of mac_header pointing to the outer IP header.

Just set the interface type to ARPHRD_NONE in collect metadata mode for
ipgre (not gretap, that still correctly stays ARPHRD_ETHER) and reset
mac_header.

Fixes: a64b04d86d14 ("gre: do not assign header_ops in collect metadata mode")
Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/ip_gre.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 205a2b8a5a84..4cc84212cce1 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -398,7 +398,10 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 				  iph->saddr, iph->daddr, tpi->key);
 
 	if (tunnel) {
-		skb_pop_mac_header(skb);
+		if (tunnel->dev->type != ARPHRD_NONE)
+			skb_pop_mac_header(skb);
+		else
+			skb_reset_mac_header(skb);
 		if (tunnel->collect_md) {
 			__be16 flags;
 			__be64 tun_id;
@@ -1031,6 +1034,8 @@ static void ipgre_netlink_parms(struct net_device *dev,
 		struct ip_tunnel *t = netdev_priv(dev);
 
 		t->collect_md = true;
+		if (dev->type == ARPHRD_IPGRE)
+			dev->type = ARPHRD_NONE;
 	}
 }
 
-- 
1.8.3.1
