From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 22:10:39 -0700 (PDT)
Message-ID: <20070724.221039.40831312.davem@davemloft.net>
References: <20070724.174537.21926733.davem@davemloft.net>
	<1185326149.1803.421.camel@localhost.localdomain>
	<20070724.184759.111203672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58422
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752094AbXGYFKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 01:10:40 -0400
In-Reply-To: <20070724.184759.111203672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 24 Jul 2007 18:47:59 -0700 (PDT)

> EHEA is another case, in fact EHEA doesn't disable interrupts at
> all.
>
> The reason is that EHEA has several NAPI sources behind one single
> hardware interrupt.
> 
> That driver's issues were discussed long ago and actually were the
> initial impetus for Stephen to cut the first napi_struct patch.
> 
> Because of that weird layout EHEA needs special consideration, which I
> will get back to.

Some of the things I say above seem to be not true. :-)

I studied the EHEA driver a bit, enclosed at the end of this email is
the current version of the code in my napi_struct tree.

It seems there is one unique interrupt per port.  So this device's
layout is identical to the one sunvnet, and other virtualized net
devices, tend to have.  Multiple ports per netdev, each port
generating unique events.

It also seems that the EHEA interrupts are "one-shot" in nature, and
it seems that the:

 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_ep(pr->send_cq);
 		ehea_reset_cq_n1(pr->recv_cq);

operations are what get the interrupt going again.  If someone
reading this understands the hardware better, please let us know
if this analysis is accurate, thanks.

So it appears I subconsciously converted this driver to multi-NAPI
away from the dreaded "dummy netdevice" scheme a lot of multi-queue
drivers are using.  It's amusing because I don't remember consciously
doing this, but I'll take it nonetheless! :-)

This appears to resolve all of the NAPI limitations in the driver
without having to waste memory and resources on dummy net devices.

In short, EHEA is a great fit for napi_struct!

It may look corny how the spinlock in the interrupt handler
just sits around the netif_rx_schedule() call and nothing
else, but I do believe it is necessary so that the "reenable
interrupt, then maybe netif_rx_complete()" runs atomically
wrt. the interrupt NAPI trigger in order to avoid lost events.

EHEA is also a perfect candidate for the solutions being suggested
for multi-TX-queue situations like sunvnet.  I'll have to get back
to that at some point.

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 489c8b2..d4227be 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -351,6 +351,8 @@ struct ehea_q_skb_arr {
  * Port resources
  */
 struct ehea_port_res {
+	spinlock_t poll_lock;
+	struct napi_struct napi;
 	struct port_stats p_stats;
 	struct ehea_mr send_mr;       	/* send memory region */
 	struct ehea_mr recv_mr;       	/* receive memory region */
@@ -362,7 +364,6 @@ struct ehea_port_res {
 	struct ehea_cq *send_cq;
 	struct ehea_cq *recv_cq;
 	struct ehea_eq *eq;
-	struct net_device *d_netdev;
 	struct ehea_q_skb_arr rq1_skba;
 	struct ehea_q_skb_arr rq2_skba;
 	struct ehea_q_skb_arr rq3_skba;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 4c70a93..9244338 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -389,9 +389,9 @@ static int ehea_treat_poll_error(struct ehea_port_res *pr, int rq,
 	return 0;
 }
 
-static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
-					struct ehea_port_res *pr,
-					int *budget)
+static int ehea_proc_rwqes(struct net_device *dev,
+			   struct ehea_port_res *pr,
+			   int budget)
 {
 	struct ehea_port *port = pr->port;
 	struct ehea_qp *qp = pr->qp;
@@ -404,18 +404,16 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 	int skb_arr_rq2_len = pr->rq2_skba.len;
 	int skb_arr_rq3_len = pr->rq3_skba.len;
 	int processed, processed_rq1, processed_rq2, processed_rq3;
-	int wqe_index, last_wqe_index, rq, my_quota, port_reset;
+	int wqe_index, last_wqe_index, rq, port_reset;
 
 	processed = processed_rq1 = processed_rq2 = processed_rq3 = 0;
 	last_wqe_index = 0;
-	my_quota = min(*budget, dev->quota);
 
 	cqe = ehea_poll_rq1(qp, &wqe_index);
-	while ((my_quota > 0) && cqe) {
+	while ((processed < budget) && cqe) {
 		ehea_inc_rq1(qp);
 		processed_rq1++;
 		processed++;
-		my_quota--;
 		if (netif_msg_rx_status(port))
 			ehea_dump(cqe, sizeof(*cqe), "CQE");
 
@@ -430,14 +428,14 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 					if (netif_msg_rx_err(port))
 						ehea_error("LL rq1: skb=NULL");
 
-					skb = netdev_alloc_skb(port->netdev,
+					skb = netdev_alloc_skb(dev,
 							       EHEA_L_PKT_SIZE);
 					if (!skb)
 						break;
 				}
 				skb_copy_to_linear_data(skb, ((char*)cqe) + 64,
 						 cqe->num_bytes_transfered - 4);
-				ehea_fill_skb(port->netdev, skb, cqe);
+				ehea_fill_skb(dev, skb, cqe);
 			} else if (rq == 2) {  /* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
 						       skb_arr_rq2_len, cqe);
@@ -446,7 +444,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 						ehea_error("rq2: skb=NULL");
 					break;
 				}
-				ehea_fill_skb(port->netdev, skb, cqe);
+				ehea_fill_skb(dev, skb, cqe);
 				processed_rq2++;
 			} else {  /* RQ3 */
 				skb = get_skb_by_index(skb_arr_rq3,
@@ -456,7 +454,7 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 						ehea_error("rq3: skb=NULL");
 					break;
 				}
-				ehea_fill_skb(port->netdev, skb, cqe);
+				ehea_fill_skb(dev, skb, cqe);
 				processed_rq3++;
 			}
 
@@ -480,14 +478,12 @@ static struct ehea_cqe *ehea_proc_rwqes(struct net_device *dev,
 	}
 
 	pr->rx_packets += processed;
-	*budget -= processed;
 
 	ehea_refill_rq1(pr, last_wqe_index, processed_rq1);
 	ehea_refill_rq2(pr, processed_rq2);
 	ehea_refill_rq3(pr, processed_rq3);
 
-	cqe = ehea_poll_rq1(qp, &wqe_index);
-	return cqe;
+	return processed;
 }
 
 static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
@@ -551,12 +547,13 @@ static struct ehea_cqe *ehea_proc_cqes(struct ehea_port_res *pr, int my_quota)
 
 #define EHEA_NAPI_POLL_NUM_BEFORE_IRQ 16
 
-static int ehea_poll(struct net_device *dev, int *budget)
+static int ehea_poll(struct napi_struct *napi, int budget)
 {
-	struct ehea_port_res *pr = dev->priv;
+	struct ehea_port_res *pr = container_of(napi, struct ehea_port_res, napi);
+	struct net_device *dev = pr->port->netdev;
 	struct ehea_cqe *cqe;
 	struct ehea_cqe *cqe_skb = NULL;
-	int force_irq, wqe_index;
+	int force_irq, wqe_index, rx;
 
 	cqe = ehea_poll_rq1(pr->qp, &wqe_index);
 	cqe_skb = ehea_poll_cq(pr->send_cq);
@@ -564,8 +561,8 @@ static int ehea_poll(struct net_device *dev, int *budget)
 	force_irq = (pr->poll_counter > EHEA_NAPI_POLL_NUM_BEFORE_IRQ);
 
 	if ((!cqe && !cqe_skb) || force_irq) {
+		spin_lock_irq(&pr->poll_lock);
 		pr->poll_counter = 0;
-		netif_rx_complete(dev);
 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_ep(pr->send_cq);
 		ehea_reset_cq_n1(pr->recv_cq);
@@ -573,27 +570,31 @@ static int ehea_poll(struct net_device *dev, int *budget)
 		cqe = ehea_poll_rq1(pr->qp, &wqe_index);
 		cqe_skb = ehea_poll_cq(pr->send_cq);
 
-		if (!cqe && !cqe_skb)
-			return 0;
-
-		if (!netif_rx_reschedule(dev, dev->quota))
+		if (!cqe && !cqe_skb) {
+			netif_rx_complete(dev, napi);
+			spin_unlock_irq(&pr->poll_lock);
 			return 0;
+		}
+		spin_unlock_irq(&pr->poll_lock);
 	}
 
-	cqe = ehea_proc_rwqes(dev, pr, budget);
+	rx = ehea_proc_rwqes(dev, pr, budget);
+	cqe = ehea_poll_rq1(pr->qp, &wqe_index);
 	cqe_skb = ehea_proc_cqes(pr, 300);
 
 	if (cqe || cqe_skb)
 		pr->poll_counter++;
 
-	return 1;
+	return rx;
 }
 
 static irqreturn_t ehea_recv_irq_handler(int irq, void *param)
 {
 	struct ehea_port_res *pr = param;
 
-	netif_rx_schedule(pr->d_netdev);
+	spin_lock(&pr->poll_lock);
+	netif_rx_schedule(pr->port->netdev, &pr->napi);
+	spin_unlock(&pr->poll_lock);
 
 	return IRQ_HANDLED;
 }
@@ -1207,14 +1208,8 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 
 	kfree(init_attr);
 
-	pr->d_netdev = alloc_netdev(0, "", ether_setup);
-	if (!pr->d_netdev)
-		goto out_free;
-	pr->d_netdev->priv = pr;
-	pr->d_netdev->weight = 64;
-	pr->d_netdev->poll = ehea_poll;
-	set_bit(__LINK_STATE_START, &pr->d_netdev->state);
-	strcpy(pr->d_netdev->name, port->netdev->name);
+	spin_lock_init(&pr->poll_lock);
+	netif_napi_init(&pr->napi, ehea_poll, NULL, 64);
 
 	ret = 0;
 	goto out;
@@ -1237,8 +1232,6 @@ static int ehea_clean_portres(struct ehea_port *port, struct ehea_port_res *pr)
 {
 	int ret, i;
 
-	free_netdev(pr->d_netdev);
-
 	ret = ehea_destroy_qp(pr->qp);
 
 	if (!ret) {
@@ -2261,9 +2254,7 @@ static int ehea_down(struct net_device *dev)
 	ehea_free_interrupts(dev);
 
 	for (i = 0; i < port->num_def_qps; i++)
-		while (test_bit(__LINK_STATE_RX_SCHED,
-				&port->port_res[i].d_netdev->state))
-			msleep(1);
+		napi_disable(&port->port_res[i].napi);
 
 	port->state = EHEA_PORT_DOWN;
 
@@ -2626,8 +2617,6 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	memcpy(dev->dev_addr, &port->mac_addr, ETH_ALEN);
 
 	dev->open = ehea_open;
-	dev->poll = ehea_poll;
-	dev->weight = 64;
 	dev->stop = ehea_stop;
 	dev->hard_start_xmit = ehea_start_xmit;
 	dev->get_stats = ehea_get_stats;
