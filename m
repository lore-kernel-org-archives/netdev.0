From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH 2/2] sctp: optimize the sctp_sysctl_net_register
Date: Mon, 27 Jan 2014 11:49:03 +0800
Message-ID: <1390794543-1008-3-git-send-email-wangweidong1@huawei.com>
References: <1390794543-1008-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:55053 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbaA0Dup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 22:50:45 -0500
In-Reply-To: <1390794543-1008-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here, when the net is init_net, we needn't to kmemdup the ctl_table
again. So add a check for net. Also we can save some memory.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sysctl.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 2ddb401..b65396b 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -403,15 +403,17 @@ static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
 
 int sctp_sysctl_net_register(struct net *net)
 {
-	struct ctl_table *table;
-	int i;
+	struct ctl_table *table = sctp_net_table;
 
-	table = kmemdup(sctp_net_table, sizeof(sctp_net_table), GFP_KERNEL);
-	if (!table)
-		return -ENOMEM;
+	if (!net_eq(net, &init_net)) {
+		int i;
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
