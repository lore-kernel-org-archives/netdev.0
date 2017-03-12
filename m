From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: regression (4.10) - interface remove uevents not generated
Date: Sat, 11 Mar 2017 22:51:04 -0800
Message-ID: <20170311234324.GA15113@outlook.office365.com>
References: <d519f10b-8512-efa2-03a1-81f6e4a91c7c@gmail.com>
 <20170311195047.GA10561@outlook.office365.com>
 <3aff47fb-7dde-2d21-74bc-9954560a2b51@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dkEUBIird37B8yKS"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Andrei Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>
To: Mantas =?utf-8?Q?Mikul=C4=97nas?= <grawity@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0120.outbound.protection.outlook.com ([104.47.0.120]:63725
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750933AbdCLGvX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Mar 2017 01:51:23 -0500
Content-Disposition: inline
In-Reply-To: <3aff47fb-7dde-2d21-74bc-9954560a2b51@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--dkEUBIird37B8yKS
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Sat, Mar 11, 2017 at 11:24:34PM +0200, Mantas Mikulėnas wrote:
> On 2017-03-11 21:50, Andrei Vagin wrote:
> > Hi Mantas,
> > 
> > Thank you for the report. Could you try out the attached patch?
> 
> Thanks, I tested it on current master but it doesn't seem to help; there
> still aren't any uevents for removed interfaces.

I reproduced the issue on my host and the correct patch is attached to
this message. Thanks!

> 
> -- 
> Mantas Mikulėnas <grawity@gmail.com>
> 

--dkEUBIird37B8yKS
Content-Type: text/plain; charset="koi8-r"
Content-Disposition: attachment;
	filename="0001-net-check-net-count-to-check-whether-a-netns-is-aliv.patch"

>From 456e28813d40f2076d4b9346fe8633c83b7a19d8 Mon Sep 17 00:00:00 2001
From: Andrei Vagin <avagin@openvz.org>
Date: Sat, 11 Mar 2017 15:18:25 -0800
Subject: [PATCH] net: check net->count to check whether a netns is alive or
 not

The previous idea was to check whether a net namespace is in
net_exit_list or not. It doesn't work, because net->exit_list is used in
__register_pernet_operations and __unregister_pernet_operations where
all namespaces are added to a temporary list to make cleanup in error
cases, so list_empty(&net->exit_list) always returns false.

Fixes: 002d8a1a6c11 ("net: skip genenerating uevents for network namespaces that are exiting")
Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 net/core/net-sysfs.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b0c04cf..1004418 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -952,7 +952,7 @@ net_rx_queue_update_kobjects(struct net_device *dev, int old_num, int new_num)
 	while (--i >= new_num) {
 		struct kobject *kobj = &dev->_rx[i].kobj;
 
-		if (!list_empty(&dev_net(dev)->exit_list))
+		if (!atomic_read(&dev_net(dev)->count))
 			kobj->uevent_suppress = 1;
 		if (dev->sysfs_rx_queue_group)
 			sysfs_remove_group(kobj, dev->sysfs_rx_queue_group);
@@ -1370,7 +1370,7 @@ netdev_queue_update_kobjects(struct net_device *dev, int old_num, int new_num)
 	while (--i >= new_num) {
 		struct netdev_queue *queue = dev->_tx + i;
 
-		if (!list_empty(&dev_net(dev)->exit_list))
+		if (!atomic_read(&dev_net(dev)->count))
 			queue->kobj.uevent_suppress = 1;
 #ifdef CONFIG_BQL
 		sysfs_remove_group(&queue->kobj, &dql_group);
@@ -1557,7 +1557,7 @@ void netdev_unregister_kobject(struct net_device *ndev)
 {
 	struct device *dev = &(ndev->dev);
 
-	if (!list_empty(&dev_net(ndev)->exit_list))
+	if (!atomic_read(&dev_net(ndev)->count))
 		dev_set_uevent_suppress(dev, 1);
 
 	kobject_get(&dev->kobj);
-- 
2.9.3


--dkEUBIird37B8yKS--
