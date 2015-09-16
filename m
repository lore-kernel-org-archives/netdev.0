From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the tip tree
Date: Wed, 16 Sep 2015 11:30:53 +1000
Message-ID: <20150916113053.21c217ce@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Neukum <oneukum@suse.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the next-20150915 version of the tip tree, today's
linux-next build (x86_64 allmodconfig) failed like this:

In file included from drivers/usb/gadget/function/u_ether.h:20:0,
                 from drivers/usb/gadget/function/f_ncm.c:26:
include/linux/usb/cdc.h:23:8: error: redefinition of 'struct usb_cdc_parsed_header'
 struct usb_cdc_parsed_header {
        ^
In file included from drivers/usb/gadget/function/f_ncm.c:24:0:
include/linux/usb/cdc.h:23:8: note: originally defined here
 struct usb_cdc_parsed_header {
        ^
In file included from drivers/usb/gadget/function/u_ether.h:20:0,
                 from drivers/usb/gadget/function/f_ncm.c:26:
include/linux/usb/cdc.h:44:5: error: conflicting types for 'cdc_parse_cdc_header'
 int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
     ^
In file included from drivers/usb/gadget/function/f_ncm.c:24:0:
include/linux/usb/cdc.h:44:5: note: previous declaration of 'cdc_parse_cdc_header' was here
 int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
     ^
In file included from drivers/usb/gadget/function/u_serial.h:16:0,
                 from drivers/usb/gadget/legacy/cdc2.c:17:
include/linux/usb/cdc.h:23:8: error: redefinition of 'struct usb_cdc_parsed_header'
 struct usb_cdc_parsed_header {
        ^
In file included from drivers/usb/gadget/function/u_ether.h:20:0,
                 from drivers/usb/gadget/legacy/cdc2.c:16:
include/linux/usb/cdc.h:23:8: note: originally defined here
 struct usb_cdc_parsed_header {
        ^
In file included from drivers/usb/gadget/function/u_serial.h:16:0,
                 from drivers/usb/gadget/legacy/cdc2.c:17:
include/linux/usb/cdc.h:44:5: error: conflicting types for 'cdc_parse_cdc_header'
 int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
     ^
In file included from drivers/usb/gadget/function/u_ether.h:20:0,
                 from drivers/usb/gadget/legacy/cdc2.c:16:
include/linux/usb/cdc.h:44:5: note: previous declaration of 'cdc_parse_cdc_header' was here
 int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
     ^

Caused by commit

  c40a2c8817e4 ("CDC: common parser for extra headers")

from the net-next tree that added include/linux/usb/cdc.h with no
reinclusion guards.

I am not sure why I did not see this failure when building after
merging the net-next tree.  Maybe it is exposed by some config change
in the tip tree?

I have added the following fix patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 16 Sep 2015 11:10:16 +1000
Subject: [PATCH] cdc: add header guards

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/usb/cdc.h      | 4 ++++
 include/uapi/linux/usb/cdc.h | 6 +++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/usb/cdc.h b/include/linux/usb/cdc.h
index 959d0c838113..b5706f94ee9e 100644
--- a/include/linux/usb/cdc.h
+++ b/include/linux/usb/cdc.h
@@ -7,6 +7,8 @@
  * modify it under the terms of the GNU General Public License
  * version 2 as published by the Free Software Foundation.
  */
+#ifndef __LINUX_USB_CDC_H
+#define __LINUX_USB_CDC_H
 
 #include <uapi/linux/usb/cdc.h>
 
@@ -45,3 +47,5 @@ int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
 				struct usb_interface *intf,
 				u8 *buffer,
 				int buflen);
+
+#endif /* __LINUX_USB_CDC_H */
diff --git a/include/uapi/linux/usb/cdc.h b/include/uapi/linux/usb/cdc.h
index b6a9cdd6e096..e2bc417b243b 100644
--- a/include/uapi/linux/usb/cdc.h
+++ b/include/uapi/linux/usb/cdc.h
@@ -6,8 +6,8 @@
  * firmware based USB peripherals.
  */
 
-#ifndef __LINUX_USB_CDC_H
-#define __LINUX_USB_CDC_H
+#ifndef __UAPI_LINUX_USB_CDC_H
+#define __UAPI_LINUX_USB_CDC_H
 
 #include <linux/types.h>
 
@@ -444,4 +444,4 @@ struct usb_cdc_ncm_ndp_input_size {
 #define USB_CDC_NCM_CRC_NOT_APPENDED			0x00
 #define USB_CDC_NCM_CRC_APPENDED			0x01
 
-#endif /* __LINUX_USB_CDC_H */
+#endif /* __UAPI_LINUX_USB_CDC_H */
-- 
2.5.1

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
