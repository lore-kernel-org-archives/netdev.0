From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [SCSI] cxgb3i: convert cdev->l2opt to use rcu to prevent NULL
 dereference (v2)
Date: Mon, 26 Sep 2011 10:20:52 -0400
Message-ID: <20110926142052.GA18283@hmsreliant.think-freely.org>
References: <20110926134048.GA10999@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39465 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab1IZOVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 10:21:01 -0400
Content-Disposition: inline
In-Reply-To: <20110926134048.GA10999@longonot.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2011 at 04:40:48PM +0300, Dan Carpenter wrote:
> Hi Neil,
> 
> c98bc57ee65b6 "[SCSI] cxgb3i: convert cdev->l2opt to use rcu to
> prevent NULL dereference (v2)" from linux-next introduces a usinging
> uninitialized variable bug.
> 
>  struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
>                              struct net_device *dev)
>  {
> -       struct l2t_entry *e;
> -       struct l2t_data *d = L2DATA(cdev);
> +       struct l2t_entry *e = NULL;
> +       struct l2t_data *d;
>         u32 addr = *(u32 *) neigh->primary_key;
>         int ifidx = neigh->dev->ifindex;
>         int hash = arp_hash(addr, ifidx, d);
>                                          ^
> Uninitialized variable.
> 
>         struct port_info *p = netdev_priv(dev);
>         int smt_idx = p->port_id;
>  
> +       rcu_read_lock();
> +       d = L2DATA(cdev);
> +       if (!d)
> +               goto done_rcu;
> +
> 
> regards,
> dan carpenter
> 

Yup, thanks, you need this to9 fix the uninitalized var.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

 l2t.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)


diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index 3808f99..4154097 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -302,9 +302,9 @@ struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
 {
 	struct l2t_entry *e = NULL;
 	struct l2t_data *d;
+	int hash;
 	u32 addr = *(u32 *) neigh->primary_key;
 	int ifidx = neigh->dev->ifindex;
-	int hash = arp_hash(addr, ifidx, d);
 	struct port_info *p = netdev_priv(dev);
 	int smt_idx = p->port_id;
 
@@ -313,6 +313,8 @@ struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
 	if (!d)
 		goto done_rcu;
 
+	hash = arp_hash(addr, ifidx, d);
+
 	write_lock_bh(&d->lock);
 	for (e = d->l2tab[hash].first; e; e = e->next)
 		if (e->addr == addr && e->ifindex == ifidx &&
