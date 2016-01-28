From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH V2] netfilter: h323: avoid potential attack
Date: Thu, 28 Jan 2016 16:59:57 +0800
Message-ID: <1453971597-4811-1-git-send-email-zhouzhouyi@gmail.com>
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: eric.dumazet@gmail.com, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.or
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Eric for your review and advice.

I think hackers chould build a malicious h323 packet to overflow
the pointer p which will panic during the memcpy(addr, p, len)

For example, he may fabricate a very large taddr->ipAddress.ip;

Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
---
 net/netfilter/nf_conntrack_h323_main.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 9511af0..ccd08c5 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -110,6 +110,7 @@ int (*nat_q931_hook) (struct sk_buff *skb,
 
 static DEFINE_SPINLOCK(nf_h323_lock);
 static char *h323_buffer;
+#define CHECK_BOUND(p, n) ((void *)p + n - (void *)h323_buffer > 65536)
 
 static struct nf_conntrack_helper nf_conntrack_helper_h245;
 static struct nf_conntrack_helper nf_conntrack_helper_q931[];
@@ -247,6 +248,9 @@ static int get_h245_addr(struct nf_conn *ct, const unsigned char *data,
 		return 0;
 	}
 
+	if (CHECK_BOUND(p, len + sizeof(__be16)))
+		return 0;
+
 	memcpy(addr, p, len);
 	memset((void *)addr + len, 0, sizeof(*addr) - len);
 	memcpy(port, p + len, sizeof(__be16));
@@ -669,6 +673,9 @@ int get_h225_addr(struct nf_conn *ct, unsigned char *data,
 		return 0;
 	}
 
+	if (CHECK_BOUND(p, len + sizeof(__be16)))
+		return 0;
+
 	memcpy(addr, p, len);
 	memset((void *)addr + len, 0, sizeof(*addr) - len);
 	memcpy(port, p + len, sizeof(__be16));
-- 
1.7.10.4


