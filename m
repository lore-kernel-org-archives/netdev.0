From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 09/18] switch memcpy_fromiovec()/memcpy_fromiovecend() users to copy_from_iter()
Date: Sat, 31 Jan 2015 03:56:35 +0000
Message-ID: <1422676604-18533-9-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54998 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757107AbbAaD4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:56:46 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

That takes care of the majority of ->sendmsg() instances - most of them
via memcpy_to_msg() or assorted getfrag() callbacks.  One place where we
still keep memcpy_fromiovecend() is tipc - there we potentially read the
same data over and over; separate patch, that...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/linux/skbuff.h |  3 +--
 include/net/udplite.h  |  3 +--
 net/ipv4/ip_output.c   |  6 ++----
 net/ipv4/ping.c        | 14 +++++++-------
 net/ipv4/raw.c         |  2 +-
 net/ipv4/tcp_input.c   |  2 +-
 net/ipv6/raw.c         |  2 +-
 7 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9a8bafe..b349c96 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2692,8 +2692,7 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci);
 
 static inline int memcpy_from_msg(void *data, struct msghdr *msg, int len)
 {
-	/* XXX: stripping const */
-	return memcpy_fromiovec(data, (struct iovec *)msg->msg_iter.iov, len);
+	return copy_from_iter(data, len, &msg->msg_iter) == len ? 0 : -EFAULT;
 }
 
 static inline int memcpy_to_msg(struct msghdr *msg, void *data, int len)
diff --git a/include/net/udplite.h b/include/net/udplite.h
index ae7c8d1..8076193 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -20,8 +20,7 @@ static __inline__ int udplite_getfrag(void *from, char *to, int  offset,
 				      int len, int odd, struct sk_buff *skb)
 {
 	struct msghdr *msg = from;
-	/* XXX: stripping const */
-	return memcpy_fromiovecend(to, (struct iovec *)msg->msg_iter.iov, offset, len);
+	return copy_from_iter(to, len, &msg->msg_iter) != len ? -EFAULT : 0;
 }
 
 /* Designate sk as UDP-Lite socket */
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index b50861b2..f998bc8 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -755,13 +755,11 @@ ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk
 	struct msghdr *msg = from;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		/* XXX: stripping const */
-		if (memcpy_fromiovecend(to, (struct iovec *)msg->msg_iter.iov, offset, len) < 0)
+		if (copy_from_iter(to, len, &msg->msg_iter) != len)
 			return -EFAULT;
 	} else {
 		__wsum csum = 0;
-		/* XXX: stripping const */
-		if (csum_partial_copy_fromiovecend(to, (struct iovec *)msg->msg_iter.iov, offset, len, &csum) < 0)
+		if (csum_and_copy_from_iter(to, len, &csum, &msg->msg_iter) != len)
 			return -EFAULT;
 		skb->csum = csum_block_add(skb->csum, csum, odd);
 	}
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 9e15ba7..e9f66e1 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -599,18 +599,18 @@ int ping_getfrag(void *from, char *to,
 	struct pingfakehdr *pfh = (struct pingfakehdr *)from;
 
 	if (offset == 0) {
-		if (fraglen < sizeof(struct icmphdr))
+		fraglen -= sizeof(struct icmphdr);
+		if (fraglen < 0)
 			BUG();
-		if (csum_partial_copy_fromiovecend(to + sizeof(struct icmphdr),
-			    pfh->msg->msg_iter.iov, 0, fraglen - sizeof(struct icmphdr),
-			    &pfh->wcheck))
+		if (csum_and_copy_from_iter(to + sizeof(struct icmphdr),
+			    fraglen, &pfh->wcheck,
+			    &pfh->msg->msg_iter) != fraglen)
 			return -EFAULT;
 	} else if (offset < sizeof(struct icmphdr)) {
 			BUG();
 	} else {
-		if (csum_partial_copy_fromiovecend
-				(to, pfh->msg->msg_iter.iov, offset - sizeof(struct icmphdr),
-				 fraglen, &pfh->wcheck))
+		if (csum_and_copy_from_iter(to, fraglen, &pfh->wcheck,
+					    &pfh->msg->msg_iter) != fraglen)
 			return -EFAULT;
 	}
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2c9d252..f027a70 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -382,7 +382,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb->transport_header = skb->network_header;
 	err = -EFAULT;
-	if (memcpy_fromiovecend((void *)iph, msg->msg_iter.iov, 0, length))
+	if (memcpy_from_msg(iph, msg, length))
 		goto error_free;
 
 	iphlen = iph->ihl * 4;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 93c7482..71fb37c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4368,7 +4368,7 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
 	if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
 		goto err_free;
 
-	if (copy_from_iter(skb_put(skb, size), size, &msg->msg_iter) != size)
+	if (memcpy_from_msg(skb_put(skb, size), msg, size))
 		goto err_free;
 
 	TCP_SKB_CB(skb)->seq = tcp_sk(sk)->rcv_nxt;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 0dbb328..dae7f1a 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -648,7 +648,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 	skb->ip_summed = CHECKSUM_NONE;
 
 	skb->transport_header = skb->network_header;
-	err = memcpy_fromiovecend((void *)iph, msg->msg_iter.iov, 0, length);
+	err = memcpy_from_msg(iph, msg, length);
 	if (err)
 		goto error_fault;
 
-- 
2.1.4
