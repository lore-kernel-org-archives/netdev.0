From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: Bug 71591 - Temporary address re-generated when it should not (public
 address about to expire)
Date: Thu, 06 Mar 2014 17:29:12 +0100
Message-ID: <5318A258.1010100@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:60685 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751015AbaCFQ3R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 11:29:17 -0500
Received: from [192.168.178.101] ([84.153.198.61]) by smtp.web.de (mrweb001)
 with ESMTPSA (Nemesis) id 0Mdueb-1WY4XZ1xIT-00PhXV for
 <netdev@vger.kernel.org>; Thu, 06 Mar 2014 17:29:16 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I faced the issue that a public address was about to expire and 
3s before expiry a new temporary address was generated which instantly 
went into deprecated state.
This didn't do any harm however it's wrong IMHO. Problem seems to be in 
function ipv6_create_tempaddr in addrconf.c.
A new temporary address is generated if this condition is met: 
tmp_prefered_lft > regen_advance
tmp_prefered_lft however is an offset from tstamp, not from now.
This condition only checks that the new address is preferred until more 
than regen_advance from tstamp,
but it should check that the new address is preferred until more than 
regen_advance from now.

I submitted this issue to kernel bugzilla -> 71591
Hannes asked me to propose a patch, here it comes.

Rgds, Heiner

diff -uNr linux-3.10.32.vanilla/net/ipv6/addrconf.c 
linux-3.10.32.patched/net/ipv6/addrconf.c
--- linux-3.10.32.vanilla/net/ipv6/addrconf.c    2014-02-22 
14:41:54.000000000 -0600
+++ linux-3.10.32.patched/net/ipv6/addrconf.c    2014-03-06 
17:07:12.953699438 -0600
@@ -1111,8 +1111,9 @@
       * Lifetime is greater than REGEN_ADVANCE time units.  In particular,
       * an implementation must not create a temporary address with a zero
       * Preferred Lifetime.
+     * Note that tmp_prefered_lft is relative to ifp->tstamp not now.
       */
-    if (tmp_prefered_lft <= regen_advance) {
+    if (tmp_prefered_lft <= regen_advance + age) {
          in6_ifa_put(ifp);
          in6_dev_put(idev);
          ret = -1;
