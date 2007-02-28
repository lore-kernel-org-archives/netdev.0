From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH] NetLabel: Verify sensitivity level has a valid CIPSO mapping
Date: Wed, 28 Feb 2007 15:01:31 -0500
Message-ID: <20070228200140.491071752@hp.com>
Cc: redhat-lspp@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:60245 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892AbXB1UD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 15:03:27 -0500
Content-Disposition: inline; filename=netlabel-cipso_std_bug
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current CIPSO engine has a problem where it does not verify that the given
sensitivity level has a valid CIPSO mapping when the "std" CIPSO DOI type is
used.  The end result is that bad packets are sent on the wire which should
have never been sent in the first place.  This patch corrects this problem by
verifying the sensitivity level mapping similar to what is done with the
category mapping.  This patch also changes the returned error code in this case
to -EPERM to better match what the category mapping verification code returns.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/ipv4/cipso_ipv4.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

Index: net-2.6_bugfix/net/ipv4/cipso_ipv4.c
===================================================================
--- net-2.6_bugfix.orig/net/ipv4/cipso_ipv4.c
+++ net-2.6_bugfix/net/ipv4/cipso_ipv4.c
@@ -732,11 +732,12 @@ static int cipso_v4_map_lvl_hton(const s
 		*net_lvl = host_lvl;
 		return 0;
 	case CIPSO_V4_MAP_STD:
-		if (host_lvl < doi_def->map.std->lvl.local_size) {
+		if (host_lvl < doi_def->map.std->lvl.local_size &&
+		    doi_def->map.std->lvl.local[host_lvl] < CIPSO_V4_INV_LVL) {
 			*net_lvl = doi_def->map.std->lvl.local[host_lvl];
 			return 0;
 		}
-		break;
+		return -EPERM;
 	}
 
 	return -EINVAL;
@@ -771,7 +772,7 @@ static int cipso_v4_map_lvl_ntoh(const s
 			*host_lvl = doi_def->map.std->lvl.cipso[net_lvl];
 			return 0;
 		}
-		break;
+		return -EPERM;
 	}
 
 	return -EINVAL;

--
paul moore
linux security @ hp

