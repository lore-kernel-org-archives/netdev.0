From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/9] afs: Wait for outstanding async calls before closing
 rxrpc socket
Date: Thu, 07 Apr 2016 17:23:03 +0100
Message-ID: <20160407162303.21283.63145.stgit@warthog.procyon.org.uk>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The afs filesystem needs to wait for any outstanding asynchronous calls
(such as FS.GiveUpCallBacks cleaning up the callbacks lodged with a server)
to complete before closing the AF_RXRPC socket when unloading the module.

This may occur if the module is removed too quickly after unmounting all
filesystems.  This will produce an error report that looks like:

	AFS: Assertion failed
	1 == 0 is false
	0x1 == 0x0 is false
	------------[ cut here ]------------
	kernel BUG at ../fs/afs/rxrpc.c:135!
	...
	RIP: 0010:[<ffffffffa004111c>] afs_close_socket+0xec/0x107 [kafs]
	...
	Call Trace:
	 [<ffffffffa004a160>] afs_exit+0x1f/0x57 [kafs]
	 [<ffffffff810c30a0>] SyS_delete_module+0xec/0x17d
	 [<ffffffff81610417>] entry_SYSCALL_64_fastpath+0x12/0x6b

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index b50642870a43..7c2567a711ea 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -65,6 +65,12 @@ static void afs_async_workfn(struct work_struct *work)
 	call->async_workfn(call);
 }
 
+static int afs_wait_atomic_t(atomic_t *p)
+{
+	schedule();
+	return 0;
+}
+
 /*
  * open an RxRPC socket and bind it to be a server for callback notifications
  * - the socket is left in blocking mode and non-blocking ops use MSG_DONTWAIT
@@ -126,13 +132,16 @@ void afs_close_socket(void)
 {
 	_enter("");
 
+	wait_on_atomic_t(&afs_outstanding_calls, afs_wait_atomic_t,
+			 TASK_UNINTERRUPTIBLE);
+	_debug("no outstanding calls");
+	
 	sock_release(afs_socket);
 
 	_debug("dework");
 	destroy_workqueue(afs_async_calls);
 
 	ASSERTCMP(atomic_read(&afs_outstanding_skbs), ==, 0);
-	ASSERTCMP(atomic_read(&afs_outstanding_calls), ==, 0);
 	_leave("");
 }
 
@@ -178,8 +187,6 @@ static void afs_free_call(struct afs_call *call)
 {
 	_debug("DONE %p{%s} [%d]",
 	       call, call->type->name, atomic_read(&afs_outstanding_calls));
-	if (atomic_dec_return(&afs_outstanding_calls) == -1)
-		BUG();
 
 	ASSERTCMP(call->rxcall, ==, NULL);
 	ASSERT(!work_pending(&call->async_work));
@@ -188,6 +195,9 @@ static void afs_free_call(struct afs_call *call)
 
 	kfree(call->request);
 	kfree(call);
+
+	if (atomic_dec_and_test(&afs_outstanding_calls))
+		wake_up_atomic_t(&afs_outstanding_calls);
 }
 
 /*
