From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] hp100 -- isa probe fix
Date: Thu, 26 Feb 2004 10:33:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040226103347.65bd7de9@dell_ss3.pdx.osdl.net>
References: <20040224170700.11adc3cc@dell_ss3.pdx.osdl.net>
	<20040225213347.5491.qmail@web14006.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Cacophonix <cacophonix@yahoo.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20040225213347.5491.qmail@web14006.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff, here is a cleaned up version of the 2.6.3 hp100 isa (non-modular) probing.
It needs to check for the board being present before reading the signature.

--- linux-2.6/drivers/net/hp100.c	2004-02-24 17:08:00.000000000 -0800
+++ test-2.6/drivers/net/hp100.c	2004-02-26 10:32:33.625878016 -0800
@@ -326,16 +326,21 @@ static __init const char *hp100_read_id(
 	return str;
 }
 
-static __init int hp100_isa_probe1(struct net_device *dev, int addr)
+static __init int hp100_isa_probe1(struct net_device *dev, int ioaddr)
 {
 	const char *sig;
 	int i;
 
-	if (!request_region(addr, HP100_REGION_SIZE, "hp100"))
+	if (!request_region(ioaddr, HP100_REGION_SIZE, "hp100"))
 		goto err;
 
-	sig = hp100_read_id(addr);
-	release_region(addr, HP100_REGION_SIZE);
+	if (hp100_inw(HW_ID) != HP100_HW_ID_CASCADE) {
+		release_region(ioaddr, HP100_REGION_SIZE);
+		goto err;
+	}
+
+	sig = hp100_read_id(ioaddr);
+	release_region(ioaddr, HP100_REGION_SIZE);
 
 	if (sig == NULL)
 		goto err;
@@ -347,7 +352,7 @@ static __init int hp100_isa_probe1(struc
 	}
 
 	if (i < ARRAY_SIZE(hp100_isa_tbl))
-		return hp100_probe1(dev, addr, HP100_BUS_ISA, NULL);
+		return hp100_probe1(dev, ioaddr, HP100_BUS_ISA, NULL);
  err:
 	return -ENODEV;
 
