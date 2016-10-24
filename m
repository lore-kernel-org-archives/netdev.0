From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] kalmia: avoid potential uninitialized variable use
Date: Mon, 24 Oct 2016 17:54:18 +0200
Message-ID: <20161024155430.3077348-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd@arndb.de>, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kalmia_send_init_packet() returns zero or a negative return
code, but gcc has no way of knowing that there cannot be a
positive return code, so it determines that copying the ethernet
address at the end of kalmia_bind() will access uninitialized
data:

drivers/net/usb/kalmia.c: In function ‘kalmia_bind’:
arch/x86/include/asm/string_32.h:78:22: error: ‘*((void *)&ethernet_addr+4)’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
   *((short *)to + 2) = *((short *)from + 2);
                      ^
drivers/net/usb/kalmia.c:138:5: note: ‘*((void *)&ethernet_addr+4)’ was declared here

This warning is harmless, but for consistency, we should make
the check for the return code match what the driver does everywhere
else and just progate it, which then gets rid of the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/usb/kalmia.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
index 5662babf0583..3e37724d30ae 100644
--- a/drivers/net/usb/kalmia.c
+++ b/drivers/net/usb/kalmia.c
@@ -151,7 +151,7 @@ kalmia_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	status = kalmia_init_and_get_ethernet_addr(dev, ethernet_addr);
 
-	if (status < 0) {
+	if (status) {
 		usb_set_intfdata(intf, NULL);
 		usb_driver_release_interface(driver_of(intf), intf);
 		return status;
-- 
2.9.0
