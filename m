From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v3 2/2] sctp: optimize the sctp_sysctl_net_register
Date: Wed, 12 Feb 2014 09:44:44 +0800
Message-ID: <1392169484-8256-3-git-send-email-wangweidong1@huawei.com>
References: <1392169484-8256-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:26239 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbaBLBpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 20:45:21 -0500
In-Reply-To: <1392169484-8256-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here, when the net is init_net, we needn't to kmemdup the ctl_table
again. So add a check for net. Also we can save some memory.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sysctl.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index d354de5..35c8923 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -402,15 +402,18 @@ static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
 
 int sctp_sysctl_net_register(struct net *net)
 {
-	struct ctl_table *table;
-	int i;
+	struct ctl_table *table = sctp_net_table;
+
+	if (!net_eq(net, &init_net)) {
+		int i;
 
-	table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
-	if (!table)
-		return -ENOMEM;
+		table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
+		if (!table)
+			return -ENOMEM;
 
-	for (i = 0; table[i].data; i++)
-		table[i].data += (char *)(&net->sctp) - (char *)&init_net.sctp;
+		for (i = 0; table[i].data; i++)
+			table[i].data += (char *)(&net->sctp) - (char *)&init_net.sctp;
+	}
 
 	net->sctp.sysctl_header = register_net_sysctl(net, "net/sctp", table);
 	return 0;
-- 
1.7.12
