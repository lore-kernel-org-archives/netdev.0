From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/26] netfilter: nf_log: fix error on write NONE to logger choice sysctl
Date: Wed,  6 Jul 2016 16:24:08 +0200
Message-ID: <1467815048-2240-27-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34357 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932352AbcGFO1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 10:27:09 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id A3D3A17DB70
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:27:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 92E069EBC7
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:27:07 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5FA939EBA5
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:27:03 +0200 (CEST)
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>

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

v2: add missed error check for proc_dostring

Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_log.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 18e325c..aa5847a 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -418,16 +418,17 @@ static int nf_log_proc_dostring(struct ctl_table *table, int write,
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
+		r = proc_dostring(&tmp, write, buffer, lenp, ppos);
+		if (r)
+			return r;
 
 		if (!strcmp(buf, "NONE")) {
 			nf_log_unbind_pf(net, tindex);
-- 
2.1.4
