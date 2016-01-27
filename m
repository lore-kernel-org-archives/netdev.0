From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH 1/1] netfilter: h323: avoid potential attack
Date: Wed, 27 Jan 2016 22:40:45 +0800
Message-ID: <1453905646-6446-1-git-send-email-zhouzhouyi@gmail.com>
Cc: Zhouyi Zhou <yizhouzhou@ict.ac.cn>,
	Zhouyi Zhou <zhouzhouyi@gmail.com>
To: <pablo@netfilter.org>, <kaber@trash.net>,
	<kadlec@blackhole.kfki.hu>, <davem@davemloft.net>,
	<netfilter-devel@vger.kernel.org>, <coreteam@netfilter.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp15.cstnet.cn ([159.226.251.15]:56259 "EHLO cstnet.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932725AbcA0Ou2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 09:50:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhouyi Zhou <yizhouzhou@ict.ac.cn>

I think hackers chould build a malicious h323 packet to overflow
the pointer p which will panic during the memcpy(addr, p, len)

For example, he may fabricate a very large taddr->ipAddress.ip; 

Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
---
 net/netfilter/nf_conntrack_h323_main.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 9511af0..3b3dd8c 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -110,6 +110,10 @@ int (*nat_q931_hook) (struct sk_buff *skb,
 
 static DEFINE_SPINLOCK(nf_h323_lock);
 static char *h323_buffer;
+#define CHECK_BOUND(p, n) do {					\
+		if (((p - h323_buffer) + n) > 65536)		\
+			return 0;				\
+} while (0)
 
 static struct nf_conntrack_helper nf_conntrack_helper_h245;
 static struct nf_conntrack_helper nf_conntrack_helper_q931[];
@@ -247,6 +251,8 @@ static int get_h245_addr(struct nf_conn *ct, const unsigned char *data,
 		return 0;
 	}
 
+	CHECK_BOUND(p, len);
+
 	memcpy(addr, p, len);
 	memset((void *)addr + len, 0, sizeof(*addr) - len);
 	memcpy(port, p + len, sizeof(__be16));
@@ -669,6 +675,8 @@ int get_h225_addr(struct nf_conn *ct, unsigned char *data,
 		return 0;
 	}
 
+	CHECK_BOUND(p, len);
+
 	memcpy(addr, p, len);
 	memset((void *)addr + len, 0, sizeof(*addr) - len);
 	memcpy(port, p + len, sizeof(__be16));
-- 
1.7.10.4
