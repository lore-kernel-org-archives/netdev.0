From: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: [PATCH RESEND] ip_gre: sendto/recvfrom NBMA address
Date: Tue, 23 Oct 2007 18:57:25 +0300
Message-ID: <471E19E5.5040509@iki.fi>
References: <471E05BD.7040407@iki.fi> <471E0638.9040405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw02.mail.saunalahti.fi ([195.197.172.116]:42137 "EHLO
	gw02.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbXJWP5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 11:57:32 -0400
In-Reply-To: <471E0638.9040405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When GRE tunnel is in NBMA mode, this patch allows an application to use
a PF_PACKET socket to:
- send a packet to specific NBMA address with sendto()
- use recvfrom() to receive packet and check which NBMA address it came from

This is required to implement properly NHRP over GRE tunnel.

Signed-off-by: Timo Teras <timo.teras@iki.fi>

---
Patrick McHardy wrote:
> Your mailer mangled tabs, it won't apply like this. Try sending to
> yourself for testing, then repost when it works properly.

Tabs were ok, I think. But somehow it seems that cut'n'paste from my
default editor loses the space from context lines. It should be good now.

 net/ipv4/ip_gre.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f151900..b1e3816 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1033,7 +1033,6 @@ static int ipgre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-#ifdef CONFIG_NET_IPGRE_BROADCAST
 /* Nice toy. Unfortunately, useless in real life :-)
    It allows to construct virtual multiprotocol broadcast "LAN"
    over the Internet, provided multicast routing is tuned.
@@ -1092,10 +1091,19 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 	return -t->hlen;
 }
 
+static int ipgre_header_parse(const struct sk_buff *skb, unsigned char *haddr)
+{
+	struct iphdr *iph = (struct iphdr*) skb_mac_header(skb);
+	memcpy(haddr, &iph->saddr, 4);
+	return 4;
+}
+
 static const struct header_ops ipgre_header_ops = {
 	.create	= ipgre_header,
+	.parse	= ipgre_header_parse,
 };
 
+#ifdef CONFIG_NET_IPGRE_BROADCAST
 static int ipgre_open(struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
@@ -1197,6 +1205,8 @@ static int ipgre_tunnel_init(struct net_device *dev)
 			dev->stop = ipgre_close;
 		}
 #endif
+	} else {
+		dev->header_ops = &ipgre_header_ops;
 	}
 
 	if (!tdev && tunnel->parms.link)
