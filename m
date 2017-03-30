From: gfree.wind@foxmail.com
Subject: [PATCH net 1/1] proc/sysctl: Fix the int overflow for jiffies conversion
Date: Thu, 30 Mar 2017 08:39:44 +0800
Message-ID: <1490834384-8833-1-git-send-email-gfree.wind@foxmail.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgbr2.qq.com ([54.207.22.56]:49537 "EHLO smtpbgbr2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932700AbdC3AkD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:40:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The function do_proc_dointvec_jiffies_conv uses LONG_MX/HZ as the
max value to avoid overflow. But actually the *valp is int type, so
it still causes overflow.

For example,
echo 2147483647 > ./sys/net/ipv4/tcp_keepalive_time
Then,
cat ./sys/net/ipv4/tcp_keepalive_time
The output is "-1", it is not expected.

Now use INT_MAX/HZ as the max value instead LONG_MAX/HZ to fix it.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 kernel/sysctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index acf0a5a..60474df 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2571,7 +2571,7 @@ static int do_proc_dointvec_jiffies_conv(bool *negp, unsigned long *lvalp,
 					 int write, void *data)
 {
 	if (write) {
-		if (*lvalp > LONG_MAX / HZ)
+		if (*lvalp > INT_MAX / HZ)
 			return 1;
 		*valp = *negp ? -(*lvalp*HZ) : (*lvalp*HZ);
 	} else {
-- 
1.9.1
