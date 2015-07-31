From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Panic with demuxed ipv4 multicast udp sockets on 4.0.4
Date: Fri, 31 Jul 2015 12:17:46 +0200
Message-ID: <1438337866.2748.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <2ddbe291fff643899849eb068ef219e0@svr-chch-ex1.atlnz.lc>
	 <1438234969.20182.124.camel@edumazet-glaptop2.roam.corp.google.com>
	 ,<1438235159.20182.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0dd213ace919410da723ac93892d1f4d@svr-chch-ex1.atlnz.lc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"alexgartrell@gmail.com" <alexgartrell@gmail.com>
To: Gregory Hoggarth <Gregory.Hoggarth@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35153 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbbGaKRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 06:17:50 -0400
Received: by wibxm9 with SMTP id xm9so27074382wib.0
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 03:17:49 -0700 (PDT)
In-Reply-To: <0dd213ace919410da723ac93892d1f4d@svr-chch-ex1.atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-30 at 22:29 +0000, Gregory Hoggarth wrote:
> Hi Eric,
> 
> Thanks for the patch. I have put this into our code and we'll run our test over tonight and the weekend and report back on Monday.
> 
> Thanks,

Oh well, real fix will be :

(Or at least test if DST_NOCACHE is set : those dst need special care)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 83aa604f9273..470196cb50b8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1995,12 +1995,12 @@ void udp_v4_early_demux(struct sk_buff *skb)
 
 	skb->sk = sk;
 	skb->destructor = sock_efree;
-	dst = sk->sk_rx_dst;
+	dst = READ_ONCE(sk->sk_rx_dst);
 
 	if (dst)
 		dst = dst_check(dst, 0);
-	if (dst)
-		skb_dst_set_noref(skb, dst);
+	if (dst && atomic_inc_not_zero(&dst->__refcnt))
+		skb_dst_set(skb, dst);
 }
 
 int udp_rcv(struct sk_buff *skb)
