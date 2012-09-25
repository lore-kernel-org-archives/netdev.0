From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: raw: revert unrelated change
Date: Tue, 25 Sep 2012 08:21:16 +0200
Message-ID: <1348554076.26828.1990.camel@edumazet-glaptop>
References: <20120925123438.bbf3126889513ee5cc195e5c@canb.auug.org.au>
	 <1348549842.26828.1897.camel@edumazet-glaptop>
	 <20120925.011343.1495275645575636949.davem@davemloft.net>
	 <1348550602.26828.1918.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1348550602.26828.1918.camel@edumazet-glaptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

Commit 5640f7685831 ("net: use a per task frag allocator")
accidentally contained an unrelated change to net/ipv4/raw.c,
later committed (without the pr_err() debugging bits) in
net tree as commit ab43ed8b749 (ipv4: raw: fix icmp_filter())

This patch reverts this glitch, noticed by Stephen Rothwell.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/raw.c |   19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index a80740b..f242578 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -131,23 +131,18 @@ found:
  *	0 - deliver
  *	1 - block
  */
-static int icmp_filter(const struct sock *sk, const struct sk_buff *skb)
+static __inline__ int icmp_filter(struct sock *sk, struct sk_buff *skb)
 {
-	struct icmphdr _hdr;
-	const struct icmphdr *hdr;
-
-	pr_err("icmp_filter skb_transport_offset %d data-head %ld len %d/%d\n",
-		skb_transport_offset(skb), skb->data - skb->head, skb->len, skb->data_len);
-	hdr = skb_header_pointer(skb, skb_transport_offset(skb),
-				 sizeof(_hdr), &_hdr);
-	pr_err("head %p data %p hdr %p type %d\n", skb->head, skb->data, hdr, hdr ? hdr->type : -1);
-	if (!hdr)
+	int type;
+
+	if (!pskb_may_pull(skb, sizeof(struct icmphdr)))
 		return 1;
 
-	if (hdr->type < 32) {
+	type = icmp_hdr(skb)->type;
+	if (type < 32) {
 		__u32 data = raw_sk(sk)->filter.data;
 
-		return ((1U << hdr->type) & data) != 0;
+		return ((1 << type) & data) != 0;
 	}
 
 	/* Do not block unknown ICMP types */
