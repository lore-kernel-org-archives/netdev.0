From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.4 SCTP]: Fix inetaddr notifier chain corruption
Date: Mon, 15 Nov 2004 11:28:30 +0100
Message-ID: <419884CE.2080406@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090602060505050700000305"
Cc: netdev@oss.sgi.com, sri@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090602060505050700000305
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Backport of 2.6 patch: SCTP corrupts the inetaddr notifier chain
by registering the same notifier block twice.



--------------090602060505050700000305
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/15 11:25:40+01:00 kaber@coreworks.de 
#   [SCTP]: Fix inetaddr notifier chain corruption
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sctp/protocol.c
#   2004/11/15 11:25:38+01:00 kaber@coreworks.de +3 -3
#   [SCTP]: Fix inetaddr notifier chain corruption
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sctp/ipv6.c
#   2004/11/15 11:25:38+01:00 kaber@coreworks.de +6 -3
#   [SCTP]: Fix inetaddr notifier chain corruption
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c	2004-11-15 11:25:51 +01:00
+++ b/net/sctp/ipv6.c	2004-11-15 11:25:51 +01:00
@@ -78,7 +78,10 @@
 
 #include <asm/uaccess.h>
 
-extern struct notifier_block sctp_inetaddr_notifier;
+extern int sctp_inetaddr_event(struct notifier_block *, unsigned long, void *);
+static struct notifier_block sctp_inet6addr_notifier = {
+	.notifier_call = sctp_inetaddr_event,
+};
 
 /* FIXME: This macro needs to be moved to a common header file. */
 #define NIP6(addr) \
@@ -980,7 +983,7 @@
 	sctp_register_af(&sctp_ipv6_specific);
 
 	/* Register notifier for inet6 address additions/deletions. */
-	register_inet6addr_notifier(&sctp_inetaddr_notifier);
+	register_inet6addr_notifier(&sctp_inet6addr_notifier);
 
 	return 0;
 }
@@ -992,5 +995,5 @@
 	inet6_del_protocol(&sctpv6_protocol);
 	inet6_unregister_protosw(&sctpv6_seqpacket_protosw);
 	inet6_unregister_protosw(&sctpv6_stream_protosw);
-	unregister_inet6addr_notifier(&sctp_inetaddr_notifier);
+	unregister_inet6addr_notifier(&sctp_inet6addr_notifier);
 }
diff -Nru a/net/sctp/protocol.c b/net/sctp/protocol.c
--- a/net/sctp/protocol.c	2004-11-15 11:25:51 +01:00
+++ b/net/sctp/protocol.c	2004-11-15 11:25:51 +01:00
@@ -621,8 +621,8 @@
 /* Event handler for inet address addition/deletion events.
  * Basically, whenever there is an event, we re-build our local address list.
  */
-static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
-			       void *ptr)
+int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
+                        void *ptr)
 {
 	unsigned long flags;
 
@@ -823,7 +823,7 @@
 };
 
 /* Notifier for inetaddr addition/deletion events.  */
-struct notifier_block sctp_inetaddr_notifier = {
+static struct notifier_block sctp_inetaddr_notifier = {
 	.notifier_call = sctp_inetaddr_event,
 };
 

--------------090602060505050700000305--
