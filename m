From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH] tun: Fix unicast filter overflow
Date: Sat, 07 Feb 2009 10:45:13 -0700
Message-ID: <20090207174404.16716.20574.stgit@kvm.aw>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alex.williamson@hp.com
To: maxk@qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:6866 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752948AbZBGRrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 12:47:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tap devices can make use of a small MAC filter set via the
TUNSETTXFILTER ioctl.  The filter has a set of exact matches
plus a hash for imperfect filtering of additional multicast
addresses.  The current code is unbalanced, adding unicast
addresses to the multicast hash, but only checking the hash
against multicast addresses.  This results in the filter
dropping unicast addresses that overflow the exact filter.
The fix is simply to disable the filter by leaving count set
to zero if we find non-multicast addresses after the exact
match table is filled.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

Proposed for 2.6.29 and stable.

 drivers/net/tun.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index d7b81e4..09fea31 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -157,10 +157,16 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
 
 	nexact = n;
 
-	/* The rest is hashed */
+	/* Remaining multicast addresses are hashed,
+	 * unicast will leave the filter disabled. */
 	memset(filter->mask, 0, sizeof(filter->mask));
-	for (; n < uf.count; n++)
+	for (; n < uf.count; n++) {
+		if (!is_multicast_ether_addr(addr[n].u)) {
+			err = 0; /* no filter */
+			goto done;
+		}
 		addr_hash_set(filter->mask, addr[n].u);
+	}
 
 	/* For ALLMULTI just set the mask to all ones.
 	 * This overrides the mask populated above. */

