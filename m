From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.51 3/5] lib: Support pushing of MPLS LSE before
	or after VLAN tag
Date: Thu, 21 Nov 2013 12:46:44 +0900
Message-ID: <1385005606-30130-4-git-send-email-horms@verge.net.au>
References: <1385005606-30130-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1385005606-30130-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

This patch modifies the push_mpls behaviour to allow
pushing of an MPLS LSE either before any VLAN tag that may be present.

Pushing the MPLS LSE before any VLAN tag that is present is the
behaviour specified in OpenFlow 1.3.

Pushing the MPLS LSE after the any VLAN tag that is present is the
behaviour specified in OpenFlow 1.1 and 1.2. This is the only behaviour
that was supported prior to this patch.

When an push_mpls action has been inserted using OpenFlow 1.2 or earlier
the behaviour of pushing the MPLS LSE before any VLAN tag that may be
present is implemented by by inserting VLAN actions around the MPLS push
action during odp translation; Pop VLAN tags before committing MPLS
actions, and push the expected VLAN tag afterwards.

The trigger condition for the two different behaviours is the value of
the mpls_before_vlan field of struct ofpact_push_mpls. This field is set
when parsing OpenFlow actions.

Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v2.51
* Revert ofpact_check__() changes introduced in v2.49
* Enable consistency checking when OpenFlow1.3 is in use
  by deleting the line of ofpacts_check__() which disables it.
* Add write_actions test
* Use OF1.3 for all ovs-ofctl commands
  - Allows write_actions to show up in dump-flows
  - Otherwise cosmetic

v2.50
* No change

v2.49 [Simon Horman]
* Teach ofpact_check__() when OpenFlow1.3 is in use and thus
  MPLS LSEs are pushed before VLAN tags, that in effect there
  is no VLAN tag present after an mpls_push action.

v2.48 [Simon Horman]
* Only use OpenFlow1.3 actions in OpenFlow1.3 tests

v2.46 - v2.47
* No change

v2.45 [Simon Horman]
* Rebased for updates to VLAN handling in the presence of MPLS
* Update tests to use ovs-ofctl monitor "-m" to allow full
  inspection of MPLS LSE and VLAN tags present in packets.

v2.44
* No change

v2.43 [Simon Horman]
* Trivial rebase as the result of replacing 'mpls_before_vlan' field
  of struct ofpact_push_mpls with a 'position' field.

v2.42
* No change

v2.41 [Simon Horman]
* Use 'mpls_before_vlan' field of struct ofpact_push_mpls.
* Reword changelog to describe the difference in behaviour between
  different Open Flow versions.

v2.40 [Simon Horman]
* Trivial rebase for removal of set_ethertype()

v2.36 - v2.39
* No change

v2.35 [Joe Stringer]
* First post
---
 lib/flow.c                   |   2 +-
 lib/ofp-actions.c            |   8 -
 lib/packets.c                |  10 +-
 lib/packets.h                |   2 +-
 ofproto/ofproto-dpif-xlate.c |  29 +--
 tests/ofproto-dpif.at        | 480 +++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 503 insertions(+), 28 deletions(-)

diff --git a/lib/flow.c b/lib/flow.c
index c6683a5..ae4d2b2 100644
--- a/lib/flow.c
+++ b/lib/flow.c
@@ -1136,7 +1136,7 @@ flow_compose(struct ofpbuf *b, const struct flow *flow)
     }
 
     if (eth_type_mpls(flow->dl_type)) {
-        b->l2_5 = b->l3;
+        b->l2_5 = (char*)b->l2 + ETH_HEADER_LEN;
         push_mpls(b, flow->dl_type, flow->mpls_lse);
     }
 }
diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index 6754939..36fc617 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -2257,14 +2257,6 @@ ofpacts_check__(struct ofpact ofpacts[], size_t ofpacts_len,
         if (error) {
             break;
         }
-        /* XXX
-         * OF1.3 tag order is not currently implemented.
-         * The following line effectively disables the
-         * use of 'of13_vlan_tci' to check OF1.3+ tag order
-         * consistency. This means that pre-OF1.3+ is always used.
-         * This line should be removed by a subequent
-         * patch which enables the use of OF1.3+ tag order */
-        *of13_vlan_tci = flow->vlan_tci;
     }
     /* Restore fields that may have been modified. */
     flow->dl_type = dl_type;
diff --git a/lib/packets.c b/lib/packets.c
index 4bec4d1..b55726e 100644
--- a/lib/packets.c
+++ b/lib/packets.c
@@ -219,11 +219,11 @@ eth_pop_vlan(struct ofpbuf *packet)
 
 /* Set ethertype of the packet. */
 void
-set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type)
+set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner)
 {
     struct eth_header *eh = packet->data;
 
-    if (eh->eth_type == htons(ETH_TYPE_VLAN)) {
+    if (inner && eh->eth_type == htons(ETH_TYPE_VLAN)) {
         ovs_be16 *p;
         p = ALIGNED_CAST(ovs_be16 *,
                 (char *)(packet->l2_5 ? packet->l2_5 : packet->l3) - 2);
@@ -331,8 +331,8 @@ push_mpls(struct ofpbuf *packet, ovs_be16 ethtype, ovs_be32 lse)
 
     if (!is_mpls(packet)) {
         /* Set ethtype and MPLS label stack entry. */
-        set_ethertype(packet, ethtype);
-        packet->l2_5 = packet->l3;
+        set_ethertype(packet, ethtype, false);
+        packet->l2_5 = (char*)packet->l2 + ETH_HEADER_LEN;
     }
 
     /* Push new MPLS shim header onto packet. */
@@ -353,7 +353,7 @@ pop_mpls(struct ofpbuf *packet, ovs_be16 ethtype)
         size_t len;
         mh = packet->l2_5;
         len = (char*)packet->l2_5 - (char*)packet->l2;
-        set_ethertype(packet, ethtype);
+        set_ethertype(packet, ethtype, true);
         if (mh->mpls_lse & htonl(MPLS_BOS_MASK)) {
             packet->l2_5 = NULL;
         } else {
diff --git a/lib/packets.h b/lib/packets.h
index ef8c00c..4d1d197 100644
--- a/lib/packets.h
+++ b/lib/packets.h
@@ -143,7 +143,7 @@ void compose_rarp(struct ofpbuf *, const uint8_t eth_src[ETH_ADDR_LEN]);
 void eth_push_vlan(struct ofpbuf *, ovs_be16 tci);
 void eth_pop_vlan(struct ofpbuf *);
 
-void set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type);
+void set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner);
 
 const char *eth_from_hex(const char *hex, struct ofpbuf **packetp);
 void eth_format_masked(const uint8_t eth[ETH_ADDR_LEN],
diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index daacee6..d734028 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -2811,24 +2811,27 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             break;
         }
 
-        case OFPACT_PUSH_MPLS:
-            if (compose_mpls_push_action(ctx,
-                                         ofpact_get_PUSH_MPLS(a)->ethertype)) {
+        case OFPACT_PUSH_MPLS: {
+            struct ofpact_push_mpls *oam = ofpact_get_PUSH_MPLS(a);
+
+            if (compose_mpls_push_action(ctx, oam->ethertype)) {
                 return;
             }
 
-            /* Save and pop any existing VLAN tags. They will be pushed
-             * back onto the packet after pushing the MPLS LSE. The overall
-             * effect is to push the MPLS LSE after any VLAN tags that may
-             * be present. This is the behaviour described for OpenFlow 1.1
-             * and 1.2. This code needs to be enhanced to make this
-             * conditional to also and support pushing the MPLS LSE before
-             * any VLAN tags that may be present, the behaviour described
-             * for OpenFlow 1.3. */
-            ctx->post_mpls_vlan_tci = *ctx->next_vlan_tci;
-            flow->vlan_tci = htons(0);
+            /* Save and pop any existing VLAN tags if the MPLS LSE should
+             * be pushed after VLAN tags.  The overall effect is to push
+             * the MPLS LSE after any VLAN tags that may be present.  This
+             * is the behaviour described for OpenFlow 1.1 and 1.2.
+             * Do not save and therefore pop the VLAN tags if the MPLS LSE
+             * should be pushed before any VLAN tags that are present.
+             * This is the behaviour described for OpenFlow 1.3. */
+            if (oam->position == OFPACT_MPLS_AFTER_VLAN) {
+                ctx->post_mpls_vlan_tci = *ctx->next_vlan_tci;
+                flow->vlan_tci = htons(0);
+            }
             ctx->next_vlan_tci = &ctx->post_mpls_vlan_tci;
             break;
+        }
 
         case OFPACT_POP_MPLS:
             if (compose_mpls_pop_action(ctx,
diff --git a/tests/ofproto-dpif.at b/tests/ofproto-dpif.at
index 9becf05..4aa48a5 100644
--- a/tests/ofproto-dpif.at
+++ b/tests/ofproto-dpif.at
@@ -1452,6 +1452,486 @@ OFPST_FLOW reply (OF1.2):
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
+cookie=0xa dl_src=40:44:44:44:55:45 actions=push_vlan:0x8100,set_vlan_vid:99,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:55:46 actions=push_vlan:0x8100,set_vlan_vid:99,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:55:47 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:55:48 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:55:49 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,set_vlan_vid:99,controller
+cookie=0xa dl_src=40:44:44:44:55:50 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,set_vlan_vid:99,controller
+cookie=0xa dl_src=40:44:44:44:55:51 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:55:52 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:55:53,vlan_tci=0x1000/0x1000 actions=load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:55:54 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:55:55 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],write_actions(push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,controller)
+])
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 add-flows br0 flows.txt])
+
+dnl Modified MPLS controller action.
+dnl The input packet has a VLAN tag, but because we push an MPLS tag in
+dnl OF1.3 mode, we can no longer see it in the final flow.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:44,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:44,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 44 88 47 00 00
+00000010  a7 40 e0 58 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:44,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 44 88 47 00 00
+00000010  a7 40 e0 58 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:44,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 44 88 47 00 00
+00000010  a7 40 e0 58 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push a VLAN tag, then an MPLS tag in OF1.3 mode, so we
+dnl can only see the MPLS tag in the final flow.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:45,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:45,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 45 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:45,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 45 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:45,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 45 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet is vlan-tagged; we update this tag then
+dnl push an MPLS tag in OF1.3 mode. As such, we can only see the MPLS tag in
+dnl the final flow.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:46,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:46,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 46 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:46,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 46 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:46,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 46 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push a VLAN tag, then an MPLS tag in OF1.3 mode, so we
+dnl can only see the MPLS tag in the final flow.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:47,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:47,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 47 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:47,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 47 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:47,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 47 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet is vlan-tagged; we update this tag then
+dnl push an MPLS tag in OF1.3 mode. As such, we can only see the MPLS tag in
+dnl the final flow.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:48,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 48 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 48 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:55:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 48 88 47 00 00
+00000010  a7 40 00 63 08 00 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we see
+dnl both of these in the final flow.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:49,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 49 81 00 00 63
+00000010  88 47 00 00 a7 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 49 81 00 00 63
+00000010  88 47 00 00 a7 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 49 81 00 00 63
+00000010  88 47 00 00 a7 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:50,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 50 81 00 00 63
+00000010  88 47 00 00 a7 40 e0 58-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 50 81 00 00 63
+00000010  88 47 00 00 a7 40 e0 58-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=0,dl_src=40:44:44:44:55:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 50 81 00 00 63
+00000010  88 47 00 00 a7 40 e0 58-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we see
+dnl both of these in the final flow.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:51,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 51 81 00 20 63
+00000010  88 47 00 00 a7 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 51 81 00 20 63
+00000010  88 47 00 00 a7 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 51 81 00 20 63
+00000010  88 47 00 00 a7 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be unaltered
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:52,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:52,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 52 81 00 20 63
+00000010  88 47 00 00 a7 40 e0 58-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:52,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 52 81 00 20 63
+00000010  88 47 00 00 a7 40 e0 58-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:52,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 52 81 00 20 63
+00000010  88 47 00 00 a7 40 e0 58-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be modified
+dnl before we push MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:53,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 53 81 00 20 63
+00000010  88 47 00 00 a7 40 20 63-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 53 81 00 20 63
+00000010  88 47 00 00 a7 40 20 63-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 53 81 00 20 63
+00000010  88 47 00 00 a7 40 20 63-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be modified
+dnl before we push MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:54,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=72 in_port=1 (via action) data_len=72 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 54 81 00 20 63
+00000010  88 47 00 00 a7 40 20 63-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00 00 00 00 00-
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=72 in_port=1 (via action) data_len=72 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 54 81 00 20 63
+00000010  88 47 00 00 a7 40 20 63-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00 00 00 00 00-
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=72 in_port=1 (via action) data_len=72 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 54 81 00 20 63
+00000010  88 47 00 00 a7 40 20 63-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00 00 00 00 00-
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be modified
+dnl before we push MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow13 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:55:55,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=72 in_port=1 (via action) data_len=72 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 55 81 00 20 63
+00000010  88 47 00 00 a7 40 20 63-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00 00 00 00 00-
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=72 in_port=1 (via action) data_len=72 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 55 81 00 20 63
+00000010  88 47 00 00 a7 40 20 63-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00 00 00 00 00-
+dnl
+OFPT_PACKET_IN (OF1.3): cookie=0xa total_len=72 in_port=1 (via action) data_len=72 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:55:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 55 55 81 00 20 63
+00000010  88 47 00 00 a7 40 20 63-08 00 45 00 00 28 00 00
+00000020  00 00 40 06 f9 7c c0 a8-00 01 c0 a8 00 02 00 00
+00000030  00 00 00 00 00 00 00 00-00 00 50 00 00 00 00 00
+00000040  00 00 00 00 00 00 00 00-
+])
+
+AT_CHECK([ovs-appctl time/warp 5000], [0], [ignore])
+AT_CHECK([ovs-ofctl --protocol=OpenFlow13 dump-flows br0 | ofctl_strip | sort], [0], [dnl
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:44 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:45 actions=push_vlan:0x8100,set_field:4195->vlan_vid,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:46 actions=push_vlan:0x8100,set_field:4195->vlan_vid,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:47 actions=push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:48 actions=push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:49 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,set_field:4195->vlan_vid,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:50 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,set_field:4195->vlan_vid,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:51 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:52 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:54 actions=push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:55:55 actions=push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],write_actions(push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,CONTROLLER:65535)
+ cookie=0xa, n_packets=3, n_bytes=180, vlan_tci=0x1000/0x1000,dl_src=40:44:44:44:55:53 actions=load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,CONTROLLER:65535
+OFPST_FLOW reply (OF1.3):
+])
+
+OVS_VSWITCHD_STOP
+AT_CLEANUP
+
 AT_SETUP([ofproto-dpif - fragment handling])
 OVS_VSWITCHD_START
 ADD_OF_PORTS([br0], [1], [2], [3], [4], [5], [6], [90])
-- 
1.8.4
