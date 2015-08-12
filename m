From: Calvin Owens <calvinowens@fb.com>
Subject: [PATCH] net: Use SK_MEM_QUANTUM as minimum for tcp/udp rmem/wmem
Date: Tue, 11 Aug 2015 21:54:20 -0700
Message-ID: <20150812045420.GA3908557@mail.thefacebook.com>
References: <1438806414-751067-1-git-send-email-calvinowens@fb.com>
 <20150809.224114.818332231954008575.davem@davemloft.net>
 <20150811033406.GA1136819@mail.thefacebook.com>
 <20150810.204630.1903301700926701432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>, <sorin@returnze.ro>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150810.204630.1903301700926701432.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 8133534c760d4083 ("net: limit tcp/udp rmem/wmem to
SOCK_{RCV,SND}BUF_MIN") modified four sysctls to enforce that the values
written to them are not less than SOCK_MIN_{RCV,SND}BUF.

That change causes 4096 (or SK_MEM_QUANTUM) to no longer be accepted as
a valid value for 'min' in tcp_wmem and udp_wmem_min. 4096 has been the
default for both of those sysctls for a long time, and unfortunately
seems to be an extremely popular setting. This change breaks a large
number of sysctl configurations at FB.

That commit referred to b1cb59cf2efe7971 ("net: sysctl_net_core: check
SNDBUF and RCVBUF for min length"), which choose to use the SOCK_MIN
constants as the lower limits to avoid nasty bugs. But AFAICS, a limit
of SOCK_MIN_SNDBUF isn't necessary to do that: the BUG_ON cited in the
commit message seems to have happened because unix_stream_sendmsg()
expects a minimum of a full page (ie SK_MEM_QUANTUM) and the math broke,
not because it had less than SOCK_MIN_SNDBUF allocated.

Nothing seems to assume that it has at least SOCK_MIN_SNDBUF to play
with, so I think enforcing a minimum of SK_MEM_QUANTUM avoids the sort
of bugs 8133534c was trying to avoid, and it does so without breaking
anybody's sysctl configurations.

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
