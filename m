From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc: ematch: Ignore all-zero mask value when printing filters
Date: Thu, 14 Jul 2016 23:10:53 +0200
Message-ID: <1468530653-19773-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45537 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699AbcGNVLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 17:11:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The optional mask which may be added to int values is considered by the
kernel only if it is non-zero, therefore tc should only then also print
it.

Without this, not passing a mask value like so:

| # tc filter add dev d0 parent 8001: \
| 	basic match meta\(vlan eq 1\) \
| 	classid 8001:1

Would lead to tc printing an all-zero mask later:

| # tc filter show dev d0
| filter parent 8001: protocol all pref 49151 basic
| filter parent 8001: protocol all pref 49151 basic handle 0x1 flowid 8001:1
|   meta(vlan mask 0x00000000 eq 1)

This is obviously confusing as an all-zero mask strictly means to
eliminate all bits from the value, but the opposite is the case.

Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/em_meta.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tc/em_meta.c b/tc/em_meta.c
index 9ce5a78a628ac..ce98386082b86 100644
--- a/tc/em_meta.c
+++ b/tc/em_meta.c
@@ -485,8 +485,9 @@ static int print_object(FILE *fd, struct tcf_meta_val *obj, struct rtattr *rta)
 				if (RTA_PAYLOAD(rta) < sizeof(__u32))
 					goto size_mismatch;
 
-				fprintf(fd, " mask 0x%08x",
-				    rta_getattr_u32(rta));
+				if (rta_getattr_u32(rta))
+					fprintf(fd, " mask 0x%08x",
+						rta_getattr_u32(rta));
 			}
 			break;
 	}
-- 
2.8.2
