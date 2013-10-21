From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net-next PATCH] macvlan: resolve ENOENT errors on creation
Date: Mon, 21 Oct 2013 23:34:41 +0200
Message-ID: <20131021213441.GB18170@redhat.com>
References: <20131021212801.19330.69659.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287Ab3JUVhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Oct 2013 17:37:12 -0400
Content-Disposition: inline
In-Reply-To: <20131021212801.19330.69659.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 21, 2013 at 02:28:02PM -0700, John Fastabend wrote:
>After the commit below attempting to create macvlan devices was
>resulting in ENOENT errors,
>
># ip link add link p3p2 type macvlan
>RTNETLINK answers: Invalid argument
>
>This happens because netdev_upper_dev_link() is called before
>register_netdevice() in the macvlan code. Through a call chain
>this results in a call to __netdev_adjacent_dev_insert() and
>finally a sysfs_create_link(). This requires the kobject of
>the macvlan to be registered which is done in register_netdevice().
>If there is no kobject which is the case here the ENOENT error
>is seen on the command line.
>
>To resolve this move the netdev_upper_dev_link() call below
>the register_netdevice() call. This aligns with vlan driver
>flow.

Yep, changed the vlan code, but didn't see the macvlan. My cscope didn't
catch it for some reason :-/.

I've also checked - there are no users except bonding, vlan (both are ok),
and macvlan.

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>
>Regression introduced here,
>
>commit 5831d66e8097aedfa3bc35941cf265ada2352317
>Author: Veaceslav Falico <vfalico@redhat.com>
>Date:   Wed Sep 25 09:20:32 2013 +0200
>
>    net: create sysfs symlinks for neighbour devices
>
>CC: Veaceslav Falico <vfalico@redhat.com>
>CC: Neil Horman <nhorman@tuxdriver.com>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>---
> drivers/net/macvlan.c |   11 +++++------
> 1 file changed, 5 insertions(+), 6 deletions(-)
>
>diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>index 9bf46bd..cc9845e 100644
>--- a/drivers/net/macvlan.c
>+++ b/drivers/net/macvlan.c
>@@ -828,22 +828,21 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
> 		eth_hw_addr_inherit(dev, lowerdev);
> 	}
>
>+	port->count += 1;
>+	err = register_netdevice(dev);
>+	if (err < 0)
>+		goto destroy_port;
>+
> 	err = netdev_upper_dev_link(lowerdev, dev);
> 	if (err)
> 		goto destroy_port;
>
>-	port->count += 1;
>-	err = register_netdevice(dev);
>-	if (err < 0)
>-		goto upper_dev_unlink;
>
> 	list_add_tail_rcu(&vlan->list, &port->vlans);
> 	netif_stacked_transfer_operstate(lowerdev, dev);
>
> 	return 0;
>
>-upper_dev_unlink:
>-	netdev_upper_dev_unlink(lowerdev, dev);
> destroy_port:
> 	port->count -= 1;
> 	if (!port->count)
>
