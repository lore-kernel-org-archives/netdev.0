From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 10/14] rxrpc: Calls displayed in /proc may in
 future lack a connection [ver #2]
Date: Wed, 22 Jun 2016 17:04:03 +0100
Message-ID: <146661144374.15011.1174994794577410748.stgit@warthog.procyon.org.uk>
References: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allocated rxrpc calls displayed in /proc/net/rxrpc_calls may in future be
on the proc list before they're connected or after they've been
disconnected - in which case they may not have a pointer to a connection
struct that can be used to get data from there.

Deal with this by using stuff from the call struct in preference where
possible and printing "no_connection" rather than a peer address if no
connection is assigned.

This change also has the added bonus that the service ID is now taken from
the call rather the connection which will allow per-call service upgrades
to be shown - something required for AuriStor server compatibility.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/proc.c |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index 9863270691d7..500cdcdc843c 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -59,25 +59,28 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	}
 
 	call = list_entry(v, struct rxrpc_call, link);
-	conn = call->conn;
 
 	sprintf(lbuff, "%pI4:%u",
-		&conn->params.local->srx.transport.sin.sin_addr,
-		ntohs(conn->params.local->srx.transport.sin.sin_port));
+		&call->local->srx.transport.sin.sin_addr,
+		ntohs(call->local->srx.transport.sin.sin_port));
 
-	sprintf(rbuff, "%pI4:%u",
-		&conn->params.peer->srx.transport.sin.sin_addr,
-		ntohs(conn->params.peer->srx.transport.sin.sin_port));
+	conn = call->conn;
+	if (conn)
+		sprintf(rbuff, "%pI4:%u",
+			&conn->params.peer->srx.transport.sin.sin_addr,
+			ntohs(conn->params.peer->srx.transport.sin.sin_port));
+	else
+		strcpy(rbuff, "no_connection");
 
 	seq_printf(seq,
 		   "UDP   %-22.22s %-22.22s %4x %08x %08x %s %3u"
 		   " %-8.8s %08x %lx\n",
 		   lbuff,
 		   rbuff,
-		   call->conn->params.service_id,
+		   call->service_id,
 		   call->cid,
 		   call->call_id,
-		   rxrpc_conn_is_service(call->conn) ? "Svc" : "Clt",
+		   call->in_clientflag ? "Svc" : "Clt",
 		   atomic_read(&call->usage),
 		   rxrpc_call_states[call->state],
 		   call->remote_abort ?: call->local_abort,
