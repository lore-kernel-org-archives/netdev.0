From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 6/9] gre: TX path for GRE/UDP Generic UDP
 Encapsulation
Date: Wed, 16 Jul 2014 21:15:18 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407162056280.30966@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:54711 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895AbaGQEPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 00:15:19 -0400
Received: by mail-qc0-f202.google.com with SMTP id i17so265550qcy.1
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 21:15:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to perform GRE over GUE encapsulation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ip_gre.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 9b84254..8053b3b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -239,7 +239,7 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 	tpi.seq = htonl(tunnel->o_seqno);
 
 	/* Push GRE header. */
-	gre_build_header(skb, &tpi, tunnel->hlen);
+	gre_build_header(skb, &tpi, tunnel->tun_hlen);
 
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
@@ -310,9 +310,14 @@ out:
 static int ipgre_tunnel_ioctl(struct net_device *dev,
 			      struct ifreq *ifr, int cmd)
 {
-	int err = 0;
+	int err;
 	struct ip_tunnel_parm p;
 
+	/* Try generic tunnel ioctls first */
+	err = ip_tunnel_gen_ioctl(dev, ifr, cmd);
+	if (err != -ENOIOCTLCMD)
+		return err;
+
 	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
 		return -EFAULT;
 	if (cmd == SIOCADDTUNNEL || cmd == SIOCCHGTUNNEL) {
@@ -472,9 +477,11 @@ static void __gre_tunnel_init(struct net_device *dev)
 	struct ip_tunnel *tunnel;
 
 	tunnel = netdev_priv(dev);
-	tunnel->hlen = ip_gre_calc_hlen(tunnel->parms.o_flags);
+	tunnel->tun_hlen = ip_gre_calc_hlen(tunnel->parms.o_flags);
 	tunnel->parms.iph.protocol = IPPROTO_GRE;
 
+	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
+
 	dev->needed_headroom	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 4;
 
-- 
2.0.0.526.g5318336
