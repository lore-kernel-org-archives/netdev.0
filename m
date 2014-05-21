From: David Miller <davem@davemloft.net>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0
 (bridge : Sanitize skb before it enters the IP stack)
Date: Wed, 21 May 2014 16:18:41 -0400 (EDT)
Message-ID: <20140521.161841.1806439174351824310.davem@davemloft.net>
References: <537A6E5C.6090602@pandora.be> <537C5A6C.3030809@davidnewall.com>
	<537CF5A2.3080401@pandora.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davidn@davidnewall.com,
	bridge@lists.linux-foundation.org, fw@strlen.de,
	stephen@networkplumber.org, netfilter-devel@vger.kernel.org
To: bdschuym@pandora.be
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <537CF5A2.3080401@pandora.be>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Bart De Schuymer <bdschuym@pandora.be>
Date: Wed, 21 May 2014 20:51:14 +0200

> David Newall schreef op 21/05/2014 9:49:
>>> An alternative would be to make sure that the data pointed to by IPCB
>>> and BR_INPUT_SKB_CB don't overlap. If this were the case, we could
>>> indeed just revert the commit that was referred to.
>>
>> They are identical spaces, but you imply a good point: the cb area is
>> possibly being used, simultaneously, for two, incompatible
>> purposes. Yet
>> another argument for divorcing bridge of ip logic.
> 
> There's no reason why they should overlap in the cb: it's 48 bytes
> big, so big enough to hold both struct br_input_skb_cb and struct
> inet_skb_parm. The original problem was introduced when
> BR_INPUT_SKB_CB was introduced (around Feb 27, 2010), so fixing
> BR_INPUT_SKB_CB seems most appropriate to me.

So you are suggesting the patch below will fix everything?

> As for your other remark: as I've said before, if you don't like
> bridge-netfilter then don't compile it into your kernel.

That's never a good argument, please stop making it.

%99.999999999 of users get their kernels from distributions and
they are all going to enable basically every feature available.

We never should have added bridging netfilter to the tree in the
first place, I wish I had better judgment back then.

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 06811d7..2300def 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -18,6 +18,7 @@
 #include <linux/netpoll.h>
 #include <linux/u64_stats_sync.h>
 #include <net/route.h>
+#include <net/ip.h>
 #include <linux/if_vlan.h>
 
 #define BR_HASH_BITS 8
@@ -297,6 +298,7 @@ struct net_bridge
 };
 
 struct br_input_skb_cb {
+	struct inet_skb_parm ip;
 	struct net_device *brdev;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
