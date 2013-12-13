From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v2] sctp: loading sctp when load sctp_probe
Date: Fri, 13 Dec 2013 11:00:10 +0800
Message-ID: <52AA783A.7090502@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:34998 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776Ab3LMDB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 22:01:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when I modprobe sctp_probe, it failed with "FATAL: ". I found that
sctp should load before sctp_probe register jprobe. So I add a
sctp_setup_jprobe for loading 'sctp' when first failed to register
jprobe, just do this similar to dccp_probe.

v2: add MODULE_SOFTDEP and check of request_module, as suggested by Neil

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/probe.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 53c452e..5e68b94 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -38,6 +38,7 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
+MODULE_SOFTDEP("pre: sctp");
 MODULE_AUTHOR("Wei Yongjun <yjwei@cn.fujitsu.com>");
 MODULE_DESCRIPTION("SCTP snooper");
 MODULE_LICENSE("GPL");
@@ -182,6 +183,20 @@ static struct jprobe sctp_recv_probe = {
 	.entry	= jsctp_sf_eat_sack,
 };
 
+static __init int sctp_setup_jprobe(void)
+{
+	int ret = register_jprobe(&sctp_recv_probe);
+
+	if (ret) {
+		if (request_module("sctp"))
+			goto out;
+		ret = register_jprobe(&sctp_recv_probe);
+	}
+
+out:
+	return ret;
+}
+
 static __init int sctpprobe_init(void)
 {
 	int ret = -ENOMEM;
@@ -202,7 +217,7 @@ static __init int sctpprobe_init(void)
 			 &sctpprobe_fops))
 		goto free_kfifo;
 
-	ret = register_jprobe(&sctp_recv_probe);
+	ret = sctp_setup_jprobe();
 	if (ret)
 		goto remove_proc;
 
-- 
1.7.12
