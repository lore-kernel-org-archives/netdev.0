From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Fix mglist corruption that leads to memory corruption
Date: Sat, 12 Feb 2011 09:36:55 +1100
Message-ID: <20110211223655.GA5585@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ihands@redhat.com, jbacik@redhat.com
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:41265 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758264Ab1BKWg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 17:36:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This patch fixes a nasty memory corruption issue.

bridge: Fix mglist corruption that leads to memory corruption

The list mp->mglist is used to indicate whether a multicast group
is active on the bridge interface itself as opposed to one of the
constituent interfaces in the bridge.

Unfortunately the operation that adds the mp->mglist node to the
list neglected to check whether it has already been added.  This
leads to list corruption in the form of nodes pointing to itself.

Normally this would be quite obvious as it would cause an infinite
loop when walking the list.  However, as this list is never actually
walked (which means that we don't really need it, I'll get rid of
it in a subsequent patch), this instead is hidden until we perform
a delete operation on the affected nodes.

As the same node may now be pointed to by more than one node, the
delete operations can then cause modification of freed memory.

This was observed in practice to cause corruption in 512-byte slabs,
most commonly leading to crashes in jbd2.

Thanks to Josef Bacik for pointing me in the right direction.

Reported-by: Ian Page Hands <ihands@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index f701a21..802d3f8 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -719,7 +719,8 @@ static int br_multicast_add_group(struct net_bridge *br,
 		goto err;
 
 	if (!port) {
-		hlist_add_head(&mp->mglist, &br->mglist);
+		if (hlist_unhashed(&mp->mglist))
+			hlist_add_head(&mp->mglist, &br->mglist);
 		mod_timer(&mp->timer, now + br->multicast_membership_interval);
 		goto out;
 	}

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
