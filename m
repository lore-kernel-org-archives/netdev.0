From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] drop_monitor: Add error code to detect duplicate state
 changes
Date: Tue, 20 Jul 2010 10:52:09 -0400
Message-ID: <20100720145209.GE1995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60043 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758499Ab0GTOyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 10:54:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
	Patch to add -EAGAIN error to dropwatch netlink message handling code.
-EAGAIN will be returned anytime userspace attempts to transition the state of
the drop monitor service to a state that its already in.  That allows user space
to detect this condition, so it doesn't wait for a success ACK that will never
arrive.  Tested successfully by me

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 drop_monitor.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)


diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index ad41529..646ef3b 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -223,6 +223,11 @@ static int set_all_monitor_traces(int state)
 
 	spin_lock(&trace_state_lock);
 
+	if (state == trace_state) {
+		rc = -EAGAIN;
+		goto out_unlock;
+	}
+
 	switch (state) {
 	case TRACE_ON:
 		rc |= register_trace_kfree_skb(trace_kfree_skb_hit, NULL);
@@ -251,11 +256,12 @@ static int set_all_monitor_traces(int state)
 
 	if (!rc)
 		trace_state = state;
+	else
+		rc = -EINPROGRESS;
 
+out_unlock:
 	spin_unlock(&trace_state_lock);
 
-	if (rc)
-		return -EINPROGRESS;
 	return rc;
 }
 
