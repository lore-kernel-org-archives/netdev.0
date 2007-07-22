From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Fix sch_prio to detect the root qdisc loading
Date: Sun, 22 Jul 2007 18:32:32 +0200
Message-ID: <46A386A0.4050406@trash.net>
References: <20070721191459.2146.48448.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030700070505060801090802"
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43491 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040AbXGVQel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 12:34:41 -0400
In-Reply-To: <20070721191459.2146.48448.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030700070505060801090802
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

PJ Waskiewicz wrote:
> The sch->parent handle will be NULL for the scheduler that is TC_H_ROOT.
> Change this check in prio_tune() so that only the root qdisc can be
> multiqueue-enabled.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> ---
> 
>  net/sched/sch_prio.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
> index 2d8c084..271051e 100644
> --- a/net/sched/sch_prio.c
> +++ b/net/sched/sch_prio.c
> @@ -239,11 +239,13 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
>  	/* If we're multiqueue, make sure the number of incoming bands
>  	 * matches the number of queues on the device we're associating with.
>  	 * If the number of bands requested is zero, then set q->bands to
> -	 * dev->egress_subqueue_count.
> +	 * dev->egress_subqueue_count.  Also, the root qdisc must be the
> +	 * only one that is enabled for multiqueue, since it's the only one
> +	 * that interacts with the underlying device.
>  	 */
>  	q->mq = RTA_GET_FLAG(tb[TCA_PRIO_MQ - 1]);
>  	if (q->mq) {
> -		if (sch->handle != TC_H_ROOT)
> +		if (sch->parent != NULL)


As explained in my last mail, sch->parent is an integer. And it is
set when grafting the qdisc, not on initilization, so it is always
0 here when coming from prio_init.

This untested patch should make sure its always set correctly.

--------------030700070505060801090802
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 13c09bc..0975547 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -380,6 +380,10 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 		return;
 	while ((parentid = sch->parent)) {
 		sch = qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
+		if (sch == NULL) {
+			WARN_ON(parentid != TC_H_ROOT);
+			return;
+		}
 		cops = sch->ops->cl_ops;
 		if (cops->qlen_notify) {
 			cl = cops->get(sch, parentid);
@@ -420,8 +424,6 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
 			unsigned long cl = cops->get(parent, classid);
 			if (cl) {
 				err = cops->graft(parent, cl, new, old);
-				if (new)
-					new->parent = classid;
 				cops->put(parent, cl);
 			}
 		}
@@ -436,7 +438,8 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
  */
 
 static struct Qdisc *
-qdisc_create(struct net_device *dev, u32 handle, struct rtattr **tca, int *errp)
+qdisc_create(struct net_device *dev, u32 parent, u32 handle,
+	     struct rtattr **tca, int *errp)
 {
 	int err;
 	struct rtattr *kind = tca[TCA_KIND-1];
@@ -482,6 +485,8 @@ qdisc_create(struct net_device *dev, u32 handle, struct rtattr **tca, int *errp)
 		goto err_out2;
 	}
 
+	new->parent = parent;
+
 	if (handle == TC_H_INGRESS) {
 		sch->flags |= TCQ_F_INGRESS;
 		sch->stats_lock = &dev->ingress_lock;
@@ -758,9 +763,11 @@ create_n_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
 	if (clid == TC_H_INGRESS)
-		q = qdisc_create(dev, tcm->tcm_parent, tca, &err);
+		q = qdisc_create(dev, tcm->tcm_parent, tcm->tcm_parent,
+				 tca, &err);
 	else
-		q = qdisc_create(dev, tcm->tcm_handle, tca, &err);
+		q = qdisc_create(dev, tcm->tcm_parent, tcm->tcm_handle,
+				 tca, &err);
 	if (q == NULL) {
 		if (err == -EAGAIN)
 			goto replay;

--------------030700070505060801090802--
