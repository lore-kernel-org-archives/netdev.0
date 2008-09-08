From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 28/33] netns nat: fix ipt_MASQUERADE in netns
Date: Mon,  8 Sep 2008 07:03:05 +0400
Message-ID: <1220842990-30500-28-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.184]:64074 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbYIHDDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 23:03:16 -0400
Received: by gv-out-0910.google.com with SMTP id e6so91840gvc.37
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 20:03:15 -0700 (PDT)
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First, allow entry in notifier hook.
Second, start conntrack cleanup in netns to which netdevice belongs.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 5e1c817..65c811b 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -119,9 +119,7 @@ static int masq_device_event(struct notifier_block *this,
 			     void *ptr)
 {
 	const struct net_device *dev = ptr;
-
-	if (!net_eq(dev_net(dev), &init_net))
-		return NOTIFY_DONE;
+	struct net *net = dev_net(dev);
 
 	if (event == NETDEV_DOWN) {
 		/* Device was downed.  Search entire table for
@@ -129,7 +127,7 @@ static int masq_device_event(struct notifier_block *this,
 		   and forget them. */
 		NF_CT_ASSERT(dev->ifindex != 0);
 
-		nf_ct_iterate_cleanup(&init_net, device_cmp,
+		nf_ct_iterate_cleanup(net, device_cmp,
 				      (void *)(long)dev->ifindex);
 	}
 
