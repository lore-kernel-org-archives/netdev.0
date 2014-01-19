From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] net: gre: don't pull skb if dealing with icmp message
Date: Sun, 19 Jan 2014 16:35:22 +0800
Message-ID: <52DB8E4A.7050809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:37794 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750774AbaASIgS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jan 2014 03:36:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When dealing with icmp messages, the skb->data points the
ip header that triggered the sending of the icmp message.

In gre_cisco_err(), the parse_gre_header() is called, and the
iptunnel_pull_header() is called to pull the skb at the end of
the parse_gre_header(). Unfortunately, the ipgre_err still needs
the skb->data points the ip header following the icmp layer,
and those ip addresses in ip header will be used to look up
tunnel by ip_tunnel_lookup().

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/gre_demux.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 5893e99..35bfba4 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -116,7 +116,7 @@ static __sum16 check_checksum(struct sk_buff *skb)
 }
 
 static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
-			    bool *csum_err)
+			    bool *csum_err, bool in_err)
 {
 	unsigned int ip_hlen = ip_hdrlen(skb);
 	const struct gre_base_hdr *greh;
@@ -160,6 +160,9 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 	} else
 		tpi->seq = 0;
 
+	if (in_err)
+		return 0;
+
 	/* WCCP version 1 and 2 protocol decoding.
 	 * - Change protocol to IP
 	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
@@ -182,7 +185,7 @@ static int gre_cisco_rcv(struct sk_buff *skb)
 	int i;
 	bool csum_err = false;
 
-	if (parse_gre_header(skb, &tpi, &csum_err) < 0)
+	if (parse_gre_header(skb, &tpi, &csum_err, false) < 0)
 		goto drop;
 
 	rcu_read_lock();
@@ -229,7 +232,7 @@ static void gre_cisco_err(struct sk_buff *skb, u32 info)
 	bool csum_err = false;
 	int i;
 
-	if (parse_gre_header(skb, &tpi, &csum_err)) {
+	if (parse_gre_header(skb, &tpi, &csum_err, true)) {
 		if (!csum_err)		/* ignore csum errors. */
 			return;
 	}
-- 
1.8.3.1
