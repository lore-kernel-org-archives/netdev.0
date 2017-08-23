From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next v3 4/4] ipv6: Use multipath hash from flow info if available
Date: Wed, 23 Aug 2017 09:58:31 +0200
Message-ID: <20170823075831.27031-5-jkbs@redhat.com>
References: <20170823075831.27031-1-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33535 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753541AbdHWH6m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 03:58:42 -0400
Received: by mail-wm0-f48.google.com with SMTP id b189so4662718wmd.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 00:58:41 -0700 (PDT)
In-Reply-To: <20170823075831.27031-1-jkbs@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow our callers to influence the choice of ECMP link by honoring the
hash passed together with the flow info. This allows for special
treatment of ICMP errors which we would like to route over the same path
as the IPv6 datagram that triggered the error.

Also go through rt6_multipath_hash(), in the usual case when we aren't
dealing with an ICMP error, so that there is one central place where
multipath hash is computed.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 net/ipv6/route.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 246e7d7..4d02734 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -452,7 +452,13 @@ static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
 	struct rt6_info *sibling, *next_sibling;
 	int route_choosen;
 
-	route_choosen = get_hash_from_flowi6(fl6) % (match->rt6i_nsiblings + 1);
+	/* We might have already computed the hash for ICMPv6 errors. In such
+	 * case it will always be non-zero. Otherwise now is the time to do it.
+	 */
+	if (!fl6->mp_hash)
+		fl6->mp_hash = rt6_multipath_hash(fl6, NULL);
+
+	route_choosen = fl6->mp_hash % (match->rt6i_nsiblings + 1);
 	/* Don't change the route, if route_choosen == 0
 	 * (siblings does not include ourself)
 	 */
-- 
2.9.4
