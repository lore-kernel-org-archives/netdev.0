From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: [PATCH] ipv6: Avoid unnecessary temporary addresses being generated
Date: Wed, 12 Mar 2014 20:53:48 +0100
Message-ID: <5320BB4C.9060400@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:53060 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbaCLTy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 15:54:57 -0400
Received: from [192.168.178.101] ([84.153.195.113]) by smtp.web.de (mrweb103)
 with ESMTPSA (Nemesis) id 0MVcZf-1Wf9wd1OD1-00Z3Hc for
 <netdev@vger.kernel.org>; Wed, 12 Mar 2014 20:54:56 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tmp_prefered_lft is an offset to ifp->tstamp, not now. Therefore
age needs to be added to the condition.

Age calculation in ipv6_create_tempaddr is different from the one
in addrconf_verify and doesn't consider ADDRCONF_TIMER_FUZZ_MINUS.
This can cause age in ipv6_create_tempaddr to be less than the one
in addrconf_verify and therefore unnecessary temporary address to
be generated.
Use age calculation as in addrconf_modify to avoid this.

Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>
---
 net/ipv6/addrconf.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fdbfeca..bd64dbe 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1103,8 +1103,11 @@ retry:
 	 * Lifetime is greater than REGEN_ADVANCE time units.  In particular,
 	 * an implementation must not create a temporary address with a zero
 	 * Preferred Lifetime.
+	 * Use age calculation as in addrconf_verify to avoid unnecessary
+	 * temporary addresses being generated.
 	 */
-	if (tmp_prefered_lft <= regen_advance) {
+	age = (now - ifp->tstamp + ADDRCONF_TIMER_FUZZ_MINUS) / HZ;
+	if (tmp_prefered_lft <= regen_advance + age) {
 		in6_ifa_put(ifp);
 		in6_dev_put(idev);
 		ret = -1;
-- 
1.7.10.4
