From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6.25] [NETNS] Make arp code network namespace consistent.
Date: Mon, 14 Jan 2008 16:48:20 +0300
Message-ID: <1200318504-18215-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	den1/0006-ARP-Move-inet_addr_type-call-after-simple-error-ch.patch@sw.ru,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:57680 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751327AbYANNs2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 08:48:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some calls in the arp.c have network namespace as an argument. Getting
init_net inside these functions is simply inconsistent. Fix this.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/arp.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 49c24ff..0db7d49 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -969,13 +969,13 @@ static int arp_req_set_public(struct net *net, struct arpreq *r,
 	if (mask && mask != htonl(0xFFFFFFFF))
 		return -EINVAL;
 	if (!dev && (r->arp_flags & ATF_COM)) {
-		dev = dev_getbyhwaddr(&init_net, r->arp_ha.sa_family,
+		dev = dev_getbyhwaddr(net, r->arp_ha.sa_family,
 				r->arp_ha.sa_data);
 		if (!dev)
 			return -ENODEV;
 	}
 	if (mask) {
-		if (pneigh_lookup(&arp_tbl, &init_net, &ip, dev, 1) == NULL)
+		if (pneigh_lookup(&arp_tbl, net, &ip, dev, 1) == NULL)
 			return -ENOBUFS;
 		return 0;
 	}
@@ -1084,7 +1084,7 @@ static int arp_req_delete_public(struct net *net, struct arpreq *r,
 	__be32 mask = ((struct sockaddr_in *)&r->arp_netmask)->sin_addr.s_addr;
 
 	if (mask == htonl(0xFFFFFFFF))
-		return pneigh_delete(&arp_tbl, &init_net, &ip, dev);
+		return pneigh_delete(&arp_tbl, net, &ip, dev);
 
 	if (mask)
 		return -EINVAL;
@@ -1162,7 +1162,7 @@ int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	rtnl_lock();
 	if (r.arp_dev[0]) {
 		err = -ENODEV;
-		if ((dev = __dev_get_by_name(&init_net, r.arp_dev)) == NULL)
+		if ((dev = __dev_get_by_name(net, r.arp_dev)) == NULL)
 			goto out;
 
 		/* Mmmm... It is wrong... ARPHRD_NETROM==0 */
-- 
1.5.3.rc5

