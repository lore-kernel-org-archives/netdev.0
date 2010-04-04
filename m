From: John Hughes <john@Calva.COM>
Subject: patch to improve x.25 throughput negotiation
Date: Sun, 04 Apr 2010 18:48:10 +0200
Message-ID: <4BB8C2CA.6040102@Calva.COM>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020500020107000904040300"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:44771 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793Ab0DDQsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 12:48:13 -0400
Received: from [192.168.14.6] (colmar.atlantech.com [82.224.234.55])
	(authenticated (0 bits))
	by oceanic.CalvaEDI.COM (8.11.1-20030923/8.11.1/6.32) with ESMTP id o34GmAg05061
	(using TLSv1/SSLv3 with cipher RC4-MD5 (128 bits) verified NO)
	for <netdev@vger.kernel.org>; Sun, 4 Apr 2010 18:48:11 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020500020107000904040300
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The current X.25 code has some bugs in throughput negotiation:

   1. It does negotiation in all cases, usually there is no need
   2. It incorrectly attempts to negotiate the throughput class in one
      direction only.  There are separate throughput classes for input
      and output and if either is negotiated both mist be negotiates.

This is bug https://bugzilla.kernel.org/show_bug.cgi?id=15681

This bug was first reported by Daniel Ferenci to the linux-x25 mailing 
list on 6/8/2004, but is still present.


--------------020500020107000904040300
Content-Type: text/x-patch;
 name="throughput.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="throughput.patch"

From: John Hughes <john@calva.com>
Subject: x.25 attempts to negotiate invalid throughput

The current (2.6.34) x.25 code doesn't seem to know that the X.25 throughput
facility includes two values, one for the required throughput outbound, one
for inbound.

This causes it to attempt to negotiate throughput 0x0A, which is throughput
9600 inbound and the illegal value "0" for inbound throughput.

Because of this some X.25 devices (e.g. Cisco 1600) refuse to connect to Linux
X.25.

The following patch fixes this behaviour.  Unless the user specifies a required
throughput it does not attempt to negotiate.  If the user does not specify
a throughput it accepts the suggestion of the remote X.25 system.  If the
user requests a throughput then it validates both the input and output
throughputs and correctly negotiates them with the remote end.

Signed-off-by: John Hughes <john@calva.com>

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 9796f3e..f391f61 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -553,7 +553,8 @@ static int x25_create(struct net *net, struct socket *sock, int protocol,
 	x25->facilities.winsize_out = X25_DEFAULT_WINDOW_SIZE;
 	x25->facilities.pacsize_in  = X25_DEFAULT_PACKET_SIZE;
 	x25->facilities.pacsize_out = X25_DEFAULT_PACKET_SIZE;
-	x25->facilities.throughput  = X25_DEFAULT_THROUGHPUT;
+	x25->facilities.throughput  = 0;	/* by default don't negotiate
+						   throughput */
 	x25->facilities.reverse     = X25_DEFAULT_REVERSE;
 	x25->dte_facilities.calling_len = 0;
 	x25->dte_facilities.called_len = 0;
@@ -1414,9 +1415,20 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			if (facilities.winsize_in < 1 ||
 			    facilities.winsize_in > 127)
 				break;
-			if (facilities.throughput < 0x03 ||
-			    facilities.throughput > 0xDD)
-				break;
+			if (facilities.throughput) {
+				int out = facilities.throughput & 0xf0;
+				int in  = facilities.throughput & 0x0f;
+				if (!out)
+					facilities.throughput |=
+						X25_DEFAULT_THROUGHPUT << 4;
+				else if (out < 0x30 || out > 0xD0)
+					break;
+				if (!in)
+					facilities.throughput |=
+						X25_DEFAULT_THROUGHPUT;
+				else if (in < 0x03 || in > 0x0D)
+					break;
+			}
 			if (facilities.reverse &&
 				(facilities.reverse & 0x81) != 0x81)
 				break;
diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index a21f664..b447a66 100644
--- a/net/x25/x25_facilities.c
+++ b/net/x25/x25_facilities.c
@@ -259,9 +259,18 @@ int x25_negotiate_facilities(struct sk_buff *skb, struct sock *sk,
 	new->reverse = theirs.reverse;
 
 	if (theirs.throughput) {
-		if (theirs.throughput < ours->throughput) {
-			SOCK_DEBUG(sk, "X.25: throughput negotiated down\n");
-			new->throughput = theirs.throughput;
+		int theirs_in =  theirs.throughput & 0x0f;
+		int theirs_out = theirs.throughput & 0xf0;
+		int ours_in  = ours->throughput & 0x0f;
+		int ours_out = ours->throughput & 0xf0;
+		if (!ours_in || theirs_in < ours_in) {
+			SOCK_DEBUG(sk, "X.25: inbound throughput negotiated\n");
+			new->throughput = (new->throughput & 0xf0) | theirs_in;
+		}
+		if (!ours_out || theirs_out < ours_out) {
+			SOCK_DEBUG(sk,
+				"X.25: outbound throughput negotiated\n");
+			new->throughput = (new->throughput & 0x0f) | theirs_out;
 		}
 	}
 

--------------020500020107000904040300--
