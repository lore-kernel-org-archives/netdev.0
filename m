From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] cdc-phonet: Don't leak in usbpn_open
Date: Tue, 7 Aug 2012 23:56:26 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1208072354030.3227@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	=?ISO-8859-15?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>,
	Remi Denis-Courmont <courmisch@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We allocate memory for 'req' with usb_alloc_urb() and then test
'if (!req || rx_submit(pnd, req, GFP_KERNEL | __GFP_COLD))'.
If we enter that branch due to '!req' then there is no problem. But if
we enter the branch due to 'req' being != 0 and the 'rx_submit()' call
being false, then we'll leak the memory we allocated.
Deal with the leak by always calling 'usb_free_urb(req)' when entering
the branch. If 'req' happens to be 0 then the call is harmless, if it
is not 0 then we free the memory we allocated but don't need.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/usb/cdc-phonet.c | 1 +
 1 file changed, 1 insertion(+)

  Only compile tested due to lack of hardware.

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 6461004..7d78669 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -232,6 +232,7 @@ static int usbpn_open(struct net_device *dev)
 		struct urb *req = usb_alloc_urb(0, GFP_KERNEL);
 
 		if (!req || rx_submit(pnd, req, GFP_KERNEL | __GFP_COLD)) {
+			usb_free_urb(req);
 			usbpn_close(dev);
 			return -ENOMEM;
 		}
-- 
1.7.11.4


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
