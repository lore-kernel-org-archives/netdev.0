From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/9] rxrpc: fix undefined behavior in
 rxrpc_mark_call_released
Date: Sun, 04 Sep 2016 22:02:31 +0100
Message-ID: <147302295141.28597.17761498339552126149.stgit@warthog.procyon.org.uk>
References: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

gcc -Wmaybe-initialized correctly points out a newly introduced bug
through which we can end up calling rxrpc_queue_call() for a dead
connection:

net/rxrpc/call_object.c: In function 'rxrpc_mark_call_released':
net/rxrpc/call_object.c:600:5: error: 'sched' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This sets the 'sched' variable to zero to restore the previous
behavior.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: f5c17aaeb2ae ("rxrpc: Calls should only have one terminal state")
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 516d8ea82f02..57e00fc9cff2 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -586,7 +586,7 @@ static void rxrpc_dead_call_expired(unsigned long _call)
  */
 static void rxrpc_mark_call_released(struct rxrpc_call *call)
 {
-	bool sched;
+	bool sched = false;
 
 	rxrpc_see_call(call);
 	write_lock(&call->state_lock);
