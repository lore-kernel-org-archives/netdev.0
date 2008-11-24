From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: avoid a pair of dst_hold()/dst_release() in ip_push_pending_frames()
Date: Mon, 24 Nov 2008 14:59:51 +0100
Message-ID: <492AB357.1080304@cosmosbay.com>
References: <492A6C94.7030308@cosmosbay.com> <87y6z9h33h.fsf@basil.nowhere.org> <492A7E85.3060502@cosmosbay.com> <492A8F05.3080509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050304030009070809050009"
Cc: Andi Kleen <andi@firstfloor.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Corey Minyard <minyard@acm.org>,
	Christian Bell <christian@myri.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:60863 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbYKXOAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:00:06 -0500
In-Reply-To: <492A8F05.3080509@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050304030009070809050009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

We can reduce pressure on dst entry refcount that slowdown UDP transmit
path on SMP machines. This pressure is visible on RTP servers when
delivering content to mediagateways, especially big ones, handling
thousand of streams. Several cpus send UDP frames to the same
destination, hence use the same dst entry.

This patch makes ip_push_pending_frames() steal the refcount its
callers had to take when filling inet->cork.dst.

This doesnt avoid all refcounting, but still gives speedups on SMP,
on UDP/RAW transmit path.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv4/ip_output.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)

--------------050304030009070809050009
Content-Type: text/plain;
 name="ip_push_pending_frames.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ip_push_pending_frames.patch"

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 46d7be2..89bc1b9 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1279,7 +1279,12 @@ int ip_push_pending_frames(struct sock *sk)
 
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
-	skb->dst = dst_clone(&rt->u.dst);
+	/*
+	 * Steal rt from cork.dst to avoid a pair of atomic_inc/atomic_dec
+	 * on dst refcount
+	 */
+	inet->cork.dst = NULL;
+	skb->dst = &rt->u.dst;
 
 	if (iph->protocol == IPPROTO_ICMP)
 		icmp_out_count(net, ((struct icmphdr *)

--------------050304030009070809050009--
