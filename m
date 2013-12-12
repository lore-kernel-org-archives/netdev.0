From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH] sctp: loading sctp when load sctp_probe
Date: Thu, 12 Dec 2013 20:32:36 +0800
Message-ID: <52A9ACE4.3080506@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:18291 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab3LLMdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 07:33:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when I modprobe sctp_probe, it failed with "FATAL: ". I found that 
sctp should load before sctp_probe register jprobe. So I add a
sctp_setup_jprobe for loading 'sctp' when first failed to register
jprobe, just do this similar to dccp_probe.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/probe.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 53c452e..cd9565a 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -182,6 +182,17 @@ static struct jprobe sctp_recv_probe = {
 	.entry	= jsctp_sf_eat_sack,
 };
 
+static __init int sctp_setup_jprobe(void)
+{
+	int ret = register_jprobe(&sctp_recv_probe);
+
+	if (ret) {
+		request_module("sctp");
+		ret = register_jprobe(&sctp_recv_probe);
+	}
+	return ret;
+}
+
 static __init int sctpprobe_init(void)
 {
 	int ret = -ENOMEM;
@@ -202,7 +213,7 @@ static __init int sctpprobe_init(void)
 			 &sctpprobe_fops))
 		goto free_kfifo;
 
-	ret = register_jprobe(&sctp_recv_probe);
+	ret = sctp_setup_jprobe();
 	if (ret)
 		goto remove_proc;
 
-- 
1.7.12
