From: Ronen Arad <ronen.arad@intel.com>
Subject: [PATCH net-next v2] netlink: Trim skb to alloc size to avoid MSG_TRUNC
Date: Thu, 15 Oct 2015 01:55:17 -0700
Message-ID: <1444899317-3345-1-git-send-email-ronen.arad@intel.com>
References: <1444698923-13992-1-git-send-email-ronen.arad@intel.com>
Cc: Ronen Arad <ronen.arad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50500 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732AbbJOIzc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 04:55:32 -0400
In-Reply-To: <1444698923-13992-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink_dump() allocates skb based on the calculated min_dump_alloc or
a per socket max_recvmsg_len.
min_alloc_size is maximum space required for any single netdev
attributes as calculated by rtnl_calcit().
max_recvmsg_len tracks the user provided buffer to netlink_recvmsg.
It is capped at 16KiB.
The intention is to avoid small allocations and to minimize the number
of calls required to obtain dump information for all net devices.

netlink_dump packs as many small messages as could fit within an skb
that was sized for the largest single netdev information. The actual
space available within an skb is larger than what is requested. It could
be much larger and up to near 2x with align to next power of 2 approach.

Allowing netlink_dump to use all the space available within the
allocated skb increases the buffer size a user has to provide to avoid
truncaion (i.e. MSG_TRUNG flag set).

It was observed that with many VLANs configured on at least one netdev,
a larger buffer of near 64KiB was necessary to avoid "Message truncated"
error in "ip link" or "bridge [-c[ompressvlans]] vlan show" when
min_alloc_size was only little over 32KiB.

This patch trims skb to allocated size in order to allow the user to
avoid truncation with more reasonable buffer size.

Signed-off-by: Ronen Arad <ronen.arad@intel.com>
---
 net/netlink/af_netlink.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 8f060d7..0a49a8c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2785,6 +2785,7 @@ static int netlink_dump(struct sock *sk)
 	struct sk_buff *skb = NULL;
 	struct nlmsghdr *nlh;
 	int len, err = -ENOBUFS;
+	int alloc_min_size;
 	int alloc_size;
 
 	mutex_lock(nlk->cb_mutex);
@@ -2793,9 +2794,6 @@ static int netlink_dump(struct sock *sk)
 		goto errout_skb;
 	}
 
-	cb = &nlk->cb;
-	alloc_size = max_t(int, cb->min_dump_alloc, NLMSG_GOODSIZE);
-
 	if (!netlink_rx_is_mmaped(sk) &&
 	    atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
 		goto errout_skb;
@@ -2805,23 +2803,35 @@ static int netlink_dump(struct sock *sk)
 	 * to reduce number of system calls on dump operations, if user
 	 * ever provided a big enough buffer.
 	 */
-	if (alloc_size < nlk->max_recvmsg_len) {
-		skb = netlink_alloc_skb(sk,
-					nlk->max_recvmsg_len,
-					nlk->portid,
+	cb = &nlk->cb;
+	alloc_min_size = max_t(int, cb->min_dump_alloc, NLMSG_GOODSIZE);
+
+	if (alloc_min_size < nlk->max_recvmsg_len) {
+		alloc_size = nlk->max_recvmsg_len;
+		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
 					GFP_KERNEL |
 					__GFP_NOWARN |
 					__GFP_NORETRY);
-		/* available room should be exact amount to avoid MSG_TRUNC */
-		if (skb)
-			skb_reserve(skb, skb_tailroom(skb) -
-					 nlk->max_recvmsg_len);
 	}
-	if (!skb)
+	if (!skb) {
+		alloc_size = alloc_min_size;
 		skb = netlink_alloc_skb(sk, alloc_size, nlk->portid,
 					GFP_KERNEL);
+	}
 	if (!skb)
 		goto errout_skb;
+
+	/* Trim skb to allocated size. User is expected to provide buffer as
+	 * large as max(min_dump_alloc, 16KiB (mac_recvmsg_len capped at
+	 * netlink_recvmsg())). dump will pack as many smaller messages as
+	 * could fit within the allocated skb. skb is typically allocated
+	 * with larger space than required (could be as much as near 2x the
+	 * requested size with align to next power of 2 approach). Allowing
+	 * dump to use the excess space makes it difficult for a user to have a
+	 * reasonable static buffer based on the expected largest dump of a
+	 * single netdev. The outcome is MSG_TRUNC error.
+	 */
+	skb_reserve(skb, skb_tailroom(skb) - alloc_size);
 	netlink_skb_set_owner_r(skb, sk);
 
 	len = cb->dump(skb, cb);
-- 
2.1.0
