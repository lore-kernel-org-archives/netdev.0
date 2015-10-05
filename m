From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH v3 05/14] RDS: defer the over_batch work to send worker
Date: Mon, 5 Oct 2015 11:31:51 -0700
Message-ID: <5612C217.8020408@oracle.com>
References: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
 <1444067797-14101-6-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444067797-14101-6-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/5/2015 10:56 AM, Santosh Shilimkar wrote:
>
Darn. Header hunk remained in the repo. Resending it.

 From 4bebdd7a4d2960b2ff6c40b27156d041ea270765 Mon Sep 17 00:00:00 2001
From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Thu, 10 Sep 2015 11:57:14 -0700
Subject: [PATCH v3 05/14] RDS: defer the over_batch work to send worker

Current process gives up if its send work over the batch limit.
The work queue will get  kicked to finish off any other requests.
This fixes remainder condition from commit 443be0e5affe ("RDS: make
sure not to loop forever inside rds_send_xmit").

The restart condition is only for the case where we reached to
over_batch code for some other reason so just retrying again
before giving up.

While at it, make sure we use already available 'send_batch_count'
parameter instead of magic value. The batch count threshold value
of 1024 came via commit 443be0e5affe ("RDS: make sure not to loop
forever inside rds_send_xmit"). The idea is to process as big a
batch as we can but at the same time we don't hold other waiting
processes for send. Hence back-off after the send_batch_count
limit (1024) to avoid soft-lock ups.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
[v3]
Updated patch as per David Miller's comment to avoid the magic
value usage. Patch now makes use of already available but unused
send_batch_count module parameter.

  net/rds/send.c | 9 ++++++---
  1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 4df61a5..b0acd45 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -38,6 +38,7 @@
  #include <linux/list.h>
  #include <linux/ratelimit.h>
  #include <linux/export.h>
+#include <linux/sizes.h>

  #include "rds.h"

@@ -51,7 +52,7 @@
   * it to 0 will restore the old behavior (where we looped until we had
   * drained the queue).
   */
-static int send_batch_count = 64;
+static int send_batch_count = SZ_1K;
  module_param(send_batch_count, int, 0444);
  MODULE_PARM_DESC(send_batch_count, " batch factor when working the 
send queue");

@@ -223,7 +224,7 @@ restart:
  			 * through a lot of messages, lets back off and see
  			 * if anyone else jumps in
  			 */
-			if (batch_count >= 1024)
+			if (batch_count >= send_batch_count)
  				goto over_batch;

  			spin_lock_irqsave(&conn->c_lock, flags);
@@ -423,7 +424,9 @@ over_batch:
  		     !list_empty(&conn->c_send_queue)) &&
  		    send_gen == conn->c_send_gen) {
  			rds_stats_inc(s_send_lock_queue_raced);
-			goto restart;
+			if (batch_count < send_batch_count)
+				goto restart;
+			queue_delayed_work(rds_wq, &conn->c_send_w, 1);
  		}
  	}
  out:
-- 
1.9.1
