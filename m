From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next v2] net: dev: fix the incorrect hold of net namespace's lo device
Date: Fri, 24 Aug 2012 09:36:55 +0800
Message-ID: <1345772215-30379-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:21566 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752876Ab2HXBhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 21:37:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When moving a net device from one net namespace to another
net namespace,dev_change_net_namespace calls NETDEV_DOWN
event,so the original net namespace's dst entries which
beloned to this net device will be put into dst_garbage
list.

then dev_change_net_namespace will set this net device's
net to the new net namespace.

If we unregister this net device's driver, this will trigger
the NETDEV_UNREGISTER_FINAL event, dst_ifdown will be called,
and get this net device's dst entries from dst_garbage list,
put these entries' dev to the new net namespace's lo device.

It's not what we want,actually we need these dst entries hold
the original net namespace's lo device,this incorrect device
holding will trigger emg message like below.
unregister_netdevice: waiting for lo to become free. Usage count = 1

so we should call NETDEV_UNREGISTER_FINAL event in
dev_change_net_namespace too,in order to make sure dst entries
already in the dst_garbage list, we need rcu_barrier before we
call NETDEV_UNREGISTER_FINAL event.

With help form Eric Dumazet.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/dev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index bc857fe..6956d4c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6256,6 +6256,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	   the device is just moving and can keep their slaves up.
 	*/
 	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
+	rcu_barrier();
+	call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
 	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
 
 	/*
-- 
1.7.7.6
