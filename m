From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v8 1/6] openvswitch: Allow each vport to have an array of 'port_id's.
Date: Tue, 22 Jul 2014 11:34:23 -0700
Message-ID: <1406054063-1642-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Alex Wang <alexw@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog034.obsmtp.com ([74.125.150.108]:59674 "HELO
	na6sys009bog034.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751047AbaGVSmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 14:42:17 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so78941pab.2
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 11:42:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Wang <alexw@nicira.com>

In order to allow handlers directly read upcalls from datapath,
we need to support per-handler netlink socket for each vport in
datapath.  This commit makes this happen.  Also, it is guaranteed
to be backward compatible with previous branch.

Signed-off-by: Alex Wang <alexw@nicira.com>
Acked-by: Thomas Graf <tgraf@redhat.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/uapi/linux/openvswitch.h |  13 +++--
 net/openvswitch/datapath.c       |  23 ++++++---
 net/openvswitch/vport.c          | 101 ++++++++++++++++++++++++++++++++++++++-
 net/openvswitch/vport.h          |  27 +++++++++--
 4 files changed, 148 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 0b979ee..a794d1d 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -118,6 +118,9 @@ struct ovs_vport_stats {
 /* Allow last Netlink attribute to be unaligned */
 #define OVS_DP_F_UNALIGNED	(1 << 0)
 
+/* Allow datapath to associate multiple Netlink PIDs to each vport */
+#define OVS_DP_F_VPORT_PIDS	(1 << 1)
+
 /* Fixed logical ports. */
 #define OVSP_LOCAL      ((__u32)0)
 
@@ -203,9 +206,10 @@ enum ovs_vport_type {
  * this is the name of the network device.  Maximum length %IFNAMSIZ-1 bytes
  * plus a null terminator.
  * @OVS_VPORT_ATTR_OPTIONS: Vport-specific configuration information.
- * @OVS_VPORT_ATTR_UPCALL_PID: The Netlink socket in userspace that
- * OVS_PACKET_CMD_MISS upcalls will be directed to for packets received on
- * this port.  A value of zero indicates that upcalls should not be sent.
+ * @OVS_VPORT_ATTR_UPCALL_PID: The array of Netlink socket pids in userspace
+ * among which OVS_PACKET_CMD_MISS upcalls will be distributed for packets
+ * received on this port.  If this is a single-element array of value 0,
+ * upcalls should not be sent.
  * @OVS_VPORT_ATTR_STATS: A &struct ovs_vport_stats giving statistics for
  * packets sent or received through the vport.
  *
@@ -228,7 +232,8 @@ enum ovs_vport_attr {
 	OVS_VPORT_ATTR_TYPE,	/* u32 OVS_VPORT_TYPE_* constant. */
 	OVS_VPORT_ATTR_NAME,	/* string name, up to IFNAMSIZ bytes long */
 	OVS_VPORT_ATTR_OPTIONS, /* nested attributes, varies by vport type */
-	OVS_VPORT_ATTR_UPCALL_PID, /* u32 Netlink PID to receive upcalls */
+	OVS_VPORT_ATTR_UPCALL_PID, /* array of u32 Netlink socket PIDs for */
+				/* receiving upcalls */
 	OVS_VPORT_ATTR_STATS,	/* struct ovs_vport_stats */
 	__OVS_VPORT_ATTR_MAX
 };
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 20f59b6..65a8e5c 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -266,7 +266,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 		upcall.cmd = OVS_PACKET_CMD_MISS;
 		upcall.key = &key;
 		upcall.userdata = NULL;
-		upcall.portid = p->upcall_portid;
+		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		ovs_dp_upcall(dp, skb, &upcall);
 		consume_skb(skb);
 		stats_counter = &stats->n_missed;
@@ -1373,7 +1373,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	parms.options = NULL;
 	parms.dp = dp;
 	parms.port_no = OVSP_LOCAL;
-	parms.upcall_portid = nla_get_u32(a[OVS_DP_ATTR_UPCALL_PID]);
+	parms.upcall_portids = a[OVS_DP_ATTR_UPCALL_PID];
 
 	ovs_dp_change(dp, a);
 
@@ -1632,8 +1632,8 @@ static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
 
 	if (nla_put_u32(skb, OVS_VPORT_ATTR_PORT_NO, vport->port_no) ||
 	    nla_put_u32(skb, OVS_VPORT_ATTR_TYPE, vport->ops->type) ||
-	    nla_put_string(skb, OVS_VPORT_ATTR_NAME, vport->ops->get_name(vport)) ||
-	    nla_put_u32(skb, OVS_VPORT_ATTR_UPCALL_PID, vport->upcall_portid))
+	    nla_put_string(skb, OVS_VPORT_ATTR_NAME,
+			   vport->ops->get_name(vport)))
 		goto nla_put_failure;
 
 	ovs_vport_get_stats(vport, &vport_stats);
@@ -1641,6 +1641,9 @@ static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
 		    &vport_stats))
 		goto nla_put_failure;
 
+	if (ovs_vport_get_upcall_portids(vport, skb))
+		goto nla_put_failure;
+
 	err = ovs_vport_get_options(vport, skb);
 	if (err == -EMSGSIZE)
 		goto error;
@@ -1762,7 +1765,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	parms.options = a[OVS_VPORT_ATTR_OPTIONS];
 	parms.dp = dp;
 	parms.port_no = port_no;
-	parms.upcall_portid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
+	parms.upcall_portids = a[OVS_VPORT_ATTR_UPCALL_PID];
 
 	vport = new_vport(&parms);
 	err = PTR_ERR(vport);
@@ -1812,8 +1815,14 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 			goto exit_unlock_free;
 	}
 
-	if (a[OVS_VPORT_ATTR_UPCALL_PID])
-		vport->upcall_portid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
+
+	if (a[OVS_VPORT_ATTR_UPCALL_PID]) {
+		struct nlattr *ids = a[OVS_VPORT_ATTR_UPCALL_PID];
+
+		err = ovs_vport_set_upcall_portids(vport, ids);
+		if (err)
+			goto exit_unlock_free;
+	}
 
 	err = ovs_vport_cmd_fill_info(vport, reply, info->snd_portid,
 				      info->snd_seq, 0, OVS_VPORT_CMD_NEW);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 42c0f4a..702fb21 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -134,10 +134,12 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 
 	vport->dp = parms->dp;
 	vport->port_no = parms->port_no;
-	vport->upcall_portid = parms->upcall_portid;
 	vport->ops = ops;
 	INIT_HLIST_NODE(&vport->dp_hash_node);
 
+	if (ovs_vport_set_upcall_portids(vport, parms->upcall_portids))
+		return ERR_PTR(-EINVAL);
+
 	vport->percpu_stats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!vport->percpu_stats) {
 		kfree(vport);
@@ -161,6 +163,10 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
  */
 void ovs_vport_free(struct vport *vport)
 {
+	/* vport is freed from RCU callback or error path, Therefore
+	 * it is safe to use raw dereference.
+	 */
+	kfree(rcu_dereference_raw(vport->upcall_portids));
 	free_percpu(vport->percpu_stats);
 	kfree(vport);
 }
@@ -327,6 +333,99 @@ int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
 }
 
 /**
+ *	ovs_vport_set_upcall_portids - set upcall portids of @vport.
+ *
+ * @vport: vport to modify.
+ * @ids: new configuration, an array of port ids.
+ *
+ * Sets the vport's upcall_portids to @ids.
+ *
+ * Returns 0 if successful, -EINVAL if @ids is zero length or cannot be parsed
+ * as an array of U32.
+ *
+ * Must be called with ovs_mutex.
+ */
+int ovs_vport_set_upcall_portids(struct vport *vport,  struct nlattr *ids)
+{
+	struct vport_portids *old, *vport_portids;
+
+	if (!nla_len(ids) || nla_len(ids) % sizeof(u32))
+		return -EINVAL;
+
+	old = ovsl_dereference(vport->upcall_portids);
+
+	vport_portids = kmalloc(sizeof(*vport_portids) + nla_len(ids),
+				GFP_KERNEL);
+	if (!vport_portids)
+		return -ENOMEM;
+
+	vport_portids->n_ids = nla_len(ids) / sizeof(u32);
+	vport_portids->rn_ids = reciprocal_value(vport_portids->n_ids);
+	nla_memcpy(vport_portids->ids, ids, nla_len(ids));
+
+	rcu_assign_pointer(vport->upcall_portids, vport_portids);
+
+	if (old)
+		kfree_rcu(old, rcu);
+	return 0;
+}
+
+/**
+ *	ovs_vport_get_upcall_portids - get the upcall_portids of @vport.
+ *
+ * @vport: vport from which to retrieve the portids.
+ * @skb: sk_buff where portids should be appended.
+ *
+ * Retrieves the configuration of the given vport, appending the
+ * %OVS_VPORT_ATTR_UPCALL_PID attribute which is the array of upcall
+ * portids to @skb.
+ *
+ * Returns 0 if successful, -EMSGSIZE if @skb has insufficient room.
+ * If an error occurs, @skb is left unmodified.  Must be called with
+ * ovs_mutex or rcu_read_lock.
+ */
+int ovs_vport_get_upcall_portids(const struct vport *vport,
+				 struct sk_buff *skb)
+{
+	struct vport_portids *ids;
+
+	ids = rcu_dereference_ovsl(vport->upcall_portids);
+
+	if (vport->dp->user_features & OVS_DP_F_VPORT_PIDS)
+		return nla_put(skb, OVS_VPORT_ATTR_UPCALL_PID,
+			       ids->n_ids * sizeof(u32), (void *)ids->ids);
+	else
+		return nla_put_u32(skb, OVS_VPORT_ATTR_UPCALL_PID, ids->ids[0]);
+}
+
+/**
+ *	ovs_vport_find_upcall_portid - find the upcall portid to send upcall.
+ *
+ * @vport: vport from which the missed packet is received.
+ * @skb: skb that the missed packet was received.
+ *
+ * Uses the skb_get_hash() to select the upcall portid to send the
+ * upcall.
+ *
+ * Returns the portid of the target socket.  Must be called with rcu_read_lock.
+ */
+u32 ovs_vport_find_upcall_portid(const struct vport *p, struct sk_buff *skb)
+{
+	struct vport_portids *ids;
+	u32 ids_index;
+	u32 hash;
+
+	ids = rcu_dereference(p->upcall_portids);
+
+	if (ids->n_ids == 1 && ids->ids[0] == 0)
+		return 0;
+
+	hash = skb_get_hash(skb);
+	ids_index = hash - ids->n_ids * reciprocal_divide(hash, ids->rn_ids);
+	return ids->ids[ids_index];
+}
+
+/**
  *	ovs_vport_receive - pass up received packet to the datapath for processing
  *
  * @vport: vport that received the packet
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 8d721e6..35f89d8 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -23,6 +23,7 @@
 #include <linux/list.h>
 #include <linux/netlink.h>
 #include <linux/openvswitch.h>
+#include <linux/reciprocal_div.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/u64_stats_sync.h>
@@ -52,6 +53,10 @@ void ovs_vport_get_stats(struct vport *, struct ovs_vport_stats *);
 int ovs_vport_set_options(struct vport *, struct nlattr *options);
 int ovs_vport_get_options(const struct vport *, struct sk_buff *);
 
+int ovs_vport_set_upcall_portids(struct vport *, struct nlattr *pids);
+int ovs_vport_get_upcall_portids(const struct vport *, struct sk_buff *);
+u32 ovs_vport_find_upcall_portid(const struct vport *, struct sk_buff *);
+
 int ovs_vport_send(struct vport *, struct sk_buff *);
 
 /* The following definitions are for implementers of vport devices: */
@@ -62,13 +67,27 @@ struct vport_err_stats {
 	u64 tx_dropped;
 	u64 tx_errors;
 };
+/**
+ * struct vport_portids - array of netlink portids of a vport.
+ *                        must be protected by rcu.
+ * @rn_ids: The reciprocal value of @n_ids.
+ * @rcu: RCU callback head for deferred destruction.
+ * @n_ids: Size of @ids array.
+ * @ids: Array storing the Netlink socket pids to be used for packets received
+ * on this port that miss the flow table.
+ */
+struct vport_portids {
+	struct reciprocal_value rn_ids;
+	struct rcu_head rcu;
+	u32 n_ids;
+	u32 ids[];
+};
 
 /**
  * struct vport - one port within a datapath
  * @rcu: RCU callback head for deferred destruction.
  * @dp: Datapath to which this port belongs.
- * @upcall_portid: The Netlink port to use for packets received on this port that
- * miss the flow table.
+ * @upcall_portids: RCU protected 'struct vport_portids'.
  * @port_no: Index into @dp's @ports array.
  * @hash_node: Element in @dev_table hash table in vport.c.
  * @dp_hash_node: Element in @datapath->ports hash table in datapath.c.
@@ -80,7 +99,7 @@ struct vport_err_stats {
 struct vport {
 	struct rcu_head rcu;
 	struct datapath	*dp;
-	u32 upcall_portid;
+	struct vport_portids __rcu *upcall_portids;
 	u16 port_no;
 
 	struct hlist_node hash_node;
@@ -111,7 +130,7 @@ struct vport_parms {
 	/* For ovs_vport_alloc(). */
 	struct datapath *dp;
 	u16 port_no;
-	u32 upcall_portid;
+	struct nlattr *upcall_portids;
 };
 
 /**
-- 
1.9.3
