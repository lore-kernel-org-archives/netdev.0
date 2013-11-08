From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.48 4/4] datapath: Add basic MPLS support to kernel
Date: Fri,  8 Nov 2013 09:17:11 +0900
Message-ID: <1383869831-9426-5-git-send-email-horms@verge.net.au>
References: <1383869831-9426-1-git-send-email-horms@verge.net.au>
Cc: Pravin B Shelar <pshelar@nicira.com>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55592 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057Ab3KHARU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:17:20 -0500
In-Reply-To: <1383869831-9426-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow datapath to recognize and extract MPLS labels into flow keys
and execute actions which push, pop, and set labels on packets.

Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.

Cc: Ravi K <rkerur@gmail.com>
Cc: Leo Alterman <lalterman@nicira.com>
Cc: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

v2.48
* No change

v2.47
* Rebase for HAVE_RHEL_OVS_HOOK and OVS_KEY_ATTR_TCP_FLAGS

v2.43 - v2.46
* No change

v2.42
* Rebase for:
  + 0585f7a ("datapath: Simplify mega-flow APIs.")
  + a097c0b ("datapath: Restructure datapath.c and flow.c")
* As suggested by Jesse Gross
  + Take into account that push_mpls() will have freed the skb on error
  + Remove dubious !eth_p_mpls(skb->protocol) condition from push_mpls
    The !eth_p_mpls(skb->protocol) condition on setting inner_protocol
    has no effect. Its motivation was to ensure that inner_protocol was
    only set the first time that mpls_push occured. However this is already
    ensured by the !ovs_skb_get_inner_protocol(skb) condition.
  + Return -EINVAL instead of -ENOMEM from pop_mpls() if the skb is too short
  + Do not add @inner_protocol to kernel doc for struct ovs_skb_cb.
    The patch no longer adds an inner_protocol member to struct ovs_skb_cb
  + Do not add and set otherwise unsued inner_protocol variable in
    rpl_dev_queue_xmit()
* As suggested by Pravin Shelar
  + Implement compatibility code in existing rpl_skb_gso_segment
    rather than introducing to use rpl___skb_gso_segment

v2.41
* No change

v2.40
* Rebase for:
  + New dev_queue_xmit compat code
  + Updated put_vlan()
* As suggested by Jesse Gross
  + Remove bogus mac_len update from push_mpls()
  + Slightly simplify push_mpls() by using eth_hdr()
  + Remove dubious condition !eth_p_mpls(inner_protocol) on
    an skb being considered to be MPLS in netdev_send()
  + Only use compatibility code for MPLS GSO segmentation on kernels
    older than 3.11
  + Revamp setting of inner_protocol
    1. Do not unconditionally set inner_protocol to the value of
       skb->protocol in ovs_execute_actions().
    2. Initialise inner_protocol it to zero only if compatibility code is in
       use. In the case where compatibility code is not in use it will either
       be zero due since the allocation of the skb or some other value set
       by some other user.
    3. Conditionally set the inner_protocol in push_mpls() to the value of
       skb->protocol when entering push_mpls(). The condition is that
       inner_protocol is zero and the value of skb->protocol is not an MPLS
       ethernet type.
    - This new scheme:
      + Pushes logic to set inner_protocol closer to the case where it is
	needed.
      + Avoids over-writing values set by other users.
* As suggested by Pravin Shelar
  + Only set and restore skb->protocol in rpl___skb_gso_segment() in the
    case of MPLS
  + Add inner_protocol field to struct ovs_gso_cb instead of ovs_skb_cb.
    This moves compatibility code closer to where it is used
    and creates fewer differences with mainline.
* Update comment on mac_len updates in datapath/actions.c
* Remove HAVE_INNER_PROCOTOL and instead just check
  against kernel version 3.11 directly.
  HAVE_INNER_PROCOTOL is a hang-over from work done prior
  to the merge of inner_protocol into the kernel.
* Remove dubious condition !eth_p_mpls(inner_protocol) on
  using inner_protocol as the type in rpl_skb_network_protocol()
* Do not update type of features in rpl_dev_queue_xmit.
  Though arguably correct this is not an inherent part of
  the changes made by this patch.
* Use skb_cow_head() in push_mpls()
  + Call skb_cow_head(skb, MPLS_HLEN) instead of
    make_writable(skb, skb->mac_len) to ensure that there is enough head
    room to push an MPLS LSE regardless of whether the skb is cloned or not.
  + This is consistent with the behaviour of rpl__vlan_put_tag().
  + This is a fix for crashes reported when performing mpls_push
    with headroom less than 4. This problem was introduced in v3.36.
* Skip popping in mpls_pop if the skb is too short to contain an MPLS LSE

v2.39
* Rebase for removal of vlan, checksum and skb->mark compat code

v2.38
* Rebase for SCTP support
* Refactor validate_tp_port() to iterate over eth_types rather
  than open-coding the loop. With the addition of SCTP this logic
  is now used three times.

v2.36 - v2.37
* Rebase

* Do not add set_ethertype() to datapath/actions.c.
  As this patch has evolved this function had devolved into
  to sets of functionality wrapped into a single function with
  only one line of common code. Refactor things to simply
  open-code setting the ether type in the two locations where
  set_ethertype() was previously used. The aim here is to improve
  readability.

* Update setting skb->ethertype after mpls push and pop.
  - In the case of push_mpls it should be set unconditionally
    as in v2.35 the behaviour of this function to always push
    an MPLS LSE before any VLAN tags.
  - In the case of mpls_pop eth_p_mpls(skb->protocol) is a better
    test than skb->protocol != htons(ETH_P_8021Q) as it will give the
    correct behaviour in the presence of other VLAN ethernet types,
    for example 0x88a8 which is used by 802.1ad. Moreover, it seems
    correct to update the ethernet type if it was previously set
    according to the top-most MPLS LSE.

* Deaccelerate VLANs when pushing MPLS tags the
  - Since v2.35 MPLS push will insert an MPLS LSE before any VLAN tags.
    This means that if an accelerated tag is present it should be
    deaccelerated to ensure it ends up in the correct position.

* Update skb->mac_len in push_mpls() so that it will be correct
  when used by a subsequent call to pop_mpls().

  As things stand I do not believe this is strictly necessary as
  ovs-vswitchd will not send a pop MPLS action after a push MPLS action.
  However, I have added this in order to code more defensively as I believe
  that if such a sequence did occur it would be rather unobvious why
  it didn't work.

* Do not add skb_cow_head() call in push_mpls().
  It is unnecessary as there is a make_writable() call.
  This change was also made in v2.30 but some how the
  code regressed between then and v2.35.

v2.35
* Rebase
* Move MPLS constants to mpls.h
* Push MPLS tags after ethernet, before VLAN tags
  - This is consistent with the OpenFlow 1.3 specification
  - Compatibility with OpenFlow 1.2 and earlier versions
    may be provided by ovs-vswitchd.
* Correct GSO behaviour in the presence of MPLS but absence of VLANs

v2.34
* Rebase for megaflow changes

v2.33
* Ensure that inner_protocol is always set to to the current
  skb->protocol value in ovs_execute_actions(). This ensures
  it is set to the correct value in the absence of a push_mpls action.
  Also remove setting of inner_protocol in push_mpls() as
  it duplicates the code now in ovs_execute_actions().
* Call __skb_gso_segment() instead of skb_gso_segment() from
  rpl___skb_gso_segment() in the case that HAVE___SKB_GSO_SEGMENT is set.
  This was a typo.

v2.32
* As suggested by Jesse Gross
  - Use int instead of size_t in validate_and_copy_actions__().
  - Fix crazy edit mess in pop_mpls() action comment
  - Move eth_p_mpls() into mpls.h
  - Refactor skb_gso_segment MPLS handling into rpl_skb_gso_segment
    Address Jesse's comments regarding this code:
    "Can we push this completely into the skb_gso_segment() compatibility
     code? It's both nicer and may make the interactions with the vlan code
     less confusing."
  - Move GSO compatibility code into linux/compat/gso.*
  - Set skb->protocol on mpls_push and mpls_pop in the presence
    of an offloaded VLAN.

v2.31
* As suggested by Jesse Gross
  - There is no need to make mac_header_end inline as it is not in a header file
  - Remove dubious if (*skb_ethertype == ethertype) optimisation from
    set_ethertype
  - Only set skb->protocol in push_mpls() or pop_mpls() for non-VLAN packets
  - Use MAX_ETH_TYPES instead of SAMPLE_ACTION_DEPTH for array size
    of types in struct eth_types. This corrects a typo/thinko.
  - Correct eth type tracking logic such that start isn't advanced
    when entering a sample action, ensuring that all possibly types
    are checked when verifying nested actions.
* Define HAVE_INNER_PROTOCOL based on kernel version.
  inner_protocol has been merged into net-next and should appear in
  v3.11 so there is no longer a need for a acinclude.m4 test to check for it.
* Add MPLS GSO compatibility code.
  This is for use on kernels that do not have MPLS GSO support.
  Thanks to Joe Stringer for his work on this.

v2.30
* As suggested by Jesse Gross
  - Use skb_cow_head in push_mpls to ensure there is sufficient headroom for
    skb_push
  - Call make_writable with skb->mac_len instead of skb->mac_len + MPLS_HLEN
    in push_mpls as only the first skb->mac_len bytes of existing packet data
    are modified.
  - Rename skb_mac_header_end as mac_header_end, this seems
    to be a more appropriate name for a local function.
  - Remove OVS_CSUM_COMPLETE code from set_ethertype().
    Inside OVS the ethernet header is not covered by OVS_CSUM_COMPLETE.
  - Use __skb_pull() instead of skb_pull() in pop_mpls()
  - Decrement and decrement skb->mac_len when poping and pushing VLAN tags.
    Previously mac_len was reset, but this would result in forgetting
    the MPLS label stack.
  - Remove spurious comment from before do_execute_actions().
  - Move OVS_KEY_ATTR_MPLS attribute to its final, upstreamable, location.
  - Correct ethertype check for OVS_ACTION_ATTR_POP_MPLS case in
    validate_and_copy_actions() to check for MPLS ethertypes rather than
    ETH_P_IP.
  - Rewrite tracking of eth types used to verify actions in the presence
    of sample actions. There is a large comment above struct eth_types
    describing the new implementation.

v2.29
* Break include/ and lib/ portions of the patch out into a
  separate patch "datapath: Add basic MPLS support to kernel"
* Update for new MPLS GSO scheme
  - skb->protocol is set to the new ethertype of the packet
    on MPLS push and pop
  - When pushing the first MPLS LSE onto a previously non-MPLS
    packet set skb->inner_protocol to the original ethertype.
  - skb->inner_protocol may be used by the network stack
    for GSO of the inner-packet.
* Drop const from ethertype parameter of set_ethertype.
  This appears to be a legacy of this parameter being a pointer.
* Pass the ethertype patrameter of pop_mpls as a value rather
  than a pointer.

v2.28
* Kernel Datapath changes as suggested by Jarno Rajahalme
  + Correct the logic introduced in v2.27 to set the network_header
    to after the MPLS label stack in the case of an MPLS packet.
    - Increment stack_len offset so that label stacks of depth greater
      than two do not cause an infinite loop.
    - Correct offset passed to check_header to include skb->mac len

v2.27
* Kernel Datapath changes as suggested by Jarno Rajahalme and Jesse Gross:
  + Previously the mac_len and network_header of an skb corresponded
    to the end of the L2 header.  To support GSO, just before transmission,
    do_output, with the results as follows:

    Input: non-MPLS skb: Output: network header and mac_len correspond
                         to the beginning of the L3 headers
    Input: MPLS:         Output: network header and mac_len correspond to the
                         end of the L2 headers.

    This is somewhat confusing.

  + The new scheme is as follows:
    - The mac_len always corresponds to the end of the L2 header.
    - The network header always corresponds to the beginning of the
      L3 header.

  + Note that in the case of MPLS output the end of the L2 headers and the
  beginning of the L3 headers will differ.

* Remove unused declaration of skb_cb_mpls_stack()

v2.26
* Rebase on master
* Kernel Datapath changes as suggested by Jarno Rajahalme
  - Use skb_network_header() instead of skb_mac_header() to locate
    the ethertype to set in set_ethertype() as the latter will
    be wrong in the presence of VLAN tags. This resolves
    a regression introduced in v2.24.
  - Enhance comment in do_output()
  - do_execute_actions(): Do not alter mpls_stack_depth if
    a MPLS push or pop action fail. This is achieved by altering
    mpls_stack_depth at the end of push_mpls() and pop_mpls().

v2.25
* Rebase on master
* Pass big-endian value as the last argument of eth_types_set() in
  validate_and_copy_actions__()
* Use revised GSO support as provided by the patch series
  "[PATCH 0/2] Small Modifications to GSO to allow segmentation of MPLS"
  - Set skb->mac_len to the length of the l2 header + MPLS stack length
  - Update skb->network_header accordingly
  - Set skb->encapsulated_features

v2.24
* Use skb_mac_header() in set_ethertype()
* Set skb->encapsulation in set_ethertype() to support MPLS GSO.
  Also add a note about the other requirements for MPLS GSO.
  MPLS GSO support will be posted as a patch net-next (Linux mainline)
  "MPLS: Add limited GSO support"
* Do not add ETH_TYPE_MIN, it is no longer used

v2.23
* As suggested by Jesse Gross:
  - Verify the current ethernet type when validating sample actions
    both for the taken and not-taken path if the sample action.
  - Document that the OVS_KEY_ATTR_MPLS attribute accepts a list of
    struct ovs_key_mpls but that an implementation may restrict
    the length it accepts.
  - Restrict the array length of the OVS_KEY_ATTR_MPLS to one.
    + Don't add ovs_flow_verify_key_len as it was added to
      handle attributes whose values are arrays but there are
      no attributes with values that are arrays (of length greater than one).

v2.22
* As suggested by Jesse Gross:
  - Fix sparse warning in validate_and_copy_actions()
    I have no idea why sparse doesn't show this up this on my system.
  - Remove call to skb_cow_head() from push_mpls() as it
    is already covered by a call to make_writable()
  - Check (key_type > OVS_KEY_ATTR_MAX) in ovs_flow_verify_key_len()
  - Disallow set actions on l2.5+ data and MPLS push and pop actions
    after an MPLS pop action as there is no verification that the packet
    is actually of the new ethernet type. This may later be supported
    using recirculation or by other means.
  - Do not add spurious debuging message to ovs_flow_cmd_new_or_set()

v2.21
* As suggested by Jesse Gross:
  - Verify that l3 and l4 actions always always occur prior to
    a push_mpls action and use the network header pointer of an skb
    to track the top of the MPLS stack. This avoids adding an l2_size
    element to the skb callback.

v2.20
* As suggested by Jesse Gross:
  - Do not add ovs_dp_ioctl_hook
    + This appears to be garbage from a rebase
  - Do not add skb_cb_set_l2_size. Instead set OVS_CB(skb)->l2_size
    in ovs_flow_extract().
  - Do not free skb on error in push_mpls(), it is freed in the caller
  - Call skb_reset_mac_len() in pop_mpls() and push_mpls()
  - Update checksums in pop_mpls(), push_mpls() and set_mpls().
  - Rename skb_cb_mpls_bos() as skb_cb_mpls_stack().
    It returns the top not the bottom of the stack.
  - Track the current eth_type in validate_and_copy_actions
    which is initially the eth_type of the flow and may be modified
    by push_mpls and pop_mpls actions. Use this to correctly validate
    mpls_set actions. This is to allow mpls_set actions to be applied
    to a non-MPLS frame after an mpls_push action (although ovs-vswitchd
    doesn't currently do that).
    Also:
    + Remove the check of the eth_type in set_mpls() as the new validation
      scheme should ensure it cannot be incorrect.
    + Use the current eth_type to validate mpls_pop actions and remove
      the eth_type check from pop_mpls().
  - Move OVS_KEY_ATTR_MPLS to non-upstream group in ovs_key_lens
  - Remove unnecessary memset of mpls_key in ovs_flow_to_nlattrs()
  - Make a union of the mpls and ip elements of struct sw_flow_key.
    Currently the code stops parsing after an MPLS header so it is
    not possible for the ip and mpls elements to be used simultaneously
    and some space can be saved by using a union.
  - Allow an array of MPLS key attributes
    + Currently all but the first element is ignored
    + User-space needs to be updated to accept more than one element,
      currently it will treat their presence as an error
  - Do not update network header in ovs_flow_extract() for after parsing
    the MPLS stack as it is never used because no l3+ processing
    occurs on MPLS frames.
  - Allow multiple MPLS entries in a match by allowing the OVS_KEY_ATTR_MPLS
    to be an array of struct ovs_key_mpls with at least one entry.
    Currently only one entry is used which is byte-for-byte compatible with
    the previous scheme of having OVS_KEY_ATTR_MPLS as a struct
    ovs_key_mpls.
* Make skb writable in pop_mpls(), push_mpls() and set_mpls().

v2.18 - v2.19
* No change

v2.17
* As suggested by Ben Pfaff
  - Use consistent terminology for MPLS.
    + Consistently refer to the MPLS component of a packet as the
      MPLS label stack and entries in the stack as MPLS label stack entries
      (LSE).  An MPLS label is a component of an MPLS label stack entry.
      The other components are the traffic class (TC), time to live (TTL)
      and bottom of stack (BoS) bit.
  - Rename compose_.*mpls_ functions as execute_.*mpls_

v2.16
* No change

v2.15
* As suggested by Ben Pfaff
  - Use OVS_ACTION_SET to set OVS_KEY_ATTR_MPLS instead of
    OVS_ACTION_ATTR_SET_MPLS

v2.14
* Remove include/linux/openvswitch.h portion which added add
  new key and action attributes. This
  now present in "User-Space MPLS actions and matches"
  which is now a dependency of this patch

v2.13
* As suggested by Jarno Rajahalme
  - Rename mpls_bos element of ovs_skb_cb as l2_size as it is set and used
    regardless of if an MPLS stack is present or not. Update the name of
    helper functions and documentation accordingly.
  - Ensure that skb_cb_mpls_bos() never returns NULL
* Correct endieness in eth_p_mpls()

v2.12
* Update skb and network header on MPLS extraction in ovs_flow_extract()
* Use NULL in skb_cb_mpls_bos()
* Add eth_p_mpls helper

v2.10 - v2.11
* No change

v2.9
* datapath: Always update the mpls bos if  vlan_pop is successful

  Regardless of the details of how a successful
  vlan_pop is achieved, the mpls bos needs to be updated.

  Without this fix it has been observed that the following
  results in malformed packets

v2.8
* No change

v2.7
* Rebase

v2.6
* As suggested by Yamahata-san
  - Do not guard against label == 0 for
    OVS_ACTION_ATTR_SET_MPLS in validate_actions().
    A label of 0 is valid
  - Remove comment stupulating that if
    the top_label element of struct sw_flow_key is 0 then
    there is no MPLS label. An MPLS label of 0 is valid
    and the correct check if ethertype is
    ntohs(ETH_TYPE_MPLS) or ntohs(ETH_TYPE_MPLS_MCAST)

v2.4 - v2.5
* No change

v2.3
* s/mpls_stack/mpls_bos/
  This is in keeping with the naming used in the OpenFlow 1.3 specification

v2.2
* Call skb_reset_mac_header() in skb_cb_set_mpls_stack()
  eth_hdr(skb) is non-NULL when called in skb_cb_set_mpls_stack().
* Add a call to skb_cb_set_mpls_stack() in ovs_packet_cmd_execute().
  I apologise that I have mislaid my notes on this but
  it avoids a kernel panic. I can investigate again if necessary.
* Use struct ovs_action_push_mpls instead of
  __be16 to decode OVS_ACTION_ATTR_PUSH_MPLS in validate_actions(). This is
  consistent with the data format for the attribute.
* Indentation fix in skb_cb_mpls_stack(). [cosmetic]

v2.1
* Manual rebase
---
 datapath/Modules.mk                             |   1 +
 datapath/actions.c                              | 131 ++++++++++-
 datapath/datapath.c                             |   4 +-
 datapath/flow.c                                 |  29 +++
 datapath/flow.h                                 |  17 +-
 datapath/flow_netlink.c                         | 286 ++++++++++++++++++++++--
 datapath/flow_netlink.h                         |   2 +-
 datapath/linux/compat/gso.c                     |  70 +++++-
 datapath/linux/compat/gso.h                     |  41 ++++
 datapath/linux/compat/include/linux/netdevice.h |   6 +-
 datapath/linux/compat/netdevice.c               |  10 +-
 datapath/mpls.h                                 |  15 ++
 include/linux/openvswitch.h                     |   7 +-
 13 files changed, 569 insertions(+), 50 deletions(-)
 create mode 100644 datapath/mpls.h

diff --git a/datapath/Modules.mk b/datapath/Modules.mk
index b652411..6aa80e5 100644
--- a/datapath/Modules.mk
+++ b/datapath/Modules.mk
@@ -26,6 +26,7 @@ openvswitch_headers = \
 	flow.h \
 	flow_netlink.h \
 	flow_table.h \
+	mpls.h \
 	vlan.h \
 	vport.h \
 	vport-internal_dev.h \
diff --git a/datapath/actions.c b/datapath/actions.c
index ee2456b..d47776d 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -35,6 +35,8 @@
 #include <net/sctp/checksum.h>
 
 #include "datapath.h"
+#include "gso.h"
+#include "mpls.h"
 #include "vlan.h"
 #include "vport.h"
 
@@ -71,7 +73,8 @@ static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
 
 	vlan_set_encap_proto(skb, vhdr);
 	skb->mac_header += VLAN_HLEN;
-	skb_reset_mac_len(skb);
+	/* Update mac_len for subsequent MPLS actions */
+	skb->mac_len -= VLAN_HLEN;
 
 	return 0;
 }
@@ -113,6 +116,9 @@ static int put_vlan(struct sk_buff *skb)
 	if (!__vlan_put_tag(skb, skb->vlan_proto, current_tag))
 		return -ENOMEM;
 
+	/* update mac_len for subsequent MPLS actions */
+	skb->mac_len += VLAN_HLEN;
+
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		skb->csum = csum_add(skb->csum, csum_partial(skb->data
 				+ (2 * ETH_ALEN), VLAN_HLEN, 0));
@@ -133,6 +139,114 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
 	return 0;
 }
 
+/* The end of the mac header.
+ *
+ * For non-MPLS skbs this will correspond to the network header.
+ * For MPLS skbs it will be before the network_header as the MPLS
+ * label stack lies between the end of the mac header and the network
+ * header. That is, for MPLS skbs the end of the mac header
+ * is the top of the MPLS label stack.
+ */
+static unsigned char *mac_header_end(const struct sk_buff *skb)
+{
+	return skb_mac_header(skb) + skb->mac_len;
+}
+
+/* Push MPLS after the ethernet header. */
+static int push_mpls(struct sk_buff *skb,
+		     const struct ovs_action_push_mpls *mpls)
+{
+	__be32 *new_mpls_lse;
+	struct ethhdr *hdr;
+
+	if (unlikely(vlan_tx_tag_present(skb))) {
+		int err;
+
+		err = put_vlan(skb);
+		if (unlikely(err))
+			return err;
+
+	        vlan_set_tci(skb, 0);
+	}
+
+	if (skb_cow_head(skb, MPLS_HLEN) < 0) {
+		kfree_skb(skb);
+		return -ENOMEM;
+	}
+	skb_push(skb, MPLS_HLEN);
+
+	memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
+		ETH_HLEN);
+	skb_reset_mac_header(skb);
+
+	new_mpls_lse = (__be32 *)(skb_mac_header(skb) + ETH_HLEN);
+	*new_mpls_lse = mpls->mpls_lse;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
+							     MPLS_HLEN, 0));
+
+	hdr = eth_hdr(skb);
+	hdr->h_proto = mpls->mpls_ethertype;
+	if (!ovs_skb_get_inner_protocol(skb))
+		ovs_skb_set_inner_protocol(skb, skb->protocol);
+	skb->protocol = mpls->mpls_ethertype;
+	return 0;
+}
+
+static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
+{
+	struct ethhdr *hdr;
+	int err;
+
+	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
+	if (unlikely(err))
+		return err;
+
+	if (unlikely(skb->len < skb->mac_len + MPLS_HLEN))
+		return -EINVAL;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_sub(skb->csum,
+				     csum_partial(mac_header_end(skb),
+						  MPLS_HLEN, 0));
+
+	memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
+		skb->mac_len);
+
+	__skb_pull(skb, MPLS_HLEN);
+	skb_reset_mac_header(skb);
+
+	/* mac_header_end() is used to locate the ethertype
+	 * field correctly in the presence of VLAN tags.
+	 */
+	hdr = (struct ethhdr *)(mac_header_end(skb) - ETH_HLEN);
+	hdr->h_proto = ethertype;
+	if (eth_p_mpls(skb->protocol))
+		skb->protocol = ethertype;
+	return 0;
+}
+
+static int set_mpls(struct sk_buff *skb, const __be32 *mpls_lse)
+{
+	__be32 *stack = (__be32 *)mac_header_end(skb);
+	int err;
+
+	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
+	if (unlikely(err))
+		return err;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		__be32 diff[] = { ~(*stack), *mpls_lse };
+		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
+					  ~skb->csum);
+	}
+
+	*stack = *mpls_lse;
+
+	return 0;
+}
+
 static int set_eth_addr(struct sk_buff *skb,
 			const struct ovs_key_ethernet *eth_key)
 {
@@ -508,6 +622,9 @@ static int execute_set_action(struct sk_buff *skb,
 
 	case OVS_KEY_ATTR_SCTP:
 		err = set_sctp(skb, nla_data(nested_attr));
+
+	case OVS_KEY_ATTR_MPLS:
+		err = set_mpls(skb, nla_data(nested_attr));
 		break;
 	}
 
@@ -544,6 +661,16 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			output_userspace(dp, skb, a);
 			break;
 
+		case OVS_ACTION_ATTR_PUSH_MPLS:
+			err = push_mpls(skb, nla_data(a));
+			if (unlikely(err)) /* skb already freed. */
+				return err;
+			break;
+
+		case OVS_ACTION_ATTR_POP_MPLS:
+			err = pop_mpls(skb, nla_get_be16(a));
+			break;
+
 		case OVS_ACTION_ATTR_PUSH_VLAN:
 			err = push_vlan(skb, nla_data(a));
 			if (unlikely(err)) /* skb already freed. */
@@ -617,6 +744,8 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 		goto out_loop;
 	}
 
+	ovs_skb_init_inner_protocol(skb);
+
 	OVS_CB(skb)->tun_key = NULL;
 	error = do_execute_actions(dp, skb, acts->actions,
 					 acts->actions_len, false);
diff --git a/datapath/datapath.c b/datapath/datapath.c
index e4aa672..df146b1 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -512,7 +512,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_flow_free;
 
 	err = ovs_nla_copy_actions(a[OVS_PACKET_ATTR_ACTIONS],
-				   &flow->key, 0, &acts);
+				   &flow->key, &acts);
 	rcu_assign_pointer(flow->sf_acts, acts);
 	if (err)
 		goto err_flow_free;
@@ -786,7 +786,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 
 		ovs_flow_mask_key(&masked_key, &key, &mask);
 		error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS],
-					     &masked_key, 0, &acts);
+					     &masked_key, &acts);
 		if (error) {
 			OVS_NLERR("Flow actions may not be safe on all matching packets.\n");
 			goto err_kfree;
diff --git a/datapath/flow.c b/datapath/flow.c
index 57eb6b5..9817341 100644
--- a/datapath/flow.c
+++ b/datapath/flow.c
@@ -45,6 +45,7 @@
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 
+#include "mpls.h"
 #include "vlan.h"
 
 u64 ovs_flow_used_time(unsigned long flow_jiffies)
@@ -443,6 +444,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 		return -ENOMEM;
 
 	skb_reset_network_header(skb);
+	skb_reset_mac_len(skb);
 	__skb_push(skb, skb->data - skb_mac_header(skb));
 
 	/* Network layer. */
@@ -526,6 +528,33 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 			memcpy(key->ipv4.arp.sha, arp->ar_sha, ETH_ALEN);
 			memcpy(key->ipv4.arp.tha, arp->ar_tha, ETH_ALEN);
 		}
+	} else if (eth_p_mpls(key->eth.type)) {
+		size_t stack_len = MPLS_HLEN;
+
+		/* In the presence of an MPLS label stack the end of the L2
+		 * header and the beginning of the L3 header differ.
+		 *
+		 * Advance network_header to the beginning of the L3
+		 * header. mac_len corresponds to the end of the L2 header.
+		 */
+		while (1) {
+			__be32 lse;
+
+			error = check_header(skb, skb->mac_len + stack_len);
+			if (unlikely(error))
+				return 0;
+
+			memcpy(&lse, skb_network_header(skb), MPLS_HLEN);
+
+			if (stack_len == MPLS_HLEN)
+				memcpy(&key->mpls.top_lse, &lse, MPLS_HLEN);
+
+			skb_set_network_header(skb, skb->mac_len + stack_len);
+			if (lse & htonl(MPLS_BOS_MASK))
+				break;
+
+			stack_len += MPLS_HLEN;
+		}
 	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		int nh_len;             /* IPv6 Header + Extensions */
 
diff --git a/datapath/flow.h b/datapath/flow.h
index fdc309f..37c67c7 100644
--- a/datapath/flow.h
+++ b/datapath/flow.h
@@ -80,12 +80,17 @@ struct sw_flow_key {
 		__be16 tci;		/* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
 		__be16 type;		/* Ethernet frame type. */
 	} eth;
-	struct {
-		u8     proto;		/* IP protocol or lower 8 bits of ARP opcode. */
-		u8     tos;		/* IP ToS. */
-		u8     ttl;		/* IP TTL/hop limit. */
-		u8     frag;		/* One of OVS_FRAG_TYPE_*. */
-	} ip;
+	union {
+		struct {
+			__be32 top_lse;		/* top label stack entry */
+		} mpls;
+		struct {
+			u8     proto;		/* IP protocol or lower 8 bits of ARP opcode. */
+			u8     tos;		/* IP ToS. */
+			u8     ttl;		/* IP TTL/hop limit. */
+			u8     frag;		/* One of OVS_FRAG_TYPE_*. */
+		} ip;
+	};
 	union {
 		struct {
 			struct {
diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
index 75c72b3..cf1f9fe 100644
--- a/datapath/flow_netlink.c
+++ b/datapath/flow_netlink.c
@@ -18,6 +18,7 @@
 
 #include "flow.h"
 #include "datapath.h"
+#include "mpls.h"
 #include <linux/uaccess.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -120,7 +121,8 @@ static bool match_validate(const struct sw_flow_match *match,
 			| (1ULL << OVS_KEY_ATTR_ICMP)
 			| (1ULL << OVS_KEY_ATTR_ICMPV6)
 			| (1ULL << OVS_KEY_ATTR_ARP)
-			| (1ULL << OVS_KEY_ATTR_ND));
+			| (1ULL << OVS_KEY_ATTR_ND)
+			| (1ULL << OVS_KEY_ATTR_MPLS));
 
 	/* Always allowed mask fields. */
 	mask_allowed |= ((1ULL << OVS_KEY_ATTR_TUNNEL)
@@ -135,6 +137,13 @@ static bool match_validate(const struct sw_flow_match *match,
 			mask_allowed |= 1ULL << OVS_KEY_ATTR_ARP;
 	}
 
+
+	if (eth_p_mpls(match->key->eth.type)) {
+		key_expected |= 1ULL << OVS_KEY_ATTR_MPLS;
+		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
+			mask_allowed |= 1ULL << OVS_KEY_ATTR_MPLS;
+	}
+
 	if (match->key->eth.type == htons(ETH_P_IP)) {
 		key_expected |= 1ULL << OVS_KEY_ATTR_IPV4;
 		if (match->mask && (match->mask->key.eth.type == htons(0xffff)))
@@ -250,6 +259,7 @@ static const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
 	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
 	[OVS_KEY_ATTR_TUNNEL] = -1,
+	[OVS_KEY_ATTR_MPLS] = sizeof(struct ovs_key_mpls),
 };
 
 static bool is_all_zero(const u8 *fp, size_t size)
@@ -624,6 +634,16 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match,  u64 attrs,
 		attrs &= ~(1ULL << OVS_KEY_ATTR_ARP);
 	}
 
+	if (attrs & (1ULL << OVS_KEY_ATTR_MPLS)) {
+		const struct ovs_key_mpls *mpls_key;
+
+		mpls_key = nla_data(a[OVS_KEY_ATTR_MPLS]);
+		SW_FLOW_KEY_PUT(match, mpls.top_lse,
+				mpls_key->mpls_lse, is_mask);
+
+		attrs &= ~(1ULL << OVS_KEY_ATTR_MPLS);
+	 }
+
 	if (attrs & (1ULL << OVS_KEY_ATTR_TCP)) {
 		const struct ovs_key_tcp *tcp_key;
 
@@ -1009,6 +1029,14 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 		arp_key->arp_op = htons(output->ip.proto);
 		memcpy(arp_key->arp_sha, output->ipv4.arp.sha, ETH_ALEN);
 		memcpy(arp_key->arp_tha, output->ipv4.arp.tha, ETH_ALEN);
+	} else if (eth_p_mpls(swkey->eth.type)) {
+		struct ovs_key_mpls *mpls_key;
+
+		nla = nla_reserve(skb, OVS_KEY_ATTR_MPLS, sizeof(*mpls_key));
+		if (!nla)
+			goto nla_put_failure;
+		mpls_key = nla_data(nla);
+		mpls_key->mpls_lse = output->mpls.top_lse;
 	}
 
 	if ((swkey->eth.type == htons(ETH_P_IP) ||
@@ -1217,15 +1245,133 @@ static inline void add_nested_action_end(struct sw_flow_actions *sfa,
 
 	a->nla_len = sfa->actions_len - st_offset;
 }
+#define MAX_ETH_TYPES 16 /* Arbitrary Limit */
+
+/* struct eth_types - possible eth types
+ * @types: provides storage for the possible eth types.
+ * @start: is the index of the first entry of types which is possible.
+ * @end: is the index of the last entry of types which is possible.
+ * @cursor: is the index of the entry which should be updated if an action
+ * changes the eth type.
+ *
+ * Due to the sample action there may be multiple possible eth types.
+ * In order to correctly validate actions all possible types are tracked
+ * and verified. This is done using struct eth_types.
+ *
+ * Initially start, end and cursor should be 0, and the first element of
+ * types should be set to the eth type of the flow.
+ *
+ * When an action changes the eth type then the values of start and end are
+ * updated to the value of cursor. The new type is stored at types[cursor].
+ *
+ * When entering a sample action the start and cursor values are saved. The
+ * value of cursor is set to the value of end plus one.
+ *
+ * When leaving a sample action the start and cursor values are restored to
+ * their saved values.
+ *
+ * An example follows.
+ *
+ * actions: pop_mpls(A),sample(pop_mpls(B)),sample(pop_mpls(C)),pop_mpls(D)
+ *
+ * 0. Initial state:
+ *	types = { original_eth_type }
+ * 	start = end = cursor = 0;
+ *
+ * 1. pop_mpls(A)
+ *    a. Check types from start (0) to end (0) inclusive
+ *       i.e. Check against original_eth_type
+ *    b. Set start = end = cursor
+ *    c. Set types[cursor] = A
+ *    New state:
+ *	types = { A }
+ *	start = end = cursor = 0;
+ *
+ * 2. Enter first sample()
+ *    a. Save start and cursor
+ *    b. Set cursor = end + 1
+ *    New state:
+ *	types = { A }
+ *	start = end = 0;
+ *	cursor = 1;
+ *
+ * 3. pop_mpls(B)
+ *    a. Check types from start (0) to end (0)
+ *       i.e: Check against A
+ *    b. Set start = end = cursor
+ *    c. Set types[cursor] = B
+ *    New state:
+ *	types = { A, B }
+ *	start = end = cursor = 1;
+ *
+ * 4. Leave first sample()
+ *    a. Restore start and cursor to the values when entering 2.
+ *    New state:
+ *	types = { A, B }
+ *	start = cursor = 0;
+ *	end = 1;
+ *
+ * 5. Enter second sample()
+ *    a. Save start and cursor
+ *    b. Set cursor = end + 1
+ *    New state:
+ *	types = { A, B }
+ *	start = 0;
+ *	end = 1;
+ *	cursor = 2;
+ *
+ * 6. pop_mpls(C)
+ *    a. Check types from start (0) to end (1) inclusive
+ *       i.e: Check against A and B
+ *    b. Set start = end = cursor
+ *    c. Set types[cursor] = C
+ *    New state:
+ *	types = { A, B, C }
+ *	start = end = cursor = 2;
+ *
+ * 7. Leave second sample()
+ *    a. Restore start and cursor to the values when entering 5.
+ *    New state:
+ *	types = { A, B, C }
+ *	start = cursor = 0;
+ *	end = 2;
+ *
+ * 8. pop_mpls(D)
+ *    a. Check types from start (0) to end (2) inclusive
+ *       i.e: Check against A, B and C
+ *    b. Set start = end = cursor
+ *    c. Set types[cursor] = D
+ *    New state:
+ *	types = { D } // Trailing entries of type are no longer used end = 0
+ *	start = end = cursor = 0;
+ */
+struct eth_types {
+	int start, end, cursor;
+	__be16 types[MAX_ETH_TYPES];
+};
+
+static void eth_types_set(struct eth_types *types, __be16 type)
+{
+	types->start = types->end = types->cursor;
+	types->types[types->cursor] = type;
+}
+
+static int ovs_nla_copy_actions__(const struct nlattr *attr,
+				  const struct sw_flow_key *key,
+				  int depth,
+				  struct sw_flow_actions **sfa,
+				  struct eth_types *eth_types);
 
 static int validate_and_copy_sample(const struct nlattr *attr,
 				    const struct sw_flow_key *key, int depth,
-				    struct sw_flow_actions **sfa)
+				    struct sw_flow_actions **sfa,
+				    struct eth_types *eth_types)
 {
 	const struct nlattr *attrs[OVS_SAMPLE_ATTR_MAX + 1];
 	const struct nlattr *probability, *actions;
 	const struct nlattr *a;
 	int rem, start, err, st_acts;
+	int saved_eth_types_start, saved_eth_types_cursor;
 
 	memset(attrs, 0, sizeof(attrs));
 	nla_for_each_nested(a, attr, rem) {
@@ -1257,22 +1403,38 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 	if (st_acts < 0)
 		return st_acts;
 
-	err = ovs_nla_copy_actions(actions, key, depth + 1, sfa);
+	/* Save and update eth_types cursor and start.  Please see the
+	 * comment for struct eth_types for a discussion of this.
+	 */
+	saved_eth_types_start = eth_types->start;
+	saved_eth_types_cursor = eth_types->cursor;
+	eth_types->cursor = eth_types->end + 1;
+	if (eth_types->cursor == MAX_ETH_TYPES)
+		return -EINVAL;
+
+	err = ovs_nla_copy_actions__(actions, key, depth + 1, sfa, eth_types);
 	if (err)
 		return err;
 
+	/* Restore eth_types cursor and start.  Please see the
+	 * comment for struct eth_types for a discussion of this.
+	 */
+	eth_types->cursor = saved_eth_types_cursor;
+	eth_types->start = saved_eth_types_start;
+
 	add_nested_action_end(*sfa, st_acts);
 	add_nested_action_end(*sfa, start);
 
 	return 0;
 }
 
-static int validate_tp_port(const struct sw_flow_key *flow_key)
+static int validate_tp_port__(const struct sw_flow_key *flow_key,
+			      __be16 eth_type)
 {
-	if (flow_key->eth.type == htons(ETH_P_IP)) {
+	if (eth_type == htons(ETH_P_IP)) {
 		if (flow_key->ipv4.tp.src || flow_key->ipv4.tp.dst)
 			return 0;
-	} else if (flow_key->eth.type == htons(ETH_P_IPV6)) {
+	} else  if (eth_type == htons(ETH_P_IPV6)) {
 		if (flow_key->ipv6.tp.src || flow_key->ipv6.tp.dst)
 			return 0;
 	}
@@ -1280,6 +1442,21 @@ static int validate_tp_port(const struct sw_flow_key *flow_key)
 	return -EINVAL;
 }
 
+static int validate_tp_port(const struct sw_flow_key *flow_key,
+                           const struct eth_types *eth_types)
+{
+	int i;
+
+	for (i = eth_types->start; i < eth_types->end; i++) {
+		int ret = validate_tp_port__(flow_key, eth_types->types[i]);
+
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
 void ovs_match_init(struct sw_flow_match *match,
 		    struct sw_flow_key *key,
 		    struct sw_flow_mask *mask)
@@ -1322,7 +1499,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 static int validate_set(const struct nlattr *a,
 			const struct sw_flow_key *flow_key,
 			struct sw_flow_actions **sfa,
-			bool *set_tun)
+			bool *set_tun, struct eth_types *eth_types)
 {
 	const struct nlattr *ovs_key = nla_data(a);
 	int key_type = nla_type(ovs_key);
@@ -1353,9 +1530,12 @@ static int validate_set(const struct nlattr *a,
 			return err;
 		break;
 
-	case OVS_KEY_ATTR_IPV4:
-		if (flow_key->eth.type != htons(ETH_P_IP))
-			return -EINVAL;
+	case OVS_KEY_ATTR_IPV4: {
+		int i;
+
+		for (i = eth_types->start; i <= eth_types->end; i++)
+			if (eth_types->types[i] != htons(ETH_P_IP))
+				return -EINVAL;
 
 		if (!flow_key->ip.proto)
 			return -EINVAL;
@@ -1368,10 +1548,14 @@ static int validate_set(const struct nlattr *a,
 			return -EINVAL;
 
 		break;
+	}
 
-	case OVS_KEY_ATTR_IPV6:
-		if (flow_key->eth.type != htons(ETH_P_IPV6))
-			return -EINVAL;
+	case OVS_KEY_ATTR_IPV6: {
+		int i;
+
+		for (i = eth_types->start; i <= eth_types->end; i++)
+			if (eth_types->types[i] != htons(ETH_P_IPV6))
+				return -EINVAL;
 
 		if (!flow_key->ip.proto)
 			return -EINVAL;
@@ -1387,24 +1571,35 @@ static int validate_set(const struct nlattr *a,
 			return -EINVAL;
 
 		break;
+	}
+
 
 	case OVS_KEY_ATTR_TCP:
 		if (flow_key->ip.proto != IPPROTO_TCP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key);
+		return validate_tp_port(flow_key, eth_types);
 
 	case OVS_KEY_ATTR_UDP:
 		if (flow_key->ip.proto != IPPROTO_UDP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key);
+		return validate_tp_port(flow_key, eth_types);
+
+	case OVS_KEY_ATTR_MPLS: {
+		int i;
+
+		for (i = eth_types->start; i < eth_types->end; i++)
+			if (!eth_p_mpls(eth_types->types[i]))
+				return -EINVAL;
+		break;
+	}
 
 	case OVS_KEY_ATTR_SCTP:
 		if (flow_key->ip.proto != IPPROTO_SCTP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key);
+		return validate_tp_port(flow_key, eth_types);
 
 	default:
 		return -EINVAL;
@@ -1448,10 +1643,11 @@ static int copy_action(const struct nlattr *from,
 	return 0;
 }
 
-int ovs_nla_copy_actions(const struct nlattr *attr,
-			 const struct sw_flow_key *key,
-			 int depth,
-			 struct sw_flow_actions **sfa)
+static int ovs_nla_copy_actions__(const struct nlattr *attr,
+				  const struct sw_flow_key *key,
+				  int depth,
+				  struct sw_flow_actions **sfa,
+				  struct eth_types *eth_types)
 {
 	const struct nlattr *a;
 	int rem, err;
@@ -1464,6 +1660,8 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 		static const u32 action_lens[OVS_ACTION_ATTR_MAX + 1] = {
 			[OVS_ACTION_ATTR_OUTPUT] = sizeof(u32),
 			[OVS_ACTION_ATTR_USERSPACE] = (u32)-1,
+			[OVS_ACTION_ATTR_PUSH_MPLS] = sizeof(struct ovs_action_push_mpls),
+			[OVS_ACTION_ATTR_POP_MPLS] = sizeof(__be16),
 			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
 			[OVS_ACTION_ATTR_POP_VLAN] = 0,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
@@ -1506,14 +1704,44 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 				return -EINVAL;
 			break;
 
+		case OVS_ACTION_ATTR_PUSH_MPLS: {
+			const struct ovs_action_push_mpls *mpls = nla_data(a);
+			if (!eth_p_mpls(mpls->mpls_ethertype))
+				return -EINVAL;
+			eth_types_set(eth_types, mpls->mpls_ethertype);
+			break;
+		}
+
+		case OVS_ACTION_ATTR_POP_MPLS: {
+			int i;
+
+			for (i = eth_types->start; i <= eth_types->end; i++)
+				if (!eth_p_mpls(eth_types->types[i]))
+					return -EINVAL;
+
+			/* Disallow subsequent L2.5+ set and mpls_pop actions
+			 * as there is no check here to ensure that the new
+			 * eth_type is valid and thus set actions could
+			 * write off the end of the packet or otherwise
+			 * corrupt it.
+			 *
+			 * Support for these actions is planned using packet
+			 * recirculation.
+			 */
+			eth_types_set(eth_types, htons(0));
+			break;
+		}
+
 		case OVS_ACTION_ATTR_SET:
-			err = validate_set(a, key, sfa, &skip_copy);
+			err = validate_set(a, key, sfa, &skip_copy,
+					   eth_types);
 			if (err)
 				return err;
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-			err = validate_and_copy_sample(a, key, depth, sfa);
+			err = validate_and_copy_sample(a, key, depth, sfa,
+						       eth_types);
 			if (err)
 				return err;
 			skip_copy = true;
@@ -1535,6 +1763,20 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 	return 0;
 }
 
+int ovs_nla_copy_actions(const struct nlattr *attr,
+			 const struct sw_flow_key *key,
+			 struct sw_flow_actions **sfa)
+{
+	struct eth_types eth_type = {
+		.start = 0,
+		.end = 0,
+		.cursor = 0,
+		.types = { key->eth.type, },
+	};
+
+	return ovs_nla_copy_actions__(attr, key, 0, sfa, &eth_type);
+}
+
 static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
 {
 	const struct nlattr *a;
diff --git a/datapath/flow_netlink.h b/datapath/flow_netlink.h
index 4401510..b471ece 100644
--- a/datapath/flow_netlink.h
+++ b/datapath/flow_netlink.h
@@ -49,7 +49,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 		      const struct nlattr *);
 
 int ovs_nla_copy_actions(const struct nlattr *attr,
-			 const struct sw_flow_key *key, int depth,
+			 const struct sw_flow_key *key,
 			 struct sw_flow_actions **sfa);
 int ovs_nla_put_actions(const struct nlattr *attr,
 			int len, struct sk_buff *skb);
diff --git a/datapath/linux/compat/gso.c b/datapath/linux/compat/gso.c
index 32f906c..43f0d16 100644
--- a/datapath/linux/compat/gso.c
+++ b/datapath/linux/compat/gso.c
@@ -19,6 +19,7 @@
 #include <linux/module.h>
 #include <linux/if.h>
 #include <linux/if_tunnel.h>
+#include <linux/if_vlan.h>
 #include <linux/icmp.h>
 #include <linux/in.h>
 #include <linux/ip.h>
@@ -35,6 +36,8 @@
 #include <net/xfrm.h>
 
 #include "gso.h"
+#include "mpls.h"
+#include "vlan.h"
 
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37) && \
 	!defined(HAVE_VLAN_BUG_WORKAROUND)
@@ -47,10 +50,12 @@ MODULE_PARM_DESC(vlan_tso, "Enable TSO for VLAN packets");
 #define vlan_tso true
 #endif
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
 static bool dev_supports_vlan_tx(struct net_device *dev)
 {
-#if defined(HAVE_VLAN_BUG_WORKAROUND)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
+	return true;
+#elif defined(HAVE_VLAN_BUG_WORKAROUND)
 	return dev->features & NETIF_F_HW_VLAN_TX;
 #else
 	/* Assume that the driver is buggy. */
@@ -58,24 +63,64 @@ static bool dev_supports_vlan_tx(struct net_device *dev)
 #endif
 }
 
+/* Strictly this is not needed and will be optimised out
+ * as this code is guarded by if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0).
+ * It is here to make things explicit should the compatibility
+ * code be extended in some way prior extending its life-span
+ * beyond v3.11.
+ */
+static bool supports_mpls_gso(void)
+{
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
+	return true;
+#else
+	return false;
+#endif
+}
+
 int rpl_dev_queue_xmit(struct sk_buff *skb)
 {
 #undef dev_queue_xmit
 	int err = -ENOMEM;
+	bool vlan, mpls;
+
+	vlan = mpls = false;
+
+	if (eth_p_mpls(skb->protocol) && !supports_mpls_gso())
+		mpls = true;
+
+	if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev))
+		vlan = true;
 
-	if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev)) {
+	if (vlan || mpls) {
 		int features;
 
 		features = netif_skb_features(skb);
 
-		if (!vlan_tso)
-			features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
-				      NETIF_F_UFO | NETIF_F_FSO);
+		if (vlan) {
+			if (!vlan_tso)
+				features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
+					      NETIF_F_UFO | NETIF_F_FSO);
 
-		skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
-		if (unlikely(!skb))
-			return err;
-		vlan_set_tci(skb, 0);
+			skb = __vlan_put_tag(skb, skb->vlan_proto,
+					     vlan_tx_tag_get(skb));
+			if (unlikely(!skb))
+				return err;
+			vlan_set_tci(skb, 0);
+		}
+
+		/* As of v3.11 the kernel provides an mpls_features field in
+		 * struct net_device which allows devices to advertise which
+		 * features its supports for MPLS. This value defaults to
+		 * NETIF_F_SG and as of v3.11.
+		 *
+		 * This compatibility code is intended for kernels older
+		 * than v3.11 that do not support MPLS GSO and thus do not
+		 * provide mpls_features. Thus this code uses NETIF_F_SG
+		 * directly in place of mpls_features.
+		 */
+		if (mpls)
+			features &= NETIF_F_SG;
 
 		if (netif_needs_gso(skb, features)) {
 			struct sk_buff *nskb;
@@ -114,13 +159,15 @@ drop:
 	kfree_skb(skb);
 	return err;
 }
-#endif /* kernel version < 2.6.37 */
 
 static __be16 __skb_network_protocol(struct sk_buff *skb)
 {
 	__be16 type = skb->protocol;
 	int vlan_depth = ETH_HLEN;
 
+	if (eth_p_mpls(skb->protocol))
+		type = ovs_skb_get_inner_protocol(skb);
+
 	while (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
 		struct vlan_hdr *vh;
 
@@ -134,6 +181,7 @@ static __be16 __skb_network_protocol(struct sk_buff *skb)
 
 	return type;
 }
+#endif /* kernel version < 3.11.0 */
 
 static struct sk_buff *tnl_skb_gso_segment(struct sk_buff *skb,
 					   netdev_features_t features,
diff --git a/datapath/linux/compat/gso.h b/datapath/linux/compat/gso.h
index 44fd213..d7a9cea 100644
--- a/datapath/linux/compat/gso.h
+++ b/datapath/linux/compat/gso.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_GSO_WRAPPER_H
 #define __LINUX_GSO_WRAPPER_H
 
+#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/protocol.h>
 
@@ -11,6 +12,9 @@ struct ovs_gso_cb {
 	sk_buff_data_t	inner_network_header;
 	sk_buff_data_t	inner_mac_header;
 	void (*fix_segment)(struct sk_buff *);
+#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
+	__be16			inner_protocol;
+#endif
 };
 #define OVS_GSO_CB(skb) ((struct ovs_gso_cb *)(skb)->cb)
 
@@ -69,4 +73,41 @@ static inline void skb_reset_inner_headers(struct sk_buff *skb)
 
 #define ip_local_out rpl_ip_local_out
 int ip_local_out(struct sk_buff *skb);
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
+static inline void ovs_skb_init_inner_protocol(struct sk_buff *skb) {
+	OVS_GSO_CB(skb)->inner_protocol = htons(0);
+}
+
+static inline void ovs_skb_set_inner_protocol(struct sk_buff *skb,
+					      __be16 ethertype) {
+	OVS_GSO_CB(skb)->inner_protocol = ethertype;
+}
+
+static inline __be16 ovs_skb_get_inner_protocol(struct sk_buff *skb)
+{
+	return OVS_GSO_CB(skb)->inner_protocol;
+}
+
+#else
+
+static inline void ovs_skb_init_inner_protocol(struct sk_buff *skb) {
+	/* Nothing to do. The inner_protocol is either zero or
+	 * has been set to a value by another user.
+	 * Either way it may be considered initialised.
+	 */
+}
+
+static inline void ovs_skb_set_inner_protocol(struct sk_buff *skb,
+					      __be16 ethertype)
+{
+	skb->inner_protocol = ethertype;
+}
+
+static inline __be16 ovs_skb_get_inner_protocol(struct sk_buff *skb)
+{
+	return skb->inner_protocol;
+}
+#endif
+
 #endif
diff --git a/datapath/linux/compat/include/linux/netdevice.h b/datapath/linux/compat/include/linux/netdevice.h
index b303f39..4987d1c 100644
--- a/datapath/linux/compat/include/linux/netdevice.h
+++ b/datapath/linux/compat/include/linux/netdevice.h
@@ -60,10 +60,12 @@ static inline struct net_device *dev_get_by_index_rcu(struct net *net, int ifind
 #define NETIF_F_FSO 0
 #endif
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,38)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
 #define skb_gso_segment rpl_skb_gso_segment
 struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb, u32 features);
+#endif
 
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,38)
 #define netif_skb_features rpl_netif_skb_features
 u32 rpl_netif_skb_features(struct sk_buff *skb);
 
@@ -112,7 +114,7 @@ static inline struct net_device *netdev_master_upper_dev_get(struct net_device *
 }
 #endif
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
+#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
 #define dev_queue_xmit rpl_dev_queue_xmit
 int dev_queue_xmit(struct sk_buff *skb);
 #endif
diff --git a/datapath/linux/compat/netdevice.c b/datapath/linux/compat/netdevice.c
index 3d28a9b..e9efa7d 100644
--- a/datapath/linux/compat/netdevice.c
+++ b/datapath/linux/compat/netdevice.c
@@ -1,6 +1,9 @@
 #include <linux/netdevice.h>
 #include <linux/if_vlan.h>
 
+#include "mpls.h"
+#include "gso.h"
+
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,38)
 #ifndef HAVE_CAN_CHECKSUM_PROTOCOL
 static bool can_checksum_protocol(unsigned long features, __be16 protocol)
@@ -67,7 +70,9 @@ u32 rpl_netif_skb_features(struct sk_buff *skb)
 		return harmonize_features(skb, protocol, features);
 	}
 }
+#endif	/* kernel version < 2.6.38 */
 
+#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
 struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb, u32 features)
 {
 	int vlan_depth = ETH_HLEN;
@@ -75,6 +80,9 @@ struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb, u32 features)
 	__be16 skb_proto;
 	struct sk_buff *skb_gso;
 
+	if (eth_p_mpls(skb->protocol))
+		type = ovs_skb_get_inner_protocol(skb);
+
 	while (type == htons(ETH_P_8021Q)) {
 		struct vlan_hdr *vh;
 
@@ -95,4 +103,4 @@ struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb, u32 features)
 	skb->protocol = skb_proto;
 	return skb_gso;
 }
-#endif	/* kernel version < 2.6.38 */
+#endif	/* kernel version < 3.11.0 */
diff --git a/datapath/mpls.h b/datapath/mpls.h
new file mode 100644
index 0000000..7eab104
--- /dev/null
+++ b/datapath/mpls.h
@@ -0,0 +1,15 @@
+#ifndef MPLS_H
+#define MPLS_H 1
+
+#include <linux/if_ether.h>
+
+#define MPLS_BOS_MASK	0x00000100
+#define MPLS_HLEN 4
+
+static inline bool eth_p_mpls(__be16 eth_type)
+{
+	return eth_type == htons(ETH_P_MPLS_UC) ||
+		eth_type == htons(ETH_P_MPLS_MC);
+}
+
+#endif
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index b429201..63ab2fa 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -295,14 +295,13 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_TUNNEL,	/* Nested set of ovs_tunnel attributes */
 	OVS_KEY_ATTR_SCTP,      /* struct ovs_key_sctp */
 	OVS_KEY_ATTR_TCP_FLAGS,	/* be16 TCP flags. */
+	OVS_KEY_ATTR_MPLS,      /* array of struct ovs_key_mpls.
+				 * The implementation may restrict
+				 * the accepted length of the array. */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
 #endif
-
-	OVS_KEY_ATTR_MPLS = 62, /* array of struct ovs_key_mpls.
-				 * The implementation may restrict
-				 * the accepted length of the array. */
 	__OVS_KEY_ATTR_MAX
 };
 
-- 
1.8.4
