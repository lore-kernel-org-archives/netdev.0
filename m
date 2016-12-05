From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v2 net-next 1/2] flow dissector: ICMP support
Date: Mon, 5 Dec 2016 15:23:16 +0100
Message-ID: <20161205142208.GA16425@penelope.horms.nl>
References: <1480710702-16850-1-git-send-email-simon.horman@netronome.com>
 <1480710702-16850-2-git-send-email-simon.horman@netronome.com>
 <20161203104918.GA1880@nanopsycho.orion>
 <CALx6S36EorReKwSs=qpS6uxCrL=_CQHf2BfV+Y=Kw-Dzfc241A@mail.gmail.com>
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
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35500 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbcLEOX7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 09:23:59 -0500
Received: by mail-wm0-f43.google.com with SMTP id a197so99258103wmd.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 06:23:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALx6S36EorReKwSs=qpS6uxCrL=_CQHf2BfV+Y=Kw-Dzfc241A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 03, 2016 at 10:52:32AM -0800, Tom Herbert wrote:
> On Sat, Dec 3, 2016 at 2:49 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> > Fri, Dec 02, 2016 at 09:31:41PM CET, simon.horman@netronome.com wrote:
> >>Allow dissection of ICMP(V6) type and code. This re-uses transport layer
> >>port dissection code as although ICMP is not a transport protocol and their
> >>type and code are not ports this allows sharing of both code and storage.
> >>
> >>Signed-off-by: Simon Horman <simon.horman@netronome.com>

...

> > Digging into this a bit more. I think it would be much nice not to mix
> > up l4 ports and icmp stuff.
> >
> > How about to have FLOW_DISSECTOR_KEY_ICMP
> > and
> > struct flow_dissector_key_icmp {
> >         u8 type;
> >         u8 code;
> > };
> >
> > The you can make this structure and struct flow_dissector_key_ports into
> > an union in struct flow_keys.
> >
> > Looks much cleaner to me.

Hi Jiri,

I wondered about that too. The main reason that I didn't do this the first
time around is that I wasn't sure what to do to differentiate between ports
and icmp in fl_init_dissector() given that using a union would could to
mask bits being set in both if they are set in either.

I've taken a stab at addressing that below along with implementing your
suggestion. If the treatment in fl_init_dissector() is acceptable
perhaps something similar should be done for FLOW_DISSECTOR_KEY_IPV[46]_ADDRS
too?

> I agree, this patch adds to many conditionals into the fast path for
> ICMP handling. Neither is there much point in using type and code as
> input to the packet hash.

Hi Tom,

I'm not sure that I follow this. A packet may be ICMP or not regardless of
if FLOW_DISSECTOR_KEY_PORT (and now FLOW_DISSECTOR_KEY_ICMP) port is set or
not. I'd appreciate some guidance here.


First-pass at implementing Jiri's suggestion follows:

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 5540dfa18872..475cd121496f 100644
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
@@ -133,6 +141,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_ipv4_addrs */
 	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
+	FLOW_DISSECTOR_KEY_ICMP, /* struct flow_dissector_key_icmp */
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
 	FLOW_DISSECTOR_KEY_VLAN, /* struct flow_dissector_key_flow_vlan */
@@ -171,7 +180,10 @@ struct flow_keys {
 	struct flow_dissector_key_tags tags;
 	struct flow_dissector_key_vlan vlan;
 	struct flow_dissector_key_keyid keyid;
-	struct flow_dissector_key_ports ports;
+	union {
+		struct flow_dissector_key_ports ports;
+		struct flow_dissector_key_icmp icmp;
+	};
 	struct flow_dissector_key_addrs addrs;
 };
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 0584b4bb4390..33e5fa2b3e87 100644
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
@@ -975,6 +983,10 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 		.offset = offsetof(struct flow_keys, ports),
 	},
 	{
+		.key_id = FLOW_DISSECTOR_KEY_ICMP,
+		.offset = offsetof(struct flow_keys, icmp),
+	},
+	{
 		.key_id = FLOW_DISSECTOR_KEY_VLAN,
 		.offset = offsetof(struct flow_keys, vlan),
 	},
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index c96b2a349779..f4ba69bd362f 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -38,7 +38,10 @@ struct fl_flow_key {
 		struct flow_dissector_key_ipv4_addrs ipv4;
 		struct flow_dissector_key_ipv6_addrs ipv6;
 	};
-	struct flow_dissector_key_ports tp;
+	union {
+		struct flow_dissector_key_ports tp;
+		struct flow_dissector_key_icmp icmp;
+	};
 	struct flow_dissector_key_keyid enc_key_id;
 	union {
 		struct flow_dissector_key_ipv4_addrs enc_ipv4;
@@ -511,19 +514,23 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
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
@@ -609,15 +616,16 @@ static int fl_init_hashtable(struct cls_fl_head *head,
 		keys[cnt].key_id = id;						\
 		keys[cnt].offset = FL_KEY_MEMBER_OFFSET(member);		\
 		cnt++;								\
-	} while(0);
+	} while(0)
 
 #define FL_KEY_SET_IF_MASKED(mask, keys, cnt, id, member)			\
 	do {									\
 		if (FL_KEY_IS_MASKED(mask, member))				\
 			FL_KEY_SET(keys, cnt, id, member);			\
-	} while(0);
+	} while(0)
 
 static void fl_init_dissector(struct cls_fl_head *head,
+			      struct cls_fl_filter *f,
 			      struct fl_flow_mask *mask)
 {
 	struct flow_dissector_key keys[FLOW_DISSECTOR_KEY_MAX];
@@ -631,8 +639,12 @@ static void fl_init_dissector(struct cls_fl_head *head,
 			     FLOW_DISSECTOR_KEY_IPV4_ADDRS, ipv4);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_IPV6_ADDRS, ipv6);
-	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
-			     FLOW_DISSECTOR_KEY_PORTS, tp);
+	if (flow_basic_key_is_icmpv4(&f->key.basic))
+		FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+				     FLOW_DISSECTOR_KEY_ICMP, icmp);
+	else
+		FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+				     FLOW_DISSECTOR_KEY_PORTS, tp);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
 			     FLOW_DISSECTOR_KEY_VLAN, vlan);
 	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
@@ -652,6 +664,7 @@ static void fl_init_dissector(struct cls_fl_head *head,
 }
 
 static int fl_check_assign_mask(struct cls_fl_head *head,
+				struct cls_fl_filter *f,
 				struct fl_flow_mask *mask)
 {
 	int err;
@@ -672,7 +685,7 @@ static int fl_check_assign_mask(struct cls_fl_head *head,
 	memcpy(&head->mask, mask, sizeof(head->mask));
 	head->mask_assigned = true;
 
-	fl_init_dissector(head, mask);
+	fl_init_dissector(head, f, mask);
 
 	return 0;
 }
@@ -785,7 +798,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	if (err)
 		goto errout;
 
-	err = fl_check_assign_mask(head, &mask);
+	err = fl_check_assign_mask(head, fnew, &mask);
 	if (err)
 		goto errout;
 
@@ -1000,24 +1013,24 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
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
