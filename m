From: William Tu <u9012063@gmail.com>
Subject: [net-next,v4] openvswitch: Add packet len info to upcall.
Date: Mon, 20 Jun 2016 07:26:17 -0700
Message-ID: <1466432777-30305-1-git-send-email-u9012063@gmail.com>
Cc: Pravin Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33790 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758AbcFTOkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 10:40:36 -0400
Received: by mail-pa0-f65.google.com with SMTP id ts6so11162947pac.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 07:40:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit f2a4d086ed4c ("openvswitch: Add packet truncation support.")
introduces packet truncation before sending to userspace upcall receiver.
This patch passes up the skb->len before truncation so that the upcall
receiver knows the original packet size. Potentially this will be used
by sFlow, where OVS translates sFlow config header=N to a sample action,
truncating packet to N byte in kernel datapath. Thus, only N bytes instead
of full-packet size is copied from kernel to userspace, saving the
kernel-to-userspace bandwidth.

Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Pravin Shelar <pshelar@nicira.com>
---
v3->v4:
- Add OVS_PACKET_ATTR_LEN only when packet is truncated, 
  This avoid sending extra attribute in the case of miss flow.
v2->v3:
- Remove platform specific name.
- Fix issue when receiving GSO packet
- Remove skblen in struct dp_upcall_info
v1->v2:
- Pass skb->len to userspace instead of cutlen
---
 include/uapi/linux/openvswitch.h |  2 ++
 net/openvswitch/datapath.c       | 13 ++++++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 8274675..d95a301 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -166,6 +166,7 @@ enum ovs_packet_cmd {
  * output port is actually a tunnel port. Contains the output tunnel key
  * extracted from the packet as nested %OVS_TUNNEL_KEY_ATTR_* attributes.
  * @OVS_PACKET_ATTR_MRU: Present for an %OVS_PACKET_CMD_ACTION and
+ * @OVS_PACKET_ATTR_LEN: Packet size before truncation.
  * %OVS_PACKET_ATTR_USERSPACE action specify the Maximum received fragment
  * size.
  *
@@ -185,6 +186,7 @@ enum ovs_packet_attr {
 	OVS_PACKET_ATTR_PROBE,      /* Packet operation is a feature probe,
 				       error logging should be suppressed. */
 	OVS_PACKET_ATTR_MRU,	    /* Maximum received IP fragment size. */
+	OVS_PACKET_ATTR_LEN,		/* Packet size before truncation. */
 	__OVS_PACKET_ATTR_MAX
 };
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 6739342..524c0fd 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -387,7 +387,8 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 {
 	size_t size = NLMSG_ALIGN(sizeof(struct ovs_header))
 		+ nla_total_size(hdrlen) /* OVS_PACKET_ATTR_PACKET */
-		+ nla_total_size(ovs_key_attr_size()); /* OVS_PACKET_ATTR_KEY */
+		+ nla_total_size(ovs_key_attr_size()) /* OVS_PACKET_ATTR_KEY */
+		+ nla_total_size(sizeof(unsigned int)); /* OVS_PACKET_ATTR_LEN */
 
 	/* OVS_PACKET_ATTR_USERDATA */
 	if (upcall_info->userdata)
@@ -514,6 +515,16 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		pad_packet(dp, user_skb);
 	}
 
+	/* Add OVS_PACKET_ATTR_LEN when packet is truncated */
+	if (cutlen > 0) {
+		if (nla_put_u32(user_skb, OVS_PACKET_ATTR_LEN,
+				skb->len)) {
+			err = -ENOBUFS;
+			goto out;
+		}
+		pad_packet(dp, user_skb);
+	}
+
 	/* Only reserve room for attribute header, packet data is added
 	 * in skb_zerocopy() */
 	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0))) {
-- 
2.5.0
