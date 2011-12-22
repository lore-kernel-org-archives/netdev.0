From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v2] rps: fix insufficient bounds checking in store_rps_dev_flow_table_cnt()
Date: Thu, 22 Dec 2011 18:35:22 -0500
Message-ID: <4EF3BEBA.4040402@gmail.com>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58853 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334Ab1LVXf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 18:35:27 -0500
Received: by iaeh11 with SMTP id h11so14171680iae.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 15:35:26 -0800 (PST)
In-Reply-To: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting a large rps_flow_cnt like (1 << 30) on 32-bit platform will
cause a kernel oops due to insufficient bounds checking.

	if (count > 1<<30) {
		/* Enforce a limit to prevent overflow */
		return -EINVAL;
	}
	count = roundup_pow_of_two(count);
	table = vmalloc(RPS_DEV_FLOW_TABLE_SIZE(count));

Note that the macro RPS_DEV_FLOW_TABLE_SIZE(count) is defined as:

	... + (count * sizeof(struct rps_dev_flow))

where sizeof(struct rps_dev_flow) is 8.  (1 << 30) * 8 will overflow
32 bits.

This patch replaces the magic number (1 << 30) with a symbolic bound.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 net/core/net-sysfs.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index c71c434..385aefe 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -665,11 +665,14 @@ static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 	if (count) {
 		int i;
 
-		if (count > 1<<30) {
+		if (count > INT_MAX)
+			return -EINVAL;
+		count = roundup_pow_of_two(count);
+		if (count > (ULONG_MAX - sizeof(struct rps_dev_flow_table))
+				/ sizeof(struct rps_dev_flow)) {
 			/* Enforce a limit to prevent overflow */
 			return -EINVAL;
 		}
-		count = roundup_pow_of_two(count);
 		table = vmalloc(RPS_DEV_FLOW_TABLE_SIZE(count));
 		if (!table)
 			return -ENOMEM;
-- 
1.7.5.4
