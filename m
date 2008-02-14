From: Chuck Ebbert <cebbert@redhat.com>
Subject: [patch] Fix station address detection in smc
Date: Wed, 13 Feb 2008 19:47:11 -0500
Message-ID: <47B38F8F.6060408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia@lists.infradead.org, Netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39873 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756004AbYBNAro (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 19:47:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Megahertz EM1144 PCMCIA ethernet adapter needs special handling
because it has two VERS_1 tuples and the station address is in
the second one. Conversion to generic handling of these fields
broke it. Reverting that fixes the device.

  https://bugzilla.redhat.com/show_bug.cgi?id=233255

Thanks go to Jon Stanley for not giving up on this one until the
problem was found.

Signed-off-by: Chuck Ebbert <cebbert@redhat.com>

---

This was broken for over a year before the problem was found...

--- b/drivers/net/pcmcia/smc91c92_cs.c	Tue Dec 05 06:09:21 2006 +0500
+++ a/drivers/net/pcmcia/smc91c92_cs.c	Tue Dec 05 06:09:20 2006 +0500
@@ -560,8 +560,16 @@

     /* Read the station address from the CIS.  It is stored as the last
        (fourth) string in the Version 1 Version/ID tuple. */
+    tuple->DesiredTuple = CISTPL_VERS_1;
+    if (first_tuple(link, tuple, parse) != CS_SUCCESS) {
+	rc = -1;
+	goto free_cfg_mem;
+    }
+    /* Ugh -- the EM1144 card has two VERS_1 tuples!?! */
+    if (next_tuple(link, tuple, parse) != CS_SUCCESS)
+	first_tuple(link, tuple, parse);
+    if (parse->version_1.ns > 3) {
+	station_addr = parse->version_1.str + parse->version_1.ofs[3];
-    if (link->prod_id[3]) {
-	station_addr = link->prod_id[3];
 	if (cvt_ascii_address(dev, station_addr) == 0) {
 		rc = 0;
 		goto free_cfg_mem;
