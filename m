From: "David S. Miller" <davem@davemloft.net>
Subject: Re: e1000 lockup in linux 2.6.9-rc2
Date: Mon, 20 Sep 2004 13:56:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920135606.7a0885df.davem@davemloft.net>
References: <Pine.LNX.4.58.0409202339050.2170@kai.makisara.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kai Makisara <Kai.Makisara@kolumbus.fi>
In-Reply-To: <Pine.LNX.4.58.0409202339050.2170@kai.makisara.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2004 23:53:15 +0300 (EEST)
Kai Makisara <Kai.Makisara@kolumbus.fi> wrote:

> When I started large data transfers in 100 Mb/s network, my computer very 
> soon locked totally (i.e., not responding to network, keyboard and mouse 
> dead). This had not happened for several days with 2.6.9-rc2 when the 
> network activity had been light (1 Mb/s DSL).
> 
> Some experimentation showed that the lockups were caused by this patch 
> fragment in 2.6.9-rc2:

Please make sure you have this patch in your
tree, it should fix your problem:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/13 12:58:04-07:00 ak@muc.de 
#   [NET]: Fix missing spin lock in lltx path.
#   
#   This fixes a silly missing spin lock in the relock path. For some 
#   reason it seems to still work when you don't have spinlock debugging
#   enabled.
#   
#   Please apply.
#   
#   Thanks to Arjan's spinlock debug kernel for finding it.
#   
#   Signed-off-by: Andi Kleen <ak@muc.de>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/sched/sch_generic.c
#   2004/09/13 12:57:46-07:00 ak@muc.de +3 -1
#   [NET]: Fix missing spin lock in lltx path.
#   
#   This fixes a silly missing spin lock in the relock path. For some 
#   reason it seems to still work when you don't have spinlock debugging
#   enabled.
#   
#   Please apply.
#   
#   Thanks to Arjan's spinlock debug kernel for finding it.
#   
#   Signed-off-by: Andi Kleen <ak@muc.de>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-09-20 13:36:19 -07:00
+++ b/net/sched/sch_generic.c	2004-09-20 13:36:19 -07:00
@@ -148,8 +148,10 @@
 					spin_lock(&dev->queue_lock);
 					return -1;
 				}
-				if (ret == NETDEV_TX_LOCKED && nolock)
+				if (ret == NETDEV_TX_LOCKED && nolock) {
+					spin_lock(&dev->queue_lock);
 					goto collision; 
+				}
 			}
 
 			/* NETDEV_TX_BUSY - we need to requeue */
