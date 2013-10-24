From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 1/2] ipv6: reset dst.expires value when clearing expire flag
Date: Thu, 24 Oct 2013 07:48:16 +0200
Message-ID: <20131024054816.GB5973@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: sgunderson@bigfoot.com, valentyn@blub.net, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54074 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427Ab3JXFsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 01:48:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On receiving a packet too big icmp error we update the expire value by
calling rt6_update_expires. This function uses dst_set_expires which is
implemented that it can only reduce the expiration value of the dst entry.

If we insert new routing non-expiry information into the ipv6 fib where
we already have a matching rt6_info we only clear the RTF_EXPIRES flag
in rt6i_flags and leave the dst.expires value as is.

When new mtu information arrives for that cached dst_entry we again
call dst_set_expires. This time it won't update the dst.expire value
because we left the dst.expire value intact from the last update. So
dst_set_expires won't touch dst.expires.

Fix this by resetting dst.expires when clearing the RTF_EXPIRE flag.
dst_set_expires checks for a zero expiration and updates the
dst.expires.

In the past this (not updating dst.expires) was necessary because
dst.expire was placed in a union with the dst_entry *from reference. So
an update on the value would have caused page faults. This split happend
in ecd9883724b78cc72ed92c98bcb1a46c764fff21 ("ipv6: fix race condition
regarding dst->expires and dst->from").

Reported-by: Steinar H. Gunderson <sgunderson@bigfoot.com>
Reported-by: Valentijn Sessink <valentyn@blub.net>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
I would propose this patch for -stable.

 include/net/ip6_fib.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 48ec25a..5e661a9 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -165,6 +165,7 @@ static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 static inline void rt6_clean_expires(struct rt6_info *rt)
 {
 	rt->rt6i_flags &= ~RTF_EXPIRES;
+	rt->dst.expires = 0;
 }
 
 static inline void rt6_set_expires(struct rt6_info *rt, unsigned long expires)
-- 
1.8.3.1
