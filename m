From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net] ipv4: flush route cache after change accept_local
Date: Thu,  1 Dec 2011 19:47:56 +0800
Message-ID: <1e224b52de77dcd5f994c8e4c77c780c6996e4a4.1322740026.git.panweiping3@gmail.com>
Cc: Weiping Pan <panweiping3@gmail.com>,
	"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
	[IPv4/...),
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> (maintainer:NETWORKING
	[IPv4/...),
	James Morris <jmorris@namei.org> (maintainer:NETWORKING [IPv4/...),
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org> (maintainer:NETWORKING
	[IPv4/...),
	Patrick McHardy <kaber@trash.net> (maintainer:NETWORKING [IPv4/...),
	netdev@vger.kernel.org (open list:NETWORKING [IPv4/...),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After reset ipv4_devconf->data[IPV4_DEVCONF_ACCEPT_LOCAL] to 0,
we should flash route cache, or it will continue receive packets with local
source address, which should be dropped.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/devinet.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index c6b5092..de1a772 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1490,7 +1490,9 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 			     void __user *buffer,
 			     size_t *lenp, loff_t *ppos)
 {
+	int old_value = *(int *)ctl->data;
 	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	int new_value = *(int *)ctl->data;
 
 	if (write) {
 		struct ipv4_devconf *cnf = ctl->extra1;
@@ -1501,6 +1503,9 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 
 		if (cnf == net->ipv4.devconf_dflt)
 			devinet_copy_dflt_conf(net, i);
+		if ((i == IPV4_DEVCONF_ACCEPT_LOCAL - 1))
+			if ((new_value == 0) && (old_value != 0))
+				rt_cache_flush(net, 0);
 	}
 
 	return ret;
-- 
1.7.4
