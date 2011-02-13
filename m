From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Net, USB, Option, hso: Do not dereference NULL pointer
Date: Sun, 13 Feb 2011 22:15:35 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1102132206390.18930@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Jan Dumon <j.dumon@option.com>, Filip Aben <f.aben@option.com>,
	Denis Joseph Barrow <d.barow@option.com>,
	Andrew Bird <ajb@spheresystems.co.uk>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:10884 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922Ab1BMVQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 16:16:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In drivers/net/usb/hso.c::hso_create_bulk_serial_device() we have this 
code:
...
	serial = kzalloc(sizeof(*serial), GFP_KERNEL);
	if (!serial)
		goto exit;
...
exit:
	hso_free_tiomget(serial);
...
hso_free_tiomget() directly dereferences its argument, which in the 
example above is a NULL pointer, ouch.
I could just add a 'if (serial)' test at the 'exit' label, but since most 
freeing functions in the kernel accept NULL pointers (and it seems like 
this was also assumed here) I opted to instead change 'hso_free_tiomget()' 
so that it is safe to call it with a NULL argument. I also modified the 
function to get rid of a pointles conditional before the call to 
'usb_free_urb()' since that function already tests for NULL itself - 
besides fixing the NULL deref this change also buys us a few bytes in 
size.
Before:
$ size drivers/net/usb/hso.o
   text    data     bss     dec     hex filename
  32200     592    9960   42752    a700 drivers/net/usb/hso.o
After:
$ size drivers/net/usb/hso.o
   text    data     bss     dec     hex filename
  32196     592    9960   42748    a6fc drivers/net/usb/hso.o

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 hso.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index bed8fce..6d83812 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2628,15 +2628,15 @@ exit:
 
 static void hso_free_tiomget(struct hso_serial *serial)
 {
-	struct hso_tiocmget *tiocmget = serial->tiocmget;
+	struct hso_tiocmget *tiocmget;
+	if (!serial)
+		return;
+	tiocmget = serial->tiocmget;
 	if (tiocmget) {
-		if (tiocmget->urb) {
-			usb_free_urb(tiocmget->urb);
-			tiocmget->urb = NULL;
-		}
+		usb_free_urb(tiocmget->urb);
+		tiocmget->urb = NULL;
 		serial->tiocmget = NULL;
 		kfree(tiocmget);
-
 	}
 }
 


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html

