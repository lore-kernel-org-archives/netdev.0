From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH v2.56] datapath: Add basic MPLS support to
 kernel
Date: Wed, 30 Apr 2014 14:58:08 +0900
Message-ID: <20140430055807.GA8246@verge.net.au>
References: <20140424232441.GA6282@verge.net.au>
 <20140425080639.DDFA371E74@kuma.localdomain>
 <CAEP_g=8y=jXukP=a2xyk4XMTrBLYWPQOgbTO_h8LE_mVMB9tFQ@mail.gmail.com>
 <20140428070012.GB21494@verge.net.au>
 <CAEP_g=-p1Zrs7ETjRrSLK+ug0Y7tbsF5U77K29tYyMTDk_0b4Q@mail.gmail.com>
 <20140429001317.GB31083@verge.net.au>
 <CAEP_g=8Or4axD_1Ztuc8+LHVZUKs6W0bsfNQxOHzGGENS0br-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	ravi kerur <rkerur@gmail.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53772 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021AbaD3F6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 01:58:11 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8Or4axD_1Ztuc8+LHVZUKs6W0bsfNQxOHzGGENS0br-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 11:41:57AM -0700, Jesse Gross wrote:
> On Mon, Apr 28, 2014 at 5:13 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Mon, Apr 28, 2014 at 02:37:47PM -0700, Jesse Gross wrote:
> >> On Mon, Apr 28, 2014 at 12:00 AM, Simon Horman <horms@verge.net.au> wrote:
> >> > On Fri, Apr 25, 2014 at 12:57:20PM -0700, Jesse Gross wrote:
> >> >> On Fri, Apr 25, 2014 at 1:06 AM, YAMAMOTO Takashi
> >> >> <yamamoto@valinux.co.jp> wrote:
> >> >> >> On Thu, Apr 24, 2014 at 05:57:29PM +0900, YAMAMOTO Takashi wrote:
> >> >> >>> hi,
> >> >> >>>
> >> >> >>> > + * Due to the sample action there may be multiple possible eth types.
> >> >> >>> > + * In order to correctly validate actions all possible types are tracked
> >> >> >>> > + * and verified. This is done using struct eth_types.
> >> >> >>>
> >> >> >>> is there any real-world use cases of these actions inside a sample?
> >> >> >>> otherwise, how about just rejecting such combinations?
> >> >> >>> it doesn't seem to worth the code complexity to me.
> >> >> >>> (sorry if it has been already discussed.  it's the first time for me
> >> >> >>> to seriously read this long-lived patch.)
> >> >> >>
> >> >> >> Good point, the code is rather complex.
> >> >> >>
> >> >> >> My understanding is that it comes into effect in the case
> >> >> >> of sflow or ipfix being configured on the bridge. I tend
> >> >> >> to think these are real-world use-cases, though that thinking
> >> >> >> is by no means fixed.
> >> >> >>
> >> >> >> My reading of the code is that in the case of sflow and ipfix a single
> >> >> >> sample rule appears at the beginning of the flow. And that it may be
> >> >> >> possible to replace the code that you are referring to with something
> >> >> >> simpler to handle these cases.
> >> >> >
> >> >> > it seems that they put only a userland action inside a sample.
> >> >> > it's what i expected from its name "sample".
> >> >>
> >> >> Yes, that's the only current use case. In theory, this could be used
> >> >> more generally although nothing has come up yet.
> >> >>
> >> >> In retrospect, I regret the design of the sample action - not the part
> >> >> that allows it to handle different actions but the fact that the
> >> >> results can affect things outside of the sample action list. I think
> >> >> that if we had made it more like a subroutine then that would have
> >> >> retained all of the functionality but none of the complexity here.
> >> >> Perhaps if we can find a clean way to restructure it without breaking
> >> >> compatibility then that would simplify the validation here.
> >> >
> >> > I have not thought deeply about this but it seems to me that it should be
> >> > easy enough to provide compatibility for a new user-space to work with both
> >> > new and old datapaths.  But it is not clear to me how to achieve the
> >> > reverse: allowing a new datapath to work with both new and old user-spaces.
> >> > I assume that we care about such compatibility.
> >>
> >> Generally, I would say yes although there is potentially some room for
> >> debate here. No version of OVS userspace has ever put an action other
> >> than userspace in the sample field. I know that other people have
> >> talked about writing different userspaces that run on the OVS kernel
> >> module but I highly doubt that they use this action or would do so
> >> differently. I can't prove that but it might be OK to bite the bullet.
> >
> > I am also concerned about the sample() action which is exposed via OpenFlow
> > (as a Nicira extension) and in turn ovs-ofctl.  Thus it seems to me that
> > there could be users adding flows with sample actions whose behaviour would
> > either no longer be supported or would be changed.  But I believe that we
> > should reason about this case the same way that you reason about alternate
> > user-spaces above.
> 
> The sample action exposed through OpenFlow is a little different. It
> allows you to specify where in the action list to do sampling but it
> doesn't allow arbitrary actions to be embedded. As a result, it still
> always embeds a userspace action, which should be safe because it is
> idempotent.

Thanks, that nicely removes my concern.

> > Perhaps a way forward would be (for me) to come up with a prototype to
> > alter the sample action. And we can see how clean it is (or could be) and
> > what it buys us.
> >
> > It seems that the motivation for this change is is twofold: To contain the
> > sample action in the hope of making it easier to deal with in the future
> > and; to avoid some rather complex verification code introduced in the MPLS
> > datapath patch. And I think it would be good to keep that in mind when
> > assessing any prototype code.
> 
> That sounds reasonable to me.

I have come up with the following.

In terms of gains, using this approach I have reduced the size of MPLS
datapath patch by about 170 lines by replacing the complex logic that
Yamamoto-san questioned with a simple verification of the current ethernet
type (which may be changed by MPLS action).


[PATCH/RFC] Sample action without side effects

The sample action is rather generic, allowing arbitrary actions to be
executed based on a probability. However its use, within the Open vSwitch
code-base is limited: only a single user-space action is ever nested.

A consequence of the current implementation of sample actions is that
depending on weather the sample action executed (due to its probability)
any side-effects of nested actions may or may not be present before
executing subsequent actions.  This has the potential to complicate
verification of valid actions by the (kernel) datapath. And indeed adding
support for push and pop MPLS actions inside sample actions is one case
where such case.

In order to allow all supported actions to be continue to be nested
inside sample actions without the potential need for complex verification
code this patch changes the implementation of the sample action in the
kernel datapath so that sample actions are more like a function call
and any side effects of nested actions are not present when executing
subsequent actions.

With the above in mind the motivation for this change is twofold:

* To contain side-effects the sample action in the hope of making it
  easier to deal with in the future and;
* To avoid some rather complex verification code introduced in the MPLS
  datapath patch.

Some notes about the implementation:

* The OVS_SAMPLE_ATTR_FLAGS portion of this patch, which contributes to a
  good portion of the size of the patch is intended to prevent any users
  that were relying on side effects from sample actions from being silently
  broken.

  Any rule that includes a sample action with nested actions that
  may have side effects (e.g. set, push/pop VLAN) will be rejected
  unless OVS_SAMPLE_ATTR_FLAGS is present and its
  OVS_SAMPLE_FLAG_SIDE_EFFECTS bit is set.

  Thus users that were relying on side effects will experience rules
  being rejected by the datapath. Rather than being silently handled
  a different way.

  It seems to me that it is rather unlikely that such users exist.
  And thus it seems reasonable to me to remove the OVS_SAMPLE_ATTR_FLAGS
  portion of this patch.

* It is my understanding that the only user of the user-space datapath is
  ovs-vswitchd.

  As ovs-vswitchd never adds rules to the datapath that have sample actions
  with nested actions with side effects I have not updated the user-space
  datapath other than to call OVS_NOT_REACHED() if a sample action includes
  the new OVS_SAMPLE_ATTR_FLAGS attribute. Primarily to make the
  compiler happy about all values of the ovs_sample_attr enumeration
  being handled by the case statement where that code resides.

  My reasoning is follows:

  + If the user-space datapath executes a sample action with nested
    actions with side effects then it will be done so in the old way.
    That is differently to the kernel datapath. But this will never happen
    because ovs-vswitchd never creates such an action.

  + If the OVS_SAMPLE_ATTR_FLAGS attribute is present when executing a
    sample action in the user-space datapath then ovs-vswtichd will abort. But
    again this will never happen because ovs-vswitchd never creates such
    an action.

Signed-off-by: Simon Horman <horms@verge.net.au>

---
 datapath/actions.c          | 16 +++++++++++++---
 datapath/flow_netlink.c     | 30 +++++++++++++++++++++++++-----
 include/linux/openvswitch.h | 11 +++++++++++
 lib/odp-execute.c           |  1 +
 lib/odp-util.c              | 20 ++++++++++++++++++++
 5 files changed, 70 insertions(+), 8 deletions(-)

diff --git a/datapath/actions.c b/datapath/actions.c
index 5871d82..e3e1bc1 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -606,12 +606,22 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			err = execute_set_action(skb, nla_data(a));
 			break;
 
-		case OVS_ACTION_ATTR_SAMPLE:
-			err = sample(dp, skb, a);
-			if (unlikely(err)) /* skb already freed. */
+		case OVS_ACTION_ATTR_SAMPLE: {
+			struct sk_buff *sample_skb;
+			const bool last_action = (a->nla_len == rem);
+
+			if (!last_action || keep_skb)
+				sample_skb = skb_clone(skb, GFP_ATOMIC);
+			else
+				sample_skb = skb;
+
+			err = sample(dp, sample_skb, a);
+			if (unlikely(err && sample_skb == skb))
+				/* skb already freed. */
 				return err;
 			break;
 		}
+		}
 
 		if (unlikely(err)) {
 			kfree_skb(skb);
diff --git a/datapath/flow_netlink.c b/datapath/flow_netlink.c
index 803a94c..365ddea 100644
--- a/datapath/flow_netlink.c
+++ b/datapath/flow_netlink.c
@@ -1205,9 +1205,10 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 				    struct sw_flow_actions **sfa)
 {
 	const struct nlattr *attrs[OVS_SAMPLE_ATTR_MAX + 1];
-	const struct nlattr *probability, *actions;
+	const struct nlattr *probability, *actions, *flags;
 	const struct nlattr *a;
 	int rem, start, err, st_acts;
+	bool allow_side_effects = false;
 
 	memset(attrs, 0, sizeof(attrs));
 	nla_for_each_nested(a, attr, rem) {
@@ -1227,6 +1228,21 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 	if (!actions || (nla_len(actions) && nla_len(actions) < NLA_HDRLEN))
 		return -EINVAL;
 
+	/* The flags attribute is optional */
+	flags = attrs[OVS_SAMPLE_ATTR_FLAGS];
+	if (flags) {
+		u32 flags_val;
+
+		if (nla_len(flags) != sizeof(u32))
+			return -EINVAL;
+
+		flags_val = nla_get_u32(flags);
+		if (flags_val & ~OVS_SAMPLE_FLAG_SIDE_EFFECTS)
+			return -EINVAL;
+		if (flags_val & OVS_SAMPLE_FLAG_SIDE_EFFECTS)
+			allow_side_effects = true;
+	}
+
 	/* validation done, copy sample action. */
 	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE);
 	if (start < 0)
@@ -1240,8 +1256,8 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 		return st_acts;
 
 	err = ovs_nla_copy_actions(actions, key, depth + 1, sfa);
-	if (err)
-		return err;
+	if (err < 0 || (err > 0 && !allow_side_effects))
+		return -EINVAL;
 
 	add_nested_action_end(*sfa, st_acts);
 	add_nested_action_end(*sfa, start);
@@ -1434,6 +1450,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 {
 	const struct nlattr *a;
 	int rem, err;
+	bool side_effect = false;
 
 	if (depth >= SAMPLE_ACTION_DEPTH)
 		return -EOVERFLOW;
@@ -1489,9 +1506,11 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 		}
 
 		case OVS_ACTION_ATTR_POP_VLAN:
+			side_effect = true;
 			break;
 
 		case OVS_ACTION_ATTR_PUSH_VLAN:
+			side_effect = true;
 			vlan = nla_data(a);
 			if (vlan->vlan_tpid != htons(ETH_P_8021Q))
 				return -EINVAL;
@@ -1503,6 +1522,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 			break;
 
 		case OVS_ACTION_ATTR_SET:
+			side_effect = true;
 			err = validate_set(a, key, sfa, &skip_copy);
 			if (err)
 				return err;
@@ -1510,7 +1530,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = validate_and_copy_sample(a, key, depth, sfa);
-			if (err)
+			if (err < 0)
 				return err;
 			skip_copy = true;
 			break;
@@ -1528,7 +1548,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 	if (rem > 0)
 		return -EINVAL;
 
-	return 0;
+	return (side_effect && depth) ? 1 : 0;
 }
 
 static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index d7f85ff..4d3ab9c 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -478,6 +478,14 @@ enum ovs_flow_attr {
 
 #define OVS_FLOW_ATTR_MAX (__OVS_FLOW_ATTR_MAX - 1)
 
+enum ovs_sample_flags {
+	OVS_SAMPLE_FLAG_SIDE_EFFECTS = 1 << 0, /* Allow actions with side
+						* effects in sample actions.
+						* The side effects are contained
+						* within the execution of the
+						* sample action. */
+};
+
 /**
  * enum ovs_sample_attr - Attributes for %OVS_ACTION_ATTR_SAMPLE action.
  * @OVS_SAMPLE_ATTR_PROBABILITY: 32-bit fraction of packets to sample with
@@ -486,6 +494,8 @@ enum ovs_flow_attr {
  * fractions of packets.
  * @OVS_SAMPLE_ATTR_ACTIONS: Set of actions to execute in sampling event.
  * Actions are passed as nested attributes.
+ * @OVS_SAMPLE_ATTR_FLAGS: Bitmap of enum ovs_sample_flags values.
+ *                         If absent a bitmap of all zeros is assumed.
  *
  * Executes the specified actions with the given probability on a per-packet
  * basis.
@@ -494,6 +504,7 @@ enum ovs_sample_attr {
 	OVS_SAMPLE_ATTR_UNSPEC,
 	OVS_SAMPLE_ATTR_PROBABILITY, /* u32 number */
 	OVS_SAMPLE_ATTR_ACTIONS,     /* Nested OVS_ACTION_ATTR_* attributes. */
+	OVS_SAMPLE_ATTR_FLAGS,       /* u32 number which is a bitmap of */
 	__OVS_SAMPLE_ATTR_MAX,
 };
 
diff --git a/lib/odp-execute.c b/lib/odp-execute.c
index 12ad679..3dfe9a4 100644
--- a/lib/odp-execute.c
+++ b/lib/odp-execute.c
@@ -179,6 +179,7 @@ odp_execute_sample(void *dp, struct ofpbuf *packet, bool steal,
             subactions = a;
             break;
 
+        case OVS_SAMPLE_ATTR_FLAGS:
         case OVS_SAMPLE_ATTR_UNSPEC:
         case __OVS_SAMPLE_ATTR_MAX:
         default:
diff --git a/lib/odp-util.c b/lib/odp-util.c
index af464a0..75a65fa 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -149,11 +149,23 @@ format_generic_odp_action(struct ds *ds, const struct nlattr *a)
     }
 }
 
+static const char *
+sample_flags_to_string(uint32_t flag)
+{
+    switch (flag) {
+    case OVS_SAMPLE_FLAG_SIDE_EFFECTS:
+        return "side_effects";
+    default:
+        return NULL;
+    }
+}
+
 static void
 format_odp_sample_action(struct ds *ds, const struct nlattr *attr)
 {
     static const struct nl_policy ovs_sample_policy[] = {
         [OVS_SAMPLE_ATTR_PROBABILITY] = { .type = NL_A_U32 },
+        [OVS_SAMPLE_ATTR_FLAGS] = { .type = NL_A_U32, .optional = true },
         [OVS_SAMPLE_ATTR_ACTIONS] = { .type = NL_A_NESTED }
     };
     struct nlattr *a[ARRAY_SIZE(ovs_sample_policy)];
@@ -173,6 +185,14 @@ format_odp_sample_action(struct ds *ds, const struct nlattr *attr)
 
     ds_put_format(ds, "(sample=%.1f%%,", percentage);
 
+    if (a[OVS_SAMPLE_ATTR_FLAGS]) {
+        uint32_t flags = nl_attr_get_u32(a[OVS_SAMPLE_ATTR_FLAGS]);
+
+        ds_put_cstr(ds, "flags(");
+        format_flags(ds, sample_flags_to_string, flags, ',');
+        ds_put_cstr(ds, "),");
+    }
+
     ds_put_cstr(ds, "actions(");
     nla_acts = nl_attr_get(a[OVS_SAMPLE_ATTR_ACTIONS]);
     len = nl_attr_get_size(a[OVS_SAMPLE_ATTR_ACTIONS]);
-- 
1.8.5.2
