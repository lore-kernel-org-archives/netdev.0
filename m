From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 03/10] Don't do the TCP socket lookup if we already have
	one attached
Date: Wed, 03 Jan 2007 17:35:27 +0100
Message-ID: <20070103163527.14635.18250.stgit@nienna.balabit>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
In-Reply-To: <20070103163357.14635.37754.stgit@nienna.balabit>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

TCP input code path looks up the TCP socket hash tables to find a
socket matching the incoming packet. However, as iptable_tproxy does
socket lookups early the skb may already have the appropriate
reference attached, in that case we steal that reference instead of
doing the lookup.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 net/ipv4/tcp_ipv4.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bf7a224..7828aec 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1647,9 +1647,16 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags	 = skb->nh.iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
-	sk = __inet_lookup(&tcp_hashinfo, skb->nh.iph->saddr, th->source,
-			   skb->nh.iph->daddr, th->dest,
-			   inet_iif(skb));
+	if (unlikely(skb->sk)) {
+		/* steal reference */
+		sk = skb->sk;
+		skb->destructor = NULL;
+		skb->sk = NULL;
+	} else {
+		sk = __inet_lookup(&tcp_hashinfo, skb->nh.iph->saddr, th->source,
+				   skb->nh.iph->daddr, th->dest,
+				   inet_iif(skb));
+	}
 
 	if (!sk)
 		goto no_tcp_socket;
