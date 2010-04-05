From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 15681] New: X25 fails to negotiate connection
 with Cisco router due to bad value for X25_DEFAULT_THROUGHPUT
Date: Mon, 5 Apr 2010 12:37:48 -0700
Message-ID: <20100405123748.2e338f69.akpm@linux-foundation.org>
References: <bug-15681-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
To: john@calva.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34051 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756104Ab0DETil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 15:38:41 -0400
In-Reply-To: <bug-15681-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 2 Apr 2010 14:48:17 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15681
> 
>            Summary: X25 fails to negotiate connection with Cisco router
>                     due to bad value for X25_DEFAULT_THROUGHPUT
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: john@calva.com
>         Regression: No
> 
> 
> X.25 connection with a Cisco router fails because Linux X.25 tries to negotiate
> an illegal value "0" for the inbound throughput.
> 
> This bug was first reported by Daniel Ferenci to the linux-x25 mailing list on
> 6/8/2004, but is still present.
> 
> X25_DEFAULT_THROUGHPUT is defined as 0x0A, i.e. when the Linux system calls it
> wants a throughput of at least 0xA (9600bps) outbound and at least 0x0
> (Reserved value) inbound.
> 
> See X.25 (1988) section 7.2.2.2

Thanks, but...  please don't send patches via bugzilla - it bypasses
all our review and merge processes and tools.

I merged your patch as below and shall send it on to Ralf and David for
review.



From: John Hughes <john@calva.com>

The current (2.6.34) x.25 code doesn't seem to know that the X.25
throughput facility includes two values, one for the required throughput
outbound, one for inbound.

This causes it to attempt to negotiate throughput 0x0A, which is
throughput 9600 inbound and the illegal value "0" for inbound throughput.

Because of this some X.25 devices (e.g.  Cisco 1600) refuse to connect to
Linux X.25.

The patch fixes this behaviour.  Unless the user specifies a required
throughput it does not attempt to negotiate.  If the user does not specify
a throughput it accepts the suggestion of the remote X.25 system.  If the
user requests a throughput then it validates both the input and output
throughputs and correctly negotiates them with the remote end.

Signed-off-by: John Hughes <john@calva.com>
Cc: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/x25/af_x25.c         |   20 ++++++++++++++++----
 net/x25/x25_facilities.c |   15 ++++++++++++---
 2 files changed, 28 insertions(+), 7 deletions(-)

diff -puN net/x25/af_x25.c~a net/x25/af_x25.c
--- a/net/x25/af_x25.c~a
+++ a/net/x25/af_x25.c
@@ -554,7 +554,8 @@ static int x25_create(struct net *net, s
 	x25->facilities.winsize_out = X25_DEFAULT_WINDOW_SIZE;
 	x25->facilities.pacsize_in  = X25_DEFAULT_PACKET_SIZE;
 	x25->facilities.pacsize_out = X25_DEFAULT_PACKET_SIZE;
-	x25->facilities.throughput  = X25_DEFAULT_THROUGHPUT;
+	x25->facilities.throughput  = 0;	/* by default don't negotiate
+						   throughput */
 	x25->facilities.reverse     = X25_DEFAULT_REVERSE;
 	x25->dte_facilities.calling_len = 0;
 	x25->dte_facilities.called_len = 0;
@@ -1415,9 +1416,20 @@ static int x25_ioctl(struct socket *sock
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
diff -puN net/x25/x25_facilities.c~a net/x25/x25_facilities.c
--- a/net/x25/x25_facilities.c~a
+++ a/net/x25/x25_facilities.c
@@ -259,9 +259,18 @@ int x25_negotiate_facilities(struct sk_b
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
 
_

