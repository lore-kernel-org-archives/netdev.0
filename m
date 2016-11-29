From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: GPF in eth_header
Date: Tue, 29 Nov 2016 06:58:21 -0800
Message-ID: <1480431501.18162.131.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+at4Fp6i7WRggYq7M1+z1aHo=Bff63p+1DzC2SnTjuWdA@mail.gmail.com>
         <CANn89iJeWV9YnOzy4eXL4Sbcyw_kj_CA8JrfGaFxMse_MUFL6Q@mail.gmail.com>
         <CAAeHK+x48aKLcKfN2aYA1pBPr4Y4ESUvjCTu0xGPoYZuiRbaaw@mail.gmail.com>
         <CACPEyM-4dwvmEvq3uTN_8Y-YosP8qA3cYV+oxkufFOn8M+=hew@mail.gmail.com>
         <CAAeHK+xr+GdLbLch7XatW5rifOz+=cjRCGf1ro8WxEZWziyU4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: syzkaller <syzkaller@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34588 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933392AbcK2O63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:58:29 -0500
In-Reply-To: <CAAeHK+xr+GdLbLch7XatW5rifOz+=cjRCGf1ro8WxEZWziyU4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-29 at 11:26 +0100, Andrey Konovalov wrote:
> On Sat, Nov 26, 2016 at 9:05 PM, Eric Dumazet <erdlkml@gmail.com> wrote:
> >> I actually see multiple places where skb_network_offset() is used as
> >> an argument to skb_pull().
> >> So I guess every place can potentially be buggy.
> >
> > Well, I think the intent is to accept a negative number.
> 
> I'm not sure that was the intent since it results in a signedness
> issue which leads to an out-of-bounds.
> 

Hey, I already mentioned where was the bug.

You missed the investigation where I pointed it to FLorian ?

> A quick grep shows that the same issue can potentially happen in
> multiple places across the kernel:
> 
> net/ipv6/ip6_output.c:1655: __skb_pull(skb, skb_network_offset(skb));
> net/packet/af_packet.c:2043: skb_pull(skb, skb_network_offset(skb));
> net/packet/af_packet.c:2165: skb_pull(skb, skb_network_offset(skb));
> net/core/neighbour.c:1301: __skb_pull(skb, skb_network_offset(skb));
> net/core/neighbour.c:1331: __skb_pull(skb, skb_network_offset(skb));
> net/core/dev.c:3157: __skb_pull(skb, skb_network_offset(skb));
> net/sched/sch_teql.c:337: __skb_pull(skb, skb_network_offset(skb));
> net/sched/sch_atm.c:479: skb_pull(skb, skb_network_offset(skb));
> net/ipv4/ip_output.c:1385: __skb_pull(skb, skb_network_offset(skb));
> net/ipv4/ip_fragment.c:391: if (!pskb_pull(skb, skb_network_offset(skb) + ihl))
> drivers/net/vxlan.c:1440: __skb_pull(reply, skb_network_offset(reply));
> drivers/net/vxlan.c:1902: __skb_pull(skb, skb_network_offset(skb));
> drivers/net/vrf.c:220: __skb_pull(skb, skb_network_offset(skb));
> drivers/net/vrf.c:314: __skb_pull(skb, skb_network_offset(skb));
> 
> A similar thing also happened to somebody else (on a receive path!):
> https://forums.grsecurity.net/viewtopic.php?f=3&t=4550
> 
> Does it make sense to check skb_network_offset() before passing it to
> skb_pull() everywhere?

Well, sure, we could add safety checks everywhere and slow the kernel
when debugging is requested.

But skb_network_offset() is not the problem here. Why are you focusing
on it ?

The real problem is in __skb_pull() or __skb_push() and all similar
helpers. Lots of added checks and slowdowns.

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c535fbccf2c7dbfae04cee393460e86d588c26b..d6116e37d054fc1536114347ed3c41fc7dc7a882 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1923,6 +1923,7 @@ static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 unsigned char *skb_push(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
 {
+	BUG_ON((int)len < 0);
 	skb->data -= len;
 	skb->len  += len;
 	return skb->data;
@@ -1931,6 +1932,7 @@ static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
 unsigned char *skb_pull(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_pull(struct sk_buff *skb, unsigned int len)
 {
+	BUG_ON((int)len < 0);
 	skb->len -= len;
 	BUG_ON(skb->len < skb->data_len);
 	return skb->data += len;
@@ -1938,6 +1940,7 @@ static inline unsigned char *__skb_pull(struct sk_buff *skb, unsigned int len)
 
 static inline unsigned char *skb_pull_inline(struct sk_buff *skb, unsigned int len)
 {
+	BUG_ON((int)len < 0);
 	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d1d1a5a5ad24ded523fc12ffba8c602b03bd0830..7bf098c848fd857ba5d287fc91d43f62f381bd55 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1450,6 +1450,7 @@ EXPORT_SYMBOL(skb_put);
  */
 unsigned char *skb_push(struct sk_buff *skb, unsigned int len)
 {
+	BUG_ON((int)len < 0);
 	skb->data -= len;
 	skb->len  += len;
 	if (unlikely(skb->data<skb->head))
