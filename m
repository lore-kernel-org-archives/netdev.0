From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.32] datapath: Add basic MPLS support to kernel
Date: Thu, 13 Jun 2013 16:42:04 +0900
Message-ID: <1371109324-17263-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40599 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756572Ab3FMHmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 03:42:15 -0400
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

This patch depends on "gre: Restructure tunneling" which it aims
to be compatible with.

This is the remaining patch of the series "MPLS actions and matches".
To aid review it and its dependency are available in git at:

        git://github.com/horms/openvswitch.git devel/mpls-v2.32


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
 datapath/actions.c                              | 130 +++++++++++-
 datapath/datapath.c                             | 254 +++++++++++++++++++++---
 datapath/datapath.h                             |   9 +
 datapath/flow.c                                 |  51 +++++
 datapath/flow.h                                 |  19 +-
 datapath/linux/compat/gso.c                     |  46 +++++
 datapath/linux/compat/gso.h                     |  36 ++++
 datapath/linux/compat/include/linux/netdevice.h |  12 --
 datapath/linux/compat/include/linux/skbuff.h    |   1 +
 datapath/linux/compat/netdevice.c               |  28 ---
 datapath/mpls.h                                 |  12 ++
 datapath/tunnel.c                               |   1 +
 datapath/vport-netdev.c                         |  28 ++-
 include/linux/openvswitch.h                     |   7 +-
 15 files changed, 556 insertions(+), 79 deletions(-)
 create mode 100644 datapath/mpls.h

diff --git a/datapath/Modules.mk b/datapath/Modules.mk
index 2ce8888..ad19807 100644
--- a/datapath/Modules.mk
+++ b/datapath/Modules.mk
@@ -26,6 +26,7 @@ openvswitch_headers = \
 	compat.h \
 	datapath.h \
 	flow.h \
+	mpls.h \
 	tunnel.h \
 	vlan.h \
 	vport.h \
diff --git a/datapath/actions.c b/datapath/actions.c
index 09d0c3f..7d81f70 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -34,6 +34,8 @@
 
 #include "checksum.h"
 #include "datapath.h"
+#include "gso.h"
+#include "mpls.h"
 #include "vlan.h"
 #include "vport.h"
 
@@ -48,6 +50,117 @@ static int make_writable(struct sk_buff *skb, int write_len)
 	return pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 }
 
+/* The end of the mac header.
+ *
+ * For non-MPLS skbs this will correspond to the network header.
+ * For MPLS skbs it will be berfore the network_header as the MPLS
+ * label stack lies between the end of the mac header and the network
+ * header. That is, for MPLS skbs the end of the mac header
+ * is the top of the MPLS label stack.
+ */
+static unsigned char *mac_header_end(const struct sk_buff *skb)
+{
+	return skb_mac_header(skb) + skb->mac_len;
+}
+
+static __be16 *get_ethertype(struct sk_buff *skb)
+{
+	/* skb_mac_header() is not used to locate the ethertype to
+	 * set as it will be incorrect in the presence of VLAN tags
+	 */
+	struct ethhdr *hdr = (struct ethhdr *)(mac_header_end(skb) - ETH_HLEN);
+	return &hdr->h_proto;
+}
+
+static void set_ethertype(struct sk_buff *skb, __be16 ethertype)
+{
+	__be16 *skb_ethertype = get_ethertype(skb);
+	*skb_ethertype = ethertype;
+}
+
+static int push_mpls(struct sk_buff *skb,
+		     const struct ovs_action_push_mpls *mpls)
+{
+	__be32 *new_mpls_lse;
+	int err;
+
+	if (skb_cow_head(skb, MPLS_HLEN) < 0)
+		return -ENOMEM;
+
+	err = make_writable(skb, skb->mac_len);
+	if (unlikely(err))
+		return err;
+
+	skb_push(skb, MPLS_HLEN);
+	memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
+		skb->mac_len);
+	skb_reset_mac_header(skb);
+
+	new_mpls_lse = (__be32 *)mac_header_end(skb);
+	*new_mpls_lse = mpls->mpls_lse;
+
+	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
+		skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
+							     MPLS_HLEN, 0));
+
+	/* If the skb was non-MPLS then record the original protocol
+	 * in skb->inner_protocol. This is to allow GSO to perform
+	 * segmentation of the inner-packet.
+	 */
+	if (!eth_p_mpls(skb->protocol))
+		ovs_skb_set_inner_protocol(skb, skb->protocol);
+
+	set_ethertype(skb, mpls->mpls_ethertype);
+	if (skb->protocol != htons(ETH_P_8021Q))
+		skb->protocol = mpls->mpls_ethertype;
+	return 0;
+}
+
+static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
+{
+	int err;
+
+	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
+	if (unlikely(err))
+		return err;
+
+	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
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
+	set_ethertype(skb, ethertype);
+	if (skb->protocol != htons(ETH_P_8021Q))
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
+	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE) {
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
 /* remove VLAN header from packet and update csum accordingly. */
 static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
 {
@@ -70,7 +183,7 @@ static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
 
 	vlan_set_encap_proto(skb, vhdr);
 	skb->mac_header += VLAN_HLEN;
-	skb_reset_mac_len(skb);
+	skb->mac_len -= VLAN_HLEN;
 
 	return 0;
 }
@@ -115,6 +228,9 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
 		if (!__vlan_put_tag(skb, current_tag))
 			return -ENOMEM;
 
+		/* update mac_len for mac_header_end() */
+		skb->mac_len += VLAN_HLEN;
+
 		if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
 			skb->csum = csum_add(skb->csum, csum_partial(skb->data
 					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
@@ -467,6 +583,10 @@ static int execute_set_action(struct sk_buff *skb,
 	case OVS_KEY_ATTR_UDP:
 		err = set_udp(skb, nla_data(nested_attr));
 		break;
+
+	case OVS_KEY_ATTR_MPLS:
+		err = set_mpls(skb, nla_data(nested_attr));
+		break;
 	}
 
 	return err;
@@ -502,6 +622,14 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			output_userspace(dp, skb, a);
 			break;
 
+		case OVS_ACTION_ATTR_PUSH_MPLS:
+			err = push_mpls(skb, nla_data(a));
+			break;
+
+		case OVS_ACTION_ATTR_POP_MPLS:
+			err = pop_mpls(skb, nla_get_be16(a));
+			break;
+
 		case OVS_ACTION_ATTR_PUSH_VLAN:
 			err = push_vlan(skb, nla_data(a));
 			if (unlikely(err)) /* skb already freed. */
diff --git a/datapath/datapath.c b/datapath/datapath.c
index 42af315..264b8b6 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -57,6 +57,8 @@
 #include "checksum.h"
 #include "datapath.h"
 #include "flow.h"
+#include "gso.h"
+#include "mpls.h"
 #include "vlan.h"
 #include "tunnel.h"
 #include "vport-internal_dev.h"
@@ -551,18 +553,132 @@ static inline void add_nested_action_end(struct sw_flow_actions *sfa, int st_off
 	a->nla_len = sfa->actions_len - st_offset;
 }
 
-static int validate_and_copy_actions(const struct nlattr *attr,
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
+static int validate_and_copy_actions__(const struct nlattr *attr,
 				const struct sw_flow_key *key, int depth,
-				struct sw_flow_actions **sfa);
+				struct sw_flow_actions **sfa,
+				struct eth_types *eth_types);
 
 static int validate_and_copy_sample(const struct nlattr *attr,
 			   const struct sw_flow_key *key, int depth,
-			   struct sw_flow_actions **sfa)
+			   struct sw_flow_actions **sfa,
+			   struct eth_types *eth_types)
 {
 	const struct nlattr *attrs[OVS_SAMPLE_ATTR_MAX + 1];
 	const struct nlattr *probability, *actions;
 	const struct nlattr *a;
 	int rem, start, err, st_acts;
+	int saved_eth_types_start, saved_eth_types_cursor;
 
 	memset(attrs, 0, sizeof(attrs));
 	nla_for_each_nested(a, attr, rem) {
@@ -593,22 +709,38 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 	if (st_acts < 0)
 		return st_acts;
 
-	err = validate_and_copy_actions(actions, key, depth + 1, sfa);
+	/* Save and update eth_types cursor and start.  Please see the
+	 * comment for struct eth_types for a discussion of this.
+	 */
+	saved_eth_types_start = eth_types->start;
+	saved_eth_types_cursor = eth_types->cursor;
+	eth_types->cursor = eth_types->end + 1;
+	if (eth_types->cursor == MAX_ETH_TYPES)
+		return -EINVAL;
+
+	err = validate_and_copy_actions__(actions, key, depth + 1, sfa,
+					  eth_types);
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
+static int validate_tp_port(const struct sw_flow_key *flow_key, __be16 eth_type)
 {
-	if (flow_key->eth.type == htons(ETH_P_IP)) {
+	if (eth_type == htons(ETH_P_IP)) {
 		if (flow_key->ipv4.tp.src || flow_key->ipv4.tp.dst)
 			return 0;
-	} else if (flow_key->eth.type == htons(ETH_P_IPV6)) {
+	} else 	if (eth_type == htons(ETH_P_IPV6)) {
 		if (flow_key->ipv6.tp.src || flow_key->ipv6.tp.dst)
 			return 0;
 	}
@@ -639,7 +771,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 static int validate_set(const struct nlattr *a,
 			const struct sw_flow_key *flow_key,
 			struct sw_flow_actions **sfa,
-			bool *set_tun)
+			bool *set_tun, struct eth_types *eth_types)
 {
 	const struct nlattr *ovs_key = nla_data(a);
 	int key_type = nla_type(ovs_key);
@@ -676,9 +808,12 @@ static int validate_set(const struct nlattr *a,
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
@@ -691,10 +826,14 @@ static int validate_set(const struct nlattr *a,
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
@@ -710,18 +849,37 @@ static int validate_set(const struct nlattr *a,
 			return -EINVAL;
 
 		break;
+	}
+
+	case OVS_KEY_ATTR_TCP: {
+		int i;
 
-	case OVS_KEY_ATTR_TCP:
 		if (flow_key->ip.proto != IPPROTO_TCP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key);
+		for (i = eth_types->start; i <= eth_types->end; i++)
+			if (validate_tp_port(flow_key, eth_types->types[i]))
+				return -EINVAL;
+	}
 
-	case OVS_KEY_ATTR_UDP:
+	case OVS_KEY_ATTR_UDP: {
+		int i;
 		if (flow_key->ip.proto != IPPROTO_UDP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key);
+		for (i = eth_types->start; i <= eth_types->end; i++)
+			if (validate_tp_port(flow_key, eth_types->types[i]))
+				return -EINVAL;
+	}
+
+	case OVS_KEY_ATTR_MPLS: {
+		int i;
+
+		for (i = eth_types->start; i < eth_types->end; i++)
+			if (!eth_p_mpls(eth_types->types[i]))
+				return -EINVAL;
+		break;
+	}
 
 	default:
 		return -EINVAL;
@@ -765,10 +923,10 @@ static int copy_action(const struct nlattr *from,
 	return 0;
 }
 
-static int validate_and_copy_actions(const struct nlattr *attr,
-				const struct sw_flow_key *key,
-				int depth,
-				struct sw_flow_actions **sfa)
+static int validate_and_copy_actions__(const struct nlattr *attr,
+				const struct sw_flow_key *key, int depth,
+				struct sw_flow_actions **sfa,
+				struct eth_types *eth_types)
 {
 	const struct nlattr *a;
 	int rem, err;
@@ -781,6 +939,8 @@ static int validate_and_copy_actions(const struct nlattr *attr,
 		static const u32 action_lens[OVS_ACTION_ATTR_MAX + 1] = {
 			[OVS_ACTION_ATTR_OUTPUT] = sizeof(u32),
 			[OVS_ACTION_ATTR_USERSPACE] = (u32)-1,
+			[OVS_ACTION_ATTR_PUSH_MPLS] = sizeof(struct ovs_action_push_mpls),
+			[OVS_ACTION_ATTR_POP_MPLS] = sizeof(__be16),
 			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
 			[OVS_ACTION_ATTR_POP_VLAN] = 0,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
@@ -811,6 +971,33 @@ static int validate_and_copy_actions(const struct nlattr *attr,
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
 
 		case OVS_ACTION_ATTR_POP_VLAN:
 			break;
@@ -824,13 +1011,14 @@ static int validate_and_copy_actions(const struct nlattr *attr,
 			break;
 
 		case OVS_ACTION_ATTR_SET:
-			err = validate_set(a, key, sfa, &skip_copy);
+			err = validate_set(a, key, sfa, &skip_copy, eth_types);
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
@@ -852,6 +1040,20 @@ static int validate_and_copy_actions(const struct nlattr *attr,
 	return 0;
 }
 
+static int validate_and_copy_actions(const struct nlattr *attr,
+				const struct sw_flow_key *key,
+				struct sw_flow_actions **sfa)
+{
+	struct eth_types eth_type = {
+		.start = 0,
+		.end = 0,
+		.cursor = 0,
+		.types = { key->eth.type, },
+	};
+
+	return validate_and_copy_actions__(attr, key, 0, sfa, &eth_type);
+}
+
 static void clear_stats(struct sw_flow *flow)
 {
 	flow->used = 0;
@@ -916,7 +1118,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(acts))
 		goto err_flow_free;
 
-	err = validate_and_copy_actions(a[OVS_PACKET_ATTR_ACTIONS], &flow->key, 0, &acts);
+	err = validate_and_copy_actions(a[OVS_PACKET_ATTR_ACTIONS], &flow->key, &acts);
 	rcu_assign_pointer(flow->sf_acts, acts);
 	if (err)
 		goto err_flow_free;
@@ -1252,7 +1454,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		if (IS_ERR(acts))
 			goto error;
 
-		error = validate_and_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &key,  0, &acts);
+		error = validate_and_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &key, &acts);
 		if (error)
 			goto err_kfree;
 	} else if (info->genlhdr->cmd == OVS_FLOW_CMD_NEW) {
diff --git a/datapath/datapath.h b/datapath/datapath.h
index ad59a3a..f779d1b 100644
--- a/datapath/datapath.h
+++ b/datapath/datapath.h
@@ -38,6 +38,10 @@
 
 #define SAMPLE_ACTION_DEPTH 3
 
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
+#define HAVE_INNER_PROTOCOL
+#endif
+
 /**
  * struct dp_stats_percpu - per-cpu packet processing statistics for a given
  * datapath.
@@ -101,6 +105,8 @@ struct datapath {
  * packet was not received on a tunnel.
  * @vlan_tci: Provides a substitute for the skb->vlan_tci field on kernels
  * before 2.6.27.
+ * @inner_protocol: Provides a substitute for the skb->inner_protocol field on
+ * kernels before 3.11.
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
@@ -112,6 +118,9 @@ struct ovs_skb_cb {
 #ifdef NEED_VLAN_FIELD
 	u16			vlan_tci;
 #endif
+#ifndef HAVE_INNER_PROTOCOL
+	__be16			inner_protocol;
+#endif
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
diff --git a/datapath/flow.c b/datapath/flow.c
index 1f5a8e5..ed38ac4 100644
--- a/datapath/flow.c
+++ b/datapath/flow.c
@@ -43,10 +43,13 @@
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 
+#include "mpls.h"
 #include "vlan.h"
 
 static struct kmem_cache *flow_cache;
 
+#define MPLS_BOS_MASK	0x00000100
+
 static int check_header(struct sk_buff *skb, int len)
 {
 	if (unlikely(skb->len < len))
@@ -650,6 +653,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 		return -ENOMEM;
 
 	skb_reset_network_header(skb);
+	skb_reset_mac_len(skb);
 	__skb_push(skb, skb->data - skb_mac_header(skb));
 
 	/* Network layer. */
@@ -732,6 +736,35 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 			memcpy(key->ipv4.arp.tha, arp->ar_tha, ETH_ALEN);
 			key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
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
+				goto out;
+
+			memcpy(&lse, skb_network_header(skb), MPLS_HLEN);
+
+			if (stack_len == MPLS_HLEN) {
+				key_len = SW_FLOW_KEY_OFFSET(mpls.top_lse);
+				memcpy(&key->mpls.top_lse, &lse, MPLS_HLEN);
+			}
+
+			skb_set_network_header(skb, skb->mac_len + stack_len);
+			if (lse & htonl(MPLS_BOS_MASK))
+				break;
+
+			stack_len += MPLS_HLEN;
+		}
 	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		int nh_len;             /* IPv6 Header + Extensions */
 
@@ -850,6 +883,7 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
 	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
 	[OVS_KEY_ATTR_TUNNEL] = -1,
+	[OVS_KEY_ATTR_MPLS] = sizeof(struct ovs_key_mpls),
 };
 
 static int ipv4_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_len,
@@ -1256,6 +1290,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		swkey->ip.proto = ntohs(arp_key->arp_op);
 		memcpy(swkey->ipv4.arp.sha, arp_key->arp_sha, ETH_ALEN);
 		memcpy(swkey->ipv4.arp.tha, arp_key->arp_tha, ETH_ALEN);
+	} else if (eth_p_mpls(swkey->eth.type)) {
+		const struct ovs_key_mpls *mpls_key;
+		if (!(attrs & (1ULL << OVS_KEY_ATTR_MPLS)))
+			return -EINVAL;
+		attrs &= ~(1ULL << OVS_KEY_ATTR_MPLS);
+
+		key_len = SW_FLOW_KEY_OFFSET(mpls.top_lse);
+		mpls_key = nla_data(a[OVS_KEY_ATTR_MPLS]);
+		swkey->mpls.top_lse = mpls_key->mpls_lse;
 	}
 
 	if (attrs)
@@ -1422,6 +1465,14 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 		arp_key->arp_op = htons(swkey->ip.proto);
 		memcpy(arp_key->arp_sha, swkey->ipv4.arp.sha, ETH_ALEN);
 		memcpy(arp_key->arp_tha, swkey->ipv4.arp.tha, ETH_ALEN);
+	} else if (eth_p_mpls(swkey->eth.type)) {
+		struct ovs_key_mpls *mpls_key;
+
+		nla = nla_reserve(skb, OVS_KEY_ATTR_MPLS, sizeof(*mpls_key));
+		if (!nla)
+			goto nla_put_failure;
+		mpls_key = nla_data(nla);
+		mpls_key->mpls_lse = swkey->mpls.top_lse;
 	}
 
 	if ((swkey->eth.type == htons(ETH_P_IP) ||
diff --git a/datapath/flow.h b/datapath/flow.h
index dfffed7..bc17fab 100644
--- a/datapath/flow.h
+++ b/datapath/flow.h
@@ -69,12 +69,17 @@ struct sw_flow_key {
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
@@ -140,6 +145,8 @@ struct arp_eth_header {
 	unsigned char       ar_tip[4];		/* target IP address        */
 } __packed;
 
+#define MPLS_HLEN 4
+
 int ovs_flow_init(void);
 void ovs_flow_exit(void);
 
diff --git a/datapath/linux/compat/gso.c b/datapath/linux/compat/gso.c
index 8cb2e06..c084ee4 100644
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
@@ -35,12 +36,20 @@
 #include <net/xfrm.h>
 
 #include "gso.h"
+#include "mpls.h"
+#include "vlan.h"
 
+#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
 static __be16 skb_network_protocol(struct sk_buff *skb)
 {
 	__be16 type = skb->protocol;
+	__be16 inner_proto;
 	int vlan_depth = ETH_HLEN;
 
+	inner_proto = ovs_skb_get_inner_protocol(skb);
+	if (eth_p_mpls(skb->protocol) && !eth_p_mpls(inner_proto))
+		type = inner_proto;
+
 	while (type == htons(ETH_P_8021Q) || type == htons(ETH_P_8021AD)) {
 		struct vlan_hdr *vh;
 
@@ -55,6 +64,43 @@ static __be16 skb_network_protocol(struct sk_buff *skb)
 	return type;
 }
 
+struct sk_buff *rpl___skb_gso_segment(struct sk_buff *skb,
+				      netdev_features_t features,
+				      bool tx_path)
+{
+	struct sk_buff *skb_gso;
+	__be16 type = skb->protocol;
+
+	skb->protocol = skb_network_protocol(skb);
+
+	/* this hack needed to get regular skb_gso_segment() */
+#ifdef HAVE___SKB_GSO_SEGMENT
+#undef __skb_gso_segment
+	skb_gso = skb_gso_segment(skb, features, tx_path);
+#else
+#undef skb_gso_segment
+	skb_gso = skb_gso_segment(skb, features);
+#endif
+
+	if (!skb_gso || IS_ERR(skb_gso))
+	    return skb_gso;
+
+	skb = skb_gso;
+	while (skb) {
+		skb->protocol = type;
+		skb = skb->next;
+	}
+
+	return skb_gso;
+}
+
+struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb,
+				    netdev_features_t features)
+{
+	return rpl___skb_gso_segment(skb, features, true);
+}
+#endif /* kernel version < 3.11.0 */
+
 static struct sk_buff *tnl_skb_gso_segment(struct sk_buff *skb,
 					   netdev_features_t features,
 					   bool tx_path)
diff --git a/datapath/linux/compat/gso.h b/datapath/linux/compat/gso.h
index 44fd213..a8bc3b0 100644
--- a/datapath/linux/compat/gso.h
+++ b/datapath/linux/compat/gso.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_GSO_WRAPPER_H
 #define __LINUX_GSO_WRAPPER_H
 
+#include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <net/protocol.h>
 
@@ -69,4 +70,39 @@ static inline void skb_reset_inner_headers(struct sk_buff *skb)
 
 #define ip_local_out rpl_ip_local_out
 int ip_local_out(struct sk_buff *skb);
+
+#ifdef HAVE_INNER_PROTOCOL
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
+#else
+static inline void ovs_skb_set_inner_protocol(struct sk_buff *skb,
+					      __be16 ethertype) {
+	OVS_CB(skb)->inner_protocol = ethertype;
+}
+
+static inline __be16 ovs_skb_get_inner_protocol(struct sk_buff *skb)
+{
+	return OVS_CB(skb)->inner_protocol;
+}
+#endif
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
+#define skb_gso_segment rpl_skb_gso_segment
+struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb,
+				    netdev_features_t features);
+
+#define __skb_gso_segment rpl___skb_gso_segment
+struct sk_buff *rpl___skb_gso_segment(struct sk_buff *skb,
+				      netdev_features_t features,
+				      bool tx_path);
+#endif /* before 3.11 */
+
 #endif
diff --git a/datapath/linux/compat/include/linux/netdevice.h b/datapath/linux/compat/include/linux/netdevice.h
index 644e7d7..c98317d 100644
--- a/datapath/linux/compat/include/linux/netdevice.h
+++ b/datapath/linux/compat/include/linux/netdevice.h
@@ -140,9 +140,6 @@ static inline struct net_device *dev_get_by_index_rcu(struct net *net, int ifind
 #endif
 
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,38)
-#define skb_gso_segment rpl_skb_gso_segment
-struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb, u32 features);
-
 #define netif_skb_features rpl_netif_skb_features
 u32 rpl_netif_skb_features(struct sk_buff *skb);
 
@@ -158,15 +155,6 @@ static inline int rpl_netif_needs_gso(struct sk_buff *skb, int features)
 typedef u32 netdev_features_t;
 #endif
 
-#ifndef HAVE___SKB_GSO_SEGMENT
-static inline struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
-						netdev_features_t features,
-						bool tx_path)
-{
-	return skb_gso_segment(skb, features);
-}
-#endif
-
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
 #define skb_has_frag_list skb_has_frags
 #endif
diff --git a/datapath/linux/compat/include/linux/skbuff.h b/datapath/linux/compat/include/linux/skbuff.h
index d485b39..02a0193 100644
--- a/datapath/linux/compat/include/linux/skbuff.h
+++ b/datapath/linux/compat/include/linux/skbuff.h
@@ -251,4 +251,5 @@ static inline void skb_reset_mac_len(struct sk_buff *skb)
 	skb->mac_len = skb->network_header - skb->mac_header;
 }
 #endif
+
 #endif
diff --git a/datapath/linux/compat/netdevice.c b/datapath/linux/compat/netdevice.c
index d26fb5e..ef0f155 100644
--- a/datapath/linux/compat/netdevice.c
+++ b/datapath/linux/compat/netdevice.c
@@ -71,32 +71,4 @@ u32 rpl_netif_skb_features(struct sk_buff *skb)
 		return harmonize_features(skb, protocol, features);
 	}
 }
-
-struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb, u32 features)
-{
-	int vlan_depth = ETH_HLEN;
-	__be16 type = skb->protocol;
-	__be16 skb_proto;
-	struct sk_buff *skb_gso;
-
-	while (type == htons(ETH_P_8021Q)) {
-		struct vlan_hdr *vh;
-
-		if (unlikely(!pskb_may_pull(skb, vlan_depth + VLAN_HLEN)))
-			return ERR_PTR(-EINVAL);
-
-		vh = (struct vlan_hdr *)(skb->data + vlan_depth);
-		type = vh->h_vlan_encapsulated_proto;
-		vlan_depth += VLAN_HLEN;
-	}
-
-	/* this hack needed to get regular skb_gso_segment() */
-#undef skb_gso_segment
-	skb_proto = skb->protocol;
-	skb->protocol = type;
-
-	skb_gso = skb_gso_segment(skb, features);
-	skb->protocol = skb_proto;
-	return skb_gso;
-}
 #endif	/* kernel version < 2.6.38 */
diff --git a/datapath/mpls.h b/datapath/mpls.h
new file mode 100644
index 0000000..e72f2e7
--- /dev/null
+++ b/datapath/mpls.h
@@ -0,0 +1,12 @@
+#ifndef MPLS_H
+#define MPLS_H 1
+
+#include <linux/if_ether.h>
+
+static inline bool eth_p_mpls(__be16 eth_type)
+{
+	return eth_type == htons(ETH_P_MPLS_UC) ||
+		eth_type == htons(ETH_P_MPLS_MC);
+}
+
+#endif
diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index 9102786..162a099 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -33,6 +33,7 @@
 #include "checksum.h"
 #include "compat.h"
 #include "datapath.h"
+#include "gso.h"
 #include "tunnel.h"
 #include "vlan.h"
 #include "vport.h"
diff --git a/datapath/vport-netdev.c b/datapath/vport-netdev.c
index fe7e359..b2b0e99 100644
--- a/datapath/vport-netdev.c
+++ b/datapath/vport-netdev.c
@@ -30,6 +30,8 @@
 
 #include "checksum.h"
 #include "datapath.h"
+#include "gso.h"
+#include "mpls.h"
 #include "vlan.h"
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
@@ -299,6 +301,8 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 	struct netdev_vport *netdev_vport = netdev_vport_priv(vport);
 	int mtu = netdev_vport->dev->mtu;
 	int len;
+	__be16 inner_protocol;
+	bool vlan, mpls;
 
 	if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
 		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
@@ -310,8 +314,17 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 	skb->dev = netdev_vport->dev;
 	forward_ip_summed(skb, true);
 
-	if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev)) {
-		int features;
+	vlan = mpls = false;
+
+	inner_protocol = ovs_skb_get_inner_protocol(skb);
+	if (eth_p_mpls(skb->protocol) && !eth_p_mpls(inner_protocol))
+		mpls = true;
+
+	if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev))
+		vlan = true;
+
+	if (vlan || mpls) {
+		netdev_features_t features;
 
 		features = netif_skb_features(skb);
 
@@ -319,6 +332,17 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
 			features &= ~(NETIF_F_TSO | NETIF_F_TSO6 |
 				      NETIF_F_UFO | NETIF_F_FSO);
 
+		/* As of v3.11 the kernel provides an mpls_features field in
+		 * struct net_device which allows devices to advertise which
+		 * features its supports for MPLS. This value defaults to
+		 * NETIF_F_SG and as of writing is not overridden anywhere.
+		 * This compatibility code is intended for older kernels which
+		 * do not support MPLS GSO and thus do not provide
+		 * mpls_features. Thus this code uses NETIF_F_SG directly in
+		 * place of mpls_features. */
+		if (mpls)
+			features &= NETIF_F_SG;
+
 		if (netif_needs_gso(skb, features)) {
 			struct sk_buff *nskb;
 
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index e890fd8..ba21b53 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -282,14 +282,13 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_ND,        /* struct ovs_key_nd */
 	OVS_KEY_ATTR_SKB_MARK,  /* u32 skb mark */
 	OVS_KEY_ATTR_TUNNEL,	/* Nested set of ovs_tunnel attributes */
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
1.8.2.1
