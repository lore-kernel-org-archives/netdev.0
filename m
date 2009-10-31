From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next-2.6] veth: Fix unregister_netdevice_queue for veth
Date: Fri, 30 Oct 2009 17:51:13 -0700
Message-ID: <m1639wjshq.fsf_-_@fess.ebiederm.org>
References: <4AEA8F0F.4030100@gmail.com> <m1hbtgmqew.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46089 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757542AbZJaAvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 20:51:13 -0400
In-Reply-To: <m1hbtgmqew.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Fri\, 30 Oct 2009 16\:07\:51 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I tested the recent unregister many changes and got a weird,
nasty and seemingly unrelasted kernel oops. Changing
unregister_netdevice_queue to use list_move_tail fixes
the problem for me.

ip link add type veth
rmmod veth

ls /sys/class/net/
showed one of the veth devices still present.

A subsequent ip link oopsed the box.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

---
diff --git a/net/core/dev.c b/net/core/dev.c
index 94f42a1..9c0b202 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5227,6 +5227,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	netdev_init_queues(dev);
 
 	INIT_LIST_HEAD(&dev->napi_list);
+	INIT_LIST_HEAD(&dev->unreg_list);
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
 	strcpy(dev->name, name);
@@ -5308,7 +5309,7 @@ void unregister_netdevice_queue(struct net_device *dev, struct list_head *head)
 	ASSERT_RTNL();
 
 	if (head) {
-		list_add_tail(&dev->unreg_list, head);
+		list_move_tail(&dev->unreg_list, head);
 	} else {
 		rollback_registered(dev);
 		/* Finish processing unregister after unlock */
