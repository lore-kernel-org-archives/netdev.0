From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] rocker: move netevent neigh update to processes
 context
Date: Thu, 21 May 2015 10:00:38 +0200
Message-ID: <20150521080038.GA2212@nanopsycho.orion>
References: <1432184707-27252-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	makita.toshiaki@lab.ntt.co.jp
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:33151 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbbEUIAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 04:00:42 -0400
Received: by wgjc11 with SMTP id c11so76997819wgj.0
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 01:00:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1432184707-27252-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 21, 2015 at 07:05:07AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>In review of Simon's patchset "rocker: transaction fixes". it was noted
>that rocker->neigh_tbl_next_index was unprotected in the call path below
>and could race with other contexts calling rocker_port_ipv4_neigh():
>
>	arp_process()
>	neigh_update()
>	rocker_neigh_update()
>	rocker_port_ipv4_neigh()
>
>To fix, move the neigh_update() event processing to process contexts and
>hold rtnl_lock to call rocker_port_ipv4_neigh().  This will protect
>rocker->neigh_tbl_next_index accesses and is more consistent with the rest
>of the driver code where non-I/O processing is done under process context
>with rtnl_lock held.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> drivers/net/ethernet/rocker/rocker.c |   52 +++++++++++++++++++++++++++++-----
> 1 file changed, 45 insertions(+), 7 deletions(-)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index 0f5e962..4cff2f6 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -5240,14 +5240,52 @@ static struct notifier_block rocker_netdevice_nb __read_mostly = {
>  * Net event notifier event handler
>  ************************************/
> 
>-static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
>+struct rocker_neigh_update_work {
>+	struct work_struct work;
>+	struct rocker_port *rocker_port;
>+	int flags;
>+	__be32 ip_addr;
>+	unsigned char ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
>+};
>+
>+static void rocker_event_neigh_update_work(struct work_struct *work)
> {
>-	struct rocker_port *rocker_port = netdev_priv(dev);
>-	int flags = (n->nud_state & NUD_VALID) ? 0 : ROCKER_OP_FLAG_REMOVE;
>-	__be32 ip_addr = *(__be32 *)n->primary_key;
>+	struct rocker_neigh_update_work *nw =
>+		container_of(work, struct rocker_neigh_update_work, work);
>+	int err;
>+
>+	rtnl_lock();
>+	err = rocker_port_ipv4_neigh(nw->rocker_port, SWITCHDEV_TRANS_NONE,
>+				     nw->flags, nw->ip_addr, nw->ha);
>+	rtnl_unlock();
>+
>+	if (err)
>+		netdev_warn(nw->rocker_port->dev,
>+			    "failed to handle neigh %pI4 update (err %d)\n",
>+			    &nw->ip_addr, err);
> 
>-	return rocker_port_ipv4_neigh(rocker_port, SWITCHDEV_TRANS_NONE,
>-				      flags, ip_addr, n->ha);
>+	kfree(work);

It should be kfree(nw)
I know it is the same, but looks more correct.

Other than this, this looks good to me

Acked-by: Jiri Pirko <jiri@resnulli.us>
