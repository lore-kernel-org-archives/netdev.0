From: Gary Spiess <Gary.Spiess@Intermec.com>
Subject: Re: [PATCH] natsemi long cable fix
Date: Mon, 14 Feb 2005 16:53:14 -0600
Message-ID: <42112BDA.3050200@Intermec.com>
References: <421129DE.4070101@Intermec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: thockin@hockin.org
To: netdev@oss.sgi.com
In-Reply-To: <421129DE.4070101@Intermec.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When used with Revision D of the DP83815, the "Recommended Registers Configuration" from page 78 of the DP83815 data sheet is not entirely compatible with the driver's "short cable patch".  When the DSPCFG register is written with the value suggested in the document, then do_cable_magic() determines that all cables attached to the DP83815D are 
'short', regardless of actual length.  Short cables (< 30m) cause do_cable_magic to enable additional attenuation to reduce CRC and idle errors.  If the extra attenuation is unintentionally enabled for long cables (> 100m?), they will not operate properly.  The National Semiconductor driver, 'dp83815.c' from http://www.national.com/appinfo/networks/files/linux_2_4.tar.gz was used as a basis for this modification.

--- linux-2.6.10.orig/drivers/net/natsemi.c	2004-12-24 15:33:50.000000000 -0600
+++ linux-2.6.10/drivers/net/natsemi.c	2005-02-14 16:45:46.000000000 -0600
@@ -441,6 +441,7 @@
 #define DSPCFG_VAL	0x5040
 #define SDCFG_VAL	0x008c	/* set voltage thresholds for Signal Detect */
 #define DSPCFG_LOCK	0x20	/* coefficient lock bit in DSPCFG */
+#define DSPCFG_COEF	0x1000	/* see coefficient (in TSTDAT) bit in DSPCFG */
 #define TSTDAT_FIXED	0xe8	/* magic number for bad coefficients */
 
 /* misc PCI space registers */
@@ -1243,7 +1244,8 @@
 		writew(1, ioaddr + PGSEL);
 		writew(PMDCSR_VAL, ioaddr + PMDCSR);
 		writew(TSTDAT_VAL, ioaddr + TSTDAT);
-		np->dspcfg = DSPCFG_VAL;
+		np->dspcfg = (np->srr <= SRR_DP83815_C)?
+			DSPCFG_VAL : DSPCFG_COEF;
 		writew(np->dspcfg, ioaddr + DSPCFG);
 		writew(SDCFG_VAL, ioaddr + SDCFG);
 		writew(0, ioaddr + PGSEL);
