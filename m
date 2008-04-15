From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Wed, 16 Apr 2008 01:49:10 +0300
Message-ID: <480530E6.8020700@teltonika.lt>
References: <20080414213238.GB28833@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080100040801010303060208"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080414213238.GB28833-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080100040801010303060208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Reworked MAC address generation from USB serial number
Now it is very similar to the one done in the cdc_ether.c

Filip: Does the dummy MAC address have to start with 0xFA?

--------------080100040801010303060208
Content-Type: text/x-patch;
 name="hso_mac_gen.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_mac_gen.patch"

--- linux-2.6-hso/drivers/net/usb/hso.c	2008-04-15 23:56:33.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-16 01:22:56.000000000 +0300
@@ -345,7 +345,6 @@ static int hso_get_activity(struct hso_d
 /* convert a character representing a hex value to a number */
 static unsigned char hex2dec(unsigned char digit)
 {
-
 	if ((digit >= '0') && (digit <= '9'))
 		return (digit - '0');
 	/* Map all characters to 0-15 */
@@ -353,7 +352,7 @@ static unsigned char hex2dec(unsigned ch
 		return (digit - 'a' + 10) % 16;
 	if ((digit >= 'A') && (digit <= 'Z'))
 		return (digit - 'A' + 10) % 16;
-	return 16;
+	return 0;
 }
 
 #define SIOCSETRADIO   (SIOCDEVPRIVATE+4)
@@ -3032,7 +3031,6 @@ static void set_ethernet_addr(struct hso
 	int i = 0;
 	int len = 0;
 	unsigned char buffer[13];
-	unsigned char checkserial[7] = "Serial";
 
 	/* we can't fail, therefor we use a random macaddress */
 	random_ether_addr(mac_addr);
@@ -3048,26 +3046,11 @@ static void set_ethernet_addr(struct hso
 	len = usb_string(odev->parent->usb,
 			 odev->parent->usb->descriptor.iSerialNumber,
 			 buffer, 13);
-	if (len != 12) {
-		/* some devices don't have the serial filled in, checking ... */
-		for (i = 0; i < 6; i++) {
-			if (buffer[i] != checkserial[i]) {
-				/* Fill in the mac_addr */
-				for (i = 2; i < 6; i++) {
-					if ((16 == buffer[2 * i]) ||
-					    (16 == buffer[2 * i + 1])) {
-						dev_err(&odev->parent->usb->dev,
-							"Bad value in MAC "
-							"address i:%d\n", i);
-					} else {
-						mac_addr[i] =
-						    (hex2dec(buffer[2 * i]) <<
-						     4) + hex2dec(buffer[2 * i +
-									 1]);
-					}
-				}
-				break;
-			}
+	if (len != 12 && strcmp("Serial", buffer)) {
+		/* Fill in the mac_addr */
+		for (i = 1; i < 6; i++) {
+			mac_addr[i] = (hex2dec(buffer[2 * i]) << 4) +
+				       hex2dec(buffer[2 * i + 1]);
 		}
 	} else {
 		dev_err(&odev->parent->usb->dev, "Attempting to get MAC "
@@ -3236,7 +3219,7 @@ module_param(debug, int, S_IRUGO | S_IWU
 MODULE_PARM_DESC(tty_major, "Set the major tty number");
 module_param(tty_major, int, S_IRUGO | S_IWUSR);
 
-/* set the major tty number (eg: insmod hso.ko tty_major=245) */
+/* disable network interface (eg: insmod hso.ko disable_net=1) */
 MODULE_PARM_DESC(disable_net, "Disable the network interface");
 module_param(disable_net, int, S_IRUGO | S_IWUSR);
 

--------------080100040801010303060208--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
