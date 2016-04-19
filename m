From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 14:31:34 -0400 (EDT)
Message-ID: <20160419.143134.2014460805657420897.davem@davemloft.net>
References: <20160418.234137.26692086759328024.davem@davemloft.net>
	<1461040324.10638.159.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160419.010316.1863885429013017239.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, tgraf@suug.ch, nicolas.dichtel@6wind.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754830AbcDSSbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 14:31:36 -0400
In-Reply-To: <20160419.010316.1863885429013017239.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 19 Apr 2016 01:03:16 -0400 (EDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 18 Apr 2016 21:32:04 -0700
> 
>> On Mon, 2016-04-18 at 23:41 -0400, David Miller wrote:
>>>  
>>> +	/* Add a zero length NOP attribute so that the nla_data()
>>> +	 * of the IFLA_STATS64 will be 64-bit aligned.
>>> +	 */
>>> +#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
>>> +	attr = nla_reserve(skb, IFLA_PAD, 0);
>>> +	if (!attr)
>>> +		return -EMSGSIZE;
>>> +#endif
>> 
>> You must do this only if current skb->data alignment is not correct.
> 
> I'll put an assertion there if it makes you happy. :-)

Actually, you are right, as usual.

Here is the final patch I'm about to push out, thanks a lot Eric.

Roopa, please adjust your GETSTATS patch as needed (I think you need
to adjust the SELinux table entry as well) and we can integrate that
too.

====================
[PATCH] net: Align IFLA_STATS64 attributes properly on architectures that need it.

Since the nlattr header is 4 bytes in size, it can cause the netlink
attribute payload to not be 8-byte aligned.

This is particularly troublesome for IFLA_STATS64 which contains 64-bit
statistic values.

Solve this by creating a dummy IFLA_PAD attribute which has a payload
which is zero bytes in size.  When HAVE_EFFICIENT_UNALIGNED_ACCESS is
false, we insert an IFLA_PAD attribute into the netlink response when
necessary such that the IFLA_STATS64 payload will be properly aligned.

With help and suggestions from Eric Dumazet.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

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
index a7a3d34..198ca2c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -878,6 +878,9 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(IFNAMSIZ) /* IFLA_QDISC */
 	       + nla_total_size(sizeof(struct rtnl_link_ifmap))
 	       + nla_total_size(sizeof(struct rtnl_link_stats))
+#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+	       + nla_total_size(0) /* IFLA_PAD */
+#endif
 	       + nla_total_size(sizeof(struct rtnl_link_stats64))
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_BROADCAST */
@@ -1052,6 +1055,22 @@ static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
 	struct rtnl_link_stats64 *sp;
 	struct nlattr *attr;
 
+#ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
+	/* IF necessary, add a zero length NOP attribute so that the
+	 * nla_data() of the IFLA_STATS64 will be 64-bit aligned.
+	 *
+	 * The nlattr header is 4 bytes in size, that's why we test
+	 * if the skb->data _is_ aligned.  This NOP attribute, plus
+	 * nlattr header for IFLA_STATS64, will make nla_data() 8-byte
+	 * aligned.
+	 */
+	if (IS_ALIGNED((unsigned long)skb->data, 8)) {
+		attr = nla_reserve(skb, IFLA_PAD, 0);
+		if (!attr)
+			return -EMSGSIZE;
+	}
+#endif
+
 	attr = nla_reserve(skb, IFLA_STATS64,
 			   sizeof(struct rtnl_link_stats64));
 	if (!attr)
-- 
2.4.1
