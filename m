From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net:rfs: adjust table size checking
Date: Sun, 08 Feb 2015 20:39:13 -0800
Message-ID: <1423456753.31870.175.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:54852 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360AbbBIEjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 23:39:15 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so13931980igj.4
        for <netdev@vger.kernel.org>; Sun, 08 Feb 2015 20:39:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Make sure root user does not try something stupid.

Also make sure mask field in struct rps_sock_flow_table
does not share a cache line with the potentially often dirtied
flow table.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 567e4b79731c ("net: rfs: add hash collision detection")
---
 include/linux/netdevice.h  |    3 ++-
 net/core/sysctl_net_core.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ab3b7cef4638ceba92b749bc35564a60b0ff2a75..d115256ed5a209fe28ce971bdbde7ca421d048aa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -653,7 +653,8 @@ struct rps_dev_flow_table {
  */
 struct rps_sock_flow_table {
 	u32	mask;
-	u32	ents[0];
+
+	u32	ents[0] ____cacheline_aligned_in_smp;
 };
 #define	RPS_SOCK_FLOW_TABLE_SIZE(_num) (offsetof(struct rps_sock_flow_table, ents[_num]))
 
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 7a31be5e361fbb06d4a5063bf68da507bab3e8ec..eaa51ddf2368747c21399bf44f5a1993c0a0e39b 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -52,7 +52,7 @@ static int rps_sock_flow_sysctl(struct ctl_table *table, int write,
 
 	if (write) {
 		if (size) {
-			if (size > 1<<30) {
+			if (size > 1<<29) {
 				/* Enforce limit to prevent overflow */
 				mutex_unlock(&sock_flow_mutex);
 				return -EINVAL;
