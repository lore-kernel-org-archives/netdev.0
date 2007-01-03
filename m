From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 04/10] Don't do the UDP socket lookup if we already have
	one attached
Date: Wed, 03 Jan 2007 17:35:57 +0100
Message-ID: <20070103163557.14635.87510.stgit@nienna.balabit>
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

UDP input code path looks up the UDP socket hash tables to find a
socket matching the incoming packet. However, as iptable_tproxy does
socket lookups early the skb may already have the appropriate
reference attached, in that case we steal that reference instead of
doing the lookup.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 net/ipv4/udp.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cfff930..1b348f5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1225,8 +1225,15 @@ int __udp4_lib_rcv(struct sk_buff *skb,
 	if(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 		return __udp4_lib_mcast_deliver(skb, uh, saddr, daddr, udptable);
 
-	sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
-			       skb->dev->ifindex, udptable        );
+	if (skb->sk) {
+		/* steal reference */
+		sk = skb->sk;
+		skb->destructor = NULL;
+		skb->sk = NULL;
+	} else {
+		sk = __udp4_lib_lookup(saddr, uh->source, daddr, uh->dest,
+				       skb->dev->ifindex, udptable        );
+	}
 
 	if (sk != NULL) {
 		int ret = udp_queue_rcv_skb(sk, skb);
