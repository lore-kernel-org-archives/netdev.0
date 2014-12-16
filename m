From: David Miller <davem@davemloft.net>
Subject: Re: Netlink mmap tx security?
Date: Tue, 16 Dec 2014 17:58:17 -0500 (EST)
Message-ID: <20141216.175817.576861457076632402.davem@davemloft.net>
References: <20141014.220908.123550384430402000.davem@davemloft.net>
	<543F6998.5090000@redhat.com>
	<20141016070753.GA16738@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, luto@amacapital.net,
	torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbaLPW6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 17:58:20 -0500
In-Reply-To: <20141016070753.GA16738@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 16 Oct 2014 08:07:53 +0100

> On 10/16/14 at 08:45am, Daniel Borkmann wrote:
>> On 10/15/2014 04:09 AM, David Miller wrote:
>> >That would work as well.
>> >
>> >There are pros and cons to all of these approaches.
>> >
>> >I was thinking that if we do the "TX mmap --> copy to kernel buffer"
>> >approach, then if in the future we find a way to make it work
>> >reliably, we can avoid the copy.  And frankly performance wise it's no
>> >worse than what happens via normal sendmsg() calls.
>> >
>> >And all applications using NETLINK_RX_RING keep working and keep
>> >getting the performance boost.
>> 
>> That would be better, yes. This would avoid having such a TPACKET_V*
>> API chaos we have in packet sockets if this could be fixed for netlink
>> eventually.
> 
> Only saw the second part of Dave's message now. I agree that this
> is even a better option.

Sorry for dropping the ball on this, here is the patch I have right
now, any comments?

====================
[PATCH] netlink: Always copy on mmap TX.

Checking the file f_count and the nlk->mapped count is not completely
sufficient to prevent the mmap'd area contents from changing from
under us during netlink mmap sendmsg() operations.

Be careful to sample the header's length field only once, because this
could change from under us as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netlink/af_netlink.c | 52 +++++++++++++++---------------------------------
 1 file changed, 16 insertions(+), 36 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ef5f77b..a64680a 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -525,14 +525,14 @@ out:
 	return err;
 }
 
-static void netlink_frame_flush_dcache(const struct nl_mmap_hdr *hdr)
+static void netlink_frame_flush_dcache(const struct nl_mmap_hdr *hdr, unsigned int nm_len)
 {
 #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
 	struct page *p_start, *p_end;
 
 	/* First page is flushed through netlink_{get,set}_status */
 	p_start = pgvec_to_page(hdr + PAGE_SIZE);
-	p_end   = pgvec_to_page((void *)hdr + NL_MMAP_HDRLEN + hdr->nm_len - 1);
+	p_end   = pgvec_to_page((void *)hdr + NL_MMAP_HDRLEN + nm_len - 1);
 	while (p_start <= p_end) {
 		flush_dcache_page(p_start);
 		p_start++;
@@ -714,24 +714,16 @@ static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
 	struct nl_mmap_hdr *hdr;
 	struct sk_buff *skb;
 	unsigned int maxlen;
-	bool excl = true;
 	int err = 0, len = 0;
 
-	/* Netlink messages are validated by the receiver before processing.
-	 * In order to avoid userspace changing the contents of the message
-	 * after validation, the socket and the ring may only be used by a
-	 * single process, otherwise we fall back to copying.
-	 */
-	if (atomic_long_read(&sk->sk_socket->file->f_count) > 1 ||
-	    atomic_read(&nlk->mapped) > 1)
-		excl = false;
-
 	mutex_lock(&nlk->pg_vec_lock);
 
 	ring   = &nlk->tx_ring;
 	maxlen = ring->frame_size - NL_MMAP_HDRLEN;
 
 	do {
+		unsigned int nm_len;
+
 		hdr = netlink_current_frame(ring, NL_MMAP_STATUS_VALID);
 		if (hdr == NULL) {
 			if (!(msg->msg_flags & MSG_DONTWAIT) &&
@@ -739,35 +731,23 @@ static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
 				schedule();
 			continue;
 		}
-		if (hdr->nm_len > maxlen) {
+
+		nm_len = ACCESS_ONCE(hdr->nm_len);
+		if (nm_len > maxlen) {
 			err = -EINVAL;
 			goto out;
 		}
 
-		netlink_frame_flush_dcache(hdr);
+		netlink_frame_flush_dcache(hdr, nm_len);
 
-		if (likely(dst_portid == 0 && dst_group == 0 && excl)) {
-			skb = alloc_skb_head(GFP_KERNEL);
-			if (skb == NULL) {
-				err = -ENOBUFS;
-				goto out;
-			}
-			sock_hold(sk);
-			netlink_ring_setup_skb(skb, sk, ring, hdr);
-			NETLINK_CB(skb).flags |= NETLINK_SKB_TX;
-			__skb_put(skb, hdr->nm_len);
-			netlink_set_status(hdr, NL_MMAP_STATUS_RESERVED);
-			atomic_inc(&ring->pending);
-		} else {
-			skb = alloc_skb(hdr->nm_len, GFP_KERNEL);
-			if (skb == NULL) {
-				err = -ENOBUFS;
-				goto out;
-			}
-			__skb_put(skb, hdr->nm_len);
-			memcpy(skb->data, (void *)hdr + NL_MMAP_HDRLEN, hdr->nm_len);
-			netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
+		skb = alloc_skb(nm_len, GFP_KERNEL);
+		if (skb == NULL) {
+			err = -ENOBUFS;
+			goto out;
 		}
+		__skb_put(skb, nm_len);
+		memcpy(skb->data, (void *)hdr + NL_MMAP_HDRLEN, nm_len);
+		netlink_set_status(hdr, NL_MMAP_STATUS_UNUSED);
 
 		netlink_increment_head(ring);
 
@@ -813,7 +793,7 @@ static void netlink_queue_mmaped_skb(struct sock *sk, struct sk_buff *skb)
 	hdr->nm_pid	= NETLINK_CB(skb).creds.pid;
 	hdr->nm_uid	= from_kuid(sk_user_ns(sk), NETLINK_CB(skb).creds.uid);
 	hdr->nm_gid	= from_kgid(sk_user_ns(sk), NETLINK_CB(skb).creds.gid);
-	netlink_frame_flush_dcache(hdr);
+	netlink_frame_flush_dcache(hdr, hdr->nm_len);
 	netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
 
 	NETLINK_CB(skb).flags |= NETLINK_SKB_DELIVERED;
-- 
2.1.0
