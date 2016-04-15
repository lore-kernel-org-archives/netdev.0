From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: qdisc spin lock
Date: Fri, 15 Apr 2016 16:56:28 -0700
Message-ID: <1460764588.10638.83.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
	 <CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
	 <CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
	 <1460125157.6473.434.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAAmHdhw8-qEHwe+GNU_p9UGZyMU38PgrjaM9zEK9nOfSENxDUg@mail.gmail.com>
	 <1460760854.10638.81.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAAmHdhzbEJAR00akLg8UG9UOwa+TRw+PaeuYyguiJuciYaLroA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:33448 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbcDOX4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 19:56:33 -0400
Received: by mail-ob0-f180.google.com with SMTP id tz8so72314930obc.0
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 16:56:32 -0700 (PDT)
In-Reply-To: <CAAmHdhzbEJAR00akLg8UG9UOwa+TRw+PaeuYyguiJuciYaLroA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-15 at 16:05 -0700, Michael Ma wrote:
> Would definitely appreciate that. If you can share the patch it will
> be helpful as well. Let me know if I can help with this...

Sure, here is what I am going to test :

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 941ec99cd3b6..f890ebe78629 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4003,11 +4003,17 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb,
 	 * skb_tx_hash and will put the skbs in the queue we expect on their
 	 * way down to the bonding driver.
 	 */
-	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
+	struct bonding *bond = netdev_priv(dev);
+	u16 txq;
 
 	/* Save the original txq to restore before passing to the driver */
 	qdisc_skb_cb(skb)->slave_dev_queue_mapping = skb->queue_mapping;
 
+	if (!bond->queue_id_selection_enabled)
+		return fallback(dev, skb);
+
+	txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
+
 	if (unlikely(txq >= dev->real_num_tx_queues)) {
 		do {
 			txq -= dev->real_num_tx_queues;
@@ -4020,7 +4026,8 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
 {
 	struct bonding *bond = netdev_priv(dev);
 
-	if (bond_should_override_tx_queue(bond) &&
+	if (bond->queue_id_selection_enabled &&
+	    bond_should_override_tx_queue(bond) &&
 	    !bond_slave_override(bond, skb))
 		return NETDEV_TX_OK;
 
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 577e57cad1dc..1a8a5153f027 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -1270,6 +1270,7 @@ static int bond_option_ad_select_set(struct bonding *bond,
 static int bond_option_queue_id_set(struct bonding *bond,
 				    const struct bond_opt_value *newval)
 {
+	bool queue_id_selection_enabled = false;
 	struct slave *slave, *update_slave;
 	struct net_device *sdev;
 	struct list_head *iter;
@@ -1318,6 +1319,12 @@ static int bond_option_queue_id_set(struct bonding *bond,
 	/* Actually set the qids for the slave */
 	update_slave->queue_id = qid;
 
+	bond_for_each_slave(bond, slave, iter) {
+		if (update_slave->queue_id)
+			queue_id_selection_enabled = true;
+	}
+	bond->queue_id_selection_enabled = queue_id_selection_enabled;
+
 out:
 	return ret;
 
diff --git a/include/net/bonding.h b/include/net/bonding.h
index 791800ddd6d9..29e29491c571 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -204,6 +204,7 @@ struct bonding {
 	struct   slave __rcu *primary_slave;
 	struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
 	bool     force_primary;
+	bool	 queue_id_selection_enabled;
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
 			      struct slave *);
