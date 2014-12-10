From: Luis Henriques <luis.henriques@canonical.com>
Subject: [3.16.y-ckt stable] Patch "xen-netfront: Fix handling packets on compound pages with skb_linearize" has been added to staging queue
Date: Wed, 10 Dec 2014 17:26:28 +0000
Message-ID: <1418232388-16853-1-git-send-email-luis.henriques@canonical.com>
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Paul Durrant <paul.durrant@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
	"David S. Miller" <davem@davemloft.net>,
	Stefan Bader <stefan.bader@canonical.com>,
	Luis Henriques <luis.henriques@canonical.com>,
	kernel-team@lists.ubuntu.com
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a note to let you know that I have just added a patch titled

    xen-netfront: Fix handling packets on compound pages with skb_linearize

to the linux-3.16.y-queue branch of the 3.16.y-ckt extended stable tree 
which can be found at:

 http://kernel.ubuntu.com/git?p=ubuntu/linux.git;a=shortlog;h=refs/heads/linux-3.16.y-queue

This patch is scheduled to be released in version 3.16.7-ckt3.

If you, or anyone else, feels it should not be added to this tree, please 
reply to this email.

For more information about the 3.16.y-ckt tree, see
https://wiki.ubuntu.com/Kernel/Dev/ExtendedStable

Thanks.
-Luis

------

>From 079f869ca5082866d276b686721e89a649e622fe Mon Sep 17 00:00:00 2001
From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 11 Aug 2014 18:32:23 +0100
Subject: xen-netfront: Fix handling packets on compound pages with
 skb_linearize

commit 97a6d1bb2b658ac85ed88205ccd1ab809899884d upstream.

There is a long known problem with the netfront/netback interface: if the guest
tries to send a packet which constitues more than MAX_SKB_FRAGS + 1 ring slots,
it gets dropped. The reason is that netback maps these slots to a frag in the
frags array, which is limited by size. Having so many slots can occur since
compound pages were introduced, as the ring protocol slice them up into
individual (non-compound) page aligned slots. The theoretical worst case
scenario looks like this (note, skbs are limited to 64 Kb here):
linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page boundary,
using 2 slots
first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last bytes are at the
end and the beginning of a page, therefore they use 3 * 15 = 45 slots
last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 = 4 slots
Although I don't think this 51 slots skb can really happen, we need a solution
which can deal with every scenario. In real life there is only a few slots
overdue, but usually it causes the TCP stream to be blocked, as the retry will
most likely have the same buffer layout.
This patch solves this problem by linearizing the packet. This is not the
fastest way, and it can fail much easier as it tries to allocate a big linear
area for the whole packet, but probably easier by an order of magnitude than
anything else. Probably this code path is not touched very frequently anyway.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <Ian.Campbell@citrix.com>
Cc: Paul Durrant <paul.durrant@citrix.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Signed-off-by: David S. Miller <davem@davemloft.net>
Cc: Stefan Bader <stefan.bader@canonical.com>
Signed-off-by: Luis Henriques <luis.henriques@canonical.com>
---
 drivers/net/xen-netfront.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 055222bae6e4..23359aeb1ba0 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -628,9 +628,10 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
 		xennet_count_skb_frag_slots(skb);
 	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
-		net_alert_ratelimited(
-			"xennet: skb rides the rocket: %d slots\n", slots);
-		goto drop;
+		net_dbg_ratelimited("xennet: skb rides the rocket: %d slots, %d bytes\n",
+				    slots, skb->len);
+		if (skb_linearize(skb))
+			goto drop;
 	}

 	spin_lock_irqsave(&queue->tx_lock, flags);
