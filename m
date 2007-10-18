From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Fix again the fl6_sock_lookup() fixed locking
Date: Thu, 18 Oct 2007 16:36:58 +0400
Message-ID: <4717536A.2080400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55386 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756290AbXJRMhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 08:37:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI fairly pointed out, that the users increment should
be done under the ip6_sk_fl_lock not to give IPV6_FL_A_PUT a
chance to put this count to zero and release the flowlabel.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index e55ae1a..b12cc22 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -210,9 +210,9 @@ struct ip6_flowlabel * fl6_sock_lookup(struct sock *sk, __be32 label)
 	for (sfl=np->ipv6_fl_list; sfl; sfl = sfl->next) {
 		struct ip6_flowlabel *fl = sfl->fl;
 		if (fl->label == label) {
-			read_unlock_bh(&ip6_sk_fl_lock);
 			fl->lastuse = jiffies;
 			atomic_inc(&fl->users);
+			read_unlock_bh(&ip6_sk_fl_lock);
 			return fl;
 		}
 	}

