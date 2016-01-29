From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH V3] netfilter: h323: avoid potential attack
Date: Fri, 29 Jan 2016 11:25:35 +0800
Message-ID: <1454037935-14842-1-git-send-email-zhouzhouyi@gmail.com>
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: eric.dumazet@gmail.com, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, fw@strlen.de,
	gnomes@lxorguk.ukuu.org.uk, sergei.shtylyov@cogentembedded.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think hackers chould build a malicious h323 packet to overflow
the pointer p which will panic during the memcpy(addr, p, len)
For example, he may fabricate a very large taddr->ipAddress.ip;
As suggested by Eric, this module is protected by a lock (nf_h323_lock)
so adding a variable h323_buffer_valid_bytes that would contain
the number of valid bytes would not require to change prototypes of
get_h2x5_addr.

Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> 

---
 net/netfilter/nf_conntrack_h323_main.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 9511af0..65d84bc 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -110,6 +110,11 @@ int (*nat_q931_hook) (struct sk_buff *skb,
 
 static DEFINE_SPINLOCK(nf_h323_lock);
 static char *h323_buffer;
+static unsigned int h323_buffer_valid_bytes;
+/* check offset overflow and out of range data reference */
+#define CHECK_BOUND(p, n) ((n) > h323_buffer_valid_bytes ||		\
+			   ((void *)(p) + (n) - (void *)h323_buffer	\
+			    > h323_buffer_valid_bytes))
 
 static struct nf_conntrack_helper nf_conntrack_helper_h245;
 static struct nf_conntrack_helper nf_conntrack_helper_q931[];
@@ -145,6 +150,7 @@ static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 
 	if (*data == NULL) {	/* first TPKT */
 		/* Get first TPKT pointer */
+		h323_buffer_valid_bytes = tcpdatalen;
 		tpkt = skb_header_pointer(skb, tcpdataoff, tcpdatalen,
 					  h323_buffer);
 		BUG_ON(tpkt == NULL);
@@ -247,6 +253,9 @@ static int get_h245_addr(struct nf_conn *ct, const unsigned char *data,
 		return 0;
 	}
 
+	if (CHECK_BOUND(p, len + sizeof(__be16)))
+		return 0;
+
 	memcpy(addr, p, len);
 	memset((void *)addr + len, 0, sizeof(*addr) - len);
 	memcpy(port, p + len, sizeof(__be16));
@@ -669,6 +678,9 @@ int get_h225_addr(struct nf_conn *ct, unsigned char *data,
 		return 0;
 	}
 
+	if (CHECK_BOUND(p, len + sizeof(__be16)))
+		return 0;
+
 	memcpy(addr, p, len);
 	memset((void *)addr + len, 0, sizeof(*addr) - len);
 	memcpy(port, p + len, sizeof(__be16));
@@ -1248,6 +1260,7 @@ static unsigned char *get_udp_data(struct sk_buff *skb, unsigned int protoff,
 	if (dataoff >= skb->len)
 		return NULL;
 	*datalen = skb->len - dataoff;
+	h323_buffer_valid_bytes = *datalen;
 	return skb_header_pointer(skb, dataoff, *datalen, h323_buffer);
 }
 
-- 
1.9.1


