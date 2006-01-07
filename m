From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER 08/10]: Keep conntrack reference until IPsec policy
	checks are done
Date: Sat,  7 Jan 2006 02:09:42 +0100 (MET)
Message-ID: <20060107010906.8712.84422.sendpatchset@localhost.localdomain>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S. Miller <davem@davemloft.net>
In-Reply-To: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
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

[NETFILTER]: Keep conntrack reference until IPsec policy checks are done

Keep the conntrack reference until policy checks have been performed for
IPsec NAT support. The reference needs to be dropped before a packet is
queued to avoid having the conntrack module unloadable.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7573dacaa96b4bd8ddc1be7139d17f7c95010413
tree 63a51c62e2d7a4730df5339a0f7d22f1121c8750
parent 00b264ce82ccc3216e3e4b0175dd1337eeb16f24
author Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 01:22:09 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 01:22:09 +0100

 net/dccp/ipv4.c     |    1 +
 net/ipv4/ip_input.c |   15 ++++++---------
 net/ipv4/raw.c      |    1 +
 net/ipv4/tcp_ipv4.c |    1 +
 net/ipv4/udp.c      |    2 ++
 net/sctp/input.c    |    1 +
 6 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 3f24467..23ba177 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1099,6 +1099,7 @@ int dccp_v4_destroy_sock(struct sock *sk
 		kfree_skb(sk->sk_send_head);
 		sk->sk_send_head = NULL;
 	}
+	nf_reset(skb);
 
 	/* Clean up a referenced DCCP bind bucket. */
 	if (inet_csk(sk)->icsk_bind_hash != NULL)
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index e45846a..18d7fad 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -185,7 +185,6 @@ int ip_call_ra_chain(struct sk_buff *skb
 					raw_rcv(last, skb2);
 			}
 			last = sk;
-			nf_reset(skb);
 		}
 	}
 
@@ -204,10 +203,6 @@ static inline int ip_local_deliver_finis
 
 	__skb_pull(skb, ihl);
 
-	/* Free reference early: we don't need it any more, and it may
-           hold ip_conntrack module loaded indefinitely. */
-	nf_reset(skb);
-
         /* Point into the IP datagram, just past the header. */
         skb->h.raw = skb->data;
 
@@ -232,10 +227,12 @@ static inline int ip_local_deliver_finis
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
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 4b0d7e4..165a4d8 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -255,6 +255,7 @@ int raw_rcv(struct sock *sk, struct sk_b
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
+	nf_reset(skb);
 
 	skb_push(skb, skb->data - skb->nh.raw);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e9f83e5..6ea3539 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1080,6 +1080,7 @@ process:
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
+	nf_reset(skb);
 
 	if (sk_filter(sk, skb, 0))
 		goto discard_and_relse;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 223abaa..0084047 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -989,6 +989,7 @@ static int udp_queue_rcv_skb(struct sock
 		kfree_skb(skb);
 		return -1;
 	}
+	nf_reset(skb);
 
 	if (up->encap_type) {
 		/*
@@ -1149,6 +1150,7 @@ int udp_rcv(struct sk_buff *skb)
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto drop;
+	nf_reset(skb);
 
 	/* No socket. Drop packet silently, if checksum is wrong */
 	if (udp_checksum_complete(skb))
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 238f1bf..4aa6fc6 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -225,6 +225,7 @@ int sctp_rcv(struct sk_buff *skb)
 
 	if (!xfrm_policy_check(sk, XFRM_POLICY_IN, skb, family))
 		goto discard_release;
+	nf_reset(skb);
 
 	ret = sk_filter(sk, skb, 1);
 	if (ret)
