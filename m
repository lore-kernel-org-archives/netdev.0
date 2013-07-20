From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.35 5/6] lib: Push MPLS tags in the OpenFlow 1.3 ordering
Date: Sat, 20 Jul 2013 12:07:02 +0900
Message-ID: <1374289623-17056-6-git-send-email-horms@verge.net.au>
References: <1374289623-17056-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38102 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589Ab3GTDGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 23:06:49 -0400
In-Reply-To: <1374289623-17056-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

This patch modifies the push_mpls behaviour to follow the OpenFlow 1.3
specification in the presence of VLAN tagged packets. From the spec:

"Newly pushed tags should always be inserted as the outermost tag in the
outermost valid location for that tag. When a new VLAN tag is pushed, it
should be the outermost tag inserted, immediately after the Ethernet
header and before other tags. Likewise, when a new MPLS tag is pushed,
it should be the outermost tag inserted, immediately after the Ethernet
header and before other tags."

When the push_mpls action was inserted using OpenFlow 1.2, we implement
the previous behaviour by inserting VLAN actions around the MPLS action
in the odp translation; Pop VLAN tags before committing MPLS actions,
and push the expected VLAN tag afterwards. The trigger condition for
this is based on the ofpact->compat field.

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 lib/flow.c                   |    2 +-
 lib/packets.c                |   10 +-
 lib/packets.h                |    2 +-
 ofproto/ofproto-dpif-xlate.c |   10 +-
 tests/ofproto-dpif.at        |  237 ++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 253 insertions(+), 8 deletions(-)

diff --git a/lib/flow.c b/lib/flow.c
index d899d26..3dc4489 100644
--- a/lib/flow.c
+++ b/lib/flow.c
@@ -1035,7 +1035,7 @@ flow_compose(struct ofpbuf *b, const struct flow *flow)
     }
 
     if (eth_type_mpls(flow->dl_type)) {
-        b->l2_5 = b->l3;
+        b->l2_5 = (char*)b->l2 + ETH_HEADER_LEN;
         push_mpls(b, flow->dl_type, flow->mpls_lse);
     }
 }
diff --git a/lib/packets.c b/lib/packets.c
index 7fe6513..3bc155f 100644
--- a/lib/packets.c
+++ b/lib/packets.c
@@ -240,11 +240,11 @@ eth_mpls_depth(const struct ofpbuf *packet)
 
 /* Set ethertype of the packet. */
 void
-set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type)
+set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner)
 {
     struct eth_header *eh = packet->data;
 
-    if (eh->eth_type == htons(ETH_TYPE_VLAN)) {
+    if (inner && eh->eth_type == htons(ETH_TYPE_VLAN)) {
         ovs_be16 *p;
         p = (ovs_be16 *)((char *)(packet->l2_5 ? packet->l2_5 : packet->l3) - 2);
         *p = eth_type;
@@ -351,8 +351,8 @@ push_mpls(struct ofpbuf *packet, ovs_be16 ethtype, ovs_be32 lse)
 
     if (!is_mpls(packet)) {
         /* Set ethtype and MPLS label stack entry. */
-        set_ethertype(packet, ethtype);
-        packet->l2_5 = packet->l3;
+        set_ethertype(packet, ethtype, false);
+        packet->l2_5 = (char*)packet->l2 + ETH_HEADER_LEN;
     }
 
     /* Push new MPLS shim header onto packet. */
@@ -373,7 +373,7 @@ pop_mpls(struct ofpbuf *packet, ovs_be16 ethtype)
         size_t len;
         mh = packet->l2_5;
         len = (char*)packet->l2_5 - (char*)packet->l2;
-        set_ethertype(packet, ethtype);
+        set_ethertype(packet, ethtype, true);
         if (mh->mpls_lse & htonl(MPLS_BOS_MASK)) {
             packet->l2_5 = NULL;
         } else {
diff --git a/lib/packets.h b/lib/packets.h
index e852761..923fd53 100644
--- a/lib/packets.h
+++ b/lib/packets.h
@@ -142,7 +142,7 @@ void eth_pop_vlan(struct ofpbuf *);
 
 uint16_t eth_mpls_depth(const struct ofpbuf *packet);
 
-void set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type);
+void set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner);
 
 const char *eth_from_hex(const char *hex, struct ofpbuf **packetp);
 void eth_format_masked(const uint8_t eth[ETH_ADDR_LEN],
diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index 8a0c32e..457a1d1 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -1912,6 +1912,12 @@ tunnel_ecn_ok(struct xlate_ctx *ctx)
     return true;
 }
 
+static bool
+mpls_compat_behaviour(enum ofputil_action_code compat)
+{
+    return (compat != OFPUTIL_OFPAT13_PUSH_MPLS);
+}
+
 static void
 vlan_tci_restore(struct xlate_in *xin, ovs_be16 *tci_ptr, ovs_be16 orig_tci)
 {
@@ -2089,7 +2095,9 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
             /* Save and pop any existing VLAN tags if running in OF1.2 mode. */
             ctx->xin->vlan_tci = *vlan_tci;
-            flow->vlan_tci = htons(0);
+            if (mpls_compat_behaviour(a->compat)) {
+                flow->vlan_tci = htons(0);
+            }
             vlan_tci = &ctx->xin->vlan_tci;
             break;
 
diff --git a/tests/ofproto-dpif.at b/tests/ofproto-dpif.at
index 62531da..5e85ab2 100644
--- a/tests/ofproto-dpif.at
+++ b/tests/ofproto-dpif.at
@@ -1017,6 +1017,243 @@ NXST_FLOW reply:
 OVS_VSWITCHD_STOP
 AT_CLEANUP
 
+AT_SETUP([ofproto-dpif - OF1.3+ VLAN+MPLS handling])
+OVS_VSWITCHD_START([dnl
+   add-port br0 p1 -- set Interface p1 type=dummy
+])
+ON_EXIT([kill `cat ovs-ofctl.pid`])
+
+AT_CAPTURE_FILE([ofctl_monitor.log])
+AT_DATA([flows.txt], [dnl
+cookie=0xa dl_src=40:44:44:44:55:44 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:55:45 actions=push_vlan:0x8100,mod_vlan_vid:99,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:55:46 actions=push_vlan:0x8100,mod_vlan_vid:99,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:55:47 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:55:48 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:55:49 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,mod_vlan_vid:99,controller
+cookie=0xa dl_src=40:44:44:44:55:50 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,mod_vlan_vid:99,controller
+cookie=0xa dl_src=40:44:44:44:55:51 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:55:52 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,controller
+])
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 add-flows br0 flows.txt])
+
+dnl Modified MPLS controller action.
+dnl The input packet has a VLAN tag, but because we push an MPLS tag in
+dnl OF1.3 mode, we can no longer see it.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:44,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:44,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:44,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:44,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push a VLAN tag, then an MPLS tag in OF1.3 mode, so we
+dnl can only see the MPLS tag in the result.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:45,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:45,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:45,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:45,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet is vlan-tagged; we update this tag then
+dnl push an MPLS tag in OF1.3 mode. As such, we can only see the MPLS tag in
+dnl the result.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:46,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:46,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:46,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:46,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push a VLAN tag, then an MPLS tag in OF1.3 mode, so we
+dnl can only see the MPLS tag in the result.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:47,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:47,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:47,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:47,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet is vlan-tagged; we update this tag then
+dnl push an MPLS tag in OF1.3 mode. As such, we can only see the MPLS tag in
+dnl the result.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:48,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we see
+dnl both of these in the final flow.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:49,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:50,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we see
+dnl both of these in the final flow.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:51,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:52,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:52,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:52,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:52,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+])
+
+AT_CHECK([ovs-appctl time/warp 5000], [0], [ignore])
+AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:44 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:45 actions=mod_vlan_vid:99,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:46 actions=mod_vlan_vid:99,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:47 actions=load:0x63->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:48 actions=load:0x63->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:49 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],mod_vlan_vid:99,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:50 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],mod_vlan_vid:99,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:51 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],load:0x63->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:52 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],load:0x63->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,CONTROLLER:65535
+NXST_FLOW reply:
+])
+
+OVS_VSWITCHD_STOP
+AT_CLEANUP
+
 AT_SETUP([ofproto-dpif - fragment handling])
 OVS_VSWITCHD_START
 ADD_OF_PORTS([br0], [1], [2], [3], [4], [5], [6], [90])
-- 
1.7.10.4
