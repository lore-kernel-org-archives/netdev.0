From: Liping Zhang <zlpnobody@163.com>
Subject: [PATCH net V2] openvswitch: fix skb_panic due to the incorrect actions attrlen
Date: Tue, 15 Aug 2017 19:29:13 +0800
Message-ID: <20170815112913.14678-1-zlpnobody@163.com>
Cc: netdev@vger.kernel.org, Liping Zhang <zlpnobody@gmail.com>,
        Neil McKee <neil.mckee@inmon.com>
To: pshelar@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:35955 "EHLO m50-132.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751147AbdHOLai (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 07:30:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

For sw_flow_actions, the actions_len only represents the kernel part's
size, and when we dump the actions to the userspace, we will do the
convertions, so it's true size may become bigger than the actions_len.

But unfortunately, for OVS_PACKET_ATTR_ACTIONS, we use the actions_len
to alloc the skbuff, so the user_skb's size may become insufficient and
oops will happen like this:
  skbuff: skb_over_panic: text:ffffffff8148fabf len:1749 put:157 head:
  ffff881300f39000 data:ffff881300f39000 tail:0x6d5 end:0x6c0 dev:<NULL>
  ------------[ cut here ]------------
  kernel BUG at net/core/skbuff.c:129!
  [...]
  Call Trace:
   <IRQ>
   [<ffffffff8148be82>] skb_put+0x43/0x44
   [<ffffffff8148fabf>] skb_zerocopy+0x6c/0x1f4
   [<ffffffffa0290d36>] queue_userspace_packet+0x3a3/0x448 [openvswitch]
   [<ffffffffa0292023>] ovs_dp_upcall+0x30/0x5c [openvswitch]
   [<ffffffffa028d435>] output_userspace+0x132/0x158 [openvswitch]
   [<ffffffffa01e6890>] ? ip6_rcv_finish+0x74/0x77 [ipv6]
   [<ffffffffa028e277>] do_execute_actions+0xcc1/0xdc8 [openvswitch]
   [<ffffffffa028e3f2>] ovs_execute_actions+0x74/0x106 [openvswitch]
   [<ffffffffa0292130>] ovs_dp_process_packet+0xe1/0xfd [openvswitch]
   [<ffffffffa0292b77>] ? key_extract+0x63c/0x8d5 [openvswitch]
   [<ffffffffa029848b>] ovs_vport_receive+0xa1/0xc3 [openvswitch]
  [...]

Also we can find that the actions_len is much little than the orig_len:
  crash> struct sw_flow_actions 0xffff8812f539d000
  struct sw_flow_actions {
    rcu = {
      next = 0xffff8812f5398800,
      func = 0xffffe3b00035db32
    },
    orig_len = 1384,
    actions_len = 592,
    actions = 0xffff8812f539d01c
  }

So as a quick fix, use the orig_len instead of the actions_len to alloc
the user_skb.

Last, this oops happened on our system running a relative old kernel, but
the same risk still exists on the mainline, since we use the wrong
actions_len from the beginning.

Fixes: ccea74457bbd ("openvswitch: include datapath actions with sampled-packet upcall to userspace")
Cc: Neil McKee <neil.mckee@inmon.com>
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
---
 V2: move actions_attrlen into ovs_skb_cb, which will make codes more
     clean, suggested by Pravin Shelar.

 net/openvswitch/actions.c  | 2 ++
 net/openvswitch/datapath.c | 2 +-
 net/openvswitch/datapath.h | 3 +++
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e4610676299b..f849ef52853f 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -921,6 +921,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			/* Include actions. */
 			upcall.actions = actions;
 			upcall.actions_len = actions_len;
+			upcall.actions_attrlen = OVS_CB(skb)->acts_origlen;
 			break;
 		}
 
@@ -1337,6 +1338,7 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		goto out;
 	}
 
+	OVS_CB(skb)->acts_origlen = acts->orig_len;
 	err = do_execute_actions(dp, skb, key,
 				 acts->actions, acts->actions_len);
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 45fe8c8a884d..66162e64e8b5 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -398,7 +398,7 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 
 	/* OVS_PACKET_ATTR_ACTIONS */
 	if (upcall_info->actions_len)
-		size += nla_total_size(upcall_info->actions_len);
+		size += nla_total_size(upcall_info->actions_attrlen);
 
 	/* OVS_PACKET_ATTR_MRU */
 	if (upcall_info->mru)
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 5d8dcd88815f..8fd902c946ff 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -99,11 +99,13 @@ struct datapath {
  * when a packet is received by OVS.
  * @mru: The maximum received fragement size; 0 if the packet is not
  * fragmented.
+ * @acts_origlen: The netlink size of the flow actions applied to this skb.
  * @cutlen: The number of bytes from the packet end to be removed.
  */
 struct ovs_skb_cb {
 	struct vport		*input_vport;
 	u16			mru;
+	u16			acts_origlen;
 	u32			cutlen;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
@@ -124,6 +126,7 @@ struct dp_upcall_info {
 	const struct nlattr *userdata;
 	const struct nlattr *actions;
 	int actions_len;
+	int actions_attrlen;
 	u32 portid;
 	u8 cmd;
 	u16 mru;
-- 
2.13.4
