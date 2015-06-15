From: Roman I Khimov <khimov@altell.ru>
Subject: [PATCH] net: fix search limit handling in skb_find_text()
Date: Mon, 15 Jun 2015 12:11:58 +0300
Message-ID: <1434359518-16897-1-git-send-email-khimov@altell.ru>
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, roman@khimov.ru,
	Roman I Khimov <khimov@altell.ru>,
	Phil Oester <kernel@linuxace.com>
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Suppose that we're trying to use an xt_string netfilter module to match a
string in a specially crafted packet that has "a nice string" starting at
offset 28.

It could be done in iptables like this:

-A some_chain -m string --string "a nice string" --algo bm --from 28 --to 38 -j DROP

And it would work as expected. Now changing that to

-A some_chain -m string --string "a nice string" --algo bm --from 29 --to 38 -j DROP

breaks the match, as expected. But, if we try to make

-A some_chain -m string --string "a nice string" --algo bm --from 20 --to 28 -j DROP

then it suddenly works again! So the 'to' parameter seems to be inclusive, not
working as an offset after which no search should be done. OK, now if we try:

-A some_chain -m string --string "a nice string" --algo bm --from 28 --to 28 -j DROP

it doesn't work. So, for the case of equal 'from' and 'to' it's treated in a
different way.

The first behaviour (matching at 'to' offset) comes from skb_find_text()
comparison. The second one (not matching if 'from' and 'to' are equal) comes
from skb_seq_read() check for (abs_offset >= st->upper_offset).

I think that the way skb_find_text() handles 'to' is wrong and should be fixed
so that we always have predictable behaviour -- only match before 'to' offset.

There are currently only five usages of skb_find_text() in the kernel and it
looks to me that none of them expect to match something at the 'to' offset,
so probably this change is safe.

Reported-by: Edward Makarov <makarov@altell.ru>
Tested-by: Edward Makarov <makarov@altell.ru>
Signed-off-by: Roman I Khimov <khimov@altell.ru>
Cc: Phil Oester <kernel@linuxace.com>
---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3cfff2a..0d32be7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2901,7 +2901,7 @@ unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
 	skb_prepare_seq_read(skb, from, to, TS_SKB_CB(&state));
 
 	ret = textsearch_find(config, &state);
-	return (ret <= to - from ? ret : UINT_MAX);
+	return (ret < to - from ? ret : UINT_MAX);
 }
 EXPORT_SYMBOL(skb_find_text);
 
-- 
2.1.4

