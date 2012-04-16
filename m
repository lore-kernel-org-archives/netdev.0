From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] ipv6: fix rt6_update_expires
Date: Mon, 16 Apr 2012 15:34:39 +0200
Message-ID: <20120416133439.GB18159@midget.suse.cz>
References: <1330064404-24763-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1333707190-14075-1-git-send-email-gaofeng@cn.fujitsu.com>
 <20120413.125851.894792528374368454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54672 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343Ab2DPNen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 09:34:43 -0400
Content-Disposition: inline
In-Reply-To: <20120413.125851.894792528374368454.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit 1716a961 (ipv6: fix problem with expired dst cache) broke PMTU
discovery. rt6_update_expires() calls dst_set_expires(), which only updates
dst->expires if it has not been set previously (expires == 0) or if the new
expires is earlier than the current dst->expires.

rt6_update_expires() needs to zero rt->dst.expires, otherwise it will contain
ivalid data left over from rt->dst.from and will confuse dst_set_expires().

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index ad4126f..68c1f94 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -143,8 +143,13 @@ static inline void rt6_set_expires(struct rt6_info *rt, unsigned long expires)
 
 static inline void rt6_update_expires(struct rt6_info *rt, int timeout)
 {
-	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
-		dst_release(rt->dst.from);
+	if (!(rt->rt6i_flags & RTF_EXPIRES)) {
+		if (rt->dst.from)
+			dst_release(rt->dst.from);
+		/* dst_set_expires relies on expires == 0 
+                  if it has not been set previously */
+		rt->dst.expires = 0;
+	}
 
 	dst_set_expires(&rt->dst, timeout);
 	rt->rt6i_flags |= RTF_EXPIRES;

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
