From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: DNS (?) not working on G5 (64-bit powerpc) (was
 [net-next,v3,3/3] udp: try to avoid 2 cache miss on dequeue)
Date: Thu, 22 Jun 2017 22:57:06 +0200
Message-ID: <1498165026.2503.21.camel@redhat.com>
References: <87shisqihz.fsf@concordia.ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49450 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751193AbdFVU5O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 16:57:14 -0400
In-Reply-To: <87shisqihz.fsf@concordia.ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-22 at 23:06 +1000, Michael Ellerman wrote:
> Paolo wrote:
> > when udp_recvmsg() is executed, on x86_64 and other archs, most skb
> > fields are on cold cachelines.
> > If the skb are linear and the kernel don't need to compute the udp
> > csum, only a handful of skb fields are required by udp_recvmsg().
> > Since we already use skb->dev_scratch to cache hot data, and
> > there are 32 bits unused on 64 bit archs, use such field to cache
> > as much data as we can, and try to prefetch on dequeue the relevant
> > fields that are left out.
> > 
> > This can save up to 2 cache miss per packet.
> > 
> > v1 -> v2:
> >   - changed udp_dev_scratch fields types to u{32,16} variant,
> >     replaced bitfiled with bool
> > 
> > Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> > Acked-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  net/ipv4/udp.c | 114 +++++++++++++++++++++++++++++++++++++++++++++++++++------
> >  1 file changed, 103 insertions(+), 11 deletions(-)
> 
> This appears to break wget on one of my machines.
> 
> Networking in general is working, I'm able to SSH in, but then I can't
> do a wget.

Can you please check if the following patch fixes the issue? Only
compiled tested here.

Thanks!!!
---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 067a607..80d89fe 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1446,16 +1446,19 @@ static struct sk_buff *__first_packet_length(struct sock *sk,
 {
 	struct sk_buff *skb;
 
-	while ((skb = skb_peek(rcvq)) != NULL &&
-	       udp_lib_checksum_complete(skb)) {
-		__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS,
-				IS_UDPLITE(sk));
-		__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
-				IS_UDPLITE(sk));
-		atomic_inc(&sk->sk_drops);
-		__skb_unlink(skb, rcvq);
-		*total += skb->truesize;
-		kfree_skb(skb);
+	while ((skb = skb_peek(rcvq)) != NULL) {
+		if (udp_lib_checksum_complete(skb)) {
+			__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS,
+					IS_UDPLITE(sk));
+			__UDP_INC_STATS(sock_net(sk), UDP_MIB_INERRORS,
+					IS_UDPLITE(sk));
+			atomic_inc(&sk->sk_drops);
+			__skb_unlink(skb, rcvq);
+			*total += skb->truesize;
+			kfree_skb(skb);
+		} else {
+			udp_set_dev_scratch(skb);
+		}
 	}
 	return skb;
 }
