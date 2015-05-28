From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next] vlan: Add GRO support for non hardware accelerated vlan
Date: Thu, 28 May 2015 20:17:41 +0900
Message-ID: <1432811861-9976-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:41853 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753802AbbE1LSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 07:18:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently packets with non-hardware-accelerated vlan cannot be handled
by GRO. This causes low performance for 802.1ad and stacked vlan, as their
vlan tags are currently not stripped by hardware.

This patch adds GRO support for non-hardware-accelerated vlan and
improves receive performance of them.

Test Environment:
 vlan device (.1Q) on vlan device (.1ad) on ixgbe (82599)

Result:

- Before

$ netperf -t TCP_STREAM -H 192.168.20.2 -l 60
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    60.00    5233.17

Rx side CPU usage:
  %usr      %sys      %irq     %soft     %idle
  0.27     58.03      0.00     41.70      0.00

- After

$ netperf -t TCP_STREAM -H 192.168.20.2 -l 60
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    60.00    7586.85

Rx side CPU usage:
  %usr      %sys      %irq     %soft     %idle
  0.50     25.83      0.00     59.53     14.14

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/8021q/vlan.c | 94 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 94 insertions(+)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 59555f0..0a9e8e1 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -618,6 +618,90 @@ out:
 	return err;
 }
 
+static struct sk_buff **vlan_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	struct sk_buff *p, **pp = NULL;
+	struct vlan_hdr *vhdr;
+	unsigned int hlen, off_vlan;
+	const struct packet_offload *ptype;
+	__be16 type;
+	int flush = 1;
+
+	off_vlan = skb_gro_offset(skb);
+	hlen = off_vlan + sizeof(*vhdr);
+	vhdr = skb_gro_header_fast(skb, off_vlan);
+	if (skb_gro_header_hard(skb, hlen)) {
+		vhdr = skb_gro_header_slow(skb, hlen, off_vlan);
+		if (unlikely(!vhdr))
+			goto out;
+	}
+
+	type = vhdr->h_vlan_encapsulated_proto;
+
+	rcu_read_lock();
+	ptype = gro_find_receive_by_type(type);
+	if (!ptype)
+		goto out_unlock;
+
+	flush = 0;
+
+	for (p = *head; p; p = p->next) {
+		struct vlan_hdr *vhdr2;
+
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		vhdr2 = (struct vlan_hdr *)(p->data + off_vlan);
+		if (memcmp(vhdr, vhdr2, VLAN_HLEN))
+			NAPI_GRO_CB(p)->same_flow = 0;
+	}
+
+	skb_gro_pull(skb, sizeof(*vhdr));
+	skb_gro_postpull_rcsum(skb, vhdr, sizeof(*vhdr));
+	pp = ptype->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int vlan_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct vlan_hdr *vhdr = (struct vlan_hdr *)(skb->data + nhoff);
+	__be16 type = vhdr->h_vlan_encapsulated_proto;
+	struct packet_offload *ptype;
+	int err = -ENOENT;
+
+	rcu_read_lock();
+	ptype = gro_find_complete_by_type(type);
+	if (ptype)
+		err = ptype->callbacks.gro_complete(skb, nhoff + sizeof(*vhdr));
+
+	rcu_read_unlock();
+	return err;
+}
+
+static struct packet_offload vlan_packet_offloads[] __read_mostly = {
+	{
+		.type = cpu_to_be16(ETH_P_8021Q),
+		.callbacks = {
+			.gro_receive = vlan_gro_receive,
+			.gro_complete = vlan_gro_complete,
+		},
+	},
+	{
+		.type = cpu_to_be16(ETH_P_8021AD),
+		.callbacks = {
+			.gro_receive = vlan_gro_receive,
+			.gro_complete = vlan_gro_complete,
+		},
+	},
+};
+
 static int __net_init vlan_init_net(struct net *net)
 {
 	struct vlan_net *vn = net_generic(net, vlan_net_id);
@@ -645,6 +729,7 @@ static struct pernet_operations vlan_net_ops = {
 static int __init vlan_proto_init(void)
 {
 	int err;
+	unsigned int i;
 
 	pr_info("%s v%s\n", vlan_fullname, vlan_version);
 
@@ -668,6 +753,9 @@ static int __init vlan_proto_init(void)
 	if (err < 0)
 		goto err5;
 
+	for (i = 0; i < ARRAY_SIZE(vlan_packet_offloads); i++)
+		dev_add_offload(&vlan_packet_offloads[i]);
+
 	vlan_ioctl_set(vlan_ioctl_handler);
 	return 0;
 
@@ -685,7 +773,13 @@ err0:
 
 static void __exit vlan_cleanup_module(void)
 {
+	unsigned int i;
+
 	vlan_ioctl_set(NULL);
+
+	for (i = 0; i < ARRAY_SIZE(vlan_packet_offloads); i++)
+		dev_remove_offload(&vlan_packet_offloads[i]);
+
 	vlan_netlink_fini();
 
 	unregister_netdevice_notifier(&vlan_notifier_block);
-- 
1.8.1.2
