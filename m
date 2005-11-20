From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 10/13]: [NETFILTER]: Keep the conntrack reference until
	after policy checks
Date: Sun, 20 Nov 2005 17:31:41 +0100
Message-ID: <20051120163140.16666.70958.sendpatchset@localhost.localdomain>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
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

[NETFILTER]: Keep the conntrack reference until after policy checks

Keep the conntrack reference until policy checks have been performed for
IPsec NAT support. The reference needs to be dropped before a packet is
queued to avoid having the conntrack module unloadable and before icmp_send
is called to avoid having the reference attached manually to the outgoing
ICMP packet and the conntrack entry confirmed when ICMP packets leaves the
machine.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 3f615f37e68903f0eea66f5b242bfbb1875ee204
tree 4c3f9966a01f44784b9cd42e8f7091dbbc09fe5a
parent 8cb6cfa80dd5dc4da1de280a0278746c262a2d8d
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:08:45 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:08:45 +0100

 net/dccp/ipv4.c     |    1 +
 net/ipv4/ip_input.c |   15 +++++++--------
 net/ipv4/raw.c      |    1 +
 net/ipv4/tcp_ipv4.c |    1 +
 net/ipv4/udp.c      |    2 ++
 net/sctp/input.c    |    1 +
 6 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ca03521..0030923 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1147,6 +1147,7 @@ int dccp_v4_rcv(struct sk_buff *skb)
 		dccp_pr_debug("xfrm4_policy_check failed\n");
 		goto discard_and_relse;
 	}
+	nf_reset(skb);
 
         if (sk_filter(sk, skb, 0)) {
 		dccp_pr_debug("sk_filter failed\n");
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 473d0f2..1757778 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -203,10 +203,6 @@ static inline int ip_local_deliver_finis
 
 	__skb_pull(skb, ihl);
 
-	/* Free reference early: we don't need it any more, and it may
-           hold ip_conntrack module loaded indefinitely. */
-	nf_reset(skb);
-
         /* Point into the IP datagram, just past the header. */
         skb->h.raw = skb->data;
 
@@ -231,10 +227,12 @@ static inline int ip_local_deliver_finis
 		if ((ipprot = rcu_dereference(inet_protos[hash])) != NULL) {
 			int ret;
 
-			if (!ipprot->no_policy &&
-			    !xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-				kfree_skb(skb);
-				goto out;
+			if (!ipprot->no_policy) {
+				if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
+					kfree_skb(skb);
+					goto out;
+				}
+				nf_reset(skb);
 			}
 			ret = ipprot->handler(skb);
 			if (ret < 0) {
@@ -246,6 +244,7 @@ static inline int ip_local_deliver_finis
 			if (!raw_sk) {
 				if (xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 					IP_INC_STATS_BH(IPSTATS_MIB_INUNKNOWNPROTOS);
+					nf_reset(skb);
 					icmp_send(skb, ICMP_DEST_UNREACH,
 						  ICMP_PROT_UNREACH, 0);
 				}
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 421538a..8251a28 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -255,6 +255,7 @@ int raw_rcv(struct sock *sk, struct sk_b
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
+	nf_reset(skb);
 
 	skb_push(skb, skb->data - skb->nh.raw);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4d5021e..66300f9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1238,6 +1238,7 @@ process:
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
+	nf_reset(skb);
 
 	if (sk_filter(sk, skb, 0))
 		goto discard_and_relse;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2422a5f..483ca69 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1001,6 +1001,7 @@ static int udp_queue_rcv_skb(struct sock
 		kfree_skb(skb);
 		return -1;
 	}
+	nf_reset(skb);
 
 	if (up->encap_type) {
 		/*
@@ -1163,6 +1164,7 @@ int udp_rcv(struct sk_buff *skb)
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto drop;
+	nf_reset(skb);
 
 	/* No socket. Drop packet silently, if checksum is wrong */
 	if (udp_checksum_complete(skb))
diff --git a/net/sctp/input.c b/net/sctp/input.c
index b24ff2c..100f577 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -225,6 +225,7 @@ int sctp_rcv(struct sk_buff *skb)
 
 	if (!xfrm_policy_check(sk, XFRM_POLICY_IN, skb, family))
 		goto discard_release;
+	nf_reset(skb);
 
 	ret = sk_filter(sk, skb, 1);
 	if (ret)
