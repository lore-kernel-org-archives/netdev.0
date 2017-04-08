From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next v2] can: initial support for network namespaces
Date: Sat, 8 Apr 2017 20:10:58 +0200
Message-ID: <defa959f-46c3-4dfb-ab3b-26bab051dd53@hartkopp.net>
References: <63994a75-c87d-e9d4-f002-afe14127d6a0@kicherer.org>
 <17a0be47-6b8b-1c4f-308b-b09d6f66b86d@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------4AA74DBA81D157914708766E"
To: Mario Kicherer <dev@kicherer.org>, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <17a0be47-6b8b-1c4f-308b-b09d6f66b86d@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------4AA74DBA81D157914708766E
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Mario,

I started to convert the statistics ... but there's some code adaption 
missing in proc.c

Is this the right way to start?

diff --git a/include/net/netns/can.h b/include/net/netns/can.h
index e8beba772f1a..a8866ae1788f 100644
--- a/include/net/netns/can.h
+++ b/include/net/netns/can.h
@@ -8,6 +8,8 @@
  #include <linux/spinlock.h>

  struct dev_rcv_lists;
+struct s_stats;
+struct s_pstats;

  struct netns_can {
  #if IS_ENABLED(CONFIG_PROC_FS)
@@ -26,6 +28,8 @@ struct netns_can {
  	/* receive filters subscribed for 'all' CAN devices */
  	struct dev_rcv_lists *can_rx_alldev_list;
  	spinlock_t can_rcvlists_lock;
+	struct s_stats *can_stats;	/* packet statistics */
+	struct s_pstats *can_pstats;	/* receive list statistics */
  };

  #endif /* __NETNS_CAN_H__ */
diff --git a/net/can/af_can.c b/net/can/af_can.c
index abf7d854a94d..db35d6a5ac26 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -84,8 +84,6 @@ static const struct can_proto *proto_tab[CAN_NPROTO] 
__read_mostly;
  static DEFINE_MUTEX(proto_tab_lock);

  struct timer_list can_stattimer;   /* timer for statistics update */
-struct s_stats    can_stats;       /* packet statistics */
-struct s_pstats   can_pstats;      /* receive list statistics */

  static atomic_t skbcounter = ATOMIC_INIT(0);

@@ -223,6 +221,7 @@ int can_send(struct sk_buff *skb, int loop)
  {
  	struct sk_buff *newskb = NULL;
  	struct canfd_frame *cfd = (struct canfd_frame *)skb->data;
+	struct net *net = dev_net(skb->dev);
  	int err = -EINVAL;

  	if (skb->len == CAN_MTU) {
@@ -311,8 +310,8 @@ int can_send(struct sk_buff *skb, int loop)
  		netif_rx_ni(newskb);

  	/* update statistics */
-	can_stats.tx_frames++;
-	can_stats.tx_frames_delta++;
+	net->can.can_stats->tx_frames++;
+	net->can.can_stats->tx_frames_delta++;

  	return 0;

@@ -501,9 +500,9 @@ int can_rx_register(struct net *net, struct 
net_device *dev, canid_t can_id,
  		hlist_add_head_rcu(&r->list, rl);
  		d->entries++;

-		can_pstats.rcv_entries++;
-		if (can_pstats.rcv_entries_max < can_pstats.rcv_entries)
-			can_pstats.rcv_entries_max = can_pstats.rcv_entries;
+		net->can.can_pstats->rcv_entries++;
+		if (net->can.can_pstats->rcv_entries_max < 
net->can.can_pstats->rcv_entries)
+			net->can.can_pstats->rcv_entries_max = net->can.can_pstats->rcv_entries;
  	} else {
  		kmem_cache_free(rcv_cache, r);
  		err = -ENODEV;
@@ -591,8 +590,8 @@ void can_rx_unregister(struct net *net, struct 
net_device *dev, canid_t can_id,
  	hlist_del_rcu(&r->list);
  	d->entries--;

-	if (can_pstats.rcv_entries > 0)
-		can_pstats.rcv_entries--;
+	if (net->can.can_pstats->rcv_entries > 0)
+		net->can.can_pstats->rcv_entries--;

  	/* remove device structure requested by NETDEV_UNREGISTER */
  	if (d->remove_on_zero_entries && !d->entries) {
@@ -686,11 +685,12 @@ static int can_rcv_filter(struct dev_rcv_lists *d, 
struct sk_buff *skb)
  static void can_receive(struct sk_buff *skb, struct net_device *dev)
  {
  	struct dev_rcv_lists *d;
+	struct net *net = dev_net(dev);
  	int matches;

  	/* update statistics */
-	can_stats.rx_frames++;
-	can_stats.rx_frames_delta++;
+	net->can.can_stats->rx_frames++;
+	net->can.can_stats->rx_frames_delta++;

  	/* create non-zero unique skb identifier together with *skb */
  	while (!(can_skb_prv(skb)->skbcnt))
@@ -699,10 +699,10 @@ static void can_receive(struct sk_buff *skb, 
struct net_device *dev)
  	rcu_read_lock();

  	/* deliver the packet to sockets listening on all devices */
-	matches = can_rcv_filter(dev_net(dev)->can.can_rx_alldev_list, skb);
+	matches = can_rcv_filter(net->can.can_rx_alldev_list, skb);

  	/* find receive list for this device */
-	d = find_dev_rcv_lists(dev_net(dev), dev);
+	d = find_dev_rcv_lists(net, dev);
  	if (d)
  		matches += can_rcv_filter(d, skb);

@@ -712,8 +712,8 @@ static void can_receive(struct sk_buff *skb, struct 
net_device *dev)
  	consume_skb(skb);

  	if (matches > 0) {
-		can_stats.matches++;
-		can_stats.matches_delta++;
+		net->can.can_stats->matches++;
+		net->can.can_stats->matches_delta++;
  	}
  }

@@ -878,6 +878,9 @@ static int can_pernet_init(struct net *net)
  	net->can.can_rx_alldev_list =
  		kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL);

+	net->can.can_stats = kzalloc(sizeof(struct s_stats), GFP_KERNEL);
+	net->can.can_pstats = kzalloc(sizeof(struct s_pstats), GFP_KERNEL);
+
  	if (IS_ENABLED(CONFIG_PROC_FS))
  		can_init_proc(net);

diff --git a/net/can/af_can.h b/net/can/af_can.h
index f273c9d9b129..10d46bd2e9ea 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -110,9 +110,6 @@ struct s_pstats {
  	unsigned long rcv_entries_max;
  };

-/* receive filters subscribed for 'all' CAN devices */
-extern struct dev_rcv_lists can_rx_alldev_list;
-
  /* function prototypes for the CAN networklayer procfs (proc.c) */
  void can_init_proc(struct net *net);
  void can_remove_proc(struct net *net);
@@ -120,8 +117,5 @@ void can_stat_update(unsigned long data);

  /* structures and variables from af_can.c needed in proc.c for reading */
  extern struct timer_list can_stattimer;    /* timer for statistics 
update */
-extern struct s_stats    can_stats;        /* packet statistics */
-extern struct s_pstats   can_pstats;       /* receive list statistics */
-extern struct hlist_head can_rx_dev_list;  /* rx dispatcher structures */

  #endif /* AF_CAN_H */


On 04/08/2017 07:24 PM, Oliver Hartkopp wrote:
> Hello Mario,
>
> unfortunately Marc pushed this patch before I finally was able to review
> it ... :-(
>
> Some questions:
>
> On 02/21/2017 12:19 PM, Mario Kicherer wrote:
>> This patch adds initial support for network namespaces. The changes only
>> enable support in the CAN raw, proc and af_can code. GW and BCM still
>> have their checks that ensure that they are used only from the main
>> namespace.
>>
>> The patch boils down to moving the global structures, i.e. the global
>> filter list and their /proc stats, into a per-namespace structure and
>> passing
>> around the corresponding "struct net" in a lot of different places.
>
> (..)
>
>> diff --git a/include/net/netns/can.h b/include/net/netns/can.h
>> new file mode 100644
>> index 0000000..e8beba7
>> --- /dev/null
>> +++ b/include/net/netns/can.h
>> @@ -0,0 +1,31 @@
>> +/*
>> + * can in net namespaces
>> + */
>> +
>> +#ifndef __NETNS_CAN_H__
>> +#define __NETNS_CAN_H__
>> +
>> +#include <linux/spinlock.h>
>> +
>> +struct dev_rcv_lists;
>> +
>> +struct netns_can {
>> +#if IS_ENABLED(CONFIG_PROC_FS)
>> +    struct proc_dir_entry *proc_dir;
>> +    struct proc_dir_entry *pde_version;
>> +    struct proc_dir_entry *pde_stats;
>> +    struct proc_dir_entry *pde_reset_stats;
>> +    struct proc_dir_entry *pde_rcvlist_all;
>> +    struct proc_dir_entry *pde_rcvlist_fil;
>> +    struct proc_dir_entry *pde_rcvlist_inv;
>> +    struct proc_dir_entry *pde_rcvlist_sff;
>> +    struct proc_dir_entry *pde_rcvlist_eff;
>> +    struct proc_dir_entry *pde_rcvlist_err;
>> +#endif
>> +
>> +    /* receive filters subscribed for 'all' CAN devices */
>> +    struct dev_rcv_lists *can_rx_alldev_list;
>> +    spinlock_t can_rcvlists_lock;
>
> You didn't include the statistics here:
>
> +       struct s_stats *can_stats;      /* packet statistics */
> +       struct s_pstats *can_pstats;    /* receive list statistics */
>
> which need to be per-net too, right?
>
> (..)
>> @@ -877,6 +871,41 @@ static int can_notifier(struct notifier_block
>> *nb, unsigned long msg,
>>      return NOTIFY_DONE;
>>  }
>>
>> +int can_pernet_init(struct net *net)
>> +{
>> +    net->can.can_rcvlists_lock =
>> +        __SPIN_LOCK_UNLOCKED(net->can.can_rcvlists_lock);
>> +    net->can.can_rx_alldev_list =
>> +        kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL);
>> +    memset(net->can.can_rx_alldev_list, 0, sizeof(struct
>> dev_rcv_lists));
>> +
>> +    if (IS_ENABLED(CONFIG_PROC_FS))
>> +        can_init_proc(net);
>> +
>> +    return 0;
>> +}
>> +
>> +void can_pernet_exit(struct net *net)
>> +{
>> +    struct net_device *dev;
>> +
>> +    if (IS_ENABLED(CONFIG_PROC_FS))
>> +        can_remove_proc(net);
>> +
>> +    /* remove created dev_rcv_lists from still registered CAN devices */
>> +    rcu_read_lock();
>> +    for_each_netdev_rcu(net, dev) {
>> +        if (dev->type == ARPHRD_CAN && dev->ml_priv) {
>> +            struct dev_rcv_lists *d = dev->ml_priv;
>> +
>> +            BUG_ON(d->entries);
>> +            kfree(d);
>> +            dev->ml_priv = NULL;
>> +        }
>> +    }
>> +    rcu_read_unlock();
>
> You do a kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL) in
> can_pernet_init().
>
> Doesn't it need a kfree(net->can.can_rx_alldev_list) then??
>
> Regards,
> Oliver
> --
> To unsubscribe from this list: send the line "unsubscribe linux-can" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--------------4AA74DBA81D157914708766E
Content-Type: text/x-patch;
 name="can_netns_stats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="can_netns_stats.patch"

diff --git a/include/net/netns/can.h b/include/net/netns/can.h
index e8beba772f1a..a8866ae1788f 100644
--- a/include/net/netns/can.h
+++ b/include/net/netns/can.h
@@ -8,6 +8,8 @@
 #include <linux/spinlock.h>
 
 struct dev_rcv_lists;
+struct s_stats;
+struct s_pstats;
 
 struct netns_can {
 #if IS_ENABLED(CONFIG_PROC_FS)
@@ -26,6 +28,8 @@ struct netns_can {
 	/* receive filters subscribed for 'all' CAN devices */
 	struct dev_rcv_lists *can_rx_alldev_list;
 	spinlock_t can_rcvlists_lock;
+	struct s_stats *can_stats;	/* packet statistics */
+	struct s_pstats *can_pstats;	/* receive list statistics */
 };
 
 #endif /* __NETNS_CAN_H__ */
diff --git a/net/can/af_can.c b/net/can/af_can.c
index abf7d854a94d..db35d6a5ac26 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -84,8 +84,6 @@ static const struct can_proto *proto_tab[CAN_NPROTO] __read_mostly;
 static DEFINE_MUTEX(proto_tab_lock);
 
 struct timer_list can_stattimer;   /* timer for statistics update */
-struct s_stats    can_stats;       /* packet statistics */
-struct s_pstats   can_pstats;      /* receive list statistics */
 
 static atomic_t skbcounter = ATOMIC_INIT(0);
 
@@ -223,6 +221,7 @@ int can_send(struct sk_buff *skb, int loop)
 {
 	struct sk_buff *newskb = NULL;
 	struct canfd_frame *cfd = (struct canfd_frame *)skb->data;
+	struct net *net = dev_net(skb->dev);
 	int err = -EINVAL;
 
 	if (skb->len == CAN_MTU) {
@@ -311,8 +310,8 @@ int can_send(struct sk_buff *skb, int loop)
 		netif_rx_ni(newskb);
 
 	/* update statistics */
-	can_stats.tx_frames++;
-	can_stats.tx_frames_delta++;
+	net->can.can_stats->tx_frames++;
+	net->can.can_stats->tx_frames_delta++;
 
 	return 0;
 
@@ -501,9 +500,9 @@ int can_rx_register(struct net *net, struct net_device *dev, canid_t can_id,
 		hlist_add_head_rcu(&r->list, rl);
 		d->entries++;
 
-		can_pstats.rcv_entries++;
-		if (can_pstats.rcv_entries_max < can_pstats.rcv_entries)
-			can_pstats.rcv_entries_max = can_pstats.rcv_entries;
+		net->can.can_pstats->rcv_entries++;
+		if (net->can.can_pstats->rcv_entries_max < net->can.can_pstats->rcv_entries)
+			net->can.can_pstats->rcv_entries_max = net->can.can_pstats->rcv_entries;
 	} else {
 		kmem_cache_free(rcv_cache, r);
 		err = -ENODEV;
@@ -591,8 +590,8 @@ void can_rx_unregister(struct net *net, struct net_device *dev, canid_t can_id,
 	hlist_del_rcu(&r->list);
 	d->entries--;
 
-	if (can_pstats.rcv_entries > 0)
-		can_pstats.rcv_entries--;
+	if (net->can.can_pstats->rcv_entries > 0)
+		net->can.can_pstats->rcv_entries--;
 
 	/* remove device structure requested by NETDEV_UNREGISTER */
 	if (d->remove_on_zero_entries && !d->entries) {
@@ -686,11 +685,12 @@ static int can_rcv_filter(struct dev_rcv_lists *d, struct sk_buff *skb)
 static void can_receive(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dev_rcv_lists *d;
+	struct net *net = dev_net(dev);
 	int matches;
 
 	/* update statistics */
-	can_stats.rx_frames++;
-	can_stats.rx_frames_delta++;
+	net->can.can_stats->rx_frames++;
+	net->can.can_stats->rx_frames_delta++;
 
 	/* create non-zero unique skb identifier together with *skb */
 	while (!(can_skb_prv(skb)->skbcnt))
@@ -699,10 +699,10 @@ static void can_receive(struct sk_buff *skb, struct net_device *dev)
 	rcu_read_lock();
 
 	/* deliver the packet to sockets listening on all devices */
-	matches = can_rcv_filter(dev_net(dev)->can.can_rx_alldev_list, skb);
+	matches = can_rcv_filter(net->can.can_rx_alldev_list, skb);
 
 	/* find receive list for this device */
-	d = find_dev_rcv_lists(dev_net(dev), dev);
+	d = find_dev_rcv_lists(net, dev);
 	if (d)
 		matches += can_rcv_filter(d, skb);
 
@@ -712,8 +712,8 @@ static void can_receive(struct sk_buff *skb, struct net_device *dev)
 	consume_skb(skb);
 
 	if (matches > 0) {
-		can_stats.matches++;
-		can_stats.matches_delta++;
+		net->can.can_stats->matches++;
+		net->can.can_stats->matches_delta++;
 	}
 }
 
@@ -878,6 +878,9 @@ static int can_pernet_init(struct net *net)
 	net->can.can_rx_alldev_list =
 		kzalloc(sizeof(struct dev_rcv_lists), GFP_KERNEL);
 
+	net->can.can_stats = kzalloc(sizeof(struct s_stats), GFP_KERNEL);
+	net->can.can_pstats = kzalloc(sizeof(struct s_pstats), GFP_KERNEL);
+
 	if (IS_ENABLED(CONFIG_PROC_FS))
 		can_init_proc(net);
 
diff --git a/net/can/af_can.h b/net/can/af_can.h
index f273c9d9b129..10d46bd2e9ea 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -110,9 +110,6 @@ struct s_pstats {
 	unsigned long rcv_entries_max;
 };
 
-/* receive filters subscribed for 'all' CAN devices */
-extern struct dev_rcv_lists can_rx_alldev_list;
-
 /* function prototypes for the CAN networklayer procfs (proc.c) */
 void can_init_proc(struct net *net);
 void can_remove_proc(struct net *net);
@@ -120,8 +117,5 @@ void can_stat_update(unsigned long data);
 
 /* structures and variables from af_can.c needed in proc.c for reading */
 extern struct timer_list can_stattimer;    /* timer for statistics update */
-extern struct s_stats    can_stats;        /* packet statistics */
-extern struct s_pstats   can_pstats;       /* receive list statistics */
-extern struct hlist_head can_rx_dev_list;  /* rx dispatcher structures */
 
 #endif /* AF_CAN_H */

--------------4AA74DBA81D157914708766E--
