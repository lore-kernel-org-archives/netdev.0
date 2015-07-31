From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Panic with demuxed ipv4 multicast udp sockets on 4.0.4
Date: Fri, 31 Jul 2015 13:17:29 +0200
Message-ID: <1438341449.2748.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2ddbe291fff643899849eb068ef219e0@svr-chch-ex1.atlnz.lc>
	 <1438234969.20182.124.camel@edumazet-glaptop2.roam.corp.google.com>
	 ,<1438235159.20182.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0dd213ace919410da723ac93892d1f4d@svr-chch-ex1.atlnz.lc>
	 <1438337866.2748.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alexgartrell@gmail.com" <alexgartrell@gmail.com>
To: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36584 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbbGaLRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 07:17:33 -0400
Received: by wicgj17 with SMTP id gj17so13152500wic.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 04:17:32 -0700 (PDT)
In-Reply-To: <1438337866.2748.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-31 at 12:17 +0200, Eric Dumazet wrote:
> On Thu, 2015-07-30 at 22:29 +0000, Gregory Hoggarth wrote:
> > Hi Eric,
> > 
> > Thanks for the patch. I have put this into our code and we'll run our test over tonight and the weekend and report back on Monday.
> > 
> > Thanks,
> 
> Oh well, real fix will be :
> 
> (Or at least test if DST_NOCACHE is set : those dst need special care)

Here is a more complete patch, not destroying performance of unicast
UDP.

Please guys test it, I am confident it should solve your problems.

Thanks

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 83aa604f9273..1b8c5ba7d5f7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1995,12 +1995,19 @@ void udp_v4_early_demux(struct sk_buff *skb)
 
 	skb->sk = sk;
 	skb->destructor = sock_efree;
-	dst = sk->sk_rx_dst;
+	dst = READ_ONCE(sk->sk_rx_dst);
 
 	if (dst)
 		dst = dst_check(dst, 0);
-	if (dst)
-		skb_dst_set_noref(skb, dst);
+	if (dst) {
+		/* DST_NOCACHE can not be used without taking a reference */
+		if (dst->flags & DST_NOCACHE) {
+			if (likely(atomic_inc_not_zero(&dst->__refcnt)))
+				skb_dst_set(skb, dst);
+		} else {
+			skb_dst_set_noref(skb, dst);
+		}
+	}
 }
 
 int udp_rcv(struct sk_buff *skb)
