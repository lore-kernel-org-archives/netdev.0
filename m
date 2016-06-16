From: William Tu <u9012063@gmail.com>
Subject: [PATCH] openvswitch: Add cutlen info to upcall.
Date: Wed, 15 Jun 2016 19:28:55 -0700
Message-ID: <1466044135-9707-1-git-send-email-u9012063@gmail.com>
Cc: Pravin Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35629 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247AbcFPC3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 22:29:09 -0400
Received: by mail-pa0-f66.google.com with SMTP id hf6so2608111pac.2
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 19:29:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit f2a4d086ed4c ("openvswitch: Add packet truncation support.")
introduces packet truncation before sending to userspace upcall receiver.
This patch passes the number of bytes truncated in kernel to so that the
upcall receiver knows the original packet size. Potentially this will
be used by sFlow, where OVS translates sFlow config header=N to a sample
action to trunc(N) in kernel datapath. Thus, only N bytes instead of
full-packet size will be copied from kernel to userspace, saving the
kernel-to-userspace bandwidth.

Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Pravin Shelar <pshelar@nicira.com>
---
 include/uapi/linux/openvswitch.h |  2 ++
 net/openvswitch/actions.c        |  1 +
 net/openvswitch/datapath.c       | 15 +++++++++++++++
 net/openvswitch/datapath.h       |  1 +
 4 files changed, 19 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 8274675..aaaecb1 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -166,6 +166,7 @@ enum ovs_packet_cmd {
  * output port is actually a tunnel port. Contains the output tunnel key
  * extracted from the packet as nested %OVS_TUNNEL_KEY_ATTR_* attributes.
  * @OVS_PACKET_ATTR_MRU: Present for an %OVS_PACKET_CMD_ACTION and
+ * @OVS_PACKET_ATTR_CUTLEN: Number of bytes truncated before upcall.
  * %OVS_PACKET_ATTR_USERSPACE action specify the Maximum received fragment
  * size.
  *
@@ -185,6 +186,7 @@ enum ovs_packet_attr {
 	OVS_PACKET_ATTR_PROBE,      /* Packet operation is a feature probe,
 				       error logging should be suppressed. */
 	OVS_PACKET_ATTR_MRU,	    /* Maximum received IP fragment size. */
+	OVS_PACKET_ATTR_CUTLEN,		/* Number of bytes truncated. */
 	__OVS_PACKET_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 1ecbd77..64206ae 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -793,6 +793,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	memset(&upcall, 0, sizeof(upcall));
 	upcall.cmd = OVS_PACKET_CMD_ACTION;
 	upcall.mru = OVS_CB(skb)->mru;
+	upcall.cutlen = OVS_CB(skb)->cutlen;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 6739342..c5f5316 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -277,6 +277,7 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		upcall.cmd = OVS_PACKET_CMD_MISS;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		upcall.mru = OVS_CB(skb)->mru;
+		upcall.cutlen = OVS_CB(skb)->cutlen;
 		error = ovs_dp_upcall(dp, skb, key, &upcall, 0);
 		if (unlikely(error))
 			kfree_skb(skb);
@@ -405,6 +406,10 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 	if (upcall_info->mru)
 		size += nla_total_size(sizeof(upcall_info->mru));
 
+	/* OVS_PACKET_ATTR_CUTLEN */
+	if (upcall_info->cutlen)
+		size += nla_total_size(sizeof(upcall_info->cutlen));
+
 	return size;
 }
 
@@ -514,6 +519,16 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		pad_packet(dp, user_skb);
 	}
 
+	/* Add OVS_PACKET_ATTR_CUTLEN */
+	if (upcall_info->cutlen) {
+		if (nla_put_u32(user_skb, OVS_PACKET_ATTR_CUTLEN,
+				upcall_info->cutlen)) {
+			err = -ENOBUFS;
+			goto out;
+		}
+		pad_packet(dp, user_skb);
+	}
+
 	/* Only reserve room for attribute header, packet data is added
 	 * in skb_zerocopy() */
 	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0))) {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index ab85c1c..dd162b6 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -129,6 +129,7 @@ struct dp_upcall_info {
 	u32 portid;
 	u8 cmd;
 	u16 mru;
+	u32 cutlen;
 };
 
 /**
-- 
2.5.0
