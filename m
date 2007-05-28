From: "rae l" <crquan@gmail.com>
Subject: [PATCH] merge dst_discard in & out into one, this decrements the vmlinux image by 21 bytes under i386 arch.
Date: Mon, 28 May 2007 18:35:12 +0800
Message-ID: <91b13c310705280335k1f7d442cjdc874a3198c8acfc@mail.gmail.com>
References: <91b13c310705271941n48e266b9vc202b862ad4fabba@mail.gmail.com>
	 <Pine.LNX.4.61.0705281150010.11140@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Networking Team" <netdev@vger.kernel.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	"Adrian Bunk" <trivial@kernel.org>
To: "Jan Engelhardt" <jengelh@linux01.gwdg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:35015 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbXE1KfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 06:35:14 -0400
Received: by ug-out-1314.google.com with SMTP id j3so1597710ugf
        for <netdev@vger.kernel.org>; Mon, 28 May 2007 03:35:12 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.61.0705281150010.11140@yvahk01.tjqt.qr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/28/07, Jan Engelhardt <jengelh@linux01.gwdg.de> wrote:
> Uhm, just replace every invocation of dst_discard_in/_out() directly
> by dst_discard ... don't add macros for that.
so that, the trival patch changed to this:

because the definition of dst_discard_in and dst_discard_out are the
same, so they merged into one.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---

diff --git a/net/core/dst.c b/net/core/dst.c
index 764bccb..c6a0587 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -111,13 +111,7 @@ out:
        spin_unlock(&dst_lock);
 }

-static int dst_discard_in(struct sk_buff *skb)
-{
-       kfree_skb(skb);
-       return 0;
-}
-
-static int dst_discard_out(struct sk_buff *skb)
+static int dst_discard(struct sk_buff *skb)
 {
        kfree_skb(skb);
        return 0;
@@ -138,8 +132,7 @@ void * dst_alloc(struct dst_ops * ops)
        dst->ops = ops;
        dst->lastuse = jiffies;
        dst->path = dst;
-       dst->input = dst_discard_in;
-       dst->output = dst_discard_out;
+       dst->input = dst->output = dst_discard;
 #if RT_CACHE_DEBUG >= 2
        atomic_inc(&dst_total);
 #endif
@@ -153,8 +146,7 @@ static void ___dst_free(struct dst_entry * dst)
           protocol module is unloaded.
         */
        if (dst->dev == NULL || !(dst->dev->flags&IFF_UP)) {
-               dst->input = dst_discard_in;
-               dst->output = dst_discard_out;
+               dst->input = dst->output = dst_discard;
        }
        dst->obsolete = 2;
 }
@@ -242,8 +234,7 @@ static inline void dst_ifdown(struct dst_entry
*dst, struct net_device *dev,
                return;

        if (!unregister) {
-               dst->input = dst_discard_in;
-               dst->output = dst_discard_out;
+               dst->input = dst->output = dst_discard;
        } else {
                dst->dev = &loopback_dev;
                dev_hold(&loopback_dev);


-- 
Denis Cheng
Linux Application Developer
