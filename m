From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: [SCSI] cxgb3i: convert cdev->l2opt to use rcu to prevent NULL
 dereference (v2)
Date: Mon, 26 Sep 2011 16:40:48 +0300
Message-ID: <20110926134048.GA10999@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:37122 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952Ab1IZNng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 09:43:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil,

c98bc57ee65b6 "[SCSI] cxgb3i: convert cdev->l2opt to use rcu to
prevent NULL dereference (v2)" from linux-next introduces a usinging
uninitialized variable bug.

 struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
                             struct net_device *dev)
 {
-       struct l2t_entry *e;
-       struct l2t_data *d = L2DATA(cdev);
+       struct l2t_entry *e = NULL;
+       struct l2t_data *d;
        u32 addr = *(u32 *) neigh->primary_key;
        int ifidx = neigh->dev->ifindex;
        int hash = arp_hash(addr, ifidx, d);
                                         ^
Uninitialized variable.

        struct port_info *p = netdev_priv(dev);
        int smt_idx = p->port_id;
 
+       rcu_read_lock();
+       d = L2DATA(cdev);
+       if (!d)
+               goto done_rcu;
+

regards,
dan carpenter
