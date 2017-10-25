From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 0/12] net: Significantly shrink the size of routes.
Date: Wed, 25 Oct 2017 23:02:21 +0900 (KST)
Message-ID: <20171025.230221.268667067312345890.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48282 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdJYOC1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:02:27 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 2920C133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:02:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Through a combination of several things, our route structures are
larger than they need to be.

Mostly this stems from having members in dst_entry which are only used
by one class of routes.  So the majority of the work in this series is
about "un-commoning" these members and pushing them into the type
specific structures.

Unfortunately, IPSEC needed the most surgery.  The majority of the
changes here had to do with bundle creation and management.

The other issue is the refcount alignment in dst_entry.  Once we get
rid of the not-so-common members, it really opens the door to removing
that alignment entirely.

I think the new layout looks really nice, so I'll reproduce it here:

	struct net_device       *dev;
	struct  dst_ops	        *ops;
	unsigned long		_metrics;
	unsigned long           expires;
	struct xfrm_state	*xfrm;
	int			(*input)(struct sk_buff *);
	int			(*output)(struct net *net, struct sock *sk, struct sk_buff *skb);
	unsigned short		flags;
	short			obsolete;
	unsigned short		header_len;
	unsigned short		trailer_len;
	atomic_t		__refcnt;
	int			__use;
	unsigned long		lastuse;
	struct lwtunnel_state   *lwtstate;
	struct rcu_head		rcu_head;
	short			error;
	short			__pad;
	__u32			tclassid;

This is a rough draft, so there are still some problems to resolve.
In particular, the refcount alignment is only sorted out on 64-bit at
this time.  It shouldn't be too hard to either fix 32-bit or decide
that we don't care so much these days or can lower the target
alignment there to 32-bytes rather than 64-bytes.

So, the good news:

1) struct dst_entry shrinks from 160 to 112 bytes.

2) struct rtable shrinks from 216 to 168 bytes.

3) struct rt6_info shrinks from 384 to 320 bytes.

Enjoy.

Signed-off-by: David S. Miller <davem@davemloft.net>
