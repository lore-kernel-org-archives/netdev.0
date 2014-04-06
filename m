From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] decnet: fix possible NULL deref in dnet_select_source()
Date: Sun, 06 Apr 2014 14:59:14 -0700
Message-ID: <1396821554.12330.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5341A3C1.9060101@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-decnet-user@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:48459 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbaDFV7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2014 17:59:16 -0400
In-Reply-To: <5341A3C1.9060101@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

dnet_select_source() should make sure dn_ptr is not NULL.

While looking at this decnet code, I believe I found a device
reference leak, lets fix it as well.
 
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
It seems this bug is very old, no recent change is involved.

 net/decnet/dn_route.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index ce0cbbfe0f43..4d1608dfb0bd 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -923,6 +923,8 @@ static __le16 dnet_select_source(const struct net_device *dev, __le16 daddr, int
 
 	rcu_read_lock();
 	dn_db = rcu_dereference(dev->dn_ptr);
+	if (!dn_db)
+		goto out;
 	for (ifa = rcu_dereference(dn_db->ifa_list);
 	     ifa != NULL;
 	     ifa = rcu_dereference(ifa->ifa_next)) {
@@ -938,6 +940,7 @@ static __le16 dnet_select_source(const struct net_device *dev, __le16 daddr, int
 		if (best_match == 0)
 			saddr = ifa->ifa_local;
 	}
+out:
 	rcu_read_unlock();
 
 	return saddr;
@@ -1034,7 +1037,6 @@ source_ok:
 		if (dev_out)
 			dev_put(dev_out);
 		dev_out = init_net.loopback_dev;
-		dev_hold(dev_out);
 		if (!fld.daddr) {
 			fld.daddr =
 			fld.saddr = dnet_select_source(dev_out, 0,
@@ -1042,6 +1044,7 @@ source_ok:
 			if (!fld.daddr)
 				goto out;
 		}
+		dev_hold(dev_out);
 		fld.flowidn_oif = LOOPBACK_IFINDEX;
 		res.type = RTN_LOCAL;
 		goto make_route;
