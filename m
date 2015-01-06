From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Tue, 6 Jan 2015 11:54:58 +0900
Message-ID: <20150106025456.GB24057@vergenet.net>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
 <20141231194544.31070.30335.stgit@nitbit.x32>
 <20150104111238.GD15305@casper.infradead.org>
 <54AADEFF.3090306@gmail.com>
 <54AB303E.3000601@gmail.com>
 <20150106010942.GD14077@vergenet.net>
 <54AB381E.3010009@gmail.com>
 <20150106020514.GA24057@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org, davem@davemloft.net,
	andy@greyhouse.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:56914 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932252AbbAFCzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 21:55:10 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so30142661pad.10
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 18:55:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150106020514.GA24057@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2015 at 11:05:14AM +0900, Simon Horman wrote:
> On Mon, Jan 05, 2015 at 05:19:26PM -0800, John Fastabend wrote:
> > On 01/05/2015 05:09 PM, Simon Horman wrote:
> > >On Mon, Jan 05, 2015 at 04:45:50PM -0800, John Fastabend wrote:
> > >>[...]
> > >>
> > >>>>>+/**
> > >>>>>+ * @struct net_flow_field_ref
> > >>>>>+ * @brief uniquely identify field as header:field tuple
> > >>>>>+ */
> > >>>>>+struct net_flow_field_ref {
> > >>>>>+    int instance;
> > >>>>>+    int header;
> > >>>>>+    int field;
> > >>>>>+    int mask_type;
> > >>>>>+    int type;
> > >>>>>+    union {    /* Are these all the required data types */
> > >>>>>+        __u8 value_u8;
> > >>>>>+        __u16 value_u16;
> > >>>>>+        __u32 value_u32;
> > >>>>>+        __u64 value_u64;
> > >>>>>+    };
> > >>>>>+    union {    /* Are these all the required data types */
> > >>>>>+        __u8 mask_u8;
> > >>>>>+        __u16 mask_u16;
> > >>>>>+        __u32 mask_u32;
> > >>>>>+        __u64 mask_u64;
> > >>>>>+    };
> > >>>>>+};
> > >>>>
> > >>>>Does it make sense to write this as follows?
> > >>>
> > >>>Yes. I'll make this update it helps make it clear value/mask pairs are
> > >>>needed.
> > >>>
> > >>>>
> > >>>>union {
> > >>>>         struct {
> > >>>>                 __u8 value_u8;
> > >>>>                 __u8 mask_u8;
> > >>>>         };
> > >>>>         struct {
> > >>>>                 __u16 value_u16;
> > >>>>                 __u16 mask_u16;
> > >>>>         };
> > >>>>         ...
> > >>>>};
> > >>
> > >>Another thought is to pull this entirely out of the structure and hide
> > >>it from the UAPI so we can add more value/mask types as needed without
> > >>having to spin versions of net_flow_field_ref. On the other hand I've
> > >>been able to fit all my fields in these types so far and I can't think
> > >>of any additions we need at the moment.
> > >
> > >FWIW, I think it would be cleaner to break both field_ref and action_args
> > >out into attributes and not expose the structures to user-space. But
> > >perhaps there is an advantage to dealing with structures directly that
> > >I am missing.
> > >
> > 
> > I  came to the same conclusion just now as well. I'm reworking it now
> > for v2.
> 
> Thanks.
> 
> BTW, I think there are a few problems with net_flow_put_flow_action().
> 
> I am not quite to the bottom of it but it seems that:
> * It loops over a->args[i] and then calls net_flow_put_act_types()
>   which performs a similar loop. This outer-loop appears to be incorrect.
> * It passes a[i].args instead of a->args[i] to net_flow_put_act_types()
> 
> I can post a fix once I've got it working to my satisfaction.
> But if you are reworking that code anyway perhaps it is easier for
> you to handle it then.

FWIW this got the current scheme working for me:

diff --git a/net/core/flow_table.c b/net/core/flow_table.c
index 5dbdc13..598afa2 100644
--- a/net/core/flow_table.c
+++ b/net/core/flow_table.c
@@ -946,7 +946,7 @@ static int net_flow_put_flow_action(struct sk_buff *skb,
 				    struct net_flow_action *a)
 {
 	struct nlattr *action, *sigs;
-	int i, err = 0;
+	int err = 0;
 
 	action = nla_nest_start(skb, NET_FLOW_ACTION);
 	if (!action)
@@ -958,21 +958,19 @@ static int net_flow_put_flow_action(struct sk_buff *skb,
 	if (!a->args)
 		goto done;
 
-	for (i = 0; a->args[i].type; i++) {
-		sigs = nla_nest_start(skb, NET_FLOW_ACTION_ATTR_SIGNATURE);
-		if (!sigs) {
-			nla_nest_cancel(skb, action);
-			return -EMSGSIZE;
-		}
+	sigs = nla_nest_start(skb, NET_FLOW_ACTION_ATTR_SIGNATURE);
+	if (!sigs) {
+		nla_nest_cancel(skb, action);
+		return -EMSGSIZE;
+	}
 
-		err = net_flow_put_act_types(skb, a[i].args);
-		if (err) {
-			nla_nest_cancel(skb, sigs);
-			nla_nest_cancel(skb, action);
-			return err;
-		}
-		nla_nest_end(skb, sigs);
+	err = net_flow_put_act_types(skb, a->args);
+	if (err) {
+		nla_nest_cancel(skb, sigs);
+		nla_nest_cancel(skb, action);
+		return err;
 	}
+	nla_nest_end(skb, sigs);
 
 done:
 	nla_nest_end(skb, action);
@@ -1103,6 +1101,7 @@ static int net_flow_get_action(struct net_flow_action *a, struct nlattr *attr)
 		}
 
 		a->args[count] = *(struct net_flow_action_arg *)nla_data(args);
+		count++;
 	}
 	return 0;
 }
