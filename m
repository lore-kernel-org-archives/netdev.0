From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/2] rtnetlink: Warn when interface's information won't
 fit in our packet
Date: Wed, 23 Apr 2014 13:51:33 +0200
Message-ID: <20140423115133.GF2846@minipsycho.orion>
References: <1398237665-26980-1-git-send-email-david@gibson.dropbear.id.au>
 <1398237665-26980-2-git-send-email-david@gibson.dropbear.id.au>
 <20140423090905.GC2846@minipsycho.orion>
 <20140423114120.GC31647@voom.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ssujith@cisco.com, neepatel@cisco.com,
	benve@cisco.com, davem@davemloft.net, ben@decadent.org.uk,
	govindarajulu90@gmail.com, gregory.v.rose@intel.com
To: David Gibson <david@gibson.dropbear.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:57045 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbaDWLvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 07:51:37 -0400
Received: by mail-ee0-f47.google.com with SMTP id b15so691184eek.34
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 04:51:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140423114120.GC31647@voom.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 23, 2014 at 01:41:20PM CEST, david@gibson.dropbear.id.au wrote:
>On Wed, Apr 23, 2014 at 11:09:05AM +0200, Jiri Pirko wrote:
>> Wed, Apr 23, 2014 at 09:21:04AM CEST, david@gibson.dropbear.id.au wrote:
>> >Without IFLA_EXT_MASK specified, the information reported for a single
>> >interface in response to RTM_GETLINK is expected to fit within a netlink
>> >packet of NLMSG_GOODSIZE.
>> >
>> >If it doesn't, however, things will go badly wrong,  When listing all
>> >interfaces, netlink_dump() will incorrectly treat -EMSGSIZE on the first
>> >message in a packet as the end of the listing and omit information for
>> >that interface and all subsequent ones.  This can cause getifaddrs(3) to
>> >enter an infinite loop.
>> >
>> >This patch won't fix the problem, but it will WARN_ON() making it easier to
>> >track down what's going wrong.
>> >
>> >Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
>> >---
>> > net/core/rtnetlink.c | 16 +++++++++++-----
>> > 1 file changed, 11 insertions(+), 5 deletions(-)
>> >
>> >diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>> >index d4ff417..5331db2 100644
>> >--- a/net/core/rtnetlink.c
>> >+++ b/net/core/rtnetlink.c
>> >@@ -1198,6 +1198,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>> > 	struct hlist_head *head;
>> > 	struct nlattr *tb[IFLA_MAX+1];
>> > 	u32 ext_filter_mask = 0;
>> >+	int err;
>> > 
>> > 	s_h = cb->args[0];
>> > 	s_idx = cb->args[1];
>> >@@ -1218,11 +1219,16 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>> > 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
>> > 			if (idx < s_idx)
>> > 				goto cont;
>> >-			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
>> >-					     NETLINK_CB(cb->skb).portid,
>> >-					     cb->nlh->nlmsg_seq, 0,
>> >-					     NLM_F_MULTI,
>> >-					     ext_filter_mask) <= 0)
>> >+			err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
>> >+					       NETLINK_CB(cb->skb).portid,
>> >+					       cb->nlh->nlmsg_seq, 0,
>> >+					       NLM_F_MULTI,
>> >+					       ext_filter_mask);
>> >+			/* If we ran out of room on the first message,
>> >+			 * we're in trouble */
>> >+			WARN_ON((err == -EMSGSIZE) && (skb->len == 0));
>> >+
>> >+			if (err <= 0)
>> 			if (err)
>
><= 0 was what the original version had.  Why do you think it should be
>changed to != 0?

You are right. I misread rtnl_fill_ifinfo.

>
>-- 
>David Gibson			| I'll have my music baroque, and my code
>david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
>				| _way_ _around_!
>http://www.ozlabs.org/~dgibson
