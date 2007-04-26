From: David Howells <dhowells@redhat.com>
Subject: [PATCH 13/14] AFS: Implement the CB.InitCallBackState3 operation
	[net-2.6]
Date: Thu, 26 Apr 2007 20:55:22 +0100
Message-ID: <20070426195522.24531.63006.stgit@warthog.cambridge.redhat.com>
References: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031469AbXDZTzZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 15:55:25 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3QJtOxP029140
	for <netdev@vger.kernel.org>; Thu, 26 Apr 2007 15:55:24 -0400
In-Reply-To: <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the CB.InitCallBackState3 operation for the fileserver to call.
This reduces the amount of network traffic because if this op is aborted, the
fileserver will then attempt an CB.InitCallBackState operation.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/afs/afs_cm.h    |    1 +
 fs/afs/cmservice.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/fs/afs/afs_cm.h b/fs/afs/afs_cm.h
index d4bd201..7b4d4fa 100644
--- a/fs/afs/afs_cm.h
+++ b/fs/afs/afs_cm.h
@@ -23,6 +23,7 @@ enum AFS_CM_Operations {
 	CBGetCE			= 208,	/* get cache file description */
 	CBGetXStatsVersion	= 209,	/* get version of extended statistics */
 	CBGetXStats		= 210,	/* get contents of extended statistics data */
+	CBInitCallBackState3	= 213,	/* initialise callback state, version 3 */
 	CBGetCapabilities	= 65538, /* get client capabilities */
 };
 
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index a6af3ac..6685f4c 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -20,6 +20,8 @@ struct workqueue_struct *afs_cm_workqueue;
 
 static int afs_deliver_cb_init_call_back_state(struct afs_call *,
 					       struct sk_buff *, bool);
+static int afs_deliver_cb_init_call_back_state3(struct afs_call *,
+						struct sk_buff *, bool);
 static int afs_deliver_cb_probe(struct afs_call *, struct sk_buff *, bool);
 static int afs_deliver_cb_callback(struct afs_call *, struct sk_buff *, bool);
 static int afs_deliver_cb_get_capabilities(struct afs_call *, struct sk_buff *,
@@ -47,6 +49,16 @@ static const struct afs_call_type afs_SRXCBInitCallBackState = {
 };
 
 /*
+ * CB.InitCallBackState3 operation type
+ */
+static const struct afs_call_type afs_SRXCBInitCallBackState3 = {
+	.name		= "CB.InitCallBackState3",
+	.deliver	= afs_deliver_cb_init_call_back_state3,
+	.abort_to_error	= afs_abort_to_error,
+	.destructor	= afs_cm_destructor,
+};
+
+/*
  * CB.Probe operation type
  */
 static const struct afs_call_type afs_SRXCBProbe = {
@@ -83,6 +95,9 @@ bool afs_cm_incoming_call(struct afs_call *call)
 	case CBInitCallBackState:
 		call->type = &afs_SRXCBInitCallBackState;
 		return true;
+	case CBInitCallBackState3:
+		call->type = &afs_SRXCBInitCallBackState3;
+		return true;
 	case CBProbe:
 		call->type = &afs_SRXCBProbe;
 		return true;
@@ -312,6 +327,37 @@ static int afs_deliver_cb_init_call_back_state(struct afs_call *call,
 }
 
 /*
+ * deliver request data to a CB.InitCallBackState3 call
+ */
+static int afs_deliver_cb_init_call_back_state3(struct afs_call *call,
+						struct sk_buff *skb,
+						bool last)
+{
+	struct afs_server *server;
+	struct in_addr addr;
+
+	_enter(",{%u},%d", skb->len, last);
+
+	if (!last)
+		return 0;
+
+	/* no unmarshalling required */
+	call->state = AFS_CALL_REPLYING;
+
+	/* we'll need the file server record as that tells us which set of
+	 * vnodes to operate upon */
+	memcpy(&addr, &ip_hdr(skb)->saddr, 4);
+	server = afs_find_server(&addr);
+	if (!server)
+		return -ENOTCONN;
+	call->server = server;
+
+	INIT_WORK(&call->work, SRXAFSCB_InitCallBackState);
+	schedule_work(&call->work);
+	return 0;
+}
+
+/*
  * allow the fileserver to see if the cache manager is still alive
  */
 static void SRXAFSCB_Probe(struct work_struct *work)

