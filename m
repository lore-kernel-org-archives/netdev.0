From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH v2] Documentation: improve line discipline method descriptions
Date: Wed, 30 Sep 2015 01:45:11 +0200 (CEST)
Message-ID: <1349c282fb3642264c7c8c1478ce8a0dcdd93aef.1443569708.git.tilman@imap.cc>
References: <d43bc9f8bddbd7ce07200a8a149ae15e5eac5d6d.1436827841.git.tilman@imap.cc> <1436901132.2679.54.camel@tiscali.nl>
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Paul Bolle <pebolle@tiscali.nl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436901132.2679.54.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mention that the ldisc open method must set tty->receive_room, and
that many methods are optional. Add description of receive_buf2 method.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/serial/tty.txt | 60 ++++++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 21 deletions(-)

diff --git a/Documentation/serial/tty.txt b/Documentation/serial/tty.txt
index 973c8ad..bc3842d 100644
--- a/Documentation/serial/tty.txt
+++ b/Documentation/serial/tty.txt
@@ -39,8 +39,13 @@ TTY side interfaces:
 open()		-	Called when the line discipline is attached to
 			the terminal. No other call into the line
 			discipline for this tty will occur until it
-			completes successfully. Returning an error will
-			prevent the ldisc from being attached. Can sleep.
+			completes successfully. Should initialize any
+			state needed by the ldisc, and set receive_room
+			in the tty_struct to the maximum amount of data
+			the line discipline is willing to accept from the
+			driver with a single call to receive_buf().
+			Returning an error will prevent the ldisc from
+			being attached. Can sleep.
 
 close()		-	This is called on a terminal when the line
 			discipline is being unplugged. At the point of
@@ -52,9 +57,16 @@ hangup()	-	Called when the tty line is hung up.
 			No further calls into the ldisc code will occur.
 			The return value is ignored. Can sleep.
 
-write()		-	A process is writing data through the line
-			discipline.  Multiple write calls are serialized
-			by the tty layer for the ldisc.  May sleep. 
+read()		-	(optional) A process requests reading data from
+			the line. Multiple read calls may occur in parallel
+			and the ldisc must deal with serialization issues.
+			If not defined, the process will receive an EIO
+			error. May sleep.
+
+write()		-	(optional) A process requests writing data to the
+			line. Multiple write calls are serialized by the
+			tty layer for the ldisc. If not defined, the
+			process will receive an EIO error. May sleep.
 
 flush_buffer()	-	(optional) May be called at any point between
 			open and close, and instructs the line discipline
@@ -69,27 +81,33 @@ set_termios()	-	(optional) Called on termios structure changes.
 			termios semaphore so allowed to sleep. Serialized
 			against itself only.
 
-read()		-	Move data from the line discipline to the user.
-			Multiple read calls may occur in parallel and the
-			ldisc must deal with serialization issues. May 
-			sleep.
-
-poll()		-	Check the status for the poll/select calls. Multiple
-			poll calls may occur in parallel. May sleep.
+poll()		-	(optional) Check the status for the poll/select
+			calls. Multiple poll calls may occur in parallel.
+			May sleep.
 
-ioctl()		-	Called when an ioctl is handed to the tty layer
-			that might be for the ldisc. Multiple ioctl calls
-			may occur in parallel. May sleep. 
+ioctl()		-	(optional) Called when an ioctl is handed to the
+			tty layer that might be for the ldisc. Multiple
+			ioctl calls may occur in parallel. May sleep.
 
-compat_ioctl()	-	Called when a 32 bit ioctl is handed to the tty layer
-			that might be for the ldisc. Multiple ioctl calls
-			may occur in parallel. May sleep.
+compat_ioctl()	-	(optional) Called when a 32 bit ioctl is handed
+			to the tty layer that might be for the ldisc.
+			Multiple ioctl calls may occur in parallel.
+			May sleep.
 
 Driver Side Interfaces:
 
-receive_buf()	-	Hand buffers of bytes from the driver to the ldisc
-			for processing. Semantics currently rather
-			mysterious 8(
+receive_buf()	-	(optional) Called by the low-level driver to hand
+			a buffer of received bytes to the ldisc for
+			processing. The number of bytes is guaranteed not
+			to exceed the current value of tty->receive_room.
+			All bytes must be processed.
+
+receive_buf2()	-	(optional) Called by the low-level driver to hand
+			a buffer of received bytes to the ldisc for
+			processing. Returns the number of bytes processed.
+
+			If both receive_buf() and receive_buf2() are
+			defined, receive_buf2() should be preferred.
 
 write_wakeup()	-	May be called at any point between open and close.
 			The TTY_DO_WRITE_WAKEUP flag indicates if a call
-- 
1.9.2.459.g68773ac
