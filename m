From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/1][net-next] dccp: catch failed request_module call in
 dccp_probe init   (was: [PATCH net-next] dccp: add check request_moduls in
 setup_jprobe)
Date: Tue, 17 Dec 2013 19:24:33 -0700
Message-ID: <20131217192433.168b39ef@liptov.cs.ualberta.ca>
References: <52B043D9.9090808@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <dccp@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spey.erg.abdn.ac.uk ([139.133.204.173]:58542 "EHLO
	spey.erg.abdn.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3LRCYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 21:24:42 -0500
In-Reply-To: <52B043D9.9090808@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wang,

thank you for the patch, please find refactored version below, changes are
 (a) if request_module fails, return its error code instead of the previous ret,
 (b) refactor code -- setup_jprobe becomes superfluous.

Please add your signed off if ok, since it is essentially your patch.

>>>>>>>>>>>>>>>>>>>>>>> Wang's patch revised <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: catch failed request_module call in dccp_probe init

Check the return value of request_module during dccp_probe initialisation,
bail out if that call fails.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/probe.c |   19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -152,17 +152,6 @@ static const struct file_operations dccp
 	.llseek  = noop_llseek,
 };
 
-static __init int setup_jprobe(void)
-{
-	int ret = register_jprobe(&dccp_send_probe);
-
-	if (ret) {
-		request_module("dccp");
-		ret = register_jprobe(&dccp_send_probe);
-	}
-	return ret;
-}
-
 static __init int dccpprobe_init(void)
 {
 	int ret = -ENOMEM;
@@ -174,7 +163,13 @@ static __init int dccpprobe_init(void)
 	if (!proc_create(procname, S_IRUSR, init_net.proc_net, &dccpprobe_fops))
 		goto err0;
 
-	ret = setup_jprobe();
+	ret = register_jprobe(&dccp_send_probe);
+	if (ret) {
+		ret = request_module("dccp");
+		if (!ret)
+			ret = register_jprobe(&dccp_send_probe);
+	}
+
 	if (ret)
 		goto err1;
 
