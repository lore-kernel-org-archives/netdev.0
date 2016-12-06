From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v2 net-next 1/2] flow dissector: ICMP support
Date: Tue, 6 Dec 2016 11:51:46 +0100
Message-ID: <20161206105145.GA27020@penelope.horms.nl>
References: <1480710702-16850-1-git-send-email-simon.horman@netronome.com>
 <1480710702-16850-2-git-send-email-simon.horman@netronome.com>
 <20161203104918.GA1880@nanopsycho.orion>
 <CALx6S36EorReKwSs=qpS6uxCrL=_CQHf2BfV+Y=Kw-Dzfc241A@mail.gmail.com>
 <20161205142208.GA16425@penelope.horms.nl>
 <CALx6S37f-TFAhAidri12iD0KnhFE2kYuVnsXsj7yjivk-ovRiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34827 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752100AbcLFKvu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 05:51:50 -0500
Received: by mail-wm0-f42.google.com with SMTP id a197so123773923wmd.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 02:51:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALx6S37f-TFAhAidri12iD0KnhFE2kYuVnsXsj7yjivk-ovRiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 05, 2016 at 09:29:45AM -0800, Tom Herbert wrote:
> On Mon, Dec 5, 2016 at 6:23 AM, Simon Horman <simon.horman@netronome.com> wrote:
> > On Sat, Dec 03, 2016 at 10:52:32AM -0800, Tom Herbert wrote:
> >> On Sat, Dec 3, 2016 at 2:49 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> >> > Fri, Dec 02, 2016 at 09:31:41PM CET, simon.horman@netronome.com wrote:
> >> >>Allow dissection of ICMP(V6) type and code. This re-uses transport layer
> >> >>port dissection code as although ICMP is not a transport protocol and their
> >> >>type and code are not ports this allows sharing of both code and storage.
> >> >>
> >> >>Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >
> > ...
> >
> >> > Digging into this a bit more. I think it would be much nice not to mix
> >> > up l4 ports and icmp stuff.
> >> >
> >> > How about to have FLOW_DISSECTOR_KEY_ICMP
> >> > and
> >> > struct flow_dissector_key_icmp {
> >> >         u8 type;
> >> >         u8 code;
> >> > };
> >> >
> >> > The you can make this structure and struct flow_dissector_key_ports into
> >> > an union in struct flow_keys.
> >> >
> >> > Looks much cleaner to me.
> >
> > Hi Jiri,
> >
> > I wondered about that too. The main reason that I didn't do this the first
> > time around is that I wasn't sure what to do to differentiate between ports
> > and icmp in fl_init_dissector() given that using a union would could to
> > mask bits being set in both if they are set in either.
> >
> > I've taken a stab at addressing that below along with implementing your
> > suggestion. If the treatment in fl_init_dissector() is acceptable
> > perhaps something similar should be done for FLOW_DISSECTOR_KEY_IPV[46]_ADDRS
> > too?
> >
> >> I agree, this patch adds to many conditionals into the fast path for
> >> ICMP handling. Neither is there much point in using type and code as
> >> input to the packet hash.
> >
> > Hi Tom,
> >
> > I'm not sure that I follow this. A packet may be ICMP or not regardless of
> > if FLOW_DISSECTOR_KEY_PORT (and now FLOW_DISSECTOR_KEY_ICMP) port is set or
> > not. I'd appreciate some guidance here.
> >
> > First-pass at implementing Jiri's suggestion follows:
> >

...

> > diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> > index 0584b4bb4390..33e5fa2b3e87 100644
> > --- a/net/core/flow_dissector.c
> > +++ b/net/core/flow_dissector.c

...

> > @@ -975,6 +983,10 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
> >                 .offset = offsetof(struct flow_keys, ports),
> >         },
> >         {
> > +               .key_id = FLOW_DISSECTOR_KEY_ICMP,
> > +               .offset = offsetof(struct flow_keys, icmp),
> > +       },
> 
> This is the problem I was referring to. This adds ICMP to the keys for
> computing the skb hash and the ICMP type and code are in a union with
> port numbers so they are in the range over which the hash is computed.
> This means that we are treating type and code as some sort of flow and
> and so different type/code between the same src/dst could follow
> different paths in ECMP. For the purposes of computing a packet hash I
> don't think we want ICMP information included. This might be a matter
> of not putting FLOW_DISSECTOR_KEY_ICMP in flow_keys_dissector_keys,
> where we need this information we could define another structure that
> has all the same fields as in flow_keys_dissector_keys and include
> FLOW_DISSECTOR_KEY_ICMP. Alternatively, the flow_dissector_key_icmp
> could also be outside of the area that is used in the hash: that is no
> in flow_keys_hash_start(keys) to flow_keys_hash_length(keys), keyval);

...

> > diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
> > index c96b2a349779..f4ba69bd362f 100644
> > --- a/net/sched/cls_flower.c
> > +++ b/net/sched/cls_flower.c
> > @@ -38,7 +38,10 @@ struct fl_flow_key {
> >                 struct flow_dissector_key_ipv4_addrs ipv4;
> >                 struct flow_dissector_key_ipv6_addrs ipv6;
> >         };
> > -       struct flow_dissector_key_ports tp;
> > +       union {
> > +               struct flow_dissector_key_ports tp;
> > +               struct flow_dissector_key_icmp icmp;
> > +       };
> 
> When an ICMP packet is encapsulated within UDP then icmp overwrites
> valid port information with is a stronger signal of the flow (unless
> FLOW_DISSECTOR_F_STOP_AT_ENCAP is set). This is another reason not to
> use a union with ports.

...

Hi Tom,

thanks for your explanation. I think I have a clearer picture now.

I have reworked things to try to address your concerns.
In particular:

* FLOW_DISSECTOR_KEY_ICMP is no longer added to flow_keys_dissector_keys.
  I don't think it is needed at all for the use-case I currently have in
  mind, which is classifying packets using tc_flower. And adding it there
  was an error on my part.

* I stopped using a union for ports and icmp. At the very least this seems
  to make it easier to reason about things as we no longer need to consider
  that a port value may in fact be an ICMP type or code.

  This seems to allow us avoid adding a number of is_icmp checks (as I believe
  you pointed out earlier). And should also address the problem you state
  immediately above.

* I have also placed icmp outside of the range flow_keys_hash_start(keys)
  to flow_keys_hash_length(keys), keyval). This is because I now see no
  value of having it inside that range and it both avoids any chance of
  contaminating the hash with ICMP values and hashing over unwanted
  (hopefully zero) values.

  This required an update to flow_keys_hash_length() as the bound
  of the end of fields the hash is no longer the end of struct flow_keys.
  It seems clean but I wonder if there are similar assumptions lurking
  elsewhere.

I have lightly tested this for the tc_flower case (only).

Incremental patch on top of this series:

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a6f75cfb2bf7..8029dd4912b6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3181,8 +3181,7 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 	} else {
 		return false;
 	}
-	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34 &&
-	    proto >= 0 && !skb_flow_is_icmp_any(skb, proto))
+	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34 && proto >= 0)
 		fk->ports.ports = skb_flow_get_ports(skb, noff, proto);
 
 	return true;
@@ -3210,8 +3209,7 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
 		return bond_eth_hash(skb);
 
 	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER23 ||
-	    bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP23 ||
-	    flow_keys_are_icmp_any(&flow))
+	    bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP23)
 		hash = bond_eth_hash(skb);
 	else
 		hash = (__force u32)flow.ports.ports;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 44a8f69a9198..9c535fbccf2c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1094,11 +1094,6 @@ u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 			    void *data, int hlen_proto);
 
-static inline bool skb_flow_is_icmp_any(const struct sk_buff *skb, u8 ip_proto)
-{
-	return flow_protos_are_icmp_any(skb->protocol, ip_proto);
-}
-
 static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
 					int thoff, u8 ip_proto)
 {
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 5540dfa18872..058c9df8a4d8 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -91,14 +91,10 @@ struct flow_dissector_key_addrs {
 
 /**
  * flow_dissector_key_ports:
- *	@ports: port numbers of Transport header or
- *		type and code of ICMP header
+ *	@ports: port numbers of Transport header
  *		ports: source (high) and destination (low) port numbers
  *		src: source port number
  *		dst: destination port number
- *		icmp: ICMP type (high) and code (low)
- *		type: ICMP type
- *		type: ICMP code
  */
 struct flow_dissector_key_ports {
 	union {
@@ -107,6 +103,18 @@ struct flow_dissector_key_ports {
 			__be16 src;
 			__be16 dst;
 		};
+	};
+};
+
+/**
+ * flow_dissector_key_icmp:
+ *	@ports: type and code of ICMP header
+ *		icmp: ICMP type (high) and code (low)
+ *		type: ICMP type
+ *		code: ICMP code
+ */
+struct flow_dissector_key_icmp {
+	union {
 		__be16 icmp;
 		struct {
 			u8 type;
@@ -115,7 +123,6 @@ struct flow_dissector_key_ports {
 	};
 };
 
-
 /**
  * struct flow_dissector_key_eth_addrs:
  * @src: source Ethernet address
@@ -133,6 +140,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_ipv4_addrs */
 	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
+	FLOW_DISSECTOR_KEY_ICMP, /* struct flow_dissector_key_icmp */
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
 	FLOW_DISSECTOR_KEY_VLAN, /* struct flow_dissector_key_flow_vlan */
@@ -173,11 +181,16 @@ struct flow_keys {
 	struct flow_dissector_key_keyid keyid;
 	struct flow_dissector_key_ports ports;
 	struct flow_dissector_key_addrs addrs;
+#define FLOW_KEYS_HASH_END_FIELD addrs
+	struct flow_dissector_key_icmp icmp;
 };
 
 #define FLOW_KEYS_HASH_OFFSET		\
 	offsetof(struct flow_keys, FLOW_KEYS_HASH_START_FIELD)
 
+#define FLOW_KEYS_HASH_END		\
+	offsetofend(struct flow_keys, FLOW_KEYS_HASH_END_FIELD)
+
 __be32 flow_get_u32_src(const struct flow_keys *flow);
 __be32 flow_get_u32_dst(const struct flow_keys *flow);
 
@@ -233,8 +246,7 @@ static inline bool flow_keys_are_icmp_any(const struct flow_keys *keys)
 
 static inline bool flow_keys_have_l4(const struct flow_keys *keys)
 {
-	return (!flow_keys_are_icmp_any(keys) && keys->ports.ports) ||
-		keys->tags.flow_label;
+	return (keys->ports.ports || keys->tags.flow_label);
 }
 
 u32 flow_hash_from_keys(struct flow_keys *keys);
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 0584b4bb4390..ed6d46475343 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -139,6 +139,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_basic *key_basic;
 	struct flow_dissector_key_addrs *key_addrs;
 	struct flow_dissector_key_ports *key_ports;
+	struct flow_dissector_key_icmp *key_icmp;
 	struct flow_dissector_key_tags *key_tags;
 	struct flow_dissector_key_vlan *key_vlan;
 	struct flow_dissector_key_keyid *key_keyid;
@@ -559,18 +560,25 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		break;
 	}
 
-	if (dissector_uses_key(flow_dissector,
-			       FLOW_DISSECTOR_KEY_PORTS)) {
-		key_ports = skb_flow_dissector_target(flow_dissector,
-						      FLOW_DISSECTOR_KEY_PORTS,
-						      target_container);
-		if (flow_protos_are_icmp_any(proto, ip_proto))
-			key_ports->icmp = skb_flow_get_be16(skb, nhoff, data,
-							    hlen);
-		else
+	if (flow_protos_are_icmp_any(proto, ip_proto)) {
+		if (dissector_uses_key(flow_dissector,
+				       FLOW_DISSECTOR_KEY_ICMP)) {
+			key_icmp = skb_flow_dissector_target(flow_dissector,
+							     FLOW_DISSECTOR_KEY_ICMP,
+							     target_container);
+			key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data,
+							   hlen);
+		}
+	} else {
+		if (dissector_uses_key(flow_dissector,
+				       FLOW_DISSECTOR_KEY_PORTS)) {
+			key_ports = skb_flow_dissector_target(flow_dissector,
+							      FLOW_DISSECTOR_KEY_PORTS,
+							      target_container);
 			key_ports->ports = __skb_flow_get_ports(skb, nhoff,
 								ip_proto, data,
 								hlen);
+		}
 	}
 
 out_good:
@@ -613,9 +621,10 @@ static inline const u32 *flow_keys_hash_start(const struct flow_keys *flow)
 static inline size_t flow_keys_hash_length(const struct flow_keys *flow)
 {
 	size_t diff = FLOW_KEYS_HASH_OFFSET + sizeof(flow->addrs);
-	BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
+	BUILD_BUG_ON((FLOW_KEYS_HASH_END - FLOW_KEYS_HASH_OFFSET) %
+		     sizeof(u32));
 	BUILD_BUG_ON(offsetof(typeof(*flow), addrs) !=
-		     sizeof(*flow) - sizeof(flow->addrs));
+		     FLOW_KEYS_HASH_END - sizeof(flow->addrs));
 
 	switch (flow->control.addr_type) {
 	case FLOW_DISSECTOR_KEY_IPV4_ADDRS:
@@ -628,7 +637,7 @@ static inline size_t flow_keys_hash_length(const struct flow_keys *flow)
 		diff -= sizeof(flow->addrs.tipcaddrs);
 		break;
 	}
-	return (sizeof(*flow) - diff) / sizeof(u32);
+	return (FLOW_KEYS_HASH_END - diff) / sizeof(u32);
 }
 
 __be32 flow_get_u32_src(const struct flow_keys *flow)
@@ -745,8 +754,7 @@ void make_flow_keys_digest(struct flow_keys_digest *digest,
 
 	data->n_proto = flow->basic.n_proto;
 	data->ip_proto = flow->basic.ip_proto;
-	if (flow_keys_have_l4(flow))
-		data->ports = flow->ports.ports;
+	data->ports = flow->ports.ports;
 	data->src = flow->addrs.v4addrs.src;
 	data->dst = flow->addrs.v4addrs.dst;
 }
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 408313e33bbe..6575aba87630 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -96,7 +96,7 @@ static u32 flow_get_proto(const struct sk_buff *skb,
 static u32 flow_get_proto_src(const struct sk_buff *skb,
 			      const struct flow_keys *flow)
 {
-	if (!flow_keys_are_icmp_any(flow) && flow->ports.ports)
+	if (flow->ports.ports)
 		return ntohs(flow->ports.src);
 
 	return addr_fold(skb->sk);
@@ -105,7 +105,7 @@ static u32 flow_get_proto_src(const struct sk_buff *skb,
 static u32 flow_get_proto_dst(const struct sk_buff *skb,
 			      const struct flow_keys *flow)
 {
-	if (!flow_keys_are_icmp_any(flow) && flow->ports.ports)
+	if (flow->ports.ports)
 		return ntohs(flow->ports.dst);
 
 	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index c96b2a349779..56df0368125a 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -39,6 +39,7 @@ struct fl_flow_key {
 		struct flow_dissector_key_ipv6_addrs ipv6;
 	};
 	struct flow_dissector_key_ports tp;
+	struct flow_dissector_key_icmp icmp;
 	struct flow_dissector_key_keyid enc_key_id;
 	union {
 		struct flow_dissector_key_ipv4_addrs enc_ipv4;
@@ -511,19 +512,23 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 			       &mask->tp.dst, TCA_FLOWER_KEY_SCTP_DST_MASK,
 			       sizeof(key->tp.dst));
 	} else if (flow_basic_key_is_icmpv4(&key->basic)) {
-		fl_set_key_val(tb, &key->tp.type, TCA_FLOWER_KEY_ICMPV4_TYPE,
-			       &mask->tp.type, TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,
-			       sizeof(key->tp.type));
-		fl_set_key_val(tb, &key->tp.code, TCA_FLOWER_KEY_ICMPV4_CODE,
-			       &mask->tp.code, TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
-			       sizeof(key->tp.code));
+		fl_set_key_val(tb, &key->icmp.type, TCA_FLOWER_KEY_ICMPV4_TYPE,
+			       &mask->icmp.type,
+			       TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,
+			       sizeof(key->icmp.type));
+		fl_set_key_val(tb, &key->icmp.code, TCA_FLOWER_KEY_ICMPV4_CODE,
+			       &mask->icmp.code,
+			       TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
+			       sizeof(key->icmp.code));
 	} else if (flow_basic_key_is_icmpv6(&key->basic)) {
-		fl_set_key_val(tb, &key->tp.type, TCA_FLOWER_KEY_ICMPV6_TYPE,
-			       &mask->tp.type, TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,
-			       sizeof(key->tp.type));
-		fl_set_key_val(tb, &key->tp.code, TCA_FLOWER_KEY_ICMPV4_CODE,
-			       &mask->tp.code, TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
-			       sizeof(key->tp.code));
+		fl_set_key_val(tb, &key->icmp.type, TCA_FLOWER_KEY_ICMPV6_TYPE,
+			       &mask->icmp.type,
+			       TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,
+			       sizeof(key->icmp.type));
+		fl_set_key_val(tb, &key->icmp.code, TCA_FLOWER_KEY_ICMPV4_CODE,
+			       &mask->icmp.code,
+			       TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
+			       sizeof(key->icmp.code));
 	}
 
 	if (tb[TCA_FLOWER_KEY_ENC_IPV4_SRC] ||
@@ -634,6 +639,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_PORTS, tp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ICMP, icmp);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_VLAN, vlan);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_ENC_KEYID, enc_key_id);
@@ -1000,24 +1007,24 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 				  sizeof(key->tp.dst))))
 		goto nla_put_failure;
 	else if (flow_basic_key_is_icmpv4(&key->basic) &&
-		 (fl_dump_key_val(skb, &key->tp.type,
-				  TCA_FLOWER_KEY_ICMPV4_TYPE, &mask->tp.type,
+		 (fl_dump_key_val(skb, &key->icmp.type,
+				  TCA_FLOWER_KEY_ICMPV4_TYPE, &mask->icmp.type,
 				  TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,
-				  sizeof(key->tp.type)) ||
-		  fl_dump_key_val(skb, &key->tp.code,
-				  TCA_FLOWER_KEY_ICMPV4_CODE, &mask->tp.code,
+				  sizeof(key->icmp.type)) ||
+		  fl_dump_key_val(skb, &key->icmp.code,
+				  TCA_FLOWER_KEY_ICMPV4_CODE, &mask->icmp.code,
 				  TCA_FLOWER_KEY_ICMPV4_CODE_MASK,
-				  sizeof(key->tp.code))))
+				  sizeof(key->icmp.code))))
 		goto nla_put_failure;
 	else if (flow_basic_key_is_icmpv6(&key->basic) &&
-		 (fl_dump_key_val(skb, &key->tp.type,
-				  TCA_FLOWER_KEY_ICMPV6_TYPE, &mask->tp.type,
+		 (fl_dump_key_val(skb, &key->icmp.type,
+				  TCA_FLOWER_KEY_ICMPV6_TYPE, &mask->icmp.type,
 				  TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,
-				  sizeof(key->tp.type)) ||
-		  fl_dump_key_val(skb, &key->tp.code,
-				  TCA_FLOWER_KEY_ICMPV6_CODE, &mask->tp.code,
+				  sizeof(key->icmp.type)) ||
+		  fl_dump_key_val(skb, &key->icmp.code,
+				  TCA_FLOWER_KEY_ICMPV6_CODE, &mask->icmp.code,
 				  TCA_FLOWER_KEY_ICMPV6_CODE_MASK,
-				  sizeof(key->tp.code))))
+				  sizeof(key->icmp.code))))
 		goto nla_put_failure;
 
 	if (key->enc_control.addr_type == FLOW_DISSECTOR_KEY_IPV4_ADDRS &&
