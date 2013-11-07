From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next v2 3/3] ipv6: protect flow label renew against GC
Date: Thu,  7 Nov 2013 17:53:14 +0100
Message-ID: <1383843194-22945-3-git-send-email-florent.fourcot@enst-bretagne.fr>
References: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:34531 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753492Ab3KGQxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 11:53:19 -0500
In-Reply-To: <1383843194-22945-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take ip6_fl_lock before to read and update
a label.

v2: protect only the relevant code

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/ip6_flowlabel.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 5f10b0d..98fdcc6 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -345,6 +345,8 @@ static int fl6_renew(struct ip6_flowlabel *fl, unsigned long linger, unsigned lo
 	expires = check_linger(expires);
 	if (!expires)
 		return -EPERM;
+
+	spin_lock_bh(&ip6_fl_lock);
 	fl->lastuse = jiffies;
 	if (time_before(fl->linger, linger))
 		fl->linger = linger;
@@ -352,6 +354,8 @@ static int fl6_renew(struct ip6_flowlabel *fl, unsigned long linger, unsigned lo
 		expires = fl->linger;
 	if (time_before(fl->expires, fl->lastuse + expires))
 		fl->expires = fl->lastuse + expires;
+	spin_unlock_bh(&ip6_fl_lock);
+
 	return 0;
 }
 
-- 
1.8.4.rc3
