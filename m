From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Mon, 18 Apr 2016 23:41:37 -0400 (EDT)
Message-ID: <20160418.234137.26692086759328024.davem@davemloft.net>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbcDSDll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 23:41:41 -0400
In-Reply-To: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Mon, 18 Apr 2016 14:10:19 -0700

> This patch adds a new RTM_GETSTATS message to query link stats via
> netlink from the kernel. RTM_NEWLINK also dumps stats today, but
> RTM_NEWLINK returns a lot more than just stats and is expensive in
> some cases when frequent polling for stats from userspace is a
> common operation.

I'm holding off on this until we sort out the 64-bit netlink
attribute alignment issue.

Meanwhile, I'll some kind of a fix into the tree for the
rtnl_fill_stats() change so that it doesn't cause unaligned
accesses.

I just tested out a clever idea, where for architectures where
unaligned accesses is a problem, we insert a zero length NOP attribute
before the 64-bit stats.  This makes it properly aligned.  A quick
hack patch just passed testing on my sparc64 box, but I'll go over it
some more.

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index bb3a90b..5ffdcb3 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -155,6 +155,7 @@ enum {
 	IFLA_PROTO_DOWN,
 	IFLA_GSO_MAX_SEGS,
 	IFLA_GSO_MAX_SIZE,
+	IFLA_PAD,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a7a3d34..b192576 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1052,6 +1052,15 @@ static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
 	struct rtnl_link_stats64 *sp;
 	struct nlattr *attr;
 
+	/* Add a zero length NOP attribute so that the nla_data()
+	 * of the IFLA_STATS64 will be 64-bit aligned.
+	 */
+#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+	attr = nla_reserve(skb, IFLA_PAD, 0);
+	if (!attr)
+		return -EMSGSIZE;
+#endif
+
 	attr = nla_reserve(skb, IFLA_STATS64,
 			   sizeof(struct rtnl_link_stats64));
 	if (!attr)
