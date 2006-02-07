From: Pradeep Vincent <pradeep.vincent@gmail.com>
Subject: Re: [Patch] 2.4.32 - Neighbour Cache (ARP) State machine bug Fixed
Date: Tue, 7 Feb 2006 00:57:43 -0700
Message-ID: <9fda5f510602062357n38292cebk3c5738ccdbee83@mail.gmail.com>
References: <9fda5f510511281257o364acb3gd634f8e412cd7301@mail.gmail.com>
	 <9fda5f510602031806j2f9ef743t206c9ee2c3bef384@mail.gmail.com>
	 <20060203.181839.104353534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965010AbWBGH5y@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
In-Reply-To: <20060203.181839.104353534.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In 2.4.21, arp code uses gc_timer to check for stale arp cache
entries. In 2.6, each entry has its own timer to check for stale arp
cache. 2.4.29 to 2.4.32 kernels (atleast) use neither of these timers.
This causes problems in environments where IPs or MACs are reassigned
- saw this problem on load balancing router based networks that use
VMACs. Tested this code on load balancing router based networks as
well as peer-linux systems.


Thanks,


Signed off by: Pradeep Vincent <pradeep.vincent@gmail.com>

diff -Naur old/net/core/neighbour.c new/net/core/neighbour.c
--- old/net/core/neighbour.c    Wed Nov 23 17:15:30 2005
+++ new/net/core/neighbour.c    Wed Nov 23 17:26:01 2005
@@ -14,6 +14,7 @@
*     Vitaly E. Lavrov        releasing NULL neighbor in neigh_add.
*     Harald Welte            Add neighbour cache statistics like rtstat
*     Harald Welte            port neighbour cache rework from 2.6.9-rcX
+ *      Pradeep Vincent         Move neighbour cache entry to stale state
*/

#include <linux/config.h>
@@ -705,6 +706,14 @@
                      neigh_release(n);
                      continue;
              }
+
+               /* Mark it stale - To be reconfirmed later when used */
+               if (n->nud_state&NUD_REACHABLE &&
+                   now - n->confirmed > n->parms->reachable_time) {
+                       n->nud_state = NUD_STALE;
+                       neigh_suspect(n);
+               }
+
              write_unlock(&n->lock);


On 2/3/06, David S. Miller <davem@davemloft.net> wrote:
> From: Pradeep Vincent <pradeep.vincent@gmail.com>
> Date: Fri, 3 Feb 2006 18:06:53 -0800
>
> > Resending..
>
> Your email client has tab and newline mangled the patch so it
> cannot be applied.  Please fix this up and also supply an
> appropriate "Signed-off-by: " line.
>
> Thanks.
>
