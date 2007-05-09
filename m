From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AFS: Further write support fixes
Date: Wed, 09 May 2007 14:43:41 +0100
Message-ID: <20070509134341.18106.44110.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dhowells@redhat.com
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Further fixes for AFS write support:

 (1) The afs_send_pages() outer loop must do an extra iteration if it ends
     with 'first == last' because 'last' is inclusive in the page set
     otherwise it fails to send the last page and complete the RxRPC op under
     some circumstances.

 (2) Similarly, the outer loop in afs_pages_written_back() must also do an
     extra iteration if it ends with 'first == last', otherwise it fails to
     clear PG_writeback on the last page under some circumstances.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/rxrpc.c |    2 +-
 fs/afs/write.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 04189c4..1b36f45 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -294,7 +294,7 @@ int afs_send_pages(struct afs_call *call, struct msghdr *msg, struct kvec *iov)
 			put_page(pages[loop]);
 		if (ret < 0)
 			break;
-	} while (first < last);
+	} while (first <= last);
 
 	_leave(" = %d", ret);
 	return ret;
diff --git a/fs/afs/write.c b/fs/afs/write.c
index aa03d43..67ae4db 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -669,7 +669,7 @@ void afs_pages_written_back(struct afs_vnode *vnode, struct afs_call *call)
 	pagevec_init(&pv, 0);
 
 	do {
-		_debug("attach %lx-%lx", first, last);
+		_debug("done %lx-%lx", first, last);
 
 		count = last - first + 1;
 		if (count > PAGEVEC_SIZE)
@@ -701,7 +701,7 @@ void afs_pages_written_back(struct afs_vnode *vnode, struct afs_call *call)
 		}
 
 		__pagevec_release(&pv);
-	} while (first < last);
+	} while (first <= last);
 
 	_leave("");
 }

