From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: Fix nexthop lookups
Date: Wed, 19 Aug 2015 11:40:31 -0700
Message-ID: <1440009631-8082-1-git-send-email-dsa@cumulusnetworks.com>
References: <1029376325.2912846.1439917035503.JavaMail.zimbra@tpip.net>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33093 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbHSSkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:40:43 -0400
Received: by pdrh1 with SMTP id h1so4498712pdr.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 11:40:43 -0700 (PDT)
In-Reply-To: <1029376325.2912846.1439917035503.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas reported breakage adding routes with local nexthops:
$ ip route show table main
...
172.28.0.0/24 dev vnf-xe1p0  proto kernel  scope link  src 172.28.0.16

$ ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0
RTNETLINK answers: Resource temporarily unavailable

3bfd847203c changed the lookup to use the passed in table but for cases like
this the nexthop is in the local table rather than the passed in table.

Fixes: 3bfd847203c ("net: Use passed in table for nexthop lookups")
Reported-by: Andreas Schultz <aschultz@tpip.net>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_semantics.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c8025851dac7..0ab5bf558805 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -710,9 +710,16 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 				err = fib_table_lookup(tbl, &fl4, &res,
 						       FIB_LOOKUP_IGNORE_LINKSTATE |
 						       FIB_LOOKUP_NOREF);
-			else
+
+			/* on error or if no table given do full lookup. This
+			 * is needed for example when nexthops are in the local
+			 * table rather than the given table
+			 */
+			if (!tbl || err) {
 				err = fib_lookup(net, &fl4, &res,
 						 FIB_LOOKUP_IGNORE_LINKSTATE);
+			}
+
 			if (err) {
 				rcu_read_unlock();
 				return err;
-- 
2.3.2 (Apple Git-55)
