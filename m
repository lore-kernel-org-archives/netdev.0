From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] datapath: Add basic MPLS support to kernel
Date: Thu, 25 Apr 2013 16:58:58 +0900
Message-ID: <1366876738-29688-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>,
	jarno.rajahalme@nsn.com
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:35645 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730Ab3DYH7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 03:59:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow datapath to recognize and extract MPLS labels into flow keys
and execute actions which push, pop, and set labels on packets.

Based heavily on work by Leo Alterman and Ravi K.

Cc: Ravi K <rkerur@gmail.com>
Cc: Leo Alterman <lalterman@nicira.com>
Reviewed-by: Isaku Yamahata <yamahata@valinux.co.jp>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

This is the remaining patch of the series "MPLS actions and matches".
To aid review it is available in git at:

        git://github.com/horms/openvswitch.git devel/mpls-v2.27

TODO:
* Finalise kernel network core side of GSO. That will likely require
  minor updates to this patch.

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
 acinclude.m4                                 |   7 ++
 datapath/actions.c                           | 137 ++++++++++++++++++++++++-
 datapath/datapath.c                          | 148 ++++++++++++++++++++++-----
 datapath/flow.c                              |  47 +++++++++
 datapath/flow.h                              |  25 +++--
 datapath/linux/compat/include/linux/skbuff.h |  10 ++
 include/linux/openvswitch.h                  |   6 +-
 lib/odp-util.c                               |   8 +-
 8 files changed, 349 insertions(+), 39 deletions(-)

diff --git a/acinclude.m4 b/acinclude.m4
index 911a23d..04da8a4 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -254,6 +254,13 @@ AC_DEFUN([OVS_CHECK_LINUX_COMPAT], [
   OVS_GREP_IFELSE([$KSRC/include/linux/skbuff.h], [consume_skb])
   OVS_GREP_IFELSE([$KSRC/include/linux/skbuff.h], [skb_frag_page])
   OVS_GREP_IFELSE([$KSRC/include/linux/skbuff.h], [skb_reset_mac_len])
+  # If encapsulation_features is merged upstream then a release number may
+  # be used to select compatibility code and the following check may be
+  # removed. This check is here for now to allow Open vSwtich to provide
+  # an example of how encapsulation_features may be used to provide
+  # GSO of non-MPLS GSO skbs that are turned into MPLS GSO skbs
+  # using MPLS push actions
+  OVS_GREP_IFELSE([$KSRC/include/linux/skbuff.h], [encapsulation_features])
 
   OVS_GREP_IFELSE([$KSRC/include/linux/string.h], [kmemdup], [],
                   [OVS_GREP_IFELSE([$KSRC/include/linux/slab.h], [kmemdup])])
diff --git a/datapath/actions.c b/datapath/actions.c
index 0dac658..0e4a16a 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -48,6 +48,111 @@ static int make_writable(struct sk_buff *skb, int write_len)
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
+static inline unsigned char *skb_mac_header_end(const struct sk_buff *skb)
+{
+	return skb_mac_header(skb) + skb->mac_len;
+}
+
+static __be16 *get_ethertype(struct sk_buff *skb)
+{
+	/* skb_mac_header hdr is not used to locate the ethertype to
+	 * set as it will be incorrect in the presence of VLAN tags
+	 */
+	struct ethhdr *hdr = (struct ethhdr *)(skb_mac_header_end(skb) -
+					       ETH_HLEN);
+	return &hdr->h_proto;
+}
+
+static void set_ethertype(struct sk_buff *skb, const __be16 ethertype)
+{
+	__be16 *skb_ethertype = get_ethertype(skb);
+	if (*skb_ethertype == ethertype)
+		return;
+	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE) {
+		__be16 diff[] = { ~*skb_ethertype, ethertype };
+		skb->csum = ~csum_partial((char *)diff, sizeof(diff),
+					  ~skb->csum);
+	}
+	*skb_ethertype = ethertype;
+}
+
+static int push_mpls(struct sk_buff *skb,
+		     const struct ovs_action_push_mpls *mpls)
+{
+	__be32 *new_mpls_lse;
+	int err;
+
+	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
+	if (unlikely(err))
+		return err;
+
+	skb_push(skb, MPLS_HLEN);
+	memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
+		skb->mac_len);
+	skb_reset_mac_header(skb);
+
+	new_mpls_lse = (__be32 *)skb_mac_header_end(skb);
+	*new_mpls_lse = mpls->mpls_lse;
+
+	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
+		skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
+							     MPLS_HLEN, 0));
+
+	set_ethertype(skb, mpls->mpls_ethertype);
+	return 0;
+}
+
+static int pop_mpls(struct sk_buff *skb, const __be16 *ethertype)
+{
+	int err;
+
+	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
+	if (unlikely(err))
+		return err;
+
+	if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
+		skb->csum = csum_sub(skb->csum,
+				     csum_partial(skb_mac_header_end(skb),
+						  MPLS_HLEN, 0));
+
+	memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
+		skb->mac_len);
+
+	skb_pull(skb, MPLS_HLEN);
+	skb_reset_mac_header(skb);
+
+	set_ethertype(skb, *ethertype);
+	return 0;
+}
+
+static int set_mpls(struct sk_buff *skb, const __be32 *mpls_lse)
+{
+	__be32 *stack = (__be32 *)skb_mac_header_end(skb);
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
@@ -115,6 +220,9 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
 		if (!__vlan_put_tag(skb, current_tag))
 			return -ENOMEM;
 
+		/* update mac_len for skb_mac_header_end() */
+		skb_reset_mac_len(skb);
+
 		if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
 			skb->csum = csum_add(skb->csum, csum_partial(skb->data
 					+ (2 * ETH_ALEN), VLAN_HLEN, 0));
@@ -355,10 +463,20 @@ static int set_tcp(struct sk_buff *skb, const struct ovs_key_tcp *tcp_port_key)
 static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
 {
 	struct vport *vport;
+	__be16 *ethertype = get_ethertype(skb);
 
 	if (unlikely(!skb))
 		return -ENOMEM;
 
+	/* Consider MPLS packets as encapsulated.
+	 *
+	 * This allows GSO segmentation to occur
+	 * by forcing hw_features to be used when determining
+	 * if checksum offload is available or not.
+	 */
+	if (eth_p_mpls(*ethertype))
+		skb_set_encapsulation_features(skb);
+
 	vport = ovs_vport_rcu(dp, out_port);
 	if (unlikely(!vport)) {
 		kfree_skb(skb);
@@ -459,12 +577,21 @@ static int execute_set_action(struct sk_buff *skb,
 	case OVS_KEY_ATTR_UDP:
 		err = set_udp(skb, nla_data(nested_attr));
 		break;
+
+	case OVS_KEY_ATTR_MPLS:
+		err = set_mpls(skb, nla_data(nested_attr));
+		break;
 	}
 
 	return err;
 }
 
-/* Execute a list of actions against 'skb'. */
+/* Execute a list of actions against 'skb'.
+ *
+ * The stack depth is only tracked in the case of a non-MPLS packet
+ * that becomes MPLS via an MPLS push action. The stack depth
+ * is passed to do_output() in order to allow it to prepare the
+ * skb for possible GSO segmentation. */
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			const struct nlattr *attr, int len, bool keep_skb)
 {
@@ -494,6 +621,14 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			output_userspace(dp, skb, a);
 			break;
 
+		case OVS_ACTION_ATTR_PUSH_MPLS:
+			err = push_mpls(skb, nla_data(a));
+			break;
+
+		case OVS_ACTION_ATTR_POP_MPLS:
+			err = pop_mpls(skb, nla_data(a));
+			break;
+
 		case OVS_ACTION_ATTR_PUSH_VLAN:
 			err = push_vlan(skb, nla_data(a));
 			if (unlikely(err)) /* skb already freed. */
diff --git a/datapath/datapath.c b/datapath/datapath.c
index 3cb58b0..e4ed5e0 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -550,13 +550,26 @@ static inline void add_nested_action_end(struct sw_flow_actions *sfa, int st_off
 	a->nla_len = sfa->actions_len - st_offset;
 }
 
-static int validate_and_copy_actions(const struct nlattr *attr,
+struct eth_types {
+	size_t depth;
+	__be16 types[SAMPLE_ACTION_DEPTH];
+};
+
+static void eth_types_set(struct eth_types *types, size_t depth, __be16 type)
+{
+	types->depth = depth;
+	types->types[depth] = type;
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
@@ -592,7 +605,8 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 	if (st_acts < 0)
 		return st_acts;
 
-	err = validate_and_copy_actions(actions, key, depth + 1, sfa);
+	err = validate_and_copy_actions__(actions, key, depth + 1, sfa,
+					  eth_types);
 	if (err)
 		return err;
 
@@ -602,12 +616,12 @@ static int validate_and_copy_sample(const struct nlattr *attr,
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
@@ -638,7 +652,7 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 static int validate_set(const struct nlattr *a,
 			const struct sw_flow_key *flow_key,
 			struct sw_flow_actions **sfa,
-			bool *set_tun)
+			bool *set_tun, struct eth_types *eth_types)
 {
 	const struct nlattr *ovs_key = nla_data(a);
 	int key_type = nla_type(ovs_key);
@@ -675,9 +689,12 @@ static int validate_set(const struct nlattr *a,
 			return err;
 		break;
 
-	case OVS_KEY_ATTR_IPV4:
-		if (flow_key->eth.type != htons(ETH_P_IP))
-			return -EINVAL;
+	case OVS_KEY_ATTR_IPV4: {
+		size_t i;
+
+		for (i = 0; i < eth_types->depth; i++)
+			if (eth_types->types[i] != htons(ETH_P_IP))
+				return -EINVAL;
 
 		if (!flow_key->ip.proto)
 			return -EINVAL;
@@ -690,10 +707,14 @@ static int validate_set(const struct nlattr *a,
 			return -EINVAL;
 
 		break;
+	}
 
-	case OVS_KEY_ATTR_IPV6:
-		if (flow_key->eth.type != htons(ETH_P_IPV6))
-			return -EINVAL;
+	case OVS_KEY_ATTR_IPV6: {
+		size_t i;
+
+		for (i = 0; i < eth_types->depth; i++)
+			if (eth_types->types[i] != htons(ETH_P_IPV6))
+				return -EINVAL;
 
 		if (!flow_key->ip.proto)
 			return -EINVAL;
@@ -709,18 +730,37 @@ static int validate_set(const struct nlattr *a,
 			return -EINVAL;
 
 		break;
+	}
+
+	case OVS_KEY_ATTR_TCP: {
+		size_t i;
 
-	case OVS_KEY_ATTR_TCP:
 		if (flow_key->ip.proto != IPPROTO_TCP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key);
+		for (i = 0; i < eth_types->depth; i++)
+			if (validate_tp_port(flow_key, eth_types->types[i]))
+				return -EINVAL;
+	}
 
-	case OVS_KEY_ATTR_UDP:
+	case OVS_KEY_ATTR_UDP: {
+		size_t i;
 		if (flow_key->ip.proto != IPPROTO_UDP)
 			return -EINVAL;
 
-		return validate_tp_port(flow_key);
+		for (i = 0; i < eth_types->depth; i++)
+			if (validate_tp_port(flow_key, eth_types->types[i]))
+				return -EINVAL;
+	}
+
+	case OVS_KEY_ATTR_MPLS: {
+		size_t i;
+
+		for (i = 0; i < eth_types->depth; i++)
+			if (!eth_p_mpls(eth_types->types[i]))
+				return -EINVAL;
+		break;
+	}
 
 	default:
 		return -EINVAL;
@@ -764,10 +804,10 @@ static int copy_action(const struct nlattr *from,
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
@@ -775,11 +815,29 @@ static int validate_and_copy_actions(const struct nlattr *attr,
 	if (depth >= SAMPLE_ACTION_DEPTH)
 		return -EOVERFLOW;
 
+	/* Due to the sample action there may be more than one possibility
+	 * for the current ethernet type. They all need to be verified.
+	 *
+	 * This is handled by tracking a stack of ethernet types, one for
+	 * each (sample) depth of validation. Here the ethernet type for
+	 * the current depth is pushed onto the stack. It may be modified
+	 * as by actions are validated. When a modification occurs the
+	 * ethernet types for higher stack-depths are popped off the stack.
+	 * All entries on the stack are checked when validating the
+	 * ethernet type required by an action.
+	 */
+	if (!depth)
+		eth_types_set(eth_types, 0, key->eth.type);
+	else
+		eth_types_set(eth_types, depth, eth_types->types[depth - 1]);
+
 	nla_for_each_nested(a, attr, rem) {
 		/* Expected argument lengths, (u32)-1 for variable length. */
 		static const u32 action_lens[OVS_ACTION_ATTR_MAX + 1] = {
 			[OVS_ACTION_ATTR_OUTPUT] = sizeof(u32),
 			[OVS_ACTION_ATTR_USERSPACE] = (u32)-1,
+			[OVS_ACTION_ATTR_PUSH_MPLS] = sizeof(struct ovs_action_push_mpls),
+			[OVS_ACTION_ATTR_POP_MPLS] = sizeof(__be16),
 			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
 			[OVS_ACTION_ATTR_POP_VLAN] = 0,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
@@ -810,6 +868,35 @@ static int validate_and_copy_actions(const struct nlattr *attr,
 				return -EINVAL;
 			break;
 
+		case OVS_ACTION_ATTR_PUSH_MPLS: {
+			const struct ovs_action_push_mpls *mpls = nla_data(a);
+			if (!eth_p_mpls(mpls->mpls_ethertype))
+				return -EINVAL;
+			eth_types_set(eth_types, depth, mpls->mpls_ethertype);
+			break;
+		}
+
+		case OVS_ACTION_ATTR_POP_MPLS: {
+			size_t i;
+
+			for (i = 0; i < eth_types->depth; i++)
+				if (eth_types->types[i] != htons(ETH_P_IP))
+					return -EINVAL;
+
+			/* Disallow subsequent l2.5+ set and mpls_pop actions
+			 * as there is no check here to ensure that the new
+			 * eth_type is valid and thus set actions could
+			 * write off the end of the packet or otherwise
+			 * corrupt it.
+			 *
+			 * Support for these actions that after mpls_pop
+			 * using packet recirculation is planned.
+			 * are planned to be supported using using packet
+			 * recirculation.
+			 */
+			eth_types_set(eth_types, depth, htons(0));
+			break;
+		}
 
 		case OVS_ACTION_ATTR_POP_VLAN:
 			break;
@@ -823,13 +910,14 @@ static int validate_and_copy_actions(const struct nlattr *attr,
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
@@ -851,6 +939,14 @@ static int validate_and_copy_actions(const struct nlattr *attr,
 	return 0;
 }
 
+static int validate_and_copy_actions(const struct nlattr *attr,
+				const struct sw_flow_key *key,
+				struct sw_flow_actions **sfa)
+{
+	struct eth_types eth_type;
+	return validate_and_copy_actions__(attr, key, 0, sfa, &eth_type);
+}
+
 static void clear_stats(struct sw_flow *flow)
 {
 	flow->used = 0;
@@ -915,7 +1011,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(acts))
 		goto err_flow_free;
 
-	err = validate_and_copy_actions(a[OVS_PACKET_ATTR_ACTIONS], &flow->key, 0, &acts);
+	err = validate_and_copy_actions(a[OVS_PACKET_ATTR_ACTIONS], &flow->key, &acts);
 	rcu_assign_pointer(flow->sf_acts, acts);
 	if (err)
 		goto err_flow_free;
@@ -1251,7 +1347,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		if (IS_ERR(acts))
 			goto error;
 
-		error = validate_and_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &key,  0, &acts);
+		error = validate_and_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &key,  &acts);
 		if (error)
 			goto err_kfree;
 	} else if (info->genlhdr->cmd == OVS_FLOW_CMD_NEW) {
diff --git a/datapath/flow.c b/datapath/flow.c
index 3ce926e..d9c8b9e 100644
--- a/datapath/flow.c
+++ b/datapath/flow.c
@@ -47,6 +47,8 @@
 
 static struct kmem_cache *flow_cache;
 
+#define MPLS_BOS_MASK	0x00000100
+
 static int check_header(struct sk_buff *skb, int len)
 {
 	if (unlikely(skb->len < len))
@@ -648,6 +650,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 		return -ENOMEM;
 
 	skb_reset_network_header(skb);
+	skb_reset_mac_len(skb);
 	__skb_push(skb, skb->data - skb_mac_header(skb));
 
 	/* Network layer. */
@@ -730,6 +733,30 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 			memcpy(key->ipv4.arp.tha, arp->ar_tha, ETH_ALEN);
 			key_len = SW_FLOW_KEY_OFFSET(ipv4.arp);
 		}
+	} else if (eth_p_mpls(key->eth.type)) {
+		size_t stack_len = MPLS_HLEN;
+
+		while (1) {
+			__be32 lse;
+
+			error = check_header(skb, stack_len);
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
+			/* Advance network_header to bottom of MPLS label
+			 * stack. mac_len corresponds to the top of the stack.
+			 */
+			skb_set_network_header(skb, skb->mac_len + stack_len);
+			if (lse & htonl(MPLS_BOS_MASK))
+				break;
+		}
 	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		int nh_len;             /* IPv6 Header + Extensions */
 
@@ -848,6 +875,9 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
 	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
 	[OVS_KEY_ATTR_TUNNEL] = -1,
+
+	/* Not upstream. */
+	[OVS_KEY_ATTR_MPLS] = sizeof(struct ovs_key_mpls),
 };
 
 static int ipv4_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_len,
@@ -1254,6 +1284,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
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
@@ -1420,6 +1459,14 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
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
index dba66cf..2e3083b 100644
--- a/datapath/flow.h
+++ b/datapath/flow.h
@@ -72,12 +72,17 @@ struct sw_flow_key {
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
@@ -143,6 +148,8 @@ struct arp_eth_header {
 	unsigned char       ar_tip[4];		/* target IP address        */
 } __packed;
 
+#define MPLS_HLEN 4
+
 int ovs_flow_init(void);
 void ovs_flow_exit(void);
 
@@ -204,4 +211,10 @@ int ipv4_tun_from_nlattr(const struct nlattr *attr,
 int ipv4_tun_to_nlattr(struct sk_buff *skb,
 			const struct ovs_key_ipv4_tunnel *tun_key);
 
+static inline bool eth_p_mpls(__be16 eth_type)
+{
+	return eth_type == htons(ETH_P_MPLS_UC) ||
+		eth_type == htons(ETH_P_MPLS_MC);
+}
+
 #endif /* flow.h */
diff --git a/datapath/linux/compat/include/linux/skbuff.h b/datapath/linux/compat/include/linux/skbuff.h
index d485b39..f620a0a 100644
--- a/datapath/linux/compat/include/linux/skbuff.h
+++ b/datapath/linux/compat/include/linux/skbuff.h
@@ -251,4 +251,14 @@ static inline void skb_reset_mac_len(struct sk_buff *skb)
 	skb->mac_len = skb->network_header - skb->mac_header;
 }
 #endif
+
+#ifdef HAVE_ENCAPSULATION_FEATURES
+static inline void skb_set_encapsulation_features(struct sk_buff *skb)
+{
+	skb->encapsulation_features = 1;
+}
+#else
+/* MPLS GSO is not supported */
+static inline void skb_set_encapsulation_features(struct sk_buff *skb) { }
+#endif
 #endif
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index bd2f05f..e890fd8 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -287,7 +287,9 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
 #endif
 
-	OVS_KEY_ATTR_MPLS = 62, /* struct ovs_key_mpls */
+	OVS_KEY_ATTR_MPLS = 62, /* array of struct ovs_key_mpls.
+				 * The implementation may restrict
+				 * the accepted length of the array. */
 	__OVS_KEY_ATTR_MAX
 };
 
@@ -330,7 +332,7 @@ struct ovs_key_ethernet {
 };
 
 struct ovs_key_mpls {
-	__be32 mpls_top_lse;
+	__be32 mpls_lse;
 };
 
 struct ovs_key_ipv4 {
diff --git a/lib/odp-util.c b/lib/odp-util.c
index 1988c63..ae09267 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -942,7 +942,7 @@ format_odp_key_attr(const struct nlattr *a, struct ds *ds)
     case OVS_KEY_ATTR_MPLS: {
         const struct ovs_key_mpls *mpls_key = nl_attr_get(a);
         ds_put_char(ds, '(');
-        format_mpls_lse(ds, mpls_key->mpls_top_lse);
+        format_mpls_lse(ds, mpls_key->mpls_lse);
         ds_put_char(ds, ')');
         break;
     }
@@ -1267,7 +1267,7 @@ parse_odp_key_attr(const char *s, const struct simap *port_names,
 
             mpls = nl_msg_put_unspec_uninit(key, OVS_KEY_ATTR_MPLS,
                                             sizeof *mpls);
-            mpls->mpls_top_lse = mpls_lse_from_components(label, tc, ttl, bos);
+            mpls->mpls_lse = mpls_lse_from_components(label, tc, ttl, bos);
             return n;
         }
     }
@@ -1630,7 +1630,7 @@ odp_flow_key_from_flow(struct ofpbuf *buf, const struct flow *flow,
 
         mpls_key = nl_msg_put_unspec_uninit(buf, OVS_KEY_ATTR_MPLS,
                                             sizeof *mpls_key);
-        mpls_key->mpls_top_lse = flow->mpls_lse;
+        mpls_key->mpls_lse = flow->mpls_lse;
     }
 
     if (is_ip_any(flow) && !(flow->nw_frag & FLOW_NW_FRAG_LATER)) {
@@ -2285,7 +2285,7 @@ commit_mpls_action(const struct flow *flow, struct flow *base,
     } else {
         struct ovs_key_mpls mpls_key;
 
-        mpls_key.mpls_top_lse = flow->mpls_lse;
+        mpls_key.mpls_lse = flow->mpls_lse;
         commit_set_action(odp_actions, OVS_KEY_ATTR_MPLS,
                           &mpls_key, sizeof(mpls_key));
     }
-- 
1.8.2.1
