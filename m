From: "Gary N Spiess" <Gary.Spiess@Intermec.com>
Subject: Re: [PATCH] natsemi update 1/4 Use assigned MAC address
Date: Mon, 07 Jun 2004 12:58:55 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406071258550931.1ACDCC8B@136.179.85.112>
References: <200406041451590078.0BC23855@136.179.85.112>
 <40C31C71.6000101@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <40C31C71.6000101@colorfullife.com>
To: manfred@colorfullife.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

I agree with all comments.  Regarding the total elimination of this patch ...

Only our bootrom knows the MAC address that should be used, and it appends it to the bootargs.  If there is a way for the userspace to take a peek at the bootargs (or a similar mechanism), we can use the ifconfig method to assign the MAC address instead of changing the driver.  I'd prefer it.

Gary



*********** REPLY SEPARATOR  ***********

On 6/6/2004 at 3:30 PM Manfred Spraul wrote:

>Gary N Spiess wrote:
>
>>Jeff,
>>This is the first of a series of patches needed to support our product
>using the DP83815.
>>This patch accepts the MAC address as a parameter because our
>implementation does not have an EEPROM.  I tried to upgrade to the new
>module_param_array() macro, but couldn't find a tutorial on the new param
>scheme.
>>
>Ok. Appending "natsemi.ethaddr=00:01:02:04:05:06" works.
>
>>  To get things working for our development, I use a __setup() wrapper to
>get "ethaddr=" from the linux command line.
>>  
>>
>That's not a reason to merge a hack
>
>>+       if (find_cnt < ethaddr_num)
>>  
>>
>I think we should add a special case: if strlen(ethaddr[find_cnt]) is 0, 
>then the address from the eeprom is used - this allows to replace one 
>mac address if multiple nics are installed.
>
>>+       {
>>  
>>
>Coding style: the { should be in the same line as the if
>
>>+               int i, a[6];
>>  
>>
>i already exists, no need to define another instance.
>
>I've appended an updated patch - could you test it?
>
>But: I'm not sure that the change is required. What about just setting 
>the mac to 0, and the actual mac address is set from user space? It's 
>possible to set the mac address with
>
># ifconfig eth2 ether 80:01:02:03:04:05
>
>Is there a reason why you cannot set the mac address from user space?
>
>--
>    Manfred
>
>
>--- 2.6/drivers/net/natsemi.c	2004-05-10 04:31:59.000000000 +0200
>+++ build-2.6/drivers/net/natsemi.c	2004-06-06 15:27:12.124436291 +0200
>@@ -147,6 +147,7 @@
> 
> #include <linux/config.h>
> #include <linux/module.h>
>+#include <linux/moduleparam.h>
> #include <linux/kernel.h>
> #include <linux/string.h>
> #include <linux/timer.h>
>@@ -209,6 +210,8 @@
> #define MAX_UNITS 8		/* More are supported, limit only on options */
> static int options[MAX_UNITS];
> static int full_duplex[MAX_UNITS];
>+static char *ethaddr[MAX_UNITS] = {NULL, };
>+static int ethaddr_num = 0;
> 
> /* Operational parameters that are set at compile time. */
> 
>@@ -256,6 +259,7 @@
> MODULE_PARM(rx_copybreak, "i");
> MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
> MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
>+module_param_array(ethaddr, charp, ethaddr_num, S_IRUGO);
> MODULE_PARM_DESC(max_interrupt_work, 
> 	"DP8381x maximum events handled per interrupt");
> MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");
>@@ -265,6 +269,7 @@
> MODULE_PARM_DESC(options, 
> 	"DP8381x: Bits 0-3: media type, bit 17: full duplex");
> MODULE_PARM_DESC(full_duplex, "DP8381x full duplex setting(s) (1)");
>+MODULE_PARM_DESC(ethaddr, "DP8381x MAC addr(s) xx:xx:xx:xx:xx:xx");
> 
> /*
> 				Theory of Operation
>@@ -776,13 +781,21 @@
> 		goto err_ioremap;
> 	}
> 
>-	/* Work around the dropped serial bit. */
>-	prev_eedata = eeprom_read(ioaddr, 6);
>-	for (i = 0; i < 3; i++) {
>-		int eedata = eeprom_read(ioaddr, i + 7);
>-		dev->dev_addr[i*2] = (eedata << 1) + (prev_eedata >> 15);
>-		dev->dev_addr[i*2+1] = eedata >> 7;
>-		prev_eedata = eedata;
>+	if (find_cnt < ethaddr_num && strlen(ethaddr[find_cnt]) > 0) {
>+		int a[6];
>+		sscanf(ethaddr[find_cnt], "%2x:%2x:%2x:%2x:%2x:%2x",
>+			&a[0], &a[1], &a[2], &a[3], &a[4], &a[5]);
>+		for (i = 6; i--; )
>+			dev->dev_addr[i] = (unsigned char)a[i];
>+	} else {
>+		/* Work around the dropped serial bit. */
>+		prev_eedata = eeprom_read(ioaddr, 6);
>+		for (i = 0; i < 3; i++) {
>+			int eedata = eeprom_read(ioaddr, i + 7);
>+			dev->dev_addr[i*2] = (eedata << 1) + (prev_eedata >> 15);
>+			dev->dev_addr[i*2+1] = eedata >> 7;
>+			prev_eedata = eedata;
>+		}
> 	}
> 
> 	dev->base_addr = ioaddr;


 oooooooooooooooooooooooooooooooooooooooooooooooooo
 Gary Spiess (Gary.Spiess@Intermec.com)
 MobileLan Wireless Products Group, Intermec Technology Corp
 voice: 319 369-3580  fax: 319 369-3804
