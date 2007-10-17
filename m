From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: [PATCH] ip_gre: sendto/recvfrom NBMA address
Date: Wed, 17 Oct 2007 11:00:51 +0300
Message-ID: <4715C133.60505@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.239]:40085 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745AbXJQIAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 04:00:55 -0400
Received: by hu-out-0506.google.com with SMTP id 19so1830007hue
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 01:00:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When GRE tunnel is in NBMA mode, this patch allows an application to use
a PF_PACKET socket to:
- send a packet to specific NBMA address with sendto()
- use recvfrom() to receive packet and check which NBMA address it came from

Signed-off-by: Timo Teras <timo.teras@iki.fi>

---

This is useful for implementing NHRP over NBMA GRE tunnels.

Sent earlier to netdev list only. Resending to wider audience with
a style issue fixed.

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
+	struct iphdr *iph = (struct iphdr *) skb_mac_header(skb);
+	memcpy(haddr, &iph->saddr, 4);
+	return 4;
+}
+
static const struct header_ops ipgre_header_ops = {
	.create	= ipgre_header,
+	.parse  = ipgre_header_parse,
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

