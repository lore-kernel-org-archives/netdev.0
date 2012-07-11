From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] bridge: Fix enforcement of multicast hash_max limit
Date: Wed, 11 Jul 2012 10:29:19 +0200
Message-ID: <417e2d4ff99d88014f288e9924c5a45d4650f474.1341995313.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754223Ab2GKI3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 04:29:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hash size is doubled when it needs to grow and compared against
hash_max. The >= comparison will limit the hash table size to half
of what is expected i.e. the default 512 hash_max will not allow
the hash table to grow larger than 256.

Also print the hash table limit instead of the desirable size when
the limit is reached.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/bridge/br_multicast.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index b665812..8213618 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -540,10 +540,11 @@ static struct net_bridge_mdb_entry *br_multicast_get_group(
 
 	if (mdb->size >= max) {
 		max *= 2;
-		if (unlikely(max >= br->hash_max)) {
-			br_warn(br, "Multicast hash table maximum "
-				"reached, disabling snooping: %s, %d\n",
-				port ? port->dev->name : br->dev->name, max);
+		if (unlikely(max > br->hash_max)) {
+			br_warn(br, "Multicast hash table maximum of %d "
+				"reached, disabling snooping: %s\n",
+				br->hash_max,
+				port ? port->dev->name : br->dev->name);
 			err = -E2BIG;
 disable:
 			br->multicast_disabled = 1;
-- 
1.7.7.6
