From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next] net: squash ->rx_handler and
 ->rx_handler_data into single rcu pointer
Date: Sat, 30 Mar 2013 20:32:10 +0100
Message-ID: <20130330193210.GD1544@minipsycho.orion>
References: <1364659034-7049-1-git-send-email-jiri@resnulli.us>
	<f72ccc9e-b09e-4abb-a0ce-a6516138b25c@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, paulmck-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	streeter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nicolas.2p.debian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <f72ccc9e-b09e-4abb-a0ce-a6516138b25c-2ueSQiBKiTY7tOexoI0I+QC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Sat, Mar 30, 2013 at 08:24:04PM CET, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org wrote:
>
>
>Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org> wrote:
>
>>No need to have two pointers in struct netdevice for rx_handler func
>>and
>>priv data. Just embed rx_handler structure into driver port_priv and
>>have ->func pointer there. This introduces no performance penalty,
>>reduces struct netdevice by one pointer and reduces number of needed
>>rcu_dereference calls from 2 to 1.
>>
>>Note this also fixes the race bug pointed out by Steven Rostedt and
>>fixed by patch "[PATCH] net: add a synchronize_net() in
>>netdev_rx_handler_unregister()" by Eric Dumazet. This is based on
>>current net-next tree where the patch is not applied yet.
>>I can rebase it on whatever tree/state, just say so.
>>
>>Smoke tested with all drivers who use rx_handler.
>>
>>Reported-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
>>Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>>---
> +
>>+
>>--- a/net/core/dev.c
>>+++ b/net/core/dev.c
>>@@ -3296,10 +3296,23 @@ out:
>> #endif
>> 
>> /**
>>+ *	netdev_rx_handler_init - init receive handler structure
>>+ *	@rx_handler: receive handler to init
>>+ *	@func: receive handler function
>>+ *
>>+ *	Inits receive handler structure.
>>+ */
>>+void netdev_rx_handler_init(struct netdev_rx_handler *rx_handler,
>>+			    rx_handler_func_t *func)
>>+{
>>+	rx_handler->func = func;
>>+}
>>+EXPORT_SYMBOL_GPL(netdev_rx_handler_init);
>>+
>>+/**
>>  *	netdev_rx_handler_register - register receive handler
>>  *	@dev: device to register a handler for
>>  *	@rx_handler: receive handler to register
>>- *	@rx_handler_data: data pointer that is used by rx handler
>>  *
>>  *	Register a receive hander for a device. This handler will then be
>>  *	called from __netif_receive_skb. A negative errno code is returned
>>@@ -3310,15 +3323,13 @@ out:
>> *	For a general description of rx_handler, see enum rx_handler_result.
>>  */
>> int netdev_rx_handler_register(struct net_device *dev,
>>-			       rx_handler_func_t *rx_handler,
>>-			       void *rx_handler_data)
>>+			       struct netdev_rx_handler *rx_handler)
>> {
>> 	ASSERT_RTNL();
>> 
>> 	if (dev->rx_handler)
>> 		return -EBUSY;
>> 
>>-	rcu_assign_pointer(dev->rx_handler_data, rx_handler_data);
>> 	rcu_assign_pointer(dev->rx_handler, rx_handler);
>> 
>> 	return 0;
>>@@ -3338,7 +3349,6 @@ void netdev_rx_handler_unregister(struct
>>net_device *dev)
>> 
>> 	ASSERT_RTNL();
>> 	RCU_INIT_POINTER(dev->rx_handler, NULL);
>>-	RCU_INIT_POINTER(dev->rx_handler_data, NULL);
>> }
>> EXPORT_SYMBOL_GPL(netdev_rx_handler_unregister);
>> 
>>@@ -3362,7 +3372,7 @@ static bool skb_pfmemalloc_protocol(struct
>>sk_buff *skb)
>>static int __netif_receive_skb_core(struct sk_buff *skb, bool
>>pfmemalloc)
>> {
>> 	struct packet_type *ptype, *pt_prev;
>>-	rx_handler_func_t *rx_handler;
>>+	struct netdev_rx_handler *rx_handler;
>> 	struct net_device *orig_dev;
>> 	struct net_device *null_or_dev;
>> 	bool deliver_exact = false;
>>@@ -3445,7 +3455,7 @@ ncls:
>> 			ret = deliver_skb(skb, pt_prev, orig_dev);
>> 			pt_prev = NULL;
>> 		}
>>-		switch (rx_handler(&skb)) {
>>+		switch (rx_handler->func(&skb, rx_handler)) {
>
>
>This doesn't solve anything. The CPU can be executing func when you set it to null.  Then you have the same problem.  This patch shows you still don't understand the bug.  

rx_handler->func is never set to NULL and is valid for all rx_handler (port_priv)
lifetime.

>
>
>-- Steve
>
>
>> 		case RX_HANDLER_CONSUMED:
>> 			ret = NET_RX_SUCCESS;
>> 			goto unlock;
>>diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
>>index 5558350..5248f8e 100644
>>--- a/net/openvswitch/dp_notify.c
>>+++ b/net/openvswitch/dp_notify.c
>>@@ -32,7 +32,7 @@ static int dp_device_event(struct notifier_block
>>*unused, unsigned long event,
>> 	if (ovs_is_internal_dev(dev))
>> 		vport = ovs_internal_dev_get_vport(dev);
>> 	else
>>-		vport = ovs_netdev_get_vport(dev);
>>+		vport = ovs_netdev_get_vport_rtnl(dev);
>> 
>> 	if (!vport)
>> 		return NOTIFY_DONE;
>>diff --git a/net/openvswitch/vport-netdev.c
>>b/net/openvswitch/vport-netdev.c
>>index 2130d61..0ff6aa1 100644
>>--- a/net/openvswitch/vport-netdev.c
>>+++ b/net/openvswitch/vport-netdev.c
>>@@ -35,9 +35,6 @@
>> /* Must be called with rcu_read_lock. */
>>static void netdev_port_receive(struct vport *vport, struct sk_buff
>>*skb)
>> {
>>-	if (unlikely(!vport))
>>-		goto error;
>>-
>> 	if (unlikely(skb_warn_if_lro(skb)))
>> 		goto error;
>> 
>>@@ -57,7 +54,8 @@ error:
>> }
>> 
>> /* Called with rcu_read_lock and bottom-halves disabled. */
>>-static rx_handler_result_t netdev_frame_hook(struct sk_buff **pskb)
>>+static rx_handler_result_t
>>+netdev_frame_hook(struct sk_buff **pskb, struct netdev_rx_handler
>>*rx_handler)
>> {
>> 	struct sk_buff *skb = *pskb;
>> 	struct vport *vport;
>>@@ -65,7 +63,7 @@ static rx_handler_result_t netdev_frame_hook(struct
>>sk_buff **pskb)
>> 	if (unlikely(skb->pkt_type == PACKET_LOOPBACK))
>> 		return RX_HANDLER_PASS;
>> 
>>-	vport = ovs_netdev_get_vport(skb->dev);
>>+	vport = ovs_netdev_get_vport_by_rx_handler(rx_handler);
>> 
>> 	netdev_port_receive(vport, skb);
>> 
>>@@ -100,8 +98,8 @@ static struct vport *netdev_create(const struct
>>vport_parms *parms)
>> 		goto error_put;
>> 	}
>> 
>>-	err = netdev_rx_handler_register(netdev_vport->dev,
>>netdev_frame_hook,
>>-					 vport);
>>+	netdev_rx_handler_init(&vport->rx_handler, netdev_frame_hook);
>>+	err = netdev_rx_handler_register(netdev_vport->dev,
>>&vport->rx_handler);
>> 	if (err)
>> 		goto error_put;
>> 
>>@@ -185,16 +183,6 @@ error:
>> 	return 0;
>> }
>> 
>>-/* Returns null if this device is not attached to a datapath. */
>>-struct vport *ovs_netdev_get_vport(struct net_device *dev)
>>-{
>>-	if (likely(dev->priv_flags & IFF_OVS_DATAPATH))
>>-		return (struct vport *)
>>-			rcu_dereference_rtnl(dev->rx_handler_data);
>>-	else
>>-		return NULL;
>>-}
>>-
>> const struct vport_ops ovs_netdev_vport_ops = {
>> 	.type		= OVS_VPORT_TYPE_NETDEV,
>> 	.create		= netdev_create,
>>diff --git a/net/openvswitch/vport-netdev.h
>>b/net/openvswitch/vport-netdev.h
>>index 6478079..d3f1471 100644
>>--- a/net/openvswitch/vport-netdev.h
>>+++ b/net/openvswitch/vport-netdev.h
>>@@ -24,7 +24,21 @@
>> 
>> #include "vport.h"
>> 
>>-struct vport *ovs_netdev_get_vport(struct net_device *dev);
>>+#define ovs_netdev_vport_exists(dev) (dev->priv_flags &
>>IFF_OVS_DATAPATH)
>>+
>>+static inline struct vport *
>>+ovs_netdev_get_vport_by_rx_handler(const struct netdev_rx_handler
>>*rx_handler)
>>+{
>>+	return container_of(rx_handler, struct vport, rx_handler);
>>+}
>>+
>>+static inline struct vport *
>>+ovs_netdev_get_vport_rtnl(const struct net_device *dev)
>>+{
>>+	if (!ovs_netdev_vport_exists(dev))
>>+		return NULL;
>>+	return
>>ovs_netdev_get_vport_by_rx_handler(rtnl_dereference(dev->rx_handler));
>>+}
>> 
>> struct netdev_vport {
>> 	struct rcu_head rcu;
>>diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
>>index aee7d43..a7a07c0 100644
>>--- a/net/openvswitch/vport.h
>>+++ b/net/openvswitch/vport.h
>>@@ -67,6 +67,7 @@ struct vport_err_stats {
>> 
>> /**
>>  * struct vport - one port within a datapath
>>+ * @rx_handler: RX handler structure.
>>  * @rcu: RCU callback head for deferred destruction.
>>  * @dp: Datapath to which this port belongs.
>>* @upcall_portid: The Netlink port to use for packets received on this
>>port that
>>@@ -80,6 +81,7 @@ struct vport_err_stats {
>>  * @err_stats: Points to error statistics used and maintained by vport
>>  */
>> struct vport {
>>+	struct netdev_rx_handler rx_handler;
>> 	struct rcu_head rcu;
>> 	struct datapath	*dp;
>> 	u32 upcall_portid;
>
>-- 
>Sent from my Android phone with K-9 Mail. Please excuse my brevity.
