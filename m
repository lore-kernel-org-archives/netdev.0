From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: bond_select_queue off by one
Date: Fri, 18 Feb 2011 17:49:58 -0500
Message-ID: <20110218224958.GC11864@gospo.rdu.redhat.com>
References: <20110218020713.GA9696@linuxace.com> <22094.1298004108@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Phil Oester <kernel@linuxace.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753687Ab1BRWuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 17:50:13 -0500
Content-Disposition: inline
In-Reply-To: <22094.1298004108@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 17, 2011 at 08:41:48PM -0800, Jay Vosburgh wrote:
> Phil Oester <kernel@linuxace.com> wrote:
> 
> >The bonding driver's bond_select_queue function simply returns
> >skb->queue_mapping.  However queue_mapping could be == 16
> >for queue #16.  This causes the following message to be flooded
> >to syslog:
> >
> >kernel: bondx selects TX queue 16, but real number of TX queues is 16
> >
> >ndo_select_queue wants a zero-based number, so bonding driver needs
> >to subtract one to return the proper queue number.  Also fix grammar in
> >a comment while in the vicinity.
> 
> 	Andy, can you comment on this?
> 
> 	If memory serves, the omission of queue ID zero was on purpose;
> is this patch going to break any of the functionality added by:
> 
> commit bb1d912323d5dd50e1079e389f4e964be14f0ae3
> Author: Andy Gospodarek <andy@greyhouse.net>
> Date:   Wed Jun 2 08:40:18 2010 +0000
> 
>     bonding: allow user-controlled output slave selection
> 

My original intent was that a queue_mapping == 0 would indicate that the
mode's default transmit routine would be used.  We could still operate
under this assumption, however.  I think the patch below will work.

> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> >This looks basically correct, but it should use the proper functions:
> >
> >	skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
> 
> 	As Ben points out, skb_rx_queue_recorded, skb_record_rx_queue,
> et al, do the offset by one internally, but the bond_slave_override
> function is comparing the slave's queue_id to the skb->queue_mapping.
> 
> 	That makes me wonder if this patch is going to mess things up,
> and if bond_slave_override should also use the skb_rx_queue_recorded, et
> al, functions.
> 

They could be use them, but I really dislike using functions with 'rx'
in the name for options that are clearly for transmit.  I would rather
get rid of access to queue_id or queue_mapping in the code in question.

How about something like this?  I have not fully tested this, but will
and would appreciate feedback from Phil or anyone else.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_main.c  |   11 ++++++-----
 drivers/net/bonding/bond_sysfs.c |    2 +-
 drivers/net/bonding/bonding.h    |   16 ++++++++++++++++
 include/linux/skbuff.h           |   15 +++++++++++++++
 net/core/dev.c                   |    4 ++--
 5 files changed, 40 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77e3c6a..02d8161 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4511,20 +4511,21 @@ static inline int bond_slave_override(struct bonding *bond,
 
 	read_lock(&bond->lock);
 
-	if (!BOND_IS_OK(bond) || !skb->queue_mapping)
+	if (!BOND_IS_OK(bond) || !skb_tx_queue_recorded(skb))
 		goto out;
 
 	/* Find out if any slaves have the same mapping as this skb. */
 	bond_for_each_slave(bond, check_slave, i) {
-		if (check_slave->queue_id == skb->queue_mapping) {
+		if (slave_tx_queue_recorded(check_slave) &&
+		    slave_get_tx_queue(check_slave) == skb_get_tx_queue(skb)) {
 			slave = check_slave;
 			break;
 		}
 	}
 
 	/* If the slave isn't UP, use default transmit policy. */
-	if (slave && slave->queue_id && IS_UP(slave->dev) &&
-	    (slave->link == BOND_LINK_UP)) {
+	if (slave && slave_tx_queue_recorded(slave) &&
+	    IS_UP(slave->dev) && (slave->link == BOND_LINK_UP)) {
 		res = bond_dev_queue_xmit(bond, skb, slave->dev);
 	}
 
@@ -4541,7 +4542,7 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
 	 * skb_tx_hash and will put the skbs in the queue we expect on their
 	 * way down to the bonding driver.
 	 */
-	return skb->queue_mapping;
+	return skb_tx_queue_recorded(skb) ? skb_get_tx_queue(skb) : 0;
 }
 
 static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 72bb0f6..b3bc092 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1499,7 +1499,7 @@ static ssize_t bonding_store_queue_id(struct device *d,
 	/* Check buffer length, valid ifname and queue id */
 	if (strlen(buffer) > IFNAMSIZ ||
 	    !dev_valid_name(buffer) ||
-	    qid > bond->params.tx_queues)
+	    qid >= bond->params.tx_queues)
 		goto err_no_cmd;
 
 	/* Get the pointer to that interface if it exists */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 31fe980..75b5798 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -422,4 +422,20 @@ static inline void bond_unregister_ipv6_notifier(void)
 }
 #endif
 
+static inline void slave_record_tx_queue(struct slave *slave, u16 tx_queue)
+{
+	slave->queue_id = tx_queue + 1;
+}
+
+static inline u16 slave_get_tx_queue(const struct slave *slave)
+{
+	return slave->queue_id - 1;
+}
+
+static inline bool slave_tx_queue_recorded(const struct slave *slave)
+{
+	return slave->queue_id != 0;
+}
+
+
 #endif /* _LINUX_BONDING_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 31f02d0..49d101c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2194,6 +2194,21 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 	return skb->queue_mapping != 0;
 }
 
+static inline void skb_record_tx_queue(struct sk_buff *skb, u16 tx_queue)
+{
+	skb->queue_mapping = tx_queue + 1;
+}
+
+static inline u16 skb_get_tx_queue(const struct sk_buff *skb)
+{
+	return skb->queue_mapping - 1;
+}
+
+static inline bool skb_tx_queue_recorded(const struct sk_buff *skb)
+{
+	return skb->queue_mapping != 0;
+}
+
 extern u16 __skb_tx_hash(const struct net_device *dev,
 			 const struct sk_buff *skb,
 			 unsigned int num_tx_queues);
diff --git a/net/core/dev.c b/net/core/dev.c
index a413276..50aa490 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2211,8 +2211,8 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 	u16 qoffset = 0;
 	u16 qcount = num_tx_queues;
 
-	if (skb_rx_queue_recorded(skb)) {
-		hash = skb_get_rx_queue(skb);
+	if (skb_tx_queue_recorded(skb)) {
+		hash = skb_get_tx_queue(skb);
 		while (unlikely(hash >= num_tx_queues))
 			hash -= num_tx_queues;
 		return hash;
