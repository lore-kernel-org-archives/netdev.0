From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net] igmp: Avoid zero delay when receiving odd mixture of
 IGMP queries
Date: Mon, 9 Jan 2012 22:04:28 +0000
Message-ID: <20120109220428.GS20752@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Simon McVittie <smcv@debian.org>,
	654876@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60842 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932412Ab2AIWEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 17:04:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5b7c84066733c5dfb0e4016d939757b38de189e4 ('ipv4: correct IGMP
behavior on v3 query during v2-compatibility mode') added yet another
case for query parsing, which can result in max_delay = 0.  Substitute
a value of 1, as in the usual v3 case.

Reported-by: Simon McVittie <smcv@debian.org>
References: http://bugs.debian.org/654876
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/ipv4/igmp.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index d577199..e0d42db 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -875,6 +875,8 @@ static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 		 * to be intended in a v3 query.
 		 */
 		max_delay = IGMPV3_MRC(ih3->code)*(HZ/IGMP_TIMER_SCALE);
+		if (!max_delay)
+			max_delay = 1;	/* can't mod w/ 0 */
 	} else { /* v3 */
 		if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)))
 			return;
-- 
1.7.8.2
