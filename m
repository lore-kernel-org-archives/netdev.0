From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] net: Separate the close_list and the unreg_list
Date: Sat, 05 Oct 2013 19:13:14 -0700
Message-ID: <87a9inb0zp.fsf@xmission.com>
References: <5250c0b6.45dc420a.738b.6a58@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Francesco Ruggeri <fruggeri@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:56858 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab3JFCN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 22:13:27 -0400
In-Reply-To: <5250c0b6.45dc420a.738b.6a58@mx.google.com> (Francesco Ruggeri's
	message of "Sat, 5 Oct 2013 06:18:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@aristanetworks.com> writes:

> Hi Eric,
> I am running some more extensive tests with this patch and I ran into
> the crash below.
>
> It may be caused by
>
> @@ -1301,7 +1301,7 @@ int dev_close(struct net_device *dev)
>  	if (dev->flags & IFF_UP) {
>  		LIST_HEAD(single);
>  
> -		list_add(&dev->unreg_list, &single);
> +		list_add(&dev->close_list, &single);
>  		dev_close_many(&single);
>  		list_del(&single);
>  	}
>
> dev_close_many expects net_devices to be linked by unreg_list.
> Let me know what you think.

Yes.  There does appear to be a logic problem there.
Grr.

It looks like the least error prone approach is to simply have
dev_close_many consume it's list.

Can you verify this incremental change fixes it for you?

This changes all of the callers to build the close_list before
calling dev_close_many.  Which makes it safe to muck with the close
list however we want.

---

diff --git a/net/core/dev.c b/net/core/dev.c
index c8db0bfc36d6..fa0b2b06c1a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1362,16 +1362,15 @@ static int __dev_close(struct net_device *dev)
 static int dev_close_many(struct list_head *head)
 {
        struct net_device *dev, *tmp;
-       LIST_HEAD(many);
 
-       /* rollback_registered_many needs the original unmodified list */
-       list_for_each_entry(dev, head, unreg_list)
-               if (dev->flags & IFF_UP)
-                       list_add_tail(&dev->close_list, &many);
+       /* Remove the devices that don't need to be closed */
+       list_for_each_entry_safe(dev, tmp, head, close_list)
+               if (!(dev->flags & IFF_UP))
+                       list_del_init(&dev->close_list);
 
-       __dev_close_many(&many);
+       __dev_close_many(head);
 
-       list_for_each_entry_safe(dev, tmp, &many, close_list) {
+       list_for_each_entry_safe(dev, tmp, head, close_list) {
                rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
                call_netdevice_notifiers(NETDEV_DOWN, dev);
                list_del_init(&dev->close_list);
@@ -5439,6 +5438,7 @@ static void net_set_todo(struct net_device *dev)
 static void rollback_registered_many(struct list_head *head)
 {
        struct net_device *dev, *tmp;
+       LIST_HEAD(close_head);
 
        BUG_ON(dev_boot_phase);
        ASSERT_RTNL();
@@ -5461,7 +5461,9 @@ static void rollback_registered_many(struct list_head *head)
        }
 
        /* If device is running, close it first. */
-       dev_close_many(head);
+       list_for_each_entry(dev, head, unreg_list)
+               list_add_tail(&dev->close_list, &close_head);
+       dev_close_many(&close_head);
 
        list_for_each_entry(dev, head, unreg_list) {
                /* And unlink it from device chain. */
