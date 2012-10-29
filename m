From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: fix a potential NULL deref
Date: Mon, 29 Oct 2012 11:50:20 +0800
Message-ID: <1351482620-11008-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753814Ab2J2Dua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Oct 2012 23:50:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipv6_del_addr():

                if (rt != net->ipv6.ip6_null_entry &&
                    addrconf_is_prefix_route(rt)) {
                        if (onlink == 0) {
                                ip6_del_rt(rt);
                                rt = NULL;
                        } else if (!(rt->rt6i_flags & RTF_EXPIRES)) {
                                rt6_set_expires(rt, expires);
                        }
                }
                dst_release(&rt->dst);

obviously rt could be NULL'd before dst_release(), so
we have to check if rt is NULL before calling it.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f0b12a..c467dbb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -951,7 +951,8 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 				rt6_set_expires(rt, expires);
 			}
 		}
-		dst_release(&rt->dst);
+		if (rt)
+			dst_release(&rt->dst);
 	}
 
 	/* clean up prefsrc entries */
