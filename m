From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v2] net: gre: use icmp_hdr() to get inner ip header
Date: Tue, 28 Jan 2014 11:49:43 +0800
Message-ID: <52E728D7.70506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org,
	Pravin Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:24632 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753428AbaA1Du2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 22:50:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When dealing with icmp messages, the skb->data points the
ip header that triggered the sending of the icmp message.

In gre_cisco_err(), the parse_gre_header() is called, and the
iptunnel_pull_header() is called to pull the skb at the end of
the parse_gre_header(), so the skb->data doesn't point the
inner ip header.

Unfortunately, the ipgre_err still needs those ip addresses in
inner ip header to look up tunnel by ip_tunnel_lookup().

So just use icmp_hdr() to get inner ip header instead of skb->data.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---

v2: use icmp_hdr() instead of conditional pulling of headers

 net/ipv4/ip_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index e7a92fd..ec4f762 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -178,7 +178,7 @@ static int ipgre_err(struct sk_buff *skb, u32 info,
 	else
 		itn = net_generic(net, ipgre_net_id);
 
-	iph = (const struct iphdr *)skb->data;
+	iph = (const struct iphdr *)(icmp_hdr(skb) + 1);
 	t = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
 			     iph->daddr, iph->saddr, tpi->key);
 
-- 
1.8.3.1
