From: David Howells <dhowells@redhat.com>
Subject: [PATCH 15/16] AFS: Implement the CB.InitCallBackState3 operation [try
	#3]
Date: Wed, 25 Apr 2007 11:51:55 +0100
Message-ID: <20070425105154.10872.25892.stgit@warthog.cambridge.redhat.com>
References: <20070425105036.10872.48596.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161859AbXDYKy5@vger.kernel.org>
In-Reply-To: <20070425105036.10872.48596.stgit@warthog.cambridge.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the CB.InitCallBackState3 operation for the fileserver to call.
This reduces the amount of network traffic because if this op is aborted, the
fileserver will then attempt an CB.InitCallBackState operation.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/afs/AFS_CM.h    |    1 +
 fs/afs/cmservice.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/fs/afs/AFS_CM.h b/fs/afs/AFS_CM.h
index d4bd201..7b4d4fa 100644
--- a/fs/afs/AFS_CM.h
+++ b/fs/afs/AFS_CM.h
@@ -23,6 +23,7 @@ enum AFS_CM_Operations {
 	CBGetCE			= 208,	/* get cache file description */
 	CBGetXStatsVersion	= 209,	/* get version of extended statistics */
 	CBGetXStats		= 210,	/* get contents of extended statistics data */
+	CBInitCallBackState3	= 213,	/* initialise callback state, version 3 */
 	CBGetCapabilities	= 65538, /* get client capabilities */
 };
 
diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 5139723..3d58861 100644
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
+	memcpy(&addr, &skb->nh.iph->saddr, 4);
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
