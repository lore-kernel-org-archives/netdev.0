From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH] bridge: netfilter: fix information leak
Date: Mon, 14 Feb 2011 13:54:35 +0300
Message-ID: <1297680875-11663-1-git-send-email-segoon@openwall.com>
Cc: security@kernel.org,
	Bart De Schuymer <bart.de.schuymer@pandora.be>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	ebtables-user@lists.sourceforge.net,
	ebtables-devel@lists.sourceforge.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Struct tmp is copied from userspace.  It is not checked whether the "name"
field is NULL terminated.  This may lead to buffer overflow and passing
contents of kernel stack as a module name to try_then_request_module() and,
consequently, to modprobe commandline.  It would be seen by all userspace
processes.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 Compile tested.

 net/bridge/netfilter/ebtables.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 5f1825d..1ea820b 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1107,6 +1107,8 @@ static int do_replace(struct net *net, const void __user *user,
 	if (tmp.num_counters >= INT_MAX / sizeof(struct ebt_counter))
 		return -ENOMEM;
 
+	tmp.name[sizeof(tmp.name)-1] = 0;
+
 	countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
 	newinfo = vmalloc(sizeof(*newinfo) + countersize);
 	if (!newinfo)
-- 
1.7.0.4

