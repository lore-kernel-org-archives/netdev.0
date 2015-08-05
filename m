From: Calvin Owens <calvinowens@fb.com>
Subject: [PATCH] net: Unbreak resetting default values for tcp_wmem/udp_wmem_min
Date: Wed, 5 Aug 2015 13:26:54 -0700
Message-ID: <1438806414-751067-1-git-send-email-calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>, Sorin Dumitru <sorin@returnze.ro>,
	Calvin Owens <calvinowens@fb.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to
SOCK_{RCV,SND}BUF_MIN") modified four sysctls to enforce that the values
written to them are not less than SOCK_MIN_{RCV,SND}BUF.

This change is fine for tcp_rmem and udp_rmem_min, since SOCK_MIN_RCVBUF
is equal to equal to TCP_SKB_MIN_TRUESIZE. But it breaks tcp_wmem and
udp_wmem_min for previously valid values because SOCK_MIN_SNDBUF is
(2 * TCP_SKB_MIN_TRUESIZE), which ends up being greater than 4KB.

Thus, 4096 is no longer accepted as a valid value, despite still being
the default for udp_wmem_min, and for 'min' in tcp_wmem. A huge number
of sysctl configurations at FB use 4096 as 'min', so this change breaks
all of them.

This patch changes the sysctls to simply enforce that the value written
is greater than or equal to the default value of SK_MEM_QUANTUM.

Fixes: 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to SOCK_MIN...")
Signed-off-by: Calvin Owens <calvinowens@fb.com>
---
 net/ipv4/sysctl_net_ipv4.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 433231c..a214b6a 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -41,8 +41,7 @@ static int tcp_syn_retries_min = 1;
 static int tcp_syn_retries_max = MAX_TCP_SYNCNT;
 static int ip_ping_group_range_min[] = { 0, 0 };
 static int ip_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
-static int min_sndbuf = SOCK_MIN_SNDBUF;
-static int min_rcvbuf = SOCK_MIN_RCVBUF;
+static int min_buf = SK_MEM_QUANTUM;
 
 /* Update system visible IP port range */
 static void set_local_port_range(struct net *net, int range[2])
@@ -530,7 +529,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_tcp_wmem),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &min_sndbuf,
+		.extra1		= &min_buf,
 	},
 	{
 		.procname	= "tcp_notsent_lowat",
@@ -545,7 +544,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_tcp_rmem),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &min_rcvbuf,
+		.extra1		= &min_buf,
 	},
 	{
 		.procname	= "tcp_app_win",
@@ -758,7 +757,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_udp_rmem_min),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &min_rcvbuf,
+		.extra1		= &min_buf,
 	},
 	{
 		.procname	= "udp_wmem_min",
@@ -766,7 +765,7 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= sizeof(sysctl_udp_wmem_min),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &min_sndbuf,
+		.extra1		= &min_buf,
 	},
 	{ }
 };
-- 
1.8.1
