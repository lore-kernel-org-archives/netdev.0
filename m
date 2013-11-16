From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 06/14] ipv6/ip6_tunnel: Apply ACCESS_ONCE() to avoid sparse false positive
Date: Fri, 15 Nov 2013 16:40:09 -0800
Message-ID: <1384562417-817-6-git-send-email-paulmck@linux.vnet.ibm.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:38301 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754836Ab3KPAk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 19:40:27 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 15 Nov 2013 17:40:26 -0700
In-Reply-To: <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

The sparse checking for rcu_assign_pointer() was recently upgraded
to reject non-__kernel address spaces.  This also rejects __rcu,
which is almost always the right thing to do.  However, the use in
ip6_tnl_unlink() is legitimate: It is assigning a pointer to an element
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
 net/ipv6/ip6_tunnel.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 61355f7f4da5..2bea7a4e49ed 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -245,7 +245,8 @@ ip6_tnl_unlink(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 	     (iter = rtnl_dereference(*tp)) != NULL;
 	     tp = &iter->next) {
 		if (t == iter) {
-			rcu_assign_pointer(*tp, t->next);
+			/* Both --rcu and visible, so ACCESS_ONCE() is OK. */
+			ACCESS_ONCE(*tp) = t->next;
 			break;
 		}
 	}
-- 
1.8.1.5
