From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 16/22] x86: intel-mid: fix a format string overflow warning
Date: Fri, 14 Jul 2017 14:07:08 +0200
Message-ID: <20170714120720.906842-17-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have space for exactly one character for the index in "max7315_%d_base",
but as gcc points out having more would cause an string overflow:

arch/x86/platform/intel-mid/device_libs/platform_max7315.c: In function 'max7315_platform_data':
arch/x86/platform/intel-mid/device_libs/platform_max7315.c:41:26: error: '%d' directive writing between 1 and 11 bytes into a region of size 9 [-Werror=format-overflow=]
   sprintf(base_pin_name, "max7315_%d_base", nr);
                          ^~~~~~~~~~~~~~~~~
arch/x86/platform/intel-mid/device_libs/platform_max7315.c:41:26: note: directive argument in the range [-2147483647, 2147483647]
arm-soc/arch/x86/platform/intel-mid/device_libs/platform_max7315.c:41:3: note: 'sprintf' output between 15 and 25 bytes into a destination of size 17
   sprintf(base_pin_name, "max7315_%d_base", nr);

This makes it use an snprintf() to truncate the string if that happened
rather than overflowing the stack.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/x86/platform/intel-mid/device_libs/platform_max7315.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/platform/intel-mid/device_libs/platform_max7315.c b/arch/x86/platform/intel-mid/device_libs/platform_max7315.c
index 6e075afa7877..58337b2bc682 100644
--- a/arch/x86/platform/intel-mid/device_libs/platform_max7315.c
+++ b/arch/x86/platform/intel-mid/device_libs/platform_max7315.c
@@ -38,8 +38,10 @@ static void __init *max7315_platform_data(void *info)
 	 */
 	strcpy(i2c_info->type, "max7315");
 	if (nr++) {
-		sprintf(base_pin_name, "max7315_%d_base", nr);
-		sprintf(intr_pin_name, "max7315_%d_int", nr);
+		snprintf(base_pin_name, sizeof(base_pin_name),
+			 "max7315_%d_base", nr);
+		snprintf(intr_pin_name, sizeof(intr_pin_name),
+			 "max7315_%d_int", nr);
 	} else {
 		strcpy(base_pin_name, "max7315_base");
 		strcpy(intr_pin_name, "max7315_int");
-- 
2.9.0
