From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: [PATCH] netfilter: nf_log: fix error on write NONE to logger choice sysctl
Date: Fri,  1 Jul 2016 16:16:12 +0300
Message-ID: <1467378972-16770-1-git-send-email-ptikhomirov@virtuozzo.com>
Cc: Eric Leblond <eric@inl.fr>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Konstantin Khorenko <khorenko@virtuozzo.com>,
	Pavel Tikhomirov <ptikhomirov@virtuozzo.com>,
	<devel@openvz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is hard to unbind nf-logger:

  echo NONE > /proc/sys/net/netfilter/nf_log/0
  bash: echo: write error: No such file or directory

  sysctl -w net.netfilter.nf_log.0=NONE
  sysctl: setting key "net.netfilter.nf_log.0": No such file or directory
  net.netfilter.nf_log.0 = NONE

You need explicitly send '\0', for instance like:

  echo -e "NONE\0" > /proc/sys/net/netfilter/nf_log/0

That seem to be strange, so fix it using proc_dostring.

Now it works fine:
   modprobe nfnetlink_log
   echo nfnetlink_log > /proc/sys/net/netfilter/nf_log/0
   cat /proc/sys/net/netfilter/nf_log/0
   nfnetlink_log
   echo NONE > /proc/sys/net/netfilter/nf_log/0
   cat /proc/sys/net/netfilter/nf_log/0
   NONE

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
---
 net/netfilter/nf_log.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index a5d41df..c7c5882 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -398,16 +398,15 @@ static int nf_log_proc_dostring(struct ctl_table *table, int write,
 {
 	const struct nf_logger *logger;
 	char buf[NFLOGGER_NAME_LEN];
-	size_t size = *lenp;
 	int r = 0;
 	int tindex = (unsigned long)table->extra1;
 	struct net *net = current->nsproxy->net_ns;
 
 	if (write) {
-		if (size > sizeof(buf))
-			size = sizeof(buf);
-		if (copy_from_user(buf, buffer, size))
-			return -EFAULT;
+		struct ctl_table tmp = *table;
+
+		tmp.data = buf;
+		proc_dostring(&tmp, write, buffer, lenp, ppos);
 
 		if (!strcmp(buf, "NONE")) {
 			nf_log_unbind_pf(net, tindex);
-- 
2.5.5
