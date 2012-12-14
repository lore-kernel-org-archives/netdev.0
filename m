From: Duan Jiong <djduanjiong@gmail.com>
Subject: [PATCH v3] ipv6: Change skb->data before using icmpv6_notify() to
 propagate redirect
Date: Fri, 14 Dec 2012 20:59:59 +0800
Message-ID: <50CB22CF.9010505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:62666 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147Ab2LNNAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 08:00:05 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so1475388dak.19
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2012 05:00:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In function ndisc_redirect_rcv(), the skb->data points to the transport
header, but function icmpv6_notify() need the skb->data points to the
inner IP packet. So before using icmpv6_notify() to propagate redirect,
change skb->data to point the inner IP packet that triggered the sending
of the Redirect, and introduce struct rd_msg to make it easy.

Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
---
 include/net/ndisc.h |    7 +++++++
 net/ipv6/ndisc.c    |   17 +++++++++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 980d263..6b305d7 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -78,6 +78,13 @@ struct ra_msg {
 	__be32			retrans_timer;
 };
 
+struct rd_msg {
+	struct icmp6hdr icmph;
+	struct in6_addr	target;
+	struct in6_addr	dest;
+	__u8		opt[0];
+};
+
 struct nd_opt_hdr {
 	__u8		nd_opt_type;
 	__u8		nd_opt_len;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 2edce30..89dab79 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1314,6 +1314,12 @@ out:
 
 static void ndisc_redirect_rcv(struct sk_buff *skb)
 {
+	u8 *hdr;
+	struct ndisc_options ndopts;
+	struct rd_msg *msg = (struct rd_msg *)skb_transport_header(skb);
+	u32 ndoptlen = skb->tail - (skb->transport_header +
+				    offsetof(struct rd_msg, opt));
+
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	switch (skb->ndisc_nodetype) {
 	case NDISC_NODETYPE_HOST:
@@ -1330,6 +1336,17 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 		return;
 	}
 
+	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
+		return;
+
+	if (!ndopts.nd_opts_rh)
+		return;
+
+	hdr = (u8 *)ndopts.nd_opts_rh;
+	hdr += 8;
+	if (!pskb_pull(skb, hdr - skb_transport_header(skb)))
+		return;
+
 	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
 }
 
-- 
1.7.1
