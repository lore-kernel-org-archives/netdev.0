From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 13/13] net: ipv6: address selection should only consider devices in L3 domain
Date: Wed,  4 May 2016 20:33:30 -0700
Message-ID: <1462419210-10463-14-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34609 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562AbcEEDeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:25 -0400
Received: by mail-pf0-f175.google.com with SMTP id y69so32269814pfb.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:25 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 version of 3f2fb9a834cb ("net: l3mdev: address selection should only
consider devices in L3 domain"). IPv4's follow up commit, a17b693cdd876
("net: l3mdev: prefer VRF master for source address selection"), is not
relevant. For IPv6 the VRF device should not be preferred over the dst_dev
as it leads to unnecessary forwarding versus a direct hop.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/addrconf.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b12553905e42..d13813867460 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1577,7 +1577,14 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 		if (idev)
 			hiscore_idx = __ipv6_dev_get_saddr(net, &dst, idev, scores, hiscore_idx);
 	} else {
+		int master_idx = l3mdev_master_ifindex_rcu(dst_dev);
+
 		for_each_netdev_rcu(net, dev) {
+			/* only consider addresses on devices in the
+			 * same L3 domain
+			 */
+			if (l3mdev_master_ifindex_rcu(dev) != master_idx)
+				continue;
 			idev = __in6_dev_get(dev);
 			if (!idev)
 				continue;
-- 
2.1.4
