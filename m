From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [janitor] strip: use kernel min/max
Date: Mon, 23 Feb 2004 13:44:45 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223134445.32c3c367.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.3-current.

--
~Randy


From: Michael Veeck <michael.veeck@gmx.net>


Domen Puncer schrieb:
> 
> Just some suggestions...
> 
>> #define ELEMENTS_OF(X) (sizeof(X) / sizeof((X)[0]))
> 
> Remove this define and s/ELEMENTS_OF/ARRAY_SIZE/g
> 

There are more occurances of redundant ARRAY_SIZEs in the kernel. I will
keep that in mind!

> 
> 
>>@@ -847,7 +845,7 @@
>> static int allocate_buffers(struct strip *strip_info, int mtu)
>> {
>>        struct net_device *dev = strip_info->dev;
>>-       int sx_size = MAX(STRIP_ENCAP_SIZE(MAX_RECV_MTU), 4096);
>>+       int sx_size = max((int)STRIP_ENCAP_SIZE(MAX_RECV_MTU), 4096);
> 
> 
> max_t?

Changed that to max_t and min_t. A newbie queston: What should when be
preferred and why?

Attached is the new patch.

	Veeck



 linux-263-kj1-rddunlap/drivers/net/wireless/strip.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff -puN drivers/net/wireless/strip.c~net_strip_minmax drivers/net/wireless/strip.c
--- linux-263-kj1/drivers/net/wireless/strip.c~net_strip_minmax	2004-02-18 14:46:24.000000000 -0800
+++ linux-263-kj1-rddunlap/drivers/net/wireless/strip.c	2004-02-18 14:46:24.000000000 -0800
@@ -82,6 +82,7 @@ static const char StripVersion[] = "1.3A
 /* Header files								*/
 
 #include <linux/config.h>
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <asm/system.h>
@@ -454,10 +455,7 @@ static spinlock_t strip_lock = SPIN_LOCK
 
 #define READDEC(X) ((X)>='0' && (X)<='9' ? (X)-'0' : 0)
 
-#define MIN(X, Y) ((X) < (Y) ? (X) : (Y))
-#define MAX(X, Y) ((X) > (Y) ? (X) : (Y))
-#define ELEMENTS_OF(X) (sizeof(X) / sizeof((X)[0]))
-#define ARRAY_END(X) (&((X)[ELEMENTS_OF(X)]))
+#define ARRAY_END(X) (&((X)[ARRAY_SIZE(X)]))
 
 #define JIFFIE_TO_SEC(X) ((X) / HZ)
 
@@ -847,7 +845,7 @@ static __u8 *radio_address_to_string(con
 static int allocate_buffers(struct strip *strip_info, int mtu)
 {
 	struct net_device *dev = strip_info->dev;
-	int sx_size = MAX(STRIP_ENCAP_SIZE(MAX_RECV_MTU), 4096);
+	int sx_size = max_t(int, STRIP_ENCAP_SIZE(MAX_RECV_MTU), 4096);
 	int tx_size = STRIP_ENCAP_SIZE(mtu) + MaxCommandStringLength;
 	__u8 *r = kmalloc(MAX_RECV_MTU, GFP_ATOMIC);
 	__u8 *s = kmalloc(sx_size, GFP_ATOMIC);
@@ -1465,7 +1463,7 @@ static void strip_send(struct strip *str
 		/* Cycle to next periodic command? */
 		if (strip_info->firmware_level >= StructuredMessages)
 			if (++strip_info->next_command >=
-			    ELEMENTS_OF(CommandString))
+			    ARRAY_SIZE(CommandString))
 				strip_info->next_command = 0;
 #ifdef EXT_COUNTERS
 		strip_info->tx_ebytes += ts.length;
@@ -1709,7 +1707,7 @@ static void get_radio_version(struct str
 	p++;
 
 	len = value_end - value_begin;
-	len = MIN(len, sizeof(FirmwareVersion) - 1);
+	len = min_t(int, len, sizeof(FirmwareVersion) - 1);
 	if (strip_info->firmware_version.c[0] == 0)
 		printk(KERN_INFO "%s: Radio Firmware: %.*s\n",
 		       strip_info->dev->name, len, value_begin);

_
