From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo
 ops
Date: Wed, 3 Jun 2015 23:05:59 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1506032249390.46554@rocker1.rocker.net>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com> <1433183947-13095-6-git-send-email-sfeldma@gmail.com> <556D363A.5010005@lab.ntt.co.jp> <20150601.222442.1854333703599698362.davem@davemloft.net> <CAE4R7bBL+=-akoNLPqPae=zrYe3DH59t=8UK_T7KhcHSNaKUtw@mail.gmail.com>
 <556D96ED.9010309@mojatatu.com> <CAE4R7bAXA27cqBLv6MP0kak-L=1bXUoZPw7vxUyYpP=-dk=eAg@mail.gmail.com> <556DE0CD.9080000@cumulusnetworks.com> <CAE4R7bCPKcCYcHZ3WhkvjpioPhJP12Q35zRsq=t5gAO7JOZ94Q@mail.gmail.com> <556F209A.6090304@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Scott Feldman <sfeldma@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Netdev <netdev@vger.kernel.org>,
	=?ISO-8859-2?Q?Ji=F8=ED_P=EDrko?= <jiri@resnulli.us>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34558 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbbFDGEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 02:04:10 -0400
Received: by payr10 with SMTP id r10so22663938pay.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 23:04:09 -0700 (PDT)
In-Reply-To: <556F209A.6090304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 4 Jun 2015, Toshiaki Makita wrote:

> Bridge's vlan_filtering is handled in master->op->foo(), not in 
> port->op->foo().
> Can't we introduce another switchdev handler that performs MASTER operation 
> instead of calling SELF operation?
>
> br_afspec()
> nbp_vlan_add()
>  netdev_switch_port_vlan_add()
>   rocker->ndo_switch_port_vlan_add() <- only used for MASTER operation
>
> I'm wondering why SELF operation (rocker->ndo_bridge_setlink()) does what 
> should be done in MASTER operation.

Something like this:

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 13013fe..df57ede 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -2,6 +2,7 @@
  #include <linux/netdevice.h>
  #include <linux/rtnetlink.h>
  #include <linux/slab.h>
+#include <net/switchdev.h>

  #include "br_private.h"

@@ -36,6 +37,36 @@ static void __vlan_add_flags(struct net_port_vlans *v, u16 vid, u16 flags)
  		clear_bit(vid, v->untagged_bitmap);
  }

+
+static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
+			  u16 vid, u16 flags)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct switchdev_obj vlan_obj = {
+		.id = SWITCHDEV_OBJ_PORT_VLAN,
+		.u.vlan = {
+			.flags = flags,
+			.vid_start = vid,
+			.vid_end = vid,
+		},
+	};
+	int err;
+
+	/* If driver uses VLAN ndo ops, use 8021q to install vid
+	 * on device, otherwise try switchdev ops to install vid.
+	 */
+
+	if (ops->ndo_vlan_rx_add_vid) {
+		err = vlan_vid_add(dev, br->vlan_proto, vid);
+	} else {
+		err = switchdev_port_obj_add(dev, &vlan_obj);
+		if (err == -EOPNOTSUPP)
+			err = 0;
+	}
+
+	return err;
+}
+
  static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
  {
  	struct net_bridge_port *p = NULL;
@@ -62,7 +93,7 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
  		 * This ensures tagged traffic enters the bridge when
  		 * promiscuous mode is disabled by br_manage_promisc().
  		 */
-		err = vlan_vid_add(dev, br->vlan_proto, vid);
+		err = __vlan_vid_add(dev, br, vid, flags);
  		if (err)
  			return err;
  	}
@@ -86,6 +117,28 @@ out_filt:
  	return err;
  }

+static void __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
+			  u16 vid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct switchdev_obj vlan_obj = {
+		.id = SWITCHDEV_OBJ_PORT_VLAN,
+		.u.vlan = {
+			.vid_start = vid,
+			.vid_end = vid,
+		},
+	};
+
+	/* If driver uses VLAN ndo ops, use 8021q to delete vid
+	 * on device, otherwise try switchdev ops to delete vid.
+	 */
+
+	if (ops->ndo_vlan_rx_kill_vid)
+		vlan_vid_del(dev, br->vlan_proto, vid);
+	else
+		switchdev_port_obj_del(dev, &vlan_obj);
+}
+
  static int __vlan_del(struct net_port_vlans *v, u16 vid)
  {
  	if (!test_bit(vid, v->vlan_bitmap))
@@ -96,7 +149,7 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)

  	if (v->port_idx) {
  		struct net_bridge_port *p = v->parent.port;
-		vlan_vid_del(p->dev, p->br->vlan_proto, vid);
+		__vlan_vid_del(p->dev, p->br, vid);
  	}

  	clear_bit(vid, v->vlan_bitmap);
