From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 05/14] ipv4/ip_socketglue: Apply ACCESS_ONCE() to avoid sparse false positive
Date: Fri, 15 Nov 2013 16:40:08 -0800
Message-ID: <1384562417-817-5-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20131116003946.GA316@linux.vnet.ibm.com>
 <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
Cc: mingo@kernel.org, laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	josh@joshtriplett.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com,
	edumazet@google.com, darren@dvhart.com, fweisbec@gmail.com,
	sbw@mit.edu, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

The sparse checking for rcu_assign_pointer() was recently upgraded
to reject non-__kernel address spaces.  This also rejects __rcu,
which is almost always the right thing to do.  However, the use in
ip_ra_control() is legitimate: It is assigning a pointer to an element
from an RCU-protected list, and all elements of this list are already
visible to caller.

This commit therefore silences this false positive by laundering the
pointer using ACCESS_ONCE() as suggested by Eric Dumazet and Josh
Triplett.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
---
 net/ipv4/ip_sockglue.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index d9c4f113d709..a0e7f176e9c8 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -269,7 +269,8 @@ int ip_ra_control(struct sock *sk, unsigned char on,
 			}
 			/* dont let ip_call_ra_chain() use sk again */
 			ra->sk = NULL;
-			rcu_assign_pointer(*rap, ra->next);
+			/* Both --rcu and visible, so ACCESS_ONCE() is OK. */
+			ACCESS_ONCE(*rap) = ra->next;
 			spin_unlock_bh(&ip_ra_lock);
 
 			if (ra->destructor)
-- 
1.8.1.5
