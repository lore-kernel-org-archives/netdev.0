From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next v2 2/4] net_sched: introduce tclass_del_notify()
Date: Fri, 25 Aug 2017 10:54:38 +0200
Message-ID: <20170825085438.GC2023@nanopsycho>
References: <20170824235130.28503-1-xiyou.wangcong@gmail.com>
 <20170824235130.28503-3-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36061 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755039AbdHYIyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 04:54:41 -0400
Received: by mail-wm0-f67.google.com with SMTP id j72so1890630wmi.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 01:54:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170824235130.28503-3-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 25, 2017 at 01:51:28AM CEST, xiyou.wangcong@gmail.com wrote:
>Like for TC actions, ->delete() is a special case,
>we have to prepare and fill the notification before delete
>otherwise would get use-after-free after we remove the
>reference count.
>
>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>---

[...]


>+static int tclass_del_notify(struct net *net,
>+			     const struct Qdisc_class_ops *cops,
>+			     struct sk_buff *oskb, struct nlmsghdr *n,
>+			     struct Qdisc *q, unsigned long cl)
>+{
>+	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
>+	struct sk_buff *skb;
>+	int err = 0;
>+
>+	if (!cops->delete)
>+		return -EOPNOTSUPP;
>+
>+	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
>+	if (!skb)
>+		return -ENOBUFS;
>+
>+	if (tc_fill_tclass(skb, q, cl, portid, n->nlmsg_seq, 0,
>+			   RTM_DELTCLASS) < 0) {
>+		kfree_skb(skb);
>+		return -EINVAL;
>+	}
>+
>+	err = cops->delete(q, cl);
>+	if (err) {
>+		kfree_skb(skb);
>+		return err;
>+	}
>+
>+	return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
>+			      n->nlmsg_flags & NLM_F_ECHO);

There is a lot of code duplication with tclass_notify function. Don't
you rather want to split tclass_notify into tclass_notify_prepare and
tclass_notify_send and use these 2 from both tclass_notify and
tclass_del_notify?
