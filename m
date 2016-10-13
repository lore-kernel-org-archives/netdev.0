From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 4/4] afs: call->operation_ID sometimes used as __be32
 sometimes as u32
Date: Thu, 13 Oct 2016 17:12:37 +0100
Message-ID: <147637515792.17348.9242833749328649855.stgit@warthog.procyon.org.uk>
References: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        dan.carpenter@oracle.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

call->operation_ID is sometimes being used as __be32 sometimes is being
used as u32.  Be consistent and settle on using as u32.

Signed-off-by: David Howells <dhowells@redhat.com.
---

 fs/afs/cmservice.c |    6 ++----
 fs/afs/internal.h  |    2 +-
 fs/afs/rxrpc.c     |    3 ++-
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 2037e7a77a37..d764236072b1 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -91,11 +91,9 @@ static const struct afs_call_type afs_SRXCBTellMeAboutYourself = {
  */
 bool afs_cm_incoming_call(struct afs_call *call)
 {
-	u32 operation_id = ntohl(call->operation_ID);
+	_enter("{CB.OP %u}", call->operation_ID);
 
-	_enter("{CB.OP %u}", operation_id);
-
-	switch (operation_id) {
+	switch (call->operation_ID) {
 	case CBCallBack:
 		call->type = &afs_SRXCBCallBack;
 		return true;
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 5497c8496055..535a38d2c1d0 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -112,7 +112,7 @@ struct afs_call {
 	bool			need_attention;	/* T if RxRPC poked us */
 	u16			service_id;	/* RxRPC service ID to call */
 	__be16			port;		/* target UDP port */
-	__be32			operation_ID;	/* operation ID for an incoming call */
+	u32			operation_ID;	/* operation ID for an incoming call */
 	u32			count;		/* count for use in unmarshalling */
 	__be32			tmp;		/* place to extract temporary data */
 	afs_dataversion_t	store_version;	/* updated version expected from store */
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 477928b25940..25f05a8d21b1 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -676,10 +676,11 @@ static int afs_deliver_cm_op_id(struct afs_call *call)
 	ASSERTCMP(call->offset, <, 4);
 
 	/* the operation ID forms the first four bytes of the request data */
-	ret = afs_extract_data(call, &call->operation_ID, 4, true);
+	ret = afs_extract_data(call, &call->tmp, 4, true);
 	if (ret < 0)
 		return ret;
 
+	call->operation_ID = ntohl(call->tmp);
 	call->state = AFS_CALL_AWAIT_REQUEST;
 	call->offset = 0;
 
