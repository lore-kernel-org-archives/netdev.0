From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next 3/5] ipv6: Use multipath hash from flow info if available
Date: Mon, 24 Oct 2016 11:28:50 +0200
Message-ID: <1477301332-23954-4-git-send-email-jkbs@redhat.com>
References: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36425 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757214AbcJXJ27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 05:28:59 -0400
Received: by mail-wm0-f42.google.com with SMTP id b80so92915287wme.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2016 02:28:58 -0700 (PDT)
In-Reply-To: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow our callers to influence the choice of ECMP link by honoring the
hash passed together with the flow info. This will allow for special
treatment of ICMP errors which we would like to route over the same link
as the IP datagram that triggered the error.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 net/ipv6/route.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0514b35..1184c2b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -430,9 +430,11 @@ static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
 					     int strict)
 {
 	struct rt6_info *sibling, *next_sibling;
+	unsigned int hash;
 	int route_choosen;
 
-	route_choosen = get_hash_from_flowi6(fl6) % (match->rt6i_nsiblings + 1);
+	hash = fl6->mp_hash ? : get_hash_from_flowi6(fl6);
+	route_choosen = hash % (match->rt6i_nsiblings + 1);
 	/* Don't change the route, if route_choosen == 0
 	 * (siblings does not include ourself)
 	 */
-- 
2.7.4
