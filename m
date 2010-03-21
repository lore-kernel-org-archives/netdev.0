From: James Morris <jmorris@namei.org>
Subject: [PATCH] Netfilter: Fix integer overflow in net/ipv6/netfilter/ip6_tables.c
 (fwd)
Date: Mon, 22 Mar 2010 08:50:24 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1003220850180.3232@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:34220 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753168Ab0CUVuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Mar 2010 17:50:24 -0400
Received: from localhost (localhost [127.0.0.1])
	by tundra.namei.org (8.13.1/8.13.1) with ESMTP id o2LLoOw9003428
	for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 17:50:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---------- Forwarded message ----------
Date: Sat, 20 Mar 2010 22:32:40 +0800
From: wzt.wzt@gmail.com
To: linux-kernel@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net
Subject: [PATCH] Netfilter: Fix integer overflow in
    net/ipv6/netfilter/ip6_tables.c

The get.size field in the get_entries() interface is not bounded
correctly. The size is used to determine the total entry size.
The size is bounded, but can overflow and so the size checks may
not be sufficient to catch invalid size. Fix it by catching size
values that would cause overflows before calculating the size.

Signed-off-by: Zhitong Wang <zhitong.wangzt@alibaba-inc.com>

---
 net/ipv4/netfilter/ip_tables.c  |    4 ++++
 net/ipv6/netfilter/ip6_tables.c |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 4e7c719..6abd3d2 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1164,6 +1164,10 @@ get_entries(struct net *net, struct ipt_get_entries __user *uptr, int *len)
 	}
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
+
+	if (get.size >= INT_MAX / sizeof(struct ipt_get_entries))
+		return -EINVAL;
+
 	if (*len != sizeof(struct ipt_get_entries) + get.size) {
 		duprintf("get_entries: %u != %zu\n",
 			 *len, sizeof(get) + get.size);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 0b4557e..5185822 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1190,6 +1190,10 @@ get_entries(struct net *net, struct ip6t_get_entries __user *uptr, int *len)
 	}
 	if (copy_from_user(&get, uptr, sizeof(get)) != 0)
 		return -EFAULT;
+
+	if (get.size >= INT_MAX / sizeof(struct ip6t_get_entries))
+		return -EINVAL;
+
 	if (*len != sizeof(struct ip6t_get_entries) + get.size) {
 		duprintf("get_entries: %u != %zu\n",
 			 *len, sizeof(get) + get.size);
-- 
1.6.5.3

--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
