From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: fix ASCONF to allow non SCTP_ADDR_SRC addresses in ipv6
Date: Tue, 22 Oct 2013 18:34:56 +0200
Message-ID: <1382459696-1732-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754137Ab3JVQfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 12:35:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8a07eb0a50 ("sctp: Add ASCONF operation on the single-homed host")
implemented possible use of IPv4 addresses with non SCTP_ADDR_SRC state
as source address when sending ASCONF (ADD) packets, but IPv6 part for
that was not implemented in 8a07eb0a50. Therefore, as this is not restricted
to IPv4-only, fix this up to allow the same for IPv6 addresses in SCTP.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Michio Honda <micchie@sfc.wide.ad.jp>
---
 net/sctp/ipv6.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index e7b2d4f..96a5591 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -279,7 +279,9 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		sctp_v6_to_addr(&dst_saddr, &fl6->saddr, htons(bp->port));
 		rcu_read_lock();
 		list_for_each_entry_rcu(laddr, &bp->address_list, list) {
-			if (!laddr->valid || (laddr->state != SCTP_ADDR_SRC))
+			if (!laddr->valid || laddr->state == SCTP_ADDR_DEL ||
+			    (laddr->state != SCTP_ADDR_SRC &&
+			     !asoc->src_out_of_asoc_ok))
 				continue;
 
 			/* Do not compare against v4 addrs */
-- 
1.8.3.1
