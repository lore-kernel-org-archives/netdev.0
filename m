From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 5/5] openvswitch: Allow OVS_USERSPACE_ATTR_USERDATA to be variable length.
Date: Fri, 15 Mar 2013 10:38:51 -0700
Message-ID: <1363369131-16830-6-git-send-email-jesse@nicira.com>
References: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Ben Pfaff <blp@nicira.com>,
	Romain Lenglet <rlenglet@vmware.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:35052 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751901Ab3CORjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 13:39:09 -0400
Received: by mail-ob0-f200.google.com with SMTP id un3so18206508obb.3
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 10:39:08 -0700 (PDT)
In-Reply-To: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pfaff <blp@nicira.com>

Until now, the optional OVS_USERSPACE_ATTR_USERDATA attribute had to be
exactly 64 bits long, if it was present.  However, 64 bits is not enough
space to associate as much information with a flow as would be convenient
for some userspace features now under development.  This commit generalizes
the attribute, allowing it to be any length.

This generalization is backward-compatible: if userspace only uses 64-bit
attributes, then it will not see any change in behavior.

CC: Romain Lenglet <rlenglet@vmware.com>
Signed-off-by: Ben Pfaff <blp@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/openvswitch.h |   11 ++++++-----
 net/openvswitch/datapath.c  |   11 ++++++-----
 net/openvswitch/datapath.h  |    2 +-
 3 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index 99e6414..67d6c7b 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -127,7 +127,8 @@ enum ovs_packet_cmd {
  * for %OVS_PACKET_CMD_EXECUTE.  It has nested %OVS_ACTION_ATTR_* attributes.
  * @OVS_PACKET_ATTR_USERDATA: Present for an %OVS_PACKET_CMD_ACTION
  * notification if the %OVS_ACTION_ATTR_USERSPACE action specified an
- * %OVS_USERSPACE_ATTR_USERDATA attribute.
+ * %OVS_USERSPACE_ATTR_USERDATA attribute, with the same length and content
+ * specified there.
  *
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_PACKET_* commands.
@@ -137,7 +138,7 @@ enum ovs_packet_attr {
 	OVS_PACKET_ATTR_PACKET,      /* Packet data. */
 	OVS_PACKET_ATTR_KEY,         /* Nested OVS_KEY_ATTR_* attributes. */
 	OVS_PACKET_ATTR_ACTIONS,     /* Nested OVS_ACTION_ATTR_* attributes. */
-	OVS_PACKET_ATTR_USERDATA,    /* u64 OVS_ACTION_ATTR_USERSPACE arg. */
+	OVS_PACKET_ATTR_USERDATA,    /* OVS_ACTION_ATTR_USERSPACE arg. */
 	__OVS_PACKET_ATTR_MAX
 };
 
@@ -389,13 +390,13 @@ enum ovs_sample_attr {
  * enum ovs_userspace_attr - Attributes for %OVS_ACTION_ATTR_USERSPACE action.
  * @OVS_USERSPACE_ATTR_PID: u32 Netlink PID to which the %OVS_PACKET_CMD_ACTION
  * message should be sent.  Required.
- * @OVS_USERSPACE_ATTR_USERDATA: If present, its u64 argument is copied to the
- * %OVS_PACKET_CMD_ACTION message as %OVS_PACKET_ATTR_USERDATA,
+ * @OVS_USERSPACE_ATTR_USERDATA: If present, its variable-length argument is
+ * copied to the %OVS_PACKET_CMD_ACTION message as %OVS_PACKET_ATTR_USERDATA.
  */
 enum ovs_userspace_attr {
 	OVS_USERSPACE_ATTR_UNSPEC,
 	OVS_USERSPACE_ATTR_PID,	      /* u32 Netlink PID to receive upcalls. */
-	OVS_USERSPACE_ATTR_USERDATA,  /* u64 optional user-specified cookie. */
+	OVS_USERSPACE_ATTR_USERDATA,  /* Optional user-specified cookie. */
 	__OVS_USERSPACE_ATTR_MAX
 };
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index f9d2438..96cd5b2 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -370,8 +370,8 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	len = sizeof(struct ovs_header);
 	len += nla_total_size(skb->len);
 	len += nla_total_size(FLOW_BUFSIZE);
-	if (upcall_info->cmd == OVS_PACKET_CMD_ACTION)
-		len += nla_total_size(8);
+	if (upcall_info->userdata)
+		len += NLA_ALIGN(upcall_info->userdata->nla_len);
 
 	user_skb = genlmsg_new(len, GFP_ATOMIC);
 	if (!user_skb) {
@@ -388,8 +388,9 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 	nla_nest_end(user_skb, nla);
 
 	if (upcall_info->userdata)
-		nla_put_u64(user_skb, OVS_PACKET_ATTR_USERDATA,
-			    nla_get_u64(upcall_info->userdata));
+		__nla_put(user_skb, OVS_PACKET_ATTR_USERDATA,
+			  nla_len(upcall_info->userdata),
+			  nla_data(upcall_info->userdata));
 
 	nla = __nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, skb->len);
 
@@ -544,7 +545,7 @@ static int validate_userspace(const struct nlattr *attr)
 {
 	static const struct nla_policy userspace_policy[OVS_USERSPACE_ATTR_MAX + 1] =	{
 		[OVS_USERSPACE_ATTR_PID] = {.type = NLA_U32 },
-		[OVS_USERSPACE_ATTR_USERDATA] = {.type = NLA_U64 },
+		[OVS_USERSPACE_ATTR_USERDATA] = {.type = NLA_UNSPEC },
 	};
 	struct nlattr *a[OVS_USERSPACE_ATTR_MAX + 1];
 	int error;
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 031dfbf..9125ad5 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -119,7 +119,7 @@ struct ovs_skb_cb {
  * struct dp_upcall - metadata to include with a packet to send to userspace
  * @cmd: One of %OVS_PACKET_CMD_*.
  * @key: Becomes %OVS_PACKET_ATTR_KEY.  Must be nonnull.
- * @userdata: If nonnull, its u64 value is extracted and passed to userspace as
+ * @userdata: If nonnull, its variable-length value is passed to userspace as
  * %OVS_PACKET_ATTR_USERDATA.
  * @pid: Netlink PID to which packet should be sent.  If @pid is 0 then no
  * packet is sent and the packet is accounted in the datapath's @n_lost
-- 
1.7.10.4
