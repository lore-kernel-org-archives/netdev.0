From: Patrick Caulfield <patrick@tykepenguin.com>
Subject: [PATCH] DECnet Fix for DECnet routing bug
Date: Wed, 02 Aug 2006 15:19:24 +0100
Message-ID: <44D0B46C.2040500@tykepenguin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: steve@chygwyn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from spc1-leed3-0-0-cust958.seac.broadband.ntl.com ([82.8.19.191]:55286
	"EHLO fentible.pjc.net") by vger.kernel.org with ESMTP
	id S1750882AbWHBOTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 10:19:32 -0400
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a bug in the DECnet routing code where we were selecting
a loopback device in preference to an outward facing device even when
the destination was known non-local. This patch should fix the problem.

Signed-off-by: Patrick Caulfield <patrick@tykepenguin.com>
Signed-off-by: Steven Whitehouse <steve@chygwyn.com>

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 1355614..743e9fc 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -925,8 +925,13 @@ static int dn_route_output_slow(struct d
 		for(dev_out = dev_base; dev_out; dev_out = dev_out->next) {
 			if (!dev_out->dn_ptr)
 				continue;
-			if (dn_dev_islocal(dev_out, oldflp->fld_src))
-				break;
+			if (!dn_dev_islocal(dev_out, oldflp->fld_src))
+				continue;
+			if ((dev_out->flags & IFF_LOOPBACK) &&
+			    oldflp->fld_dst &&
+			    !dn_dev_islocal(dev_out, oldflp->fld_dst))
+				continue;
+			break;
 		}
 		read_unlock(&dev_base_lock);
 		if (dev_out == NULL)


