From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next 3/4 v5] pktgen: Fixing UPD checksum calculation
Date: Wed, 6 Aug 2014 19:17:03 +0100
Message-ID: <1407349024-2489-4-git-send-email-zoltan.kiss@citrix.com>
References: <1407349024-2489-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Joe Perches <joe@perches.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Mathias Krause <minipli@googlemail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407349024-2489-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It passes port number instead of IP address for checksuming. The udp4_hwcsum()
call is also bad, but my next patch will get rid of it anyway. The IPv6 code
does it correctly already. It also changes replaces 8 with sizeof(struct udphdr) 

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Joe Perches <joe@perches.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
---
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index ba61e2b..d8905cd 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3061,8 +3061,9 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 		__wsum csum = udp_csum(skb);
 
 		/* add protocol-dependent pseudo-header */
-		udph->check = csum_tcpudp_magic(udph->source, udph->dest,
-						datalen + 8, IPPROTO_UDP, csum);
+		udph->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
+						datalen + sizeof(struct udphdr),
+						IPPROTO_UDP, csum);
 
 		if (udph->check == 0)
 			udph->check = CSUM_MANGLED_0;
