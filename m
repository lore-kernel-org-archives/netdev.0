From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] rxrpc: out of bound read in debug code
Date: Mon, 20 Jan 2014 13:28:59 +0300
Message-ID: <20140120102859.GA14233@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Smatch complains because we are using an untrusted index into the
rxrpc_acks[] array.  It's just a read and it's only in the debug code,
but it's simple enough to add a check and fix it.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index e4d9cbcff402..cd97a0ce48d8 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -21,10 +21,17 @@
 
 static unsigned int rxrpc_ack_defer = 1;
 
-static const char *const rxrpc_acks[] = {
-	"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY", "IDL",
-	"-?-"
-};
+static const char *rxrpc_acks(u8 reason)
+{
+	static const char *const str[] = {
+		"---", "REQ", "DUP", "OOS", "WIN", "MEM", "PNG", "PNR", "DLY",
+		"IDL", "-?-"
+	};
+
+	if (reason >= ARRAY_SIZE(str))
+		reason = ARRAY_SIZE(str) - 1;
+	return str[reason];
+}
 
 static const s8 rxrpc_ack_priority[] = {
 	[0]				= 0,
@@ -50,7 +57,7 @@ void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 	ASSERTCMP(prior, >, 0);
 
 	_enter("{%d},%s,%%%x,%u",
-	       call->debug_id, rxrpc_acks[ack_reason], ntohl(serial),
+	       call->debug_id, rxrpc_acks(ack_reason), ntohl(serial),
 	       immediate);
 
 	if (prior < rxrpc_ack_priority[call->ackr_reason]) {
@@ -637,7 +644,7 @@ process_further:
 		       hard,
 		       ntohl(ack.previousPacket),
 		       ntohl(ack.serial),
-		       rxrpc_acks[ack.reason],
+		       rxrpc_acks(ack.reason),
 		       ack.nAcks);
 
 		rxrpc_extract_ackinfo(call, skb, latest, ack.nAcks);
@@ -1180,7 +1187,7 @@ send_ACK:
 	       ntohl(ack.firstPacket),
 	       ntohl(ack.previousPacket),
 	       ntohl(ack.serial),
-	       rxrpc_acks[ack.reason],
+	       rxrpc_acks(ack.reason),
 	       ack.nAcks);
 
 	del_timer_sync(&call->ack_timer);
