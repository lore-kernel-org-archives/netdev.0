From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net] neigh: Force garbage collection if an entry is deleted
 administratively
Date: Tue, 12 Nov 2013 09:57:14 +0100
Message-ID: <20131112085714.GU31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48705 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab3KLI5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 03:57:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since git commit 2724680 ("neigh: Keep neighbour cache entries if number
of them is small enough."), we keep all neighbour cache entries if the
number is below a threshold. But if we now delete an entry administratively
and then try to replace this by a permanent one, we get -EEXIST because the
old entry ist still in the table (in NUD_FAILED state).

So lets force a garbage collect if we delete an entry administratively.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/neighbour.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 6072610..ec20880 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1659,6 +1659,8 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 				   NEIGH_UPDATE_F_OVERRIDE |
 				   NEIGH_UPDATE_F_ADMIN);
 		neigh_release(neigh);
+
+		neigh_forced_gc(tbl);
 		goto out;
 	}
 	read_unlock(&neigh_tbl_lock);
-- 
1.7.9.5
