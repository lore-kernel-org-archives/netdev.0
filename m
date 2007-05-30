From: Rankle_ <crquan@gmail.com>
Subject: [PATCH] merge dst_discard in & out into one, removed a duplicate
 function
Date: Wed, 30 May 2007 16:39:40 +0800
Message-ID: <465D384C.4060006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:41743 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbXE3Ij6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 04:39:58 -0400
Received: by py-out-1112.google.com with SMTP id a29so1323548pyi
        for <netdev@vger.kernel.org>; Wed, 30 May 2007 01:39:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/28/07, Jan Engelhardt <jengelh@linux01.gwdg.de 
<mailto:jengelh@linux01.gwdg.de>> wrote:
 > Uhm, just replace every invocation of dst_discard_in/_out() directly
 > by dst_discard ... don't add macros for that.

merge dst_discard in & out into one, this removed a duplicate function.

Signed-off-by: Denis Cheng <crquan@gmail.com <mailto:crquan@gmail.com>>

---

Is there anybody also found this duplicate? I found this duplcate had
existed from linux-2.2 linux-2.4 to the latest kernel tree, you could
check it in the lxr site conveniently:
http://lxr.linux.no/source/net/core/dst.c?v=2.2.26 
<http://lxr.linux.no/source/net/core/dst.c?v=2.2.26>
http://lxr.linux.no/source/net/core/dst.c?v=2.4.18 
<http://lxr.linux.no/source/net/core/dst.c?v=2.4.18>
http://lxr.linux.no/source/net/core/dst.c 
<http://lxr.linux.no/source/net/core/dst.c>
With little difference, the 2.2 and 2.4 version use two different
function name: dst_discard and dst_blackhole, but the definition of
them are the same, so they are  same substantially. Additionally, the
two same function are two local(static) functions in a single file
dst.c, I don't know why there should exist two same functions. I
wonder what the consideration of this design is, because I'm just a
kernel newbie; this problem has been confusing me for many days, so if
you know why, please drop me some directions.

--- net/core/dst.c      2007-05-30 16:33:45.000000000 +0800
+++ net/core/dst.c.new  2007-05-28 18:22:36.000000000 +0800
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
@@ -153,8 +146,7 @@ static void ___dst_free(struct dst_entry
           protocol module is unloaded.
         */
        if (dst->dev == NULL || !(dst->dev->flags&IFF_UP)) {
-               dst->input = dst_discard_in;
-               dst->output = dst_discard_out;
+               dst->input = dst->output = dst_discard;
        }
        dst->obsolete = 2;
 }
@@ -242,8 +234,7 @@ static inline void dst_ifdown(struct dst
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

