From: Jarod Wilson <jarod@redhat.com>
Subject: [RFC PATCH net] net/core: don't increment rx_dropped on inactive slaves
Date: Fri, 22 Jan 2016 14:11:22 -0500
Message-ID: <1453489882-57948-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tom Herbert <tom@herbertland.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The network core tries to keep track of dropped packets, but some packets
you wouldn't really call dropped, so much as intentionally ignored, under
certain circumstances. One such case is that of bonding and team device
slaves that are currently inactive. Their respective rx_handler functions
return RX_HANDLER_EXACT (the only places in the kernel that return that),
which ends up tracking into the network core's __netif_receive_skb_core()
function's drop path, with no pt_prev set. On a noisy network, this can
result in a very rapidly incrementing rx_dropped counter, not only on the
inactive slave(s), but also on the master device, such as the following:

Inter-|   Receive                                                |  Transmit
 face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  p7p1: 14783346  140430    0 140428    0     0          0      2040      680       8    0    0    0     0       0          0
  p7p2: 14805198  140648    0    0    0     0          0      2034        0       0    0    0    0     0       0          0
 bond0: 53365248  532798    0 421160    0     0          0    115151     2040      24    0    0    0     0       0          0
    lo:    5420      54    0    0    0     0          0         0     5420      54    0    0    0     0       0          0
  p5p1: 19292195  196197    0 140368    0     0          0     56564      680       8    0    0    0     0       0          0
  p5p2: 19289707  196171    0 140364    0     0          0     56547      680       8    0    0    0     0       0          0
   em3: 20996626  158214    0    0    0     0          0       383        0       0    0    0    0     0       0          0
   em2: 14065122  138462    0    0    0     0          0       310        0       0    0    0    0     0       0          0
   em1: 14063162  138440    0    0    0     0          0       308        0       0    0    0    0     0       0          0
   em4: 21050830  158729    0    0    0     0          0       385    71662     469    0    0    0     0       0          0
   ib0:       0       0    0    0    0     0          0         0        0       0    0    0    0     0       0          0

In this scenario, p5p1, p5p2 and p7p1 are all inactive slaves in an
active-backup bond0, and you can see that all three have high drop counts,
with the master bond0 showing a tally of all three.

I know that this was previously discussed some here:

    http://www.spinics.net/lists/netdev/msg226341.html

It seems additional counters never came to fruition, but honestly, for
this particular case, I'm not even sure they're warranted, I'd be inclined
to say just silently drop these packets without incrementing a counter. At
least, that's probably what would make someone who has complained loudly
about this issue happy, as they have monitoring tools that are squaking
loudly at any increments to rx_dropped.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@mellanox.com>
CC: Daniel Borkmann <daniel@iogearbox.net>
CC: Tom Herbert <tom@herbertland.com>
CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 net/core/dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8cba3d8..1354c7b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4153,8 +4153,11 @@ ncls:
 		else
 			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
+		if (deliver_exact)
+			goto inactive; /* bond or team inactive slave */
 drop:
 		atomic_long_inc(&skb->dev->rx_dropped);
+inactive:
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)
-- 
1.8.3.1
