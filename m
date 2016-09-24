From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/8] rxrpc: Delay the resend timer to allow for
 nsec->jiffies conv error
Date: Sun, 25 Sep 2016 00:25:31 +0100
Message-ID: <147475953101.15231.16234106806253063069.stgit@warthog.procyon.org.uk>
References: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When determining the resend timer value, we have a value in nsec but the
timer is in jiffies which may be a million or more times more coarse.
nsecs_to_jiffies() rounds down - which means that the resend timeout
expressed as jiffies is very likely earlier than the one expressed as
nanoseconds from which it was derived.

The problem is that rxrpc_resend() gets triggered by the timer, but can't
then find anything to resend yet.  It sets the timer again - but gets
kicked off immediately again and again until the nanosecond-based expiry
time is reached and we actually retransmit.

Fix this by adding 1 to the jiffies-based resend_at value to counteract the
rounding and make sure that the timer happens after the nanosecond-based
expiry is passed.

Alternatives would be to adjust the timestamp on the packets to align
with the jiffie scale or to switch back to using jiffie-timestamps.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index a78a92fe5d77..d5bf9ce7ec6f 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -200,8 +200,14 @@ static void rxrpc_resend(struct rxrpc_call *call)
 				       ktime_to_ns(ktime_sub(skb->tstamp, max_age)));
 	}
 
-	resend_at = ktime_sub(ktime_add_ms(oldest, rxrpc_resend_timeout), now);
-	call->resend_at = jiffies + nsecs_to_jiffies(ktime_to_ns(resend_at));
+	resend_at = ktime_add_ms(oldest, rxrpc_resend_timeout);
+	call->resend_at = jiffies +
+		nsecs_to_jiffies(ktime_to_ns(ktime_sub(resend_at, now))) +
+		1; /* We have to make sure that the calculated jiffies value
+		    * falls at or after the nsec value, or we shall loop
+		    * ceaselessly because the timer times out, but we haven't
+		    * reached the nsec timeout yet.
+		    */
 
 	/* Now go through the Tx window and perform the retransmissions.  We
 	 * have to drop the lock for each send.  If an ACK comes in whilst the
