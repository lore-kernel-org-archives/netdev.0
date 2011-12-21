From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH] rps: fix insufficient bounds checking in store_rps_dev_flow_table_cnt()
Date: Wed, 21 Dec 2011 13:50:59 -0500
Message-ID: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, Xi Wang <xi.wang@gmail.com>
To: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:45820 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754Ab1LUSwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 13:52:41 -0500
Received: by qadb15 with SMTP id b15so4909787qad.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 10:52:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting a large rps_flow_cnt like 1073741824 (1 << 30) on 32-bit
platform will cause a kernel oops due to insufficient bounds checking.

	if (count > 1<<30) {
		/* Enforce a limit to prevent overflow */
		return -EINVAL;
	}
	count = roundup_pow_of_two(count);
	table = vmalloc(RPS_DEV_FLOW_TABLE_SIZE(count));

Note that the macro RPS_DEV_FLOW_TABLE_SIZE(count) is defined as:

	... + (count * sizeof(struct rps_dev_flow))

where sizeof(struct rps_dev_flow) is 8.  (1 << 30) * 8 will overflow
32 bits.  This patch changes the upper bound to (1 << 28).

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 net/core/net-sysfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index c71c434..f53a947 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -665,7 +665,7 @@ static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 	if (count) {
 		int i;
 
-		if (count > 1<<30) {
+		if (count > 1<<28) {
 			/* Enforce a limit to prevent overflow */
 			return -EINVAL;
 		}
-- 
1.7.5.4
