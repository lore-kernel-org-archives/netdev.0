From: Bill Sommerfeld <wsommerfeld@google.com>
Subject: [PATCH] Constrain UFO fragment sizes to multiples of 8 bytes
Date: Tue, 19 Jul 2011 18:22:33 -0700
Message-ID: <1311124953-32159-1-git-send-email-wsommerfeld@google.com>
Cc: netdev@vger.kernel.org, Tom Herbert <therbert@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:43097 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595Ab1GTBXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 21:23:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the ip fragment offset field counts 8-byte chunks, ip
fragments other than the last must contain a multiple of 8 bytes of
payload.  ip_ufo_append_data wasn't respecting this constraint and,
depending on the MTU and ip option sizes, could create malformed
non-final fragments.

Google-Bug-Id: 5009328
Signed-off-by: Bill Sommerfeld <wsommerfeld@google.com>
---

Note to reviewers: The first two hunks simply rename the "mtu"
parameter to "maxfraglen"; the real change is in the third hunk.
maxfraglen (the size of the largest non-final fragment which fits
inside mtu) is already computed for the non-UFO fragmentation path.

We saw this problem in a 2.6.34-based kernel with a bond device that
had UFO enabled (as a result of changeset d9f5950f90292f7c);
1742f183fc218798 rewrote netdev_increment_features to no longer force
on UFO.  The MTU on this bond device was set to 1470; fragmented
datagrams were mangled, causing the receiver to get errors of the
form:

[506259.362640] UDP: short packet: From x.x.x.x:nnnn 1471/1469 to y.y.y.y:nnnn

 net/ipv4/ip_output.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index be27e60..ccaaa85 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -734,7 +734,7 @@ static inline int ip_ufo_append_data(struct sock *sk,
 			int getfrag(void *from, char *to, int offset, int len,
 			       int odd, struct sk_buff *skb),
 			void *from, int length, int hh_len, int fragheaderlen,
-			int transhdrlen, int mtu, unsigned int flags)
+			int transhdrlen, int maxfraglen, unsigned int flags)
 {
 	struct sk_buff *skb;
 	int err;
@@ -767,7 +767,7 @@ static inline int ip_ufo_append_data(struct sock *sk,
 		skb->csum = 0;
 
 		/* specify the length of each IP datagram fragment */
-		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
+		skb_shinfo(skb)->gso_size = maxfraglen - fragheaderlen;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 		__skb_queue_tail(queue, skb);
 	}
@@ -831,7 +831,7 @@ static int __ip_append_data(struct sock *sk,
 	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len) {
 		err = ip_ufo_append_data(sk, queue, getfrag, from, length,
 					 hh_len, fragheaderlen, transhdrlen,
-					 mtu, flags);
+					 maxfraglen, flags);
 		if (err)
 			goto error;
 		return 0;
-- 
1.7.3.1

